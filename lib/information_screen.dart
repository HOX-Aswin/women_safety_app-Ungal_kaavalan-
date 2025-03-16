import 'package:flutter/material.dart';

class InformationPage extends StatefulWidget {
  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Information")),
      body: SingleChildScrollView( // Prevents overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Name*",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 10),

                // Phone Number Field
                TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number*",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Phone number is required";
                    if (value.length != 10) return "Phone number must be 10 digits";
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: ["Male", "Female", "Other"]
                      .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Gender*",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  ),
                  validator: (value) =>
                  value == null ? "Please select a gender" : null,
                ),
                const SizedBox(height: 10),

                // Age Field
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Age*",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Age is required" : null,
                ),
                const SizedBox(height: 10),

                // Address Field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                // Aadhar Number Field
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Aadhar Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Aadhar number is required";
                    if (value.length != 12) return "Aadhar number must be 12 digits";
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Terms & Conditions Checkbox
                CheckboxListTile(
                  title: GestureDetector(
                    onTap: () {
                      // Navigate to Terms & Conditions page if needed
                    },
                    child: const Text(
                      "I agree to the Terms & Conditions",
                      style:
                      TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 10),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (!_isChecked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please accept the Terms & Conditions"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          // Navigate to the next page or process the data
                        }
                      }
                    },
                    child: const Text("Done"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
