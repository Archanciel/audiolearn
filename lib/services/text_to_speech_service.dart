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

  // Track if we're in multi-part speech mode
  bool _isMultiPartSpeech = false;

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
      
      // Only call completion if we're not in multi-part speech mode
      if (!_isMultiPartSpeech) {
        _isSpeaking = false;  // Update internal state
        if (_onSpeechComplete != null) {
          _onSpeechComplete!();
        }
      }
    });

    // Set up error handler
    _flutterTts!.setErrorHandler((msg) {
      logError('TTS Error: $msg');
      _isSpeaking = false;  // Update internal state on error
      _isMultiPartSpeech = false;
      if (_onSpeechComplete != null) {
        _onSpeechComplete!();
      }
    });

    // Set up start handler
    _flutterTts!.setStartHandler(() {
      logInfo('TTS started speaking');
      if (!_isMultiPartSpeech) {
        _isSpeaking = true;
      }
    });

    // Set up cancel handler
    _flutterTts!.setCancelHandler(() {
      logInfo('TTS cancelled');
      _isSpeaking = false;
      _isMultiPartSpeech = false;
      if (_onSpeechComplete != null) {
        _onSpeechComplete!();
      }
    });
  }

  // Method to set completion callback from ViewModel
  void setCompletionHandler(Function() onComplete) {
    _onSpeechComplete = onComplete;
  }

  // Process text with silence markers using async approach
  Future<void> _speakTextWithSilence({
    required String text,
    required bool isVoiceMan,
    required double silenceDurationSeconds,
  }) async {
    logInfo('Processing text with silence markers: "$text"');
    
    _isMultiPartSpeech = true;
    
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
          
          // Speak this part and wait for completion
          await _speakPartAndWait(part);
        }
        
        // Add silence if this is not the last part and TTS is still active
        if (i < parts.length - 1 && _isSpeaking) {
          logInfo('Adding ${silenceDurationSeconds}s silence');
          await Future.delayed(Duration(milliseconds: (silenceDurationSeconds * 1000).round()));
        }
      }
    } finally {
      _isMultiPartSpeech = false;
      
      // Call completion handler manually at the end
      if (_isSpeaking) {
        logInfo('Multi-part speech completed');
        _isSpeaking = false;
        if (_onSpeechComplete != null) {
          _onSpeechComplete!();
        }
      }
    }
  }

  // Speak a single part and wait for it to complete
  Future<void> _speakPartAndWait(String text) async {
    bool partCompleted = false;
    
    // Create a one-time completion handler for this part
    void partCompletionHandler() {
      partCompleted = true;
    }
    
    // Temporarily override the completion handler
    _flutterTts!.setCompletionHandler(partCompletionHandler);
    
    // Speak the text
    final result = await _flutterTts!.speak(text);
    if (result != 1) {
      logWarning('⚠️ Problème avec flutter_tts, code: $result');
      partCompleted = true; // Assume completed on error
    }
    
    // Wait for completion with timeout
    int waitTime = 0;
    while (!partCompleted && waitTime < 10000 && _isSpeaking) { // 10 second timeout
      await Future.delayed(Duration(milliseconds: 100));
      waitTime += 100;
    }
    
    // Restore the original completion handler
    _flutterTts!.setCompletionHandler(() {
      logInfo('TTS completed - calling completion callback');
      
      // Only call completion if we're not in multi-part speech mode
      if (!_isMultiPartSpeech) {
        _isSpeaking = false;
        if (_onSpeechComplete != null) {
          _onSpeechComplete!();
        }
      }
    });
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
      _isMultiPartSpeech = false;

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
        logInfo('Text contains silence markers, processing with pauses...');
        await _speakTextWithSilence(
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
      _isMultiPartSpeech = false;

      // Dernier recours : essayer avec voix par défaut
      try {
        logWarning('Dernier recours avec voix système...');
        _isSpeaking = true; // Set again for fallback attempt
        await _flutterTts!.setLanguage("en-US"); // Anglais par défaut
        
        if (text.contains('{')) {
          await _speakTextWithSilence(
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
        _isMultiPartSpeech = false;
        rethrow;
      }
    }
  }

  Future<void> stop() async {
    try {
      _isSpeaking = false; // Set state to false when stopping
      _isMultiPartSpeech = false;
      await _directAudioPlayer?.stop();
      await _flutterTts?.stop();
      logInfo('Lecture arrêtée (tous systèmes)');
    } catch (e) {
      logError('Erreur lors de l\'arrêt', e);
      _isSpeaking = false; // Ensure state is reset even on error
      _isMultiPartSpeech = false;
    }
  }

  void dispose() {
    _isSpeaking = false;
    _isMultiPartSpeech = false;
    _directAudioPlayer?.dispose();
    _flutterTts = null;
  }
}