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

    // CRITICAL FIX: Don't modify _inputText directly
    // Create a processed copy instead
    String processedText = _convertSingleBracesToQuoted(_inputText);

    _isSpeaking = true;
    notifyListeners();

    try {
      // Start speaking with silence support
      await _ttsService.speak(
        text: processedText, // Use processedText, not _inputText
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

  String _convertSingleBracesToQuoted(String text) {
    if (!text.contains('{')) {
      return text;
    }

    StringBuffer result = StringBuffer();

    // First, identify all brace sequences
    List<int> bracePositions = [];
    for (int i = 0; i < text.length; i++) {
      if (text[i] == '{') {
        bracePositions.add(i);
      }
    }

    // Group consecutive brace positions
    List<List<int>> braceGroups = [];
    if (bracePositions.isNotEmpty) {
      List<int> currentGroup = [bracePositions[0]];

      for (int i = 1; i < bracePositions.length; i++) {
        if (bracePositions[i] == bracePositions[i - 1] + 1) {
          // Consecutive brace
          currentGroup.add(bracePositions[i]);
        } else {
          // Non-consecutive, start new group
          braceGroups.add(currentGroup);
          currentGroup = [bracePositions[i]];
        }
      }
      braceGroups.add(currentGroup); // Add the last group
    }

    // Build result string
    int textIndex = 0;

    for (List<int> group in braceGroups) {
      // Add text before this brace group
      while (textIndex < group[0]) {
        result.write(text[textIndex]);
        textIndex++;
      }

      // Handle the brace group
      if (group.length == 1) {
        for (int i = 0; i <= 1; i++) {
          result.write('{');
        }
      } else {
        // Multiple consecutive braces - keep as is
        for (int _ in group) {
          result.write('{');
        }
      }

      textIndex += group.length;
    }

    // Add remaining text after last brace group
    while (textIndex < text.length) {
      result.write(text[textIndex]);
      textIndex++;
    }

    return result.toString();
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

      // CRITICAL FIX: Don't modify _inputText directly
      // Create a processed copy instead
      String processedText = _convertSingleBracesToQuoted(_inputText);

      audioFile = await _directGoogleTtsService.convertTextToMP3(
        warningMessageVMlistenFalse: warningMessageVMlistenFalse,
        text: processedText, // Use processedText, not _inputText
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
