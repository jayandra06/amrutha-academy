# Seed Admin User via Firebase CLI

## Method 1: Using Firebase CLI (Recommended for Quick Setup)

### Prerequisites
- Firebase CLI installed: `npm install -g firebase-tools`
- Logged in: `firebase login`
- Firebase project initialized: `firebase use amrutha-academy`

### Option A: Update User via Firestore Console
1. Go to Firebase Console: https://console.firebase.google.com/project/amrutha-academy/firestore
2. Navigate to `users` collection
3. Find user document with phone number `9550538735` or `+919550538735`
4. Click on the document
5. Edit the `role` field and set it to `"admin"`

### Option B: Update User via Firebase CLI Firestore Commands

```bash
# First, login to Firebase
firebase login

# Set the active project
firebase use amrutha-academy

# List users to find the user ID
# (Note: You may need to find the user ID from Firestore Console first)

# Update user role to admin (replace <USER_ID> with actual user ID from Firestore)
firebase firestore:set users/<USER_ID> '{ "role": "admin" }' --merge

# OR use Firebase Admin SDK via Node.js script (see seed-admin.ts)
npm run seed-admin
```

### Option C: Use Firebase CLI with Node.js Script
The `seed-admin.ts` script can be run after setting up Firebase CLI:

```bash
# Ensure you're authenticated
firebase login

# Run the seeding script
npm run seed-admin
```

## Method 2: Using Firebase Admin SDK Script (Current Implementation)

The `seed-admin.ts` script uses Firebase Admin SDK directly:

```bash
npm run seed-admin
```

This script:
1. Automatically finds the service account JSON file
2. Initializes Firebase Admin SDK
3. Searches for user with phone number `9550538735`
4. Updates the user's role to `admin`

## Troubleshooting

### If Service Account File Not Found
1. Ensure `amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json` exists in the backend root
2. OR set `GOOGLE_APPLICATION_CREDENTIALS` environment variable pointing to the file

### If User Not Found
1. First login to the Flutter app with phone number `9550538735`
2. Complete phone authentication (OTP verification)
3. Then run `npm run seed-admin` again

### Verify Admin Status
After running the script, verify in Firebase Console:
- Firestore → users → find user with phone `9550538735`
- Check that `role` field is set to `"admin"`

