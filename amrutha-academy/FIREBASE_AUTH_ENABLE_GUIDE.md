# Firebase Authentication Setup Guide

## ✅ Current Status

### What's Already Done:
1. ✅ Firebase Auth package installed (`firebase_auth: ^5.3.1`)
2. ✅ Firebase Auth initialized in `FirebaseConfig`
3. ✅ Phone Authentication screen implemented (`phone_auth_screen.dart`)
4. ✅ Authentication flow integrated (Splash → Auth → Main)
5. ✅ User profile management with Firestore
6. ✅ Sign out functionality implemented

### What You Need to Do:

## 🔧 Enable Phone Authentication in Firebase Console

### Step 1: Go to Firebase Console
1. Open: https://console.firebase.google.com/project/amrutha-cademy/authentication
2. Or navigate: Firebase Console → Your Project → Authentication

### Step 2: Enable Phone Authentication
1. Click on **"Get started"** (if you see this button)
2. Go to **"Sign-in method"** tab
3. Find **"Phone"** in the list of providers
4. Click on **"Phone"**
5. Toggle **"Enable"** to ON
6. Click **"Save"**

### Step 3: Configure Phone Authentication (Optional but Recommended)
1. **Test phone numbers** (for development):
   - You can add test phone numbers that will bypass SMS verification
   - Useful for testing without using real SMS credits
   - Format: `+91XXXXXXXXXX` (with country code)

2. **App verification**:
   - For Android: Make sure SHA-1 and SHA-256 fingerprints are added (see `FIREBASE_PHONE_AUTH_SETUP.md`)
   - For iOS: Make sure the app is properly configured

### Step 4: Verify Setup
After enabling Phone Auth, your app should work. Test by:
1. Running the app: `flutter run`
2. Entering a phone number
3. Receiving OTP (or using test phone number)
4. Verifying and logging in

## 📱 Current Authentication Flow

1. **Splash Screen** → Checks if user is logged in
2. **If not logged in** → Redirects to `PhoneAuthScreen`
3. **Phone Auth Screen**:
   - User enters phone number
   - OTP is sent via Firebase
   - User enters OTP
   - User is authenticated
4. **After Auth**:
   - If profile incomplete → `ProfileCompletionScreen`
   - If profile complete → `MainNavigationScreen`

## 🔐 Authentication Methods Currently Implemented

### ✅ Phone Authentication (Primary)
- **Status**: Fully implemented
- **Screen**: `lib/presentation/screens/auth/phone_auth_screen.dart`
- **Features**:
  - Phone number validation
  - OTP sending
  - OTP verification
  - Resend OTP (with 60s cooldown)
  - Error handling
  - Auto-verification (when available)

### ❌ Email/Password Authentication
- **Status**: NOT implemented
- **Note**: Email is stored in user profiles but not used for authentication

## 🚨 Important: SHA Fingerprints for Android

If you get `invalid-app-credential` error, you need to add SHA fingerprints:

1. **Get your SHA fingerprints**:
   ```bash
   cd amrutha-academy
   ./get-sha-fingerprints.sh
   ```

2. **Add to Firebase Console**:
   - Go to: https://console.firebase.google.com/project/amrutha-cademy/settings/general
   - Scroll to "Your apps" → Android app
   - Click "Add fingerprint"
   - Add SHA-1 and SHA-256

See `FIREBASE_PHONE_AUTH_SETUP.md` for detailed instructions.

## ✅ Verification Checklist

- [ ] Phone Authentication enabled in Firebase Console
- [ ] SHA-1 fingerprint added to Firebase (for Android)
- [ ] SHA-256 fingerprint added to Firebase (for Android)
- [ ] Test phone authentication in the app
- [ ] Verify OTP is received
- [ ] Test login flow end-to-end

## 🧪 Testing

### Test with Real Phone Number:
1. Run the app
2. Enter your phone number (with country code, e.g., `+91XXXXXXXXXX`)
3. Wait for OTP SMS
4. Enter OTP
5. Should log in successfully

### Test with Test Phone Number (if configured):
1. Add test phone number in Firebase Console
2. Use that number in the app
3. OTP will be auto-verified (no SMS sent)

## 📝 Next Steps After Enabling

1. **Test the authentication flow**
2. **Set up Firestore Security Rules** (if not done):
   - Go to Firestore Database → Rules
   - Configure rules to protect user data

3. **Set up Cloud Messaging** (if using push notifications):
   - Already initialized in `FirebaseConfig`
   - Configure in Firebase Console if needed

4. **Monitor Authentication**:
   - Firebase Console → Authentication → Users
   - See all authenticated users

## 🐛 Troubleshooting

### Error: "Phone authentication is not enabled"
- **Solution**: Enable Phone Auth in Firebase Console (Step 2 above)

### Error: "invalid-app-credential"
- **Solution**: Add SHA fingerprints (see `FIREBASE_PHONE_AUTH_SETUP.md`)

### Error: "too-many-requests"
- **Solution**: Wait 15-30 minutes, Firebase temporarily blocks after too many attempts

### OTP not received
- Check phone number format (must include country code)
- Check Firebase Console → Authentication → Usage for quota
- Verify phone number is correct

## 📚 Related Files

- `lib/core/config/firebase_config.dart` - Firebase initialization
- `lib/presentation/screens/auth/phone_auth_screen.dart` - Phone auth UI
- `lib/presentation/screens/splash/splash_screen.dart` - Auth state check
- `FIREBASE_PHONE_AUTH_SETUP.md` - SHA fingerprint setup

