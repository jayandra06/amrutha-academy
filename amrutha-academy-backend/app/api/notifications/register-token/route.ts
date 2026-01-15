import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';
import { FieldValue } from 'firebase-admin/firestore';

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

    const body = await request.json();
    const { fcmToken } = body;

    if (!fcmToken) {
      return NextResponse.json(
        createErrorResponse('FCM token is required', 400),
        { status: 400 }
      );
    }

    // Store FCM token in user document
    await db.collection(COLLECTIONS.USERS).doc(user.id).update({
      fcmToken,
      fcmTokenUpdatedAt: FieldValue.serverTimestamp(),
    });

    return NextResponse.json(
      createSuccessResponse({ success: true }, 200, ['FCM token registered successfully']),
      { status: 200 }
    );
  } catch (error: any) {
    console.error('Register FCM token error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Internal server error', 500),
      { status: 500 }
    );
  }
}




