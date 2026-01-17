import { initializeApp, getApps, cert, ServiceAccount, App } from 'firebase-admin/app';
import { getFirestore, Firestore } from 'firebase-admin/firestore';
import { getAuth, Auth } from 'firebase-admin/auth';
import { getStorage, Storage } from 'firebase-admin/storage';
import { getDatabase, Database } from 'firebase-admin/database';
import * as path from 'path';
import * as fs from 'fs';

let app: App | undefined;
let db: Firestore;
let authInstance: Auth;
let storageInstance: Storage;
let databaseInstance: Database;

// Initialize Firebase Admin SDK
if (!getApps().length) {
  // First, try to use service account JSON file if it exists in project root
  const serviceAccountPath = path.join(process.cwd(), 'amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json');
  
  if (fs.existsSync(serviceAccountPath) && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    try {
      const serviceAccountJson = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
      
      if (serviceAccountJson.private_key && serviceAccountJson.client_email && serviceAccountJson.project_id) {
        // Ensure private key has proper newlines and is valid
        let privateKey = serviceAccountJson.private_key;
        
        // Replace escaped newlines with actual newlines
        privateKey = privateKey.replace(/\\n/g, '\n');
        
        // Validate private key format
        if (!privateKey.includes('BEGIN PRIVATE KEY') || !privateKey.includes('END PRIVATE KEY')) {
          throw new Error('Invalid private key format in service account file');
        }
        
        const serviceAccount: ServiceAccount = {
          projectId: serviceAccountJson.project_id,
          clientEmail: serviceAccountJson.client_email,
          privateKey: privateKey,
        };

        app = initializeApp({
          credential: cert(serviceAccount),
          storageBucket: serviceAccountJson.storage_bucket || `${serviceAccountJson.project_id}.appspot.com`,
        });
        
        console.log('✅ Firebase initialized using service account JSON file');
      }
    } catch (error: any) {
      console.error('Firebase initialization error (using service account JSON file):', error.message);
      console.error('Error details:', error.code || 'N/A');
      // Continue to try other methods
    }
  }
  
  // Check if GOOGLE_APPLICATION_CREDENTIALS is set (service account JSON file path)
  if (!app && process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    try {
      // Firebase Admin SDK will automatically use the service account file
      // No need to pass explicit credentials
      app = initializeApp();
      console.log('✅ Firebase initialized using GOOGLE_APPLICATION_CREDENTIALS');
    } catch (error) {
      console.error('Firebase initialization error (using GOOGLE_APPLICATION_CREDENTIALS):', error);
      // Don't throw - allow build to continue, but services won't work without config
    }
  }
  
  // Fallback to environment variables
  if (!app) {
    // Fallback to environment variables
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
    console.log('✅ Firebase services initialized');
  } catch (error: any) {
    console.error('Error initializing Firebase services:', error.message);
    // Set to undefined so we know services aren't available
    db = undefined as any;
    authInstance = undefined as any;
    storageInstance = undefined as any;
    databaseInstance = undefined as any;
  }
} else {
  console.warn('⚠️  Firebase app not initialized. Services will not be available.');
  // Initialize as undefined to prevent errors
  db = undefined as any;
  authInstance = undefined as any;
  storageInstance = undefined as any;
  databaseInstance = undefined as any;
}

// Export services (will be undefined if Firebase is not initialized)
export { db, authInstance as auth, storageInstance as storage, databaseInstance as database };
