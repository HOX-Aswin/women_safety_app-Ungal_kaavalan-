import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ungal_kaavalan/providers/provider.dart';

// ignore: must_be_immutable
class SignUpScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();
  final aadharController = TextEditingController();
  String? _selectedGender;

  SignUpScreen({super.key});

  void signUp(BuildContext context, WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;
        ref.read(uidProvider.notifier).state = userCredential.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'gender': _selectedGender,
          'age': ageController.text,
          'address': addressController.text,
          'aadhar': aadharController.text,
        });

        ref.read(authProvider.notifier).state = true;
        context.go('/home');
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Color(0xFFA1E3F9), // Accent Color
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create Account",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3674B5)), // Primary Color
              ),
              SizedBox(height: 10),
              Text("Sign up to continue",
                  style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 20),
              _buildCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                          nameController, "Full Name", Icons.person),
                      _buildTextField(emailController, "Email", Icons.email),
                      _buildTextField(
                          phoneController, "Phone Number", Icons.phone),
                      Row(
                        children: [
                          Expanded(child: _buildDropdown(ref)), // Gender
                          SizedBox(width: 10),
                          Expanded(
                              child: _buildTextField(
                                  ageController, "Age", Icons.cake)), // Age
                        ],
                      ),
                      _buildTextField(addressController, "Address", Icons.home),
                      _buildTextField(
                          aadharController, "Aadhar Number", Icons.credit_card),
                      _buildTextField(
                          passwordController, "Password", Icons.lock,
                          obscureText: true),
                      _buildTextField(confirmPasswordController,
                          "Confirm Password", Icons.lock,
                          obscureText: true),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => signUp(context, ref),
                        style: _buttonStyle(),
                        child: Text("Sign Up",
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () => context.go('/'),
                child: Text("Already have an account? Log in",
                    style:
                        TextStyle(color: Color(0xFF3674B5))), // Primary Color
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

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF3674B5)), // Primary Color
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          filled: true,
          fillColor: Color(0xFFF0F7FF), // Light background
        ),
        obscureText: obscureText,
        validator: (value) => value!.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  Widget _buildDropdown(WidgetRef ref) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      items: ["Male", "Female", "Other"]
          .map((label) => DropdownMenuItem(value: label, child: Text(label)))
          .toList(),
      onChanged: (value) => ref.read(genderProvider.notifier).state = value,
      decoration: InputDecoration(
        labelText: "Gender",
        prefixIcon:
            Icon(Icons.people, color: Color(0xFF3674B5)), // Primary Color
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Color(0xFFF0F7FF), // Light background
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF3674B5), // Primary Color
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
