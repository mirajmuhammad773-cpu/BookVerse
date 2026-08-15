import 'package:bookverse/Auths/SignupScreen.dart';
import 'package:bookverse/ViewModels/UserProvider.dart';
import 'package:bookverse/Views/BooknaScreen.dart';
import 'package:bookverse/Widgets/SigninWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class BookVerseSignInScreen extends StatefulWidget {
  const BookVerseSignInScreen({
    super.key,
  });

  @override
  State<BookVerseSignInScreen> createState() =>
      _BookVerseSignInScreenState();
}

class _BookVerseSignInScreenState
    extends State<BookVerseSignInScreen> {

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider =
        context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [

              const SizedBox(height: 30),

              const Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Sign in to continue your\n'
                'reading journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // EMAIL
              // =================================================

              SigninInputField(
                controller:
                    _emailController,
                hint: 'Email Address',
                icon:
                    Icons.mail_outline_rounded,
                keyboardType:
                    TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              // =================================================
              // PASSWORD
              // =================================================

              SigninInputField(
                controller:
                    _passwordController,
                hint: 'Password',
                icon:
                    Icons.lock_outline_rounded,
                obscureText:
                    _obscurePassword,

                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword;
                    });
                  },

                  icon: Icon(
                    _obscurePassword
                        ? Icons
                            .visibility_off_outlined
                        : Icons
                            .visibility_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // SIGN IN
              // =================================================

              SigninButton(
                isLoading:
                    userProvider.isLoading,

                onTap: _signIn,
              ),

              // =================================================
              // ERROR
              // =================================================

              if (userProvider.errorMessage !=
                  null) ...[
                const SizedBox(height: 14),

                Text(
                  userProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12.5,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              const SigninSecureCard(),

              const SizedBox(height: 24),

              // =================================================
              // GOOGLE
              // =================================================

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color:
                          Colors.grey.shade300,
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),

                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        color:
                            Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Divider(
                      color:
                          Colors.grey.shade300,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  SigninSocialButton(
                    onTap:
                        _signInWithGoogle,

                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF4285F4),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  const SigninSocialButton(
                    child: Icon(
                      Icons.apple,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  const SigninSocialButton(
                    child: Icon(
                      Icons.facebook_rounded,
                      color:
                          Color(0xFF1877F2),
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // =================================================
              // CREATE ACCOUNT
              // =================================================

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const CreateAccountScreen(),
                      ),
                    );
                  },

                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey.shade700,
                      ),

                      children: const [
                        TextSpan(
                          text:
                              "Don't have an account? ",
                        ),

                        TextSpan(
                          text: 'Create Account',
                          style: TextStyle(
                            color:
                                Color(0xFF8B5CF6),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMAIL SIGN IN
  // ============================================================

  Future<void> _signIn() async {
    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    if (email.isEmpty) {
      _showMessage(
        'Please enter your email.',
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage(
        'Please enter your password.',
      );
      return;
    }

    final provider =
        context.read<UserProvider>();

    final success =
        await provider.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      _showMessage(
        'Sign in successful!',
      );

      // ========================================================
      // YAHAN APNI HOME SCREEN PAR LE JAYEIN
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BookNavScreen(),
        ),
      );
    }
  }

  // ============================================================
  // GOOGLE SIGN IN
  // ============================================================

  Future<void> _signInWithGoogle() async {
    final provider =
        context.read<UserProvider>();

    final success =
        await provider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      _showMessage(
        'Google sign in successful!',
      );

      // ========================================================
      // YAHAN HOME SCREEN
      // ========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BookNavScreen(),
        ),
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}