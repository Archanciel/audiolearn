import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:flutter/material.dart';
import '../services/direct_google_tts_service.dart';
import '../services/logging_service.dart';
import '../models/audio_file.dart';
import '../services/text_to_speech_service.dart';
import 'warning_message_vm.dart';

class TextToSpeechVM extends ChangeNotifier {
  final TextToSpeechService _ttsService = TextToSpeechService();
  final DirectGoogleTtsService _directGoogleTtsService =
      DirectGoogleTtsService();
  String _inputText = '';
  bool _isConverting = false;
  AudioFile? _currentAudioFile;

  // Silence duration setting
  double _silenceDurationSeconds = 1.0;

  // Getters
  String get inputText => _inputText;
  bool get isConverting => _isConverting;
  AudioFile? get currentAudioFile => _currentAudioFile;
  double get silenceDurationSeconds => _silenceDurationSeconds;

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  TextToSpeechVM() {
    // Set up TTS completion listener
    _setupTtsListeners();
  }

  void _setupTtsListeners() {
    // This will be called when TTS completes naturally
    _ttsService.setCompletionHandler(() {
      logInfo('TTS completion detected in ViewModel');
      _isSpeaking = false;
      notifyListeners();
    });
  }

  void updateInputText({
    required String text,
  }) {
    _inputText = text;
    notifyListeners();
  }

  void updateSilenceDuration({
    required double seconds,
  }) {
    _silenceDurationSeconds = seconds;
    notifyListeners();
  }

  Future<void> speakText({
    bool isVoiceMan = true,
  }) async {
    if (_inputText.trim().isEmpty) return;

    _isSpeaking = true;
    notifyListeners();

    try {
      // Start speaking with silence support
      await _ttsService.speak(
        text: _inputText,
        isVoiceMan: isVoiceMan,
        silenceDurationSeconds: _silenceDurationSeconds,
      );

      // The _isSpeaking state will be managed by:
      // 1. TTS completion callback (most reliable)
      // 2. TTS error callback
      // 3. Manual stop via stopSpeaking() method
    } catch (e) {
      logInfo('Erreur lors de la lecture: $e');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> convertTextToMP3WithFileName({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required WarningMessageVM warningMessageVMlistenFalse,
    required String fileName,
    required String mp3FileDirectory,
    bool isVoiceMan = true,
  }) async {
    if (_inputText.trim().isEmpty) return;

    _isConverting = true;
    notifyListeners();
    await audioPlayerVMlistenFalse.releaseCurrentAudioFile();

    try {
      AudioFile? audioFile;

      audioFile = await _directGoogleTtsService.convertTextToMP3(
        warningMessageVMlistenFalse: warningMessageVMlistenFalse,
        text: _inputText,
        customFileName: fileName,
        mp3FileDirectory: mp3FileDirectory,
        isVoiceMan: isVoiceMan,
        silenceDurationSeconds: _silenceDurationSeconds,
      );

      if (audioFile != null) {
        _currentAudioFile = audioFile;
        notifyListeners();
      }
    } catch (e) {
      logInfo('Erreur lors de la conversion: $e');
      rethrow;
    } finally {
      _isConverting = false;
      notifyListeners();
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _ttsService.stop();
      logInfo('Lecture arrêtée');
    } catch (e) {
      logInfo('Erreur lors de l\'arrêt: $e');
    } finally {
      // Always set speaking to false when stop is called
      _isSpeaking = false;
      notifyListeners();
    }
  }
}
