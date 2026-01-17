import * as path from 'path';
import * as fs from 'fs';
import { initializeApp, cert, getApps, ServiceAccount } from 'firebase-admin/app';
import { getFirestore, Firestore } from 'firebase-admin/firestore';
import { COLLECTIONS } from '../lib/firebase/collections';
import type { QueryDocumentSnapshot } from 'firebase-admin/firestore';

// Admin phone number configuration
const ADMIN_PHONE_NUMBER = '9550538735';
const ADMIN_PHONE_WITH_CODE = '+919550538735'; // Format used in Firebase Auth
const ADMIN_EMAIL = 'admin@amruthaacademy.com';
const ADMIN_NAME = 'Admin User';

// Initialize Firebase Admin SDK with service account JSON file
function initializeFirebase(): Firestore | null {
  try {
    // If Firebase is already initialized, use it
    if (getApps().length > 0) {
      return getFirestore();
    }

    // Try to find and use the service account JSON file
    const serviceAccountPath = path.join(process.cwd(), 'amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json');
    
    if (fs.existsSync(serviceAccountPath)) {
      console.log('📄 Using service account JSON file for Firebase initialization...');
      const serviceAccountJson = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
      
      // Validate service account structure
      if (!serviceAccountJson.private_key || !serviceAccountJson.client_email || !serviceAccountJson.project_id) {
        throw new Error('Service account JSON file is missing required fields (private_key, client_email, or project_id)');
      }
      
      // Verify project ID matches
      if (serviceAccountJson.project_id !== 'amrutha-academy') {
        console.warn(`⚠️  Warning: Service account project_id (${serviceAccountJson.project_id}) doesn't match expected project (amrutha-academy)`);
      }
      
      // Ensure private key has proper newlines
      const privateKey = serviceAccountJson.private_key.replace(/\\n/g, '\n');
      
      const serviceAccount: ServiceAccount = {
        projectId: serviceAccountJson.project_id,
        clientEmail: serviceAccountJson.client_email,
        privateKey: privateKey,
      };
      
      initializeApp({
        credential: cert(serviceAccount),
        projectId: serviceAccountJson.project_id, // Explicitly set project ID
      });
      
      console.log(`   Project ID: ${serviceAccountJson.project_id}`);
      console.log(`   Client Email: ${serviceAccountJson.client_email}`);
      console.log('✅ Firebase Admin SDK initialized successfully\n');
      return getFirestore();
    }

    // Fallback: Try using GOOGLE_APPLICATION_CREDENTIALS environment variable
    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      console.log('📄 Using GOOGLE_APPLICATION_CREDENTIALS for Firebase initialization...');
      initializeApp();
      console.log('✅ Firebase Admin SDK initialized successfully\n');
      return getFirestore();
    }

    // Fallback: Try environment variables from .env.local
    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

    if (projectId && clientEmail && privateKey) {
      console.log('📄 Using environment variables for Firebase initialization...');
      initializeApp({
        credential: cert({
          projectId,
          clientEmail,
          privateKey,
        } as ServiceAccount),
      });
      console.log('✅ Firebase Admin SDK initialized successfully\n');
      return getFirestore();
    }

    throw new Error('No Firebase credentials found. Please provide service account JSON file or set environment variables.');
  } catch (error: any) {
    console.error('❌ Failed to initialize Firebase Admin SDK:', error.message);
    return null;
  }
}

