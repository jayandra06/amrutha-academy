#!/bin/bash

# Script to download google-services.json for Android
# This requires Firebase CLI and authentication

set -e

echo "🔧 Firebase Configuration Downloader"
echo "======================================"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed."
    echo "Install it with: npm install -g firebase-tools"
    exit 1
fi

echo "✅ Firebase CLI found: $(firebase --version)"
echo ""

# Check if logged in
if ! firebase projects:list &> /dev/null; then
    echo "🔐 You need to login to Firebase first."
    echo "Running: firebase login"
    echo ""
    echo "⚠️  This will open a browser window for authentication."
    echo "Press Enter to continue..."
    read -r
    firebase login
fi

PROJECT_ID="amrutha-academy"
APP_ID="android:com.amruthaacademy.amrutha_academy"
OUTPUT_FILE="android/app/google-services.json"

echo ""
echo "📱 Project: $PROJECT_ID"
echo "📦 App ID: $APP_ID"
echo "📄 Output: $OUTPUT_FILE"
echo ""

# Try to download the config
echo "🔍 Checking for existing Android app..."
echo ""

# Get apps for the project
APPS=$(firebase apps:list --project "$PROJECT_ID" --format json 2>/dev/null || echo "[]")

if echo "$APPS" | grep -q "android"; then
    echo "✅ Android app found!"
    echo ""
    echo "📥 Downloading google-services.json..."
    
    # Use Firebase CLI to get app config
    firebase apps:sdkconfig android "$APP_ID" --project "$PROJECT_ID" > "$OUTPUT_FILE" 2>&1 || {
        echo ""
        echo "⚠️  Could not download automatically."
        echo "Please download manually from Firebase Console:"
        echo "https://console.firebase.google.com/project/$PROJECT_ID/settings/general"
        echo ""
        echo "1. Go to Project Settings > Your apps"
        echo "2. Find Android app (or create one with package: com.amruthaacademy.amrutha_academy)"
        echo "3. Download google-services.json"
        echo "4. Place it in: $OUTPUT_FILE"
        exit 1
    }
    
    echo "✅ Downloaded successfully!"
    echo ""
    echo "📋 File location: $OUTPUT_FILE"
else
    echo "❌ Android app not found in Firebase project."
    echo ""
    echo "📝 You need to create an Android app first:"
    echo ""
    echo "1. Go to: https://console.firebase.google.com/project/$PROJECT_ID/settings/general"
    echo "2. Scroll to 'Your apps' section"
    echo "3. Click 'Add app' > Android"
    echo "4. Package name: com.amruthaacademy.amrutha_academy"
    echo "5. Register the app"
    echo "6. Download google-services.json"
    echo "7. Place it in: $OUTPUT_FILE"
    echo ""
    exit 1
fi

echo ""
echo "✅ Setup complete! Now run:"
echo "   flutter clean && flutter pub get && flutter run"



