# Technology Stack

## Core Framework
- Flutter SDK (>=3.10.0)
- Dart (>=3.0.0)

## Dependencies
- **State Management**: Provider
- **Local Storage**: 
  - SQLite (sqflite)
  - Shared Preferences
- **Network**: HTTP package
- **Text-to-Speech**: flutter_tts
- **Animations**: animate_do

## Backend Services
- **AWS Infrastructure**:
  - DynamoDB for data storage
  - Lambda for serverless functions
  - API Gateway for REST endpoints
  - S3 for static web hosting
  - CloudFront for content delivery

## Development Tools
- Flutter CLI
- AWS CLI (for deployment)

## Common Commands

### Flutter Development
```bash
# Get dependencies
flutter pub get

# Run the app in debug mode
flutter run

# Build for specific platforms
flutter build ios
flutter build apk
flutter build web

# Run tests
flutter test
```

### AWS Deployment
```bash
# Deploy infrastructure
./deploy.sh

# Update Lambda function
cd aws/lambda
zip -r function.zip .
aws lambda update-function-code --function-name tigrinya-guide-letters-handler --zip-file fileb://function.zip
```

## Code Style Guidelines
- Use camelCase for variables and functions
- Use PascalCase for classes and enums
- Prefer const constructors when possible
- Use .withValues() instead of deprecated .withOpacity() for colors
- Use logging framework instead of print statements
- Follow Flutter's recommended widget structure patterns