import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  final Color primaryColor = const Color(0xFF4F46E5);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // EMAIL VALIDATION
  // ----------------------------------------------------------

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    if (email.contains(' ')) {
      return 'Email cannot contain spaces';
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // ----------------------------------------------------------
  // PASSWORD VALIDATION
  // ----------------------------------------------------------

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    return null;
  }

  // ----------------------------------------------------------
  // SIGN IN
  // ----------------------------------------------------------

  Future<void> signin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.session != null && response.user != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      final code = error.code?.toLowerCase() ?? '';
      final message = error.message.toLowerCase();

      // ------------------------------------------------------
      // EMAIL NOT VERIFIED
      // ------------------------------------------------------

      if (code == 'email_not_confirmed' ||
          message.contains('email not confirmed')) {
        showVerificationRequired();
      }
      // ------------------------------------------------------
      // WRONG EMAIL / PASSWORD
      // ------------------------------------------------------
      else if (code == 'invalid_credentials' ||
          message.contains('invalid login credentials')) {
        showErrorMessage('Invalid email or password.');
      }
      // ------------------------------------------------------
      // USER BANNED
      // ------------------------------------------------------
      else if (code == 'user_banned') {
        showErrorMessage('This account is currently unavailable.');
      }
      // ------------------------------------------------------
      // OTHER ERROR
      // ------------------------------------------------------
      else {
        showErrorMessage('Unable to sign in. Please try again.');
      }
    } catch (error) {
      if (!mounted) return;

      showErrorMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ----------------------------------------------------------
  // RESEND VERIFICATION EMAIL
  // ----------------------------------------------------------

  Future<void> resendVerification() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showErrorMessage('Enter your email address first.');
      return;
    }

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF16A34A),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Row(
            children: [
              Icon(Icons.mark_email_read_outlined, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verification email sent again.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      showErrorMessage(error.message);
    }
  }

  // ----------------------------------------------------------
  // EMAIL VERIFICATION REQUIRED
  // ----------------------------------------------------------

  void showVerificationRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFD97706),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: const Row(
          children: [
            Icon(Icons.mark_email_unread_outlined, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Please verify your email before signing in.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        // ----------------------------------------------------
        // RESEND BUTTON
        // ----------------------------------------------------
        action: SnackBarAction(
          label: 'RESEND',
          textColor: Colors.white,
          onPressed: resendVerification,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ERROR MESSAGE
  // ----------------------------------------------------------

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFDC2626),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // INPUT DECORATION
  // ----------------------------------------------------------

  InputDecoration inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,

      filled: true,
      fillColor: const Color(0xFFF9FAFB),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    );
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ------------------------------------------------
                    // LOGO
                    // ------------------------------------------------
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.location_city_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Sign in to continue to CivicMind.',
                      style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                    ),

                    const SizedBox(height: 32),

                    // ------------------------------------------------
                    // EMAIL
                    // ------------------------------------------------
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: validateEmail,

                      decoration: inputDecoration(
                        label: 'Email',
                        hint: 'Enter your email address',
                        icon: Icons.email_outlined,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ------------------------------------------------
                    // PASSWORD
                    // ------------------------------------------------
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: validatePassword,

                      onFieldSubmitted: (_) {
                        if (!isLoading) {
                          signin();
                        }
                      },

                      decoration: inputDecoration(
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    // ------------------------------------------------
                    // FORGOT PASSWORD
                    // ------------------------------------------------
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ------------------------------------------------
                    // SIGN IN BUTTON
                    // ------------------------------------------------
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : signin,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: primaryColor.withOpacity(
                            0.5,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ------------------------------------------------
                    // CREATE ACCOUNT
                    // ------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
