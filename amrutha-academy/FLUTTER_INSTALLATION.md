# Flutter Installation Guide for Windows

## Quick Installation Steps

### Option 1: Manual Installation (Recommended)

1. **Download Flutter SDK**
   - Visit: https://docs.flutter.dev/get-started/install/windows
   - Or direct download: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip
   - Download the ZIP file

2. **Extract Flutter**
   - Extract the ZIP to a location like `C:\src\flutter` or `C:\flutter`
   - **Important:** Avoid paths with spaces or special characters
   - Do NOT extract to `C:\Program Files\` (requires admin rights)

3. **Add Flutter to PATH**
   - Press `Win + X` and select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "User variables", find "Path" and click "Edit"
   - Click "New" and add: `C:\src\flutter\bin` (or your Flutter path)
   - Click "OK" on all dialogs
   - **Restart your terminal/IDE** for changes to take effect

4. **Verify Installation**
   ```powershell
   flutter --version
   flutter doctor
   ```

### Option 2: Using Chocolatey (Requires Admin)

If you have administrator access:

1. **Open PowerShell as Administrator**
   - Right-click PowerShell → "Run as Administrator"

2. **Install Flutter**
   ```powershell
   choco install flutter -y
   ```

3. **Restart terminal and verify**
   ```powershell
   flutter --version
   flutter doctor
   ```

## After Installation

Once Flutter is installed, run these commands in the project:

```powershell
# Navigate to Flutter app directory
cd amrutha-academy\amrutha-academy

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Check Flutter setup
flutter doctor
```

## Troubleshooting

### Flutter command not found after installation
- Restart your terminal/IDE completely
- Verify PATH is set correctly: `echo $env:PATH` (should include flutter\bin)
- Try using full path: `C:\src\flutter\bin\flutter.bat --version`

### Flutter doctor shows issues
- Install Android Studio for Android development
- Install VS Code with Flutter extension
- Accept Android licenses: `flutter doctor --android-licenses`

### Permission errors
- Don't install to `C:\Program Files\`
- Use `C:\src\flutter` or `C:\flutter` instead
- Ensure you have write permissions to the installation directory

