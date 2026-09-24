import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CivicMind',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 70,
                color: Color(0xFF16A34A),
              ),

              const SizedBox(height: 20),

              const Text(
                'Welcome to CivicMind',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 12),

              Text(
                user?.email ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
              ),

              const SizedBox(height: 30),

              const Text(
                'Your account is successfully signed in.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
