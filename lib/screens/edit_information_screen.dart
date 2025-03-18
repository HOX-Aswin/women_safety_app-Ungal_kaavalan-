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
  bool isLoading = true;

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
        isLoading = false;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height; // ✅ Get dynamic height
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom; // ✅ Get keyboard height

    return Scaffold(
      resizeToAvoidBottomInset: false, // ✅ Prevents automatic resizing issues
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Color(0xFF3674B5),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // ✅ Hide keyboard when tapping outside
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // ✅ Dismiss keyboard on scroll
          child: Container(
            height: screenHeight - keyboardHeight, // ✅ Adjust height dynamically
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Expanded(
                    child: Column(
                      children: [
                        _buildTextField(nameController, "Name"),
                        _buildTextField(phoneController, "Phone", isNumber: true),
                        _buildTextField(ageController, "Age", isNumber: true),
                        _buildTextField(addressController, "Address"),
                        _buildTextField(aadharController, "Aadhar", isNumber: true),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
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
