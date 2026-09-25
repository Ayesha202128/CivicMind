import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'signup_page.dart';
import 'signin_page.dart';
import 'home_page.dart';
import 'verify_email_page.dart';
import 'forgot_password_page.dart';
import 'reset_password_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qpbjwsgipxiahwvgtftx.supabase.co',
    publishableKey: 'sb_publishable_ht7eyTk3Hiks_pjqJbejhw_dKkerWvg',
  );

  runApp(const CivicMindApp());
}

class CivicMindApp extends StatelessWidget {
  const CivicMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CivicMind',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        scaffoldBackgroundColor: Colors.white,
      ),

      home: const AuthWrapper(),

      routes: {
        '/signup': (context) => const SignupPage(),
        '/signin': (context) => const SigninPage(),
        '/verify-email': (context) => const VerifyEmailPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/reset-password': (context) => const ResetPasswordPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  // Email verification link থেকে এসেছে কি না
  bool _verificationLinkClicked = false;

  // Password recovery link থেকে এসেছে কি না
  bool _recoveryLinkClicked = false;

  // Auth state listener-এর subscription
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final supabase = Supabase.instance.client;

    try {
      final uri = Uri.base;

      // ----------------------------------------------------------
      // EMAIL VERIFICATION LINK
      // ----------------------------------------------------------

      if (uri.queryParameters['verified'] == 'true') {
        _verificationLinkClicked = true;

        // Verification-এর পরে যদি temporary session থাকে,
        // user-কে manually Sign In করানোর জন্য sign out করছি।
        if (supabase.auth.currentSession != null) {
          await supabase.auth.signOut();
        }
      }

      // ----------------------------------------------------------
      // PASSWORD RECOVERY LINK
      // ----------------------------------------------------------

      if (uri.queryParameters['recovery'] == 'true') {
        _recoveryLinkClicked = true;
      }

      // ----------------------------------------------------------
      // AUTH STATE LISTENER
      // ----------------------------------------------------------

      _authSubscription = supabase.auth.onAuthStateChange.listen(
        (data) {
          final event = data.event;

          if (!mounted) return;

          // Password recovery link process complete হলে
          // ResetPasswordPage দেখানো হবে।
          if (event == AuthChangeEvent.passwordRecovery) {
            setState(() {
              _recoveryLinkClicked = true;
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          debugPrint('Auth state listener error: $error');
        },
      );
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ----------------------------------------------------------
    // PASSWORD RECOVERY
    // ----------------------------------------------------------

    if (_recoveryLinkClicked) {
      return const ResetPasswordPage();
    }

    // ----------------------------------------------------------
    // EMAIL VERIFICATION
    // ----------------------------------------------------------

    if (_verificationLinkClicked) {
      return const SigninPage();
    }

    // ----------------------------------------------------------
    // ACTIVE SESSION
    // ----------------------------------------------------------
    //
    // এটিই এখন authentication-এর মূল source of truth।
    //
    // Session আছে → Home
    // Session নেই → Sign In
    // ----------------------------------------------------------

    // ----------------------------------------------------------
    // ACTIVE SESSION
    // ----------------------------------------------------------
    //
    // এটিই এখন authentication-এর মূল source of truth.
    //
    // Session আছে → Home
    // Session নেই → Sign In
    // ----------------------------------------------------------

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const HomePage();
    }

    // ----------------------------------------------------------
    // NO ACTIVE SESSION
    // ----------------------------------------------------------
    //
    // Supabase session নেই → Sign In
    //
    // Sign In page থেকেই নতুন user Create Account করতে পারবে.
    // ----------------------------------------------------------

    return const SigninPage();

    if (session != null) {
      return const HomePage();
    }

    // ----------------------------------------------------------
    // NO ACTIVE SESSION
    // ----------------------------------------------------------
    //
    // Account আগে তৈরি হয়েছে কি না সেটা আর
    // SharedPreferences দিয়ে check করছি না।
    //
    // Supabase session নেই → Sign In
    //
    // Sign In page থেকেই নতুন user Create Account করতে পারবে।
    // ----------------------------------------------------------

    return const SigninPage();
  }
}
