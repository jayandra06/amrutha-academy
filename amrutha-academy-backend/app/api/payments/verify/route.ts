import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { RazorpayService } from '@/lib/services/razorpayService';
import { EnrollmentService } from '@/lib/services/enrollmentService';
import { RazorpayVerifyRequest } from '@/types';

export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json(
        createErrorResponse('Unauthorized', 401),
        { status: 401 }
      );
    }

    const token = authHeader.substring(7);
    const user = await verifyFirebaseToken(token);

    if (!user) {
      return NextResponse.json(
        createErrorResponse('Unauthorized', 401),
        { status: 401 }
      );
    }

    const body: RazorpayVerifyRequest = await request.json();
    const { orderId, paymentId, signature, courseId } = body;

    if (!orderId || !paymentId || !signature) {
      return NextResponse.json(
        createErrorResponse('Order ID, payment ID, and signature are required', 400),
        { status: 400 }
      );
    }

    // Verify payment signature
    const isValid = RazorpayService.verifyPayment(orderId, paymentId, signature);

    if (!isValid) {
      return NextResponse.json(
        createErrorResponse('Invalid payment signature', 400),
        { status: 400 }
      );
    }

    // Get payment details from Razorpay
    const paymentDetails = await RazorpayService.getPaymentDetails(paymentId);

    if (paymentDetails.status !== 'captured' && paymentDetails.status !== 'authorized') {
      return NextResponse.json(
        createErrorResponse('Payment not successful', 400),
        { status: 400 }
      );
    }

    // If courseId is provided, create enrollment after successful payment
    let enrollment = null;
    if (courseId) {
      try {
        enrollment = await EnrollmentService.createEnrollment(user.id, courseId, paymentId);
      } catch (error: any) {
        // Enrollment might already exist, that's okay
        console.warn('Enrollment creation error:', error.message);
      }
    }

    return NextResponse.json(
      createSuccessResponse(
        {
          verified: true,
          paymentId,
          orderId,
          amount: paymentDetails.amount / 100, // Convert from paise to rupees
          status: paymentDetails.status,
          enrollment,
        },
        200,
        ['Payment verified successfully']
      ),
      { status: 200 }
    );
  } catch (error: any) {
    console.error('Verify payment error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Internal server error', 500),
      { status: 500 }
    );
  }
}




