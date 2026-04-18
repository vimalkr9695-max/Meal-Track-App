import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _errorMessage;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = AuthService.validateName(_nameController.text);
      _emailError = AuthService.validateEmail(_emailController.text);
      _passwordError = AuthService.validatePassword(_passwordController.text);
      _confirmError = _passwordController.text != _confirmController.text
          ? 'Passwords do not match'
          : null;
    });
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmError == null;
  }

  Future<void> _signUp() async {
    if (!_validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final error = await AuthService.signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _loading = false;
        _errorMessage = error;
      });
      if (error == null) {
        await AuthService.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
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
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 41,
                  height: 41,
                  decoration: const BoxDecoration(
                    color: Color(0xFF222220),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('‹',
                        style: GoogleFonts.dmSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w200,
                          color: const Color(0xFF9B9890),
                        )),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text('Create Account',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF0EDE6),
                  )),
              const SizedBox(height: 6),
              Text('Start tracking your meals today',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: const Color(0xFF9B9890),
                  )),

              const SizedBox(height: 32),

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
                            )),
                      ),
                    ],
                  ),
                ),

              _buildLabel('YOUR NAME'),
              const SizedBox(height: 8),
              _buildField(
                controller: _nameController,
                hint: 'Alex Johnson',
                error: _nameError,
              ),
              if (_nameError != null) _buildFieldError(_nameError!),

              const SizedBox(height: 16),

              _buildLabel('EMAIL'),
              const SizedBox(height: 8),
              _buildField(
                controller: _emailController,
                hint: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
                error: _emailError,
              ),
              if (_emailError != null) _buildFieldError(_emailError!),

              const SizedBox(height: 16),

              _buildLabel('PASSWORD'),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _passwordController,
                hint: 'Min 8 chars, 1 uppercase, 1 number',
                obscure: _obscurePass,
                onToggle: () =>
                    setState(() => _obscurePass = !_obscurePass),
                error: _passwordError,
              ),
              if (_passwordError != null) _buildFieldError(_passwordError!),

              const SizedBox(height: 4),
              Text('• At least 8 characters  • 1 uppercase  • 1 number',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: const Color(0xFF5C5A56),
                  )),

              const SizedBox(height: 16),

              _buildLabel('CONFIRM PASSWORD'),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _confirmController,
                hint: 'Re-enter your password',
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                error: _confirmError,
              ),
              if (_confirmError != null) _buildFieldError(_confirmError!),

              const SizedBox(height: 32),

              GestureDetector(
                onTap: _loading ? null : _signUp,
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
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Color(0xFF0A0A09),
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Create Account',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A0A09),
                            )),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: const Color(0xFF9B9890)),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign In',
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
        ));
  }

  Widget _buildFieldError(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(error,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: const Color(0xFFE05252),
          )),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    String? error,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              error != null ? const Color(0xFFE05252) : const Color(0xFF2E2E2B),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style:
            GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFFF0EDE6)),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
              fontSize: 13, color: const Color(0xFF5C5A56)),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? error,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              error != null ? const Color(0xFFE05252) : const Color(0xFF2E2E2B),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: const Color(0xFFF0EDE6)),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.dmSans(
                    fontSize: 12, color: const Color(0xFF5C5A56)),
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF5C5A56),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}