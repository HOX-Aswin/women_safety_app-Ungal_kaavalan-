import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('sms_channel');

  // Emergency contacts
  final List<String> emergencyNumbers = [
    // "8778938882", //hari
    // "8072661442", //akesh
    "6383488874", //aswin
    // "9043795535", //gokulanand
    // "7604864097", //aathi
  ];
  final String emergencyMessage =
      "🚨 SOS! I need help immediately. Please contact me!";
  // Function to send SOS message
  Future<void> _sendSOS() async {
    var status = await Permission.sms.request(); // Request SMS permission

    if (status.isGranted) {
      for (String number in emergencyNumbers) {
        try {
          await platform.invokeMethod(
              'sendSms', {"phone": number, "message": emergencyMessage});
        } on PlatformException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Failed to send SMS: ${e.message}")),
          );
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ SOS Message Sent!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ SMS Permission Denied")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF3674B5),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60), // Padding between app bar and button
          Center(
            child: ElevatedButton(
              onPressed: _sendSOS, // Calls the SOS function
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(130), // Large button
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "SOS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
          Center(
            child: ElevatedButton(
              onPressed: () => context.go('/emergencycontact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3674B5),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text("Emergency contacts",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
