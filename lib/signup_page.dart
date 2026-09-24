import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // --------------------------------------------------
  // EMAIL VALIDATION
  // --------------------------------------------------

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    // No spaces
    if (email.contains(' ')) {
      return 'Email cannot contain spaces';
    }

    // Basic email structure
    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Avoid consecutive dots
    if (email.contains('..')) {
      return 'Please enter a valid email address';
    }

    // Check @ position
    final parts = email.split('@');

    if (parts.length != 2) {
      return 'Please enter a valid email address';
    }

    final domain = parts[1];

    if (domain.startsWith('.') || domain.endsWith('.')) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // --------------------------------------------------
  // SIGN UP
  // --------------------------------------------------

  Future<void> signup() async {
    // Validate all fields
    if (!formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;

      /*
       * If Confirm Email is enabled in Supabase,
       * Supabase normally returns a user but no active session.
       */

      if (response.user != null) {
        showSuccessMessage('Account created. Please verify your email.');

        // TODO:
        // Later we will navigate to VerifyEmailPage.
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      showErrorMessage(getFriendlyAuthError(error.message));
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

  // --------------------------------------------------
  // FRIENDLY SUPABASE ERRORS
  // --------------------------------------------------

  String getFriendlyAuthError(String message) {
    final error = message.toLowerCase();

    if (error.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    if (error.contains('password')) {
      return 'Please use a stronger password.';
    }

    if (error.contains('already registered')) {
      return 'This email is already registered. Please log in.';
    }

    if (error.contains('rate limit')) {
      return 'Too many attempts. Please try again later.';
    }

    if (error.contains('signups')) {
      return 'New registrations are currently unavailable.';
    }

    return message;
  }

  // --------------------------------------------------
  // SUCCESS MESSAGE
  // --------------------------------------------------

  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade600,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
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

  // --------------------------------------------------
  // ERROR MESSAGE
  // --------------------------------------------------

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade600,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // INPUT DECORATION
  // --------------------------------------------------

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.grey.shade50,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),

      errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    );
  }

  // --------------------------------------------------
  // DISPOSE
  // --------------------------------------------------

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 35),

          child: Form(
            key: formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // --------------------------------------------------
                // LOGO
                // --------------------------------------------------
                Center(
                  child: Container(
                    width: 64,
                    height: 64,

                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: const Icon(
                      Icons.location_city_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // --------------------------------------------------
                // TITLE
                // --------------------------------------------------
                const Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Join CivicMind and help improve your community.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                ),

                const SizedBox(height: 35),

                // --------------------------------------------------
                // EMAIL
                // --------------------------------------------------
                const Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,

                  decoration: inputDecoration(
                    label: 'Enter your email',
                    icon: Icons.email_outlined,
                  ),

                  validator: validateEmail,
                ),

                const SizedBox(height: 20),

                // --------------------------------------------------
                // PASSWORD
                // --------------------------------------------------
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,

                  decoration: inputDecoration(
                    label: 'Create a password',
                    icon: Icons.lock_outline,

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },

                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
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

                const SizedBox(height: 20),

                // --------------------------------------------------
                // CONFIRM PASSWORD
                // --------------------------------------------------
                const Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,

                  decoration: inputDecoration(
                    label: 'Confirm your password',
                    icon: Icons.lock_reset_outlined,

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },

                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // --------------------------------------------------
                // SIGN UP BUTTON
                // --------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(
                    onPressed: isLoading ? null : signup,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),

                      foregroundColor: Colors.white,

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
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 22),

                // --------------------------------------------------
                // LOGIN
                // --------------------------------------------------
                Center(
                  child: RichText(
                    text: const TextSpan(
                      text: 'Already have an account? ',

                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),

                      children: [
                        TextSpan(
                          text: 'Log in',

                          style: TextStyle(
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --------------------------------------------------
                // TERMS
                // --------------------------------------------------
                const Center(
                  child: Text(
                    'By creating an account, you agree to our\n'
                    'Terms of Service and Privacy Policy.',

                    textAlign: TextAlign.center,

                    style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
