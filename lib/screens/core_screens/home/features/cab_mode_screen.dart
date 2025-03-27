import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ungal_kaavalan/providers/cab_mode_provider.dart';
import 'package:ungal_kaavalan/providers/contact_provider.dart';

class CabModeScreen extends ConsumerStatefulWidget {
  const CabModeScreen({super.key});

  @override
  ConsumerState<CabModeScreen> createState() => _CabModeScreenState();
}

class _CabModeScreenState extends ConsumerState<CabModeScreen> {
  static const platform = MethodChannel('sms_channel');

  void _showRideDialog({bool isEditing = false}) {
    final ride = ref.read(cabModeProvider);
    final startLocController = TextEditingController(
        text: isEditing && ride != null ? ride["startLoc"] ?? "" : "");
    final endLocController = TextEditingController(
        text: isEditing && ride != null ? ride["endLoc"] ?? "" : "");
    final carNumberController = TextEditingController(
        text: isEditing && ride != null ? ride["carNumber"] ?? "" : "");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? "Edit Ride" : "New Ride"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startLocController,
              decoration: const InputDecoration(labelText: "Start Location"),
            ),
            TextField(
              controller: endLocController,
              decoration: const InputDecoration(labelText: "End Location"),
            ),
            TextField(
              controller: carNumberController,
              decoration: const InputDecoration(labelText: "Car Number"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newRide = {
                "startLoc": startLocController.text,
                "endLoc": endLocController.text,
                "carNumber": carNumberController.text,
                "status": "stopped",
              };
              ref.read(cabModeProvider.notifier).saveRide(newRide);
              Navigator.of(ctx).pop();
            },
            child: Text(isEditing ? "Save Changes" : "Save Ride"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSOS(String message) async {
    final emergencyContacts = ref.read(emergencyContactProvider);
    List<String> emergencyNumbers = emergencyContacts
        .map<String>((contact) => contact['phone'] ?? '')
        .where((number) => number.isNotEmpty)
        .toList();

    var status = await Permission.sms.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ SMS Permission Denied")),
      );
      return;
    }

    for (String number in emergencyNumbers) {
      try {
        await platform.invokeMethod(
          'sendSms',
          {"phone": number, "message": message},
        );
      } on PlatformException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ Failed to send SMS to $number: ${e.message}")),
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Ride update Message Sent!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(cabModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cab Mode"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ride == null
            ? const Center(
                child: Text(
                  "No ride available. Click '+' to add one.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Ride:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🚀 Start Location: ${ride['startLoc']}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("🎯 End Location: ${ride['endLoc']}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("🚗 Car Number: ${ride['carNumber']}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (ride["status"] == "stopped") ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showRideDialog(isEditing: true),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text("Edit Ride",
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final startMessage =
                                "I am travelling from ${ride['startLoc']} to ${ride['endLoc']} in ${ride['carNumber']}";
                            _sendSOS(startMessage);
                            ref.read(cabModeProvider.notifier).startRide();
                          },
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text("Start Ride",
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final endMessage = "I have reached ${ride['endLoc']}";
                          _sendSOS(endMessage);
                          ref.read(cabModeProvider.notifier).stopRide();
                        },
                        icon: const Icon(Icons.stop, color: Colors.white),
                        label: const Text("Stop Ride",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
      floatingActionButton: ride == null
          ? FloatingActionButton(
              onPressed: _showRideDialog,
              child: const Icon(Icons.add),
            )
          : null, // Hide "+" button if a ride exists
    );
  }
}
