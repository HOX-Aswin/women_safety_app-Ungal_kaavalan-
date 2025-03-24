import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Color(0xFF3674B5),
      ),
      body: Column(
        children: [
          SizedBox(height: 60), // Padding between app bar and button
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Add SOS functionality here
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(130), // Slightly larger size
                backgroundColor: Colors.red,
              ),
              child: Text(
                "SOS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
