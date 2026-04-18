import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../storage.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isSignIn = true;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isSignIn && _nameController.text.trim().isNotEmpty) {
      await Storage.saveUserName(_nameController.text.trim());
    }
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
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

              // Logo / Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A853).withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFD4A853).withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.restaurant_outlined,
                          color: Color(0xFFD4A853), size: 30),
                    ),
                    const SizedBox(height: 16),
                    Text('Meal Tracker',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF0EDE6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Track every meal. Every rupee.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF9B9890),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Tab Switch
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E2E2B)),
                ),
                child: Row(
                  children: [
                    _tabBtn('Sign In', _isSignIn, () => setState(() => _isSignIn = true)),
                    _tabBtn('Sign Up', !_isSignIn, () => setState(() => _isSignIn = false)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Name field (Sign Up only)
              if (!_isSignIn) ...[
                _buildLabel('YOUR NAME'),
                const SizedBox(height: 8),
                _buildField(_nameController, 'e.g. Alex Johnson', false),
                const SizedBox(height: 16),
              ],

              // Email
              _buildLabel('EMAIL'),
              const SizedBox(height: 8),
              _buildField(_emailController, 'your@email.com', false),

              const SizedBox(height: 16),

              // Password
              _buildLabel('PASSWORD'),
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2E2E2B)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: const Color(0xFFF0EDE6),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '••••••••',
                          hintStyle: GoogleFonts.dmSans(
                            color: const Color(0xFF5C5A56),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF5C5A56), size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A853),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E2E2B)),
                  ),
                  child: Center(
                    child: Text(_isSignIn ? 'Sign In' : 'Create Account',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0A09),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Toggle link
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _isSignIn = !_isSignIn),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: const Color(0xFF9B9890)),
                      children: [
                        TextSpan(
                            text: _isSignIn
                                ? "Don't have an account? "
                                : 'Already have an account? '),
                        TextSpan(
                          text: _isSignIn ? 'Sign Up' : 'Sign In',
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

  Widget _tabBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFD4A853) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active
                    ? const Color(0xFF0A0A09)
                    : const Color(0xFF9B9890),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
      style: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF9B9890),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller, String hint, bool obscure) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2E2E2B)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          color: const Color(0xFFF0EDE6),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
            fontSize: 12,
            color: const Color(0xFF5C5A56),
          ),
        ),
      ),
    );
  }
}