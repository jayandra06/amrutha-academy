import { NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { CategoryService } from '@/lib/services/courseService';

export async function GET() {
  try {
    const categories = await CategoryService.getAllCategories();
    
    return NextResponse.json(
      createSuccessResponse(categories, 200),
      { status: 200 }
    );
  } catch (error) {
    console.error('Categories fetch error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}
