import 'package:flutter/foundation.dart';
import '../models/letter.dart';
import '../services/database_service.dart';

class AppState extends ChangeNotifier {
  List<Letter> _letters = [];
  bool _isLoading = false;
  String? _error;

  List<Letter> get letters => _letters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLetters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _letters = await DatabaseService.instance.getLetters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLetter(Letter letter) async {
    try {
      await DatabaseService.instance.insertLetter(letter);
      await loadLetters();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateLetter(Letter letter) async {
    try {
      await DatabaseService.instance.updateLetter(letter);
      await loadLetters();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteLetter(int id) async {
    try {
      await DatabaseService.instance.deleteLetter(id);
      await loadLetters();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
