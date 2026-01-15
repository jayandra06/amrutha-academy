# Firebase Setup for Android (Flutter App)

## Problem
The app is stuck at splash screen because it's missing `google-services.json` file for Android.

## Quick Solution: Direct Download Link

**🔗 Direct link to your project settings:**
https://console.firebase.google.com/project/amrutha-academy/settings/general

## Method 1: Manual Download (Recommended - Fastest)

1. **Go to Firebase Console**
   - Click this direct link: https://console.firebase.google.com/project/amrutha-academy/settings/general
   - Or visit: https://console.firebase.google.com/ → Select "amrutha-academy"

2. **Scroll to "Your apps" section**
   - On the General settings page, scroll down to find "Your apps" section

3. **Create Android App (if not exists)**
   - If you see no Android app, click **"Add app"** → Select **Android** icon
   - **Android package name**: `com.amruthaacademy.amrutha_academy`
   - **App nickname** (optional): `Amrutha Academy`
   - Click **"Register app"**

4. **Download google-services.json**
   - After registering (or if app already exists), you'll see a "Download google-services.json" button
   - Click to download the file

5. **Place the file in your project**
   - Move the downloaded `google-services.json` file to:
   ```
   amrutha-academy/android/app/google-services.json
   ```

6. **Rebuild the app**
   ```bash
   cd amrutha-academy
   flutter clean
   flutter pub get
   flutter run
   ```

## Method 2: Using Firebase CLI (Alternative)

If you prefer command line:

1. **Login to Firebase** (first time only)
   ```bash
   cd amrutha-academy
   firebase login
   ```
   This will open a browser for authentication.

2. **Run the download script**
   ```bash
   ./download-firebase-config.sh
   ```

   Or manually:
   ```bash
   firebase apps:sdkconfig android android:com.amruthaacademy.amrutha_academy \
     --project amrutha-academy > android/app/google-services.json
   ```

## Verify the setup

After placing the file, verify the structure:
```
amrutha-academy/
  android/
    app/
      google-services.json  ← This file should exist
      build.gradle.kts
```

## Important Notes

- **Package name must match**: `com.amruthaacademy.amrutha_academy` (from `android/app/build.gradle.kts`)
- The build.gradle.kts files have been configured to use the google-services plugin automatically
- After adding the file, Firebase will be able to initialize and the app will proceed past the splash screen

## Troubleshooting

If you get errors after adding the file:
1. Make sure the package name matches exactly
2. Run `flutter clean` before rebuilding
3. Check that `google-services.json` is valid JSON
4. Verify the plugin is applied in `android/app/build.gradle.kts`:
   ```kotlin
   plugins {
       // ... other plugins
       id("com.google.gms.google-services")
   }
   ```

