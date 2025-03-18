import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(uid: uid)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA1E3F9), // Restoring original accent color as background
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome Back", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF3674B5))),
              SizedBox(height: 10),
              Text("Login to continue", style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 20),
              _buildCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(emailController, "Email", Icons.email),
                      _buildTextField(passwordController, "Password", Icons.lock, obscureText: true),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: login,
                        style: _buttonStyle(),
                        child: Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen())),
                child: Text("Don't have an account? Sign Up", style: TextStyle(color: Color(0xFF3674B5))),
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
      child: Padding(padding: EdgeInsets.all(20), child: child),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF3674B5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          filled: true,
          fillColor: Color(0xFFF0F7FF),
        ),
        obscureText: obscureText,
        validator: (value) => value!.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF3674B5),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
