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
  bool _checkingVerification = true;
  bool _verificationLinkClicked = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationRedirect();
  }

  Future<void> _checkVerificationRedirect() async {
    final uri = Uri.base;

    // ----------------------------------------------------------
    // EMAIL VERIFICATION REDIRECT
    // ----------------------------------------------------------
    //
    // Signup থেকে আমরা:
    //   ?verified=true
    //
    // পাঠাব।
    //
    // তাই verification link click করার পরে
    // এই condition true হবে।
    // ----------------------------------------------------------

    if (uri.queryParameters['verified'] == 'true') {
      _verificationLinkClicked = true;

      // Verification link-এর মাধ্যমে Supabase temporary
      // session তৈরি করতে পারে।
      //
      // কিন্তু আমরা চাই user নিজে Sign In করুক।
      //
      // তাই existing session থাকলে sign out করে দিচ্ছি।
      if (Supabase.instance.client.auth.currentSession != null) {
        await Supabase.instance.client.auth.signOut();
      }
    }

    if (!mounted) return;

    setState(() {
      _checkingVerification = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------
    // CHECKING
    // ----------------------------------------------------------

    if (_checkingVerification) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ----------------------------------------------------------
    // VERIFICATION LINK CLICKED
    // ----------------------------------------------------------
    //
    // Verification email থেকে এলে সরাসরি Sign In page.
    // Signup page দেখাবে না।
    // ----------------------------------------------------------

    if (_verificationLinkClicked) {
      return const SigninPage();
    }

    // ----------------------------------------------------------
    // NORMAL APP OPEN
    // ----------------------------------------------------------

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const HomePage();
    }

    // ----------------------------------------------------------
    // NO SESSION
    // ----------------------------------------------------------

    return const SignupPage();
  }
}
