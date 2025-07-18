import 'package:flutter_tts/flutter_tts.dart';
import '../utils/logger.dart';

/// Service for handling text-to-speech functionality
class PronunciationService {
  static final PronunciationService _instance =
      PronunciationService._internal();
  static PronunciationService get instance => _instance;
  PronunciationService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final Logger _logger = Logger('PronunciationService');
  bool _isInitialized = false;

  /// Initialize the TTS service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure TTS
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Slower for learning
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Check available languages
      List<dynamic> languages = await _flutterTts.getLanguages;
      _logger.info("Available TTS languages: $languages");

      _isInitialized = true;
    } catch (e) {
      _logger.error("Error initializing TTS", e);
    }
  }

  /// Speak the pronunciation of a character or word
  Future<void> speakPronunciation(String pronunciation) async {
    try {
      await initialize();

      // Stop any current speech
      await _flutterTts.stop();

      // Speak the pronunciation
      await _flutterTts.speak(pronunciation);
    } catch (e) {
      _logger.error("Error speaking pronunciation", e);
    }
  }

  /// Speak a character with its pronunciation
  Future<void> speakCharacter(String character, String pronunciation) async {
    try {
      await initialize();

      // Stop any current speech
      await _flutterTts.stop();

      // Speak both character description and pronunciation
      String textToSpeak =
          "The character $character is pronounced as $pronunciation";
      await _flutterTts.speak(textToSpeak);
    } catch (e) {
      _logger.error("Error speaking character", e);
    }
  }

  /// Speak an example word with its translation
  Future<void> speakExample(String example, String translation) async {
    try {
      await initialize();

      // Stop any current speech
      await _flutterTts.stop();

      // Speak the example and its translation
      String textToSpeak = "Example word: $example, which means $translation";
      await _flutterTts.speak(textToSpeak);
    } catch (e) {
      _logger.error("Error speaking example", e);
    }
  }

  /// Stop any ongoing speech
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      _logger.error("Error stopping speech", e);
    }
  }

  /// Clean up resources
  void dispose() {
    _flutterTts.stop();
  }
}
