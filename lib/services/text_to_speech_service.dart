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
      _isSpeaking = false;  // Update internal state
      if (_onSpeechComplete != null) {
        _onSpeechComplete!();
      }
    });

    // Set up error handler
    _flutterTts!.setErrorHandler((msg) {
      logError('TTS Error: $msg');
      _isSpeaking = false;  // Update internal state on error
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
    
    // Temporarily disable the completion handler to prevent premature completion
    _flutterTts!.setCompletionHandler(() {
      // Do nothing during multi-part speech
      logInfo('TTS segment completed (ignored during multi-part speech)');
    });
    
    // Split text by { character
    List<String> parts = text.split('{');
    
    try {
      for (int i = 0; i < parts.length; i++) {
        if (!_isSpeaking) {
          // Stop processing if TTS was stopped
          break;
        }
        
        String part = parts[i].trim();
        
        if (part.isNotEmpty) {
          logInfo('Speaking part ${i + 1}: "$part"');
          
          // Speak this part
          final result = await _flutterTts!.speak(part);
          if (result != 1) {
            logWarning('⚠️ Problème avec flutter_tts pour la partie ${i + 1}, code: $result');
          }
          
          // Wait for this segment to complete using a simple time-based approach
          await _waitForSegmentCompletionSimple(part);
        }
        
        // Add actual silence delay if this is not the last part and still speaking
        if (i < parts.length - 1 && _isSpeaking) {
          logInfo('Adding ${silenceDurationSeconds}s actual silence');
          await Future.delayed(Duration(milliseconds: (silenceDurationSeconds * 1000).round()));
        }
      }
    } finally {
      // Always restore the original completion handler
      _flutterTts!.setCompletionHandler(() {
        logInfo('TTS completed - calling completion callback');
        _isSpeaking = false;
        if (_onSpeechComplete != null) {
          _onSpeechComplete!();
        }
      });
      
      // Call completion manually if we finished successfully
      if (_isSpeaking) {
        logInfo('Multi-part speech completed successfully');
        _isSpeaking = false;
        if (_onSpeechComplete != null) {
          _onSpeechComplete!();
        }
      }
    }
  }

  // Simple time-based waiting for segment completion
  Future<void> _waitForSegmentCompletionSimple(String text) async {
    // Estimate speaking time based on text length and speech rate
    // Average speaking rate is about 150-200 words per minute
    int wordCount = text.split(' ').length;
    int estimatedMs = ((wordCount * 60000) / 180).round(); // 180 WPM
    
    // Add minimum wait time and maximum cap
    estimatedMs = estimatedMs.clamp(500, 15000); // 0.5 to 15 seconds
    
    logInfo('Estimated speaking time for segment: ${estimatedMs}ms');
    
    // Wait for the estimated time
    await Future.delayed(Duration(milliseconds: estimatedMs));
    
    // Add a small buffer
    await Future.delayed(Duration(milliseconds: 200));
  }

  Future<void> speak({
    required String text,
    required bool isVoiceMan,
    double silenceDurationSeconds = 2.0, // Default 2 seconds silence
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
        logInfo('Text contains silence markers, processing with actual delays...');
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