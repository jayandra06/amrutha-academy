import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { UserService } from '@/lib/services/userService';
import { auth, db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';
import { User } from '@/types';

export async function POST(request: NextRequest) {
  try {
    // Check if Firebase is initialized
    if (!db) {
      console.error('Firebase database not initialized');
      console.error('Please ensure:');
      console.error('  1. Service account JSON file exists in backend root, OR');
      console.error('  2. GOOGLE_APPLICATION_CREDENTIALS env var is set, OR');
      console.error('  3. FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY env vars are set');
      return NextResponse.json(
        createErrorResponse('Database not initialized. Check Firebase configuration. See server logs for details.', 500),
        { 
          status: 500,
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );
    }

    // Parse request body
    let body;
    try {
      body = await request.json();
    } catch (parseError: any) {
      console.error('Error parsing request body:', parseError);
      return NextResponse.json(
        createErrorResponse('Invalid request body. Expected JSON.', 400),
        { 
          status: 400,
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );
    }

    const { fullName, email, phoneNumber, role, bio, birthday, location } = body;

    // Validate required fields
    if (!fullName || !role) {
      return NextResponse.json(
        createErrorResponse('Full name and role are required', 400),
        { status: 400 }
      );
    }

    // Validate role
    if (!['student', 'trainer', 'admin'].includes(role)) {
      return NextResponse.json(
        createErrorResponse('Role must be student, trainer, or admin', 400),
        { status: 400 }
      );
    }

    // Format phone number if provided
    let formattedPhoneNumber = phoneNumber || '';
    if (formattedPhoneNumber && !formattedPhoneNumber.startsWith('+')) {
      // Add +91 for India if no country code
      formattedPhoneNumber = `+91${formattedPhoneNumber}`;
    }

    // Generate a unique user ID (you can also use a UUID library)
    const userId = `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // Create user data
    const userData: Partial<User> = {
      fullName: fullName.trim(),
      email: email?.trim() || '',
      phoneNumber: formattedPhoneNumber,
      role: role as 'student' | 'trainer' | 'admin',
      bio: bio?.trim() || '',
      birthday: birthday || '',
      location: location?.trim() || '',
      avatar: '',
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // Check if user with same phone number or email already exists
    // Note: Skip duplicate check for now if Firestore is having auth issues
    // This allows users to be created even if the query fails
    if (formattedPhoneNumber) {
      try {
        const existingByPhone = await db
          .collection(COLLECTIONS.USERS)
          .where('phoneNumber', '==', formattedPhoneNumber)
          .limit(1)
          .get();

        if (!existingByPhone.empty) {
          return NextResponse.json(
            createErrorResponse('User with this phone number already exists', 409),
            { status: 409 }
          );
        }
      } catch (error: any) {
        // If it's an authentication error, log it but continue (allow user creation)
        // The duplicate check is a nice-to-have, not critical
        if (error.code === 16 || error.message?.includes('UNAUTHENTICATED')) {
          console.warn('⚠️ Firestore authentication error during duplicate check. Continuing with user creation...');
          console.warn('Error details:', error.message);
          // Continue with user creation - skip duplicate check
        } else {
          // For other errors, still fail
          console.error('Error checking existing phone number:', error);
          return NextResponse.json(
            createErrorResponse(`Error checking phone number: ${error.message}`, 500),
            { status: 500 }
          );
        }
      }
    }

    if (email) {
      try {
        const existingByEmail = await UserService.getUserByEmail(email);
        if (existingByEmail) {
          return NextResponse.json(
            createErrorResponse('User with this email already exists', 409),
            { status: 409 }
          );
        }
      } catch (error: any) {
        console.error('Error checking existing email:', error);
        return NextResponse.json(
          createErrorResponse(`Error checking email: ${error.message}`, 500),
          { status: 500 }
        );
      }
    }

    // Create user in Firestore
    let user;
    try {
      user = await UserService.createUser(userId, userData);
    } catch (error: any) {
      console.error('Error creating user in Firestore:', error);
      return NextResponse.json(
        createErrorResponse(`Failed to create user in Firestore: ${error.message}`, 500),
        { status: 500 }
      );
    }

    // Optionally create user in Firebase Auth if phone number is provided
    // Note: This requires Firebase Admin SDK auth
    if (formattedPhoneNumber && auth) {
      try {
        // Check if user already exists in Firebase Auth
        try {
          const existingAuthUser = await auth.getUserByPhoneNumber(formattedPhoneNumber);
          if (existingAuthUser) {
            console.log(`Firebase Auth user already exists for phone: ${formattedPhoneNumber}`);
            // Update the Firestore user ID to match Firebase Auth UID
            if (existingAuthUser.uid !== userId) {
              // Update Firestore document to use Firebase Auth UID
              await db.collection(COLLECTIONS.USERS).doc(existingAuthUser.uid).set(userData);
              await db.collection(COLLECTIONS.USERS).doc(userId).delete();
              user.id = existingAuthUser.uid;
            }
          }
        } catch (authError: any) {
          // User doesn't exist in Firebase Auth, create one
          if (authError.code === 'auth/user-not-found') {
            try {
              await auth.createUser({
                phoneNumber: formattedPhoneNumber,
                displayName: fullName,
                email: email || undefined,
              });
              console.log(`Firebase Auth user created for phone: ${formattedPhoneNumber}`);
            } catch (createError: any) {
              console.warn(`Could not create Firebase Auth user: ${createError.message}`);
              // Continue anyway - user exists in Firestore
            }
          }
        }
      } catch (error: any) {
        console.warn(`Firebase Auth operation failed: ${error.message}`);
        // Continue anyway - user exists in Firestore
      }
    }

    return NextResponse.json(
      createSuccessResponse(
        {
          user,
          message: 'User created successfully',
        },
        201,
        ['User created successfully']
      ),
      { status: 201 }
    );
  } catch (error: any) {
    console.error('Error creating user:', error);
    console.error('Error name:', error?.name);
    console.error('Error code:', error?.code);
    console.error('Error message:', error?.message);
    console.error('Error stack:', error?.stack);
    
    // Ensure we always return a valid JSON response
    let errorMessage = 'Failed to create user';
    if (error?.message) {
      errorMessage = error.message;
    } else if (typeof error === 'string') {
      errorMessage = error;
    }
    
    const errorResponse = createErrorResponse(errorMessage, 500);
    
    console.log('Returning error response:', JSON.stringify(errorResponse));
    
    return NextResponse.json(errorResponse, { 
      status: 500,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }
}

