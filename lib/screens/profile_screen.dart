import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  ProfileScreen({required this.uid});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool _isEditing = false;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();

    setState(() {
      userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null) {
        nameController.text = userData!['name'];
        phoneController.text = userData!['phone'];
        ageController.text = userData!['age'];
      }
    });
  }

  void saveChanges() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
      'name': nameController.text,
      'phone': phoneController.text,
      'age': ageController.text,
    });

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile"), backgroundColor: Color(0xFF3674B5)),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name"),
                    enabled: _isEditing,
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: "Phone"),
                    enabled: _isEditing,
                  ),
                  TextField(
                    controller: ageController,
                    decoration: InputDecoration(labelText: "Age"),
                    enabled: _isEditing,
                  ),
                  SizedBox(height: 20),
                  _isEditing
                      ? ElevatedButton(
                          onPressed: saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF578FCA),
                          ),
                          child: Text("Save", style: TextStyle(color: Colors.white)),
                        )
                      : ElevatedButton(
                          onPressed: () => setState(() => _isEditing = true),
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
