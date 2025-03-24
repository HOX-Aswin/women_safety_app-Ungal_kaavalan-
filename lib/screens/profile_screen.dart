import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungal_kaavalan/providers/provider.dart';
import 'package:ungal_kaavalan/screens/edit_information_screen.dart';

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
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${userData!['name'] ?? 'Not Provided'}"),
                      Text("Phone: ${userData!['phone'] ?? 'Not Provided'}"),
                      Text("Age: ${userData!['age'] ?? 'Not Provided'}"),
                      Text("Gender: ${userData!['gender'] ?? 'Not Provided'}"),
                      Text("Address: ${userData!['address'] ?? 'Not Provided'}"),
                      Text("Aadhar: ${userData!['aadhar'] ?? 'Not Provided'}"),
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
                          backgroundColor: Color(0xFFA1E3F9),
                        ),
                        child: Text("Edit Profile", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
    );
  }
}
