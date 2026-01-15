import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';
import { CourseExtended } from '@/types';
import { FieldValue } from 'firebase-admin/firestore';

export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json(
        createErrorResponse('Unauthorized', 401),
        { status: 401 }
      );
    }

    const token = authHeader.substring(7);
    const user = await verifyFirebaseToken(token);

    if (!user || user.role !== 'admin') {
      return NextResponse.json(
        createErrorResponse('Only admins can create courses', 403),
        { status: 403 }
      );
    }

    const body = await request.json();
    const {
      title,
      description,
      level,
      price,
      startDate,
      endDate,
      duration,
      category,
      image,
      trainerId,
    } = body;

    // Validation
    if (!title || !description || !level || !price || !startDate || !endDate || !duration) {
      return NextResponse.json(
        createErrorResponse('Missing required fields', 400),
        { status: 400 }
      );
    }

    if (![1, 2, 3].includes(level)) {
      return NextResponse.json(
        createErrorResponse('Level must be 1, 2, or 3', 400),
        { status: 400 }
      );
    }

    // Get trainer name if trainerId provided
    let trainerName = null;
    if (trainerId) {
      const trainerDoc = await db.collection(COLLECTIONS.USERS).doc(trainerId).get();
      if (trainerDoc.exists && trainerDoc.data()?.role === 'trainer') {
        trainerName = trainerDoc.data()?.fullName || null;
      }
    }

    const courseData = {
      title,
      description,
      level: parseInt(level),
      price: parseFloat(price),
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      duration: parseInt(duration),
      category: category || null,
      image: image || null,
      trainerId: trainerId || null,
      trainerName,
      adminId: user.id,
      createdAt: FieldValue.serverTimestamp(),
      // Legacy fields for compatibility
      originalPrice: parseFloat(price) * 1.2,
      rating: 0,
      reviewsCount: 0,
      students: 0,
      certificate: true,
      about: description,
    };

    const courseRef = await db.collection(COLLECTIONS.COURSES).add(courseData);
    const courseDoc = await courseRef.get();
    const data = courseDoc.data();

    const course: any = {
      id: courseDoc.id,
      title: data?.title || '',
      description: data?.description || '',
      level: data?.level || 1,
      price: data?.price || 0,
      startDate: data?.startDate?.toDate?.().toISOString() || startDate,
      endDate: data?.endDate?.toDate?.().toISOString() || endDate,
      duration: data?.duration || 0,
      category: data?.category || '',
      image: data?.image || '',
      trainerId: data?.trainerId,
      trainerName: data?.trainerName,
      adminId: data?.adminId,
      createdAt: data?.createdAt?.toDate?.().toISOString() || new Date().toISOString(),
      // Legacy fields for compatibility
      originalPrice: data?.originalPrice || 0,
      rating: data?.rating || 0,
      reviewsCount: data?.reviewsCount || 0,
      students: data?.students || 0,
      certificate: data?.certificate || false,
      mentor: { id: '', name: '', title: '', avatarUrl: '' },
      tools: [],
      about: data?.about || '',
    };

    return NextResponse.json(
      createSuccessResponse(course, 201, ['Course created successfully']),
      { status: 201 }
    );
  } catch (error: any) {
    console.error('Create course error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Failed to create course', 500),
      { status: 500 }
    );
  }
}

