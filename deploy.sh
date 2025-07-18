#!/bin/bash

# Tigrinya Guide Deployment Script
set -e

echo "🚀 Starting Tigrinya Guide deployment..."

# Configuration
APP_NAME="tigrinya-guide"
AWS_REGION="us-east-1"
STACK_NAME="${APP_NAME}-stack"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install it first."
    exit 1
fi

# Step 1: Deploy AWS Infrastructure
print_status "Deploying AWS infrastructure..."
aws cloudformation deploy \
    --template-file aws/cloudformation/infrastructure.yaml \
    --stack-name $STACK_NAME \
    --parameter-overrides AppName=$APP_NAME \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $AWS_REGION

if [ $? -eq 0 ]; then
    print_status "AWS infrastructure deployed successfully!"
else
    print_error "Failed to deploy AWS infrastructure"
    exit 1
fi

# Step 2: Get stack outputs
print_status "Getting stack outputs..."
API_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $AWS_REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayUrl`].OutputValue' \
    --output text)

BUCKET_NAME=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $AWS_REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`WebsiteURL`].OutputValue' \
    --output text | sed 's|http://||' | sed 's|\.s3-website.*||')

CLOUDFRONT_URL=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $AWS_REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontURL`].OutputValue' \
    --output text)

print_status "API Gateway URL: $API_URL"
print_status "S3 Bucket: $BUCKET_NAME"
print_status "CloudFront URL: $CLOUDFRONT_URL"

# Step 3: Update Lambda function code
print_status "Updating Lambda function..."
cd aws/lambda
zip -r letters_handler.zip letters_handler.py
aws lambda update-function-code \
    --function-name "${APP_NAME}-letters-handler" \
    --zip-file fileb://letters_handler.zip \
    --region $AWS_REGION
rm letters_handler.zip
cd ../..

# Step 4: Build Flutter web app
print_status "Building Flutter web app..."
flutter clean
flutter pub get
flutter build web --release

if [ $? -eq 0 ]; then
    print_status "Flutter web app built successfully!"
else
    print_error "Failed to build Flutter web app"
    exit 1
fi

# Step 5: Update Flutter app configuration with API URL
print_status "Updating app configuration..."
cat > lib/config/app_config.dart << EOF
class AppConfig {
  static const String apiBaseUrl = '$API_URL';
  static const String appName = 'Tigrinya Guide';
  static const String version = '1.0.0';
}
EOF

# Rebuild with updated configuration
flutter build web --release

# Step 6: Deploy to S3
print_status "Deploying to S3..."
aws s3 sync build/web/ s3://$BUCKET_NAME --delete --region $AWS_REGION

if [ $? -eq 0 ]; then
    print_status "Web app deployed to S3 successfully!"
else
    print_error "Failed to deploy to S3"
    exit 1
fi

# Step 7: Invalidate CloudFront cache
print_status "Invalidating CloudFront cache..."
DISTRIBUTION_ID=$(aws cloudfront list-distributions \
    --query "DistributionList.Items[?Comment=='$APP_NAME'].Id" \
    --output text)

if [ ! -z "$DISTRIBUTION_ID" ]; then
    aws cloudfront create-invalidation \
        --distribution-id $DISTRIBUTION_ID \
        --paths "/*"
    print_status "CloudFront cache invalidated!"
fi

# Step 8: Initialize DynamoDB with sample data
print_status "Initializing database with sample data..."
python3 - << EOF
import boto3
import json
from datetime import datetime
import uuid

dynamodb = boto3.resource('dynamodb', region_name='$AWS_REGION')
table = dynamodb.Table('${APP_NAME}-letters')

# Sample Tigrinya letters data
sample_letters = [
    {'character': 'ሀ', 'pronunciation': 'ha', 'example': 'ሀገር', 'translation': 'country'},
    {'character': 'ለ', 'pronunciation': 'le', 'example': 'ለባስ', 'translation': 'clothes'},
    {'character': 'ሐ', 'pronunciation': 'Ha', 'example': 'ሐሳብ', 'translation': 'thought'},
    {'character': 'መ', 'pronunciation': 'me', 'example': 'መጽሓፍ', 'translation': 'book'},
    {'character': 'ሠ', 'pronunciation': 'se', 'example': 'ሠላም', 'translation': 'peace'},
]

for letter_data in sample_letters:
    letter = {
        'id': str(uuid.uuid4()),
        'character': letter_data['character'],
        'pronunciation': letter_data['pronunciation'],
        'example': letter_data['example'],
        'translation': letter_data['translation'],
        'created_at': datetime.utcnow().isoformat(),
        'updated_at': datetime.utcnow().isoformat()
    }
    
    try:
        table.put_item(Item=letter)
        print(f"Added letter: {letter_data['character']}")
    except Exception as e:
        print(f"Error adding letter {letter_data['character']}: {e}")

print("Sample data initialization completed!")
EOF

print_status "✅ Deployment completed successfully!"
print_status ""
print_status "🌐 Your Tigrinya Guide app is now live at:"
print_status "   CloudFront URL: $CLOUDFRONT_URL"
print_status "   S3 Website URL: http://$BUCKET_NAME.s3-website-$AWS_REGION.amazonaws.com"
print_status ""
print_status "🔗 API Endpoint: $API_URL"
print_status ""
print_status "📱 You can now access your app and start learning Tigrinya!"