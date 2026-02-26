import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  /// Speak a single word (slightly slower, clearer).
  Future<void> speakWord(String word) async {
    await init();
    await _tts.setSpeechRate(0.35);
    await _tts.speak(word);
  }

  /// Speak a full sentence (normal pace).
  Future<void> speakSentence(String sentence) async {
    await init();
    await _tts.setSpeechRate(0.45);
    await _tts.speak(sentence);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
