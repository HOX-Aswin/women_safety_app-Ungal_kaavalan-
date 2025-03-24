import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ungal_kaavalan/providers/provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void logout(BuildContext context, WidgetRef ref) async {
    await FirebaseAuth.instance.signOut();

    await ref.read(uidProvider.notifier).setUid(null);
    await ref.read(authProvider.notifier).setAuthState(false);

    context.go('/'); // Navigate to login screen
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Color(0xFF3674B5),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton(
          onPressed: () => logout(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3674B5),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text("Logout",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
