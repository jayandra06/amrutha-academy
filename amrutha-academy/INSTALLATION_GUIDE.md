# Amrutha Academy - Installation Guide

This guide will help you set up both the backend and Flutter mobile app.

## Prerequisites

### ✅ Already Installed
- **Node.js** v20.19.3 ✓
- **npm** v10.8.2 ✓

### ❌ Need to Install
- **Flutter SDK** (for mobile app development)

---

## Part 1: Backend Setup (Next.js)

### Step 1: Install Dependencies ✅ COMPLETED
```bash
cd amrutha-academy-backend
npm install
```
**Status:** ✅ Dependencies installed successfully (555 packages)

### Step 2: Configure Environment Variables

You need to create a `.env.local` file in the `amrutha-academy-backend` directory.

**Option 1: Manual Creation (Recommended)**
1. Navigate to `amrutha-academy-backend` folder
2. Create a new file named `.env.local`
3. Add the following content:

```env
FIREBASE_PROJECT_ID=amrutha-academy
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@amrutha-academy.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDvh8lgEnTZiiky\nuU5uCXXet39S6Rgs5dQmQBQ1PkGLuG9wCqGEjVR4yPlWoFy4IvXjF16b/2e+YaFL\nZ4zn4D9nDo/oNlnTN5RDflfvuWvLzYRahQYY0mUpzfkSbwcARnGUrIsRBjD1/NjL\nq+QCWFhQbhXoChA6hxe7x4JjPXa3LWXEGDjh+ljmtqLzDBYOsVAeqIhkZwruykaJ\n6KR8YFEDYOfF4TkXwm/X50kUvW/Ws0XagL1OAsGDIHnTHTyU+3+2qYt7G8mZhmBt\nn5fZQDayVxVHhxM4ynr6dWvsObFS8hdNf/ueCu5KfeuatrZmutrLCJCy81FUgT7O\naTNfwGzvAgMBAAECggEAbzjO4eRQC78imCIBcAjGiY8M+ROxHQ/u7X/tojdxOg5+\n+DiHfUQeyCMR3A6EXyAkqrjsPmVe58Dvo1LG09iFuDXDzqCGHxR8rMZa0L55dl3M\nqjeAeEAhp0Kz98JELvWGwfFIdbQ5Qc+RXylGq2wYPeiQFXmuxW57L79ZJPmiSTVO\nKmwLqXSyhk/A4a2Qy51NBGDqbsEOAYxp1HoPTGhm11w/Avj+TZ3NhZEnxyiTOUSQ\nqqQbmsk1N5gn9j58Ty8ZDA+vjo7jmLrxzM1WxAIxt6B9TJ2bBO73N1fAcS3uuZGp\n7QRVoty5aXMepVOeIq4S47kEkyyj+FY4IRz1p1AaIQKBgQD/eC05fGLzB1FM7mj3\nm6dthDvDn45Om9VW7PjhiqSzO/Pfo1DBOf4HYmJc3Xqj/nZruaXAWGH8vKEN7meS\nx0lN4y5fnLXJJQpy3UUeCozrqFYbNULWQLUD26ESWPJwLxTTiaphDf4JLMFXs87N\nUtAJoaY8dImbArqp8GlADyPbEQKBgQDwByLDYu4WscF+N7sVBHkADth98E0mRANA\nNsBM2rxWc56/EiJ9WJjL7vbkWyD1RN6ofA6UaybfM1xE+3p6FRKOvZPKGvbp69PK\ntGh6UVI5UMSPH2hbIbV6TDk1eDQvJmbQGsRG6EtQMExp1fpQJRooW9FSHSPJVxll\n/XYyuc/H/wKBgQD4FCKOlUydRbjcZRPHhv6yKdvDXrjZexhTnjEdC/5eEtUCkdxE\nl2UolJCCL4z9nYgvmgrsWqdkv2QCXEV10lJL8VXCATLCTlb0Lg0FXCd2XHSpXTI3\nToS5Z1jlsTxUVlP6C9BJCUZscGqcGP60gjuFbtU4Fc7emWrcxZnfXBRskQKBgA5d\nPvVWbE0rYhr9ltKRK/SW7tnKkbNiipdDL4rp5C+AR9XDbhD2Rl6d9GSCF5zV/EU0\n92JmbzMYTcNLEW9Q54VnTvrfVjt1g300ArSfPT502O5/wK0DfWrOOPY8NVNFBw4Z\nK/naWPd5jHkg9xPoxIH5zLMPT17zOW/jFTm/6PFdAoGAfPaEoDtF9RU6rqFddavx\nBM1vWAfcqj6O3e5Yd4N8Du3j8Gz4H91BjmMUtC9X4fbTjdIIdNU2gaZoHCm9EmCP\nGJXHT/n+27jUAml0pmU8hzrFgDfeZWhMvmXIXHYp5dYHywQf/69xpD7rKbk91kz+\nieJWoBsDZmgGEMNkguCNGEQ=\n-----END PRIVATE KEY-----\n"
FIREBASE_STORAGE_BUCKET=amrutha-academy.firebasestorage.app
```

