import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:flutter/material.dart';
import '../services/direct_google_tts_service.dart';
import '../services/logging_service.dart';
import '../models/text_to_mp3_audio_file.dart';
import '../services/text_to_speech_service.dart';
import 'warning_message_vm.dart';

class TextToSpeechVM extends ChangeNotifier {
  final TextToSpeechService _ttsService = TextToSpeechService();
  final DirectGoogleTtsService _directGoogleTtsService =
      DirectGoogleTtsService();
  String _inputText = '';
  bool _isConverting = false;
  TextToMp3AudioFile? _currentAudioFile;

  // Silence duration setting
  double _silenceDurationSeconds = 1.0;

  // Getters
  String get inputText => _inputText;

  // Used to indicate if a conversion is in progress
  bool get isConverting => _isConverting;

  TextToMp3AudioFile? get currentAudioFile => _currentAudioFile;
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
    required bool notify,
  }) {
    _inputText = text;

    if (notify) {
      notifyListeners();
    }
  }

  void updateSilenceDuration({
    required double seconds,
  }) {
    _silenceDurationSeconds = seconds;
    notifyListeners();
  }

  Future<void> speakText({
    required bool isVoiceMan,
    required bool clearEndLineChars,
  }) async {
    if (_inputText.trim().isEmpty) return;

    // According to the clearEndLineChars, the invisible new line
    // characters are removed or not. If they are removed, this
    // will avoid that unwanted pauses are created in the generated
    // audio. On Windows, removing them also improves listening the
    // spoken text.
    String inputText = _removeOrNotEndLineChars(
      clearEndLineChars: clearEndLineChars,
    );

    // CRITICAL FIX: Don't modify _inputText directly
    // Create a processed copy instead
    String processedText = _convertSingleBracesToQuoted(
      text: inputText,
      isForMP3Creation: false,
    );

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

  String _convertSingleBracesToQuoted({
    required String text,
    required bool isForMP3Creation,
  }) {
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

      for (int _ in group) {
        result.write('{');
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
    required bool isVoiceMan,
    required bool clearEndLineChars,
  }) async {
    if (_inputText.trim().isEmpty) return;

    _isConverting = true;
    notifyListeners();
    await audioPlayerVMlistenFalse.releaseCurrentAudioFile();

    // According to the clearEndLineChars, the invisible new line
    // characters are removed or not. If they are not removed, this
    // will avoid that unwanted pauses are created in the generated
    // audio.
    String inputText = _removeOrNotEndLineChars(
      clearEndLineChars: clearEndLineChars,
    );

    try {
      TextToMp3AudioFile? audioFile;

      // CRITICAL FIX: Don't modify _inputText directly
      // Create a processed copy instead
      String processedText = _convertSingleBracesToQuoted(
        text: inputText,
        isForMP3Creation: true,
      );

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

  /// According to the clearEndLineChars, the invisible new line characters are removed
  /// or not. If they are not removed, this will avoid that unwanted pauses are created
  /// in the generated audio. On Windows, removing them also improves listening the spoken
  /// text.
  String _removeOrNotEndLineChars({
    required bool clearEndLineChars,
  }) {
    if (clearEndLineChars) {
      // Remove line break characters
      return _inputText.replaceAll(RegExp(r'(\r\n|\r|\n)'), ' ');
    } else {
      return _inputText;
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
