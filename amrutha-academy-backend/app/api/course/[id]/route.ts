import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { CourseService } from '@/lib/services/courseService';
import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: courseId } = await params;
    const course = await CourseService.getCourseById(courseId);

    if (!course) {
      return NextResponse.json(
        createErrorResponse('Course not found', 404),
        { status: 404 }
      );
    }

    // Get extended fields from Firestore
    const courseDoc = await db.collection(COLLECTIONS.COURSES).doc(courseId).get();
    const courseData = courseDoc.data();

    const extendedCourse = {
      ...course,
      level: courseData?.level || 1,
      startDate: courseData?.startDate?.toDate?.().toISOString() || null,
      endDate: courseData?.endDate?.toDate?.().toISOString() || null,
      duration: courseData?.duration || course.duration,
      trainerId: courseData?.trainerId || null,
      trainerName: courseData?.trainerName || course.mentor?.name || null,
      adminId: courseData?.adminId || null,
      createdAt: courseData?.createdAt?.toDate?.().toISOString() || new Date().toISOString(),
    };

    return NextResponse.json(
      createSuccessResponse(extendedCourse, 200),
      { status: 200 }
    );
  } catch (error: any) {
    console.error('Course fetch error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Internal server error', 500),
      { status: 500 }
    );
  }
}
