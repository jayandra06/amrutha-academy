import { NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { PromoteService } from '@/lib/services/courseService';

export async function GET() {
  try {
    const promotes = await PromoteService.getActivePromotes();
    
    return NextResponse.json(
      createSuccessResponse(promotes, 200),
      { status: 200 }
    );
  } catch (error) {
    console.error('Promote fetch error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}
