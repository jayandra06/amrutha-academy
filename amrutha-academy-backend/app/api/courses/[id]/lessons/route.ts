import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { CourseService } from '@/lib/services/courseService';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const lessons = await CourseService.getLessonsByCourseId(id);

    return NextResponse.json(
      createSuccessResponse(lessons, 200),
      { status: 200 }
    );
  } catch (error) {
    console.error('Lessons fetch error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}



