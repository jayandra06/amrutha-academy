# ⚠️ URGENT: Regenerate Firebase Service Account Key

## Security Alert

The Firebase service account key was accidentally committed to the repository and has been exposed on GitHub. **You must regenerate it immediately.**

## Steps to Fix:

### 1. Delete the Old Service Account Key

1. Go to Firebase Console: https://console.firebase.google.com/project/amrutha-academy/settings/serviceaccounts/adminsdk
2. Find the service account: `firebase-adminsdk-fbsvc@amrutha-academy.iam.gserviceaccount.com`
3. Click on the key (or delete it if possible)
4. **Delete the old key** to revoke access

### 2. Generate a New Service Account Key

1. In the same page, click **"Generate New Private Key"**
2. Click **"Generate Key"** to confirm
3. Download the new JSON file
4. Save it as: `amrutha-academy-firebase-adminsdk-fbsvc-2b814053af.json` (or any name)
5. Place it in: `amrutha-academy-backend/` directory

### 3. Update Local Files

The file is now in `.gitignore` and will NOT be committed to git.

### 4. Verify

- The new JSON file should be in `amrutha-academy-backend/`
- It should NOT appear in `git status`
- Restart your Next.js server: `npm run dev`

## Important Notes:

- ✅ The file is now in `.gitignore` - it will NOT be committed again
- ✅ The old key has been removed from git tracking
- ⚠️ **You MUST regenerate the key** - the old one is compromised
- ⚠️ Anyone who has access to the GitHub repository has seen the private key

## Alternative: Use Environment Variables

Instead of the JSON file, you can use `.env.local`:

1. Create `.env.local` in `amrutha-academy-backend/`
2. Add:
```env
FIREBASE_PROJECT_ID=amrutha-academy
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@amrutha-academy.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_STORAGE_BUCKET=amrutha-academy.firebasestorage.app
```

3. Copy the private key from the new service account JSON (keep `\n` for newlines)

