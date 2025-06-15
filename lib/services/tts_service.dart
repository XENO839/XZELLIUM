import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _currentlySpeaking = false;
  static Function(bool)? onSpeakingStateChanged;

  /// Initialize TTS with default settings and handlers
  static Future<void> initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);

    _tts.setStartHandler(() {
      _currentlySpeaking = true;
      if (onSpeakingStateChanged != null) {
        onSpeakingStateChanged!(true);
      }
    });

    _tts.setCompletionHandler(() {
      _currentlySpeaking = false;
      if (onSpeakingStateChanged != null) {
        onSpeakingStateChanged!(false);
      }
    });

    _tts.setCancelHandler(() {
      _currentlySpeaking = false;
      if (onSpeakingStateChanged != null) {
        onSpeakingStateChanged!(false);
      }
    });
  }

  /// Speak given text and notify state
  static Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await stop(); // Stop any existing speech
    await _tts.speak(text);
  }

  /// Stop speaking
  static Future<void> stop() async {
    _currentlySpeaking = false;
    await _tts.stop();
    if (onSpeakingStateChanged != null) {
      onSpeakingStateChanged!(false);
    }
  }

  /// Pause speaking
  static Future<void> pause() async {
    _currentlySpeaking = false;
    await _tts.pause();
    if (onSpeakingStateChanged != null) {
      onSpeakingStateChanged!(false);
    }
  }

  /// Whether currently speaking
  static bool isSpeaking() {
    return _currentlySpeaking;
  }

  /// Change language
  static Future<void> setLanguage(String langCode) async {
    await _tts.setLanguage(langCode);
  }

  /// Change pitch
  static Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }

  /// Change speech rate
  static Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  /// Change volume
  static Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume);
  }
}
