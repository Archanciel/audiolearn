import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'logging_service.dart';

class TextToSpeechService {
  AudioPlayer? _directAudioPlayer;
  FlutterTts? _flutterTts;

  // Track speaking state internally
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  // Completion callback
  Function()? _onSpeechComplete;

  TextToSpeechService() {
    _directAudioPlayer = AudioPlayer();
    _initializeTts();
  }

  // Initialize TTS with all handlers
  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();

    // Set up completion handler
    _flutterTts!.setCompletionHandler(() {
      logInfo('TTS completed - calling completion callback');
      _isSpeaking = false; // Update internal state
      if (_onSpeechComplete != null) {
        _onSpeechComplete!();
      }
    });

    // Set up error handler
    _flutterTts!.setErrorHandler((msg) {
      logError('TTS Error: $msg');
      _isSpeaking = false; // Update internal state on error
      if (_onSpeechComplete != null) {
        _onSpeechComplete!();
      }
    });

    // Set up start handler
    _flutterTts!.setStartHandler(() {
      logInfo('TTS started speaking');
      _isSpeaking = true;
    });

    // Set up cancel handler
    _flutterTts!.setCancelHandler(() {
      logInfo('TTS cancelled');
      _isSpeaking = false;
      if (_onSpeechComplete != null) {
        _onSpeechComplete!();
      }
    });
  }

  // Method to set completion callback from ViewModel
  void setCompletionHandler(Function() onComplete) {
    _onSpeechComplete = onComplete;
  }

  // Speak text with actual silence delays between segments
  Future<void> _speakTextWithActualSilence({
    required String text,
    required bool isVoiceMan,
    required double silenceDurationSeconds,
  }) async {
    logInfo('Processing text with actual silence delays: "$text"');

    final originalHandler = _onSpeechComplete;

    _flutterTts!.setCompletionHandler(() {
      logInfo('TTS segment completed (ignored during multi-part speech)');
    });

    // Split text by { character
    List<String> parts = text.split('{');

    try {
      for (int i = 0; i < parts.length; i++) {
        if (!_isSpeaking) {
          logInfo('TTS stopped, breaking at part ${i + 1}');
          break;
        }

        String part = parts[i].trim();

        if (part.isNotEmpty) {
          logInfo('Speaking part ${i + 1}: "$part"');

          final result = await _flutterTts!.speak(part);
          if (result != 1) {
            logWarning(
                '⚠️ Problème avec flutter_tts pour la partie ${i + 1}, code: $result');
          }

          await _waitForSegmentCompletionSimple(part);
        }

        // CRITICAL FIX: Only add silence delay once per group of consecutive empty segments
        if (i < parts.length - 1 && _isSpeaking) {
          // Check if we should add silence delay
          bool shouldAddSilence = false;

          if (part.isNotEmpty) {
            // Always add silence after non-empty segments
            shouldAddSilence = true;
          } else {
            // For empty segments, only add silence if the NEXT segment is non-empty
            // This prevents multiple silence delays for consecutive braces
            for (int j = i + 1; j < parts.length; j++) {
              if (parts[j].trim().isNotEmpty) {
                shouldAddSilence = true;
                break;
              }
            }
          }

          if (shouldAddSilence) {
            logInfo('Adding ${silenceDurationSeconds}s actual silence');
            await Future.delayed(Duration(
                milliseconds: (silenceDurationSeconds * 1000).round()));
          } else {
            logInfo('Skipping silence delay for consecutive empty segment');
          }
        }
      }
    } finally {
      _flutterTts!.setCompletionHandler(() {
        logInfo('TTS completed - calling completion callback');
        _isSpeaking = false;
        if (originalHandler != null) {
          originalHandler();
        }
      });

      if (_isSpeaking) {
        logInfo('Multi-part speech completed - triggering completion');
        _isSpeaking = false;
        if (originalHandler != null) {
          originalHandler();
        }
      }
    }
  }

  // Simple time-based waiting for segment completion
  Future<void> _waitForSegmentCompletionSimple(String text) async {
    // Skip timing estimation for empty or whitespace-only segments
    if (text.trim().isEmpty) {
      logInfo('Skipping timing estimation for empty segment');
      return;
    }

    // Estimate speaking time based on text length and speech rate
    int wordCount = text.split(' ').length;
    int characterCount = text.length;

    // Use both word count and character count for better estimation
    // THE multiplier VALUE SOLVES A DURABLE PROBLEM THE IA WAS NOT
    // ABLE TO FIX: THE TTS OF FLUTTER_TTS IS MUCH BETTER NOW.
    const int multiplier = 47000;
    int wordBasedMs = ((wordCount * multiplier) / 180).round(); // 180 WPM
    int charBasedMs =
        ((characterCount * multiplier) / 900).round(); // ~15 chars per second

    // Take the higher of the two estimates for safety
    int estimatedMs = wordBasedMs > charBasedMs ? wordBasedMs : charBasedMs;

    // Remove the artificial cap - let longer text take the time it needs
    // Add minimum wait time but no maximum cap
    estimatedMs = estimatedMs < 1000 ? 1000 : estimatedMs; // Minimum 1 second

    // Add extra buffer for longer segments to account for TTS processing delays
    if (wordCount > 50) {
      estimatedMs += 2000; // Extra 2 seconds for very long segments
    } else if (wordCount > 20) {
      estimatedMs += 1000; // Extra 1 second for medium segments
    }

    logInfo('Segment stats - Words: $wordCount, Chars: $characterCount');
    logInfo(
        'Estimated speaking time: ${estimatedMs}ms (${(estimatedMs / 1000).toStringAsFixed(1)}s)');

    // Wait for the estimated time
    await Future.delayed(Duration(milliseconds: estimatedMs));

    // Add a buffer, but smaller for longer segments to avoid excessive delays
    int bufferMs = wordCount > 30 ? 300 : 500;
    await Future.delayed(Duration(milliseconds: bufferMs));

    logInfo('Finished waiting for segment completion');
  }

  Future<void> speak({
    required String text,
    required bool isVoiceMan,
    required double silenceDurationSeconds,
  }) async {
    logInfo('=== FALLBACK: LECTURE AVEC FLUTTER_TTS ===');

    try {
      // Initialiser flutter_tts si nécessaire
      _flutterTts ??= FlutterTts();

      // Set speaking state to true at start
      _isSpeaking = true;

      // Each voice is a Map containing at least these keys: name, locale
      // - Windows (UWP voices) only: gender, identifier
      // - iOS, macOS only: quality, gender, identifier
      // - Android only: quality, latency, network_required, features
      final List<dynamic> dynamicVoices = await _flutterTts!.getVoices;
      final List<Map<String, String>> voices = dynamicVoices
          .map((voice) => Map<String, String>.from(voice as Map))
          .toList();

      final List<Map<String, String>> frenchVoices =
          voices.where((voice) => voice['locale'] == "fr-FR").toList();

      Map<String, String>? selectedVoice; // man voice
      double voiceSpeed; // man voice speed

      if (Platform.isWindows) {
        if (isVoiceMan) {
          selectedVoice = frenchVoices[2]; // man voice
          voiceSpeed = 0.5; // man voice speed
        } else {
          selectedVoice = frenchVoices[0]; // woman voice
          voiceSpeed = 0.6; // woman voice speed
        }
      } else {
        if (isVoiceMan) {
          selectedVoice = frenchVoices[10]; // man voice
          voiceSpeed = 0.5; // man voice speed
        } else {
          selectedVoice = frenchVoices[5]; // woman voice
          voiceSpeed = 0.6; // woman voice speed
        }
      }

      await _flutterTts!.setVoice(selectedVoice);

      // Configuration française
      await _flutterTts!.setSpeechRate(voiceSpeed);
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);

      logInfo('Configuration flutter_tts terminée');
      logInfo('Lecture du texte: "$text"');

      // Check if text contains silence markers
      if (text.contains('{')) {
        logInfo(
            'Text contains silence markers, processing with actual delays...');
        await _speakTextWithActualSilence(
          text: text,
          isVoiceMan: isVoiceMan,
          silenceDurationSeconds: silenceDurationSeconds,
        );
      } else {
        // Regular speech without silence markers
        final result = await _flutterTts!.speak(text);

        if (result == 1) {
          logInfo('✅ Lecture flutter_tts lancée avec succès');
        } else {
          logWarning('⚠️ Problème avec flutter_tts, code: $result');
          _isSpeaking = false; // Reset state if speak failed
        }
      }
    } catch (e) {
      logError('Erreur avec flutter_tts', e);
      _isSpeaking = false; // Reset state on error

      // Dernier recours : essayer avec voix par défaut
      try {
        logWarning('Dernier recours avec voix système...');
        _isSpeaking = true; // Set again for fallback attempt
        await _flutterTts!.setLanguage("en-US"); // Anglais par défaut

        if (text.contains('{')) {
          await _speakTextWithActualSilence(
            text: text,
            isVoiceMan: isVoiceMan,
            silenceDurationSeconds: silenceDurationSeconds,
          );
        } else {
          await _flutterTts!.speak(text);
        }
        logInfo('✅ Lecture avec voix anglaise système');
      } catch (finalError) {
        logError('Toutes les options TTS ont échoué', finalError);
        _isSpeaking = false; // Reset state on final error
        rethrow;
      }
    }
  }

  Future<void> stop() async {
    try {
      _isSpeaking = false; // Set state to false when stopping
      await _directAudioPlayer?.stop();
      await _flutterTts?.stop();
      logInfo('Lecture arrêtée (tous systèmes)');
    } catch (e) {
      logError('Erreur lors de l\'arrêt', e);
      _isSpeaking = false; // Ensure state is reset even on error
    }
  }

  void dispose() {
    _isSpeaking = false;
    _directAudioPlayer?.dispose();
    _flutterTts = null;
  }
}
