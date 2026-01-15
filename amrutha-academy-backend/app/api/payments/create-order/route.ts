import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { RazorpayService } from '@/lib/services/razorpayService';
import { RazorpayOrderRequest } from '@/types';

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

    const body: RazorpayOrderRequest = await request.json();
    const { amount, currency = 'INR', receipt, notes } = body;

    if (!amount || amount <= 0) {
      return NextResponse.json(
        createErrorResponse('Valid amount is required', 400),
        { status: 400 }
      );
    }

    try {
      const order = await RazorpayService.createOrder(amount, currency, receipt, {
        ...notes,
        userId: user.id,
        userEmail: user.email,
      });

      return NextResponse.json(
        createSuccessResponse(order, 201, ['Order created successfully']),
        { status: 201 }
      );
    } catch (error: any) {
      return NextResponse.json(
        createErrorResponse(error.message || 'Failed to create order', 500),
        { status: 500 }
      );
    }
  } catch (error: any) {
    console.error('Create order error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Internal server error', 500),
      { status: 500 }
    );
  }
}




