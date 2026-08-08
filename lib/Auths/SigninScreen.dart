// ignore_for_file: deprecated_member_use, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:bookverse/Auths/SignupScreen.dart';
import 'package:bookverse/Views/BooknaScreen.dart';
import 'package:flutter/material.dart';

class BookVerseSignInScreen extends StatefulWidget {
  const BookVerseSignInScreen({super.key});

  @override
  State<BookVerseSignInScreen> createState() => _BookVerseSignInScreenState();
}

class _BookVerseSignInScreenState extends State<BookVerseSignInScreen> {
  static const _primary = Color(0xFF6366F1);
  static const _secondary = Color(0xFF8B5CF6);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
       
        children: [
          // Layer 1 (bottom-most): background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
             
            ),
          ),

          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                 

                  // Logo + wordmark
                  Row(
                    
                    children: [
                      SizedBox(width: 50),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_primary, _secondary]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(text: 'Book', style: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)),
                                TextSpan(text: 'Verse', style: TextStyle(color: _secondary, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to continue your reading journey',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  // Email Address
                  _inputField(
                    controller: _emailController,
                    hint: 'Email Address',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  // Password
                  _inputField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    trailing: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 19,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: const Text('Forgot Password?', style: TextStyle(color: _secondary, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Sign In button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_primary, _secondary]),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const BookNavScreen()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15.5)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('or sign in with', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton(child: const Text('G', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF4285F4)))),
                      const SizedBox(width: 16),
                      _socialButton(child: const Icon(Icons.apple, color: Colors.black, size: 24)),
                      const SizedBox(width: 16),
                      _socialButton(child: const Icon(Icons.facebook_rounded, color: Color(0xFF1877F2), size: 24)),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Secure & Private info card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _secondary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _secondary.withOpacity(0.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: _secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.shield_rounded, color: _secondary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Secure & Private', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.black87)),
                              SizedBox(height: 3),
                              Text(
                                'Your data is safe with us. We never share your information.',
                                style: TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                 

                  Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAccountScreen()));
                      },
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(text: 'Sign Up', style: const TextStyle(color: _secondary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                ],
              ),
              
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? trailing,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E1F5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13.5),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _socialButton({required Widget child}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Center(child: child),
    );
  }
}

