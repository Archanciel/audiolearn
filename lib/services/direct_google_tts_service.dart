// lib/services/direct_google_tts_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../models/audio_file.dart';
import 'logging_service.dart';

class DirectGoogleTtsService {
  final String _apiKey = 'AIzaSyCcj0KjrlTuj8a6JTdowDMODjZSlTGVGvo';

  // Sanitize filename for Android compatibility
  String _sanitizeFilename(String filename) {
    // Remove or replace problematic characters
    String sanitized = filename
        // Replace quotes with nothing
        .replaceAll('"', '')
        // Replace colon with dash
        .replaceAll(':', ' -')
        // Replace other problematic characters
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll('<', '_')
        .replaceAll('>', '_')
        .replaceAll('|', '_')
        .replaceAll('*', '_')
        .replaceAll('?', '_')
        // Replace multiple spaces with single space
        .replaceAll(RegExp(r'\s+'), ' ')
        // Trim whitespace
        .trim();

    // Ensure filename isn't too long (Android has ~255 char limit)
    if (sanitized.length > 200) {
      sanitized = sanitized.substring(0, 200);
    }

    // Ensure it's not empty after sanitization
    if (sanitized.isEmpty) {
      sanitized = 'audio_${DateTime.now().millisecondsSinceEpoch}';
    }

    logInfo('Original filename: "$filename"');
    logInfo('Sanitized filename: "$sanitized"');

    return sanitized;
  }

  Future<AudioFile?> convertTextToMP3({
    required String text,
    required String customFileName,
    required String mp3FileDirectory,
    required bool isVoiceMan,
  }) async {
    try {
      logInfo('=== CONVERSION MP3 AVEC VOIX SELECTIONNEE ===');
      logInfo('Texte: "$text"');
      logInfo('Fichier original: "$customFileName"');

      // Sanitize the filename
      String sanitizedFileName = _sanitizeFilename(customFileName);

      List<Map<String, String>>? voicesToTry;

      if (isVoiceMan) {
        // Préparer la liste des voix à essayer
        voicesToTry = [
          {'name': 'fr-FR-Standard-B', 'lang': 'fr-FR'}, // man voice
          {'name': 'fr-FR-Standard-A', 'lang': 'fr-FR'}, // woman voice
        ];
      } else {
        voicesToTry = [
          {'name': 'fr-FR-Standard-A', 'lang': 'fr-FR'}, // woman voice
          {'name': 'fr-FR-Standard-B', 'lang': 'fr-FR'}, // man voice
        ];
      }

      AudioFile? result;

      // Essayer chaque voix jusqu'à en trouver une qui marche
      for (final voice in voicesToTry) {
        try {
          logInfo('Tentative avec voix: ${voice['name']}');

          final requestBody = {
            'input': {'text': text},
            'voice': {'languageCode': voice['lang'], 'name': voice['name']},
            'audioConfig': {'audioEncoding': 'MP3', 'sampleRateHertz': 24000},
          };

          final response = await http
              .post(
            Uri.parse(
              'https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
              .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'API request timed out',
                Duration(seconds: 30),
              );
            },
          );

          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            final audioContent = responseData['audioContent'] as String;
            final audioBytes = base64Decode(audioContent);

            logInfo(
              '✅ Succès avec ${voice['name']}: ${audioBytes.length} bytes',
            );

            // Use sanitized filename
            final fileName = sanitizedFileName.endsWith('.mp3')
                ? sanitizedFileName
                : '$sanitizedFileName.mp3';
            final filePath = '$mp3FileDirectory${path.separator}$fileName';

            logInfo('Chemin du fichier: $filePath');

            // Check if directory exists and create if necessary
            final directory = Directory(mp3FileDirectory);
            if (!directory.existsSync()) {
              logInfo('Création du répertoire: $mp3FileDirectory');
              directory.createSync(recursive: true);
            }

            final file = File(filePath);

            // Check if we have write permissions
            try {
              await file.writeAsBytes(audioBytes);
              logInfo('✅ Fichier sauvegardé: $filePath');
            } catch (writeError) {
              logError('Erreur d\'écriture du fichier: $writeError');

              // Try alternative location if write fails
              final fallbackDir = Directory('/storage/emulated/0/Download');
              if (fallbackDir.existsSync()) {
                final fallbackPath =
                    '${fallbackDir.path}${path.separator}$fileName';
                logInfo(
                    'Tentative d\'écriture dans le répertoire de téléchargement: $fallbackPath');

                final fallbackFile = File(fallbackPath);
                await fallbackFile.writeAsBytes(audioBytes);
                logInfo('✅ Fichier sauvegardé dans Download: $fallbackPath');

                result = AudioFile(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  text: text,
                  filePath: fallbackPath,
                  createdAt: DateTime.now(),
                  sizeBytes: audioBytes.length,
                );
              } else {
                rethrow;
              }
            }

            result ??= AudioFile(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text: text,
                filePath: filePath,
                createdAt: DateTime.now(),
                sizeBytes: audioBytes.length,
              );

            break; // Succès ! Sortir de la boucle
          } else {
            _handleHttpError(
              statusCode: response.statusCode,
              responseBody: response.body,
              voiceName: voice['name']!,
            );
          }
        } catch (voiceError) {
          logWarning('Erreur avec ${voice['name']}: $voiceError');
          continue; // Essayer la voix suivante
        }
      }

      if (result == null) {
        throw Exception(
          'Toutes les voix ont échoué - Vérifiez votre connexion internet et votre clé API',
        );
      }

      logInfo('=== CONVERSION MP3 TERMINÉE ===');
      return result;
    } catch (e) {
      logError('Erreur conversion MP3 avec voix', e);
      rethrow;
    }
  }

  // Helper method to handle specific HTTP status codes
  void _handleHttpError({
    required int statusCode,
    required String responseBody,
    required String voiceName,
  }) {
    switch (statusCode) {
      case 400:
        logError(
          'Erreur 400 avec $voiceName: Requête invalide - $responseBody',
        );
        break;
      case 401:
        logError('Erreur 401 avec $voiceName: Clé API invalide ou manquante');
        throw Exception(
          'Clé API Google Cloud invalide. Vérifiez votre configuration.',
        );
      case 403:
        logError(
          'Erreur 403 avec $voiceName: Accès refusé - Quota dépassé ou API désactivée',
        );
        throw Exception(
          'Quota Google Cloud dépassé ou API désactivée. Vérifiez votre compte.',
        );
      case 404:
        logError('Erreur 404 avec $voiceName: Ressource non trouvée');
        break;
      case 429:
        logError('Erreur 429 avec $voiceName: Trop de requêtes');
        throw Exception(
          'Trop de requêtes. Attendez quelques minutes avant de réessayer.',
        );
      case 500:
      case 502:
      case 503:
        logError(
          'Erreur serveur $statusCode avec $voiceName: Problème côté Google',
        );
        break;
      default:
        logWarning('Échec $voiceName: $statusCode - $responseBody');
    }
  }
}
