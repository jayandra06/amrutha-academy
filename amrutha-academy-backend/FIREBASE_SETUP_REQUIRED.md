# Firebase Setup Required

## Current Issue

The Next.js app is failing to initialize Firebase because the service account credentials are missing.

## Quick Fix Options

### Option 1: Place Service Account JSON File (Recommended)

1. **Get the service account key:**
   - Go to: https://console.firebase.google.com/project/amrutha-academy/settings/serviceaccounts/adminsdk
   - Click "Generate New Private Key"
   - Download the JSON file

2. **Place it in the backend root:**
   ```bash
   cd amrutha-academy-backend
   # Copy the downloaded file to:
   # amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json
   ```

3. **Restart the Next.js server:**
   ```bash
   npm run dev
   ```

### Option 2: Use Environment Variables

Create a `.env.local` file in `amrutha-academy-backend/`:

```env
FIREBASE_PROJECT_ID=amrutha-academy
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@amrutha-academy.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"
FIREBASE_STORAGE_BUCKET=amrutha-academy.firebasestorage.app
```

**Important:** Copy the entire private key from the service account JSON, including the `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` lines, and replace `\n` with actual newlines or use `\\n` in the env file.

### Option 3: Use GOOGLE_APPLICATION_CREDENTIALS

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/service-account-key.json"
npm run dev
```

## Verify Setup

After setting up Firebase, you should see in the server logs:
```
✅ Firebase initialized using service account JSON file
✅ Firebase services initialized
```

If you see warnings about Firebase not being initialized, check:
1. Service account file exists and is valid
2. File permissions are correct
3. Private key is properly formatted

## Note

The service account JSON file is intentionally excluded from git for security reasons. Each developer needs to set it up locally.


