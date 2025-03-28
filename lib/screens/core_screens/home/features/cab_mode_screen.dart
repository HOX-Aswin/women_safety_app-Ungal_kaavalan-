import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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
  Timer? _sosTimer;

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
        backgroundColor: const Color(0xFF4F46E5).withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        title: Text(
          isEditing ? "Edit Ride" : "New Ride",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(startLocController, "Start Location", Icons.location_on),
            const SizedBox(height: 16),
            _buildTextField(endLocController, "End Location", Icons.location_on_outlined),
            const SizedBox(height: 16),
            _buildTextField(carNumberController, "Car Number", Icons.directions_car),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
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
              child: Text(
                isEditing ? "Save Changes" : "Save Ride",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  void _startPeriodicSOS(String message) {
    _sosTimer?.cancel();
    _sosTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _sendSOS(message);
    });
  }

  void _stopPeriodicSOS() {
    _sosTimer?.cancel();
    _sosTimer = null;
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    super.dispose();
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
        const SnackBar(
          content: Text("❌ SMS Permission Denied"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var locationStatus = await Permission.location.request();

    if (!locationStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Location Permission Denied"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String locationMessage =
          "📍 My Location: https://www.google.com/maps?q=${position.latitude},${position.longitude}";
      print("📍 Location: ${position.latitude}, ${position.longitude}");

      for (String number in emergencyNumbers) {
        print("📤 Sending SOS to: $number");

        if (number.isNotEmpty) {
          await platform.invokeMethod(
            'sendSms',
            {
              "phone": number.trim(),
              "sosMessage": message.trim(),
              "locationMessage": locationMessage.trim(),
            },
          );

          print("✅ SMS Sent to: $number");
        } else {
          print("⚠️ Skipping empty phone number.");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ SOS Message Sent!"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("❌ Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to get location: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Ride update Message Sent!"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(cabModeProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background design with curved shapes
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App bar with shadcn-inspired design
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Text(
                            "Cab Mode",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            const Icon(Icons.local_taxi_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              ride != null ? "Active" : "Inactive",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ride == null
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car_outlined,
                            size: 80,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No ride available",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Tap the + button to add a new ride",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ride details card with glassmorphism effect
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "RIDE DETAILS",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildRideDetail(Icons.location_on, "From", ride['startLoc'] ?? ""),
                              const SizedBox(height: 16),
                              _buildRideDetail(Icons.location_on_outlined, "To", ride['endLoc'] ?? ""),
                              const SizedBox(height: 16),
                              _buildRideDetail(Icons.directions_car, "Car", ride['carNumber'] ?? ""),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: ride["status"] == "stopped"
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: ride["status"] == "stopped"
                                        ? Colors.orange.withOpacity(0.5)
                                        : Colors.green.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  ride["status"] == "stopped" ? "Ready to start" : "Ride in progress",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (ride["status"] == "stopped") ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                "Edit",
                                Icons.edit,
                                Colors.orange,
                                    () => _showRideDialog(isEditing: true),
                              ),
                              _buildActionButton(
                                "Start Ride",
                                Icons.play_arrow_rounded,
                                Colors.green,
                                    () {
                                  final startMessage =
                                      "I am travelling from ${ride['startLoc']} to ${ride['endLoc']} in ${ride['carNumber']}";
                                  _sendSOS(startMessage);
                                  _startPeriodicSOS("This is my current location");
                                  ref.read(cabModeProvider.notifier).startRide();
                                },
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildActionButton(
                            "End Ride",
                            Icons.stop_circle,
                            Colors.red,
                                () {
                              final endMessage = "I have reached ${ride['endLoc']}";
                              _sendSOS(endMessage);
                              _stopPeriodicSOS();
                              ref.read(cabModeProvider.notifier).stopRide();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ride == null
          ? Container(
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF1E40AF)],
            radius: 0.8,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showRideDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      )
          : null,
    );
  }

  Widget _buildRideDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the background (same as in HomeScreen)
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4F46E5),  // Indigo
          Color(0xFF1E40AF),  // Dark blue
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Paint background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw decorative shapes
    final shapePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // First shape
    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.2,
          size.width,
          size.height * 0.3
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path1, shapePaint);

    // Second shape
    final path2 = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
          size.width * 0.7,
          size.height * 0.8,
          size.width,
          size.height * 0.95
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path2, shapePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}