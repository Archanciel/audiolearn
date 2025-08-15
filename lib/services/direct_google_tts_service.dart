// lib/services/direct_google_tts_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../models/audio_file.dart';
import 'logging_service.dart';

class DirectGoogleTtsService {
  final String _apiKey = 'AIzaSyCcj0KjrlTuj8a6JTdowDMODjZSlTGVGvo';

  Future<AudioFile?> convertTextToMP3({
    required String text,
    required String customFileName,
    required bool isVoiceMan,
  }) async {
    try {
      logInfo('=== CONVERSION MP3 AVEC VOIX SELECTIONNEE ===');
      logInfo('Texte: "$text"');
      logInfo('Fichier: "$customFileName"');

      // Choisir le dossier
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        logInfo('Sélection annulée');
        return null;
      }

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

            // Sauvegarder le fichier
            final fileName = customFileName.endsWith('.mp3')
                ? customFileName
                : '$customFileName.mp3';
            final filePath = '$selectedDirectory/$fileName';

            final file = File(filePath);
            await file.writeAsBytes(audioBytes);

            logInfo('✅ Fichier sauvegardé: $filePath');

            result = AudioFile(
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
