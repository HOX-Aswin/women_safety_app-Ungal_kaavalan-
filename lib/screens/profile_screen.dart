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
  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final aadharController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData();
  }


  void getUserData() async {
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();

    if (userDoc.exists) {
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
        nameController.text = userData?['name'] ?? "Not Provided";
        phoneController.text = userData?['phone'] ?? "Not Provided";
        ageController.text = userData?['age'] ?? "Not Provided";
        genderController.text = userData?['gender'] ?? "Not Provided";
        addressController.text = userData?['address'] ?? "Not Provided";
        aadharController.text = userData?['aadhar'] ?? "Not Provided";
      });
    } else {
      setState(() {
        userData = {
          'name': "Not Provided",
          'phone': "Not Provided",
          'age': "Not Provided",
          'gender': "Not Provided",
          'address': "Not Provided",
          'aadhar': "Not Provided",
        };
      });
    }
  }


  void saveChanges() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
      'name': nameController.text,
      'phone': phoneController.text,
      'age': ageController.text,
      'gender': genderController.text,
      'address': addressController.text,
      'aadhar': aadharController.text,
    });

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated!")));
  }

  Widget buildTextField(String label, TextEditingController controller, bool enabled) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        enabled: enabled,
      ),
    );
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
            buildTextField("Name", nameController, _isEditing),
            buildTextField("Phone", phoneController, _isEditing),
            buildTextField("Age", ageController, _isEditing),
            buildTextField("Gender", genderController, _isEditing),
            buildTextField("Address", addressController, _isEditing),
            buildTextField("Aadhar", aadharController, _isEditing),
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