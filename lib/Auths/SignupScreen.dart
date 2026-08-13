import 'package:bookverse/ViewModels/UserProvider.dart';
import 'package:bookverse/Views/BooknaScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Widgets/Signupwidget.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState
    extends State<CreateAccountScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ============================================================
  // LOCAL UI STATE
  // ============================================================

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;

  bool _acceptedTerms = false;

  bool _googleLoading = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool error = true,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message.replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor:
              error ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();

    final String name =
        _nameController.text.trim();

    final String email =
        _emailController.text.trim();

    final String password =
        _passwordController.text;

    final String confirmPassword =
        _confirmPasswordController.text;

    // ==========================================================
    // NAME
    // ==========================================================

    if (name.isEmpty) {
      _showMessage(
        'Please enter your name.',
      );
      return;
    }

    if (name.length < 2) {
      _showMessage(
        'Please enter a valid name.',
      );
      return;
    }

    // ==========================================================
    // EMAIL
    // ==========================================================

    if (email.isEmpty) {
      _showMessage(
        'Please enter your email.',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage(
        'Please enter a valid email address.',
      );
      return;
    }

    // ==========================================================
    // PASSWORD
    // ==========================================================

    if (password.isEmpty) {
      _showMessage(
        'Please enter a password.',
      );
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Password must be at least 6 characters.',
      );
      return;
    }

    // ==========================================================
    // CONFIRM PASSWORD
    // ==========================================================

    if (confirmPassword.isEmpty) {
      _showMessage(
        'Please confirm your password.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Passwords do not match.',
      );
      return;
    }

    // ==========================================================
    // TERMS
    // ==========================================================

    if (!_acceptedTerms) {
      _showMessage(
        'Please accept the Terms of Service and Privacy Policy.',
      );
      return;
    }

    // ==========================================================
    // PROVIDER
    // ==========================================================

    final UserProvider provider =
        context.read<UserProvider>();

    final bool success =
        await provider.signUp(
      name: name,
      email: email,
      password: password,
    );

    if (!mounted) return;

    // ==========================================================
    // ERROR
    // ==========================================================

    if (!success) {
      _showMessage(
        provider.errorMessage ??
            'Unable to create account.',
      );
      return;
    }

    // ==========================================================
    // SUCCESS
    // ==========================================================

    _showMessage(
      'Account created successfully!',
      error: false,
    );

    // ==========================================================
    // NAVIGATION
    // ==========================================================
    
    // Yahan apni next screen add karni hai.
    
    // Example:
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const BookNavScreen(),
      ),
    );
    
  }

  // ============================================================
  // GOOGLE SIGN UP
  // ============================================================

  Future<void> _signUpWithGoogle() async {
    FocusScope.of(context).unfocus();

    // ==========================================================
    // TERMS
    // ==========================================================

    if (!_acceptedTerms) {
      _showMessage(
        'Please accept the Terms of Service and Privacy Policy.',
      );
      return;
    }

    if (_googleLoading) {
      return;
    }

    setState(() {
      _googleLoading = true;
    });

    try {
      final UserProvider provider =
          context.read<UserProvider>();

      final bool success =
          await provider.signInWithGoogle();

      if (!mounted) return;

      if (!success) {
        _showMessage(
          provider.errorMessage ??
              'Google Sign-In failed.',
        );
        return;
      }

      _showMessage(
        'Google account connected successfully!',
        error: false,
      );

      // ========================================================
      // NAVIGATION
      // ========================================================
      //
      // Example:
      //
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BookNavScreen(),
        ),
      );
      
      // ========================================================
    } finally {
      if (mounted) {
        setState(() {
          _googleLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (
        context,
        userProvider,
        child,
      ) {
        return Scaffold(
          backgroundColor:
              const Color(0xFFF8F8FC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // BACK BUTTON
                  // ==================================================

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Create your account and start reading.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // NAME
                  // ==================================================

                  CreateAccountField(
                    controller: _nameController,
                    hint: 'Full Name',
                    icon:
                        Icons.person_outline_rounded,
                    keyboardType:
                        TextInputType.name,
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // EMAIL
                  // ==================================================

                  CreateAccountField(
                    controller: _emailController,
                    hint: 'Email Address',
                    icon:
                        Icons.email_outlined,
                    keyboardType:
                        TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  CreateAccountField(
                    controller: _passwordController,
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
                        color:
                            Colors.grey.shade500,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // CONFIRM PASSWORD
                  // ==================================================

                  CreateAccountField(
                    controller:
                        _confirmPasswordController,
                    hint: 'Confirm Password',
                    icon:
                        Icons.lock_outline_rounded,
                    obscureText:
                        _obscureConfirmPassword,
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons
                                .visibility_off_outlined
                            : Icons
                                .visibility_outlined,
                        color:
                            Colors.grey.shade500,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // TERMS
                  // ==================================================

                  CreateAccountTerms(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms =
                            value ?? false;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // CREATE ACCOUNT
                  // ==================================================

                  CreateAccountButton(
                    onPressed:
                        userProvider.isLoading
                            ? null
                            : _createAccount,
                    isLoading:
                        userProvider.isLoading,
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // DIVIDER
                  // ==================================================

                  const CreateAccountDivider(),

                  const SizedBox(height: 22),

                  // ==================================================
                  // GOOGLE
                  // ==================================================

                  Center(
                    child:
                        CreateAccountSocialButton(
                      onTap:
                          _googleLoading
                              ? null
                              : _signUpWithGoogle,
                      child: _googleLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // SIGN IN
                  // ==================================================

                  Center(
                    child:
                        CreateAccountSignInLink(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}