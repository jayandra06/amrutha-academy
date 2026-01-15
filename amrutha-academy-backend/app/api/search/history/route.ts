import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { SearchService } from '@/lib/services/searchService';

export async function GET(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json(
        createErrorResponse('Unauthorized - No token provided', 401),
        { status: 401 }
      );
    }

    const token = authHeader.substring(7);
    const user = await verifyFirebaseToken(token);

    if (!user) {
      return NextResponse.json(
        createErrorResponse('Unauthorized - Invalid token', 401),
        { status: 401 }
      );
    }

    const history = await SearchService.getSearchHistory(user.id);
    
    return NextResponse.json(
      createSuccessResponse(history, 200),
      { status: 200 }
    );
  } catch (error) {
    console.error('Search history fetch error:', error);
    return NextResponse.json(
      createErrorResponse('Internal server error', 500),
      { status: 500 }
    );
  }
}
