import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'signup_page.dart';

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
      home: const SignupPage(),
    );
  }
}
