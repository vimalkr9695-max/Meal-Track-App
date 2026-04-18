import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    // Validate
    final emailError = AuthService.validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() => _errorMessage = emailError);
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Password is required');
      return;
    }

    setState(() { _loading = true; _errorMessage = null; });

    final error = await AuthService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() { _loading = false; _errorMessage = error; });
    }
    // If error is null = success → StreamBuilder in main.dart
    // auto navigates to HomePage
  }

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _errorMessage = null; });
    final error = await AuthService.signInWithGoogle();
    if (mounted) {
      setState(() { _loading = false; _errorMessage = error; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A853).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFD4A853).withOpacity(0.4),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.restaurant_outlined,
                          color: Color(0xFFD4A853), size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text('Welcome Back',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF0EDE6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Sign in to your Meal Tracker',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF9B9890),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Error message
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE05252).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFE05252).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFE05252), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: const Color(0xFFE05252),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Email
              _buildLabel('EMAIL'),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _emailController,
                hint: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // Password
              _buildLabel('PASSWORD'),
              const SizedBox(height: 8),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E2E2B)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: const Color(0xFFF0EDE6),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '••••••••',
                          hintStyle: GoogleFonts.dmSans(
                              color: const Color(0xFF5C5A56)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF5C5A56), size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () async {
                    final email = _emailController.text.trim();
                    if (email.isEmpty) {
                      setState(() => _errorMessage = 'Enter your email first');
                      return;
                    }
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Password reset email sent!',
                              style: GoogleFonts.dmSans(
                                  color: const Color(0xFFF0EDE6))),
                          backgroundColor: const Color(0xFF1A1A18),
                        ),
                      );
                    }
                  },
                  child: Text('Forgot Password?',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFFD4A853),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sign In Button
              GestureDetector(
                onTap: _loading ? null : _signIn,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _loading
                        ? const Color(0xFFD4A853).withOpacity(0.5)
                        : const Color(0xFFD4A853),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                              color: Color(0xFF0A0A09),
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Sign In',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A0A09),
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  const Expanded(
                      child: Divider(color: Color(0xFF2E2E2B))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: const Color(0xFF5C5A56)),
                    ),
                  ),
                  const Expanded(
                      child: Divider(color: Color(0xFF2E2E2B))),
                ],
              ),

              const SizedBox(height: 16),

              // Google Sign In
              GestureDetector(
                onTap: _loading ? null : _googleSignIn,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E2E2B)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Center(
                          child: Text('G',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4285F4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Continue with Google',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF0EDE6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Sign up link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SignupPage())),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: const Color(0xFF9B9890)),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFFD4A853),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF9B9890),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2E2B)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          color: const Color(0xFFF0EDE6),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
            fontSize: 13,
            color: const Color(0xFF5C5A56),
          ),
        ),
      ),
    );
  }
}