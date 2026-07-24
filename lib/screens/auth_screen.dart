// ============================================================
// 📁 FILE: auth_screen.dart
// 📍 LOCATION: lib/screens/auth_screen.dart
// 🎯 PURPOSE: Authentication Screen - Login & Register
// 🔗 USED BY: splash_screen.dart (When user not logged in)
// 📝 DESCRIPTION:
//    This file handles user authentication with:
//    - Google Sign In
//    - Email/Password Login
//    - Email/Password Registration
//    - Password Reset
//    - Form Validation
//    - Error Handling with Toast Messages
//    - Loading States
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// ============================================================
// 📁 IMPORT PROVIDERS, WIDGETS & UTILS
// ============================================================
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../utils/theme.dart';
import '../widgets/loading_indicator.dart';
import 'home_screen.dart';

// ============================================================
// 🎯 AUTH SCREEN - Stateful Widget
// ============================================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // ============================================================
  // 📊 CONTROLLERS & STATE VARIABLES
  // ============================================================

  // Text Editing Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Form Keys
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  // State Variables
  bool _isLoading = false;
  bool _isLoginMode = true; // true = Login, false = Register
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  // ============================================================
  // 🧹 DISPOSE - Clean up controllers
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // 🔄 TOGGLE BETWEEN LOGIN & REGISTER
  // ============================================================

  void _toggleAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
      // Clear errors when switching modes
      _loginFormKey.currentState?.reset();
      _registerFormKey.currentState?.reset();
    });
  }

  // ============================================================
  // 🔐 LOGIN WITH EMAIL & PASSWORD
  // ============================================================

  Future<void> _loginWithEmail() async {
    // ✅ Validate form
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 🎯 Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 🔐 Sign in with email and password
      final user = await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // ✅ Login successful - Navigate to Home
        _navigateToHome();
      } else {
        // ❌ Login failed
        setState(() {
          _errorMessage = 'Invalid email or password. Please try again.';
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      // ❌ Firebase Auth Error
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e);
        _isLoading = false;
      });
    } catch (e) {
      // ❌ General Error
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
      print('❌ Login Error: $e');
    }
  }

  // ============================================================
  // 📝 REGISTER WITH EMAIL & PASSWORD
  // ============================================================

  Future<void> _registerWithEmail() async {
    // ✅ Validate form
    if (!_registerFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 🎯 Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 📝 Register with email and password
      final user = await authProvider.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (user != null) {
        // ✅ Registration successful - Navigate to Home
        _navigateToHome();
      } else {
        // ❌ Registration failed
        setState(() {
          _errorMessage = 'Registration failed. Please try again.';
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      // ❌ Firebase Auth Error
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e);
        _isLoading = false;
      });
    } catch (e) {
      // ❌ General Error
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
      print('❌ Registration Error: $e');
    }
  }

  // ============================================================
  // 🔑 SIGN IN WITH GOOGLE
  // ============================================================

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 🎯 Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 🔑 Sign in with Google
      final user = await authProvider.signInWithGoogle();

      if (user != null) {
        // ✅ Google Sign In successful - Navigate to Home
        _navigateToHome();
      } else {
        // ❌ Google Sign In failed
        setState(() {
          _errorMessage = 'Google Sign In failed. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      // ❌ Error
      setState(() {
        _errorMessage = 'Google Sign In failed. Please try again.';
        _isLoading = false;
      });
      print('❌ Google Sign In Error: $e');
    }
  }

  // ============================================================
  // 🔄 PASSWORD RESET
  // ============================================================

  Future<void> _resetPassword() async {
    // ✅ Validate email
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Validate email format
    if (!Validators.isValidEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 🎯 Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 🔄 Send password reset email
      await authProvider.resetPassword(_emailController.text.trim());

      // ✅ Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent! Check your inbox.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // ❌ Error
      setState(() {
        _errorMessage = 'Failed to send reset email. Please try again.';
        _isLoading = false;
      });
      print('❌ Password Reset Error: $e');
    }
  }

  // ============================================================
  // 🧭 NAVIGATE TO HOME
  // ============================================================

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ============================================================
  // 📝 GET FIREBASE ERROR MESSAGE
  // ============================================================

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // ============================================================
  // 🎨 BUILD METHOD - UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // 🎨 Get theme
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      // 🖼️ Status Bar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      // 📦 Body
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.secondary,
                    AppColors.secondary.withOpacity(0.8),
                    AppColors.primary,
                  ]
                : [
                    AppColors.primary.withOpacity(0.9),
                    AppColors.primary.withOpacity(0.6),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================================
                // 🏷️ HEADER SECTION
                // ============================================================
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      // 🖼️ App Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            AppAssets.logo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.shopping_bag,
                                size: 40,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 📱 App Name
                      Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 📝 Tagline
                      Text(
                        _isLoginMode
                            ? 'Welcome Back! 👋'
                            : 'Create Your Account 🚀',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // ============================================================
                // ❌ ERROR MESSAGE
                // ============================================================
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ============================================================
                // 📝 LOGIN / REGISTER FORM
                // ============================================================
                _isLoginMode ? _buildLoginForm() : _buildRegisterForm(),

                const SizedBox(height: 20),

                // ============================================================
                // 🔄 TOGGLE AUTH MODE
                // ============================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLoginMode
                          ? "Don't have an account? "
                          : 'Already have an account? ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontFamily: 'Inter',
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleAuthMode,
                      child: Text(
                        _isLoginMode ? 'Sign Up' : 'Sign In',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ============================================================
                // 🔑 DIVIDER WITH "OR"
                // ============================================================
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white.withOpacity(0.3),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white.withOpacity(0.3),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ============================================================
                // 🔑 GOOGLE SIGN IN BUTTON
                // ============================================================
                _buildGoogleSignInButton(),
                const SizedBox(height: 20),

                // ============================================================
                // ⚡ POWERED BY (Footer)
                // ============================================================
                _buildPoweredBy(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 BUILD LOGIN FORM
  // ============================================================

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          // 📧 Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.email, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!Validators.isValidEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 🔒 Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.lock, color: Colors.white),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // 🔄 Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resetPassword,
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Inter',
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🔐 Login Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _loginWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎨 BUILD REGISTER FORM
  // ============================================================

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          // 👤 Name Field
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.person, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 📧 Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.email, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!Validators.isValidEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 🔒 Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.lock, color: Colors.white),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 🔒 Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // 📝 Register Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔑 BUILD GOOGLE SIGN IN BUTTON
  // ============================================================

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🅶 Google Icon
            Image.asset(
              'assets/icons/google_logo.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.g_mobiledata,
                  color: Colors.white,
                  size: 24,
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              _isLoading ? 'Signing in...' : 'Continue with Google',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ⚡ BUILD POWERED BY FOOTER
  // ============================================================

  Widget _buildPoweredBy() {
    return Column(
      children: [
        Divider(
          color: Colors.white.withOpacity(0.2),
          thickness: 1,
          indent: 60,
          endIndent: 60,
        ),
        const SizedBox(height: 12),
        Text(
          '⚡ Powered By',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.5),
            fontFamily: 'Inter',
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          AppConstants.poweredBy,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Poppins',
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version ${AppConstants.appVersion}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.3),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 🧪 UNIT TESTING
// ============================================================

/*
 🧪 UNIT TEST FOR auth_screen.dart

 import 'package:flutter_test/flutter_test.dart';
 import 'package:provider/provider.dart';

 void main() {
   testWidgets('Auth screen shows login form by default', 
       (WidgetTester tester) async {
     await tester.pumpWidget(
       MaterialApp(
         home: ChangeNotifierProvider(
           create: (_) => AuthProvider(),
           child: const AuthScreen(),
         ),
       ),
     );

     // Verify login form is displayed
     expect(find.text('Sign In'), findsOneWidget);
     expect(find.text('Create Account'), findsNothing);
   });

   testWidgets('Auth screen switches to register mode', 
       (WidgetTester tester) async {
     await tester.pumpWidget(
       MaterialApp(
         home: ChangeNotifierProvider(
           create: (_) => AuthProvider(),
           child: const AuthScreen(),
         ),
       ),
     );

     // Tap "Sign Up" text
     await tester.tap(find.text('Sign Up'));
     await tester.pump();

     // Verify register form is displayed
     expect(find.text('Create Account'), findsOneWidget);
     expect(find.text('Sign In'), findsNothing);
   });
 }
*/