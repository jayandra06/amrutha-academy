import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';
import { Enrollment, CourseExtended } from '@/types';
import { FieldValue } from 'firebase-admin/firestore';

export class EnrollmentService {
  static async createEnrollment(
    userId: string,
    courseId: string,
    paymentId?: string
  ): Promise<Enrollment> {
    try {
      // Check if enrollment already exists
      const existing = await this.getEnrollmentByUserAndCourse(userId, courseId);
      if (existing) {
        throw new Error('User is already enrolled in this course');
      }

      // Get course to extract end date for chat room
      const courseDoc = await db.collection(COLLECTIONS.COURSES).doc(courseId).get();
      if (!courseDoc.exists) {
        throw new Error('Course not found');
      }

      const courseData = courseDoc.data();
      const endDate = courseData?.endDate?.toDate?.() || new Date();

      // Create chat room ID (will be used to create Realtime DB room)
      const chatRoomId = `chat_${courseId}_${Date.now()}`;

      const enrollmentData = {
        userId,
        courseId,
        paymentStatus: paymentId ? 'completed' : 'pending',
        paymentId: paymentId || null,
        enrolledAt: FieldValue.serverTimestamp(),
        status: 'active',
        chatRoomId,
      };

      const enrollmentRef = await db.collection(COLLECTIONS.ENROLLMENTS).add(enrollmentData);

      // Create chat room in Firestore
      await db.collection(COLLECTIONS.CHAT_ROOMS).doc(chatRoomId).set({
        courseId,
        courseName: courseData?.title || '',
        enrollmentId: enrollmentRef.id,
        createdAt: FieldValue.serverTimestamp(),
        endDate: endDate,
        status: 'active',
        participants: [userId], // Will be updated when trainer/admin join
        roomId: `rooms/${chatRoomId}`, // Firebase Realtime DB path
      });

      return await this.getEnrollmentById(enrollmentRef.id)!;
    } catch (error) {
      console.error('Error creating enrollment:', error);
      throw error;
    }
  }

  static async getEnrollmentById(enrollmentId: string): Promise<Enrollment | null> {
    try {
      const doc = await db.collection(COLLECTIONS.ENROLLMENTS).doc(enrollmentId).get();
      if (!doc.exists) {
        return null;
      }

      const data = doc.data();
      return {
        id: doc.id,
        userId: data?.userId || '',
        courseId: data?.courseId || '',
        paymentStatus: data?.paymentStatus || 'pending',
        paymentId: data?.paymentId,
        enrolledAt: data?.enrolledAt?.toDate?.().toISOString() || new Date().toISOString(),
        status: data?.status || 'pending',
        chatRoomId: data?.chatRoomId,
      } as Enrollment;
    } catch (error) {
      console.error('Error fetching enrollment:', error);
      throw error;
    }
  }

  static async getEnrollmentByUserAndCourse(
    userId: string,
    courseId: string
  ): Promise<Enrollment | null> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.ENROLLMENTS)
        .where('userId', '==', userId)
        .where('courseId', '==', courseId)
        .limit(1)
        .get();

      if (snapshot.empty) {
        return null;
      }

      const doc = snapshot.docs[0];
      const data = doc.data();
      return {
        id: doc.id,
        userId: data?.userId || '',
        courseId: data?.courseId || '',
        paymentStatus: data?.paymentStatus || 'pending',
        paymentId: data?.paymentId,
        enrolledAt: data?.enrolledAt?.toDate?.().toISOString() || new Date().toISOString(),
        status: data?.status || 'pending',
        chatRoomId: data?.chatRoomId,
      } as Enrollment;
    } catch (error) {
      console.error('Error fetching enrollment:', error);
      throw error;
    }
  }

  static async getUserEnrollments(userId: string): Promise<Enrollment[]> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.ENROLLMENTS)
        .where('userId', '==', userId)
        .orderBy('enrolledAt', 'desc')
        .get();

      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          userId: data?.userId || '',
          courseId: data?.courseId || '',
          paymentStatus: data?.paymentStatus || 'pending',
          paymentId: data?.paymentId,
          enrolledAt: data?.enrolledAt?.toDate?.().toISOString() || new Date().toISOString(),
          status: data?.status || 'pending',
          chatRoomId: data?.chatRoomId,
        } as Enrollment;
      });
    } catch (error) {
      console.error('Error fetching enrollments:', error);
      throw error;
    }
  }

  static async updateEnrollmentStatus(
    enrollmentId: string,
    status: string
  ): Promise<Enrollment> {
    try {
      await db.collection(COLLECTIONS.ENROLLMENTS).doc(enrollmentId).update({
        status,
        updatedAt: FieldValue.serverTimestamp(),
      });

      return await this.getEnrollmentById(enrollmentId)!;
    } catch (error) {
      console.error('Error updating enrollment:', error);
      throw error;
    }
  }
}




