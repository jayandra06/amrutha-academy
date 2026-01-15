import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { auth } from '@/lib/firebase/config';
import { UserService } from '@/lib/services/userService';
import { VerifyOTPRequest, User } from '@/types';
import { createCustomToken } from '@/lib/utils/auth';
import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';

export async function POST(request: NextRequest) {
  try {
    const body: VerifyOTPRequest = await request.json();
    const { phoneNumber, otp, verificationId } = body;

    if (!phoneNumber || !otp || !verificationId) {
      return NextResponse.json(
        createErrorResponse('Phone number, OTP, and verification ID are required', 400),
        { status: 400 }
      );
    }

    try {
      // Note: Firebase Auth phone verification happens on the client side
      // The client sends the ID token after verifying the OTP
      // This endpoint expects the client to send the Firebase ID token instead of OTP
      // For proper implementation, we should verify the ID token here

      // Alternative approach: Accept Firebase ID token directly
      const authHeader = request.headers.get('authorization');
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return NextResponse.json(
          createErrorResponse('Firebase ID token is required in Authorization header', 401),
          { status: 401 }
        );
      }

      const idToken = authHeader.substring(7);
      
      // Verify the ID token
      const decodedToken = await auth.verifyIdToken(idToken);
      const firebaseUserId = decodedToken.uid;

      // Check if user exists
      let user = await UserService.getUserById(firebaseUserId);
      const isNewUser = !user;

      // If new user, create user record
      if (isNewUser) {
        // Extract phone number from token claims if available
        const phoneFromToken = decodedToken.phone_number || phoneNumber;
        
        const userData: Partial<User> = {
          phoneNumber: phoneFromToken,
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

      // Create custom token for client (optional, since we already have ID token)
      const customToken = await createCustomToken(firebaseUserId);

      return NextResponse.json(
        createSuccessResponse(
          {
            token: customToken,
            idToken: idToken, // Also return the ID token
            isNewUser,
            user,
          },
          200,
          ['OTP verified successfully']
        ),
        { status: 200 }
      );
    } catch (error: any) {
      console.error('OTP verification error:', error);
      
      if (error.code === 'auth/invalid-credential') {
        return NextResponse.json(
          createErrorResponse('Invalid OTP or verification ID', 401),
          { status: 401 }
        );
      }
      
      return NextResponse.json(
        createErrorResponse('Failed to verify OTP', 500),
        { status: 500 }
      );
    }
  } catch (error) {
    console.error('Verify OTP error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}




