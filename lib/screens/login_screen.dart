import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;
import '../services/auth_service_simple.dart';
import '../widgets/social_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _formController;
  late Animation<double> _backgroundAnimation;
  late Animation<Offset> _slideAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _showEmailForm = false;
  bool _showPhoneForm = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutBack,
    ));

    _formController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),

                    // Login Form
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildLoginForm(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
                AppColors.background,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Floating circles
              ...List.generate(6, (index) {
                final offset = _backgroundAnimation.value * 2 * 3.14159;
                final x = 100 + (index * 60) + 50 * math.sin(offset + index);
                final y =
                    100 + (index * 80) + 30 * math.cos(offset + index * 0.5);

                return Positioned(
                  left: x,
                  top: y,
                  child: Container(
                    width: 20 + (index * 5),
                    height: 20 + (index * 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1 - (index * 0.01)),
                    ),
                  ),
                );
              }),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF0F0F0)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'ብ',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 200),
            child: const Text(
              'Tigrinya Guide',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Learn the beautiful Tigrinya alphabet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: Text(
                _isLogin ? 'Welcome Back!' : 'Create Account',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 300),
              child: Text(
                _isLogin
                    ? 'Sign in to continue your learning journey'
                    : 'Join thousands learning Tigrinya',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Form content
            if (!_showEmailForm && !_showPhoneForm) ...[
              _buildSocialButtons(),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildLoginOptions(),
              const SizedBox(height: 16),
            ],

            // Email Form
            if (_showEmailForm) _buildEmailForm(),

            // Phone Form
            if (_showPhoneForm) _buildPhoneForm(),

            // Toggle Login/Register
            if (!_showEmailForm && !_showPhoneForm) _buildToggleButton(),

            // Add some bottom padding to avoid overflow
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[600])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Google Sign In
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 400),
          child: SocialButton(
            text: 'Continue with Google',
            icon: Icons.g_mobiledata_rounded,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            isLoading: _isLoading,
            onPressed: _handleGoogleSignIn,
          ),
        ),

        const SizedBox(height: 12),

        // Apple Sign In
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 500),
          child: SocialButton(
            text: 'Continue with Apple',
            icon: Icons.apple_rounded,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            isLoading: _isLoading,
            onPressed: _handleAppleSignIn,
          ),
        ),

        const SizedBox(height: 12),

        // Facebook Sign In
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 600),
          child: SocialButton(
            text: 'Continue with Facebook',
            icon: Icons.facebook_rounded,
            backgroundColor: const Color(0xFF1877F2),
            textColor: Colors.white,
            isLoading: _isLoading,
            onPressed: _handleFacebookSignIn,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginOptions() {
    return Column(
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 700),
          child: _buildOptionButton(
            'Continue with Email',
            Icons.email_rounded,
            () {
              setState(() => _showEmailForm = true);
              HapticFeedback.lightImpact();
            },
          ),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 800),
          child: _buildOptionButton(
            'Continue with Phone',
            Icons.phone_rounded,
            () {
              setState(() => _showPhoneForm = true);
              HapticFeedback.lightImpact();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(
      String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showEmailForm = false),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              const Text(
                'Email Login',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Email field
          CustomTextField(
            controller: _emailController,
            hint: 'Enter your email',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // Password field
          CustomTextField(
            controller: _passwordController,
            hint: 'Enter your password',
            icon: Icons.lock_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _isLogin ? 'Sign In' : 'Create Account',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showPhoneForm = false),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              const Text(
                'Phone Login',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Phone field
          CustomTextField(
            controller: _phoneController,
            hint: 'Enter your phone number',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePhoneSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Send OTP',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 900),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isLogin ? "Don't have an account? " : "Already have an account? ",
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _isLogin = !_isLogin);
              HapticFeedback.lightImpact();
            },
            child: Text(
              _isLogin ? 'Sign Up' : 'Sign In',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Authentication handlers
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await AuthService.instance.signInWithGoogle();
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Google sign in failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await AuthService.instance.signInWithApple();
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Apple sign in failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await AuthService.instance.signInWithFacebook();
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Facebook sign in failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = _isLogin
          ? await AuthService.instance.signInWithEmail(
              _emailController.text,
              _passwordController.text,
            )
          : await AuthService.instance.signUpWithEmail(
              _emailController.text,
              _passwordController.text,
            );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showErrorSnackBar(_isLogin ? 'Sign in failed' : 'Sign up failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePhoneSignIn() async {
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar('Please enter your phone number');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.signInWithPhone(_phoneController.text);
      // Handle OTP verification flow
    } catch (e) {
      _showErrorSnackBar('Phone verification failed');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
