import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  AuthService._internal();

  // Simple mock authentication for demo purposes
  Future<bool> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    await _saveUserData('Google User', 'google@example.com');
    return true;
  }

  Future<bool> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 2));
    await _saveUserData('Apple User', 'apple@example.com');
    return true;
  }

  Future<bool> signInWithFacebook() async {
    await Future.delayed(const Duration(seconds: 2));
    await _saveUserData('Facebook User', 'facebook@example.com');
    return true;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    // Admin credentials
    if (email.toLowerCase() == 'admin' && password == '123') {
      await _saveUserData('Admin User', 'admin@tigrinyaguide.com');
      return true;
    }

    // Regular email validation
    if (email.isNotEmpty && password.length >= 6) {
      await _saveUserData('Email User', email);
      return true;
    }
    return false;
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email.isNotEmpty && password.length >= 6) {
      await _saveUserData('New User', email);
      return true;
    }
    return false;
  }

  Future<void> signInWithPhone(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 2));
    // Mock phone verification
  }

  Future<bool> verifyOTP(String verificationId, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp == '123456') {
      // Mock OTP
      await _saveUserData('Phone User', 'phone@example.com');
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    await _clearUserData();
  }

  Future<void> _saveUserData(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setBool('is_logged_in', true);
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_name': prefs.getString('user_name') ?? '',
      'user_email': prefs.getString('user_email') ?? '',
    };
  }
}
