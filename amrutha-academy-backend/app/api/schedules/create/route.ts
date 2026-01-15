import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';
import { CreateScheduleRequest, Schedule } from '@/types';
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

    if (!user || (user.role !== 'admin' && user.role !== 'trainer')) {
      return NextResponse.json(
        createErrorResponse('Only admins and trainers can create schedules', 403),
        { status: 403 }
      );
    }

    const body: CreateScheduleRequest = await request.json();
    const { courseId, trainerId, startTime, endTime, date, meetingLink } = body;

    if (!courseId || !trainerId || !startTime || !endTime || !date) {
      return NextResponse.json(
        createErrorResponse('Missing required fields', 400),
        { status: 400 }
      );
    }

    // Verify trainer exists and has trainer role
    const trainerDoc = await db.collection(COLLECTIONS.USERS).doc(trainerId).get();
    if (!trainerDoc.exists || trainerDoc.data()?.role !== 'trainer') {
      return NextResponse.json(
        createErrorResponse('Invalid trainer', 400),
        { status: 400 }
      );
    }

    // Generate Jitsi Meet link if not provided
    const meetingLinkToUse = meetingLink || `https://meet.jit.si/${courseId}_${Date.now()}`;

    const scheduleData = {
      courseId,
      trainerId,
      startTime: new Date(startTime),
      endTime: new Date(endTime),
      date: new Date(date),
      meetingLink: meetingLinkToUse,
      status: 'scheduled',
      attendanceEnabled: true,
      createdAt: FieldValue.serverTimestamp(),
    };

    const scheduleRef = await db.collection(COLLECTIONS.SCHEDULES).add(scheduleData);
    const scheduleDoc = await scheduleRef.get();
    const data = scheduleDoc.data();

    const schedule: Schedule = {
      id: scheduleDoc.id,
      courseId: data?.courseId || '',
      trainerId: data?.trainerId || '',
      startTime: data?.startTime?.toDate?.().toISOString() || startTime,
      endTime: data?.endTime?.toDate?.().toISOString() || endTime,
      date: data?.date?.toDate?.().toISOString() || date,
      meetingLink: data?.meetingLink,
      status: data?.status || 'scheduled',
      attendanceEnabled: data?.attendanceEnabled || true,
    };

    return NextResponse.json(
      createSuccessResponse(schedule, 201, ['Schedule created successfully']),
      { status: 201 }
    );
  } catch (error: any) {
    console.error('Create schedule error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Failed to create schedule', 500),
      { status: 500 }
    );
  }
}




