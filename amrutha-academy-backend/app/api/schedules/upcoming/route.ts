import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';
import { Schedule } from '@/types';

export async function GET(request: NextRequest) {
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

    if (!user) {
      return NextResponse.json(
        createErrorResponse('Unauthorized', 401),
        { status: 401 }
      );
    }

    const { searchParams } = new URL(request.url);
    const courseId = searchParams.get('courseId');

    let schedules: Schedule[] = [];
    const now = new Date();

    if (user.role === 'student') {
      // Get student enrollments
      const enrollmentsSnapshot = await db
        .collection(COLLECTIONS.ENROLLMENTS)
        .where('userId', '==', user.id)
        .get();
      
      const enrolledCourseIds = enrollmentsSnapshot.docs.map(doc => doc.data().courseId);
      
      if (enrolledCourseIds.length === 0) {
        return NextResponse.json(
          createSuccessResponse([], 200),
          { status: 200 }
        );
      }

      // Filter by courseId if provided
      const courseIds = courseId 
        ? enrolledCourseIds.filter(id => id === courseId)
        : enrolledCourseIds;

      if (courseIds.length === 0) {
        return NextResponse.json(
          createSuccessResponse([], 200),
          { status: 200 }
        );
      }

      // Fetch schedules for enrolled courses
      for (const cId of courseIds) {
        const snapshot = await db
          .collection(COLLECTIONS.SCHEDULES)
          .where('courseId', '==', cId)
          .where('startTime', '>=', now)
          .orderBy('startTime', 'asc')
          .limit(50)
          .get();
        
        schedules.push(...snapshot.docs.map(doc => {
          const data = doc.data();
          return {
            id: doc.id,
            courseId: data?.courseId || '',
            trainerId: data?.trainerId || '',
            startTime: data?.startTime?.toDate?.().toISOString() || '',
            endTime: data?.endTime?.toDate?.().toISOString() || '',
            date: data?.date?.toDate?.().toISOString() || '',
            meetingLink: data?.meetingLink,
            status: data?.status || 'scheduled',
            attendanceEnabled: data?.attendanceEnabled || true,
          } as Schedule;
        }));
      }

      // Sort all schedules by startTime
      schedules.sort((a, b) => 
        new Date(a.startTime).getTime() - new Date(b.startTime).getTime()
      );

      schedules = schedules.slice(0, 50);
    } else if (user.role === 'trainer') {
      // For trainers, get their schedules
      let query: any = db
        .collection(COLLECTIONS.SCHEDULES)
        .where('trainerId', '==', user.id)
        .where('startTime', '>=', now)
        .orderBy('startTime', 'asc')
        .limit(50);

      if (courseId) {
        query = query.where('courseId', '==', courseId);
      }

      const snapshot = await query.get();
      schedules = snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          courseId: data?.courseId || '',
          trainerId: data?.trainerId || '',
          startTime: data?.startTime?.toDate?.().toISOString() || '',
          endTime: data?.endTime?.toDate?.().toISOString() || '',
          date: data?.date?.toDate?.().toISOString() || '',
          meetingLink: data?.meetingLink,
          status: data?.status || 'scheduled',
          attendanceEnabled: data?.attendanceEnabled || true,
        } as Schedule;
      });
    } else {
      // For admins, get all schedules
      let query: any = db
        .collection(COLLECTIONS.SCHEDULES)
        .where('startTime', '>=', now)
        .orderBy('startTime', 'asc')
        .limit(50);

      if (courseId) {
        query = query.where('courseId', '==', courseId);
      }

      const snapshot = await query.get();
      schedules = snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          courseId: data?.courseId || '',
          trainerId: data?.trainerId || '',
          startTime: data?.startTime?.toDate?.().toISOString() || '',
          endTime: data?.endTime?.toDate?.().toISOString() || '',
          date: data?.date?.toDate?.().toISOString() || '',
          meetingLink: data?.meetingLink,
          status: data?.status || 'scheduled',
          attendanceEnabled: data?.attendanceEnabled || true,
        } as Schedule;
      });
    }

    return NextResponse.json(
      createSuccessResponse(schedules, 200),
      { status: 200 }
    );
  } catch (error: any) {
    console.error('Get upcoming schedules error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Internal server error', 500),
      { status: 500 }
    );
  }
}

