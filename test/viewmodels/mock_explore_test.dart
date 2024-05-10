import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import 'mock_explore_test.mocks.dart';

class YoutubeExplode extends Mock implements yt.YoutubeExplode {}

class YoutubeVideo extends Mock implements yt.Video {}

late MockYoutubeExplode mockYoutubeExplode;
late MockYoutubeVideo mockYoutubeVideo;
late MockVideoClient mockVideoClient;

// Executing dart run build_runner build generates the mock
// classes in the test/viewmodels/mock_explore_test.mocks.dart
// file
@GenerateMocks([YoutubeExplode, YoutubeVideo, yt.VideoClient])
void main() {
  setUp(() {
    mockYoutubeExplode = MockYoutubeExplode();
    mockYoutubeVideo = MockYoutubeVideo();
    mockVideoClient = MockVideoClient();

    // Stubbing the 'videos' property.
    //
    // This is necessary because the 'videos' property is
    // a getter and cannot be stubbed directly:
    // mockYoutubeExplode.videos.get(any) will not work.
    // Instead, we stub the getter to return a mock of the
    // VideoClient class, which has a 'get' method that
    // can be stubbed.
    when(mockYoutubeExplode.videos).thenReturn(mockVideoClient);
  });

  test('Test getVideo functionality', () async {
    // Assuming 'get' is a method in the mockVideoClient.
    // Possible because we stubbed the 'videos' property in
    // the setUp method above with
    // when(mockYoutubeExplode.videos).thenReturn(mockVideoClient);
    when(mockVideoClient.get(any)).thenAnswer((_) async => mockYoutubeVideo);

    // Your test code here
    yt.Video result = await mockYoutubeExplode.videos.get('some_video_id');
    expect(result, isA<yt.Video>());
    expect(result, equals(mockYoutubeVideo));
    // Additional assertions as needed
  });
}
