# How to Run Flutter App on Android

## Prerequisites

### 1. Install Android Studio
1. Download from: https://developer.android.com/studio
2. Install Android Studio
3. Open Android Studio and complete the setup wizard
4. The setup wizard will install Android SDK automatically

### 2. Accept Android Licenses
After installing Android Studio, open a terminal and run:
```bash
flutter doctor --android-licenses
```
Accept all licenses when prompted (press `y` for each)

### 3. Verify Setup
```bash
flutter doctor
```
You should see `[√] Android toolchain` checked after setup.

## Running on Android

### Option 1: Using Android Emulator (Recommended for Testing)

1. **Create an Android Virtual Device (AVD)**
   - Open Android Studio
   - Click "More Actions" → "Virtual Device Manager"
   - Click "Create Device"
   - Select a device (e.g., Pixel 5)
   - Select a system image (e.g., Android 13, API 33)
   - Click "Finish"

2. **Start the Emulator**
   - In Virtual Device Manager, click the ▶️ play button next to your AVD
   - Or from terminal: `flutter emulators --launch <emulator_id>`

3. **Run the App**
   ```bash
   cd amrutha-academy
   flutter run
   ```
   Flutter will automatically detect the emulator and install the app.

### Option 2: Using Physical Android Device

1. **Enable Developer Options on Your Phone**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect Your Phone**
   - Connect phone to computer via USB
   - On your phone, allow USB debugging when prompted

3. **Verify Device is Detected**
   ```bash
   flutter devices
   ```
   You should see your Android device listed.

4. **Run the App**
   ```bash
   cd amrutha-academy
   flutter run
   ```
   Or specify the device:
   ```bash
   flutter run -d <device-id>
   ```

## Troubleshooting

### Android SDK Not Found
If Flutter can't find Android SDK:
```bash
flutter config --android-sdk <path-to-android-sdk>
```
Default location: `C:\Users\<YourUsername>\AppData\Local\Android\Sdk`

### No Devices Found
- Make sure emulator is running OR
- Physical device is connected and USB debugging is enabled
- Run `flutter devices` to see available devices

### Build Errors
```bash
cd amrutha-academy
flutter clean
flutter pub get
flutter run
```

### Firebase Configuration
Make sure `google-services.json` is in:
```
amrutha-academy/android/app/google-services.json
```

## Quick Commands

```bash
# Check available devices
flutter devices

# List available emulators
flutter emulators

# Launch a specific emulator
flutter emulators --launch <emulator_id>

# Run on Android
cd amrutha-academy
flutter run

# Run on specific device
flutter run -d <device-id>

# Check Flutter setup
flutter doctor
```
