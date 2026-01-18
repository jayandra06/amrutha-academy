import * as path from 'path';
import * as fs from 'fs';
import { initializeApp, cert, getApps, ServiceAccount } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import { COLLECTIONS } from '../lib/firebase/collections';

// Admin user configuration
const ADMIN_PHONE_NUMBER = '8309057182';
const ADMIN_PHONE_WITH_CODE = '+918309057182';
const ADMIN_EMAIL = 'admin@amruthaacademy.com';
const ADMIN_NAME = 'Admin User';

async function createAdminUser() {
  console.log('🔐 Creating Admin User...\n');
  console.log(`📱 Phone: ${ADMIN_PHONE_NUMBER} / ${ADMIN_PHONE_WITH_CODE}\n`);

  try {
    // Initialize Firebase Admin SDK
    let app;
    if (getApps().length === 0) {
      const serviceAccountPath = path.join(process.cwd(), 'amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json');
      
      if (!fs.existsSync(serviceAccountPath)) {
        throw new Error(`Service account file not found: ${serviceAccountPath}`);
      }

      const serviceAccountJson = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
      const privateKey = serviceAccountJson.private_key.replace(/\\n/g, '\n');
      
      const serviceAccount: ServiceAccount = {
        projectId: serviceAccountJson.project_id,
        clientEmail: serviceAccountJson.client_email,
        privateKey: privateKey,
      };

      app = initializeApp({
        credential: cert(serviceAccount),
        projectId: serviceAccountJson.project_id,
      });
      console.log('✅ Firebase Admin SDK initialized\n');
    } else {
      app = getApps()[0];
    }

    const db = getFirestore(app);
    const auth = getAuth(app);

    // Step 1: Check if user exists in Firestore
    console.log('🔍 Checking Firestore for existing user...');
    let userDoc = null;
    let userId: string | null = null;

    try {
      const usersWithCode = await db
        .collection(COLLECTIONS.USERS)
        .where('phoneNumber', '==', ADMIN_PHONE_WITH_CODE)
        .limit(1)
        .get();

      if (!usersWithCode.empty) {
        userDoc = usersWithCode.docs[0];
        userId = userDoc.id;
        console.log(`✅ Found user in Firestore: ${userId}`);
      } else {
        const usersWithoutCode = await db
          .collection(COLLECTIONS.USERS)
          .where('phoneNumber', '==', ADMIN_PHONE_NUMBER)
          .limit(1)
          .get();

        if (!usersWithoutCode.empty) {
          userDoc = usersWithoutCode.docs[0];
          userId = userDoc.id;
          console.log(`✅ Found user in Firestore: ${userId}`);
        }
      }
    } catch (error: any) {
      console.warn('⚠️  Could not query Firestore (will create new user):', error.message);
    }

    // Step 2: Check/create user in Firebase Auth
    console.log('\n🔍 Checking Firebase Auth...');
    let authUserId: string | null = null;
    
    try {
      const authUser = await auth.getUserByPhoneNumber(ADMIN_PHONE_WITH_CODE);
      authUserId = authUser.uid;
      console.log(`✅ Found user in Firebase Auth: ${authUserId}`);
    } catch (error: any) {
      if (error.code === 'auth/user-not-found') {
        console.log('📝 Creating user in Firebase Auth...');
        try {
          const newAuthUser = await auth.createUser({
            phoneNumber: ADMIN_PHONE_WITH_CODE,
            displayName: ADMIN_NAME,
            email: ADMIN_EMAIL,
          });
          authUserId = newAuthUser.uid;
          console.log(`✅ Created user in Firebase Auth: ${authUserId}`);
        } catch (createError: any) {
          console.warn('⚠️  Could not create Firebase Auth user:', createError.message);
        }
      } else {
        console.warn('⚠️  Error checking Firebase Auth:', error.message);
      }
    }

    // Step 3: Use Firebase Auth UID if available, otherwise generate one
    const finalUserId = authUserId || userId || `admin_${Date.now()}`;
    console.log(`\n📝 Using User ID: ${finalUserId}`);

    // Step 4: Create/Update user in Firestore
    const userData = {
      fullName: ADMIN_NAME,
      email: ADMIN_EMAIL,
      phoneNumber: ADMIN_PHONE_WITH_CODE,
      role: 'admin',
      avatar: '',
      bio: '',
      birthday: '',
      location: '',
      createdAt: userDoc?.data()?.createdAt || new Date(),
      updatedAt: new Date(),
    };

    if (userId && userId === finalUserId) {
      // Update existing user
      console.log('\n🔄 Updating existing user to admin...');
      await db.collection(COLLECTIONS.USERS).doc(finalUserId).update({
        ...userData,
        createdAt: userDoc!.data().createdAt, // Keep original createdAt
      });
      console.log('✅ User updated successfully!');
    } else {
      // Create new user
      console.log('\n📝 Creating new admin user...');
      await db.collection(COLLECTIONS.USERS).doc(finalUserId).set(userData);
      console.log('✅ Admin user created successfully!');
    }

    // Step 5: Display final user details
    const finalUserDoc = await db.collection(COLLECTIONS.USERS).doc(finalUserId).get();
    const finalData = finalUserDoc.data();

    console.log('\n📋 Admin User Details:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`User ID: ${finalUserId}`);
    console.log(`Phone: ${finalData?.phoneNumber || ADMIN_PHONE_WITH_CODE}`);
    console.log(`Name: ${finalData?.fullName || ADMIN_NAME}`);
    console.log(`Email: ${finalData?.email || ADMIN_EMAIL}`);
    console.log(`Role: ${finalData?.role || 'admin'}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    console.log('✅ Admin user setup complete!');
    console.log('\n📱 You can now login at: http://localhost:3000/login');
    console.log(`   Phone Number: ${ADMIN_PHONE_NUMBER}\n`);

  } catch (error: any) {
    console.error('\n❌ Error creating admin user:', error.message);
    console.error('   Code:', error.code);
    console.error('\n💡 Solutions:');
    console.log('   1. Verify service account file exists and is valid');
    console.log('   2. Check service account has Firestore permissions');
    console.log('   3. Try creating user via web interface: http://localhost:3000/admin/users');
    process.exit(1);
  }
}

createAdminUser();



