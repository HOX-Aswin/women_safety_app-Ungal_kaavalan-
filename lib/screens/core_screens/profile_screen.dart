import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungal_kaavalan/providers/provider.dart';
import 'package:ungal_kaavalan/screens/core_screens/edit_information_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    final uid = ref.read(uidProvider);
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
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
    final uid = ref.watch(uidProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Profile"), backgroundColor: Color(0xFF3674B5)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
              ? Center(child: Text("No user data found"))
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTextField("Name", userData!['name']),
                        _buildTextField("Phone", userData!['phone']),
                        _buildTextField("Age", userData!['age']),
                        _buildTextField("Gender", userData!['gender']),
                        _buildTextField("Address", userData!['address']),
                        _buildTextField("Aadhar", userData!['aadhar']),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(uid: uid!),
                              ),
                            ).then((_) => fetchUserData()); // Refresh on return
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
    );
  }

  Widget _buildTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
