# Quick Admin Setup Guide

## Option 1: Create Admin via Web Interface (Easiest)

1. **Start the Next.js server:**
   ```bash
   cd amrutha-academy-backend
   npm run dev
   ```

2. **Open your browser:**
   - Go to: http://localhost:3000/admin/users

3. **Create Admin User:**
   - Fill in the form:
     - Full Name: `Admin User` (or any name)
     - Phone Number: `8309057182` (or `+918309057182`)
     - Email: `admin@amruthaacademy.com` (optional)
     - Role: Select `Admin`
   - Click "Create User"

4. **Login:**
   - Go to: http://localhost:3000/login
   - Enter phone: `8309057182`
   - Complete OTP verification
   - You'll be redirected to admin dashboard

## Option 2: Firebase Console (If user already exists)

If you already created the user:

1. **Go to Firebase Console:**
   - https://console.firebase.google.com/project/amrutha-academy/firestore

2. **Navigate to Firestore Database → Data tab**

3. **Click on `users` collection**

4. **Find user with phone number:** `8309057182` or `+918309057182`

5. **Click on the document → Click Edit (pencil icon)**

6. **Update `role` field:**
   - Change from `"student"` to `"admin"`

7. **Click Update**

8. **Login again** at http://localhost:3000/login

## Option 3: Fix Service Account (For Script)

If you want to use the seed-admin script:

1. **Regenerate Service Account Key:**
   - Go to: https://console.firebase.google.com/project/amrutha-academy/settings/serviceaccounts/adminsdk
   - Click "Generate New Private Key"
   - Download the JSON file
   - Replace `amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json` in backend root

2. **Run seed script again:**
   ```bash
   npm run seed-admin
   ```

## Verify Service Account Permissions

If service account still fails:

1. Go to: https://console.cloud.google.com/iam-admin/iam?project=amrutha-academy
2. Find: `firebase-adminsdk-fbsvc@amrutha-academy.iam.gserviceaccount.com`
3. Ensure it has:
   - "Cloud Datastore User" or "Firestore User" role
   - "Service Account User" role


