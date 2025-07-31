#!/bin/bash

echo "🧹 Cleaning iOS project..."

# Clean Flutter
flutter clean

# Clean iOS build
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf Flutter/Generated.xcconfig

# Clean Xcode build
xcodebuild clean -workspace Runner.xcworkspace -scheme Runner

echo "📦 Installing pods..."
pod install

echo "🔄 Getting Flutter dependencies..."
cd ..
flutter pub get

echo "✅ iOS project cleaned and ready!"
echo "🚀 Now run: flutter run" 