import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/progress_repository.dart';

const String _soundEnabledKey = 'sound_effects_enabled';

/// StateNotifier to manage sound effects toggle preference in SharedPreferences.
class SoundEnabledNotifier extends StateNotifier<bool> {
  SoundEnabledNotifier(this._ref) : super(true) {
    _loadPreference();
  }

  final Ref _ref;

  void _loadPreference() {
    final prefs = _ref.read(sharedPreferencesProvider);
    state = prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> toggleSound(bool enabled) async {
    state = enabled;
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setBool(_soundEnabledKey, enabled);
  }
}

/// Provider for sound effects enabled state.
final soundEnabledProvider =
    StateNotifierProvider<SoundEnabledNotifier, bool>((ref) {
  return SoundEnabledNotifier(ref);
});

/// Audio service providing Japanese Text-To-Speech (TTS) voice pronunciations.
class AudioService {
  AudioService(this._ref) {
    _initTts();
  }

  final Ref _ref;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('ja-JP');
      await _flutterTts.setSpeechRate(0.45); // Clear beginner pace
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
  }

  /// Speak Japanese text (e.g. character "あ" or word) aloud if sound is enabled.
  Future<void> speak(String text) async {
    final isEnabled = _ref.read(soundEnabledProvider);
    if (!isEnabled) return;

    if (!_isInitialized) {
      await _initTts();
    }

    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {
      // Fallback silent fail if TTS engine unavailable
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}

/// Provider for AudioService.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
