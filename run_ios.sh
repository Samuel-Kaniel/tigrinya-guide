#!/bin/bash

# Exit on error
set -e

echo "🔄 Cleaning Flutter project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔄 Running pod install for iOS..."
cd ios && pod install && cd ..

echo "🚀 Running on iOS device..."
flutter run -d iPhone

# If no iPhone is connected, try running on iOS simulator
if [ $? -ne 0 ]; then
  echo "⚠️ No iPhone found. Trying iOS simulator..."
  flutter run -d "iPhone"
fi