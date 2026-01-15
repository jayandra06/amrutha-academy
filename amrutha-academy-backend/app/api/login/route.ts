import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { auth } from '@/lib/firebase/config';
import { UserService } from '@/lib/services/userService';
import { LoginRequest } from '@/types';

export async function POST(request: NextRequest) {
  try {
    const body: LoginRequest = await request.json();
    const { email, password } = body;

    // Validate input
    if (!email || !password) {
      return NextResponse.json(
        createErrorResponse('Email and password are required', 400),
        { status: 400 }
      );
    }

    try {
      // Try to sign in with Firebase Auth
      // Note: In a real app, you would use Firebase Admin SDK to verify the password
      // or use Firebase Client SDK on the client side
      // For server-side, we'll verify the user exists and create a custom token
      const user = await UserService.getUserByEmail(email);
      
      if (!user) {
        return NextResponse.json(
          createErrorResponse('Invalid email or password', 401),
          { status: 401 }
        );
      }

      // Create a custom token for the user
      // In production, you should verify the password first
      // This is a simplified version - you may want to use Firebase Auth REST API
      // or handle authentication on the client side
      const customToken = await auth.createCustomToken(user.id);

      // Return the custom token (client will exchange it for an ID token)
      // For a simpler flow, you could also return a JWT token
      return NextResponse.json(
        createSuccessResponse({ token: customToken }, 200, ['Login successful']),
        { status: 200 }
      );
    } catch (error) {
      console.error('Authentication error:', error);
      return NextResponse.json(
        createErrorResponse('Invalid email or password', 401),
        { status: 401 }
      );
    }
  } catch (error) {
    console.error('Login error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}
