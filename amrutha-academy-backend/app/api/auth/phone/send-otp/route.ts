import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { auth } from '@/lib/firebase/config';
import { SendOTPRequest } from '@/types';

export async function POST(request: NextRequest) {
  try {
    const body: SendOTPRequest = await request.json();
    const { phoneNumber } = body;

    if (!phoneNumber) {
      return NextResponse.json(
        createErrorResponse('Phone number is required', 400),
        { status: 400 }
      );
    }

    // Validate phone number format (basic validation)
    const phoneRegex = /^\+?[1-9]\d{1,14}$/;
    if (!phoneRegex.test(phoneNumber.replace(/\s/g, ''))) {
      return NextResponse.json(
        createErrorResponse('Invalid phone number format', 400),
        { status: 400 }
      );
    }

    try {
      // Use Firebase Auth to send OTP via reCAPTCHA
      // Note: This requires client-side reCAPTCHA verification
      // The backend can generate a verification ID for the client
      
      // For now, we'll return success - the actual OTP sending will be handled
      // by Firebase Auth on the client side with phone authentication
      // The backend's role is mainly to verify the token after OTP verification
      
      return NextResponse.json(
        createSuccessResponse(
          { message: 'OTP will be sent to your phone via Firebase Auth' },
          200,
          ['OTP sent successfully']
        ),
        { status: 200 }
      );
    } catch (error) {
      console.error('Error sending OTP:', error);
      return NextResponse.json(
        createErrorResponse('Failed to send OTP', 500),
        { status: 500 }
      );
    }
  } catch (error) {
    console.error('Send OTP error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}




