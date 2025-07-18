import json
import boto3
from boto3.dynamodb.conditions import Key
import uuid
from datetime import datetime

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('tigrinya-letters')

def lambda_handler(event, context):
    """
    AWS Lambda handler for Tigrinya letters CRUD operations
    """
    
    http_method = event['httpMethod']
    path = event['path']
    
    try:
        if http_method == 'GET':
            if path == '/letters':
                return get_all_letters()
            elif '/letters/' in path:
                letter_id = path.split('/')[-1]
                return get_letter(letter_id)
        
        elif http_method == 'POST' and path == '/letters':
            body = json.loads(event['body'])
            return create_letter(body)
        
        elif http_method == 'PUT' and '/letters/' in path:
            letter_id = path.split('/')[-1]
            body = json.loads(event['body'])
            return update_letter(letter_id, body)
        
        elif http_method == 'DELETE' and '/letters/' in path:
            letter_id = path.split('/')[-1]
            return delete_letter(letter_id)
        
        else:
            return {
                'statusCode': 404,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'error': 'Not found'})
            }
    
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': str(e)})
        }

def get_all_letters():
    """Get all letters from DynamoDB"""
    response = table.scan()
    letters = response['Items']
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(letters)
    }

def get_letter(letter_id):
    """Get a specific letter by ID"""
    response = table.get_item(Key={'id': letter_id})
    
    if 'Item' in response:
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response['Item'])
        }
    else:
        return {
            'statusCode': 404,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': 'Letter not found'})
        }

def create_letter(letter_data):
    """Create a new letter"""
    letter_id = str(uuid.uuid4())
    timestamp = datetime.utcnow().isoformat()
    
    letter = {
        'id': letter_id,
        'character': letter_data['character'],
        'pronunciation': letter_data['pronunciation'],
        'example': letter_data['example'],
        'translation': letter_data['translation'],
        'audio_url': letter_data.get('audio_url'),
        'created_at': timestamp,
        'updated_at': timestamp
    }
    
    table.put_item(Item=letter)
    
    return {
        'statusCode': 201,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(letter)
    }

def update_letter(letter_id, letter_data):
    """Update an existing letter"""
    timestamp = datetime.utcnow().isoformat()
    
    # Check if letter exists
    response = table.get_item(Key={'id': letter_id})
    if 'Item' not in response:
        return {
            'statusCode': 404,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': 'Letter not found'})
        }
    
    # Update the letter
    updated_letter = response['Item']
    updated_letter.update({
        'character': letter_data.get('character', updated_letter['character']),
        'pronunciation': letter_data.get('pronunciation', updated_letter['pronunciation']),
        'example': letter_data.get('example', updated_letter['example']),
        'translation': letter_data.get('translation', updated_letter['translation']),
        'audio_url': letter_data.get('audio_url', updated_letter.get('audio_url')),
        'updated_at': timestamp
    })
    
    table.put_item(Item=updated_letter)
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(updated_letter)
    }

def delete_letter(letter_id):
    """Delete a letter"""
    # Check if letter exists
    response = table.get_item(Key={'id': letter_id})
    if 'Item' not in response:
        return {
            'statusCode': 404,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': 'Letter not found'})
        }
    
    # Delete the letter
    table.delete_item(Key={'id': letter_id})
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({'message': 'Letter deleted successfully'})
    }