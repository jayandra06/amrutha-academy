import { NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { SearchService } from '@/lib/services/searchService';

export async function GET() {
  try {
    const suggestions = await SearchService.getSearchSuggestions();
    
    return NextResponse.json(
      createSuccessResponse(suggestions, 200),
      { status: 200 }
    );
  } catch (error) {
    console.error('Search suggestions fetch error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}
