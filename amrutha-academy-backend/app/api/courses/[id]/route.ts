import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { CourseService } from '@/lib/services/courseService';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const course = await CourseService.getCourseById(id);

    if (!course) {
      return NextResponse.json(
        createErrorResponse('Course not found', 404),
        { status: 404 }
      );
    }

    // Transform to include extended fields if available
    const courseDoc = await CourseService['db']
      ?.collection(CourseService['COLLECTIONS']?.COURSES || 'courses')
      .doc(id)
      .get();

    const courseData = courseDoc?.data();
    const extendedCourse = {
      ...course,
      level: courseData?.level || 1,
      startDate: courseData?.startDate?.toDate?.().toISOString() || null,
      endDate: courseData?.endDate?.toDate?.().toISOString() || null,
      duration: courseData?.duration || course.duration,
      trainerId: courseData?.trainerId || null,
      trainerName: courseData?.trainerName || course.mentor?.name || null,
      adminId: courseData?.adminId || null,
    };

    return NextResponse.json(
      createSuccessResponse(extendedCourse, 200),
      { status: 200 }
    );
  } catch (error: any) {
    console.error('Get course error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Internal server error', 500),
      { status: 500 }
    );
  }
}


