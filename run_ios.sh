#!/bin/bash

# CuckooBooru iOS App Runner (macOS only)
# This script builds and runs the CuckooBooru Flutter application for iOS

echo "CuckooBooru iOS Build Script"
echo "============================"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: iOS development requires macOS"
    echo "   Current OS: $OSTYPE"
    echo "   Please use this script on a Mac with Xcode installed"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "   Please install Xcode from the App Store"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed"
    echo "   Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ macOS detected"
echo "✅ Xcode found"
echo "✅ Flutter found"
echo ""

echo "Installing dependencies..."
flutter pub get

echo "Installing iOS pods..."
cd ios && pod install && cd ..

if [ $? -ne 0 ]; then
    echo "❌ Pod install failed"
    exit 1
fi

echo ""
echo "Available iOS devices:"
flutter devices | grep -E "(iOS|simulator)"

echo ""
echo "Building for iOS simulator..."
flutter build ios --debug --simulator

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "Starting iOS simulator..."
    flutter run -d "iPhone 15 Simulator"
else
    echo "❌ Build failed"
    echo ""
    echo "Troubleshooting tips:"
    echo "1. Make sure Xcode is up to date"
    echo "2. Run 'flutter doctor' to check for issues"
    echo "3. Try 'flutter clean' and run this script again"
    exit 1
fi