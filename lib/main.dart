import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Verification link থেকে এসেছে কি না
  bool _verificationLinkClicked = false;

  // Password recovery link থেকে এসেছে কি না
  bool _recoveryLinkClicked = false;

  // User আগে account create করেছে কি না
  bool _hasAccount = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final supabase = Supabase.instance.client;
      final uri = Uri.base;

      final prefs = await SharedPreferences.getInstance();

      // ----------------------------------------------------------
      // CHECK IF USER HAS CREATED AN ACCOUNT BEFORE
      // ----------------------------------------------------------

      _hasAccount = prefs.getBool('has_account') ?? false;

      // ----------------------------------------------------------
      // EMAIL VERIFICATION LINK
      // ----------------------------------------------------------

      if (uri.queryParameters['verified'] == 'true') {
        _verificationLinkClicked = true;

        // Verification link-এর মাধ্যমে Supabase temporary
        // session তৈরি করতে পারে।
        //
        // কিন্তু আমাদের app logic অনুযায়ী user-কে
        // manually Sign In করতে হবে।
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
      //
      // Password recovery হলে ResetPasswordPage দেখাবে।
      //
      supabase.auth.onAuthStateChange.listen((data) {
        final event = data.event;

        if (event == AuthChangeEvent.passwordRecovery) {
          if (mounted) {
            setState(() {
              _recoveryLinkClicked = true;
              _isLoading = false;
            });
          }
        }
      });
    } catch (e) {
      // কোনো unexpected error হলেও app আটকে থাকবে না।
      debugPrint('Auth initialization error: $e');
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
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
    //
    // Reset password email-এর link click করলে
    // সরাসরি ResetPasswordPage.
    // ----------------------------------------------------------

    if (_recoveryLinkClicked) {
      return const ResetPasswordPage();
    }

    // ----------------------------------------------------------
    // EMAIL VERIFICATION
    // ----------------------------------------------------------
    //
    // Verification link click করলে
    // সরাসরি Home নয়।
    //
    // User manually email + password দিয়ে Sign In করবে।
    // ----------------------------------------------------------

    if (_verificationLinkClicked) {
      return const SigninPage();
    }

    // ----------------------------------------------------------
    // EXISTING ACTIVE SESSION
    // ----------------------------------------------------------
    //
    // User আগে login করে রেখেছে এবং session এখনো valid।
    //
    // App বন্ধ করে আবার খুললেও:
    //
    // Session থাকলে → Home
    //
    // ----------------------------------------------------------

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const HomePage();
    }

    // ----------------------------------------------------------
    // NO SESSION BUT ACCOUNT EXISTS
    // ----------------------------------------------------------
    //
    // User আগে account তৈরি করেছে কিন্তু বর্তমানে
    // login করা নেই।
    //
    // তাই Signup নয়, Sign In দেখাব।
    // ----------------------------------------------------------

    if (_hasAccount) {
      return const SigninPage();
    }

    // ----------------------------------------------------------
    // FIRST TIME USER
    // ----------------------------------------------------------
    //
    // একদম নতুন user হলে Signup.
    // ----------------------------------------------------------

    return const SignupPage();
  }
}
