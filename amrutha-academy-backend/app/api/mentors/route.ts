import { NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { MentorService } from '@/lib/services/courseService';

export async function GET() {
  try {
    const mentors = await MentorService.getAllMentors();
    
    return NextResponse.json(
      createSuccessResponse(mentors, 200),
      { status: 200 }
    );
  } catch (error) {
    console.error('Mentors fetch error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}
