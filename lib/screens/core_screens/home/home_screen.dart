import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ungal_kaavalan/providers/contact_provider.dart';
import 'package:ungal_kaavalan/screens/core_screens/home/features/cab_mode_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const platform = MethodChannel('sms_channel');

  List<String> emergencyNumbers = []; // Initially empty

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  // Fetch emergency contacts from provider
  void _loadEmergencyContacts() {
    final emergencyContacts = ref.read(emergencyContactProvider);
    setState(() {
      emergencyNumbers = emergencyContacts
          .map<String>((contact) => contact['phone'] ?? '')
          .where((number) => number.isNotEmpty)
          .toList();
    });
  }

  final String emergencyMessage =
      "🚨 SOS! I need help immediately. Please contact me!";

  // Function to send SOS message
  Future<void> _sendSOS() async {
    _loadEmergencyContacts();
    var status = await Permission.sms.request(); // Request SMS permission

    if (status.isGranted) {
      if (emergencyNumbers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ No emergency contacts found.")),
        );
        return;
      }

      for (String number in emergencyNumbers) {
        try {
          await platform.invokeMethod(
            'sendSms',
            {"phone": number, "message": emergencyMessage},
          );
        } on PlatformException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("❌ Failed to send SMS to $number: ${e.message}")),
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ SOS Message Sent!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ SMS Permission Denied")),
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
                backgroundColor: const Color(0xFF3674B5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Emergency contacts",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 60),
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CabModeScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3674B5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Cab mode",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
