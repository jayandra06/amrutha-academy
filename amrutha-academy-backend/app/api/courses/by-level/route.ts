import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const level = searchParams.get('level');

    if (!level || !['1', '2', '3'].includes(level)) {
      return NextResponse.json(
        createErrorResponse('Valid level (1, 2, or 3) is required', 400),
        { status: 400 }
      );
    }

    const snapshot = await db
      .collection(COLLECTIONS.COURSES)
      .where('level', '==', parseInt(level))
      .orderBy('startDate', 'asc')
      .get();

    const courses = snapshot.docs.map(doc => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        startDate: data?.startDate?.toDate?.().toISOString() || null,
        endDate: data?.endDate?.toDate?.().toISOString() || null,
        createdAt: data?.createdAt?.toDate?.().toISOString() || null,
      };
    });

    return NextResponse.json(
      createSuccessResponse(courses, 200),
      { status: 200 }
    );
  } catch (error: any) {
    console.error('Get courses by level error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Internal server error', 500),
      { status: 500 }
    );
  }
}