async function seedAdminUser() {
  console.log('🔐 Starting admin user seeding...\n');
  console.log(`📱 Admin phone number: ${ADMIN_PHONE_NUMBER} / ${ADMIN_PHONE_WITH_CODE}\n`);

  try {
    // Initialize Firebase Admin SDK
    const db = initializeFirebase();

    if (!db) {
      throw new Error('Firebase database not initialized. Check your Firebase configuration.');
    }

    // Step 1: Check if user exists in Firestore with this phone number
    console.log('🔍 Searching for user in Firestore...');
    
    // Search for users with this phone number (could be stored as +919550538735 or 9550538735)
    const usersWithCode = await db
      .collection(COLLECTIONS.USERS)
      .where('phoneNumber', '==', ADMIN_PHONE_WITH_CODE)
      .limit(1)
      .get();

    const usersWithoutCode = await db
      .collection(COLLECTIONS.USERS)
      .where('phoneNumber', '==', ADMIN_PHONE_NUMBER)
      .limit(1)
      .get();

    let userDoc: QueryDocumentSnapshot | null = null;
    let firebaseUserId: string | null = null;

    if (!usersWithCode.empty) {
      userDoc = usersWithCode.docs[0];
      firebaseUserId = userDoc.id;
      console.log(`✅ Found existing user in Firestore with phone: ${ADMIN_PHONE_WITH_CODE}`);
      console.log(`   User ID: ${firebaseUserId}`);
    } else if (!usersWithoutCode.empty) {
      userDoc = usersWithoutCode.docs[0];
      firebaseUserId = userDoc.id;
      console.log(`✅ Found existing user in Firestore with phone: ${ADMIN_PHONE_NUMBER}`);
      console.log(`   User ID: ${firebaseUserId}`);
    } else {
      // No user found - we'll need to create one after phone auth
      console.log('⚠️  No user found in Firestore with this phone number.');
      console.log('   The user will be created automatically when they authenticate via phone.');
      console.log('   This script will prepare instructions for setting up the admin role.\n');
      
      console.log('📋 To set up admin user:');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log('1. Login to the Flutter app with phone number: 9550538735');
      console.log('2. Complete phone authentication (OTP verification)');
      console.log('3. Complete profile setup if prompted');
      console.log('4. Run this script again to update the user role to admin');
      console.log('   OR manually update in Firebase Console:');
      console.log('   - Go to Firestore → users collection');
      console.log('   - Find the user document (by phone number)');
      console.log('   - Update the "role" field to "admin"');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      console.log('💡 Alternative: After first login, you can update the user in Firestore:');
      console.log('   db.collection("users").doc("<userId>").update({ role: "admin" })');
      
      process.exit(0);
      return;
    }

    // Step 2: Update user role to admin in Firestore
    if (userDoc && firebaseUserId) {
      const currentData = userDoc.data();
      const currentRole = currentData?.role || 'student';
      
      console.log(`\n📊 Current user data:`);
      console.log(`   Name: ${currentData?.fullName || 'N/A'}`);
      console.log(`   Email: ${currentData?.email || 'N/A'}`);
      console.log(`   Phone: ${currentData?.phoneNumber || 'N/A'}`);
      console.log(`   Current Role: ${currentRole}`);
      
      if (currentRole === 'admin') {
        console.log('\n✅ User is already an admin!');
      } else {
        console.log(`\n🔄 Updating role from "${currentRole}" to "admin"...`);
        
        const userData = {
          role: 'admin',
          fullName: currentData?.fullName || ADMIN_NAME,
          email: currentData?.email || ADMIN_EMAIL,
          phoneNumber: ADMIN_PHONE_WITH_CODE, // Standardize phone format
          updatedAt: new Date(),
        };

        await db.collection(COLLECTIONS.USERS).doc(firebaseUserId).update(userData);
        console.log(`✅ User role updated to admin successfully!`);
      }
    }

    // Step 3: Display final admin user details
    const updatedUser = await db.collection(COLLECTIONS.USERS).doc(firebaseUserId!).get();
    const finalData = updatedUser.data();

    console.log('\n📋 Admin User Details:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`Firestore User ID: ${firebaseUserId}`);
    console.log(`Phone Number: ${finalData?.phoneNumber || ADMIN_PHONE_WITH_CODE}`);
    console.log(`Name: ${finalData?.fullName || ADMIN_NAME}`);
    console.log(`Email: ${finalData?.email || ADMIN_EMAIL}`);
    console.log(`Role: ${finalData?.role || 'admin'}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    console.log('\n✅ Admin user setup completed!');
    console.log('\n📱 To login as admin:');
    console.log('   1. Open the Flutter app');
    console.log('   2. Enter phone number: 9550538735');
    console.log('   3. Complete OTP verification');
    console.log('   4. You will see the admin dashboard with admin menu items');

    console.log('\n🎉 Seeding completed successfully!');

  } catch (error: any) {
    console.error('❌ Error seeding admin user:', error.message || error);
    
    if (error.code === 16 || error.message?.includes('UNAUTHENTICATED')) {
      console.error('\n🔐 Authentication Error - Service Account Issues:');
      console.error('   The service account credentials are invalid or expired.\n');
      console.error('📋 Solutions:');
      console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.error('1. Regenerate Service Account Key:');
      console.error('   - Go to: https://console.firebase.google.com/project/amrutha-academy/settings/serviceaccounts/adminsdk');
      console.error('   - Click "Generate New Private Key"');
      console.error('   - Download and replace the JSON file in backend root');
      console.error('   - File: amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json\n');
      
      console.error('2. Verify Service Account Permissions:');
      console.error('   - Go to: https://console.cloud.google.com/iam-admin/iam?project=amrutha-academy');
      console.error('   - Find: firebase-adminsdk-fbsvc@amrutha-academy.iam.gserviceaccount.com');
      console.error('   - Ensure it has "Cloud Datastore User" or "Firestore User" role\n');
      
      console.error('3. Use Firebase CLI (Alternative):');
      console.error('   - Install: npm install -g firebase-tools');
      console.error('   - Login: firebase login');
      console.error('   - Set project: firebase use amrutha-academy');
      console.error('   - Then manually update user role in Firestore Console\n');
      console.error('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } else {
      console.error('\n💡 Troubleshooting:');
      console.error('   - Ensure service account JSON file exists in the backend root directory');
      console.error('   - File name: amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json');
      console.error('   - OR set GOOGLE_APPLICATION_CREDENTIALS environment variable');
      console.error('   - OR configure .env.local with Firebase credentials');
      console.error('   - Make sure you have logged in at least once with phone: 9550538735');
    }
    throw error;
  }
}

// Run the seed function
seedAdminUser()
  .then(() => {
    console.log('\n✨ All done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n💥 Seeding failed:', error);
    process.exit(1);
  });
