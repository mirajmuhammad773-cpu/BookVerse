// lib/Screens/CreateAccountScreen.dart
import 'package:bookverse/Auths/SigninScreen.dart';
import 'package:flutter/material.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  static const purple = Color(0xFF8B5CF6);
  static const indigo = Color(0xFF6366F1);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              

              const Text('Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 6),
              Text('Join BookVerse and start your reading\njourney today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
              const SizedBox(height: 26),

              _field(controller: _nameController, hint: 'Full Name', icon: Icons.person_outline_rounded),
              const SizedBox(height: 14),
              _field(controller: _emailController, hint: 'Email Address', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _field(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                trailing: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _confirmPasswordController,
                hint: 'Confirm Password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirmPassword,
                trailing: IconButton(
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
                ),
              ),
              const SizedBox(height: 18),

              // ---------------- Terms checkbox ----------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                      activeColor: purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.4),
                          children: const [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(text: 'Terms of Service', style: TextStyle(color: purple, fontWeight: FontWeight.w600)),
                            TextSpan(text: ' and '),
                            TextSpan(text: 'Privacy Policy', style: TextStyle(color: purple, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---------------- Create Account button ----------------
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [purple, indigo]),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: purple.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BookVerseSignInScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ---------------- Divider ----------------
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('or sign up with', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 18),

              // ---------------- Social buttons ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(child: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4285F4)))),
                  const SizedBox(width: 16),
                  _socialButton(background: Colors.black, child: const Icon(Icons.apple, color: Colors.white, size: 24)),
                  const SizedBox(width: 16),
                  _socialButton(background: const Color(0xFF1877F2), child: const Icon(Icons.facebook_rounded, color: Colors.white, size: 24)),
                ],
              ),
              const SizedBox(height: 22),

              // ---------------- Sign in link ----------------
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    children: const [
                      TextSpan(text: 'Already have an account? '),
                      TextSpan(text: 'Sign In', style: TextStyle(color: purple, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Widget? trailing,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _socialButton({required Widget child, Color background = Colors.white}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Center(child: child),
    );
  }
}