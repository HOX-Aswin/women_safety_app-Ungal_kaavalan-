import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ungal_kaavalan/providers/cab_mode_provider.dart';
import 'package:ungal_kaavalan/providers/contact_provider.dart';
import 'package:ungal_kaavalan/providers/provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void logout(BuildContext context, WidgetRef ref) async {
    await FirebaseAuth.instance.signOut();

    // Remove UID from SharedPreferences
    await ref.read(uidProvider.notifier).setUid(null);
    await ref.read(authProvider.notifier).setAuthState(false);

    // Clear stored emergency contacts
    await ref.read(emergencyContactProvider.notifier).setContacts([]);

    // Clear cab details
    ref.read(cabModeProvider.notifier).stopRide();

    context.go('/'); // Navigate to login screen
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
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
