import * as path from 'path';
import * as fs from 'fs';
import { initializeApp, cert, getApps, ServiceAccount } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';
import { COLLECTIONS } from '../lib/firebase/collections';

// User configurations
const TRAINER_PHONE = '8891520765';
const TRAINER_PHONE_WITH_CODE = '+918891520765';
const TRAINER_EMAIL = 'trainer@amruthaacademy.com';
const TRAINER_NAME = 'Trainer User';

const STUDENT_PHONE = '8891660573';
const STUDENT_PHONE_WITH_CODE = '+918891660573';
const STUDENT_EMAIL = 'student@amruthaacademy.com';
const STUDENT_NAME = 'Student User';

async function createUser(phoneNumber: string, phoneWithCode: string, email: string, name: string, role: 'trainer' | 'student') {
  console.log(`\n🔐 Creating ${role.toUpperCase()} User...`);
  console.log(`📱 Phone: ${phoneNumber} / ${phoneWithCode}`);
  console.log(`📧 Email: ${email}`);
  console.log(`👤 Name: ${name}`);

  try {
    // Get Firebase services
    const db = getFirestore();
    const auth = getAuth();

    // Step 1: Check if user exists in Firestore
    let userDoc = null;
    let userId: string | null = null;

    try {
      const usersWithCode = await db
        .collection(COLLECTIONS.USERS)
        .where('phoneNumber', '==', phoneWithCode)
        .limit(1)
        .get();

      if (!usersWithCode.empty) {
        userDoc = usersWithCode.docs[0];
        userId = userDoc.id;
        console.log(`✅ Found existing user in Firestore: ${userId}`);
      } else {
        const usersWithoutCode = await db
          .collection(COLLECTIONS.USERS)
          .where('phoneNumber', '==', phoneNumber)
          .limit(1)
          .get();

        if (!usersWithoutCode.empty) {
          userDoc = usersWithoutCode.docs[0];
          userId = userDoc.id;
          console.log(`✅ Found existing user in Firestore: ${userId}`);
        }
      }
    } catch (error: any) {
      console.warn(`⚠️  Could not query Firestore: ${error.message}`);
    }

    // Step 2: Check/create user in Firebase Auth
    let authUserId: string | null = null;
    
    try {
      const authUser = await auth.getUserByPhoneNumber(phoneWithCode);
      authUserId = authUser.uid;
      console.log(`✅ Found user in Firebase Auth: ${authUserId}`);
    } catch (error: any) {
      if (error.code === 'auth/user-not-found') {
        console.log('📝 Creating user in Firebase Auth...');
        try {
          const newAuthUser = await auth.createUser({
            phoneNumber: phoneWithCode,
            displayName: name,
            email: email,
          });
          authUserId = newAuthUser.uid;
          console.log(`✅ Created user in Firebase Auth: ${authUserId}`);
        } catch (createError: any) {
          console.warn(`⚠️  Could not create Firebase Auth user: ${createError.message}`);
        }
      } else {
        console.warn(`⚠️  Error checking Firebase Auth: ${error.message}`);
      }
    }

    // Step 3: Use Firebase Auth UID if available, otherwise use existing or generate
    const finalUserId = authUserId || userId || `${role}_${Date.now()}`;
    console.log(`📝 Using User ID: ${finalUserId}`);

    // Step 4: Create/Update user in Firestore
    const userData = {
      fullName: name,
      email: email,
      phoneNumber: phoneWithCode,
      role: role,
      avatar: '',
      bio: '',
      birthday: '',
      location: '',
      createdAt: userDoc?.data()?.createdAt || new Date(),
      updatedAt: new Date(),
    };

    if (userId && userId === finalUserId) {
      // Update existing user
      console.log(`🔄 Updating existing user role to ${role}...`);
      await db.collection(COLLECTIONS.USERS).doc(finalUserId).update({
        ...userData,
        createdAt: userDoc!.data().createdAt,
      });
      console.log(`✅ User updated successfully!`);
    } else {
      // Create new user
      console.log(`📝 Creating new ${role} user...`);
      await db.collection(COLLECTIONS.USERS).doc(finalUserId).set(userData);
      console.log(`✅ ${role} user created successfully!`);
    }

    // Step 5: Display user details
    const finalUserDoc = await db.collection(COLLECTIONS.USERS).doc(finalUserId).get();
    const finalData = finalUserDoc.data();

    console.log(`\n📋 ${role.toUpperCase()} User Details:`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`User ID: ${finalUserId}`);
    console.log(`Phone: ${finalData?.phoneNumber || phoneWithCode}`);
    console.log(`Name: ${finalData?.fullName || name}`);
    console.log(`Email: ${finalData?.email || email}`);
    console.log(`Role: ${finalData?.role || role}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return { success: true, userId: finalUserId, data: finalData };
  } catch (error: any) {
    console.error(`\n❌ Error creating ${role} user:`, error.message);
    console.error(`   Code: ${error.code || 'N/A'}`);
    return { success: false, error: error.message };
  }
}

async function main() {
  console.log('🚀 Creating Trainer and Student Accounts...\n');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // Initialize Firebase Admin SDK
  if (getApps().length === 0) {
    const serviceAccountPath = path.join(process.cwd(), 'amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json');
    
    if (!fs.existsSync(serviceAccountPath)) {
      console.error(`❌ Service account file not found: ${serviceAccountPath}`);
      process.exit(1);
    }

    const serviceAccountJson = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
    const privateKey = serviceAccountJson.private_key.replace(/\\n/g, '\n');
    
    const serviceAccount: ServiceAccount = {
      projectId: serviceAccountJson.project_id,
      clientEmail: serviceAccountJson.client_email,
      privateKey: privateKey,
    };

    initializeApp({
      credential: cert(serviceAccount),
      projectId: serviceAccountJson.project_id,
    });
    console.log('✅ Firebase Admin SDK initialized\n');
  }

  // Create trainer
  const trainerResult = await createUser(
    TRAINER_PHONE,
    TRAINER_PHONE_WITH_CODE,
    TRAINER_EMAIL,
    TRAINER_NAME,
    'trainer'
  );

  // Create student
  const studentResult = await createUser(
    STUDENT_PHONE,
    STUDENT_PHONE_WITH_CODE,
    STUDENT_EMAIL,
    STUDENT_NAME,
    'student'
  );

  // Summary
  console.log('\n\n📊 Summary:');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`Trainer (${TRAINER_PHONE}): ${trainerResult.success ? '✅ Created/Updated' : '❌ Failed'}`);
  console.log(`Student (${STUDENT_PHONE}): ${studentResult.success ? '✅ Created/Updated' : '❌ Failed'}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  if (trainerResult.success && studentResult.success) {
    console.log('✅ All accounts created successfully!');
    console.log('\n📱 Login Details:');
    console.log(`   Trainer: http://localhost:3000/login (Phone: ${TRAINER_PHONE})`);
    console.log(`   Student: http://localhost:3000/login (Phone: ${STUDENT_PHONE})\n`);
  } else {
    console.log('⚠️  Some accounts failed to create. Check errors above.\n');
    process.exit(1);
  }
}

main().catch((error) => {
  console.error('\n💥 Fatal error:', error);
  process.exit(1);
});