**Important:** Keep the private key in quotes and preserve the `\n` characters.

### Step 3: Run the Backend Server

```bash
cd amrutha-academy-backend
npm run dev
```

The API will be available at `http://localhost:3000/api`

---

## Part 2: Flutter Mobile App Setup

### Step 1: Install Flutter SDK

**For Windows:**

1. **Download Flutter SDK**
   - Visit: https://docs.flutter.dev/get-started/install/windows
   - Download the latest stable Flutter SDK ZIP file
   - Extract it to a location like `C:\src\flutter` (avoid spaces in path)

2. **Add Flutter to PATH**
   - Open "Environment Variables" in Windows
   - Add `C:\src\flutter\bin` to your PATH
   - Restart your terminal/IDE

3. **Verify Installation**
   ```bash
   flutter doctor
   ```
   This will check your setup and show what else needs to be configured.

4. **Install Additional Tools** (as recommended by `flutter doctor`)
   - Android Studio (for Android development)
   - Android SDK
   - VS Code or Android Studio with Flutter plugins

### Step 2: Install Flutter Dependencies

Once Flutter is installed:

```bash
cd amrutha-academy
flutter pub get
```

### Step 3: Run Code Generation

The app uses code generation for dependency injection and API clients:

```bash
cd amrutha-academy
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Configure Firebase for Android

1. **Download `google-services.json`**
   - Visit: https://console.firebase.google.com/project/amrutha-academy/settings/general
   - Scroll to "Your apps" section
   - Download `google-services.json` for Android app
   - Place it in: `amrutha-academy/android/app/google-services.json`

2. **Verify the file exists**
   ```
   amrutha-academy/
     android/
       app/
         google-services.json  ← Should be here
   ```

### Step 5: Run the Flutter App

```bash
cd amrutha-academy
flutter run
```

---

## Quick Start Commands Summary

### Backend
```bash
# Navigate to backend
cd amrutha-academy-backend

# Install dependencies (already done)
npm install

# Create .env.local file (manual step required)

# Run development server
npm run dev
```

### Flutter App
```bash
# Navigate to Flutter app
cd amrutha-academy

# Install dependencies (after Flutter SDK is installed)
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

---

## Troubleshooting

### Backend Issues

1. **Firebase connection errors**
   - Verify `.env.local` file exists and has correct values
   - Check that private key includes `\n` characters
   - Ensure Firebase services are enabled in Firebase Console

2. **Port already in use**
   - Change port: `npm run dev -- -p 3001`

### Flutter Issues

1. **Flutter not recognized**
   - Verify Flutter is in PATH
   - Restart terminal/IDE
   - Run `flutter doctor` to check setup

2. **Build errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Run code generation again

3. **Firebase initialization errors**
   - Ensure `google-services.json` is in correct location
   - Verify package name matches Firebase console

---

## Next Steps

1. ✅ Backend dependencies installed
2. ⏳ Create `.env.local` file for backend
3. ⏳ Install Flutter SDK
4. ⏳ Install Flutter app dependencies
5. ⏳ Run code generation
6. ⏳ Configure Firebase for Android
7. ⏳ Start development!

---

## Project Structure

```
amrutha-academy/
├── amrutha-academy/              # Flutter mobile app
│   ├── lib/                      # Dart source code
│   ├── android/                  # Android configuration
│   └── pubspec.yaml              # Flutter dependencies
│
└── amrutha-academy-backend/      # Next.js backend API
    ├── app/api/                  # API routes
    ├── lib/                      # TypeScript source code
    └── package.json              # Node.js dependencies
```

---

For detailed Firebase setup, see:
- Backend: `amrutha-academy-backend/FIREBASE_SETUP.md`
- Flutter: `amrutha-academy/FIREBASE_SETUP_ANDROID.md`

