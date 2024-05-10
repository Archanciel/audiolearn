import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/viewmodels/single_video_audio_download_vm.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/mock_shared_preferences.dart';
import 'custom_mock_youtube_explode.dart';

void main() {
  group('SingleVideoAudioDownloadVM Tests', () {
    late SingleVideoAudioDownloadVM singleVideoAudioDownloadVM;
    late CustomMockYoutubeExplode mockYoutubeExplode;

    setUp(() async {
      mockYoutubeExplode = CustomMockYoutubeExplode();
      singleVideoAudioDownloadVM = SingleVideoAudioDownloadVM(
          youtubeExplode: mockYoutubeExplode,
          settingsDataService: SettingsDataService(
            sharedPreferences: MockSharedPreferences(),
            isTest: true,
          ));
    });

    test('Test download failure when the Youtube service returns an error',
        () async {
      Playlist singleVideoTargetPlaylist = Playlist(
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
      );

      expect(
        await singleVideoAudioDownloadVM.downloadSingleVideoAudio(
          videoUrl: 'invalid_url',
          singleVideoTargetPlaylist: singleVideoTargetPlaylist,
        ),
        false,
      );
    });

    // Autres tests...
  });
}
