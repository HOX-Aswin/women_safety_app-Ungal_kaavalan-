import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isNumber;

  CustomTextField({required this.controller, required this.label, this.isNumber = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
    );
  }
}
