import { auth } from '@/lib/firebase/config';
import { UserService } from '@/lib/services/userService';
import { User } from '@/types';

export async function verifyFirebaseToken(token: string): Promise<User | null> {
  try {
    const decodedToken = await auth.verifyIdToken(token);
    const user = await UserService.getUserById(decodedToken.uid);
    return user;
  } catch (error) {
    console.error('Token verification error:', error);
    return null;
  }
}

export async function createCustomToken(uid: string): Promise<string> {
  try {
    return await auth.createCustomToken(uid);
  } catch (error) {
    console.error('Error creating custom token:', error);
    throw error;
  }
}

export async function getUserByEmail(email: string): Promise<User | null> {
  try {
    return await UserService.getUserByEmail(email);
  } catch (error) {
    console.error('Error fetching user by email:', error);
    return null;
  }
}
