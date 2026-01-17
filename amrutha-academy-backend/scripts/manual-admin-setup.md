# Manual Admin User Setup (Alternative to Script)

If the seeding script fails due to authentication issues, you can set up the admin user manually using Firebase Console or Firebase CLI.

## Method 1: Firebase Console (Easiest)

### Step 1: Login to Flutter App
1. Open the Flutter app
2. Enter phone number: `9550538735`
3. Complete OTP verification
4. Complete profile setup if prompted

### Step 2: Update Role in Firebase Console
1. Go to Firebase Console: https://console.firebase.google.com/project/amrutha-academy/firestore
2. Navigate to **Firestore Database** → **Data** tab
3. Click on `users` collection
4. Find the user document with phone number `9550538735` or `+919550538735`
5. Click on the document
6. Click the **Edit** button (pencil icon)
7. Find the `role` field
8. Change its value from `"student"` to `"admin"`
9. Click **Update**

### Step 3: Verify
- The `role` field should now show `"admin"`
- Logout and login again in the Flutter app
- You should see the admin menu items

## Method 2: Firebase CLI

### Prerequisites
```bash
npm install -g firebase-tools
firebase login
firebase use amrutha-academy
```

### Update User Role
After logging in with phone `9550538735`, find the user ID from Firestore Console, then:

```bash
# Replace <USER_ID> with actual user ID from Firestore
firebase firestore:set users/<USER_ID> '{ "role": "admin" }' --merge
```

## Method 3: Regenerate Service Account Key

If service account is expired/invalid:

1. Go to: https://console.firebase.google.com/project/amrutha-academy/settings/serviceaccounts/adminsdk
2. Click **"Generate New Private Key"**
3. Click **"Generate Key"** to confirm
4. Download the JSON file
5. Replace `amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json` in the backend root
6. Run `npm run seed-admin` again

## Verify Service Account Permissions

1. Go to: https://console.cloud.google.com/iam-admin/iam?project=amrutha-academy
2. Find service account: `firebase-adminsdk-fbsvc@amrutha-academy.iam.gserviceaccount.com`
3. Ensure it has one of these roles:
   - **Firebase Admin SDK Administrator Service Agent**
   - **Cloud Datastore User**
   - **Firestore User**
   - **Editor** (for full access)

## Troubleshooting

- **Authentication Error**: Regenerate service account key (Method 3)
- **User Not Found**: Make sure you've logged in at least once with phone `9550538735`
- **Permission Denied**: Check service account has Firestore permissions (Verify Permissions section above)

