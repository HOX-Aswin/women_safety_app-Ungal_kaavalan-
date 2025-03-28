import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceDetectionScreen extends StatefulWidget {
  final VoidCallback onTriggerSOS;
  const VoiceDetectionScreen({super.key, required this.onTriggerSOS});

  @override
  State<VoiceDetectionScreen> createState() => _VoiceDetectionScreenState();
}

class _VoiceDetectionScreenState extends State<VoiceDetectionScreen> {
  final _speechToText = stt.SpeechToText();
  final List<String> alertWords = ["help", "emergency", "danger", "fire", "police"];
  String _lastDetectedWord = '';
  bool _isListening = false;
  bool _serviceRunning = false;
  String _statusMessage = 'Initializing...';
  int _errorCount = 0;

  @override
  void initState() {
    super.initState();
    _initSpeechRecognition();
  }

  Future<void> _initSpeechRecognition() async {
    final micGranted = await Permission.microphone.request();
    if (!micGranted.isGranted) {
      setState(() => _statusMessage = 'Microphone permission denied');
      return;
    }

    final isInitialized = await _speechToText.initialize(
      onError: (error) => _handleError(error.errorMsg),
      onStatus: (status) => _updateStatus(status),
    );

    if (isInitialized) {
      setState(() {
        _serviceRunning = true;
        _statusMessage = 'Ready to listen';
      });
      _startListening();
    } else {
      setState(() => _statusMessage = 'Failed to initialize');
    }
  }

  void _handleError(String errorMsg) {
    _errorCount++;
    debugPrint("Error ($_errorCount): $errorMsg");

    if (_errorCount > 5) {
      _stopService();
      setState(() => _statusMessage = 'Too many errors. Service stopped.');
      return;
    }

    setState(() => _statusMessage = 'Error: ${errorMsg.replaceAll('error_', '')}');
    if (_serviceRunning) {
      Future.delayed(const Duration(seconds: 2), () => _startListening());
    }
  }

  void _updateStatus(String status) {
    debugPrint("Status: $status");
    setState(() {
      _isListening = status == 'listening';
      if (status == 'notListening' && _serviceRunning) {
        _statusMessage = 'Paused between listening sessions';
      }
    });
  }

  Future<void> _startListening() async {
    if (!_serviceRunning || _speechToText.isListening) return;

    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            final lastWords = result.recognizedWords.toLowerCase();
            for (final word in alertWords) {
              if (lastWords.contains(word)) {
                setState(() {
                  _lastDetectedWord = word;
                  _statusMessage = 'Detected: $word';
                  _errorCount = 0;
                });
                debugPrint("Detected: $word");
                widget.onTriggerSOS(); // Trigger SOS when an alert word is detected
              }
            }
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 2),
        partialResults: false,
        listenMode: stt.ListenMode.dictation,
      );
      setState(() => _statusMessage = 'Listening...');
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void _stopService() {
    _speechToText.stop();
    setState(() {
      _serviceRunning = false;
      _isListening = false;
      _statusMessage = 'Service stopped';
    });
  }

  void _restartService() {
    _errorCount = 0;
    _initSpeechRecognition();
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
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
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        "Voice Detection",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 50), // Placeholder for symmetry
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: _isListening
                                  ? [Colors.green, Colors.green.shade700]
                                  : [Colors.grey.shade400, Colors.grey.shade600],
                              radius: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening ? Colors.green : Colors.grey)
                                    .withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_off,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusMessage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (_lastDetectedWord.isNotEmpty)
                          Column(
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                "Detected: ${_lastDetectedWord.toUpperCase()}",
                                style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFeatureButton(
                                _serviceRunning ? "Mute" : "Unmute",
                                _serviceRunning ? Icons.volume_off : Icons.volume_up,
                                _serviceRunning ? _stopService : _restartService
                            ),
                            const SizedBox(width: 20),
                            _buildFeatureButton(
                                "Clear",
                                Icons.clear,
                                    () => setState(() => _lastDetectedWord = '')
                            ),
                          ],
                        ),
                      ],
                    ),
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