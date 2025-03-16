import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InformationScreen extends StatefulWidget {
  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();
  final aadharController = TextEditingController();
  String? _selectedGender;
  bool _isChecked = false;

  void submitData() async {
    if (_formKey.currentState!.validate() && _isChecked) {
      await FirebaseFirestore.instance.collection('users').add({
        'name': nameController.text,
        'phone': phoneController.text,
        'gender': _selectedGender,
        'age': ageController.text,
        'address': addressController.text,
        'aadhar': aadharController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Saved")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Information", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Name*")),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone number*")),
              TextField(controller: ageController, decoration: InputDecoration(labelText: "Age*")),
              TextField(controller: addressController, decoration: InputDecoration(labelText: "Address")),
              TextField(controller: aadharController, decoration: InputDecoration(labelText: "Aadhar number")),
              ElevatedButton(onPressed: submitData, child: Text("Done"))
            ],
          ),
        ),
      ),
    );
  }
}