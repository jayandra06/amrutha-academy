import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';
import { Attendance } from '@/types';
import { FieldValue } from 'firebase-admin/firestore';

export class AttendanceService {
  static async markAttendance(
    scheduleId: string,
    userId: string,
    status: string,
    joinedAt?: Date
  ): Promise<Attendance> {
    try {
      // Check if attendance already exists
      const existing = await this.getAttendanceByScheduleAndUser(scheduleId, userId);
      
      if (existing) {
        // Update existing attendance
        await db.collection(COLLECTIONS.ATTENDANCE).doc(existing.id).update({
          status,
          joinedAt: joinedAt || FieldValue.serverTimestamp(),
          markedAt: FieldValue.serverTimestamp(),
        });
        return await this.getAttendanceByScheduleAndUser(scheduleId, userId)!;
      }

      // Create new attendance record
      const attendanceData = {
        scheduleId,
        userId,
        status,
        joinedAt: joinedAt || FieldValue.serverTimestamp(),
        markedAt: FieldValue.serverTimestamp(),
      };

      const attendanceRef = await db.collection(COLLECTIONS.ATTENDANCE).add(attendanceData);
      const doc = await attendanceRef.get();
      const data = doc.data();

      return {
        id: doc.id,
        scheduleId: data?.scheduleId || '',
        userId: data?.userId || '',
        status: data?.status || 'absent',
        joinedAt: data?.joinedAt?.toDate?.().toISOString(),
        markedAt: data?.markedAt?.toDate?.().toISOString() || new Date().toISOString(),
      } as Attendance;
    } catch (error) {
      console.error('Error marking attendance:', error);
      throw error;
    }
  }

  static async getAttendanceByScheduleAndUser(
    scheduleId: string,
    userId: string
  ): Promise<Attendance | null> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.ATTENDANCE)
        .where('scheduleId', '==', scheduleId)
        .where('userId', '==', userId)
        .limit(1)
        .get();

      if (snapshot.empty) {
        return null;
      }

      const doc = snapshot.docs[0];
      const data = doc.data();

      return {
        id: doc.id,
        scheduleId: data?.scheduleId || '',
        userId: data?.userId || '',
        status: data?.status || 'absent',
        joinedAt: data?.joinedAt?.toDate?.().toISOString(),
        markedAt: data?.markedAt?.toDate?.().toISOString() || new Date().toISOString(),
      } as Attendance;
    } catch (error) {
      console.error('Error fetching attendance:', error);
      throw error;
    }
  }

  static async getAttendanceBySchedule(scheduleId: string): Promise<Attendance[]> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.ATTENDANCE)
        .where('scheduleId', '==', scheduleId)
        .get();

      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          scheduleId: data?.scheduleId || '',
          userId: data?.userId || '',
          status: data?.status || 'absent',
          joinedAt: data?.joinedAt?.toDate?.().toISOString(),
          markedAt: data?.markedAt?.toDate?.().toISOString() || new Date().toISOString(),
        } as Attendance;
      });
    } catch (error) {
      console.error('Error fetching attendance:', error);
      throw error;
    }
  }

  static async getUserAttendance(userId: string, courseId?: string): Promise<Attendance[]> {
    try {
      let query: any = db.collection(COLLECTIONS.ATTENDANCE)
        .where('userId', '==', userId);

      // If courseId provided, filter by schedules for that course
      if (courseId) {
        const schedulesSnapshot = await db
          .collection(COLLECTIONS.SCHEDULES)
          .where('courseId', '==', courseId)
          .get();
        
        const scheduleIds = schedulesSnapshot.docs.map(doc => doc.id);
        
        if (scheduleIds.length === 0) {
          return [];
        }

        query = query.where('scheduleId', 'in', scheduleIds);
      }

      const snapshot = await query.get();

      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          scheduleId: data?.scheduleId || '',
          userId: data?.userId || '',
          status: data?.status || 'absent',
          joinedAt: data?.joinedAt?.toDate?.().toISOString(),
          markedAt: data?.markedAt?.toDate?.().toISOString() || new Date().toISOString(),
        } as Attendance;
      });
    } catch (error) {
      console.error('Error fetching user attendance:', error);
      throw error;
    }
  }
}




