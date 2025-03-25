import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungal_kaavalan/providers/provider.dart';
import 'package:ungal_kaavalan/screens/core_screens/profile/edit_information_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  Map<String, String> userData = {};

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    final uid = ref.read(uidProvider);
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        userData = {
          'name': data['name'] ?? "",
          'phone': data['phone'] ?? "",
          'age': data['age'] ?? "",
          'gender': data['gender'] ?? "",
          'address': data['address'] ?? "",
          'aadhar': data['aadhar'] ?? "",
        };
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ), backgroundColor: Color(0xFF3674B5)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchUserData, // Pull-to-refresh
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(), // Allows refresh even when content is short
                  child: Column(
                    children: [
                      _buildReadOnlyField("Name", userData['name']!),
                      _buildReadOnlyField("Phone", userData['phone']!),
                      _buildReadOnlyField("Age", userData['age']!),
                      _buildReadOnlyField("Gender", userData['gender']!),
                      _buildReadOnlyField("Address", userData['address']!),
                      _buildReadOnlyField("Aadhar", userData['aadhar']!),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditProfileScreen()),
                          ).then((_) => fetchUserData()); // Refresh after editing
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF578FCA),
                        ),
                        child: Text("Edit Profile", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: true,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200], // Read-only background color
        ),
      ),
    );
  }
}
