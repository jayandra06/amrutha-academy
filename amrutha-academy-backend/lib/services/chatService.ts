import { db, database } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';
import { ChatRoom } from '@/types';
import { FieldValue } from 'firebase-admin/firestore';

export class ChatService {
  static async getChatRoomById(roomId: string): Promise<ChatRoom | null> {
    try {
      const doc = await db.collection(COLLECTIONS.CHAT_ROOMS).doc(roomId).get();
      if (!doc.exists) {
        return null;
      }

      const data = doc.data();
      return {
        id: doc.id,
        courseId: data?.courseId || '',
        courseName: data?.courseName || '',
        enrollmentId: data?.enrollmentId || '',
        createdAt: data?.createdAt?.toDate?.().toISOString() || new Date().toISOString(),
        endDate: data?.endDate?.toDate?.().toISOString() || new Date().toISOString(),
        status: data?.status || 'active',
        participants: data?.participants || [],
        roomId: data?.roomId || '',
      } as ChatRoom;
    } catch (error) {
      console.error('Error fetching chat room:', error);
      throw error;
    }
  }

  static async getUserChatRooms(userId: string): Promise<ChatRoom[]> {
    try {
      // Get enrollments for user
      const enrollmentsSnapshot = await db
        .collection(COLLECTIONS.ENROLLMENTS)
        .where('userId', '==', userId)
        .get();

      const chatRoomIds = enrollmentsSnapshot.docs
        .map(doc => doc.data().chatRoomId)
        .filter(Boolean);

      if (chatRoomIds.length === 0) {
        return [];
      }

      // Fetch chat rooms
      const rooms: ChatRoom[] = [];
      for (const roomId of chatRoomIds) {
        const room = await this.getChatRoomById(roomId);
        if (room) {
          rooms.push(room);
        }
      }

      return rooms;
    } catch (error) {
      console.error('Error fetching user chat rooms:', error);
      throw error;
    }
  }

  static async updateChatRoomStatus(roomId: string, status: string): Promise<void> {
    try {
      await db.collection(COLLECTIONS.CHAT_ROOMS).doc(roomId).update({
        status,
        updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (error) {
      console.error('Error updating chat room status:', error);
      throw error;
    }
  }

  static async addParticipant(roomId: string, userId: string): Promise<void> {
    try {
      const roomRef = db.collection(COLLECTIONS.CHAT_ROOMS).doc(roomId);
      await roomRef.update({
        participants: FieldValue.arrayUnion(userId),
        updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (error) {
      console.error('Error adding participant:', error);
      throw error;
    }
  }

  static async checkChatRoomAccess(roomId: string, userId: string): Promise<boolean> {
    try {
      const room = await this.getChatRoomById(roomId);
      if (!room) {
        return false;
      }

      // Check if user is a participant
      if (!room.participants.includes(userId)) {
        return false;
      }

      // Check if room is active or read-only
      const endDate = new Date(room.endDate);
      const now = new Date();
      const isExpired = now > endDate;

      if (isExpired && room.status !== 'read-only') {
        // Update status to read-only
        await this.updateChatRoomStatus(roomId, 'read-only');
        room.status = 'read-only';
      }

      // Allow access even if read-only (for viewing messages)
      return true;
    } catch (error) {
      console.error('Error checking chat room access:', error);
      return false;
    }
  }

  static canUserSendMessage(room: ChatRoom): boolean {
    if (room.status === 'read-only') {
      return false;
    }

    const endDate = new Date(room.endDate);
    const now = new Date();
    return now <= endDate;
  }

  // Method to sync chat room status based on course end date
  static async syncChatRoomStatuses(): Promise<void> {
    try {
      const snapshot = await db.collection(COLLECTIONS.CHAT_ROOMS)
        .where('status', '==', 'active')
        .get();

      const now = new Date();

      for (const doc of snapshot.docs) {
        const data = doc.data();
        const endDate = data?.endDate?.toDate?.();

        if (endDate && now > endDate) {
          await this.updateChatRoomStatus(doc.id, 'read-only');
        }
      }
    } catch (error) {
      console.error('Error syncing chat room statuses:', error);
      throw error;
    }
  }
}

