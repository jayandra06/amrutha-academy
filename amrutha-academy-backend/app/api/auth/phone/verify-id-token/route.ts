import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { auth } from '@/lib/firebase/config';
import { UserService } from '@/lib/services/userService';
import { createCustomToken } from '@/lib/utils/auth';
import { User } from '@/types';

/**
 * This endpoint verifies a Firebase ID token (from phone auth) and creates/returns user
 * The Flutter app will call this after Firebase Auth phone verification completes
 */
export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        createErrorResponse('Firebase ID token is required in Authorization header', 401),
        { status: 401 }
      );
    }

    const idToken = authHeader.substring(7);
    
    // Get role preference from request body (optional)
    let requestedRole = 'student';
    try {
      const body = await request.json();
      requestedRole = body.role || 'student';
    } catch {
      // If body is not valid JSON or empty, use default 'student'
      requestedRole = 'student';
    }
    
    try {
      // Verify the ID token
      const decodedToken = await auth.verifyIdToken(idToken);
      const firebaseUserId = decodedToken.uid;
      const phoneNumber = decodedToken.phone_number || '';

      // Check if user exists in Firestore
      let user = await UserService.getUserById(firebaseUserId);
      const isNewUser = !user;

      // If new user, create user record with requested role (trainer/student)
      if (isNewUser) {
        const userData: Partial<User> = {
          phoneNumber: phoneNumber,
          fullName: '',
          email: '',
          avatar: '',
          bio: '',
          birthday: '',
          location: '',
          role: requestedRole === 'trainer' ? 'trainer' : 'student',
        };

        user = await UserService.createUser(firebaseUserId, userData);
      } else {
        // For existing users, verify they have the correct role if trainer was requested
        // If user is trying to login as trainer but doesn't have trainer role, keep their existing role
        if (requestedRole === 'trainer' && user.role !== 'trainer') {
          // User doesn't have trainer role, they'll be logged in with their existing role (student)
          // This is acceptable - they'll just see student interface
        }
        // If user is trainer and login as trainer is selected, they're good
        // If user is trainer but login as student is selected, they'll be logged in as trainer (their actual role)
        // User's role in database takes precedence
      }

      // Create custom token (optional, client can use ID token directly)
      const customToken = await createCustomToken(firebaseUserId);

      return NextResponse.json(
        createSuccessResponse(
          {
            token: customToken,
            idToken: idToken,
            isNewUser,
            user,
          },
          200,
          ['Authentication successful']
        ),
        { status: 200 }
      );
    } catch (error: any) {
      console.error('Token verification error:', error);
      
      if (error.code === 'auth/invalid-credential' || error.code === 'auth/id-token-expired') {
        return NextResponse.json(
          createErrorResponse('Invalid or expired token', 401),
          { status: 401 }
        );
      }
      
      return NextResponse.json(
        createErrorResponse('Failed to verify token', 500),
        { status: 500 }
      );
    }
  } catch (error) {
    console.error('Verify ID token error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}




