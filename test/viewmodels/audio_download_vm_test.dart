import 'package:audiolearn/services/settings_data_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';

import '../services/mock_shared_preferences.dart';

void main() {
  group('AudioDownloadVM video description', () {
    test('Test extract video chapters time position', () async {
      WarningMessageVM warningMessageVM = WarningMessageVM();
      AudioDownloadVM audioDownloadVM = AudioDownloadVM(
        warningMessageVM: warningMessageVM,
        settingsDataService: SettingsDataService(
            sharedPreferences: MockSharedPreferences(),
            isTest: true),
      );

      String videoDescription = '''Ma chaîne YouTube principale
  https://www.youtube.com/@LeFuturologue


  ME SOUTENIR FINANCIÈREMENT :

  Sur Tipeee
  https://fr.tipeee.com/le-futurologue
  Sur PayPal
  https://www.paypal.com/donate/?hosted_button_id=BBXFGSM5D5WQS
  Sur Patreon
  https://patreon.com/LeFuturologue


  MES VIDÉOS COURTES :

  Sur YouTube 
  https://youtube.com/@LeFuturologue/shorts
  Sur Instagram
  https://www.instagram.com/le.futurologue/
  Sur TikTok
  https://www.tiktok.com/@le.futurologue


  TIME CODE :

  0:00 Introduction
  1:37 Qui es-tu ?
  3:29 Les IA vont-elles tous nous mettre au chômage ?
  21:01 Faut-il mettre les IA en open source ? 
  48:05 Comment fonctionne les agents ?
  1:14:31 Définition de l’IA autonome, de l’IA générale et de la super IA
  1:41:23 Que manque-t-il pour avoir une AGI ?
  1:57:23 À quel point faut-il avoir peur de L’IA ?
  2:04:36 Les meilleurs arguments de ceux qui ne croient pas aux risques existentiels des AGI 
  2:11:48 Y aura-t-il plusieurs AGI ?
  2:14:06 Est-ce que l’explosion d’intelligence sera rapide ? 
  2:22:37 Quels impacts aurait une IA qui devient consciente ?
  2:53:18 Quelle est la probabilité qu’on arrive à aligner une AGI avant qu’on en crée une ?
  3:09:54 Ressources pour aller plus loin
  3:11:57 Un message pour l’humanité 


  RESSOURCES MENTIONNÉES :

  La chaîne YouTube de Jérémy
  https://youtube.com/@suboptimalchannel9704
  Le Twitter de Jérémy
  https://twitter.com/suboptimalc?s=21&t=KiEIZQwoZSOhseL0LUGLpg
  L’organisation « EffiSciences »
  https://www.effisciences.org/

  ChatGPT''';

      Map<String, String> expectedChapters = {
        'Introduction': '0:00',
        'Qui es-tu ?': '1:37',
        'Les IA vont-elles tous nous mettre au chômage ?': '3:29',
        'Faut-il mettre les IA en open source ? ': '21:01',
        'Comment fonctionne les agents ?': '48:05',
        'Définition de l’IA autonome, de l’IA générale et de la super IA':
            '1:14:31',
        'Que manque-t-il pour avoir une AGI ?': '1:41:23',
        'À quel point faut-il avoir peur de L’IA ?': '1:57:23',
        'Les meilleurs arguments de ceux qui ne croient pas aux risques existentiels des AGI ':
            '2:04:36',
        'Y aura-t-il plusieurs AGI ?': '2:11:48',
        'Est-ce que l’explosion d’intelligence sera rapide ? ': '2:14:06',
        'Quels impacts aurait une IA qui devient consciente ?': '2:22:37',
        'Quelle est la probabilité qu’on arrive à aligner une AGI avant qu’on en crée une ?':
            '2:53:18',
        'Ressources pour aller plus loin': '3:09:54',
        'Un message pour l’humanité ': '3:11:57',
      };

      Map<String, String> chapters =
          audioDownloadVM.getVideoDescriptionChapters(
        videoDescription: videoDescription,
      );

      expect(chapters, expectedChapters);
    });
  });
}
