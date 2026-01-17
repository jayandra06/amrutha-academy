/**
 * Create Admin User via Next.js API Endpoint
 * This script uses the web API instead of Firebase Admin SDK directly
 * 
 * Usage: npm run create-admin-api
 * Prerequisites: Next.js dev server must be running (npm run dev)
 */

const API_URL = process.env.API_URL || 'http://localhost:3000';
const ADMIN_PHONE = '8309057182';
const ADMIN_EMAIL = 'admin@amruthaacademy.com';
const ADMIN_NAME = 'Admin User';

async function createAdminViaAPI() {
  console.log('🔐 Creating Admin User via API...\n');
  console.log(`📱 Phone: ${ADMIN_PHONE}`);
  console.log(`📧 Email: ${ADMIN_EMAIL}`);
  console.log(`👤 Name: ${ADMIN_NAME}\n`);

  const userData = {
    fullName: ADMIN_NAME,
    email: ADMIN_EMAIL,
    phoneNumber: ADMIN_PHONE,
    role: 'admin',
    bio: '',
    birthday: '',
    location: '',
  };

  try {
    console.log(`📡 Calling API: ${API_URL}/api/users/create`);
    
    const response = await fetch(`${API_URL}/api/users/create`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(userData),
    });

    const data = await response.json();

    if (response.ok) {
      console.log('\n✅ Admin user created successfully!');
      console.log('\n📋 User Details:');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      if (data.data?.user) {
        const user = data.data.user;
        console.log(`User ID: ${user.id || 'N/A'}`);
        console.log(`Phone: ${user.phoneNumber || ADMIN_PHONE}`);
        console.log(`Name: ${user.fullName || ADMIN_NAME}`);
        console.log(`Email: ${user.email || ADMIN_EMAIL}`);
        console.log(`Role: ${user.role || 'admin'}`);
      }
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      console.log('✅ Setup complete!');
      console.log('\n📱 You can now login at: http://localhost:3000/login');
      console.log(`   Phone Number: ${ADMIN_PHONE}\n`);
    } else {
      console.error('\n❌ Error creating user:');
      console.error(`   Status: ${response.status}`);
      console.error(`   Error: ${data.error || data.message || 'Unknown error'}`);
      
      if (data.error?.includes('already exists')) {
        console.log('\n💡 User already exists!');
        console.log('   If you need to update the role to admin:');
        console.log('   1. Go to Firebase Console: https://console.firebase.google.com/project/amrutha-academy/firestore');
        console.log('   2. Find user with phone:', ADMIN_PHONE);
        console.log('   3. Update role field to "admin"');
      }
    }
  } catch (error: any) {
    console.error('\n❌ Network error:', error.message);
    console.error('\n💡 Make sure the Next.js server is running:');
    console.log('   npm run dev');
    console.log(`   Then try again or visit: http://localhost:3000/admin/users`);
  }
}

createAdminViaAPI();


