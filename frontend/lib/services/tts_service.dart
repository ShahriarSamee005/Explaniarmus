// tts_service.dart
// Text-to-speech service using flutter_tts package
// Place this in: frontend/lib/services/tts_service.dart
//
// SETUP: Add this to your pubspec.yaml under dependencies:
//   flutter_tts: ^4.0.2

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  // -------------------------------------------------------------------
  // Initialize TTS settings — call this once in result_screen.dart
  // -------------------------------------------------------------------
  Future<void> init() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);  // slightly slower = clearer for academic text
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // Update _isPlaying state automatically when speech finishes
    _tts.setCompletionHandler(() {
      _isPlaying = false;
    });

    _tts.setCancelHandler(() {
      _isPlaying = false;
    });

    _tts.setErrorHandler((error) {
      _isPlaying = false;
    });
  }

  // -------------------------------------------------------------------
  // Speak the full output aloud
  // Combines explanation + summary + steps into one readable script
  // -------------------------------------------------------------------
  Future<void> speakFullResult({
    required String simpleExplanation,
    required List<String> summary,
    required List<String> steps,
  }) async {
    if (_isPlaying) {
      await stop();
      return; // first tap stops, second tap plays
    }

    final StringBuffer script = StringBuffer();

    script.writeln('Simple Explanation.');
    script.writeln(simpleExplanation);
    script.writeln('');

    script.writeln('Key Points.');
    for (int i = 0; i < summary.length; i++) {
      script.writeln('Point ${i + 1}. ${summary[i]}');
    }
    script.writeln('');

    script.writeln('Steps and Tasks.');
    for (int i = 0; i < steps.length; i++) {
      script.writeln('Step ${i + 1}. ${steps[i]}');
    }

    _isPlaying = true;
    await _tts.speak(script.toString());
  }

  // -------------------------------------------------------------------
  // Stop playback
  // -------------------------------------------------------------------
  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
  }

  // -------------------------------------------------------------------
  // Dispose — call this in result_screen dispose()
  // -------------------------------------------------------------------
  Future<void> dispose() async {
    await _tts.stop();
    _isPlaying = false;
  }
}