# Project Structure

## Main Application Structure
```
tigrinya_guide/
├── lib/                    # Main source code
│   ├── main.dart           # Application entry point
│   ├── models/             # Data models
│   ├── providers/          # State management
│   ├── screens/            # UI screens
│   ├── services/           # Business logic and external services
│   └── widgets/            # Reusable UI components
├── assets/                 # Static assets
│   ├── audio/              # Audio files for pronunciation
│   ├── fonts/              # Custom fonts
│   └── images/             # Images and icons
├── aws/                    # AWS infrastructure
│   ├── cloudformation/     # CloudFormation templates
│   └── lambda/             # Lambda function code
├── test/                   # Unit and widget tests
└── test_tts/               # TTS testing module
```

## Key Files

### Core Application
- `lib/main.dart` - Application entry point and theme configuration
- `lib/providers/app_state.dart` - Global state management
- `lib/services/database_service.dart` - Local database operations
- `lib/services/pronunciation_service.dart` - Text-to-speech functionality
- `lib/services/aws_service.dart` - AWS API integration

### UI Components
- `lib/screens/home_screen.dart` - Main navigation hub
- `lib/screens/alphabet_screen.dart` - Alphabet browsing interface
- `lib/screens/practice_screen.dart` - Practice mode interface
- `lib/screens/quiz_screen.dart` - Quiz mode interface
- `lib/screens/login_screen.dart` - Authentication interface

### Data Models
- `lib/models/letter.dart` - Tigrinya letter model
- `lib/models/user.dart` - User profile model
- `lib/models/quiz_result.dart` - Quiz results model

### AWS Infrastructure
- `aws/cloudformation/infrastructure.yaml` - AWS resource definitions
- `aws/lambda/letters_handler.py` - Lambda function for letter operations