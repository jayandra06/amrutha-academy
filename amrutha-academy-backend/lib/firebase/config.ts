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
  // Try the current filename first, then search for any matching pattern
  let serviceAccountPath = path.join(process.cwd(), 'amrutha-academy-firebase-adminsdk-fbsvc-20f1b7d769.json');
  
  // If the specific file doesn't exist, try to find any matching file
  if (!fs.existsSync(serviceAccountPath)) {
    const files = fs.readdirSync(process.cwd());
    const serviceAccountFile = files.find(file => 
      file.startsWith('amrutha-academy-firebase-adminsdk-') && file.endsWith('.json')
    );
    if (serviceAccountFile) {
      serviceAccountPath = path.join(process.cwd(), serviceAccountFile);
    }
  }
  
  if (fs.existsSync(serviceAccountPath) && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    try {
      console.log(`📁 Found service account file: ${path.basename(serviceAccountPath)}`);
      const serviceAccountJson = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
      
      if (serviceAccountJson.private_key && serviceAccountJson.client_email && serviceAccountJson.project_id) {
        // Ensure private key has proper newlines and is valid
        let privateKey = serviceAccountJson.private_key;
        
        // Replace escaped newlines with actual newlines
        privateKey = privateKey.replace(/\\n/g, '\n');
        
        // Remove any leading/trailing whitespace
        privateKey = privateKey.trim();
        
        // Validate private key format
        if (!privateKey.includes('BEGIN PRIVATE KEY') || !privateKey.includes('END PRIVATE KEY')) {
          throw new Error('Invalid private key format in service account file: missing BEGIN/END markers');
        }
        
        // Ensure the private key starts and ends correctly
        if (!privateKey.startsWith('-----BEGIN PRIVATE KEY-----')) {
          throw new Error('Invalid private key format: must start with -----BEGIN PRIVATE KEY-----');
        }
        if (!privateKey.endsWith('-----END PRIVATE KEY-----')) {
          throw new Error('Invalid private key format: must end with -----END PRIVATE KEY-----');
        }
        
        // Validate that the key content looks valid (base64-like between markers)
        const keyContent = privateKey
          .replace('-----BEGIN PRIVATE KEY-----', '')
          .replace('-----END PRIVATE KEY-----', '')
          .replace(/\n/g, '')
          .trim();
        
        if (!keyContent || keyContent.length < 100) {
          throw new Error(`Invalid private key: key content appears to be too short (${keyContent.length} chars) or empty`);
        }
        
        // Check for common issues
        if (privateKey.includes('\\n') && !privateKey.includes('\n')) {
          console.warn('Warning: Private key may have escaped newlines that need to be converted');
        }
        
        const serviceAccount: ServiceAccount = {
          projectId: serviceAccountJson.project_id,
          clientEmail: serviceAccountJson.client_email,
          privateKey: privateKey,
        };

        try {
          // Try to create the credential first to catch any parsing errors
          const credential = cert(serviceAccount);
          
          app = initializeApp({
            credential: credential,
            storageBucket: serviceAccountJson.storage_bucket || `${serviceAccountJson.project_id}.appspot.com`,
          });
          
          console.log('✅ Firebase initialized using service account JSON file');
        } catch (certError: any) {
          console.error('Error creating Firebase credential:', certError.message);
          console.error('Private key length:', privateKey.length);
          console.error('Private key preview (first 50 chars):', privateKey.substring(0, 50));
          throw certError;
        }
      }
    } catch (error: any) {
      console.error('Firebase initialization error (using service account JSON file):', error.message);
      console.error('Error details:', error.code || 'N/A');
      if (error.message?.includes('private key')) {
        console.error('Private key validation failed. Please check:');
        console.error('  1. The private_key field in the JSON file is correct');
        console.error('  2. The private key has proper BEGIN/END markers');
        console.error('  3. The private key is not corrupted or truncated');
      }
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
    let privateKey = process.env.FIREBASE_PRIVATE_KEY;
    const storageBucket = process.env.FIREBASE_STORAGE_BUCKET;

    if (projectId && clientEmail && privateKey) {
      try {
        // Remove any surrounding quotes (single or double)
        privateKey = privateKey.replace(/^["']|["']$/g, '');
        
        // Replace escaped newlines with actual newlines
        privateKey = privateKey.replace(/\\n/g, '\n');
        
        // Remove any leading/trailing whitespace
        privateKey = privateKey.trim();
        
        // Validate private key format
        if (!privateKey.includes('BEGIN PRIVATE KEY') || !privateKey.includes('END PRIVATE KEY')) {
          throw new Error('Invalid private key format in environment variable: missing BEGIN/END markers');
        }
        
        // Ensure the private key starts and ends correctly
        if (!privateKey.startsWith('-----BEGIN PRIVATE KEY-----')) {
          throw new Error('Invalid private key format: must start with -----BEGIN PRIVATE KEY-----');
        }
        if (!privateKey.endsWith('-----END PRIVATE KEY-----')) {
          throw new Error('Invalid private key format: must end with -----END PRIVATE KEY-----');
        }
        
        // Validate that the key content looks valid
        const keyContent = privateKey
          .replace('-----BEGIN PRIVATE KEY-----', '')
          .replace('-----END PRIVATE KEY-----', '')
          .replace(/\n/g, '')
          .trim();
        
        if (!keyContent || keyContent.length < 100) {
          throw new Error(`Invalid private key: key content appears to be too short (${keyContent.length} chars) or empty`);
        }
        
        // Check for common issues
        if (process.env.FIREBASE_PRIVATE_KEY?.includes('\\n') && !privateKey.includes('\n')) {
          console.warn('Warning: Private key may have escaped newlines that need to be converted');
        }
        
        const serviceAccount: ServiceAccount = {
          projectId,
          clientEmail,
          privateKey,
        };

        try {
          // Try to create the credential first to catch any parsing errors
          const credential = cert(serviceAccount);
          
          app = initializeApp({
            credential: credential,
            storageBucket: storageBucket || `${projectId}.appspot.com`,
          });
          
          console.log('✅ Firebase initialized using environment variables');
        } catch (certError: any) {
          console.error('Error creating Firebase credential from environment variables:', certError.message);
          console.error('Private key length:', privateKey.length);
          console.error('Private key preview (first 50 chars):', privateKey.substring(0, 50));
          console.error('Full error:', certError);
          throw certError;
        }
      } catch (error: any) {
        console.error('Firebase initialization error:', error.message || error);
        console.error('Error details:', error.code || 'N/A');
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
    
    // Initialize Realtime Database only if database URL is explicitly provided
    // Realtime Database is optional - most projects use Firestore instead
    if (process.env.FIREBASE_DATABASE_URL) {
      try {
        databaseInstance = getDatabase(app, process.env.FIREBASE_DATABASE_URL);
        console.log('✅ Firebase Realtime Database initialized');
      } catch (dbError: any) {
        console.warn('⚠️  Firebase Realtime Database initialization failed:', dbError.message);
        console.warn('   This is OK if you are only using Firestore.');
        databaseInstance = undefined as any;
      }
    } else {
      // Realtime Database not configured - this is normal for Firestore-only projects
      databaseInstance = undefined as any;
      console.log('ℹ️  Firebase Realtime Database not configured (using Firestore only)');
    }
    
    console.log('✅ Firebase services initialized (Firestore, Auth, Storage)');
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
