import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ungal_kaavalan/providers/provider.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void logout(BuildContext context, WidgetRef ref) async {
  await FirebaseAuth.instance.signOut();

  ref.read(authProvider.notifier).state = false;

  // ignore: use_build_context_synchronously
  context.go('/');
}


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Color(0xFF3674B5),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => logout(context, ref),
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF578FCA),
          ),
          child: Text("Go to Profile", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
