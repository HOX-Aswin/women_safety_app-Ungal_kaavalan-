import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Info"),
        backgroundColor: Color(0xFF3674B5),
      ),
      body: Placeholder(),
    );
  }
}
