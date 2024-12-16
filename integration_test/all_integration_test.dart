import 'package:integration_test/integration_test.dart';

import 'audio_download_vm_integration_test.dart';
import 'audio_player_view_integration_test.dart';
import 'playlist_1_download_view_integration_test.dart';
import 'playlist_2_download_view_integration_test.dart';
import 'sort_filter_integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  playlistDownloadViewSortFilterIntegrationTest();
  audioPlayerViewSortFilterIntegrationTest();
  playlistOneDownloadViewIntegrationTest();
  playlistTwoDownloadViewIntegrationTest();
  audioPlayerViewIntegrationTest();
  audioDownloadVMIntegrationTest();
}
