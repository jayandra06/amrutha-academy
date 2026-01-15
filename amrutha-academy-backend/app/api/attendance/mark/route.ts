import { NextRequest, NextResponse } from 'next/server';
import { createSuccessResponse, createErrorResponse } from '@/lib/utils/apiResponse';
import { verifyFirebaseToken } from '@/lib/utils/auth';
import { AttendanceService } from '@/lib/services/attendanceService';

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

    if (!user) {
      return NextResponse.json(
        createErrorResponse('Unauthorized', 401),
        { status: 401 }
      );
    }

    const body = await request.json();
    const { scheduleId, userId, status, joinedAt } = body;

    if (!scheduleId || !status) {
      return NextResponse.json(
        createErrorResponse('Schedule ID and status are required', 400),
        { status: 400 }
      );
    }

    // Only allow marking attendance for self (students) or by trainers/admins for others
    const targetUserId = userId || user.id;
    if (targetUserId !== user.id && user.role !== 'trainer' && user.role !== 'admin') {
      return NextResponse.json(
        createErrorResponse('Unauthorized to mark attendance for this user', 403),
        { status: 403 }
      );
    }

    if (!['present', 'absent'].includes(status)) {
      return NextResponse.json(
        createErrorResponse('Status must be "present" or "absent"', 400),
        { status: 400 }
      );
    }

    const joinedAtDate = joinedAt ? new Date(joinedAt) : undefined;
    const attendance = await AttendanceService.markAttendance(
      scheduleId,
      targetUserId,
      status,
      joinedAtDate
    );

    return NextResponse.json(
      createSuccessResponse(attendance, 201, ['Attendance marked successfully']),
      { status: 201 }
    );
  } catch (error: any) {
    console.error('Mark attendance error:', error);
    return NextResponse.json(
      createErrorResponse(error.message || 'Internal server error', 500),
      { status: 500 }
    );
  }
}




