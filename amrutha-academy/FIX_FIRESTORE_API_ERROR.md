# Fix: Firestore API Not Enabled Error

## 🔴 Error You're Seeing:
```
W/Firestore( 5212): Cloud Firestore API has not been used in project amrutha-cademy before or it is disabled. 
Enable it by visiting https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=amrutha-cademy
```

## ✅ Solution: Enable Firestore API

### Step 1: Enable Firestore API in Google Cloud Console

**Direct Link**: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=amrutha-cademy

**Steps:**
1. Click the link above (or go to Google Cloud Console)
2. Make sure the project is selected: **amrutha-cademy**
3. Click **"Enable"** button
4. Wait 1-2 minutes for the API to be enabled

### Step 2: Enable Firestore in Firebase Console

1. Go to: https://console.firebase.google.com/project/amrutha-cademy/firestore
2. Click **"Create database"** (if you see this)
3. Choose:
   - **Start in test mode** (for development) OR
   - **Start in production mode** (for production - requires security rules)
4. Select a location (choose closest to your users)
5. Click **"Enable"**

### Step 3: Set Up Firestore Security Rules (Important!)

After creating the database, set up security rules:

1. Go to: https://console.firebase.google.com/project/amrutha-cademy/firestore/rules
2. Update the rules based on your needs. For development, you can use:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // Allow authenticated users to read any user
    }
    
    // Add other collections as needed
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Click **"Publish"**

### Step 4: Rebuild Your App

```bash
cd /home/jay/Desktop/amrutha-academy/amrutha-academy
flutter clean
flutter pub get
flutter run
```

## 📝 Additional Notes

### Play Integrity Token Warning (Line 251)
You also see this warning:
```
Invalid PlayIntegrity token; app not Recognized by Play Store.
```

**This is normal for debug builds!** Firebase automatically falls back to reCAPTCHA verification (which worked - see line 290: "✅ OTP code sent successfully").

**To fix this for production:**
1. Upload your app to Google Play Console (internal testing track)
2. The app will be recognized by Play Store
3. Play Integrity will work automatically

**For now, the reCAPTCHA fallback is working fine for development.**

## ✅ Verification

After enabling Firestore API:
1. The error should disappear
2. Your app should be able to read/write to Firestore
3. Check Firebase Console → Firestore Database to see your data

## 🔗 Quick Links

- **Enable Firestore API**: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=amrutha-cademy
- **Firestore Console**: https://console.firebase.google.com/project/amrutha-cademy/firestore
- **Security Rules**: https://console.firebase.google.com/project/amrutha-cademy/firestore/rules

