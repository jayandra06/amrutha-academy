# Firebase Setup Instructions

## Your Firebase Project Details

Based on your Firebase configuration:

- **Project ID**: `amrutha-academy`
- **Storage Bucket**: `amrutha-academy.firebasestorage.app`
- **Auth Domain**: `amrutha-academy.firebaseapp.com`

## Important: Backend vs Frontend Configuration

The configuration you provided (apiKey, authDomain, etc.) is for the **Frontend/Client SDK**. 

For the **Backend (Next.js)**, we need **Service Account credentials** which are different.

## Steps to Get Service Account Credentials

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Select your project: `amrutha-academy`

2. **Open Project Settings**
   - Click the gear icon ⚙️ next to "Project Overview"
   - Select "Project settings"

3. **Navigate to Service Accounts Tab**
   - Click on "Service accounts" tab
   - You'll see "Firebase Admin SDK" section

4. **Generate New Private Key**
   - Click "Generate new private key" button
   - Confirm by clicking "Generate key"
   - A JSON file will be downloaded (e.g., `amrutha-academy-firebase-adminsdk-xxxxx.json`)

5. **Extract Credentials from JSON**
   Open the downloaded JSON file and extract:
   ```json
   {
     "project_id": "amrutha-academy",
     "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
     "client_email": "firebase-adminsdk-xxxxx@amrutha-academy.iam.gserviceaccount.com"
   }
   ```

6. **Update .env.local**
   Create a `.env.local` file in the root directory with:
   ```env
   FIREBASE_PROJECT_ID=amrutha-academy
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@amrutha-academy.iam.gserviceaccount.com
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour-Actual-Private-Key-Here\n-----END PRIVATE KEY-----\n"
   FIREBASE_STORAGE_BUCKET=amrutha-academy.firebasestorage.app
   ```

   **Important**: 
   - Copy the entire private key including the `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` lines
   - Keep the `\n` characters in the private key
   - The private key should be in quotes and include newline characters

## Enable Required Firebase Services

Make sure these are enabled in your Firebase project:

1. **Firestore Database**
   - Go to "Firestore Database" in the left menu
   - Click "Create database"
   - Choose production or test mode (you can update rules later)
   - Select a location

2. **Firebase Authentication**
   - Go to "Authentication" in the left menu
   - Click "Get started"
   - Enable sign-in methods (Email/Password, etc.)

3. **Firebase Storage**
   - Go to "Storage" in the left menu
   - Click "Get started"
   - Choose security rules
   - Select a location (same as Firestore recommended)

## Security Notes

- ⚠️ **NEVER commit the service account JSON file or .env.local to git**
- The service account key has admin privileges
- Keep it secure and only use it on the backend/server
- Add `.env.local` to `.gitignore` (should already be there)

## Testing the Setup

After setting up `.env.local`, restart your development server:

```bash
npm run dev
```

The API should now connect to your Firebase project.

