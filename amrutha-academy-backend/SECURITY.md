# Security Guidelines

## ⚠️ IMPORTANT: Never Commit Sensitive Files

### Files That Should NEVER Be Committed:

1. **Firebase Service Account JSON Files**
   - Pattern: `*-firebase-adminsdk-*.json`
   - These contain private keys and should be kept local only
   - Use environment variables or `.env.local` instead

2. **Environment Files**
   - `.env`
   - `.env.local`
   - `.env*.local`

### How to Set Up Firebase Credentials Securely:

#### Option 1: Use Environment Variables (Recommended)

Create a `.env.local` file in `amrutha-academy-backend/`:

```env
FIREBASE_PROJECT_ID=amrutha-academy
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@amrutha-academy.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_STORAGE_BUCKET=amrutha-academy.firebasestorage.app
```

**Important:** 
- Copy the entire private key including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`
- Keep newlines as `\n` in the string
- Never commit `.env.local` to git

#### Option 2: Use Service Account JSON File (Local Only)

1. Download the service account JSON from Firebase Console
2. Place it in `amrutha-academy-backend/` directory
3. Name it: `amrutha-academy-firebase-adminsdk-*.json`
4. **DO NOT commit it to git** - it's already in `.gitignore`

### If You Accidentally Committed Sensitive Data:

1. **Immediately regenerate the exposed credentials:**
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Delete the old key

2. **Remove from git history:**
   ```bash
   git rm --cached <file>
   git commit -m "Remove sensitive file"
   git push
   ```

3. **Update .gitignore** to prevent future commits

4. **Rotate all exposed credentials** in Firebase Console

### Current .gitignore Protection:

The following patterns are ignored:
- `*-firebase-adminsdk-*.json`
- `.env.local`
- `.env*.local`

