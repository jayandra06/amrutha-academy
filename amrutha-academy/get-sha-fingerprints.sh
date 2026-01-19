#!/bin/bash

# Script to get SHA-1 and SHA-256 fingerprints for Firebase Phone Auth
# This is required for Android apps to use Firebase Phone Authentication

echo "🔐 Getting SHA fingerprints for Firebase Phone Auth..."
echo ""

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo "❌ keytool not found. Please install Java JDK."
    echo "   On Ubuntu/Debian: sudo apt-get install openjdk-11-jdk"
    exit 1
fi

# Default debug keystore path for Linux/Mac
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"

# Check if debug keystore exists
if [ ! -f "$DEBUG_KEYSTORE" ]; then
    echo "⚠️  Debug keystore not found at: $DEBUG_KEYSTORE"
    echo "   Creating debug keystore..."
    
    # Create .android directory if it doesn't exist
    mkdir -p "$HOME/.android"
    
    # Generate debug keystore
    keytool -genkey -v -keystore "$DEBUG_KEYSTORE" \
        -alias androiddebugkey \
        -storepass android \
        -keypass android \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -dname "CN=Android Debug,O=Android,C=US"
    
    echo "✅ Debug keystore created!"
    echo ""
fi

echo "📋 SHA Fingerprints:"
echo "─────────────────────────────────────────────────────────"
echo ""

# Get SHA-1
echo "SHA-1:"
keytool -list -v -keystore "$DEBUG_KEYSTORE" \
    -alias androiddebugkey \
    -storepass android \
    -keypass android 2>/dev/null | grep -A 1 "SHA1:" | grep -o "[0-9A-F:]\{59,59\}"

echo ""
echo "SHA-256:"
keytool -list -v -keystore "$DEBUG_KEYSTORE" \
    -alias androiddebugkey \
    -storepass android \
    -keypass android 2>/dev/null | grep -A 1 "SHA256:" | grep -o "[0-9A-F:]\{95,95\}"

echo ""
echo "─────────────────────────────────────────────────────────"
echo ""
echo "📝 Next steps:"
echo "   1. Copy the SHA-1 and SHA-256 fingerprints above"
echo "   2. Go to Firebase Console: https://console.firebase.google.com/project/amrutha-academy/settings/general"
echo "   3. Scroll to 'Your apps' section"
echo "   4. Click on your Android app (or create it if needed)"
echo "   5. Click 'Add fingerprint' and paste the SHA-1"
echo "   6. Click 'Add fingerprint' again and paste the SHA-256"
echo "   7. Download the updated google-services.json and replace the existing one"
echo "   8. Rebuild your Flutter app: flutter clean && flutter run"
echo ""


