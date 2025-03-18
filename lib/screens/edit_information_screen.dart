import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final String uid;
  EditProfileScreen({required this.uid});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();
  final aadharController = TextEditingController();
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    UserModel? fetchedUser = await FirebaseService().getUserData(widget.uid);
    if (fetchedUser != null) {
      setState(() {
        user = fetchedUser;
        nameController.text = user!.name;
        phoneController.text = user!.phone;
        ageController.text = user!.age;
        addressController.text = user!.address;
        aadharController.text = user!.aadhar;
      });
    }
  }

  void updateData() async {
    if (_formKey.currentState!.validate()) {
      UserModel updatedUser = UserModel(
        uid: widget.uid,
        name: nameController.text,
        phone: phoneController.text,
        gender: user!.gender,
        age: ageController.text,
        address: addressController.text,
        aadhar: aadharController.text,
      );

      await FirebaseService().updateUser(widget.uid, updatedUser);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
                    TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone")),
                    TextField(controller: ageController, decoration: InputDecoration(labelText: "Age")),
                    TextField(controller: addressController, decoration: InputDecoration(labelText: "Address")),
                    TextField(controller: aadharController, decoration: InputDecoration(labelText: "Aadhar")),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateData,
                      child: Text("Save Changes"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
