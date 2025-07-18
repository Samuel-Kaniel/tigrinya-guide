# Tigrinya Guide

A Flutter mobile and web application for learning the Tigrinya alphabet with pronunciation guides, examples, and interactive quizzes.

## Features

- **Alphabet Learning**: Browse through all Tigrinya letters with pronunciations
- **Practice Mode**: Flashcard-style practice with show/hide answers
- **Interactive Quiz**: Test your knowledge with multiple-choice questions
- **Progress Tracking**: Track your learning progress locally
- **Cloud Sync**: Synchronize data with AWS backend
- **Cross-Platform**: Works on iOS, Android, and Web

## Screenshots

The app includes:
- Home screen with navigation to different learning modes
- Alphabet grid view with letter details
- Practice flashcards with pronunciation and examples
- Quiz system with scoring and progress tracking

## Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile and web framework
- **Dart**: Programming language
- **Provider**: State management
- **SQLite**: Local database storage
- **HTTP**: API communication

### Backend (AWS)
- **API Gateway**: REST API endpoints
- **Lambda**: Serverless functions (Python)
- **DynamoDB**: NoSQL database
- **S3**: Static web hosting
- **CloudFront**: CDN for global distribution
- **CloudFormation**: Infrastructure as Code

## Getting Started

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- AWS CLI configured with appropriate permissions
- Python 3.9+ (for Lambda functions)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_tigrinya_guide
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For mobile development
   flutter run
   
   # For web development
   flutter run -d chrome
   ```

### AWS Deployment

1. **Configure AWS credentials**
   ```bash
   aws configure
   ```

2. **Deploy infrastructure and app**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

   This script will:
   - Deploy AWS infrastructure using CloudFormation
   - Build the Flutter web app
   - Upload to S3 for hosting
   - Update Lambda functions
   - Initialize DynamoDB with sample data

3. **Access your deployed app**
   - The deployment script will output the CloudFront URL
   - Your app will be available globally via CDN

## Project Structure

```
flutter_tigrinya_guide/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── letter.dart          # Letter data model
│   ├── screens/
│   │   ├── home_screen.dart     # Main navigation screen
│   │   ├── alphabet_screen.dart # Letter grid view
│   │   ├── practice_screen.dart # Flashcard practice
│   │   └── quiz_screen.dart     # Interactive quiz
│   ├── services/
│   │   ├── database_service.dart # Local SQLite operations
│   │   └── aws_service.dart     # Cloud API integration
│   └── providers/
│       └── app_state.dart       # Global state management
├── aws/
│   ├── cloudformation/
│   │   └── infrastructure.yaml  # AWS infrastructure template
│   └── lambda/
│       └── letters_handler.py   # Lambda function for API
├── assets/                      # Images, fonts, audio files
├── pubspec.yaml                # Flutter dependencies
├── deploy.sh                   # Deployment script
└── README.md                   # This file
```

## API Endpoints

The AWS Lambda function provides these REST endpoints:

- `GET /letters` - Retrieve all letters
- `GET /letters/{id}` - Get specific letter
- `POST /letters` - Create new letter
- `PUT /letters/{id}` - Update existing letter
- `DELETE /letters/{id}` - Delete letter

## Database Schema

### Local SQLite Tables

**letters**
- id (INTEGER PRIMARY KEY)
- character (TEXT) - Tigrinya character
- pronunciation (TEXT) - Phonetic pronunciation
- example (TEXT) - Example word
- translation (TEXT) - English translation
- audio_url (TEXT) - Optional audio file URL

**user_progress**
- id (INTEGER PRIMARY KEY)
- letter_id (INTEGER) - Foreign key to letters
- practice_count (INTEGER) - Number of times practiced
- quiz_correct (INTEGER) - Correct quiz answers
- quiz_attempts (INTEGER) - Total quiz attempts
- last_practiced (TEXT) - Timestamp of last practice

### AWS DynamoDB

**tigrinya-letters** table with the same structure as local SQLite, plus:
- created_at (STRING) - ISO timestamp
- updated_at (STRING) - ISO timestamp

## Configuration

### Environment Variables

For production deployment, set these environment variables:

```bash
export AWS_REGION=us-east-1
export API_GATEWAY_URL=https://your-api-id.execute-api.region.amazonaws.com/prod
export DYNAMODB_TABLE_NAME=tigrinya-guide-letters
```

### App Configuration

Update `lib/config/app_config.dart` with your API endpoints:

```dart
class AppConfig {
  static const String apiBaseUrl = 'https://your-api-gateway-url.amazonaws.com/prod';
  static const String appName = 'Tigrinya Guide';
  static const String version = '1.0.0';
}
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team

## Roadmap

- [ ] Audio pronunciation playback
- [ ] Advanced quiz modes
- [ ] User authentication
- [ ] Social features and leaderboards
- [ ] Offline mode improvements
- [ ] Additional language support
- [ ] Mobile app store deployment