import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';
import { User } from '@/types';

export class UserService {
  static async getUserById(userId: string): Promise<User | null> {
    try {
      const userDoc = await db.collection(COLLECTIONS.USERS).doc(userId).get();
      
      if (!userDoc.exists) {
        return null;
      }

      const data = userDoc.data();
      return {
        id: userDoc.id,
        fullName: data?.fullName || '',
        email: data?.email || '',
        avatar: data?.avatar || '',
        bio: data?.bio || '',
        phoneNumber: data?.phoneNumber || '',
        birthday: data?.birthday?.toDate?.().toISOString() || data?.birthday || '',
        location: data?.location || '',
        role: data?.role || 'student',
      } as User;
    } catch (error) {
      console.error('Error fetching user:', error);
      throw error;
    }
  }

  static async getUserByEmail(email: string): Promise<User | null> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.USERS)
        .where('email', '==', email)
        .limit(1)
        .get();

      if (snapshot.empty) {
        return null;
      }

      const userDoc = snapshot.docs[0];
      const data = userDoc.data();
      
      return {
        id: userDoc.id,
        fullName: data?.fullName || '',
        email: data?.email || '',
        avatar: data?.avatar || '',
        bio: data?.bio || '',
        phoneNumber: data?.phoneNumber || '',
        birthday: data?.birthday?.toDate?.().toISOString() || data?.birthday || '',
        location: data?.location || '',
        role: data?.role || 'student',
      } as User;
    } catch (error) {
      console.error('Error fetching user by email:', error);
      throw error;
    }
  }

  static async createUser(userId: string, userData: Partial<User>): Promise<User> {
    try {
      await db.collection(COLLECTIONS.USERS).doc(userId).set({
        ...userData,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      return (await this.getUserById(userId))!;
    } catch (error) {
      console.error('Error creating user:', error);
      throw error;
    }
  }

  static async updateUser(userId: string, userData: Partial<User>): Promise<User> {
    try {
      await db.collection(COLLECTIONS.USERS).doc(userId).update({
        ...userData,
        updatedAt: new Date(),
      });

      return (await this.getUserById(userId))!;
    } catch (error) {
      console.error('Error updating user:', error);
      throw error;
    }
  }
}

