# Fix Firebase Authentication Error

## Error Message
```
16 UNAUTHENTICATED: Request had invalid authentication credentials
```

## Cause
The service account key may be expired, invalid, or doesn't have proper Firestore permissions.

## Solution 1: Regenerate Service Account Key (Recommended)

1. Go to Firebase Console: https://console.firebase.google.com/project/amrutha-academy/settings/serviceaccounts/adminsdk
2. Click **"Generate New Private Key"**
3. Click **"Generate Key"** to confirm
4. Download the JSON file
5. Replace `amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json` in the backend root directory
6. Restart the Next.js server: `npm run dev`

## Solution 2: Verify Service Account Permissions

1. Go to Google Cloud Console: https://console.cloud.google.com/iam-admin/iam?project=amrutha-academy
2. Find the service account: `firebase-adminsdk-fbsvc@amrutha-academy.iam.gserviceaccount.com`
3. Ensure it has one of these roles:
   - **Firebase Admin SDK Administrator Service Agent** (Recommended)
   - **Cloud Datastore User**
   - **Firestore User**
   - **Editor** (Full access)

## Solution 3: Use Environment Variables

If the JSON file continues to cause issues, you can use `.env.local` instead:

1. Create/Update `.env.local` in `amrutha-academy-backend/`:
```env
FIREBASE_PROJECT_ID=amrutha-academy
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@amrutha-academy.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_STORAGE_BUCKET=amrutha-academy.firebasestorage.app
```

2. Copy the `private_key` from the service account JSON file (keep the newlines as `\n`)
3. Restart the server

## Note

The user creation API will still work even with authentication errors during duplicate checks - it will just skip the duplicate validation and allow user creation to proceed.

