import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ungal_kaavalan/providers/provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login(BuildContext context, WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final uid = userCredential.user!.uid;

        // Store UID and auth state in SharedPreferences
        await ref.read(uidProvider.notifier).setUid(uid);
        await ref.read(authProvider.notifier).setAuthState(true);

        context.go('/home'); // Navigate to home screen
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA1E3F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Welcome Back",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3674B5))),
              const SizedBox(height: 10),
              Text("Login to continue",
                  style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 20),
              _buildCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_emailController, "Email", Icons.email),
                      _buildTextField(
                          _passwordController, "Password", Icons.lock,
                          obscureText: true),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => login(context, ref),
                        style: _buttonStyle(),
                        child: const Text("Login",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => context.go('/signup'),
                child: const Text("Don't have an account? Sign Up",
                    style: TextStyle(color: Color(0xFF3674B5))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      color: Colors.white,
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF3674B5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          filled: true,
          fillColor: const Color(0xFFF0F7FF),
        ),
        obscureText: obscureText,
        validator: (value) => value!.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3674B5),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
