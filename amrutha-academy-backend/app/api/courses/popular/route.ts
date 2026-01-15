import { NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { CourseService } from '@/lib/services/courseService';

export async function GET() {
  try {
    const popularCourses = await CourseService.getPopularCourses(10);
    
    return NextResponse.json(
      createSuccessResponse(popularCourses, 200),
      { status: 200 }
    );
  } catch (error) {
    console.error('Popular courses fetch error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}
