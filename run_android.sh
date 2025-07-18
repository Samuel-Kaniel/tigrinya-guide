#!/bin/bash

# Exit on error
set -e

echo "🔄 Cleaning Flutter project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🚀 Running on Android device..."
flutter run -d android

# If no Android device is connected, try running on Android emulator
if [ $? -ne 0 ]; then
  echo "⚠️ No Android device found. Trying Android emulator..."
  flutter run -d "Android"
fi