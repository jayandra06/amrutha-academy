import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { CourseService } from '@/lib/services/courseService';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const reviews = await CourseService.getReviewsByCourseId(id);

    return NextResponse.json(
      createSuccessResponse(reviews, 200),
      { status: 200 }
    );
  } catch (error) {
    console.error('Reviews fetch error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}



