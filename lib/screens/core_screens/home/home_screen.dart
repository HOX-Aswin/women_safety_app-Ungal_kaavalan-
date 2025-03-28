import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:ungal_kaavalan/providers/contact_provider.dart';
import 'package:ungal_kaavalan/screens/core_screens/home/features/cab_mode_screen.dart';
import 'package:ungal_kaavalan/screens/core_screens/home/features/voice_detection_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const platform = MethodChannel('sms_channel');
  List<String> emergencyNumbers = [];

  // Shake detection variables
  bool _isShakeDetectionActive = true;
  DateTime? _lastShakeTime;
  int _shakeCount = 0;
  static const _shakeThreshold = 15.0;  // Adjust sensitivity as needed
  static const _shakeCooldownMs = 1000;  // Cooldown between shakes (ms)
  static const _resetShakeCountAfterMs = 3000;  // Reset counter if no shakes for this duration
  static const _requiredShakes = 3;  // Number of shakes required to trigger SOS

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
    _initShakeDetection();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initShakeDetection() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (!_isShakeDetectionActive) return;

      double acceleration = _calculateAcceleration(event);
      DateTime now = DateTime.now();

      // Reset shake count if it's been too long since last shake
      if (_lastShakeTime != null &&
          now.difference(_lastShakeTime!).inMilliseconds > _resetShakeCountAfterMs &&
          _shakeCount > 0) {
        _shakeCount = 0;
      }

      // Detect shake
      if (acceleration > _shakeThreshold) {
        // Check if enough time has passed since last shake
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!).inMilliseconds > _shakeCooldownMs) {
          _lastShakeTime = now;
          _shakeCount++;

          // Provide subtle feedback
          HapticFeedback.lightImpact();

          // Check if we've reached required number of shakes
          if (_shakeCount >= _requiredShakes) {
            _shakeCount = 0;  // Reset counter
            _temporarilyDisableShakeDetection();  // Prevent multiple triggers
            _sendSOS();  // Trigger SOS
          }
        }
      }
    });
  }

  double _calculateAcceleration(AccelerometerEvent event) {
    // Calculate acceleration magnitude using the Euclidean norm
    return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
  }

  void _temporarilyDisableShakeDetection() {
    // Disable shake detection temporarily to prevent multiple triggers
    setState(() => _isShakeDetectionActive = false);

    // Re-enable after a cooldown period
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isShakeDetectionActive = true);
      }
    });
  }

  void _loadEmergencyContacts() {
    final emergencyContacts = ref.read(emergencyContactProvider);
    setState(() {
      emergencyNumbers = emergencyContacts
          .map<String>((contact) => contact['phone'] ?? '')
          .where((number) => number.isNotEmpty)
          .toList();
    });
  }

  final String sosMessage = "🚨 SOS! I need help immediately. Please contact me!";

  Future<void> _sendSOS() async {
    _loadEmergencyContacts();

    if (emergencyNumbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ No emergency contacts found."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String locationMessage = "📍 My Location: https://www.google.com/maps?q=${position.latitude},${position.longitude}";

      for (String number in emergencyNumbers) {
        if (number.isNotEmpty) {
          await platform.invokeMethod(
            'sendSms',
            {
              "phone": number.trim(),
              "sosMessage": sosMessage.trim(),
              "locationMessage": locationMessage.trim(),
            },
          );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to get location: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        "Ungal Kaavalan",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            const Icon(Icons.people, color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              "${emergencyNumbers.length}",
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SOS Button with animated effect
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.95, end: 1.0),
                          duration: const Duration(seconds: 2),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: GestureDetector(
                                onTap: _sendSOS,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const RadialGradient(
                                      colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                                      radius: 0.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF5252).withOpacity(0.4),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                      const BoxShadow(
                                        color: Color(0xFFFFCDD2),
                                        blurRadius: 0,
                                        spreadRadius: 2,
                                        offset: Offset(0, -4),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                            width: 15,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        "SOS",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 48,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0, 2),
                                              blurRadius: 5,
                                              color: Color(0xAAB71C1C),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Press for emergency assistance",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Feature shortcuts with glassmorphism effect
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(20),
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
                        "SAFETY FEATURES",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureButton(
                            "Cab Mode",
                            Icons.local_taxi_rounded,
                                () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CabModeScreen()),
                            ),
                          ),
                          _buildFeatureButton(
                            "Voice Alert",
                            Icons.mic_rounded,
                                () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VoiceDetectionScreen(onTriggerSOS: _sendSOS)),
                            ),
                          ),
                          _buildFeatureButton(
                            "Contacts",
                            Icons.person_rounded,
                                () => context.go('/emergencycontact'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(String label, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the background
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