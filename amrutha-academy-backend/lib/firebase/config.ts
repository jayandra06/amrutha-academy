import { initializeApp, getApps, cert, ServiceAccount, App } from 'firebase-admin/app';
import { getFirestore, Firestore } from 'firebase-admin/firestore';
import { getAuth, Auth } from 'firebase-admin/auth';
import { getStorage, Storage } from 'firebase-admin/storage';
import { getDatabase, Database } from 'firebase-admin/database';

let app: App | undefined;
let db: Firestore;
let authInstance: Auth;
let storageInstance: Storage;
let databaseInstance: Database;

// Initialize Firebase Admin SDK
if (!getApps().length) {
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');
  const storageBucket = process.env.FIREBASE_STORAGE_BUCKET;

  if (projectId && clientEmail && privateKey) {
    try {
      const serviceAccount: ServiceAccount = {
        projectId,
        clientEmail,
        privateKey,
      };

      app = initializeApp({
        credential: cert(serviceAccount),
        storageBucket: storageBucket || `${projectId}.appspot.com`,
      });
    } catch (error) {
      console.error('Firebase initialization error:', error);
      // Don't throw - allow build to continue, but services won't work without config
    }
  } else {
    console.warn('Firebase environment variables not set. Firebase services will not be available.');
  }
} else {
  app = getApps()[0];
}

// Initialize services only if app is initialized
if (app) {
  try {
    db = getFirestore(app);
    authInstance = getAuth(app);
    storageInstance = getStorage(app);
    databaseInstance = getDatabase(app);
  } catch (error) {
    console.error('Error initializing Firebase services:', error);
  }
}

// Export services (will be undefined if Firebase is not initialized)
export { db, authInstance as auth, storageInstance as storage, databaseInstance as database };
