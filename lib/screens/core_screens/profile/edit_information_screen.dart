import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ungal_kaavalan/providers/provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final addressController = TextEditingController();
  final aadharController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    final uid = ref.read(uidProvider);
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        nameController.text = data['name'] ?? "";
        phoneController.text = data['phone'] ?? "";
        ageController.text = data['age'] ?? "";
        genderController.text = data['gender'] ?? "";
        addressController.text = data['address'] ?? "";
        aadharController.text = data['aadhar'] ?? "";
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void updateData() async {
    if (_formKey.currentState!.validate()) {
      final uid = ref.read(uidProvider);
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text,
        'phone': phoneController.text,
        'age': ageController.text,
        'gender': genderController.text,
        'address': addressController.text,
        'aadhar': aadharController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(
          "Edit profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ), backgroundColor: Color(0xFF3674B5)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      _buildTextField(nameController, "Name"),
                      _buildTextField(phoneController, "Phone", isNumber: true),
                      _buildTextField(ageController, "Age", isNumber: true),
                      _buildTextField(genderController, "Gender"),
                      _buildTextField(addressController, "Address"),
                      _buildTextField(aadharController, "Aadhar", isNumber: true),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: updateData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF578FCA),
                        ),
                        child: Text("Save Changes", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? "Enter your $label" : null,
      ),
    );
  }
}
