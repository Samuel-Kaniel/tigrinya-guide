#!/bin/bash

# Exit on error
set -e

echo "🔄 Cleaning Flutter project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔄 Running pod install for iOS..."
cd ios && pod install && cd ..

echo "🚀 Starting iOS simulator..."
open -a Simulator

echo "⏳ Waiting for simulator to boot..."
sleep 5

echo "🚀 Running on iOS simulator..."
flutter run -d "iPhone"