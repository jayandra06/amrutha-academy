# Firebase Phone Authentication Setup

## Problem: Invalid App Credential Error

If you see this error:
```
❌ Phone verification failed: invalid-app-credential
The phone verification request contains an invalid application verifier.
```

This means your Android app's SHA-1/SHA-256 fingerprints are not registered in Firebase Console.

## Solution

### Step 1: Get Your SHA Fingerprints

Run the provided script:
```bash
cd amrutha-academy
./get-sha-fingerprints.sh
```

Or manually run:
```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android \
  -keypass android
```

Look for the **SHA1** and **SHA256** values in the output.

**Your current fingerprints:**
- **SHA-1**: `54:49:D2:A6:8B:00:5B:20:5D:F9:3F:F3:DA:C8:F1:0A:51:69:7E:6E`
- **SHA-256**: `78:8A:E2:1C:48:E1:F5:31:17:0F:8A:0E:25:7B:E2:58:E4:B9:E5:10:E3:50:30:C8:DB:B7:C4:3F:3D:55:94:E9`

### Step 2: Add Fingerprints to Firebase Console

1. Go to [Firebase Console - Project Settings](https://console.firebase.google.com/project/amrutha-academy/settings/general)

2. Scroll down to **"Your apps"** section

3. Find your Android app (package name: `com.amruthaacademy.amrutha_academy`)
   - If it doesn't exist, click **"Add app"** → **Android** and register it

4. Click on the Android app to expand it

5. Click **"Add fingerprint"** button

6. Paste your **SHA-1** fingerprint and click **Save**

7. Click **"Add fingerprint"** again and paste your **SHA-256** fingerprint and click **Save**

### Step 3: Download Updated google-services.json

1. After adding the fingerprints, click **"Download google-services.json"**

2. Replace the existing file:
   ```bash
   # Replace the file at:
   amrutha-academy/android/app/google-services.json
   ```

### Step 4: Rebuild Your App

```bash
cd amrutha-academy
flutter clean
flutter pub get
flutter run
```

## Verification

After completing these steps, try phone authentication again. The error should be resolved.

## Important Notes

- **Debug vs Release**: The fingerprints above are for **debug builds**. For release builds, you'll need to add your release keystore's SHA fingerprints as well.

- **Multiple Developers**: Each developer's debug keystore has different fingerprints. They need to add their own SHA fingerprints to Firebase Console, OR you can use a shared debug keystore.

- **Production**: Before releasing to production, add your release keystore's SHA fingerprints:
  ```bash
  keytool -list -v -keystore /path/to/your/release.keystore \
    -alias your-key-alias
  ```

## Troubleshooting

- **"App not registered"**: Make sure you added BOTH SHA-1 and SHA-256
- **"Still getting error"**: Wait a few minutes for Firebase to propagate changes, then rebuild
- **"Can't find keystore"**: The script will create it automatically, or run `flutter build apk` first


