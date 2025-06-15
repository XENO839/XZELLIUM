/*
// STT temporarily disabled. File retained for future use.
import 'package:speech_to_text/speech_to_text.dart';

class STTService {
  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isListening = false;
  bool get isListening => _isListening;

  String _lastWords = '';
  String get lastWords => _lastWords;

  Function(String)? onSpeechResult;
  Function(bool)? onListeningStateChanged;

  /// Initializes the speech recognition service.
  Future<bool> init() async {
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => print('🛑 STT Error: $error'),
        onStatus: (status) {
          if (status == "done" || status == "notListening") {
            _isListening = false;
            onListeningStateChanged?.call(false);
          }
        },
      );
    } catch (e) {
      print("⚠️ STT Init Failed: $e");
      _isInitialized = false;
    }
    return _isInitialized;
  }

  /// Starts listening with optional live result callback
  Future<void> startListening({Function(String)? onResult}) async {
    if (!_isInitialized) await init();

    if (_isInitialized && !_isListening) {
      _isListening = true;
      onListeningStateChanged?.call(true);

      _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          onResult?.call(_lastWords);
          onSpeechResult?.call(_lastWords);
        },
        listenMode: ListenMode.confirmation,
        partialResults: true,
        cancelOnError: true,
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  /// Stops the speech recognition
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }

  /// Cancels the current session
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }

  /// Resets local data
  void reset() {
    _lastWords = '';
    _isListening = false;
  }

  /// One-shot listener: speaks once and stops
  Future<String> listenOnce() async {
    String finalResult = '';
    await startListening(
      onResult: (text) {
        finalResult = text;
      },
    );

    await Future.delayed(const Duration(seconds: 4)); // Wait for input
    await stopListening();

    return finalResult;
  }
}

/// Global instance to be used app-wide
final sttService = STTService();
*/
