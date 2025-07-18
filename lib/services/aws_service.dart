import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/letter.dart';

class AWSService {
  static const String _baseUrl =
      'https://your-api-gateway-url.amazonaws.com/prod';
  static const String _apiKey =
      'your-api-key'; // Store in environment variables

  static final AWSService _instance = AWSService._internal();
  static AWSService get instance => _instance;
  AWSService._internal();

  Future<List<Letter>> fetchLettersFromCloud() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/letters'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Letter.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch letters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Letter> createLetter(Letter letter) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/letters'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
        },
        body: json.encode(letter.toJson()),
      );

      if (response.statusCode == 201) {
        return Letter.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create letter: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Letter> updateLetter(Letter letter) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/letters/${letter.id}'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
        },
        body: json.encode(letter.toJson()),
      );

      if (response.statusCode == 200) {
        return Letter.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update letter: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteLetter(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/letters/$id'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete letter: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> syncWithCloud() async {
    try {
      // Fetch latest data from cloud
      final cloudLetters = await fetchLettersFromCloud();

      // Update local database
      // This is a simplified sync - in production, you'd want more sophisticated conflict resolution
      for (final letter in cloudLetters) {
        // Update or insert each letter in local database
        // Implementation depends on your sync strategy
      }
    } catch (e) {
      throw Exception('Sync failed: $e');
    }
  }
}
