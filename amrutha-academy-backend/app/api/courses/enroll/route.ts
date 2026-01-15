import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { EnrollmentService } from '@/lib/services/enrollmentService';
import { CreateEnrollmentRequest } from '@/types';

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

    const body: CreateEnrollmentRequest = await request.json();
    const { courseId } = body;

    if (!courseId) {
      return NextResponse.json(
        createErrorResponse('Course ID is required', 400),
        { status: 400 }
      );
    }

    try {
      const enrollment = await EnrollmentService.createEnrollment(user.id, courseId);
      
      return NextResponse.json(
        createSuccessResponse(enrollment, 201, ['Enrolled successfully']),
        { status: 201 }
      );
    } catch (error: any) {
      return NextResponse.json(
        createErrorResponse(error.message || 'Failed to enroll', 400),
        { status: 400 }
      );
    }
  } catch (error: any) {
    console.error('Enroll error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Internal server error', 500),
      { status: 500 }
    );
  }
}




