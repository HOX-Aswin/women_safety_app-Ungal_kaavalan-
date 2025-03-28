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
      appBar: AppBar(title: const Text("Voice Detection")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isListening ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic,
                size: 48,
                color: _isListening ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Text(_statusMessage, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
            if (_lastDetectedWord.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Text("Last detected word:"),
                  Text(
                    _lastDetectedWord,
                    style: const TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: _serviceRunning ? _stopService : _restartService,
                  child: Text(_serviceRunning ? "Stop" : "Start"),
                ),
                const SizedBox(width: 20),
                FilledButton(
                  onPressed: () => setState(() => _lastDetectedWord = ''),
                  child: const Text("Clear"),
                  style: FilledButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
