import 'package:integration_test/integration_test.dart';

import 'playlist_1_download_view_integration_test.dart';
import 'playlist_2_download_view_integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  playlistOneDownloadViewIntegrationTest();
  playlistOneTwoloadViewIntegrationTest();
}
