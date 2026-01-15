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
    
    try {
      // Verify the ID token
      const decodedToken = await auth.verifyIdToken(idToken);
      const firebaseUserId = decodedToken.uid;
      const phoneNumber = decodedToken.phone_number || '';

      // Check if user exists in Firestore
      let user = await UserService.getUserById(firebaseUserId);
      const isNewUser = !user;

      // If new user, create user record
      if (isNewUser) {
        const userData: Partial<User> = {
          phoneNumber: phoneNumber,
          fullName: '',
          email: '',
          avatar: '',
          bio: '',
          birthday: '',
          location: '',
          role: 'student', // Default role
        };

        user = await UserService.createUser(firebaseUserId, userData);
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




