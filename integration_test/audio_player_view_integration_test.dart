import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/logger.dart';
import 'package:matcher/matcher.dart' as matcher;

import 'package:audiolearn/models/comment.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/utils/date_time_parser.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/utils/duration_expansion.dart';
import 'package:audiolearn/views/widgets/comment_add_edit_dialog.dart';
import 'package:audiolearn/views/widgets/comment_list_add_dialog.dart';
import 'package:audiolearn/views/widgets/playlist_comment_list_dialog.dart';
import 'package:audiolearn/views/widgets/set_value_to_target_dialog.dart';
import 'package:path/path.dart' as path;
import 'package:audiolearn/constants.dart';
import 'package:audiolearn/utils/dir_util.dart';

import 'integration_test_util.dart';
import 'sort_filter_integration_test.dart';

enum AudioPositionModification {
  backward10sec,
  backward1min,
  forward10sec,
  forward1min,
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  audioPlayerViewSortFilterIntegrationTest();

  final Logger logger = Logger();
  
  group('''Play/pause/start/end tests, clicking on audio title to open
         AudioPlayerView.''', () {
    testWidgets('Check play/pause button conversion only.', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'morning _ cinematic video';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the lastly downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the currently paused audio

      // First, get the lastly downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify that the play/pause button displayed when a picture
      // is present is not displayed.
      Finder playPauseButtonFinder = find.byKey(
        const Key('picture_displayed_play_pause_button_key'),
      );
      expect(playPauseButtonFinder, findsNothing);

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Verify if the play button changes to pause button
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Verify that the selected playlist title is displayed
      Text selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(
        selectedPlaylistTitleText.data,
        audioPlayerSelectedPlaylistTitle,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Play audio during 5 seconds and then pause it. Then click on |<, and
           then on |> button''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'morning _ cinematic video';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the lastly downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the currently not played audio

      // First, get the lastly downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now verify if the displayed audio position and remaining
      // duration are correct

      Text audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      expect(audioPositionText.data, '0:00');

      Text audioRemainingDurationText = tester.widget<Text>(
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));
      expect(audioRemainingDurationText.data, '0:59');

      // Verify that the selected playlist title is displayed
      Text selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(
        selectedPlaylistTitleText.data,
        audioPlayerSelectedPlaylistTitle,
      );

      IntegrationTestUtil.verifyAudioDataElementsUpdatedInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: 0,
        audioTitle: lastDownloadedAudioTitle,
        audioPositionSeconds: 0,
        isPaused: true,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        audioPausedDateTime: null,
      );

      // Now play the audio and wait 5 seconds
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Not tapping on pause button to pause the audio. This is done
      // after the verifyAudioDataElementsUpdatedInPlaylistJsonFile()
      // method called below.

      // Since the playlist json file is updated every 30 seconds,
      // after playing during 5 seconds, it will not be updated.
      IntegrationTestUtil.verifyAudioDataElementsUpdatedInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: 0,
        audioTitle: lastDownloadedAudioTitle,
        audioPositionSeconds: 0,
        isPaused: false,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
        audioPausedDateTime: null,
      );

      // Verify if the play button changed to pause button
      final Finder pauseIconFinder = find.byIcon(Icons.pause);
      expect(pauseIconFinder, findsOneWidget);

      // Now pause the audio
      await tester.tap(pauseIconFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      DateTime pausedAudioAtDateTime = DateTime.now();

      IntegrationTestUtil.verifyAudioDataElementsUpdatedInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: 0,
        audioTitle: lastDownloadedAudioTitle,
        audioPositionSeconds: 5,
        isPaused: true,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
        audioPausedDateTime: pausedAudioAtDateTime,
      );

      await Future.delayed(const Duration(seconds: 1));

      audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      Duration audioPositionDurationAfterPauseActual =
          DateTimeParser.parseMMSSDuration(audioPositionText.data ?? '')!;

      audioRemainingDurationText = tester.widget<Text>(
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));
      Duration audioRemainingDurationAfterPauseActual =
          DateTimeParser.parseMMSSDuration(
              audioRemainingDurationText.data ?? '')!;

      Duration sumDurations = audioPositionDurationAfterPauseActual +
          audioRemainingDurationAfterPauseActual;

      // Check if the sum of the actual audio position duration
      // and the actual audio remaining duration is equal to 58 or
      // 59 seconds which is the total duration of the listened
      // audio minus 1 second. Checking the value of the audio
      // position and remaining duration is not safe.
      expect(sumDurations >= const Duration(seconds: 58), isTrue);
      expect(sumDurations <= const Duration(seconds: 59), isTrue);

      // Verify if the pause button changed back to play button
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Now go to the end of the audio
      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      IntegrationTestUtil.verifyAudioDataElementsUpdatedInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: 0,
        audioTitle: lastDownloadedAudioTitle,
        audioPositionSeconds: 59,
        isPaused: true,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        audioPausedDateTime: pausedAudioAtDateTime,
      );

      // Now go to the start of the audio
      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      IntegrationTestUtil.verifyAudioDataElementsUpdatedInPlaylistJsonFile(
        audioPlayerSelectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: 0,
        audioTitle: lastDownloadedAudioTitle,
        audioPositionSeconds: 0,
        isPaused: true,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        audioPausedDateTime: pausedAudioAtDateTime,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Click on play button to finish playing the audio downloaded before
           the last downloaded audio and start playing the not listened last
           downloaded audio.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String previousEndDownloadedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';
      const String previousEndDownloadedAudioTitleWithDuration =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches\n8:50';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_first_to_last_audio_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the audio downloaded before the last
      // downloaded audio of the playlist in order to open the
      // AudioPlayerView displaying the audio.

      // First, get the previous end downloaded audio ListTile Text
      // widget finder and tap on it
      final Finder previousEndDownloadedAudioListTileTextWidgetFinder =
          find.text(previousEndDownloadedAudioTitle);

      await tester.tap(previousEndDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now we tap on the play button in order to finish
      // playing the audio downloaded before the last downloaded
      // audio and start playing the last downloaded audio of the
      // playlist.

      // Verify that the selected playlist title is displayed
      Text selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(
        selectedPlaylistTitleText.data,
        audioPlayerSelectedPlaylistTitle,
      );

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Click on the pause button to stop the last downloaded audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the last downloaded played audio title
      expect(find.text(previousEndDownloadedAudioTitleWithDuration),
          findsOneWidget);

      // Verify that the selected playlist title is displayed
      selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(
        selectedPlaylistTitleText.data,
        audioPlayerSelectedPlaylistTitle,
      );

      // Ensure that the bug corrected on AudioPlayerVM on 06-06-2024
      // no longer happens. This bug impacted the application during
      // 3 weeks before it was discovered !!!!
      final Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '0:04',
        maxPositionTimeStr: '0:07',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Click on play button to finish playing the audio downloaded before
           the last downloaded audio and start playing the partially listened
           last downloaded audio.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String secondDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';
      const String firstDownloadedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';
      const String lastDownloadedAudioTitleWithDuration =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)\n20:32";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName:
            'audio_player_view_first_to_last_audio_corrected_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // First, we modify the audio position of the first downloaded audio
      // of the playlist. First, get the first downloaded audio ListTile Text
      // widget finder and tap on it
      final Finder
          playlistDownloadViewFirstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(
          playlistDownloadViewFirstDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Tapping 5 times on the forward 1 minute icon button. Now, the first
      // downloaded audio of the playlist is partially listened.
      for (int i = 0; i < 5; i++) {
        await tester
            .tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
        await tester.pumpAndSettle();
      }

      // Playing the first downloaded audio during 1 second.

      await tester.tap(find.byIcon(Icons.play_arrow));
      Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));

      // Click on the pause button to stop the first downloaded audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Now we want to tap on the audio downloaded after the first
      // downloaded audio of the playlist in order to start playing
      // it.

      // First, go back to the playlist download view.
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Then, get the second downloaded audio ListTile Text widget
      // finder and tap on it
      final Finder secondDownloadedAudioListTileTextWidgetFinder =
          find.text(secondDownloadedAudioTitle);

      await tester.tap(secondDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Now we tap on the play button in order to finish
      // playing the audio downloaded after the first downloaded
      // audio and start playing the first downloaded audio of the
      // playlist.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Click on the pause button to stop the first downloaded audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the last downloaded played audio title
      expect(find.text(lastDownloadedAudioTitleWithDuration), findsOneWidget);

      // Ensure that the bug corrected on AudioPlayerVM on 06-06-2024
      // no longer happens. This bug impacted the application during
      // 3 weeks before it was discovered !!!!
      final Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '20:11',
        maxPositionTimeStr: '20:16',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Click on play button to finish playing the first downloaded audio
           and start playing the not listened last downloaded audio, ignoring
           the 2 precendent audio already fully played.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String secondDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_first_to_last_audio_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Click on playlist toggle button to hide the playlist list
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(secondDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now we tap on the play button in order to finish
      // playing the first downloaded audio and start playing
      // the last downloaded audio of the playlist. The 2
      // audio in between are ignored since they are already
      // fully played.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));

      // Click on the pause button
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the last downloaded played audio title
      expect(
          find.text(
              "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet\n9:51"),
          findsOneWidget);

      // Ensure that the bug corrected on AudioPlayerVM on 06-06-2024
      // no longer happens. This bug impacted the application during
      // 3 weeks before it was discovered !!!!
      final Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '9:21',
        maxPositionTimeStr: '9:26',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''Click on play button to finish playing the first
           downloaded audio and start playing the partially listened last downloaded
           audio, ignoring the 2 precendent audio already fully played.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';
      const String secondDownloadedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName:
            'audio_player_view_first_to_last_audio_test_modified',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        tapOnPlaylistToggleButton: false,
      );

      // First, we modify the audio position of the second downloaded
      // audio of the playlist. First, get the second downloaded audio
      // ListTile Text widget finder and tap on it
      final Finder
          playlistDownloadViewSecondDownloadedAudioListTileTextWidgetFinder =
          find.text(secondDownloadedAudioTitle);

      await tester.tap(
          playlistDownloadViewSecondDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Tapping 5 times on the forward 1 minute icon button. Now, the
      // second downloaded audio of the playlist is fully listened.
      for (int i = 0; i < 5; i++) {
        await tester
            .tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
        await tester.pumpAndSettle();
      }

      // Playing the audio during 2 seconds.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));

      // Click on the pause button to stop the last downloaded audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to start playing it.

      // First, go back to the playlist download view.
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Then, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
        additionalMilliseconds: 500,
      );

      // Verify that the selected playlist title is displayed
      Text selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(
        selectedPlaylistTitleText.data,
        audioPlayerSelectedPlaylistTitle,
      );

      // Now we tap on the play button in order to finish
      // playing the first downloaded audio and start playing
      // the last downloaded audio of the playlist. The 2
      // audio in between are ignored since they are already
      // fully played.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Click on the pause button
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the last downloaded played audio title
      expect(
          find.text(
              "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet\n9:51"),
          findsOneWidget);

      // Verify that the selected playlist title is displayed
      selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(
        selectedPlaylistTitleText.data,
        audioPlayerSelectedPlaylistTitle,
      );

      final Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '8:53',
        maxPositionTimeStr: '8:58',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Back to playlist download view and click on pause, then on play
           again. Check the audio item play/pause icon as well as their color''',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String previouslyDownloadedAudioTitle = 'Really short video';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the previously downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the not yet played audio.

      // First, validate the play/pause button of the fully played
      // previously downloaded Audio item InkWell widget and obtain
      // again the previously downloaded Audio item InkWell widget
      // finder

      Finder previouslyDownloadedAudioListTileInkWellFinder =
          IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: previouslyDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kSliderThumbColorInDarkMode, // Fully played audio item play icon color
        expectedIconBackgroundColor: Colors.black,
      );

      // Now tap on the InkWell to play the audio and draw to the audio
      // player screen
      await tester.tap(previouslyDownloadedAudioListTileInkWellFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Without delaying, the playing audio and dragging to the
      // AudioPlayerView screen will not be successful !
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify if the pause button is present
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Now we go back to the PlayListDownloadView in order
      // to tap on play/pause audio item InkWell to pause the
      // audio
      final appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Again, validate the play/pause button of the previously
      // downloaded Audio item InkWell widget
      previouslyDownloadedAudioListTileInkWellFinder =
          IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: previouslyDownloadedAudioTitle,
        expectedIcon: Icons.pause,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Now tap on the InkWell pause button to pause the audio.
      // This will pause the audio and convert the pause button to
      // play button
      await tester.tap(previouslyDownloadedAudioListTileInkWellFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Verify if the pause icon button was changed to play icon
      // as well as its color and its enclosing CircleAvatar background
      // color

      previouslyDownloadedAudioListTileInkWellFinder =
          IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: previouslyDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Now tap on the InkWell to play the previously paused audio
      // and draw to the audio player screen
      await tester.tap(previouslyDownloadedAudioListTileInkWellFinder);
      await tester.pumpAndSettle();

      // Without delaying, the playing audio and dragging to the
      // AudioPlayerView screen will not be successful !
      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''Play to end the partially listened last downloaded audio and
                verify that the play/pause button is transformed from pause to
                play button. This verifies a bug fix.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String otherPlaylistTitle = 'local_3';
      const String lastDownloadedAudioTitle =
          '231226-094526-Ce qui va vraiment sauver notre espèce par Jancovici et Barrau 23-09-23';
      const String previousDownloadedAudioTitle = 'morning _ cinematic video';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_to_end_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        tapOnPlaylistToggleButton: false,
      );

      // First, we play till the end the first downloaded
      // audio of the playlist. First, get the first downloaded audio
      // ListTile Text widget finder and tap on it
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Click on play button.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1));
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));

      // Tapping 3 times on the forward 10 seconds icon button.
      for (int i = 0; i < 3; i++) {
        await tester
            .tap(find.byKey(const Key('audioPlayerViewForward10sButton')));
        await tester.pumpAndSettle();
      }

      await Future.delayed(const Duration(milliseconds: 2300));
      await tester.pumpAndSettle(const Duration(milliseconds: 1500));

      // Verify that the play button is present (due to the bug, the
      // pause button was displayed).
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Now we open the DisplaySelectableAudioListDialog
      // and select the previous downloaded audio of the playlist

      await tester.tap(find.text('$lastDownloadedAudioTitle\n6:28'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(previousDownloadedAudioTitle));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify that the play button is present (due to the bug, the
      // pause button is displayed).
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Now we go back to the playlist download view in order to select
      // another playlist.
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Now we select the other 'local_3' playlist
      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: otherPlaylistTitle,
      );

      // And we click on its unique audio item to open the audio
      // player view

      final Finder previousDownloadedAudioListTileTextWidgetFinder =
          find.text(previousDownloadedAudioTitle);

      await tester.tap(previousDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify that the play button is present (due to the bug, the
      // pause button is displayed).
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Audio with picture plays comment to end. This audio is a partially
           listened last audio. A comment whose end position is at end is played.
           Then verify that the play/pause button is transformed from pause to
           play button. This verifies a bug fix.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'Jésus-Christ';
      const String previousDownloadedAudioTitle =
          'NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE';
      const String lastDownloadedAudioTitle =
          'CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_picture_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        tapOnPlaylistToggleButton: false,
      );

      // First, through a comment, we play till the end the secondly
      // downloaded audio of the playlist. When a comment is played,
      // if the audio end is reached, the next audio does not start
      // to play.

      // First, get the second downloaded audio ListTile Text widget
      // finder and tap on it
      final Finder previousDownloadedAudioListTileTextWidgetFinder =
          find.text(previousDownloadedAudioTitle);

      await tester.tap(previousDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Play unique comment till end audio is reached
      await IntegrationTestUtil.playCommentFromListAddDialog(
        tester: tester,
        commentPosition: 1,
      );

      // Since the comment duration is 2 seconds, we wait 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Tap on the Close button to close the comment list add dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));

      // Verify that the play button is present (due to a bug, the
      // pause button was displayed).
      expect(
        find.byKey(const Key('picture_displayed_play_pause_button_key')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Now we go back to the playlist download view in order to select
      // the last downloaded audio.
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // We click on the audio item to open the audio player view

      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
        additionalMilliseconds: 1000,
      );

      // Verify that the play button is present (due to the bug, the
      // pause button was displayed).
      expect(
        find.byKey(const Key('middleScreenPlayPauseButton')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Audio no picture plays comment to end. This audio is a partially
           listened last audio. A comment whose end position is at end is played.
           Then verify that the play/pause button is transformed from pause to
           play button. This verifies a bug fix. Then, select a pictured audio.''',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local';
      const String audioPlayerNextPlaylistTitle = 'Jésus-Christ';
      const String previousDownloadedAudioTitle =
          'NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE';
      const String uniqueDownloadedAudioTitle =
          'CETTE SOEUR GUÉRIT DES MILLIERS DE PERSONNES AU NOM DE JÉSUS !  Émission Carrément Bien';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_picture_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        tapOnPlaylistToggleButton: false,
      );

      // First, through a comment, we play till the end the secondly
      // downloaded audio of the playlist. When a comment is played,
      // if the audio end is reached, the next audio does not start
      // to play.

      // First, get the unique downloaded audio ListTile Text widget
      // finder and tap on it
      final Finder uniqueDownloadedAudioListTileTextWidgetFinder =
          find.text(uniqueDownloadedAudioTitle);

      await tester.tap(uniqueDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Play unique comment till end audio is reached
      await IntegrationTestUtil.playCommentFromListAddDialog(
        tester: tester,
        commentPosition: 1,
      );

      // Since the comment duration is 2 seconds, we wait 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Tap on the Close button to close the comment list add dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));

      // Verify that the play button is present (due to the bug, the
      // pause button was displayed).
      expect(
        find.byKey(const Key('middleScreenPlayPauseButton')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Now we go back to the playlist download view in order to select
      // another playlist.
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: audioPlayerNextPlaylistTitle,
      );

      // We click on the audio item to open the audio player view

      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(previousDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
        additionalMilliseconds: 1000,
      );

      // Verify that the picture play/pause button is present.
      expect(
        find.byKey(const Key('picture_displayed_play_pause_button_key')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('Test play with or without rewind audio position', () {
    testWidgets(
        '''Partially listened audio > 1 h ago, rewind position after clicking
           on play button.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local';
      const String previouslyPartiallyListenedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: previouslyPartiallyListenedAudioTitle,
        audioToListenIndex: 1,
        audioDurationStr: '8:50',
        audioPositionBeforePlayingStr: '1:41',
        expectedMinPositionTimeStr: '1:11',
        expectedMaxPositionTimeStr: '1:12',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Partially listened audio > 1 h ago, click on << 10 sec and test
           that rewinding position after clicking on play button does not
           happen.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local';
      const String previouslyPartiallyListenedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindExcludedTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: previouslyPartiallyListenedAudioTitle,
        audioToListenIndex: 1,
        audioDurationStr: '8:50',
        audioPositionModification: AudioPositionModification.backward10sec,
        audioPositionBeforePlayingStr: '1:31',
        expectedMinPositionTimeStr: '1:31',
        expectedMaxPositionTimeStr: '1:32',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Partially listened audio > 1 h ago, click on << 1 min and test that
           rewinding position after clicking on play button does not happen.''',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local';
      const String previouslyPartiallyListenedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindExcludedTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: previouslyPartiallyListenedAudioTitle,
        audioToListenIndex: 1,
        audioDurationStr: '8:50',
        audioPositionModification: AudioPositionModification.backward1min,
        audioPositionBeforePlayingStr: '0:41',
        expectedMinPositionTimeStr: '0:41',
        expectedMaxPositionTimeStr: '0:42',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Partially listened audio > 1 h ago, click on >> 10 sec and test
           that rewinding position after clicking on play button does not
           happen.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local';
      const String previouslyPartiallyListenedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindExcludedTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: previouslyPartiallyListenedAudioTitle,
        audioToListenIndex: 1,
        audioDurationStr: '8:50',
        audioPositionModification: AudioPositionModification.forward10sec,
        audioPositionBeforePlayingStr: '1:51',
        expectedMinPositionTimeStr: '1:51',
        expectedMaxPositionTimeStr: '1:53',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Partially listened audio > 1 h ago, click on >> 1 min and test that 
           rewinding position after clicking on play button does not happen.''',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local';
      const String previouslyPartiallyListenedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindExcludedTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: previouslyPartiallyListenedAudioTitle,
        audioToListenIndex: 1,
        audioDurationStr: '8:50',
        audioPositionModification: AudioPositionModification.forward1min,
        audioPositionBeforePlayingStr: '2:41',
        expectedMinPositionTimeStr: '2:41',
        expectedMaxPositionTimeStr: '2:42',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Partially listened audio < 1 h && > 2 sec ago, rewind position
           after clicking on play button.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local';
      const String previouslyPartiallyListenedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: previouslyPartiallyListenedAudioTitle,
        audioToListenIndex: 1,
        audioDurationStr: '8:50',
        audioPausedDateTimeSecBeforeNowModification: 1800,
        audioPositionBeforePlayingStr: '1:41',
        expectedMinPositionTimeStr: '1:21',
        expectedMaxPositionTimeStr: '1:22',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''Partially listened audio < 2 sec ago, rewind position after
           clicking on play button.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local';
      const String previouslyPartiallyListenedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: previouslyPartiallyListenedAudioTitle,
        audioToListenIndex: 1,
        audioDurationStr: '8:50',
        audioPausedDateTimeSecBeforeNowModification: 1,
        audioPositionBeforePlayingStr: '1:41',
        expectedMinPositionTimeStr: '1:39',
        expectedMaxPositionTimeStr: '1:40',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Fully listened audio > 1 h ago, rewind position after clicking on
           play button.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local';
      const String fullyListenedAudioTitle =
          'Quand Aurélien Barrau va dans une école de management';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: fullyListenedAudioTitle,
        audioToListenIndex: 0,
        audioDurationStr: '17:59',
        audioPositionBeforePlayingStr: '17:59',
        expectedMinPositionTimeStr: '17:29',
        expectedMaxPositionTimeStr: '17:30',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Fully listened audio < 1 h && > 2 sec ago, rewind position after
           clicking on play button.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local';
      const String fullyListenedAudioTitle =
          'Quand Aurélien Barrau va dans une école de management';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: fullyListenedAudioTitle,
        audioToListenIndex: 0,
        audioDurationStr: '17:59',
        audioPausedDateTimeSecBeforeNowModification: 1800,
        audioPositionBeforePlayingStr: '17:59',
        expectedMinPositionTimeStr: '17:39',
        expectedMaxPositionTimeStr: '17:40',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Fully listened audio < 2 sec ago, rewind position after clicking
           on play button.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local';
      const String fullyListenedAudioTitle =
          'Quand Aurélien Barrau va dans une école de management';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: fullyListenedAudioTitle,
        audioToListenIndex: 0,
        audioDurationStr: '17:59',
        audioPausedDateTimeSecBeforeNowModification: 1,
        audioPositionBeforePlayingStr: '17:59',
        expectedMinPositionTimeStr: '17:57',
        expectedMaxPositionTimeStr: '17:58',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''Fully listened audio with audioPausedDateTime == null, rewind
           position after clicking on play button.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local_2';
      const String fullyListenedAudioTitle =
          'Quand Aurélien Barrau va dans une école de management';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: fullyListenedAudioTitle,
        audioToListenIndex: 0,
        audioDurationStr: '17:59',
        audioPositionBeforePlayingStr: '17:59',
        expectedMinPositionTimeStr: '17:59',
        expectedMaxPositionTimeStr: '17:59',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''Not listened audio with audioPausedDateTime == null, rewind
           position after clicking on play button.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'local_3';
      const String fullyListenedAudioTitle =
          'Quand Aurélien Barrau va dans une école de management';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_play_rewind',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      await _applyRewindTesting(
        tester: tester,
        audioPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        audioToListenTitle: fullyListenedAudioTitle,
        audioToListenIndex: 0,
        audioDurationStr: '17:59',
        audioPositionBeforePlayingStr: '0:00',
        expectedMinPositionTimeStr: '0:00',
        expectedMaxPositionTimeStr: '0:01',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });

  group('audio info audio state verification', () {
    testWidgets(
        '''After starting to play the audio, go back to playlist download
           view in order to verify audio info and audio play/pause icon type
           and state.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'morning _ cinematic video';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // checking the audio state displayed in audio information
      // dialog as well as audio right icon before playing
      // the audio
      await _goBackToPlaylistDownloadViewToCheckAudioStateAndIcon(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        audioStateExpectedValue: "Non écouté",
        expectedAudioRightIcon: Icons.play_arrow,
        expectedAudioRightIconColor: kDarkAndLightEnabledIconColor,
        expectedAudioRightIconSurroundedColor: Colors.black,
      );

      // Now we want to tap on the lastly downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the currently paused audio

      // First, get the lastly downloaded Audio ListTile Text
      // widget finder and tap on it to move to audio player view
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // checking the audio state displayed in audio information
      // dialog as well as audio right icon while audio is playing
      await _goBackToPlaylistDownloadViewToCheckAudioStateAndIcon(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        audioStateExpectedValue: "En lecture",
        expectedAudioRightIcon: Icons.pause,
        expectedAudioRightIconColor: Colors.white,
        expectedAudioRightIconSurroundedColor: kDarkAndLightEnabledIconColor,
      );

      // Go back to audio player view in order to pause the audio
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Pause the audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // checking the audio state displayed in audio information
      // dialog as well as audio right icon while audio is playing
      await _goBackToPlaylistDownloadViewToCheckAudioStateAndIcon(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        audioStateExpectedValue: "En pause",
        expectedAudioRightIcon: Icons.play_arrow,
        expectedAudioRightIconColor: Colors.white,
        expectedAudioRightIconSurroundedColor: kDarkAndLightEnabledIconColor,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''After starting to play the audio, click to end icon and go back
           to playlist download view in order to verify audio info and audio
           play/pause icon type and state.''', (
      WidgetTester tester,
    ) async {
      // PLACING THIS TEST IN THE PREVIOUS testWidgets FUNCTION
      // MAKES THE TEST TO FAIL. SO, IT IS PLACED IN A SEPARATE
      // testWidgets FUNCTION. WHY DID IT FAIL ? I DON'T KNOW !
      // THIS IS A FLUTTER BUG !
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_2_shorts_test';
      const String lastDownloadedAudioTitle = 'morning _ cinematic video';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the lastly downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the currently not played audio

      // First, get the lastly downloaded Audio ListTile Text
      // widget finder and tap on it to move to audio player view
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // checking the audio state displayed in audio information
      // dialog as well as audio right icon while audio is playing
      await _goBackToPlaylistDownloadViewToCheckAudioStateAndIcon(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        audioStateExpectedValue: "En lecture",
        expectedAudioRightIcon: Icons.pause,
        expectedAudioRightIconColor: Colors.white,
        expectedAudioRightIconSurroundedColor: kDarkAndLightEnabledIconColor,
      );

      // Go back to audio player view in order to go to end the audio
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Tap on the |> button to go to the end of the audio
      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // checking the audio state displayed in audio information
      // dialog as well as audio right icon when audio was played
      // to the end
      await _goBackToPlaylistDownloadViewToCheckAudioStateAndIcon(
        tester: tester,
        audioTitle: lastDownloadedAudioTitle,
        audioStateExpectedValue: "Terminé",
        expectedAudioRightIcon: Icons.play_arrow,
        expectedAudioRightIconColor: kSliderThumbColorInDarkMode,
        expectedAudioRightIconSurroundedColor: Colors.black,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('no audio selected tests', () {
    testWidgets(
        '''Opening AudioPlayerView by clicking on AudioPlayerView icon button
           with a playlist recently downloaded with no previously selected
           audio.''', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_no_sel_audio_test';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen which displays No selected audio
      // title

      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Test play button
      Finder playButton = find.byIcon(Icons.play_arrow);
      await tester.tap(playButton);
      await tester.pumpAndSettle();

      // Verify the no selected audio title is displayed in french
      expect(find.text("Aucun audio sélectionné"), findsOneWidget);

      // Verify the start and end position values

      Text audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      expect(audioPositionText.data, '0:00');

      Text audioRemainingDurationText = tester.widget<Text>(
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));
      expect(audioRemainingDurationText.data, '0:00');

      // Verify that the selected playlist title is displayed
      Text selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(
        selectedPlaylistTitleText.data,
        audioPlayerSelectedPlaylistTitle,
      );

      await IntegrationTestUtil.verifyTopButtonsState(
        tester: tester,
        areEnabled: false,
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        setAudioSpeedTextButtonValue: '1.00x',
      );

      // Select a Playlist audio

      // Now we open the AudioPlayableListDialog by tapping on the
      // "Aucun audio sélectionné" title
      await tester.tap(find.text("Aucun audio sélectionné"));
      await tester.pumpAndSettle();

      // Select the "Really short video" audio
      await tester.tap(find.text("Really short video"));
      await tester.pumpAndSettle();

      // Verify the start and end position values

      audioPositionText = tester
          .widget<Text>(find.byKey(const Key('audioPlayerViewAudioPosition')));
      expect(audioPositionText.data, '0:00');

      audioRemainingDurationText = tester.widget<Text>(
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration')));
      expect(audioRemainingDurationText.data, '0:10');

      await IntegrationTestUtil.verifyTopButtonsState(
        tester: tester,
        areEnabled: true,
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        setAudioSpeedTextButtonValue: '1.25x',
      );

      // Now, we delete all the audio of the playlist in order to test
      // the audio player view in the case where no audio exist in the
      // playlist

      // Go back to playlist download view

      final Finder audioPlayerNavButtonFinder =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(audioPlayerNavButtonFinder);
      await tester.pumpAndSettle();

      // Now delete all the audio of the playlist

      await deleteAudio(
        tester: tester,
        audioToDeleteTitle: "Really short video",
      );

      await deleteAudio(
        tester: tester,
        audioToDeleteTitle: "morning _ cinematic video",
      );

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen which displays the current
      // playable audio which is paused

      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Test play button
      playButton = find.byIcon(Icons.play_arrow);
      await tester.tap(playButton);
      await tester.pumpAndSettle();

      // Verify the no selected audio title is displayed
      expect(find.text("Aucun audio sélectionné"), findsOneWidget);

      await IntegrationTestUtil.verifyTopButtonsState(
        tester: tester,
        areEnabled: false,
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        setAudioSpeedTextButtonValue: '1.00x',
      );

      // Verify if the play button remained the same since
      // there is no audio to play
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Verify that the selected playlist title is displayed, even if
      // no audio is selected
      selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(selectedPlaylistTitleText.data, audioPlayerSelectedPlaylistTitle);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Opening AudioPlayerView by clicking on AudioPlayerView icon button
           in situation where no playlist is selected.''',
        (WidgetTester tester) async {
      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_no_playlist_selected_test',
        selectedPlaylistTitle: null, // no playlist selected
      );

      // Now we tap on the AudioPlayerView icon button to open
      // AudioPlayerView screen which displays the current
      // playable audio which is paused

      // Assuming you have a button to navigate to the AudioPlayerView
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the no selected audio title is displayed
      final Finder noAudioTitleFinder = find.text("No audio selected");
      expect(noAudioTitleFinder, findsOneWidget);

      await IntegrationTestUtil.verifyTopButtonsState(
        tester: tester,
        areEnabled: false,
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
        setAudioSpeedTextButtonValue: '1.00x',
      );

      // Verify that the playlist title Text is empty since no playlist
      // is selected
      final Text selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(selectedPlaylistTitleText.data, '');

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('set play speed tests', () {
    testWidgets(
        '''Reduce play speed. Then go back to PlaylistDownloadView and click
           on another audio title.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String lastDownloadedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';
      const String secondDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it to open the audio player
      // view
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(secondDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Verify the abscence of the help icon button (the help icon
      // button is only displayed when the audio play speed dialog
      // is opened from the application settings dialog !)
      expect(find.byIcon(Icons.help_outline), findsNothing);

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: expectedAudioPlaySpeed,
      );

      // Now we go back to the PlayListDownloadView in order
      // to tap on the last downloaded audio title

      final playlistDownloadViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(playlistDownloadViewNavButton);
      await tester.pumpAndSettle();

      // Now we want to tap on the last downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the last downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder lastDownloadedAudioListTileTextWidgetFinder =
          find.text(lastDownloadedAudioTitle);

      await tester.tap(lastDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      // Check the saved playlist last downloaded audio
      // play speed value in the json file

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Reduce play speed. Then click twice on >| button to start playing
           the most recently downloaded audio.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: expectedAudioPlaySpeed,
      );

      // Now we tap twice on the >| button in order to start
      // playing the last downloaded audio of the playlist

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Reduce play speed. Then click on play button to finish playing the
           first downloaded audio and start playing the next downloaded audio.''',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: expectedAudioPlaySpeed,
      );

      // Now we tap on the play button in order to finish
      // playing the first downloaded audio and start playing
      // the last downloaded audio of the playlist

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('Reduce play speed. Then click on Cancel.', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 1.25x
      expect(find.text('1.25x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 1.25;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Reduce play speed. Then click on play button to finish playing the
           first downloaded audio and start playing the last downloaded audio,
           ignoring the 2 precendent audio already fully played.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_first_to_last_audio_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: expectedAudioPlaySpeed,
      );

      // Now we tap on the play button in order to finish
      // playing the first downloaded audio and start playing
      // the last downloaded audio of the playlist. The 2
      // audio in between are ignored since they are already
      // fully played.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.25x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Reduce play speed. Then open the DisplaySelectableAudioListDialog
           and select the most recently downloaded audio.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String nextUnreadAndLastDownloadedAudioTitle =
          '3 fois où Aurélien Barrau tire à balles réelles sur les riches';
      const String firstDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the play speed is 0.70x
      expect(find.text('0.70x'), findsOneWidget);

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;
      double expectedAudioPlaySpeed = 0.7;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: expectedAudioPlaySpeed,
      );

      // Now we open the DisplaySelectableAudioListDialog
      // and select the last downloaded audio of the playlist

      await tester.tap(find.text(
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau\n6:29'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(nextUnreadAndLastDownloadedAudioTitle));
      await tester.pumpAndSettle();

      // Verify if the play speed of the last downloaded audio
      // which was not modified is 1.50x
      expect(find.text('1.50x'), findsOneWidget);

      playableAudioLstAudioIndex = 0;
      expectedAudioPlaySpeed = 1.5;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: expectedAudioPlaySpeed,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Click on 0 play speed audio, ensuring that its play speed is corrected
         to the app default playlist play speed defined in the app settings.json
         file. If the audio play speed would remain to zero, the audio would not
         be playable''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle =
          'audio_player_view_0_speed_test';
      const String zeroPlaySpeedAudioTitle = 'morning _ cinematic video';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_zero_speed_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the audio downloaded before the last
      // downloaded audio of the playlist in order to open the
      // AudioPlayerView displaying the audio.

      // First, get the previous end downloaded audio ListTile Text
      // widget finder and tap on it
      final Finder zeroPlaySpeedAudioTitleListTileTextWidgetFinder =
          find.text(zeroPlaySpeedAudioTitle);

      await tester.tap(zeroPlaySpeedAudioTitleListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify that audio play speed was corrected
      expect(find.text('1.25x'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''Reduce to min, then increase to max.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String secondDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it to open the audio player
      // view
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(secondDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 0.7x play speed
      await tester.tap(find.text('0.7x'));
      await tester.pumpAndSettle();

      // Then click twice on the minus icon button to reach the 0.50x
      // play speed

      await tester.tap(find.byKey(const Key('minusButtonKey')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('minusButtonKey')));
      await tester.pumpAndSettle();

      // Verify if the dialog play speed is 0.50x

      Text playSpeedDialogText =
          tester.widget(find.byKey(const Key('audioPlaySpeedTextKey')));
      expect(
        playSpeedDialogText.data,
        '0.50x',
      );

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the audio player view play speed button text is
      // 0.50x

      Text playSpeedButtonText =
          tester.widget(find.byKey(const Key('audioSpeedButtonText')));
      expect(
        playSpeedButtonText.data,
        '0.50x',
      );

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: 0.5,
      );

      // Now re-open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 1.5x play speed
      await tester.tap(find.text('1.5x'));
      await tester.pumpAndSettle();

      // Then click five times on the plus icon button to reach the 0.50x
      // play speed

      await tester.tap(find.byKey(const Key('plusButtonKey')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('plusButtonKey')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('plusButtonKey')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('plusButtonKey')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('plusButtonKey')));
      await tester.pumpAndSettle();

      // Verify if the dialog play speed is 2.00x

      playSpeedDialogText =
          tester.widget(find.byKey(const Key('audioPlaySpeedTextKey')));
      expect(
        playSpeedDialogText.data,
        '2.00x',
      );

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the audio player view play speed button text is
      // 2.00x

      playSpeedButtonText =
          tester.widget(find.byKey(const Key('audioSpeedButtonText')));
      expect(
        playSpeedButtonText.data,
        '2.00x',
      );

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: 2.0,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''Reduce, then increase from 1.25x.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String secondDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_play_speed_bug_fix_test_data',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it to open the audio player
      // view
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(secondDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now open the audio play speed dialog. The play speed
      // is 1.25x
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Click once on the minus icon button to reach 1.20x
      // play speed

      await tester.tap(find.byKey(const Key('minusButtonKey')));
      await tester.pumpAndSettle();

      // Verify if the dialog play speed is 1.20x

      Text playSpeedDialogText =
          tester.widget(find.byKey(const Key('audioPlaySpeedTextKey')));
      expect(
        playSpeedDialogText.data,
        '1.20x',
      );

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the audio player view play speed button text is
      // 1.20x

      Text playSpeedButtonText =
          tester.widget(find.byKey(const Key('audioSpeedButtonText')));
      expect(
        playSpeedButtonText.data,
        '1.20x',
      );

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      int playableAudioLstAudioIndex = 1;

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: 1.2,
      );

      // Now re-open the audio play speed dialog
      await tester.tap(find.byKey(const Key('setAudioSpeedTextButton')));
      await tester.pumpAndSettle();

      // Now select the 1.25x play speed
      await tester.tap(find.text('1.25x'));
      await tester.pumpAndSettle();

      // Then click one times on the plus icon button to reach the 1.30x
      // play speed

      await tester.tap(find.byKey(const Key('plusButtonKey')));
      await tester.pumpAndSettle();

      // Verify if the dialog play speed is 1.30x

      playSpeedDialogText =
          tester.widget(find.byKey(const Key('audioPlaySpeedTextKey')));
      expect(
        playSpeedDialogText.data,
        '1.30x',
      );

      // And click on the Ok button
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();

      // Verify if the audio player view play speed button text is
      // 1.30x

      playSpeedButtonText =
          tester.widget(find.byKey(const Key('audioSpeedButtonText')));
      expect(
        playSpeedButtonText.data,
        '1.30x',
      );

      // Check the saved playlist first downloaded audio
      // play speed value in the json file

      IntegrationTestUtil.verifyAudioPlaySpeedStoredInPlaylistJsonFile(
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
        playableAudioLstAudioIndex: playableAudioLstAudioIndex,
        expectedAudioPlaySpeed: 1.3,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('''From first downloaded audio, skip to next not fully played audio
         ignoring 5 already fully listened audio tests. Verify also the audio
         item play icon color in playlist download view.''', () {
    testWidgets('''Next fully unread audio also the last downloaded audio of the
           playlist.''', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String secondDownloadedAudioTitle =
          "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet";
      const String lastDownloadedAudioTitleOnAudioPlayerView =
          "La résilience insulaire par Fiona Roche\n13:35";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName:
            'audio_play_skip_to_next_and_last_unread_audio_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, validate the play/pause button of the almost fully
      // played first downloaded Audio item InkWell widget

      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: secondDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kSliderThumbColorInDarkMode, // 2 seconds before end (=> fully played) audio item play icon color
        expectedIconBackgroundColor: Colors.black,
      );

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(secondDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // The audio position is 2 seconds before end. Now play
      // the audio and wait 5 seconds so that the next audio
      // will start to play

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Tap on pause button to pause the audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the last downloaded audio position

      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '0:03',
        maxPositionTimeStr: '0:06',
      );

      // Verify if the last downloaded audio title is displayed
      expect(
          find.text(lastDownloadedAudioTitleOnAudioPlayerView), findsOneWidget);

      // go back to the playlist download view
      await tester.tap(find.byKey(const Key('playlistDownloadViewIconButton')));
      await tester.pumpAndSettle();

      // Now, validate the play/pause button of the now fully played
      // first downloaded Audio item InkWell widget and obtain
      // again the previously downloaded Audio item InkWell widget
      // finder

      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: secondDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kSliderThumbColorInDarkMode, // Fully played audio item play icon color
        expectedIconBackgroundColor: Colors.black,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Next partially played audio also the last downloaded audio of the
           playlist.''', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String firstDownloadedAudioTitle =
          "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet";
      const String lastDownloadedAudioTitleOnAudioPlayerView =
          "La résilience insulaire par Fiona Roche\n13:35";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'audio_play_skip_to_next_and_last_unread_audio_test',
          selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
          replacePlaylistJsonFileName: 'S8 audio.saved');

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // Trying to avoid unregular integration test failure
      await Future.delayed(const Duration(milliseconds: 400));

      // The audio position is 2 seconds before end. Now play
      // the audio and wait 5 seconds so that the next audio
      // will start to play

      Finder playIconFinder = find.byIcon(Icons.play_arrow);
      await tester.tap(playIconFinder);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Tap on pause button to pause the audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the last downloaded audio position

      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '3:03',
        maxPositionTimeStr: '3:06',
      );

      // Verify if the last downloaded audio title is displayed
      expect(
          find.text(lastDownloadedAudioTitleOnAudioPlayerView), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''User modifies the position of next fully played audio which is
           also the last downloaded audio of the playlist.''',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String firstDownloadedAudioTitle =
          "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet";
      const String nextDownloadedAudioTitle =
          "Les besoins artificiels par R.Keucheyan";
      const String nextDownloadedAudioTitleOnAudioPlayerView =
          "$nextDownloadedAudioTitle\n19:05";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'audio_play_skip_to_next_and_last_unread_audio_test',
          selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle);

      // Now, before playing the first downloaded audio, we want to
      // modify the position of the last downloaded audio of the
      // playlist so that it is partially played. Then, we will tap
      // on the first downloaded audio in order to open the start
      // playing it.

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the
      // last downloaded audio and tap on it to open the audio
      // player view.
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(nextDownloadedAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's position
      expect(find.text('19:05'), findsOneWidget);

      // change the current audio's play position

      await tester
          .tap(find.byKey(const Key('audioPlayerViewBackward1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('18:05'), findsOneWidget);

      // Now, go back to the playlist download view
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Then, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // The audio position is 2 seconds before end. Now play
      // the audio and wait 5 seconds so that the next audio
      // will start to play

      Finder playIconFinder = find.byIcon(Icons.play_arrow);
      await tester.tap(playIconFinder);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Tap on pause button to pause the audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the last downloaded audio position

      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '18:06',
        maxPositionTimeStr: '18:11',
      );

      // Verify if the last downloaded audio title is displayed
      expect(
          find.text(nextDownloadedAudioTitleOnAudioPlayerView), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''User sets to 0 the position of third downloaded audio of the
           playlist. Verify also the audio item play icon color in playlist
           download view.''', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String firstDownloadedAudioTitle =
          "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet";
      const String thirdDownloadedAudioTitle =
          "Les besoins artificiels par R.Keucheyan";
      const String thirdDownloadedAudioTitleOnAudioPlayerView =
          "$thirdDownloadedAudioTitle\n19:05";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'audio_play_skip_to_next_and_last_unread_audio_test',
          selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle);

      // Now, before playing the first downloaded audio, we want to
      // modify the position of the last downloaded audio of the
      // playlist so that it is unplayed. Then, we will tap
      // on the first downloaded audio in order to open the audio
      // player view and start playing the sound.

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // verify the fully played third downloaded audio item play icon
      // layout
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: thirdDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kSliderThumbColorInDarkMode, // Fully played audio item play icon color
        expectedIconBackgroundColor: Colors.black,
      );

      // First, get the ListTile Text widget finder of the
      // third downloaded audio and tap on it to open the audio
      // player view.
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(thirdDownloadedAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // set the current audio's play position to start

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // Now, go back to the playlist download view
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // verify the now unplayed third downloaded audio item play icon
      // layout
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: thirdDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kDarkAndLightEnabledIconColor, // Unplayed audio item play icon color
        expectedIconBackgroundColor: Colors.black,
      );

      // Then, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // The audio position is 2 seconds before end. Now play
      // the audio and wait 5 seconds so that the next audio
      // will start to play

      Finder playIconFinder = find.byIcon(Icons.play_arrow);
      await tester.tap(playIconFinder);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Tap on pause button to pause the audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the third downloaded audio position

      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '0:03',
        maxPositionTimeStr: '0:06',
      );

      // Verify if the third downloaded audio title is displayed
      expect(find.text(thirdDownloadedAudioTitleOnAudioPlayerView),
          findsOneWidget);

      // Now tap to the go to end button to reset the third downloaded
      // audio to fully played state

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // Go back to the playlist download view
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // verify the now fully played third downloaded audio item play icon
      // layout
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: thirdDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor: kSliderThumbColorInDarkMode,
        expectedIconBackgroundColor: Colors.black,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''User sets to 2 minutes the position of third downloaded audio of
           the playlist.''', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String firstDownloadedAudioTitle =
          "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet";
      const String thirdDownloadedAudioTitle =
          "Les besoins artificiels par R.Keucheyan";
      const String thirdDownloadedAudioTitleOnAudioPlayerView =
          "$thirdDownloadedAudioTitle\n19:05";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName:
              'audio_play_skip_to_next_and_last_unread_audio_test',
          selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle);

      // Now, before playing the first downloaded audio, we want to
      // modify the position of the third downloaded audio of the
      // playlist so that it is partially played. Then, we will tap
      // on the first downloaded audio in order to open the audio
      // player view and play the sound.

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the
      // third downloaded audio and tap on it to open the audio
      // player view.
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(thirdDownloadedAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // set the current audio's play position to start

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // then set the position to + 2 minutes

      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('2:00'), findsOneWidget);

      // Now, go back to the playlist download view
      final Finder appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Then, get the first downloaded Audio ListTile Text
      // widget finder and tap on it
      final Finder firstDownloadedAudioListTileTextWidgetFinder =
          find.text(firstDownloadedAudioTitle);

      await tester.tap(firstDownloadedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Trying to avoid unregular integration test failure
      await Future.delayed(const Duration(milliseconds: 200));

      // The audio position is 2 seconds before end. Now play
      // the audio and wait 5 seconds so that the next audio
      // will start to play

      Finder playIconFinder = find.byIcon(Icons.play_arrow);
      await tester.tap(playIconFinder);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Tap on pause button to pause the audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the third downloaded audio position

      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '2:01',
        maxPositionTimeStr: '2:04',
      );

      // Verify if the last downloaded audio title is displayed
      expect(find.text(thirdDownloadedAudioTitleOnAudioPlayerView),
          findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('Displaying the audio playable list.', () {
    testWidgets('All, then only no played or partially played, audio displayed',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String fifthDownloadedPartiallyPlayedAudioTitle =
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_display_audio_list_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the fifth downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the fifth downloadedand partially played audio
      // ListTile Text widget finder and tap on it
      final Finder fifthDownloadedPartiallyPlayedAudioListTileTextWidgetFinder =
          find.text(fifthDownloadedPartiallyPlayedAudioTitle);

      await tester
          .tap(fifthDownloadedPartiallyPlayedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Now we open the AudioPlayableListDialog
      // and verify the color of the displayed audio titles

      await tester
          .tap(find.text('$fifthDownloadedPartiallyPlayedAudioTitle\n6:29'));
      await tester.pumpAndSettle();

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle:
            "La sagesse ancestrale au service de la transition - Barrau & Bellet",
        expectedTitleTextColor: IntegrationTestUtil.fullyPlayedAudioTitleColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle:
            "Manger de la viande à notre époque par Aurélien Barrau",
        expectedTitleTextColor:
            IntegrationTestUtil.partiallyPlayedAudioTitleTextdColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle:
            "Jancovici démonte les avantages du numérique chez Orange",
        expectedTitleTextColor: IntegrationTestUtil.fullyPlayedAudioTitleColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle:
            "Quand Aurélien Barrau va dans une école de management",
        expectedTitleTextColor:
            IntegrationTestUtil.partiallyPlayedAudioTitleTextdColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle: fifthDownloadedPartiallyPlayedAudioTitle,
        expectedTitleTextColor:
            IntegrationTestUtil.currentlyPlayingAudioTitleTextColor,
        expectedTitleTextBackgroundColor:
            IntegrationTestUtil.currentlyPlayingAudioTitleTextBackgroundColor,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle:
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        expectedTitleTextColor: IntegrationTestUtil.fullyPlayedAudioTitleColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle: "morning _ cinematic video",
        expectedTitleTextColor: IntegrationTestUtil.unplayedAudioTitleTextColor,
        expectedTitleTextBackgroundColor: null,
      );

      // Now we tap the Exclude fully played audio checkbox
      await tester
          .tap(find.byKey(const Key('excludeFullyPlayedAudiosCheckbox')));
      await tester.pumpAndSettle();

      // Verifying that the fully played audio titles are not displayed

      expect(
          find.text(
              "La sagesse ancestrale au service de la transition - Barrau & Bellet"),
          findsNothing);
      expect(find.text("Really short video"), findsNothing);

      expect(
          find.text("Jancovici démonte les avantages du numérique chez Orange"),
          findsNothing);

      expect(
          find.text(
              "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)"),
          findsNothing);

      // Checking the color of the displayed audio titles

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle:
            "Manger de la viande à notre époque par Aurélien Barrau",
        expectedTitleTextColor:
            IntegrationTestUtil.partiallyPlayedAudioTitleTextdColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle:
            "Quand Aurélien Barrau va dans une école de management",
        expectedTitleTextColor:
            IntegrationTestUtil.partiallyPlayedAudioTitleTextdColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle: fifthDownloadedPartiallyPlayedAudioTitle,
        expectedTitleTextColor:
            IntegrationTestUtil.currentlyPlayingAudioTitleTextColor,
        expectedTitleTextBackgroundColor:
            IntegrationTestUtil.currentlyPlayingAudioTitleTextBackgroundColor,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle: "morning _ cinematic video",
        expectedTitleTextColor: IntegrationTestUtil.unplayedAudioTitleTextColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle: "La résilience insulaire par Fiona Roche",
        expectedTitleTextColor:
            IntegrationTestUtil.partiallyPlayedAudioTitleTextdColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle:
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        expectedTitleTextColor: IntegrationTestUtil.unplayedAudioTitleTextColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle: "Les besoins artificiels par R.Keucheyan",
        expectedTitleTextColor: IntegrationTestUtil.unplayedAudioTitleTextColor,
        expectedTitleTextBackgroundColor: null,
      );

      // Tap on Cancel button to close the
      // DisplaySelectableAudioListDialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Select first downloaded audio, then verify that displayed audio
           list is moved down in order to display this audio title''',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String thirdDownloadedNotPlayedAudioTitle =
          "Les besoins artificiels par R.Keucheyan";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_display_audio_list_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Scrolling down the audio list in order to display the first
      // downloaded audio title

      // Find the audio list widget using its key
      final listFinder = find.byKey(const Key('audio_list'));

      // Perform the scroll action
      await tester.drag(listFinder, const Offset(0, -1000));
      await tester.pumpAndSettle();

      // Now type on the third downloaded audio title in order to
      // open the AudioPlayerView displaying the audio
      await tester.tap(find.text(thirdDownloadedNotPlayedAudioTitle));
      await tester.pumpAndSettle();

      // Now we open the AudioPlayableListDialog by tapping on the
      // audio title
      await tester.tap(find.text("$thirdDownloadedNotPlayedAudioTitle\n19:05"));
      await tester.pumpAndSettle();

      // The list has been moved down so that the current audio is
      // displayed at the bottom of the list
      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle: thirdDownloadedNotPlayedAudioTitle,
        expectedTitleTextColor:
            IntegrationTestUtil.currentlyPlayingAudioTitleTextColor,
        expectedTitleTextBackgroundColor:
            IntegrationTestUtil.currentlyPlayingAudioTitleTextBackgroundColor,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle:
            "Le Secret de la RÉSILIENCE révélé par Boris Cyrulnik",
        expectedTitleTextColor: IntegrationTestUtil.unplayedAudioTitleTextColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle: "La résilience insulaire par Fiona Roche",
        expectedTitleTextColor:
            IntegrationTestUtil.partiallyPlayedAudioTitleTextdColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle: "Really short video",
        expectedTitleTextColor: IntegrationTestUtil.fullyPlayedAudioTitleColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle: "morning _ cinematic video",
        expectedTitleTextColor: IntegrationTestUtil.unplayedAudioTitleTextColor,
        expectedTitleTextBackgroundColor: null,
      );

      await IntegrationTestUtil.checkAudioTextColor(
        tester: tester,
        audioTitleOrSubTitle:
            "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)",
        expectedTitleTextColor: IntegrationTestUtil.fullyPlayedAudioTitleColor,
        expectedTitleTextBackgroundColor: null,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Select an Audio in the displayed audio list while current audio is
           playing and then select the previous audio. Then select again the
           previously selected audio and verify that its position corresponds
           to its position when the other audio was selected in the displayed
           audio list''', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String audioToPlayTitle =
          "Quand Aurélien Barrau va dans une école de management";
      const String audioToSelectInAudioListTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_display_audio_list_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Type on the audio to play title in order to open the
      // AudioPlayerView displaying the audio
      await tester.tap(find.text(audioToPlayTitle));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Now tap on the Play button to play the audio
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Memorizing the current audio position
      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));
      final String memorizedPositionTimeString =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      // Now we open the AudioPlayableListDialog by tapping on the
      // audio title
      await tester.tap(find.text("$audioToPlayTitle\n17:59"));
      await tester.pumpAndSettle();

      // Select an Audio in the AudioPlayableListDialog
      await IntegrationTestUtil.selectAudioInAudioPlayableDialog(
        tester: tester,
        audioToSelectTitle: audioToSelectInAudioListTitle,
      );

      // Now we are back on the AudioPlayerView displaying the selected
      // audio to play. We reopen the AudioPlayableListDialog
      // by tapping on the audio title.
      await tester.tap(find.text("$audioToSelectInAudioListTitle\n6:29"));
      await tester.pumpAndSettle();

      // Then select the previously playing audio in order to open it in
      // the AudioPlayerView
      await IntegrationTestUtil.selectAudioInAudioPlayableDialog(
        tester: tester,
        audioToSelectTitle: audioToPlayTitle,
        offsetValue: 300,
      );

      // Now we are back on the AudioPlayerView displaying the previously
      // playing audio. We verify that the audio position is the same as
      // when the other audio was selected in the displayed audio list.
      //
      // Sometime, the audio position may be different by a 1 second due
      // to the way integration tests work !

      // Retrieving the current audio position
      audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));
      final String retrievedPositionTimeString =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      int memorizedPositionTimeInTenthsOfSeconds =
          DateTimeUtil.convertToTenthsOfSeconds(
        timeString: memorizedPositionTimeString,
      );

      expect(
        DateTimeUtil.convertToTenthsOfSeconds(
          timeString: retrievedPositionTimeString,
        ),
        allOf(
          [
            greaterThanOrEqualTo(memorizedPositionTimeInTenthsOfSeconds - 10),
            lessThanOrEqualTo(memorizedPositionTimeInTenthsOfSeconds),
          ],
        ),
        reason:
            "Expected value between $memorizedPositionTimeInTenthsOfSeconds and ${memorizedPositionTimeInTenthsOfSeconds + 10} but obtained $retrievedPositionTimeString",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Save short playable SF parms to audio player view and display the
           shortened audio playable list in the audio player view.''',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String audioToPlayTitle =
          "Quand Aurélien Barrau va dans une école de management";
      const String audioToSelectInAudioListTitle =
          'Really short video'; // Short playable audio

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_view_display_audio_list_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      const String shortPlayableSortFilterName = 'short playable';

      // Select 'short playable' SF in the dropdown button and save
      // it to the audio player view
      await IntegrationTestUtil.selectAndSaveSortFilterParmsToPlaylist(
        tester: tester,
        sortFilterParmsName: shortPlayableSortFilterName,
        saveToPlaylistDownloadView: false,
        saveToAudioPlayerView: true,
      );

      // Verify confirmation dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "Sort/filter parameters \"$shortPlayableSortFilterName\" were saved to playlist \"S8 audio\" for screen(s) \"Play Audio\".",
        isWarningConfirming: true,
      );

      // Select 'Default' SF in the dropdown button
      await IntegrationTestUtil.selectSortFilterParmsInDropDownButton(
        tester: tester,
        sortFilterParmsName: 'default',
      );

      // Type on the audio to play title in order to open the
      // AudioPlayerView displaying the audio
      await tester.tap(find.text(audioToPlayTitle));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Now we open the AudioPlayableListDialog by tapping on the
      // audio title
      await tester.tap(find.text("$audioToPlayTitle\n17:59"));
      await tester.pumpAndSettle();

      // Verify the shortened displayed audio list
      expect(find.text("morning _ cinematic video"), findsOneWidget);
      expect(find.text("Really short video"), findsOneWidget);

      // Select an Audio in the AudioPlayableListDialog
      await IntegrationTestUtil.selectAudioInAudioPlayableDialog(
        tester: tester,
        audioToSelectTitle: audioToSelectInAudioListTitle,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('single undo/redo tests', () {
    testWidgets('forward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('forward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester
          .tap(find.byKey(const Key('audioPlayerViewForward10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:10'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:10'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('backward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // check the current audio's position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('backward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('skip to start position change', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // check the current audio's position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio start

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('skip to end position change', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // check the current audio's position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('play comment and undo the resulting position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle); // 3 fois où un économiste m'a ...

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's position
      expect(find.text('10:00'), findsOneWidget);

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Now tap on the play comment icon button to start playing
      // the comment
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Now tap on the pause comment icon button to stop playing
      // the comment
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));

      // check the current audio's changed position
      final Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      // If this test fails, try to rexecute it several times. If
      // the test continue to fail, restart your computer and
      // execute flutter clean, then flutter pub get and finally
      // flutter gen-l10n. This is crazy, but it solves the problem !
      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '1:23',
        maxPositionTimeStr: '1:25',
      );

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('1:23'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('undo/redo with new command between tests', () {
    testWidgets('forward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // check the current audio's play position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio start

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      expect(find.text('0:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('forward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's initial position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester
          .tap(find.byKey(const Key('audioPlayerViewForward10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:10'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio start

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      expect(find.text('0:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's redoned change position
      expect(find.text('10:10'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('backward 1 minute position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // check the current audio's play position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      expect(find.text('20:32'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('backward 10 seconds position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's play position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind10sButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      expect(find.text('20:32'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:50'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('skip to start position change', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio start

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: go forward 1 minute

      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('11:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('0:00'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('skip to end position change', (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('10:00'), findsOneWidget);

      // change the current audio's play position to audio end

      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: go back 1 minute

      await tester.tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('9:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('20:32'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('play comment and undo the resulting position change',
        (WidgetTester tester) async {
      const String audioPlayerSelectedPlaylistTitle =
          'S8 audio'; // Youtube playlist
      const String toSelectAudioTitle =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the first downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // the audio

      // Tap the 'Toggle List' button to avoid displaying the list
      // of playlists which may hide the audio title we want to
      // tap on
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio
      // to be selected and tap on it
      final Finder toSelectAudioListTileTextWidgetFinder =
          find.text(toSelectAudioTitle);

      await tester.tap(toSelectAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      // check the current audio's position
      expect(find.text('10:00'), findsOneWidget);

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Now tap on the play comment icon button to start playing
      // the comment
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Now tap on the pause comment icon button to stop playing
      // the comment
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle(const Duration(milliseconds: 2000));

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      final Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      // If this test fails, try to rexecute it several times. If
      // the test continue to fail, restart your computer and
      // execute flutter clean, then flutter pub get and finally
      // flutter gen-l10n. This is crazy, but it solves the problem !
      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '1:24',
        maxPositionTimeStr: '1:26',
      );

      // undo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position after the undo
      expect(find.text('10:00'), findsOneWidget);

      // new command: change the current audio's play position to audio start

      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      expect(find.text('0:00'), findsOneWidget);

      // redo the change

      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // check the current audio's changed position
      expect(find.text('1:23'), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('Inkwell button building tests', () {
    testWidgets(
        '''Multiple changes of the audio position in order to modify the audio
           item play/pause Inkwell button foreground and background color''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String secondDownloadedAudioTitle =
          "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'inkwell_button_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // First, validate the play/pause button of the fully played
      // second downloaded Audio item InkWell widget
      Finder secondDownloadedAudioListTileInkWellFinder =
          IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: secondDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kSliderThumbColorInDarkMode, // Fully played audio play/pause icon color
        expectedIconBackgroundColor: Colors.black,
      );

      // Now we want to tap on the second downloaded audio of the
      // playlist in order to open the AudioPlayerView displaying
      // this fully played audio.

      // Tap on the InkWell to play the audio. Since the audio is fully
      // played, the audio remains at end.
      await tester.tap(secondDownloadedAudioListTileInkWellFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Tap on << 10 seconds button to go back to 10 sec before the
      // audio end
      await tester.tap(find.byKey(const Key('audioPlayerViewRewind10sButton')));
      await tester.pumpAndSettle();

      // Now we go back to the PlayListDownloadView in order to
      // verify the play/pause audio item InkWell button color
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Validate again the play/pause button of the fully played
      // second downloaded Audio item InkWell widget. An audio positioned
      // less than 15 seconds before its end position is considered to be
      // fully played.
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: secondDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kSliderThumbColorInDarkMode, // Fully played audio play/pause icon color
        expectedIconBackgroundColor: Colors.black,
      );

      // Then return to the audio player view in order to set the audio
      // as partially played

      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Find the slider using its key
      final sliderFinder = find.byKey(const Key('audioPlayerViewAudioSlider'));

      await tester.drag(
        sliderFinder,
        const Offset(-100, 0),
      ); // Drag horizontally left
      await tester.pumpAndSettle();

      // Now we go back to the PlayListDownloadView in order to
      // verify the play/pause audio item InkWell button color
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Again, validate the play/pause button of the previously
      // downloaded Audio item InkWell widget
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: secondDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            Colors.white, // currently playing or paused icon color
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Tap again on the second downloaded audio of the playlist in
      // order to open the AudioPlayerView displaying this now
      // partially played audio.

      // Then go to the audio player view
      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Tap on |< button to go to the beginning of the audio
      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // Now we go back to the PlayListDownloadView in order to
      // verify the play/pause audio item InkWell button color
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Again, validate the play/pause button of the previously
      // downloaded Audio item InkWell widget
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: secondDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kDarkAndLightEnabledIconColor, // not played icon color
        expectedIconBackgroundColor: Colors.black,
      );

      // Then go to the audio player view
      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Tap on >> 1 minute button to position the audio player to 1
      // minute after the beginning of the audio
      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      // Now we go back to the PlayListDownloadView in order to
      // verify the play/pause audio item InkWell button color
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Again, validate the play/pause button of the previously
      // downloaded Audio item InkWell widget
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: secondDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            Colors.white, // currently playing or paused icon color
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Then go to the audio player view
      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Tap on >| button to go to the end of the audio
      await tester.tap(find.byKey(const Key('audioPlayerViewSkipToEndButton')));
      await tester.pumpAndSettle();

      // Now we go back to the PlayListDownloadView in order to
      // verify the play/pause audio item InkWell button color
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Now, validate the play/pause button of the fully played
      // second downloaded Audio item InkWell widget
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: secondDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kSliderThumbColorInDarkMode, // Fully played audio play/pause icon color
        expectedIconBackgroundColor: Colors.black,
      );

      // Then go to the audio player view to use undo button
      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Tap on the undo button to undo going to the end of the audio
      await tester.tap(find.byKey(const Key('audioPlayerViewUndoButton')));
      await tester.pumpAndSettle();

      // Now we go back to the PlayListDownloadView in order to
      // verify the play/pause audio item InkWell button color
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Again, validate the play/pause button of the previously
      // downloaded Audio item InkWell widget
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: secondDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            Colors.white, // currently playing or paused icon color
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Finally, go to the audio player view to tap on the redo button
      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Tap on the undo button to undo going to the end of the audio
      await tester.tap(find.byKey(const Key('audioPlayerViewRedoButton')));
      await tester.pumpAndSettle();

      // Now we go back to the PlayListDownloadView in order to
      // verify the play/pause audio item InkWell button color
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Now, validate the play/pause button of the fully played
      // second downloaded Audio item InkWell widget
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        audioTitle: secondDownloadedAudioTitle,
        expectedIcon: Icons.play_arrow,
        expectedIconColor:
            kSliderThumbColorInDarkMode, // Fully played audio play/pause icon color
        expectedIconBackgroundColor: Colors.black,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('Selecting playlist in AudioPlayerView', () {
    testWidgets(
        '''Selecting different playlists in order to change the playable audio 
           contained in the audio player to the selected playlist current or
           past playable audio.''', (WidgetTester tester) async {
      const String emptyPlaylistTitle = 'Empty'; // Youtube playlist
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String localPlaylistTitle = 'local'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";
      const String localPlaylistCurrentPlayableAudioTitle =
          "morning _ cinematic video";
      const String noAudioSelectedTitle = "No audio selected";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: emptyPlaylistTitle,
      );

      // Verify that the playlist list is displayed
      expect(
        find.byKey(const Key('expandable_playlist_list')),
        findsOneWidget,
      );

      // Go to the audio player view
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify the no selected audio title is displayed
      expect(find.text(noAudioSelectedTitle), findsOneWidget);

      // Verify the displayed playlist title
      Text selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(
        selectedPlaylistTitleText.data,
        emptyPlaylistTitle,
      );

      // Now, in the audio player view, select the S8 audio playlist using
      // the audio player view playlist selection button. Then verify that
      // the displayed audio title is the current playable audio title of
      // the S8 audio playlist, i.e. "Interview de Chat GPT  - IA,
      // intelligence, philosophie, géopolitique, post-vérité...".
      await _verifyAudioPlayerViewPlaylistSelectionImpact(
        tester: tester,
        playlistDownloadViewCurrentlySelectedPlaylistTitle: emptyPlaylistTitle,
        playlistToSelectTitle: youtubePlaylistTitle,
        playlistCurrentlyPlayableAudioTitleWithDuration:
            "$alreadyCommentedAudioTitle\n1:17:54",
        expectedAudioPositionTimeString: '1:12:48',
        expectedAudioRemainingDurationTimeString: '5:06',
      );

      // Now return to the playlist download view
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify that the S8 audio playlist is now selected in the playlist
      // download view since it was selected in the audio player view.
      _verifyPlaylistIsSelectedInPlaylistDownloadView(
        tester: tester,
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Now close the playlist download view playlists list. The selected
      // playlist remains S8 audio
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // And go again to the audio player view
      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the displayed audio title

      Finder audioPlayerViewAudioTitleFinder =
          find.byKey(const Key('audioPlayerViewCurrentAudioTitle'));
      String audioTitleWithDurationString =
          tester.widget<Text>(audioPlayerViewAudioTitleFinder).data!;

      expect(
        audioTitleWithDurationString,
        "$alreadyCommentedAudioTitle\n1:17:54",
      );

      // Now, in the audio player view, select the local audio playlist using
      // the audio player view playlist selection button. Then verify that
      // the displayed audio title is the current playable audio title of
      // the local audio playlist, i.e. "morning _ cinematic video".
      await _verifyAudioPlayerViewPlaylistSelectionImpact(
        tester: tester,
        playlistDownloadViewCurrentlySelectedPlaylistTitle:
            youtubePlaylistTitle,
        playlistToSelectTitle: localPlaylistTitle,
        playlistCurrentlyPlayableAudioTitleWithDuration:
            "$localPlaylistCurrentPlayableAudioTitle\n0:59",
        expectedAudioPositionTimeString: '0:02',
        expectedAudioRemainingDurationTimeString: '0:57',
      );

      // Now return to the playlist download view
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify that the playlist download view list of playlists which
      // was closed before going to the audio player view is still closed
      expect(find.byKey(const Key('expandable_playlist_list')), findsNothing);

      // Now open the playlist download view playlists list to verify that
      // the selected playlist is now the 'local' playlist selected in
      // the audio player view
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // Verify that the 'local' playlist is now selected in the playlist
      // download view since it was selected in the audio player view.
      _verifyPlaylistIsSelectedInPlaylistDownloadView(
        tester: tester,
        selectedPlaylistTitle: localPlaylistTitle,
      );

      // Return to the audio player view
      appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify the displayed audio title

      audioPlayerViewAudioTitleFinder =
          find.byKey(const Key('audioPlayerViewCurrentAudioTitle'));
      audioTitleWithDurationString =
          tester.widget<Text>(audioPlayerViewAudioTitleFinder).data!;

      expect(
        audioTitleWithDurationString,
        "$localPlaylistCurrentPlayableAudioTitle\n0:59",
      );

      // Now, in the audio player view, select the empty playlist using
      // the audio player view playlist selection button. Then verify that
      // the displayed audio title is "No audio selected".
      await _verifyAudioPlayerViewPlaylistSelectionImpact(
        tester: tester,
        playlistDownloadViewCurrentlySelectedPlaylistTitle: localPlaylistTitle,
        playlistToSelectTitle: emptyPlaylistTitle,
        playlistCurrentlyPlayableAudioTitleWithDuration: noAudioSelectedTitle,
        expectedAudioPositionTimeString: '0:00',
        expectedAudioRemainingDurationTimeString: '0:00',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''While current audio is playing, select another playlist so that the
           current audio is changed. The new current audio is not playing ! Then
           select again the previously selected playlist and verify that its current
           audio position corresponds to its position when the other playlist was
           selected while it was playing.''', (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String youtubePlaylistCurrentPlayableAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";
      const String localPlaylistTitle = 'local';
      const String emptyPlaylistTitle = 'Empty';
      const String localPlaylistCurrentPlayableAudioTitle =
          "morning _ cinematic video";
      const String noAudioSelectedTitle = "No audio selected";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Go to the audio player view
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now, in the audio player view, select the empty playlist using
      // the audio player view playlist selection button. Then verify that
      // the displayed audio title is "No audio selected".
      await _verifyAudioPlayerViewPlaylistSelectionImpact(
        tester: tester,
        playlistDownloadViewCurrentlySelectedPlaylistTitle:
            youtubePlaylistTitle,
        playlistToSelectTitle: emptyPlaylistTitle,
        playlistCurrentlyPlayableAudioTitleWithDuration: noAudioSelectedTitle,
        expectedAudioPositionTimeString: '0:00',
        expectedAudioRemainingDurationTimeString: '0:00',
      );

      // Now, in the audio player view, select the S8 audio playlist using
      // the audio player view playlist selection button. Then start playing
      // the current playable audio "Interview de Chat GPT  - IA, intelligence,
      // philosophie, géopolitique, post-vérité...".

      // Select the 'S8 audio' playlist

      // Now tap on audio player view playlist button to display the playlists
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: youtubePlaylistTitle,
      );

      // Now tap on the Play button to play the playlist current audio
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Memorizing the current audio position before selecting the
      // 'local' playlist
      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));
      final String memorizedPositionTimeString =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      // Memorizing the current audio remaining duration before
      // selecting the 'local' playlist
      Finder audioPlayerViewAudioRemainingDurationFinder =
          find.byKey(const Key('audioPlayerViewAudioRemainingDuration'));
      String memorizedRemainingDurationTimeString = tester
          .widget<Text>(audioPlayerViewAudioRemainingDurationFinder)
          .data!;

      // Now select the 'local' playlist

      String localPlaylistCurrentlyPlayableAudioTitleWithDuration =
          "$localPlaylistCurrentPlayableAudioTitle\n0:59";

      await _verifyAudioPlayerViewPlaylistSelectionImpact(
        tester: tester,
        playlistDownloadViewCurrentlySelectedPlaylistTitle:
            youtubePlaylistTitle,
        playlistToSelectTitle: localPlaylistTitle,
        playlistCurrentlyPlayableAudioTitleWithDuration:
            localPlaylistCurrentlyPlayableAudioTitleWithDuration,
        expectedAudioPositionTimeString: '0:02',
        expectedAudioRemainingDurationTimeString: '0:57',
        selectPlaylistPumpAndSettleDuration: const Duration(milliseconds: 1000),
      );

      // Ensure the play button is in play mode since the new
      // current audio is not playing
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Then select again the 'S8 audio' playlist

      await _verifyAudioPlayerViewPlaylistSelectionImpact(
        tester: tester,
        playlistDownloadViewCurrentlySelectedPlaylistTitle: localPlaylistTitle,
        playlistToSelectTitle: youtubePlaylistTitle,
        playlistCurrentlyPlayableAudioTitleWithDuration:
            "$youtubePlaylistCurrentPlayableAudioTitle\n1:17:54",
        expectedAudioPositionTimeString: memorizedPositionTimeString,
        expectedAudioRemainingDurationTimeString:
            memorizedRemainingDurationTimeString,
        selectPlaylistPumpAndSettleDuration: const Duration(milliseconds: 1000),
        positionSecondsDifference: 1,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Pictured audio sel while current audio is playing. Select another playlist
           whose current audio is pictured while the current audio of the selected
           playlist is playing. The new current audio won't be playing ! Verify its
           play/pause button status.''', (WidgetTester tester) async {
      const String jesusPlaylistTitle = 'Jésus-Christ'; // Youtube playlist
      const String jesusPlaylistCurrentPlayableAudioTitle =
          "NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE";
      const String localPlaylistTitle = 'local'; // Youtube playlist

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_picture_test',
        selectedPlaylistTitle: localPlaylistTitle,
      );

      // Go to the audio player view
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now tap on the Play button to play the playlist current audio
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Now select the 'Jésus-Christ' playlist

      await _verifyAudioPlayerViewPlaylistSelectionImpact(
        tester: tester,
        playlistDownloadViewCurrentlySelectedPlaylistTitle: localPlaylistTitle,
        playlistToSelectTitle: jesusPlaylistTitle,
        playlistCurrentlyPlayableAudioTitleWithDuration:
            "$jesusPlaylistCurrentPlayableAudioTitle\n24:07",
        expectedAudioPositionTimeString: '14:16',
        expectedAudioRemainingDurationTimeString: '9:51',
        // If this duration parm is not set, the integration test fails
        selectPlaylistPumpAndSettleDuration: const Duration(milliseconds: 1000),
      );

      // Ensure the play button is in play mode since the new
      // current audio is not playing
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Pictured audio sel while not playing current audio. Select another playlist
           whose current audio is pictured while the current audio of the selected
           playlist is not playing. The new current audio won't be playing ! Verify
           its play/pause button status.''', (WidgetTester tester) async {
      const String jesusPlaylistTitle = 'Jésus-Christ'; // Youtube playlist
      const String jesusPlaylistCurrentPlayableAudioTitle =
          "NE VOUS METTEZ PLUS JAMAIS EN COLÈRE _ SAGESSE CHRÉTIENNE";
      const String localPlaylistTitle = 'local'; // Youtube playlist

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_player_picture_test',
        selectedPlaylistTitle: localPlaylistTitle,
      );

      // Go to the audio player view
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now select the 'Jésus-Christ' playlist

      await _verifyAudioPlayerViewPlaylistSelectionImpact(
        tester: tester,
        playlistDownloadViewCurrentlySelectedPlaylistTitle: localPlaylistTitle,
        playlistToSelectTitle: jesusPlaylistTitle,
        playlistCurrentlyPlayableAudioTitleWithDuration:
            "$jesusPlaylistCurrentPlayableAudioTitle\n24:07",
        expectedAudioPositionTimeString: '14:16',
        expectedAudioRemainingDurationTimeString: '9:51',
        // If this duration parm is not set, the integration test fails
        selectPlaylistPumpAndSettleDuration: const Duration(milliseconds: 1000),
      );

      // Ensure the play button is in play mode since the new
      // current audio is not playing
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''Go to audioplayer view while no playlist is selected
                   and check a playlist in order to select its currently playable
                   audio. Then, go back to download playlist view and verify the
                   selected playlist.''', (WidgetTester tester) async {
      const String emptyPlaylistTitle = 'Empty'; // Youtube playlist
      const String noAudioSelectedTitle = "No audio selected";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: emptyPlaylistTitle,
      );

      // Unselect the 'Empty' playlist

      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: emptyPlaylistTitle,
      );

      // Then go to the audio player view
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify the no selected audio title is displayed
      expect(find.text("No audio selected"), findsOneWidget);

      // Verify that the displayed playlist title is empty
      Text selectedPlaylistTitleText =
          tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
      expect(
        selectedPlaylistTitleText.data,
        '',
      );

      // Now, in the audio player view, select the 'Empty' audio playlist using
      // the audio player view playlist selection button.

      // Select the 'Empty' playlist

      await _verifyAudioPlayerViewPlaylistSelectionImpact(
        tester: tester,
        playlistDownloadViewCurrentlySelectedPlaylistTitle: '',
        playlistToSelectTitle: emptyPlaylistTitle,
        playlistCurrentlyPlayableAudioTitleWithDuration: noAudioSelectedTitle,
        expectedAudioPositionTimeString: '0:00',
        expectedAudioRemainingDurationTimeString: '0:00',
      );

      // Now return to the playlist download view
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Verify that the 'Empty playlist is now selected in the playlist
      // download view since it was selected in the audio player view.
      _verifyPlaylistIsSelectedInPlaylistDownloadView(
        tester: tester,
        selectedPlaylistTitle: emptyPlaylistTitle,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
  group('Move audio in AudioPlayerView', () {
    testWidgets('''Selecting different playlists in order to change the playable
           audio contained in the audio player to the selected playlist
           current or past playable audio.''', (WidgetTester tester) async {
      const String emptyPlaylistTitle = 'Empty'; // Youtube playlist
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String firstDownloadedAudioTitle =
          "La surpopulation mondiale par Jancovici et Barrau";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: emptyPlaylistTitle,
      );

      // Select the 'S8 audio' playlist

      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: youtubePlaylistTitle,
      );

      // Now tap on playlist download view playlist button to close the
      // playlist list so that all the 'S8 audio' audio are displayed
      await tester.tap(find.byKey(const Key('playlist_toggle_button')));
      await tester.pumpAndSettle();

      // First, get the ListTile Text widget finder of the audio to be
      // selected and tap on it. This switches to the AudioPlayerView
      await tester.tap(find.text(firstDownloadedAudioTitle));
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Now move this audio to the 'Empty' playlist

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Now find the move audio popup menu item and tap on it
      Finder popupMoveMenuItem =
          find.byKey(const Key("popup_menu_move_audio_to_playlist"));

      await tester.tap(popupMoveMenuItem);
      await tester.pumpAndSettle();

      // Check the value of the select one playlist AlertDialog
      // dialog title
      Text alertDialogTitle = tester
          .widget(find.byKey(const Key('playlistOneSelectableDialogTitleKey')));
      expect(alertDialogTitle.data, 'Select a Playlist');

      // Find the RadioListTile target playlist to which the audio
      // will be copied

      Finder targetPlaylistRadioListTile = find.byWidgetPredicate(
        (Widget widget) =>
            widget is RadioListTile &&
            widget.title is Text &&
            (widget.title as Text).data == emptyPlaylistTitle,
      );

      // Tap the target playlist RadioListTile to select it
      await tester.tap(targetPlaylistRadioListTile);
      await tester.pumpAndSettle();

      // Now find the Confirm button and tap on it
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Verify the displayed warning or confirn dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            'Audio "La surpopulation mondiale par Jancovici et Barrau" moved from Youtube playlist "S8 audio" to local playlist "Empty".',
        isWarningConfirming: true,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });

  group('Audio comment tests', () {
    group('Playing audio comment to verify that no rewind is performed', () {
      testWidgets('''Playing from CommentAddEditDialog a comment on audio paused
             more than 1 hour ago.''', (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String alreadyCommentedAudioTitle =
            "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // Then, get the ListTile Text widget finder of the already commented
        // audio and tap on it to open the AudioPlayerView
        final Finder alreadyCommentedAudioFinder =
            find.text(alreadyCommentedAudioTitle);
        await tester.tap(alreadyCommentedAudioFinder);
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        // Tap on the comment icon button to open the comment add list
        // dialog
        final Finder commentInkWellButtonFinder = find.byKey(
          const Key('commentsInkWellButton'),
        );

        await tester.tap(commentInkWellButtonFinder);
        await tester.pumpAndSettle();

        // Tap on the comment title text to edit the comment
        String commentTitle = 'I did not thank ChatGPT';

        await tester.tap(find.text(commentTitle));
        await tester.pumpAndSettle();

        // Tap on the play/pause icon button to play the audio from the
        // comment
        await tester.tap(find.byKey(const Key('playPauseIconButton')));
        await tester.pumpAndSettle();

        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Tap on the play/pause icon button to pause the audio
        await tester.tap(find.byKey(const Key('playPauseIconButton')));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Find the Text child of the selectCommentPosition TextButton

        final Finder selectCommentPositionTextButtonFinder =
            find.byKey(const Key('selectCommentPositionTextButton'));

        final Finder selectCommentPositionTextOfButtonFinder = find.descendant(
          of: selectCommentPositionTextButtonFinder,
          matching: find.byType(Text),
        );

        // Verify that the Text widget contains the expected content

        String selectCommentPositionTextOfButton =
            tester.widget<Text>(selectCommentPositionTextOfButtonFinder).data!;

        // Ensure the audio position was not rewinded
        expect(
          selectCommentPositionTextOfButton.contains('1:17:12'),
          true,
          reason:
              'Real comment position button text value is $selectCommentPositionTextOfButton',
        );

        // Tap on the cancel comment button to close the comment
        await tester.tap(find.byKey(const Key('cancelTextButton')));
        await tester.pumpAndSettle();

        // Now close the comment list dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets('''Playing from CommentListAddDialog a comment on audio
             paused more than 1 hour ago.''', (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String alreadyCommentedAudioTitle =
            "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // Then, get the ListTile Text widget finder of the already commented
        // audio and tap on it to open the AudioPlayerView
        final Finder alreadyCommentedAudioFinder =
            find.text(alreadyCommentedAudioTitle);
        await tester.tap(alreadyCommentedAudioFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Play then pause third comment
        await IntegrationTestUtil.playCommentFromListAddDialog(
          tester: tester,
          commentPosition: 3,
          mustAudioBePaused: true,
        );

        // Verify that the Text widget contains the expected content

        final Finder audioPlayerViewAudioPositionFinder =
            find.byKey(const Key('audioPlayerViewAudioPosition'));
        String actualAudioPlayerViewCurrentAudioPosition =
            tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

        // Ensure the audio position was not rewinded
        expect(
          actualAudioPlayerViewCurrentAudioPosition,
          matcher.anyOf([equals('1:16:40'), equals('1:16:41')]),
          reason:
              'Audio Player View audio position value is $actualAudioPlayerViewCurrentAudioPosition',
        );

        // Tap on the Close button to close the comment list add dialog
        await tester.tap(find.byKey(const Key('closeDialogTextButton')));
        await tester.pumpAndSettle();

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets('''Playing from PlaylistCommentDialog a comment on audio
                     paused more than 1 hour ago.''',
          (WidgetTester tester) async {
        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // Find the playlist whose audio are commented

        // First, find the Playlist ListTile Text widget
        final Finder playlistWithCommentedAudioListTileTextWidgetFinder =
            find.text(youtubePlaylistTitle);

        // Then obtain the Playlist ListTile widget enclosing the Text widget
        // by finding its ancestor
        final Finder playlistWithCommentedAudioListTileWidgetFinder =
            find.ancestor(
          of: playlistWithCommentedAudioListTileTextWidgetFinder,
          matching: find.byType(ListTile),
        );

        // Now find the leading menu icon button of the playlist and tap on it
        final Finder playlistListTileLeadingMenuIconButton = find.descendant(
          of: playlistWithCommentedAudioListTileWidgetFinder,
          matching: find.byIcon(Icons.menu),
        );

        // Tap the leading menu icon button to open the popup menu
        await tester.tap(playlistListTileLeadingMenuIconButton);
        await tester.pumpAndSettle(); // Wait for popup menu to appear

        // Now find the playlist comment popup menu item and tap on it
        // to open the PlaylistCommentDialog
        final Finder popupDeletePlaylistMenuItem =
            find.byKey(const Key("popup_menu_display_playlist_audio_comments"));

        await tester.tap(popupDeletePlaylistMenuItem);
        await tester.pumpAndSettle();

        // Find the playlist comment list dialog widget
        final Finder commentListDialogFinder =
            find.byType(PlaylistCommentListDialog);

        // Find the list body containing the comments
        final Finder listFinder = find.descendant(
            of: commentListDialogFinder, matching: find.byType(ListBody));

        // Find all the list items
        final Finder itemsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: listFinder,
            matching: find.byType(GestureDetector));

        int gestureDectectorNumberByCommentLine = 3;

        // Since there are 3 GestureDetector per comment item, we need to
        // multiply the comment line index by 3 to get the right index
        // of "Interview de Chat GPT  - IA, intelligence, philosophie,
        // géopolitique, post-vérité..."
        int itemFinderIndex = 2 * gestureDectectorNumberByCommentLine;

        final Finder playIconButtonFinder = find.descendant(
          of: itemsFinder.at(itemFinderIndex),
          matching: find.byKey(const Key('playPauseIconButton')),
        );

        // Tap on the play/pause icon button to play the audio from the
        // comment
        await tester.tap(playIconButtonFinder);
        await tester.pumpAndSettle();

        await Future.delayed(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Tap on the play/pause icon button to pause the audio
        await tester.tap(playIconButtonFinder);
        await tester.pumpAndSettle();

        // The Audio Player View is not opened in this situation !!!

        // final Finder audioPlayerViewAudioPositionFinder =
        //     find.byKey(const Key('audioPlayerViewAudioPosition'));
        // String actualAudioPlayerViewCurrentAudioPosition =
        //     tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

        // // Ensure the audio position was not rewinded
        // expect(
        //   actualAudioPlayerViewCurrentAudioPosition,
        //   '1:16:40',
        //   reason:
        //       'Audio Player View audio position value is $actualAudioPlayerViewCurrentAudioPosition',
        // );

        // Tap on the Close button to close the playlist comment dialog
        await tester.tap(
            find.byKey(const Key('playlistCommentListCloseDialogTextButton')));
        await tester.pumpAndSettle();

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });
    testWidgets(
        '''With comment icon button, manage comments in initially empty playlist. Copy audio
           to the empty playlist, add a comment, then edit it, define start, then end, comment
           position and finally delete it.''', (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String emptyPlaylistTitle = 'Empty'; // Local empty playlist
      const String uncommentedAudioTitle =
          "La surpopulation mondiale par Jancovici et Barrau";
      const String uncommentedAudioFileNameNoExt =
          "240701-163607-La surpopulation mondiale par Jancovici et Barrau 23-12-03";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: emptyPlaylistTitle,
      );

      // Go to the audio player view
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify that the comment icon button is disabled since no
      // audio is available to be played or commented
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: kDarkAndLightDisabledIconColor,
        expectedIconBackgroundColor: Colors.black,
      );

      // Now we go back to the PlayListDownloadView in order
      // to copy an audio in the empty playlist
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Copy an uncommented audio from the Youtube playlist to
      // the empty playlist
      await IntegrationTestUtil.copyAudioFromSourceToTargetPlaylist(
        tester: tester,
        sourcePlaylistTitle: youtubePlaylistTitle,
        targetPlaylistTitle: emptyPlaylistTitle,
        audioToCopyTitle: uncommentedAudioTitle, // "La surpopulation mondiale
        //                                           par Jancovici et Barrau"
      );

      // Now we want to tap on the copied uncommented audio in the
      // empty playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, select the empty playlist
      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: emptyPlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the uncommented
      // audio copied in the empty playlist and tap on it to open the
      // AudioPlayerView
      final Finder audioTitleNotYetCommentedFinder =
          find.text(uncommentedAudioTitle);
      await tester.tap(audioTitleNotYetCommentedFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Ensure that the comment playlist directory does not exist
      final Directory directory = Directory(
          "kPlaylistDownloadRootPathWindows${path.separator}$emptyPlaylistTitle${path.separator}$kCommentDirName");

      expect(directory.existsSync(), false);

      // Verify that the comment icon button is now enabled since now
      // an audio is available to be played or commented
      Finder commentInkWellButtonFinder =
          IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: kDarkAndLightEnabledIconColor,
        expectedIconBackgroundColor: Colors.black,
      );

      // Verify the current audio position in the audio player view.

      String expectedAudioPlayerViewCurrentAudioPosition = '0:43';
      Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));
      String actualAudioPlayerViewCurrentAudioPosition =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      expect(
        expectedAudioPlayerViewCurrentAudioPosition,
        actualAudioPlayerViewCurrentAudioPosition,
      );

      // Tap on the comment icon button to open the comment add list
      // dialog
      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the comment dialog is displayed
      expect(find.text('Comments'), findsOneWidget);

      // Verify that no comment is displayed in the comment list
      final commentWidget = find.byKey(const ValueKey('commentTitleKey'));

      // Assert that no comment widgets are found
      expect(commentWidget, findsNothing);

      // Now tap on the Add comment icon button to open the add
      // edit comment dialog
      await tester
          .tap(find.byKey(const Key('addPositionedCommentIconButtonKey')));
      await tester.pumpAndSettle();

      // Verify style of title TextField and enter title text
      String commentTitle = 'Comment title';
      await IntegrationTestUtil.checkTextFieldStyleAndEnterText(
        tester: tester,
        textFieldKeyStr: 'commentTitleTextField',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        textToEnter: commentTitle,
      );

      // Verify style of comment TextField and enter comment text
      String commentText = 'Comment text';
      String commentContentTextFieldKeyStr = 'commentContentTextField';
      await IntegrationTestUtil.checkTextFieldStyleAndEnterText(
        tester: tester,
        textFieldKeyStr: commentContentTextFieldKeyStr,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        textToEnter: commentText,
      );

      // Verify audio title displayed in the comment dialog
      expect(
        find.text(uncommentedAudioTitle),
        findsOneWidget, // "La surpopulation mondiale par Jancovici
        //                  et Barrau"
      );

      // Verify the initial comment position displayed in the
      // comment start and end positions in the comment dialog.
      // This position was the audio player view position when
      // the comment dialog was opened.
      String commentStartAndEndInitialPosition =
          expectedAudioPlayerViewCurrentAudioPosition;

      final Finder commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText')); // 0:43
      final Finder commentEndTextWidgetFinder =
          find.byKey(const Key('commentEndPositionText')); // 0:43

      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 0:43
      );
      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 0:43
      );

      // Setting the comment start position in seconds ...

      // Tap three times on the forward comment start icon button, then
      // one time on the backward comment start icon button and finally
      // one time again on the forward comment start icon button to change
      // the comment start position. Since the tenth of seconds checkbox
      // is not checked, the comment start position is changed in seconds.
      final Finder forwardCommentStartIconButtonFinder =
          find.byKey(const Key('forwardCommentStartIconButton'));
      final Finder backwardCommentStartIconButtonFinder =
          find.byKey(const Key('backwardCommentStartIconButton'));

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment start position displayed in the comment
      // dialog
      const String commentStartPositionStr = '0:46';
      const String commentEndPositionStr = '0:48';

      // Obtain the current audio position in the audio player view
      audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));
      String audioPlayerViewCurrentAudioPositionStr =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data!,
        commentStartPositionStr, // 0:46
      );

      expect(
        audioPlayerViewCurrentAudioPositionStr,
        commentStartPositionStr, // 0:46
      );

      // Verify that the comment end position displayed in the comment
      // dialog is not yet modified.
      //
      // The comment end position was automatically set with the current
      // audio position in the audio player view.
      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 0:43
      );

      // Tap five times on the forward comment end icon button, then
      // one time on the backward comment end icon button and finally
      // one time again on the forward comment end icon button to change
      // the comment start position. Since the tenth of seconds checkbox
      // is not checked, the comment start position is changed in seconds.
      Finder forwardCommentEndIconButtonFinder =
          find.byKey(const Key('forwardCommentEndIconButton'));
      Finder backwardCommentEndIconButtonFinder =
          find.byKey(const Key('backwardCommentEndIconButton'));

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the comment end position displayed in the comment
      // dialog is now the expected commentEndPosition and is the same
      // as the current audio position in the audio player view.
      String actualCommentEndPositionStr =
          tester.widget<Text>(commentEndTextWidgetFinder).data!;

      expect(
        actualCommentEndPositionStr,
        commentEndPositionStr, // 0:48
      );

      // Now, modifying the comment start position in tenth of
      // seconds

      // Tap on the tenth of seconds checkbox to enable the
      // modification of the comment start position in tenth of
      // seconds
      await tester
          .tap(find.byKey(const Key('commentStartTenthOfSecondsCheckbox')));
      await tester.pumpAndSettle();

      // Verify that the comment start position is now displayed
      // with added tenth of seconds value
      String commentStartPositionWithTensOfSecond = '0:46.0';

      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data!,
        commentStartPositionWithTensOfSecond, // 0:46.0
      );

      // Tap three times on the forward comment start icon button, then
      // one time on the backward comment start icon button and finally
      // one time again on the forward comment start icon button to change
      // the comment start position. Since the tenth of seconds checkbox
      // is now checked, the comment start position is changed in tenth
      // of seconds.
      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment start position displayed in the comment
      // dialog
      String expectedCommentStartPositionWithTensOfSecond = '0:46.1';
      String actualCommentStartPositionWithTensOfSecondStr = tester
          .widget<Text>(find.byKey(const Key('commentStartPositionText')))
          .data!;

      expect(
        actualCommentStartPositionWithTensOfSecondStr,
        expectedCommentStartPositionWithTensOfSecond, // 0:46.1
        reason:
            'Expected comment start position not found. Real value: $actualCommentStartPositionWithTensOfSecondStr',
      );

      // Tap on the play/pause button to stop playing the audio
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle();

      // Tap on the comment end tenth of seconds checkbox to enable
      // displaying the comment end position with tenth of seconds
      final Finder commentEndTenthOfSecondsCheckboxFinder =
          find.byKey(const Key('commentEndTenthOfSecondsCheckbox'));
      await tester.tap(commentEndTenthOfSecondsCheckboxFinder);
      await tester.pumpAndSettle();

      String expectedCommentEndPositionWithTensOfSecondMin = '0:48.0';
      String expectedCommentEndPositionWithTensOfSecondMax = '0:48.6';

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: commentEndTextWidgetFinder,
        minPositionTimeStr: expectedCommentEndPositionWithTensOfSecondMin,
        maxPositionTimeStr: expectedCommentEndPositionWithTensOfSecondMax,
      );

      // Reset the comment end modification to seconds
      await tester.tap(commentEndTenthOfSecondsCheckboxFinder);
      await tester.pumpAndSettle();

      // Now, setting the comment end position in seconds ...

      // Tap three times on the forward comment end icon button, then
      // one time on the backward comment end icon button and finally
      // one time again on the forward comment end icon button to change
      // the comment end position. Since the tenth of seconds checkbox
      // is not checked, the comment end position is changed in seconds.
      forwardCommentEndIconButtonFinder =
          find.byKey(const Key('forwardCommentEndIconButton'));
      backwardCommentEndIconButtonFinder =
          find.byKey(const Key('backwardCommentEndIconButton'));

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Tap on the play/pause button to stop playing the audio
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle();

      // Verify the comment end position displayed in the comment
      // dialog

      String expectedCommentEndPositionSeconds =
          '0:51'; // 0:48 + 3 - 1 + 1 seconds
      String actualCommentEndPositionSecondsStr =
          tester.widget<Text>(commentEndTextWidgetFinder).data!;

      expect(
        actualCommentEndPositionSecondsStr,
        expectedCommentEndPositionSeconds, // 0:51
        reason:
            'Expected comment end position not found. Real value: $actualCommentStartPositionWithTensOfSecondStr',
      );

      // Verify the current audio position in the audio player view.
      // The audio position correspond to the comment start position
      // in seconds.
      String expectedAudioPlayerAudioPositionMin = '0:47';
      String expectedAudioPlayerAudioPositionMax = '0:49';

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: expectedAudioPlayerAudioPositionMin,
        maxPositionTimeStr: expectedAudioPlayerAudioPositionMax,
      );

      // Now, modifying the comment end position in tenth of
      // seconds

      // Tap on the tenth of seconds checkbox to enable the
      // modification of the comment end position in tenth of
      // seconds
      await tester.tap(commentEndTenthOfSecondsCheckboxFinder);
      await tester.pumpAndSettle();

      // Verify that the comment end position is now displayed
      // with added tenth of seconds value

      String expectedCommentEndPositionMin = '0:51.0';
      String expectedCommentEndPositionMax = '0:51.0';

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: commentEndTextWidgetFinder,
        minPositionTimeStr: expectedCommentEndPositionMin,
        maxPositionTimeStr: expectedCommentEndPositionMax,
      );

      // Tap three times on the forward comment end icon button, then
      // one time on the backward comment end icon button and finally
      // one time again on the forward comment end icon button to change
      // the comment end position. Since the tenth of seconds checkbox
      // is checked, the comment end position is changed in tenth of
      // seconds.
      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment end position displayed in the comment
      // dialog

      expectedCommentEndPositionMin = '0:51.3';
      expectedCommentEndPositionMax = '0:51.3';

      String actualCommentEndPositionWithTenthOfSecondsStr =
          tester.widget<Text>(commentEndTextWidgetFinder).data!;

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: commentEndTextWidgetFinder,
        minPositionTimeStr: expectedCommentEndPositionMin,
        maxPositionTimeStr: expectedCommentEndPositionMax,
      );

      // Tap on the play/pause button to stop playing the audio
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle();

      // Verify the current audio position in the audio player view.
      // The audio position correspond to the comment start position
      // in seconds.

      expectedAudioPlayerAudioPositionMin = '0:47';
      expectedAudioPlayerAudioPositionMax = '0:49';

      // If this test fails, try to rexecute it several times. If
      // the test continue to fail, restart your computer and
      // execute flutter clean, then flutter pub get and finally
      // flutter gen-l10n. This is crazy, but it solves the problem !
      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: expectedAudioPlayerAudioPositionMin,
        maxPositionTimeStr: expectedAudioPlayerAudioPositionMax,
      );

      // Tap on the add/edit comment button to save the comment

      final Finder addOrUpdateCommentTextButton =
          find.byKey(const Key('addOrUpdateCommentTextButton'));

      // Verify the add/update comment button text
      TextButton addEditTextButton =
          tester.widget<TextButton>(addOrUpdateCommentTextButton);
      expect((addEditTextButton.child! as Text).data, 'Add');

      // Tap on the add/edit comment button to save the comment
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      // Verify that the comment was correctly stored in the json file
      _verifyCommentDataStoredInCommentJsonFile(
        playlistTitle: emptyPlaylistTitle,
        audioFileNameNoExt: uncommentedAudioFileNameNoExt,
        commentTitle: commentTitle,
        commentContent: commentText,
        commentStartPositionTenthOfSecondsStr:
            actualCommentStartPositionWithTensOfSecondStr,
        commentEndPositionTenthOfSecondsStr:
            actualCommentEndPositionWithTenthOfSecondsStr,
      );

      // Verify that the comment list dialog now displays the
      // added comment

      final Finder commentListDialogFinder = find.byType(CommentListAddDialog);

      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentTitle)),
          findsOneWidget);
      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentText)),
          findsOneWidget);

      expect(
          find.descendant(
            of: commentListDialogFinder,
            matching: find.text(commentStartPositionStr), // 0:46
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: commentListDialogFinder,
            matching: find.text(expectedCommentEndPositionSeconds), // 0:51
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: commentListDialogFinder,
            matching: find.text(frenchDateFormatYy.format(DateTime.now())),
          ),
          findsOneWidget);

      // Now tap on the comment title text to edit the comment
      await tester.tap(find.text(commentTitle));
      await tester.pumpAndSettle();

      // Verify that the add/edit comment button text is now 'Update'
      addEditTextButton =
          tester.widget<TextButton>(addOrUpdateCommentTextButton);
      expect((addEditTextButton.child! as Text).data, 'Update');

      // Tap on the tenth of seconds checkbox so that the comment
      // end position is displayed ending with tenth of seconds
      await tester.tap(commentEndTenthOfSecondsCheckboxFinder);
      await tester.pumpAndSettle();

      final Finder updatableCommentEndTextWidgetFinder =
          find.byKey(const Key('commentEndPositionText')); // 0:51.3

      String updatableActualCommentEndPositionWithTenthOfSecondsStr = tester
          .widget<Text>(updatableCommentEndTextWidgetFinder)
          .data!; // 0:51.3

      expect(
        updatableActualCommentEndPositionWithTenthOfSecondsStr, // actual value on comment editing dialog
        actualCommentEndPositionWithTenthOfSecondsStr, // actual value on comment adding dialog
      );

      // Now modify the comment text

      final textFieldFinder = find.byKey(Key(commentContentTextFieldKeyStr));
      const String updatedCommentText = 'Updated comm. text';

      await tester.enterText(
        textFieldFinder,
        updatedCommentText,
      );
      await tester.pumpAndSettle();

      // Tap on the add/update comment button to save the updated comment
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      // Verify that the comment was correctly stored in the json file
      _verifyCommentDataStoredInCommentJsonFile(
        playlistTitle: emptyPlaylistTitle,
        audioFileNameNoExt: uncommentedAudioFileNameNoExt,
        commentTitle: commentTitle,
        commentContent: updatedCommentText,
        commentStartPositionTenthOfSecondsStr:
            actualCommentStartPositionWithTensOfSecondStr,
        commentEndPositionTenthOfSecondsStr:
            actualCommentEndPositionWithTenthOfSecondsStr,
      );

      // Verify that the comment list dialog now displays correctly the
      // updated comment

      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentTitle)),
          findsOneWidget);
      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentText)),
          findsNothing);
      expect(
          find.descendant(
              of: commentListDialogFinder,
              matching: find.text(updatedCommentText)),
          findsOneWidget);
      expect(
          find.descendant(
            of: commentListDialogFinder,
            matching: find.text(commentStartPositionStr),
          ),
          findsOneWidget);
      expect(
          find.descendant(
            of: commentListDialogFinder,
            matching: find.text(frenchDateFormatYy.format(DateTime.now())),
          ),
          findsOneWidget);

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Verify that the comment icon button is now highlighted since now
      // a comment exist for the audio
      commentInkWellButtonFinder = IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Now set the audio player view position to the desired comment
      // end position

      // Tap 5 times on the forward 1 minute icon button
      for (int i = 0; i < 5; i++) {
        await tester
            .tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
        await tester.pumpAndSettle();
      }

      // Verify the current audio position in the audio player view

      // expectedAudioPlayerAudioPositionMin = '5:00';
      // expectedAudioPlayerAudioPositionMax = '5:01';
      expectedAudioPlayerAudioPositionMin = '5:00'; // normally 5:48
      expectedAudioPlayerAudioPositionMax = '5:49';

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: expectedAudioPlayerAudioPositionMin,
        maxPositionTimeStr: expectedAudioPlayerAudioPositionMax,
      );

      // Tap on the comment icon button to re-open the comment list
      // dialog
      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Now tap on the comment title text to re-edit the comment
      await tester.tap(find.text(commentTitle));
      await tester.pumpAndSettle();

      // Verify that the comment end position has the same value as
      // when it was saved

      int tenthOfSeconds = DateTimeUtil.convertToTenthsOfSeconds(
        timeString: actualCommentEndPositionWithTenthOfSecondsStr,
      );

      Duration duration = Duration(milliseconds: tenthOfSeconds * 100);
      actualCommentEndPositionSecondsStr =
          duration.HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: false);

      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        DateTimeUtil.convertTimeWithTenthOfSecToTimeWithSec(
            timeWithTenthOfSecondsStr:
                actualCommentEndPositionWithTenthOfSecondsStr), // 0:51
      );

      // Verify that the audio player view audio position displayed
      // in the comment dialog is the same as the audio player view
      // audio position
      final Finder selectCommentPositionTextButtonFinder =
          find.byKey(const Key('selectCommentPositionTextButton'));

      // Find the Text child of the selectCommentPosition TextButton
      final Finder selectCommentPositionTextOfButtonFinder = find.descendant(
        of: selectCommentPositionTextButtonFinder,
        matching: find.byType(Text),
      );

      // Verify that the Text widget contains the expected content
      String commentDialogAudioPlayerViewAudioPositionWithTenthSecText =
          tester.widget<Text>(selectCommentPositionTextOfButtonFinder).data!;
      String actualAudioPlayerViewAudioPosition =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      int commentDialogAudioPlayerViewAudioPositionWithTenthSec =
          roundUpTenthOfSeconds(
        audioPositionHHMMSSWithTenthSecText:
            commentDialogAudioPlayerViewAudioPositionWithTenthSecText,
      );
      int actualAudioPlayerViewAudioPositionTenthsOfSeconds =
          DateTimeUtil.convertToTenthsOfSeconds(
              timeString: actualAudioPlayerViewAudioPosition); // 5:49

      // Adding 10 milliseconds to the actual audio player view audio
      // position avoids that the test fails sometimes because the
      // actual audio player view audio position is displayed with seconds
      // and the comment dialog audio player view audio position is
      // displayed with tenth of seconds.
      int actualAudioPlayerViewAudioPositionTenthsOfSecondsMax =
          actualAudioPlayerViewAudioPositionTenthsOfSeconds + 10;

      IntegrationTestUtil.expectWithSuccessMessage(
        actual: commentDialogAudioPlayerViewAudioPositionWithTenthSec,
        matcher: allOf(
          [
            greaterThanOrEqualTo(
                actualAudioPlayerViewAudioPositionTenthsOfSeconds),
            lessThanOrEqualTo(
                actualAudioPlayerViewAudioPositionTenthsOfSecondsMax),
          ],
        ),
        reason:
            "Expected value between $actualAudioPlayerViewAudioPositionTenthsOfSeconds and $actualAudioPlayerViewAudioPositionTenthsOfSecondsMax but obtained $commentDialogAudioPlayerViewAudioPositionWithTenthSec",
        successMessage:
            "Acceptable position between $actualAudioPlayerViewAudioPositionTenthsOfSeconds and $actualAudioPlayerViewAudioPositionTenthsOfSecondsMax is $commentDialogAudioPlayerViewAudioPositionWithTenthSec",
      );

      // Tap once on the forward comment end icon button to increase the
      // comment end position
      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Tap on the comment end checkbox to enable the modification of the
      // comment end position in tenth of seconds
      await tester.tap(commentEndTenthOfSecondsCheckboxFinder);
      await tester.pumpAndSettle();

      // Now tap twice on the backward comment end icon button to decrease
      // the comment end position of 2 tenth of seconds
      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment end position displayed in the comment dialog
      // is equal to the value when it was saved + 1 sec - 2 tenth of seconds
      int expectedCommentEndPositionInTenthOfSeconds =
          DateTimeUtil.convertToTenthsOfSeconds(
                timeString: actualCommentEndPositionSecondsStr,
              ) +
              10 -
              2;

      int actualCommentEndPositionInTenthOfSeconds =
          DateTimeUtil.convertToTenthsOfSeconds(
        timeString: tester.widget<Text>(commentEndTextWidgetFinder).data!,
      );

      expect(
          actualCommentEndPositionInTenthOfSeconds,
          inInclusiveRange(expectedCommentEndPositionInTenthOfSeconds - 5,
              expectedCommentEndPositionInTenthOfSeconds + 4));

      // Verify that the audio player view audio position displayed
      // in the comment dialog is the same as the audio player view
      // audio position

      // obtaining again the current audio position in the audio
      // player view. Since the comment end position was changed,
      // the audio player view position was also modified.
      actualAudioPlayerViewAudioPosition =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;
      int actualAudioPlayerViewAudioPositionInTenthsOfSeconds =
          DateTimeUtil.convertToTenthsOfSeconds(
        timeString: actualAudioPlayerViewAudioPosition,
      );

      // Verify that the Text widget of the text button enabling to open
      // a dialog to edit the position contains the expected content
      commentDialogAudioPlayerViewAudioPositionWithTenthSecText =
          tester.widget<Text>(selectCommentPositionTextOfButtonFinder).data!;
      expect(
        roundUpTenthOfSeconds(
          audioPositionHHMMSSWithTenthSecText:
              commentDialogAudioPlayerViewAudioPositionWithTenthSecText,
        ),
        allOf(
          [
            greaterThanOrEqualTo(
                actualAudioPlayerViewAudioPositionInTenthsOfSeconds - 10),
            lessThanOrEqualTo(
                actualAudioPlayerViewAudioPositionInTenthsOfSeconds + 10),
          ],
        ),
        reason:
            "Expected value between $actualAudioPlayerViewAudioPositionInTenthsOfSeconds and ${actualAudioPlayerViewAudioPositionInTenthsOfSeconds + 10} but obtained $commentDialogAudioPlayerViewAudioPositionWithTenthSecText",
      );

      // Now, tap on the add/update comment button to save the updated
      // comment
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      // Now tap on the delete comment icon button to delete the comment
      await tester.tap(find.byKey(const Key('deleteCommentIconButton')));
      await tester.pumpAndSettle();

      // Verify the delete comment dialog title
      expect(find.text('Delete Comment'), findsOneWidget);

      // Verify the delete comment dialog message
      expect(find.text("Deleting comment \"$commentTitle\"."), findsOneWidget);

      // Confirm the deletion of the comment
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Verify that the comment list dialog now displays no comment
      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentTitle)),
          findsNothing);

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Verify that the comment icon button is enabled but no longer
      // highlighted since no comment exist for the audio
      commentInkWellButtonFinder = IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: kDarkAndLightEnabledIconColor,
        expectedIconBackgroundColor: Colors.black,
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''With appbar comment menu, manage comments in initially empty playlist. Copy audio
           to the empty playlist, add a comment and then delete it.''',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String emptyPlaylistTitle = 'Empty'; // Local empty playlist
      const String uncommentedAudioTitle =
          "La surpopulation mondiale par Jancovici et Barrau";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: emptyPlaylistTitle,
      );

      // Go to the audio player view
      Finder appScreenNavigationButton =
          find.byKey(const ValueKey('audioPlayerViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify that the appbar left popup menu is empty since
      // no audio is available in the empty playlist

      // Tap the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // Verify that the appbar popup menu is empty
      expect(find.byType(PopupMenuItem), findsNothing);

      // Now we go back to the PlayListDownloadView in order
      // to copy an audio in the empty playlist
      appScreenNavigationButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(appScreenNavigationButton);
      await tester.pumpAndSettle();

      // Copy an uncommented audio from the Youtube playlist to
      // the empty playlist
      await IntegrationTestUtil.copyAudioFromSourceToTargetPlaylist(
        tester: tester,
        sourcePlaylistTitle: youtubePlaylistTitle,
        targetPlaylistTitle: emptyPlaylistTitle,
        audioToCopyTitle: uncommentedAudioTitle, // "La surpopulation mondiale
        //                                           par Jancovici et Barrau"
      );

      // Now we want to tap on the copied uncommented audio in the
      // empty playlist in order to open the AudioPlayerView displaying
      // the audio

      // First, select the empty playlist
      await IntegrationTestUtil.selectPlaylist(
        tester: tester,
        playlistToSelectTitle: emptyPlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the uncommented
      // audio copied in the empty playlist and tap on it to open the
      // AudioPlayerView
      final Finder audioTitleNotYetCommentedFinder =
          find.text(uncommentedAudioTitle);
      await tester.tap(audioTitleNotYetCommentedFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Ensure that the comment playlist directory does not exist
      final Directory directory = Directory(
          "kPlaylistDownloadRootPathWindows${path.separator}$emptyPlaylistTitle${path.separator}$kCommentDirName");

      expect(directory.existsSync(), false);

      // Now tap the appbar leading popup menu button which now
      // displays all the usable menu items available on an existing
      // audio.
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // Find the 'Audio Comments ...' menu item and tap on it to open the
      // comment add list dialog
      await tester
          .tap(find.byKey(const Key('appbar_popup_menu_audio_comment')));
      await tester.pumpAndSettle();

      // Verify that the comment dialog is displayed
      expect(find.text('Comments'), findsOneWidget);

      // Verify that no comment is displayed in the comment list
      final commentWidget = find.byKey(const ValueKey('commentTitleKey'));

      // Assert that no comment widgets are found
      expect(commentWidget, findsNothing);

      // Now tap on the Add comment icon button to open the add
      // edit comment dialog
      await tester
          .tap(find.byKey(const Key('addPositionedCommentIconButtonKey')));
      await tester.pumpAndSettle();

      // Verify style of title TextField and enter title text
      String commentTitle = 'Comment title';
      await IntegrationTestUtil.checkTextFieldStyleAndEnterText(
        tester: tester,
        textFieldKeyStr: 'commentTitleTextField',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        textToEnter: commentTitle,
      );

      // Verify style of comment TextField and enter comment text
      String commentText = 'Comment text';
      String commentContentTextFieldKeyStr = 'commentContentTextField';
      await IntegrationTestUtil.checkTextFieldStyleAndEnterText(
        tester: tester,
        textFieldKeyStr: commentContentTextFieldKeyStr,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        textToEnter: commentText,
      );

      // Verify audio title displayed in the comment dialog
      expect(
        find.text(uncommentedAudioTitle),
        findsOneWidget, // "La surpopulation mondiale par Jancovici
        //                  et Barrau"
      );

      String expectedAudioPlayerViewCurrentAudioPosition = '0:43';

      // Verify the initial comment position displayed in the
      // comment start and end positions in the comment dialog.
      // This position was the audio player view position when
      // the comment dialog was opened.
      String commentStartAndEndInitialPosition =
          expectedAudioPlayerViewCurrentAudioPosition;

      final Finder commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText')); // 0:43
      final Finder commentEndTextWidgetFinder =
          find.byKey(const Key('commentEndPositionText')); // 0:43

      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 0:43
      );
      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 0:43
      );

      // Tap on add text button
      final Finder addOrUpdateCommentTextButton =
          find.byKey(const Key('addOrUpdateCommentTextButton'));
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      // Verify that the comment list dialog now displays the
      // added comment

      final Finder commentListDialogFinder = find.byType(CommentListAddDialog);

      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentTitle)),
          findsOneWidget);
      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentText)),
          findsOneWidget);

      expect(
          find.descendant(
            of: commentListDialogFinder,
            matching: find.text(expectedAudioPlayerViewCurrentAudioPosition),
          ),
          findsNWidgets(2));
      expect(
          find.descendant(
            of: commentListDialogFinder,
            matching: find.text(frenchDateFormatYy.format(DateTime.now())),
          ),
          findsOneWidget);

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Now tap the appbar leading popup menu button which now
      // displays all the usable menu items available on an existing
      // audio.
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // Find the 'Audio Comments ...' menu item and tap on it to open the
      // comment add list dialog
      await tester
          .tap(find.byKey(const Key('appbar_popup_menu_audio_comment')));
      await tester.pumpAndSettle();

      // Now tap on the delete comment icon button to delete the comment
      await tester.tap(find.byKey(const Key('deleteCommentIconButton')));
      await tester.pumpAndSettle();

      // Verify the delete comment dialog title
      expect(find.text('Delete Comment'), findsOneWidget);

      // Verify the delete comment dialog message
      expect(find.text("Deleting comment \"$commentTitle\"."), findsOneWidget);

      // Confirm the deletion of the comment
      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pumpAndSettle();

      // Verify that the comment list dialog now displays no comment
      expect(
          find.descendant(
              of: commentListDialogFinder, matching: find.text(commentTitle)),
          findsNothing);

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        'Add comment near end to already commented audio. Then play comments',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_short_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      final Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify the current audio position in the audio player view.

      // Get the audio player view audio position

      final Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));
      String actualAudioPlayerViewCurrentAudioPosition =
          tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;

      // Verify that the Text widget contains the expected content
      expect(actualAudioPlayerViewCurrentAudioPosition,
          '1:12:48' // initialized in test data ...
          );

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Tap on the Add comment icon button to open the add edit comment
      // dialog
      await tester
          .tap(find.byKey(const Key('addPositionedCommentIconButtonKey')));
      await tester.pumpAndSettle();

      // Enter comment title text
      String commentTitle = 'Four';
      final Finder textFieldFinder =
          find.byKey(const Key('commentTitleTextField'));

      await tester.enterText(
        textFieldFinder,
        commentTitle,
      );
      await tester.pumpAndSettle();

      // Enter comment text
      String commentText = 'Fourth comment';
      final Finder commentContentTextFieldFinder =
          find.byKey(const Key('commentContentTextField'));

      await tester.enterText(
        commentContentTextFieldFinder,
        commentText,
      );
      await tester.pumpAndSettle();

      // Verify the initial comment position displayed in the
      // comment start and end positions in the comment dialog.
      // This position was the audio player view position when
      // the comment dialog was opened.
      String commentStartAndEndInitialPosition =
          actualAudioPlayerViewCurrentAudioPosition;

      final Finder commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText'));
      final Finder commentEndTextWidgetFinder =
          find.byKey(const Key('commentEndPositionText'));

      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 1:12:48
      );
      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 1:12:48
      );

      // Setting the comment start position in seconds ...

      // Tap two times on the backward comment start icon button
      final Finder backwardCommentStartIconButtonFinder =
          find.byKey(const Key('backwardCommentStartIconButton'));

      await tester.tap(backwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentStartIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment start position displayed in the comment
      // dialog
      String commentStartPosition = '1:12:46';
      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data!,
        commentStartPosition, // 1:12:46
      );

      // Verify that the comment end position displayed in the comment
      // dialog is not yet modified.
      //
      // The comment end position was automatically set with the current
      // audio position in the audio player view.
      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data!,
        commentStartAndEndInitialPosition, // 1:12:48
      );

      // Now, forwarding the comment end position in seconds ...

      // Tap four times on the forward comment end icon button, then 1 time
      // backward and 1 time forward
      final Finder forwardCommentEndIconButtonFinder =
          find.byKey(const Key('forwardCommentEndIconButton'));
      final Finder backwardCommentEndIconButtonFinder =
          find.byKey(const Key('backwardCommentEndIconButton'));

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify the comment end position displayed in the comment
      // dialog
      String expectedCommentEndPositionMin = '1:12:52';
      String expectedCommentEndPositionMax = '1:12:52';

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: commentEndTextWidgetFinder,
        minPositionTimeStr: expectedCommentEndPositionMin,
        maxPositionTimeStr: expectedCommentEndPositionMax,
      );

      // Now, modifying the comment end position in tenth of
      // seconds

      // Tap on the tenth of seconds checkbox to enable the
      // modification of the comment end position in tenth of
      // seconds
      await tester
          .tap(find.byKey(const Key('commentEndTenthOfSecondsCheckbox')));
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(backwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the comment end position is now displayed
      // with added tenth of seconds value

      expectedCommentEndPositionMin = '1:12:52.4';
      expectedCommentEndPositionMax = '1:12:52.4';

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: commentEndTextWidgetFinder,
        minPositionTimeStr: expectedCommentEndPositionMin,
        maxPositionTimeStr: expectedCommentEndPositionMax,
      );

      // Tap on the play/pause button to stop playing the audio
      await tester.tap(find.byKey(const Key('playPauseIconButton')));
      await tester.pumpAndSettle();

      // Tap on the add/edit comment button to save the comment

      final Finder addOrUpdateCommentTextButton =
          find.byKey(const Key('addOrUpdateCommentTextButton'));

      // Verify the add/update comment button text
      TextButton addEditTextButton =
          tester.widget<TextButton>(addOrUpdateCommentTextButton);
      expect((addEditTextButton.child! as Text).data, 'Add');

      // Tap on the add/edit comment button to save the comment
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      // Verify that the comment list dialog now displays the
      // added comment

      final Finder commentListDialogFinder = find.byType(CommentListAddDialog);

      List<String> expectedTitles = [
        'One',
        'Two',
        'Four', // created comment
        'Three',
        'I did not thank ChatGPT',
      ];

      List<String> expectedContents = [
        'First comment',
        'Second comment',
        'Fourth comment', // created comment
        'Third comment',
        'He explains why ...',
      ];

      List<String> expectedStartPositions = [
        '10:47',
        '23:47',
        '1:12:46', // created comment
        '1:16:40',
        '1:17:12',
      ];

      List<String> expectedEndPositions = [
        '10:55',
        '24:01',
        '1:12:52', // created comment
        '1:16:48',
        '1:17:19',
      ];

      List<String> expectedCreationDates = [
        '27/05/24',
        '28/05/24',
        frenchDateFormatYy.format(DateTime.now()), // created comment
        '28/05/24',
        '28/05/24',
      ];

      List<String> expectedUpdateDates = [
        '29/05/24',
        '30/05/24',
        '', // Text widget not displayed since update date == creation date
        '', // Text widget not displayed since update date == creation date
        '', // Text widget not displayed since update date == creation date
      ];

      // Verify content of each list item
      Finder itemsFinder =
          IntegrationTestUtil.verifyCommentsInCommentListDialog(
              tester: tester,
              commentListDialogFinder: commentListDialogFinder,
              commentsNumber: 5,
              expectedTitlesLst: expectedTitles,
              expectedContentsLst: expectedContents,
              expectedStartPositionsLst: expectedStartPositions,
              expectedEndPositionsLst: expectedEndPositions,
              expectedCreationDatesLst: expectedCreationDates,
              expectedUpdateDatesLst: expectedUpdateDates);

      await Future.delayed(const Duration(milliseconds: 200));

      // Now tap on first comment play icon button to ensure you can play
      // a comment located before the comment you added
      await IntegrationTestUtil.playComment(
        tester: tester,
        gestureDetectorsFinder: itemsFinder,
        itemIndex: 0,
        typeOnPauseAfterPlay: true,
      );

      // Play comments after playing a previous comment

      // Now tap on first comment play icon button
      await IntegrationTestUtil.playComment(
        tester: tester,
        gestureDetectorsFinder: itemsFinder,
        itemIndex: 0,
        typeOnPauseAfterPlay: false,
      );

      // Now tap on fourth comment play icon button
      await IntegrationTestUtil.playComment(
        tester: tester,
        gestureDetectorsFinder: itemsFinder,
        itemIndex: 9,
        typeOnPauseAfterPlay: false,
      );

      // Now tap on second comment play icon button
      await IntegrationTestUtil.playComment(
        tester: tester,
        gestureDetectorsFinder: itemsFinder,
        itemIndex: 3,
        typeOnPauseAfterPlay: false,
      );

      // Play comments after pausing a previous comment

      // Now tap on first comment play icon button
      await IntegrationTestUtil.playComment(
        tester: tester,
        gestureDetectorsFinder: itemsFinder,
        itemIndex: 0,
        typeOnPauseAfterPlay: true,
      );

      // Now tap on fourth comment play icon button
      await IntegrationTestUtil.playComment(
        tester: tester,
        gestureDetectorsFinder: itemsFinder,
        itemIndex: 9,
        typeOnPauseAfterPlay: true,
      );

      // Now tap on second comment play icon button
      await IntegrationTestUtil.playComment(
        tester: tester,
        gestureDetectorsFinder: itemsFinder,
        itemIndex: 3,
        typeOnPauseAfterPlay: true,
      );

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        'Add comment near start to already commented audio. Then play comments',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_short_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      final Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await tester.pumpAndSettle();

      // Tap on |< button to go to the beginning of the audio
      await tester
          .tap(find.byKey(const Key('audioPlayerViewSkipToStartButton')));
      await tester.pumpAndSettle();

      // Tap 5 times on the forward 1 minute icon button
      final Finder forwardOneMinuteButtonFinder =
          find.byKey(const Key('audioPlayerViewForward1mButton'));

      for (int i = 0; i < 5; i++) {
        await tester.tap(forwardOneMinuteButtonFinder);
        await tester.pumpAndSettle();
      }

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Tap on the Add comment icon button to open the add edit comment
      // dialog
      await tester
          .tap(find.byKey(const Key('addPositionedCommentIconButtonKey')));
      await tester.pumpAndSettle();

      // Enter comment title text
      String commentTitle = 'New';
      final Finder textFieldFinder =
          find.byKey(const Key('commentTitleTextField'));

      await tester.enterText(
        textFieldFinder,
        commentTitle,
      );
      await tester.pumpAndSettle();

      // Enter comment text
      String commentText = 'New comment';
      final Finder commentContentTextFieldFinder =
          find.byKey(const Key('commentContentTextField'));

      await tester.enterText(
        commentContentTextFieldFinder,
        commentText,
      );
      await tester.pumpAndSettle();

      // Now, set the comment end position in seconds

      final Finder forwardCommentEndIconButtonFinder =
          find.byKey(const Key('forwardCommentEndIconButton'));

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(forwardCommentEndIconButtonFinder);
      await tester.pumpAndSettle();

      // Saving the comment

      final Finder addOrUpdateCommentTextButton =
          find.byKey(const Key('addOrUpdateCommentTextButton'));

      // Tap on the add/edit comment button to save the comment
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      final Finder commentListDialogFinder = find.byType(CommentListAddDialog);

      // Find the list body containing the comments
      final Finder listFinder = find.descendant(
          of: commentListDialogFinder, matching: find.byType(ListBody));

      // Find all the list items
      final Finder gestureDetectorsFinder = find.descendant(
          of: listFinder, matching: find.byType(GestureDetector));

      // Check the number of items
      expect(
          gestureDetectorsFinder,
          findsNWidgets(
              15)); // Assuming there are 5 items * 3 GestureDetector per item

      // Now tap on first comment play icon button to ensure you can play
      // a comment located before the comment you added
      await IntegrationTestUtil.playComment(
        tester: tester,
        gestureDetectorsFinder: gestureDetectorsFinder,
        itemIndex: 9,
        typeOnPauseAfterPlay: true,
      );

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('Update comment created more than 1 day ago',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_short_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      final Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await tester.pumpAndSettle();

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Tap on the comment title text to edit the comment
      String commentTitle = 'I did not thank ChatGPT';

      await tester.tap(find.text(commentTitle));
      await tester.pumpAndSettle();

      // Modify comment title

      String modifiedCommentTitle = 'Modified comment';
      final Finder commentTitleTextFieldFinder =
          find.byKey(const Key('commentTitleTextField'));

      await tester.enterText(
        commentTitleTextFieldFinder,
        modifiedCommentTitle,
      );
      await tester.pumpAndSettle();

      // Modify comment text

      String modifiedCcommentText = 'Modified comment';
      final Finder commentContentTextFieldFinder =
          find.byKey(const Key('commentContentTextField'));

      await tester.enterText(
        commentContentTextFieldFinder,
        modifiedCcommentText,
      );
      await tester.pumpAndSettle();

      // Now save the updated comment

      final Finder addOrUpdateCommentTextButton =
          find.byKey(const Key('addOrUpdateCommentTextButton'));

      // Tap on the add/edit comment button to save the comment
      await tester.tap(addOrUpdateCommentTextButton);
      await tester.pumpAndSettle();

      final Finder commentListDialogFinder = find.byType(CommentListAddDialog);

      // Verify that the comment list dialog now displays the
      // added comment

      List<String> expectedTitles = [
        'One',
        'Two',
        'Three',
        modifiedCommentTitle, // updated comment
      ];

      List<String> expectedContents = [
        'First comment',
        'Second comment',
        'Third comment',
        modifiedCcommentText, // updated comment
      ];

      List<String> expectedStartPositions = [
        '10:47',
        '23:47',
        '1:16:40',
        '1:17:12', // updated comment
      ];

      List<String> expectedEndPositions = [
        '10:55',
        '24:01',
        '1:16:48',
        '1:17:19', // updated comment
      ];

      List<String> expectedCreationDates = [
        '27/05/24',
        '28/05/24',
        '28/05/24',
        '28/05/24', // updated comment
      ];

      List<String> expectedUpdateDates = [
        '29/05/24',
        '30/05/24',
        '', // Text widget not displayed since update date == creation date
        frenchDateFormat.format(DateTime.now()), // updated comment
      ];

      // Verify content of each list item
      IntegrationTestUtil.verifyCommentsInCommentListDialog(
          tester: tester,
          commentListDialogFinder: commentListDialogFinder,
          commentsNumber: 4,
          expectedTitlesLst: expectedTitles,
          expectedContentsLst: expectedContents,
          expectedStartPositionsLst: expectedStartPositions,
          expectedEndPositionsLst: expectedEndPositions,
          expectedCreationDatesLst: expectedCreationDates,
          expectedUpdateDatesLst: expectedUpdateDates);

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('3 dialogs opened, tapping outside the comment related dialogs',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      final Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Tap on the comment title text to edit the comment
      String commentTitle = 'I did not thank ChatGPT';

      await tester.tap(find.text(commentTitle));
      await tester.pumpAndSettle();

      // Now tap on select position text button to open the define position
      // dialog enabling to modify the comment start or end position

      final Finder openDefinePositionDialogTextButtonFinder =
          find.byKey(const Key('selectCommentPositionTextButton'));

      await tester.tap(openDefinePositionDialogTextButtonFinder);
      await tester.pumpAndSettle();

      // Simulate a tap outside the define position dialog to verify that
      // the dialog can not be closed by error if the user type outside it
      await tester.tapAt(const Offset(0, 0));
      await tester.pumpAndSettle();

      // Verify that the dialog is not closed
      expect(find.byType(SetValueToTargetDialog), findsOneWidget);

      // Close the define position dialog by tapping on the Cancel button
      await tester.tap(find.byKey(const Key('setValueToTargetCancelButton')));
      await tester.pumpAndSettle();

      // Simulate a tap outside the add/edit comment dialog to verify that
      // the dialog can not be closed by error if the user type outside it
      await tester.tapAt(const Offset(0, 0));
      await tester.pumpAndSettle();

      // Verify that the dialog is not closed
      expect(find.byType(CommentAddEditDialog), findsOneWidget);

      // Tap on the cancel comment button to close the dialog
      await tester.tap(find.byKey(const Key('cancelTextButton')));
      await tester.pumpAndSettle();

      // Simulate a tap outside the list comment dialog to verify that
      // the dialog can not be closed by error if the user type outside it
      await tester.tapAt(const Offset(0, 0));
      await tester.pumpAndSettle();

      // Verify that the dialog is not closed
      expect(find.byType(CommentListAddDialog), findsOneWidget);

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        'After comment list add dialog is opened, tapping outside the dialog',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      final Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Simulate a tap outside the comment list add dialog to verify that
      // the dialog can not be closed by error if the user type outside it
      await tester.tapAt(const Offset(0, 0));
      await tester.pumpAndSettle();

      // Verify that the dialog is not closed
      expect(find.byType(CommentListAddDialog), findsOneWidget);

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''After comment add/edit dialog is opened, tapping outside the comment
           related dialogs''', (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      final Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await tester.pumpAndSettle();

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Tap on the comment title text to edit the comment
      String commentTitle = 'I did not thank ChatGPT';

      await tester.tap(find.text(commentTitle));
      await tester.pumpAndSettle();

      // Simulate a tap outside the add/edit comment dialog to verify that
      // the dialog can not be closed by error if the user type outside it
      await tester.tapAt(const Offset(0, 0));
      await tester.pumpAndSettle();

      // Verify that the dialog is not closed
      expect(find.byType(CommentAddEditDialog), findsOneWidget);

      // Tap on the cancel comment button to close the dialog
      await tester.tap(find.byKey(const Key('cancelTextButton')));
      await tester.pumpAndSettle();

      // Simulate a tap outside the list comment dialog to verify that
      // the dialog can not be closed by error if the user type outside it
      await tester.tapAt(const Offset(0, 0));
      await tester.pumpAndSettle();

      // Verify that the dialog is not closed
      expect(find.byType(CommentListAddDialog), findsOneWidget);

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets('''Delete all comments and check that the comment icon button is
                  enabled but no longer highlighted. Check as well that the comment
                  file and directory was deleted.''',
        (WidgetTester tester) async {
      const String localPlaylistTitle =
          'local_delete_comment'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Jancovici m'explique l’importance des ordres de grandeur face au changement climatique";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: localPlaylistTitle,
      );

      // Verify that the comment file exists

      final String playlistCommentPath =
          '$kApplicationPathWindowsTest${path.separator}$localPlaylistTitle${path.separator}$kCommentDirName';
      final String playlistCommentFilePathName =
          "$playlistCommentPath${path.separator}240701-163521-Jancovici m'explique l’importance des ordres de grandeur face au changement climatique 22-06-12.json";

      expect(
        File(playlistCommentFilePathName).existsSync(),
        true,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      final Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Verify that the comment icon button is now highlighted since
      // several comments exist for the audio
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: Colors.white,
        expectedIconBackgroundColor: kDarkAndLightEnabledIconColor,
      );

      // Verify that the picture play/pause button is not present
      // since no picture is displayed.
      expect(
        find.byKey(const Key('picture_displayed_play_pause_button_key')),
        findsNothing,
      );

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      final Finder commentListDialogFinder = find.byType(CommentListAddDialog);

      // Find the list body containing the comments
      final Finder listFinder = find.descendant(
          of: commentListDialogFinder, matching: find.byType(ListBody));

      // Find all the list items
      final Finder gestureDetectorsFinder = find.descendant(
          of: listFinder, matching: find.byType(GestureDetector));

      // Check the number of items
      expect(
          gestureDetectorsFinder,
          findsNWidgets(
              9)); // Assuming there are 3 items * 3 GestureDetector per item

      // Now delete the 3 comments

      await deleteComment(
        tester: tester,
        gestureDetectorsFinder: gestureDetectorsFinder,
        deletedCommentIndex: 0,
        deletedCommentTitle: 'Test Title 2',
      );

      await deleteComment(
        tester: tester,
        gestureDetectorsFinder: gestureDetectorsFinder,
        deletedCommentIndex: 0,
        deletedCommentTitle: 'number 3',
      );

      await deleteComment(
        tester: tester,
        gestureDetectorsFinder: gestureDetectorsFinder,
        deletedCommentIndex: 0,
        deletedCommentTitle: 'Test Title 1',
      );

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Verify that the comment icon button is enabled but not highlighted
      // since all comments were deleted
      IntegrationTestUtil.validateInkWellButton(
        tester: tester,
        inkWellButtonKey: 'commentsInkWellButton',
        expectedIcon: Icons.bookmark_outline_outlined,
        expectedIconColor: kDarkAndLightEnabledIconColor,
        expectedIconBackgroundColor: Colors.black,
      );

      // Verify that the comment file no longer exist
      expect(
        File(playlistCommentFilePathName).existsSync(),
        false,
      );

      // Verify that the comment dir was deleted
      expect(Directory(playlistCommentPath).existsSync(), false);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Using comment position button with deleting position field and checking
        either 'Start' or 'End' checkbox. Checking 'Start' checkbox and clicking
        on 'Ok' button will set the comment start position to 0:00. Checking 'End'
        checkbox and clicking on 'Ok' button will set the comment end position to
        the audio duration value''', (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      final Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
        additionalMilliseconds: 1000,
      );

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Trying to avoid unregular integration test failure
      await Future.delayed(const Duration(milliseconds: 100));

      // Tap on the comment title text to edit the comment
      String commentTitle = 'I did not thank ChatGPT';

      await tester.tap(find.text(commentTitle));
      await tester.pumpAndSettle();

      // Now tap on select position text button to open the set
      // value to target dialog enabling to modify the comment
      // start or end position

      final Finder openDefinePositionDialogTextButtonFinder =
          find.byKey(const Key('selectCommentPositionTextButton'));

      await tester.tap(openDefinePositionDialogTextButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the Audio Player View current audio position text is
      // displayed in the define position dialog

      // This finder obtained by its key does not enable to change the
      // value of the TextField
      final Finder definePositionDialogReadTextFinder = find.byKey(
        const Key('passedValueFieldTextField'),
      );

      expect(
        tester
            .widget<TextField>(definePositionDialogReadTextFinder)
            .controller!
            .text,
        '1:12:48.0',
      );

      Finder setValueToTargetDialogFinder = find.byType(SetValueToTargetDialog);

      // This finder obtained as descendant of its enclosing dialog does
      // able to change the value of the TextField
      Finder setValueToTargetDialogEditTextFinder = find.descendant(
        of: setValueToTargetDialogFinder,
        matching: find.byType(TextField),
      );

      // Verify the TextField is focused using its focus node
      TextField textField = tester.widget<TextField>(setValueToTargetDialogEditTextFinder);
      expect(textField.focusNode?.hasFocus, isTrue, 
            reason: 'TextField should be focused when dialog opens');

      // Now empty the position in the dialog
      String positionTextToEnterWithTenthOfSeconds = '';
      textField.controller!.text = positionTextToEnterWithTenthOfSeconds;
      await tester.pumpAndSettle();

      // Select the first checkbox (Start position)
      await tester.tap(find.byKey(const Key('checkbox_0_key')));
      await tester.pumpAndSettle();

      // Tap on the Ok button to set the new position in the comment
      // previous dialog

      await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
      await tester.pumpAndSettle();

      // Check the modified comment start position in the comment dialog.

      Finder commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText'));
      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data,
        '0:00',
      );

      // Now reopen the set value to target dialog to set the comment
      // end position to the audio duration value.

      await tester.tap(openDefinePositionDialogTextButtonFinder);
      await tester.pumpAndSettle();

      // This finder obtained as descendant of its enclosing dialog does
      // able to change the value of the TextField
      setValueToTargetDialogFinder = find.byType(SetValueToTargetDialog);
      setValueToTargetDialogEditTextFinder = find.descendant(
        of: setValueToTargetDialogFinder,
        matching: find.byType(TextField),
      );

      // Verify the TextField is focused using its focus node
      textField = tester.widget<TextField>(setValueToTargetDialogEditTextFinder);
      expect(textField.focusNode?.hasFocus, isTrue, 
            reason: 'TextField should be focused when dialog opens');

      // Now empty the position in the dialog
      textField.controller!.text = positionTextToEnterWithTenthOfSeconds;
      await tester.pumpAndSettle();

      // Select the second checkbox (End position)
      await tester.tap(find.byKey(const Key('checkbox_1_key')));
      await tester.pumpAndSettle();

      // Tap on the Ok button to set the comment end position to the
      // audio duration value in the comment previous dialog.

      await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
      await tester.pumpAndSettle();

      // Check the modified comment end position in the comment dialog.
      // The position is displayed in format with tenth of seconds since
      // when opening the define position dialog, the tenth of seconds
      // checkbox was checked

      Finder commentEndTextWidgetFinder =
          find.byKey(const Key('commentEndPositionText'));

      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data,
        "1:17:53.7",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Reducing 0:00 or increasing end comment position already at audio duration.
           Verifying that setting negative start position as well as increasing the end
           position after the audio duration is not possible.''',
        (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      final Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
        additionalMilliseconds: 1000,
      );

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Trying to avoid unregular integration test failure
      await Future.delayed(const Duration(milliseconds: 100));

      // Tap on the comment title text to edit the comment
      String commentTitle = 'I did not thank ChatGPT';

      await tester.tap(find.text(commentTitle));
      await tester.pumpAndSettle();

      // Now tap on select position text button to open the set
      // value to target dialog enabling to modify the comment
      // start or end position

      final Finder openDefinePositionDialogTextButtonFinder =
          find.byKey(const Key('selectCommentPositionTextButton'));

      await tester.tap(openDefinePositionDialogTextButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the Audio Player View current audio position text is
      // displayed in the define position dialog

      Finder setValueToTargetDialogFinder = find.byType(SetValueToTargetDialog);

      // This finder obtained as descendant of its enclosing dialog does
      // able to change the value of the TextField
      Finder setValueToTargetDialogEditTextFinder = find.descendant(
        of: setValueToTargetDialogFinder,
        matching: find.byType(TextField),
      );

      // Now empty the position in the dialog
      String positionTextToEnterWithTenthOfSeconds = '';
      tester
          .widget<TextField>(setValueToTargetDialogEditTextFinder)
          .controller!
          .text = positionTextToEnterWithTenthOfSeconds;
      await tester.pumpAndSettle();

      // Select the first checkbox (Start position)
      await tester.tap(find.byKey(const Key('checkbox_0_key')));
      await tester.pumpAndSettle();

      // Tap on the Ok button to set the new position in the comment
      // previous dialog

      await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
      await tester.pumpAndSettle();

      // Check the modified comment start position in the comment dialog.

      Finder commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText'));
      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data,
        '0:00',
      );

      // Now reopen the set value to target dialog to set the comment
      // end position to the audio duration value.

      await tester.tap(openDefinePositionDialogTextButtonFinder);
      await tester.pumpAndSettle();

      // This finder obtained as descendant of its enclosing dialog does
      // able to change the value of the TextField
      setValueToTargetDialogFinder = find.byType(SetValueToTargetDialog);
      setValueToTargetDialogEditTextFinder = find.descendant(
        of: setValueToTargetDialogFinder,
        matching: find.byType(TextField),
      );

      // Now empty the position field in the dialog
      String positionTextToEnterInSeconds = '';
      tester
          .widget<TextField>(setValueToTargetDialogEditTextFinder)
          .controller!
          .text = positionTextToEnterInSeconds;
      await tester.pumpAndSettle();

      // Select the second checkbox (End position)
      await tester.tap(find.byKey(const Key('checkbox_1_key')));
      await tester.pumpAndSettle();

      // Tap on the Ok button to set the comment end position to the
      // audio duration value in the comment previous dialog.

      await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
      await tester.pumpAndSettle();

      // Check the modified comment end position in the comment dialog.
      // The position is displayed in format with tenth of seconds since
      // when opening the define position dialog, the tenth of seconds
      // checkbox was checked

      Finder commentEndTextWidgetFinder =
          find.byKey(const Key('commentEndPositionText'));

      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data,
        "1:17:53.7",
      );

      // Now type several times on the reduce start position button to
      // set the start position to a negative value
      final Finder reduceStartPositionButtonFinder = find.byKey(
        const Key('backwardCommentStartIconButton'),
      );

      await tester.tap(reduceStartPositionButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(reduceStartPositionButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(reduceStartPositionButtonFinder);
      await tester.pumpAndSettle();

      // Verify 0:00 was not changed
      commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText'));
      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data,
        '0:00',
      );

      // Now type several times on the increase end position button to
      // increase the end position to a value greater than the audio
      // duration value
      final Finder increaseEndPositionButtonFinder = find.byKey(
        const Key('forwardCommentEndIconButton'),
      );

      await tester.tap(increaseEndPositionButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(increaseEndPositionButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(increaseEndPositionButtonFinder);
      await tester.pumpAndSettle();

      // Verify the audio duration comment end position was not
      // changed

      commentEndTextWidgetFinder =
          find.byKey(const Key('commentEndPositionText'));

      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data,
        "1:17:53.7",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Clicking on comment position button uses SetValueToTargetDialog
           to set comment positions. At the end of this test, defining a
           negative comment position as well as a comment position greater than
           the audio duration is tested.''', (WidgetTester tester) async {
      const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
      const String alreadyCommentedAudioTitle =
          "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'audio_comment_test',
        selectedPlaylistTitle: youtubePlaylistTitle,
      );

      // Then, get the ListTile Text widget finder of the already commented
      // audio and tap on it to open the AudioPlayerView
      final Finder alreadyCommentedAudioFinder =
          find.text(alreadyCommentedAudioTitle);
      await tester.tap(alreadyCommentedAudioFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
        additionalMilliseconds: 1000,
      );

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      // Trying to avoid unregular integration test failure
      await Future.delayed(const Duration(milliseconds: 100));

      // Tap on the comment title text to edit the comment
      String commentTitle = 'I did not thank ChatGPT';

      await tester.tap(find.text(commentTitle));
      await tester.pumpAndSettle();

      // Now tap on select position text button to open the set
      // value to target dialog enabling to modify the comment
      // start or end position

      final Finder openDefinePositionDialogTextButtonFinder =
          find.byKey(const Key('selectCommentPositionTextButton'));

      await tester.tap(openDefinePositionDialogTextButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the Audio Player View current audio position text is
      // displayed in the define position dialog

      // This finder obtained by its key does not enable to change the
      // value of the TextField
      final Finder definePositionDialogReadTextFinder = find.byKey(
        const Key('passedValueFieldTextField'),
      );

      expect(
        tester
            .widget<TextField>(definePositionDialogReadTextFinder)
            .controller!
            .text,
        '1:12:48.0',
      );

      Finder setValueToTargetDialogFinder = find.byType(SetValueToTargetDialog);

      // This finder obtained as descendant of its enclosing dialog does
      // able to change the value of the TextField
      Finder setValueToTargetDialogEditTextFinder = find.descendant(
        of: setValueToTargetDialogFinder,
        matching: find.byType(TextField),
      );

      // Now modify the position in the dialog
      String positionTextToEnterWithTenthOfSeconds = '0:55.6';
      tester
          .widget<TextField>(setValueToTargetDialogEditTextFinder)
          .controller!
          .text = positionTextToEnterWithTenthOfSeconds;
      await tester.pumpAndSettle();

      // Select the first checkbox (Start position)
      await tester.tap(find.byKey(const Key('checkbox_0_key')));
      await tester.pumpAndSettle();

      // Tap on the Ok button to set the new position in the comment
      // previous dialog

      await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
      await tester.pumpAndSettle();

      // Check the modified comment start position in the comment dialog.
      // The position is displayed in format with tenth of seconds since
      // the position sended by the define position dialog was formatted
      // with tenth of seconds

      Finder commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText'));
      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data,
        '0:55.6',
      );

      // Now reopen the set value to target dialog to set the comment
      // start position to a value not formatted with tenth of seconds

      await tester.tap(openDefinePositionDialogTextButtonFinder);
      await tester.pumpAndSettle();

      // This finder obtained as descendant of its enclosing dialog does
      // able to change the value of the TextField
      setValueToTargetDialogFinder = find.byType(SetValueToTargetDialog);
      setValueToTargetDialogEditTextFinder = find.descendant(
        of: setValueToTargetDialogFinder,
        matching: find.byType(TextField),
      );

      // Now modify the position in the dialog with no tenth of seconds
      String positionTextToEnterInSeconds = '0:58';
      tester
          .widget<TextField>(setValueToTargetDialogEditTextFinder)
          .controller!
          .text = positionTextToEnterInSeconds;
      await tester.pumpAndSettle();

      // Select the first checkbox (Start position)
      await tester.tap(find.byKey(const Key('checkbox_0_key')));
      await tester.pumpAndSettle();

      // Tap on the Ok button to set the new position in the comment
      // previous dialog

      await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
      await tester.pumpAndSettle();

      // Check the modified comment start position in the comment dialog.
      // The position is displayed in format with tenth of seconds since
      // when opening the define position dialog, the tenth of seconds
      // checkbox was checked

      commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText'));

      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data,
        "$positionTextToEnterInSeconds.0", // 0:58.0
      );

      // Now click on the start position checkbox to disable displaying
      // the tenth of seconds part
      await tester
          .tap(find.byKey(const Key('commentStartTenthOfSecondsCheckbox')));
      await tester.pumpAndSettle();

      // Now reopen the set value to target dialog to set again the comment
      // start position to a value not formatted with tenth of seconds.
      // This time, the seconds only format will remain in the comment
      // start position field.

      await tester.tap(openDefinePositionDialogTextButtonFinder);
      await tester.pumpAndSettle();

      // This finder obtained as descendant of its enclosing dialog does
      // able to change the value of the TextField
      setValueToTargetDialogFinder = find.byType(SetValueToTargetDialog);
      setValueToTargetDialogEditTextFinder = find.descendant(
        of: setValueToTargetDialogFinder,
        matching: find.byType(TextField),
      );

      // Now modify the position in the dialog with no tenth of seconds
      positionTextToEnterInSeconds = '0:59';
      tester
          .widget<TextField>(setValueToTargetDialogEditTextFinder)
          .controller!
          .text = positionTextToEnterInSeconds;
      await tester.pumpAndSettle();

      // Select the first checkbox (Start position)
      await tester.tap(find.byKey(const Key('checkbox_0_key')));
      await tester.pumpAndSettle();

      // Tap on the Ok button to set the new position in the comment
      // previous dialog

      await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
      await tester.pumpAndSettle();

      // Check the modified comment start position in the comment dialog.
      // The position is displayed in seconds only format since when
      // the define position dialog was opened, the tenth of seconds
      // checkbox was not checked

      commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText'));

      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data,
        '0:59',
      );

      // Now reopen the set value to target dialog to set again the comment
      // start position to a value formatted with tenth of seconds,
      // but with a 0 tenth of seconds part. This time, the seconds only
      // format will remain in the comment start position field since
      // the tenth of seconds part is 0.

      await tester.tap(openDefinePositionDialogTextButtonFinder);
      await tester.pumpAndSettle();

      // This finder obtained as descendant of its enclosing dialog does
      // able to change the value of the TextField
      setValueToTargetDialogFinder = find.byType(SetValueToTargetDialog);
      setValueToTargetDialogEditTextFinder = find.descendant(
        of: setValueToTargetDialogFinder,
        matching: find.byType(TextField),
      );

      // Now modify the position in the dialog with no tenth of seconds
      positionTextToEnterWithTenthOfSeconds = '0:57.0';
      tester
          .widget<TextField>(setValueToTargetDialogEditTextFinder)
          .controller!
          .text = positionTextToEnterWithTenthOfSeconds;
      await tester.pumpAndSettle();

      // Select the first checkbox (Start position)
      await tester.tap(find.byKey(const Key('checkbox_0_key')));
      await tester.pumpAndSettle();

      // Tap on the Ok button to set the new position in the comment
      // previous dialog

      await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
      await tester.pumpAndSettle();

      // Check the modified comment start position in the comment dialog.
      // The position is displayed in seconds only format since the
      // passed value was formatted with tenth of seconds, but with a
      // 0 tenth of seconds part.

      commentStartTextWidgetFinder =
          find.byKey(const Key('commentStartPositionText'));

      expect(
        tester.widget<Text>(commentStartTextWidgetFinder).data,
        '0:57',
      );

      // Now reopen the set value to target dialog to set the comment
      // end position to a value formatted with tenth of seconds.

      await tester.tap(openDefinePositionDialogTextButtonFinder);
      await tester.pumpAndSettle();

      // This finder obtained as descendant of its enclosing dialog does
      // able to change the value of the TextField
      setValueToTargetDialogFinder = find.byType(SetValueToTargetDialog);
      setValueToTargetDialogEditTextFinder = find.descendant(
        of: setValueToTargetDialogFinder,
        matching: find.byType(TextField),
      );

      // Now modify the position in the dialog with tenth of seconds
      positionTextToEnterWithTenthOfSeconds = '1:15:45.3';
      tester
          .widget<TextField>(setValueToTargetDialogEditTextFinder)
          .controller!
          .text = positionTextToEnterWithTenthOfSeconds;
      await tester.pumpAndSettle();

      // Select the second checkbox (End position)
      await tester.tap(find.byKey(const Key('checkbox_1_key')));
      await tester.pumpAndSettle();

      // Tap on the Ok button to set the new position in the comment
      // previous dialog

      await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
      await tester.pumpAndSettle();

      // Check the modified comment end position in the comment dialog.

      final Finder commentEndTextWidgetFinder =
          find.byKey(const Key('commentEndPositionText'));

      expect(
        tester.widget<Text>(commentEndTextWidgetFinder).data,
        '1:15:45.3',
      );

      // Now reopen the set value to target dialog to set the comment
      // end position to a value formatted with tenth of seconds.

      await tester.tap(openDefinePositionDialogTextButtonFinder);
      await tester.pumpAndSettle();

      // This finder obtained as descendant of its enclosing dialog does
      // able to change the value of the TextField
      setValueToTargetDialogFinder = find.byType(SetValueToTargetDialog);
      setValueToTargetDialogEditTextFinder = find.descendant(
        of: setValueToTargetDialogFinder,
        matching: find.byType(TextField),
      );

      // Now modify the position in the dialog with tenth of seconds
      positionTextToEnterWithTenthOfSeconds = '1:15:45.9';
      tester
          .widget<TextField>(setValueToTargetDialogEditTextFinder)
          .controller!
          .text = positionTextToEnterWithTenthOfSeconds;
      await tester.pumpAndSettle();

      // Tap on the Ok button to set the new position in the comment
      // previous dialog without checking any checkbox

      await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
      await tester.pumpAndSettle();

      // Since no checkbox was checked, a warning will be displayed ...

      // Verify the displayed warning or confirn dialog
      await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
        tester: tester,
        warningDialogMessage:
            "No checkbox selected. Please select one checkbox before clicking 'Ok', or click 'Cancel' to exit.",
        isWarningConfirming: false,
      );

      await simulateEnteringTooBigAndTooSmallAudioPosition(
          tester: tester,
          setValueToTargetDialogEditTextFinder:
              setValueToTargetDialogEditTextFinder,
          doSetStartOrEndCheckbox: false);

      await simulateEnteringTooBigAndTooSmallAudioPosition(
          tester: tester,
          setValueToTargetDialogEditTextFinder:
              setValueToTargetDialogEditTextFinder,
          doSetStartOrEndCheckbox: true);

      // Close the define position dialog by tapping on the Cancel button
      await tester.tap(find.byKey(const Key('setValueToTargetCancelButton')));
      await tester.pumpAndSettle();

      // Tap on the add/edit comment button to save the comment
      await tester.tap(find.byKey(const Key('addOrUpdateCommentTextButton')));
      await tester.pumpAndSettle();

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Verify that while the commented audio is playing, after opening the
           comment list add dialog and closing it without having played a comment,
           the audio remains playing and after its end is reached, the partially
           listened last downloaded audio start playing.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String secondDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';
      const String lastDownloadedAudioTitleWithDuration =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)\n20:32";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName:
            'audio_player_view_first_to_last_audio_corrected_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the secondly downloaded audio of the
      // playlist in order to start playing it.
      //
      // Get the second downloaded audio ListTile Text widget
      // finder and tap on it
      final Finder secondDownloadedAudioListTileTextWidgetFinder =
          find.text(secondDownloadedAudioTitle);

      await tester.tap(secondDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Now we tap on the play button in order to finish
      // playing the audio downloaded after the first downloaded
      // audio and start playing the first downloaded audio of the
      // playlist.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Tap on the comment icon button to open the comment add list
      // dialog
      final Finder commentInkWellButtonFinder = find.byKey(
        const Key('commentsInkWellButton'),
      );

      await tester.tap(commentInkWellButtonFinder);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Click on the pause button to stop the first downloaded audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the last downloaded played audio title
      expect(find.text(lastDownloadedAudioTitleWithDuration), findsOneWidget);

      // Ensure that the bug corrected on AudioPlayerVM on 06-06-2024
      // no longer happens. This bug impacted the application during
      // 3 weeks before it was discovered !!!!
      final Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '20:11',
        maxPositionTimeStr: '20:16',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Using appbar menu. Verify that while the commented audio is playing, after opening the
           comment list add dialog and closing it without having played a comment,
           the audio remains playing and after its end is reached, the partially
           listened last downloaded audio start playing.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String secondDownloadedAudioTitle =
          'Ce qui va vraiment sauver notre espèce par Jancovici et Barrau';
      const String lastDownloadedAudioTitleWithDuration =
          "3 fois où un économiste m'a ouvert les yeux (Giraud, Lefournier, Porcher)\n20:32";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName:
            'audio_player_view_first_to_last_audio_corrected_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Now we want to tap on the secondly downloaded audio of the
      // playlist in order to start playing it.
      //
      // Get the second downloaded audio ListTile Text widget
      // finder and tap on it
      final Finder secondDownloadedAudioListTileTextWidgetFinder =
          find.text(secondDownloadedAudioTitle);

      await tester.tap(secondDownloadedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Now we tap on the play button in order to finish
      // playing the audio downloaded after the first downloaded
      // audio and start playing the first downloaded audio of the
      // playlist.

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Tap on the appbar leading popup menu button
      await tester.tap(find.byKey(const Key('appBarLeadingPopupMenuWidget')));
      await tester.pumpAndSettle();

      // Find the 'Audio Comments ...' menu item and tap on it to open the
      // comment add list dialog
      await tester
          .tap(find.byKey(const Key('appbar_popup_menu_audio_comment')));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Now close the comment list dialog
      await tester.tap(find.byKey(const Key('closeDialogTextButton')));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Click on the pause button to stop the first downloaded audio
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify the last downloaded played audio title
      expect(find.text(lastDownloadedAudioTitleWithDuration), findsOneWidget);

      // Ensure that the bug corrected on AudioPlayerVM on 06-06-2024
      // no longer happens. This bug impacted the application during
      // 3 weeks before it was discovered !!!!
      final Finder audioPlayerViewAudioPositionFinder =
          find.byKey(const Key('audioPlayerViewAudioPosition'));

      IntegrationTestUtil.verifyPositionBetweenMinMax(
        tester: tester,
        textWidgetFinder: audioPlayerViewAudioPositionFinder,
        minPositionTimeStr: '20:11',
        maxPositionTimeStr: '20:16',
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    group('Tests executable only with audioplayers 6.4.0 or higher', () {
      testWidgets(
          '''Verify that after typing once on the decrease end position comment button in very short
           comment (0:00 to 0:04) the comment plays till 0:03 seconds and not later.''',
          (WidgetTester tester) async {
        final String audioplayersVersion =
            await IntegrationTestUtil.getAudioplayersVersion();

        if (audioplayersVersion == '^5.2.1') {
          // This test is not executable with audioplayers 5.2.1
          return;
        }

        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String alreadyCommentedAudioTitle =
            "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";

        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // Then, get the ListTile Text widget finder of the already commented
        // audio and tap on it to open the AudioPlayerView
        final Finder alreadyCommentedAudioFinder =
            find.text(alreadyCommentedAudioTitle);
        await tester.tap(alreadyCommentedAudioFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Tap on the comment icon button to open the comment add list
        // dialog
        final Finder commentInkWellButtonFinder = find.byKey(
          const Key('commentsInkWellButton'),
        );

        await tester.tap(commentInkWellButtonFinder);
        await tester.pumpAndSettle();

        // Tap on the comment title text to edit the comment
        String commentTitle = 'I did not thank ChatGPT';

        await tester.tap(find.text(commentTitle));
        await tester.pumpAndSettle();

        // Now tap on select position text button to open the set
        // value to target dialog enabling to modify the comment
        // start position to 0:00

        final Finder openDefinePositionDialogTextButtonFinder =
            find.byKey(const Key('selectCommentPositionTextButton'));

        await tester.tap(openDefinePositionDialogTextButtonFinder);
        await tester.pumpAndSettle();

        Finder setValueToTargetDialogFinder =
            find.byType(SetValueToTargetDialog);

        // This finder obtained as descendant of its enclosing dialog does
        // able to change the value of the TextField
        Finder setValueToTargetDialogEditTextFinder = find.descendant(
          of: setValueToTargetDialogFinder,
          matching: find.byType(TextField),
        );

        // Now empty the position in the dialog
        String positionTextToEnterWithTenthOfSeconds = '';
        tester
            .widget<TextField>(setValueToTargetDialogEditTextFinder)
            .controller!
            .text = positionTextToEnterWithTenthOfSeconds;
        await tester.pumpAndSettle();

        // Select the first checkbox (Start position)
        await tester.tap(find.byKey(const Key('checkbox_0_key')));
        await tester.pumpAndSettle();

        // Tap on the Ok button to set the new position in the comment
        // previous dialog

        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Check the modified comment start position in the comment dialog.

        Finder commentStartTextWidgetFinder =
            find.byKey(const Key('commentStartPositionText'));
        expect(
          tester.widget<Text>(commentStartTextWidgetFinder).data,
          '0:00',
        );

        // Now reopen the set value to target dialog to set the comment
        // end position to 0:04 position.

        await tester.tap(openDefinePositionDialogTextButtonFinder);
        await tester.pumpAndSettle();

        // This finder obtained as descendant of its enclosing dialog does
        // able to change the value of the TextField
        setValueToTargetDialogFinder = find.byType(SetValueToTargetDialog);
        setValueToTargetDialogEditTextFinder = find.descendant(
          of: setValueToTargetDialogFinder,
          matching: find.byType(TextField),
        );

        // Now set the position field in the dialog
        String positionTextToEnterInSeconds = '0:04';
        tester
            .widget<TextField>(setValueToTargetDialogEditTextFinder)
            .controller!
            .text = positionTextToEnterInSeconds;
        await tester.pumpAndSettle();

        // Select the second checkbox (End position)
        await tester.tap(find.byKey(const Key('checkbox_1_key')));
        await tester.pumpAndSettle();

        // Tap on the Ok button to set the comment end position to
        // 0:04

        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Check the modified comment end position in the comment dialog

        Finder commentEndTextWidgetFinder =
            find.byKey(const Key('commentEndPositionText'));

        expect(
          tester.widget<Text>(commentEndTextWidgetFinder).data,
          positionTextToEnterInSeconds, // '0:04'
        );

        // Verify the value of the position text button which
        // corresponds to the current audio position

        // Find the Text child of the selectCommentPosition TextButton
        Finder selectCommentPositionTextButtonFinder =
            find.byKey(const Key('selectCommentPositionTextButton'));
        Finder selectCommentPositionTextOfButtonFinder = find.descendant(
          of: selectCommentPositionTextButtonFinder,
          matching: find.byType(Text),
        );

        // Verify that the Text widget contains the expected content

        String selectCommentPositionTextOfButton =
            tester.widget<Text>(selectCommentPositionTextOfButtonFinder).data!;
        expect(selectCommentPositionTextOfButton, '1:12:48.0');

        // Verify that the audio position is '1:12:48'
        Finder audioPositionTextWidgetFinder =
            find.byKey(const Key('audioPlayerViewAudioPosition'));
        expect(
            tester.widget<Text>(audioPositionTextWidgetFinder).data, '1:12:48');

        // Now type one time on the reduce end position button to
        // set the end position to 0:03. This will start the audio
        // playback at 0:00 and stop it at 0:03.
        final Finder reduceEndPositionButtonFinder = find.byKey(
          const Key('backwardCommentEndIconButton'),
        );

        await tester.tap(reduceEndPositionButtonFinder);
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        // Check the modified comment end position in the comment dialog

        commentEndTextWidgetFinder =
            find.byKey(const Key('commentEndPositionText'));

        expect(
          tester.widget<Text>(commentEndTextWidgetFinder).data,
          '0:03',
        );
        // Now wait during 2 seconds to verify that the audio is not
        // playing after the end position of the comment which was
        // set to 0:03.
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        // Verify also the value of the position text button

        // Edited comment and audio player view position verification
        _verifyPositionValueAfterCommentWasPlayed(
          tester: tester,
          commentPositionTextButtonInTenthSecondsMin: 20,
          commentPositionTextButtonInTenthSecondsMax: 30,
          audioPlayerViewAudioPositionMin: '0:02',
          audioPlayerViewAudioPositionMax: '0:03',
        );

        // Now click on the play button to play the comment
        await tester.tap(find.byKey(const Key('playPauseIconButton')));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        // Wait during 2 seconds to verify that the audio is not
        // playing after the end position of the comment which was
        // set to 0:03.
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        // Edited comment and audio player view position verification
        _verifyPositionValueAfterCommentWasPlayed(
          tester: tester,
          commentPositionTextButtonInTenthSecondsMin: 20,
          commentPositionTextButtonInTenthSecondsMax: 30,
          audioPlayerViewAudioPositionMin: '0:02',
          audioPlayerViewAudioPositionMax: '0:03',
        );

        // Now update the comment

        final Finder addOrUpdateCommentTextButton =
            find.byKey(const Key('addOrUpdateCommentTextButton'));

        // Tap on the add/update comment button to save the comment
        await tester.tap(addOrUpdateCommentTextButton);
        await tester.pumpAndSettle();

        await tester.drag(
          find.byType(CommentListAddDialog),
          const Offset(
              0, 600), // Negative value for vertical drag to scroll down
        );
        await tester.pumpAndSettle();

        Finder audioCommentsLstFinder = find.byKey(const Key(
          'audioCommentsListKey',
        ));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: audioCommentsLstFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the first audio comment
        // in order to start playing it
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 0, // First comment of the audio on IA
          typeOnPauseAfterPlay: false,
          maxPlayDurationSeconds: 2,
        );

        await tester.pumpAndSettle();

        // Without dragging the comment list dialog, the audio
        // won't play !
        await tester.drag(
          find.byType(CommentListAddDialog),
          const Offset(
              0, 600), // Negative value for vertical drag to scroll down
        );
        await tester.pumpAndSettle();

        // Now tap a second time on the play icon button of the first audio comment
        // in order to start playing it
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 0, // First comment of the audio on IA
          typeOnPauseAfterPlay: false,
          maxPlayDurationSeconds: 2,
        );

        await tester.pumpAndSettle();

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Audio speed 0.5. Set the fourth comment end position to 1:17:15 and verify
            that the comment stops at 1:17:15. Verify that after typing once on the decrease
            end position button, the comment plays till 1:17:14 seconds and not later.''',
          (WidgetTester tester) async {
        final String audioplayersVersion =
            await IntegrationTestUtil.getAudioplayersVersion();

        if (audioplayersVersion == '^5.2.1') {
          // This test is not executable with audioplayers 5.2.1
          return;
        }

        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String alreadyCommentedAudioTitle =
            "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // Then, get the ListTile Text widget finder of the already commented
        // audio and tap on it to open the AudioPlayerView
        final Finder alreadyCommentedAudioFinder =
            find.text(alreadyCommentedAudioTitle);
        await tester.tap(alreadyCommentedAudioFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Set the audio speed to 0.5
        await IntegrationTestUtil.setAudioSpeed(
          tester: tester,
          audioSpeed: 0.7,
          minusTapNumber: 2, // to reduce the speed from 0.7 0.5
        );

        // Tap on the comment icon button to open the comment add list
        // dialog
        final Finder commentInkWellButtonFinder = find.byKey(
          const Key('commentsInkWellButton'),
        );

        await tester.tap(commentInkWellButtonFinder);
        await tester.pumpAndSettle();

        // Tap on the comment title text to edit the comment
        String commentTitle = 'I did not thank ChatGPT';

        await tester.tap(find.text(commentTitle));
        await tester.pumpAndSettle();

        // Now open the set value to target dialog to set the comment
        // end position to 1:17:15 position.

        final Finder openDefinePositionDialogTextButtonFinder =
            find.byKey(const Key('selectCommentPositionTextButton'));

        await tester.tap(openDefinePositionDialogTextButtonFinder);
        await tester.pumpAndSettle();

        Finder setValueToTargetDialogFinder =
            find.byType(SetValueToTargetDialog);

        // This finder obtained as descendant of its enclosing dialog does
        // able to change the value of the TextField
        Finder setValueToTargetDialogEditTextFinder = find.descendant(
          of: setValueToTargetDialogFinder,
          matching: find.byType(TextField),
        );

        // Now set the position field in the dialog
        String positionTextToEnterInSeconds = '1:17:15';
        tester
            .widget<TextField>(setValueToTargetDialogEditTextFinder)
            .controller!
            .text = positionTextToEnterInSeconds;
        await tester.pumpAndSettle();

        // Select the second checkbox (End position)
        await tester.tap(find.byKey(const Key('checkbox_1_key')));
        await tester.pumpAndSettle();

        // Tap on the Ok button to set the comment end position to
        // 1:17:15

        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Check the modified comment end position in the comment dialog

        Finder commentEndTextWidgetFinder =
            find.byKey(const Key('commentEndPositionText'));

        expect(
          tester.widget<Text>(commentEndTextWidgetFinder).data,
          positionTextToEnterInSeconds, // '1:17:15'
        );

        // Verify the value of the position text button which
        // corresponds to the current audio position

        // Find the Text child of the selectCommentPosition TextButton
        Finder selectCommentPositionTextButtonFinder =
            find.byKey(const Key('selectCommentPositionTextButton'));
        Finder selectCommentPositionTextOfButtonFinder = find.descendant(
          of: selectCommentPositionTextButtonFinder,
          matching: find.byType(Text),
        );

        // Verify that the Text widget contains the expected content

        String selectCommentPositionTextOfButton =
            tester.widget<Text>(selectCommentPositionTextOfButtonFinder).data!;
        expect(selectCommentPositionTextOfButton, '1:12:48.0');

        // Verify that the audio position is '1:12:48'
        Finder audioPositionTextWidgetFinder =
            find.byKey(const Key('audioPlayerViewAudioPosition'));
        expect(
            tester.widget<Text>(audioPositionTextWidgetFinder).data, '1:12:48');

        // Now click on the play button to play the comment
        await tester.tap(find.byKey(const Key('playPauseIconButton')));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Wait during 3 seconds to verify that the audio is not
        // playing after the end position of the comment which was 1:17:15
        await Future.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        logger.i('****** Is the audio stopped ? ');

        // Edited comment and audio player view position verification
        _verifyPositionValueAfterCommentWasPlayed(
          tester: tester,
          commentPositionTextButtonInTenthSecondsMin: 46344,
          commentPositionTextButtonInTenthSecondsMax: 46349,
          audioPlayerViewAudioPositionMin: '1:17:14',
          audioPlayerViewAudioPositionMax: '1:17:15',
        );

        // Now type one time on the reduce end position button to
        // set the end position to 1:17:14. This will start the audio
        // playback at 1:17:12 and stop it at 1:17:14.
        Finder reduceEndPositionButtonFinder = find.byKey(
          const Key('backwardCommentEndIconButton'),
        );

        await tester.tap(reduceEndPositionButtonFinder);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Wait during 2 seconds to verify that the audio is not
        // playing after the end position of the comment which was 1:17:15
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        logger.i('****** Second question: is the audio stopped ? ');

        // Edited comment and audio player view position verification
        _verifyPositionValueAfterCommentWasPlayed(
          tester: tester,
          commentPositionTextButtonInTenthSecondsMin: 46333,
          commentPositionTextButtonInTenthSecondsMax: 46339,
          audioPlayerViewAudioPositionMin: '1:17:13',
          audioPlayerViewAudioPositionMax: '1:17:14',
        );

        // Now click on the play button to play the comment
        await tester.tap(find.byKey(const Key('playPauseIconButton')));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Wait during 2 seconds to verify that the audio is not
        // playing after the end position of the comment which was 1:17:15
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        logger.i('****** Third question: is the audio stopped ? ');

        // Edited comment and audio player view position verification
        _verifyPositionValueAfterCommentWasPlayed(
          tester: tester,
          commentPositionTextButtonInTenthSecondsMin: 46333,
          commentPositionTextButtonInTenthSecondsMax: 46339,
          audioPlayerViewAudioPositionMin: '1:17:13',
          audioPlayerViewAudioPositionMax: '1:17:14',
        );

        // Now update the comment

        final Finder addOrUpdateCommentTextButton =
            find.byKey(const Key('addOrUpdateCommentTextButton'));

        // Tap on the add/update comment button to save the comment
        await tester.tap(addOrUpdateCommentTextButton);
        await tester.pumpAndSettle();

        Finder audioCommentsLstFinder = find.byKey(const Key(
          'audioCommentsListKey',
        ));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: audioCommentsLstFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the fourth audio comment
        // in order to start playing it
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 9, // Fourth comment of the audio on IA
          typeOnPauseAfterPlay: false,
          maxPlayDurationSeconds: 3,
        );

        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Wait during 2 seconds to verify that the audio is not
        // playing after the end position of the comment which was 1:17:15
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        logger.i('****** Fourth question: is the audio stopped ? ');

        // Now tap a second time on the play icon button of the fourth audio comment
        // in order to restart playing it
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 9, // Fourth comment of the audio on IA
          typeOnPauseAfterPlay: false,
          maxPlayDurationSeconds: 3,
        );

        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Wait during 2 seconds to verify that the audio is not
        // playing after the end position of the comment which was 1:17:15
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        logger.i('****** Fith question: is the audio stopped ? ');

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
      testWidgets(
          '''Audio speed 2.0. Set the fourth comment end position to 1:17:20.8 and verify
            that the comment stops at 1:17:20.8. Verify that after typing twice on the decrease
            end position button, the comment plays till 1:17:18.8 seconds and not later.''',
          (WidgetTester tester) async {
        final String audioplayersVersion =
            await IntegrationTestUtil.getAudioplayersVersion();

        if (audioplayersVersion == '^5.2.1') {
          // This test is not executable with audioplayers 5.2.1
          return;
        }

        const String youtubePlaylistTitle = 'S8 audio'; // Youtube playlist
        const String alreadyCommentedAudioTitle =
            "Interview de Chat GPT  - IA, intelligence, philosophie, géopolitique, post-vérité...";
        await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
          tester: tester,
          savedTestDataDirName: 'audio_comment_test',
          selectedPlaylistTitle: youtubePlaylistTitle,
        );

        // Then, get the ListTile Text widget finder of the already commented
        // audio and tap on it to open the AudioPlayerView
        final Finder alreadyCommentedAudioFinder =
            find.text(alreadyCommentedAudioTitle);
        await tester.tap(alreadyCommentedAudioFinder);
        await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
          tester: tester,
        );

        // Set the audio speed to 2.0
        await IntegrationTestUtil.setAudioSpeed(
          tester: tester,
          audioSpeed: 1.5,
          plusTapNumber: 5, // to increase the speed from 1.5 to 2.0
        );

        // Tap on the comment icon button to open the comment add list
        // dialog
        final Finder commentInkWellButtonFinder = find.byKey(
          const Key('commentsInkWellButton'),
        );

        await tester.tap(commentInkWellButtonFinder);
        await tester.pumpAndSettle();

        // Tap on the comment title text to edit the comment
        String commentTitle = 'I did not thank ChatGPT';

        await tester.tap(find.text(commentTitle));
        await tester.pumpAndSettle();

        // Now open the set value to target dialog to set the comment
        // end position to 1:17:15 position.

        final Finder openDefinePositionDialogTextButtonFinder =
            find.byKey(const Key('selectCommentPositionTextButton'));

        await tester.tap(openDefinePositionDialogTextButtonFinder);
        await tester.pumpAndSettle();

        Finder setValueToTargetDialogFinder =
            find.byType(SetValueToTargetDialog);

        // This finder obtained as descendant of its enclosing dialog does
        // able to change the value of the TextField
        Finder setValueToTargetDialogEditTextFinder = find.descendant(
          of: setValueToTargetDialogFinder,
          matching: find.byType(TextField),
        );

        // Now set the position field in the dialog
        String positionTextToEnterInSeconds = '1:17:20.8';
        tester
            .widget<TextField>(setValueToTargetDialogEditTextFinder)
            .controller!
            .text = positionTextToEnterInSeconds;
        await tester.pumpAndSettle();

        // Select the second checkbox (End position)
        await tester.tap(find.byKey(const Key('checkbox_1_key')));
        await tester.pumpAndSettle();

        // Tap on the Ok button to set the comment end position to
        // 1:17:20.8

        await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
        await tester.pumpAndSettle();

        // Check the modified comment end position in the comment dialog

        Finder commentEndTextWidgetFinder =
            find.byKey(const Key('commentEndPositionText'));

        expect(
          tester.widget<Text>(commentEndTextWidgetFinder).data,
          positionTextToEnterInSeconds, // '1:17:21'
        );

        // Verify the value of the position text button which
        // corresponds to the current audio position

        // Find the Text child of the selectCommentPosition TextButton
        Finder selectCommentPositionTextButtonFinder =
            find.byKey(const Key('selectCommentPositionTextButton'));
        Finder selectCommentPositionTextOfButtonFinder = find.descendant(
          of: selectCommentPositionTextButtonFinder,
          matching: find.byType(Text),
        );

        // Verify that the Text widget contains the expected content

        String selectCommentPositionTextOfButton =
            tester.widget<Text>(selectCommentPositionTextOfButtonFinder).data!;
        expect(selectCommentPositionTextOfButton, '1:12:48.0');

        // Verify that the audio position is '1:12:48'
        Finder audioPositionTextWidgetFinder =
            find.byKey(const Key('audioPlayerViewAudioPosition'));
        expect(
            tester.widget<Text>(audioPositionTextWidgetFinder).data, '1:12:48');

        // Now click on the play button to play the comment
        await tester.tap(find.byKey(const Key('playPauseIconButton')));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Wait during 3 seconds to verify that the audio is not
        // playing after the end position of the comment which was 1:17:15
        await Future.delayed(const Duration(seconds: 3));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        logger.i('****** Is the audio stopped ? ');

        // Edited comment and audio player view position verification
        _verifyPositionValueAfterCommentWasPlayed(
          tester: tester,
          commentPositionTextButtonInTenthSecondsMin: 46366, // why not 46408
          commentPositionTextButtonInTenthSecondsMax: 46392,
          audioPlayerViewAudioPositionMin: '1:17:18',
          audioPlayerViewAudioPositionMax: '1:17:19',
        );

        // Type on the left checkbox to change duration from 1 tenth
        // of a second to 1 second
        final Finder commentEndTenthOfSecondsCheckboxFinder =
            find.byKey(const Key('commentEndTenthOfSecondsCheckbox'));
        await tester.tap(commentEndTenthOfSecondsCheckboxFinder);
        await tester.pumpAndSettle();

        // Now type two time on the reduce end position button to
        // set the end position to 1:17:14. This will start the audio
        // playback at 1:17:12 and stop it at 1:17:14.
        Finder reduceEndPositionButtonFinder = find.byKey(
          const Key('backwardCommentEndIconButton'),
        );

        await tester.tap(reduceEndPositionButtonFinder);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        await tester.tap(reduceEndPositionButtonFinder);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Wait during 2 seconds to verify that the audio is not
        // playing after the end position of the comment which was 1:17:15
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        logger.i('****** Second question: is the audio stopped ? ');

        // Edited comment and audio player view position verification
        _verifyPositionValueAfterCommentWasPlayed(
          tester: tester,
          commentPositionTextButtonInTenthSecondsMin: 46348,
          commentPositionTextButtonInTenthSecondsMax: 46386,
          audioPlayerViewAudioPositionMin: '1:17:18', // totalement illogique !
          audioPlayerViewAudioPositionMax: '1:17:19',
        );

        // Now click on the play button to play the comment
        await tester.tap(find.byKey(const Key('playPauseIconButton')));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Wait during 2 seconds to verify that the audio is not
        // playing after the end position of the comment which was 1:17:15
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        logger.i('****** Third question: is the audio stopped ? ');

        // Edited comment and audio player view position verification
        _verifyPositionValueAfterCommentWasPlayed(
          tester: tester,
          commentPositionTextButtonInTenthSecondsMin: 46348,
          commentPositionTextButtonInTenthSecondsMax: 46386,
          audioPlayerViewAudioPositionMin: '1:17:16', // totalement illogique !
          audioPlayerViewAudioPositionMax: '1:17:17',
        );

        // Now update the comment

        final Finder addOrUpdateCommentTextButton =
            find.byKey(const Key('addOrUpdateCommentTextButton'));

        // Tap on the add/update comment button to save the comment
        await tester.tap(addOrUpdateCommentTextButton);
        await tester.pumpAndSettle();

        Finder audioCommentsLstFinder = find.byKey(const Key(
          'audioCommentsListKey',
        ));

        // Find all the list items GestureDetector's
        final Finder gestureDetectorsFinder = find.descendant(
            // 3 GestureDetector per comment item
            of: audioCommentsLstFinder,
            matching: find.byType(GestureDetector));

        // Now tap on the play icon button of the fourth audio comment
        // in order to start playing it
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 9, // Fourth comment of the audio on IA
          typeOnPauseAfterPlay: false,
          maxPlayDurationSeconds: 3,
        );

        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Wait during 2 seconds to verify that the audio is not
        // playing after the end position of the comment which was 1:17:15
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        logger.i('****** Fourth question: is the audio stopped ? ');

        // Now tap a second time on the play icon button of the fourth audio comment
        // in order to restart playing it
        await IntegrationTestUtil.playComment(
          tester: tester,
          gestureDetectorsFinder: gestureDetectorsFinder,
          itemIndex: 9, // Fourth comment of the audio on IA
          typeOnPauseAfterPlay: false,
          maxPlayDurationSeconds: 3,
        );

        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Wait during 2 seconds to verify that the audio is not
        // playing after the end position of the comment which was 1:17:15
        await Future.delayed(const Duration(seconds: 2));
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        logger.i('****** Fith question: is the audio stopped ? ');

        // Purge the test playlist directory so that the created test
        // files are not uploaded to GitHub
        DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kApplicationPathWindowsTest,
        );
      });
    });
  });
  group('Modify audio volume tests', () {
    testWidgets(
        '''Change first audio volume to max. Then select second audio, verify its volume
            before reducing it to min. Then return to the first audio and verify its volume
            set to max. Then reduce its volume to 90 %. Finally, select the second audio, verify
            its volume set to min. Then increase it to 20 %.''', (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstModifiedAudioTitle =
          "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet";
      const String secondModifiedAudioTitle =
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'inkwell_button_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Tap on the first modifying audio of the playlist in order to
      // open the AudioPlayerView displaying this audio.

      Finder firstModifiedAudioListTileTextWidgetFinder =
          find.text(firstModifiedAudioTitle);

      await tester.tap(firstModifiedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Tap 5 times on the volume up button to set the audio volume to max

      String volumeUpIconButtonKey = 'increaseAudioVolumeIconButton';

      Finder volumeUpButtonFinder = find.byKey(
        Key(volumeUpIconButtonKey),
      );

      String volumeDownIconButtonKey = 'decreaseAudioVolumeIconButton';

      Finder volumeDownButtonFinder = find.byKey(
        Key(volumeDownIconButtonKey),
      );

      // Verify that the initial first audio volume is set to 50 % in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '50.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 50.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 50.0 %). Disabled when minimum volume is reached.",
      );

      for (int i = 0; i < 5; i++) {
        await tester.tap(volumeUpButtonFinder);
        await tester.pumpAndSettle();
      }

      // Verify that the first audio volume is set to max in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '100.0 %',
        isAudioVolumeUpButtonDisabled: true,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 100.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 100.0 %). Disabled when minimum volume is reached.",
      );

      // Now return to the playlist download page and select the second audio
      // of the playlist to open the AudioPlayerView displaying this audio.

      Finder applicationViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(applicationViewNavButton);
      await tester.pumpAndSettle();

      Finder secondModifiedAudioListTileTextWidgetFinder =
          find.text(secondModifiedAudioTitle);
      await tester.tap(secondModifiedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      volumeUpButtonFinder = find.byKey(
        Key(volumeUpIconButtonKey),
      );

      volumeDownButtonFinder = find.byKey(
        Key(volumeDownIconButtonKey),
      );

      // Verify that the initial second audio volume is set to 50 % in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '50.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 50.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 50.0 %). Disabled when minimum volume is reached.",
      );

      for (int i = 0; i < 5; i++) {
        await tester.tap(volumeDownButtonFinder);
        await tester.pumpAndSettle();
      }

      // Verify that the second audio volume is set to min in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '10.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: true,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 10.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 10.0 %). Disabled when minimum volume is reached.",
      );

      // Now return to the playlist download page and re-select the first
      // audio of the playlist to open the AudioPlayerView displaying this
      // audio.

      applicationViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(applicationViewNavButton);
      await tester.pumpAndSettle();

      firstModifiedAudioListTileTextWidgetFinder =
          find.text(firstModifiedAudioTitle);
      await tester.tap(firstModifiedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      volumeUpButtonFinder = find.byKey(
        Key(volumeUpIconButtonKey),
      );

      volumeDownButtonFinder = find.byKey(
        Key(volumeDownIconButtonKey),
      );

      // Verify that the previously modified first audio volume is set to
      // 100 % in the audio info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '100.0 %',
        isAudioVolumeUpButtonDisabled: true,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 100.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 100.0 %). Disabled when minimum volume is reached.",
      );

      // Tap once on the volume down button to set the audio volume to 90 %
      await tester.tap(volumeDownButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the first audio volume is set to 90 % in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '90.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 90.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 90.0 %). Disabled when minimum volume is reached.",
      );

      // Now return to the playlist download page and re-select the second
      // audio of the playlist to open the AudioPlayerView displaying this
      // audio.

      applicationViewNavButton =
          find.byKey(const ValueKey('playlistDownloadViewIconButton'));
      await tester.tap(applicationViewNavButton);
      await tester.pumpAndSettle();

      secondModifiedAudioListTileTextWidgetFinder =
          find.text(secondModifiedAudioTitle);
      await tester.tap(secondModifiedAudioListTileTextWidgetFinder);
      await tester.pumpAndSettle();

      volumeUpButtonFinder = find.byKey(
        Key(volumeUpIconButtonKey),
      );

      volumeDownButtonFinder = find.byKey(
        Key(volumeDownIconButtonKey),
      );

      // Verify that the previously modified second audio volume is set to
      // 100 % in the audio info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '10.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: true,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 10.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 10.0 %). Disabled when minimum volume is reached.",
      );

      // Tap once on the volume up button to set the audio volume to 20 %
      await tester.tap(volumeUpButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the second audio volume is set to 20 % in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '20.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 20.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 20.0 %). Disabled when minimum volume is reached.",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
    testWidgets(
        '''Audio selected in audio player view. Change first audio volume to max. Then select
            second audio, verify its volume before reducing it to min. Then return to the first
            audio and verify its volume set to max. Then reduce its volume to 90 %. Finally,
            re-select the second audio, verify its volume set to min. Then increase it to 20 %.''',
        (
      WidgetTester tester,
    ) async {
      const String audioPlayerSelectedPlaylistTitle = 'S8 audio';
      const String firstModifiedAudioTitle =
          "L'argument anti-nuke qui m'inquiète le plus par Y.Rousselet";
      const String secondModifiedAudioTitle =
          "Ce qui va vraiment sauver notre espèce par Jancovici et Barrau";

      await IntegrationTestUtil.initializeApplicationAndSelectPlaylist(
        tester: tester,
        savedTestDataDirName: 'inkwell_button_test',
        selectedPlaylistTitle: audioPlayerSelectedPlaylistTitle,
      );

      // Tap on the first modifying audio of the playlist in order to
      // open the AudioPlayerView displaying this audio.

      Finder firstModifiedAudioListTileTextWidgetFinder =
          find.text(firstModifiedAudioTitle);

      await tester.tap(firstModifiedAudioListTileTextWidgetFinder);
      await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
        tester: tester,
      );

      // Tap 5 times on the volume up button to set the audio volume to max

      String volumeUpIconButtonKey = 'increaseAudioVolumeIconButton';

      Finder volumeUpButtonFinder = find.byKey(
        Key(volumeUpIconButtonKey),
      );

      String volumeDownIconButtonKey = 'decreaseAudioVolumeIconButton';

      Finder volumeDownButtonFinder = find.byKey(
        Key(volumeDownIconButtonKey),
      );

      // Verify that the initial first audio volume is set to 50 % in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '50.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 50.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 50.0 %). Disabled when minimum volume is reached.",
      );

      for (int i = 0; i < 5; i++) {
        await tester.tap(volumeUpButtonFinder);
        await tester.pumpAndSettle();
      }

      // Verify that the first audio volume is set to max in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '100.0 %',
        isAudioVolumeUpButtonDisabled: true,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 100.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 100.0 %). Disabled when minimum volume is reached.",
      );

      // Now, open the AudioPlayableListDialog by tapping on the
      // audio title
      await tester.tap(find.text("$firstModifiedAudioTitle\n9:51"));
      await tester.pumpAndSettle();

      // Select the second Audio in the AudioPlayableListDialog
      await IntegrationTestUtil.selectAudioInAudioPlayableDialog(
        tester: tester,
        audioToSelectTitle: secondModifiedAudioTitle,
      );

      volumeUpButtonFinder = find.byKey(
        Key(volumeUpIconButtonKey),
      );

      volumeDownButtonFinder = find.byKey(
        Key(volumeDownIconButtonKey),
      );

      // Verify that the initial second audio volume is set to 50 % in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '50.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 50.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 50.0 %). Disabled when minimum volume is reached.",
      );

      for (int i = 0; i < 5; i++) {
        await tester.tap(volumeDownButtonFinder);
        await tester.pumpAndSettle();
      }

      // Verify that the second audio volume is set to min in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '10.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: true,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 10.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 10.0 %). Disabled when minimum volume is reached.",
      );

      // Now, open the AudioPlayableListDialog by tapping on the
      // audio title
      await tester.tap(find.text("$secondModifiedAudioTitle\n6:29"));
      await tester.pumpAndSettle();

      // Select the first Audio in the AudioPlayableListDialog
      await IntegrationTestUtil.selectAudioInAudioPlayableDialog(
        tester: tester,
        audioToSelectTitle: firstModifiedAudioTitle,
      );

      volumeUpButtonFinder = find.byKey(
        Key(volumeUpIconButtonKey),
      );

      volumeDownButtonFinder = find.byKey(
        Key(volumeDownIconButtonKey),
      );

      // Verify that the previously modified first audio volume is set to
      // 100 % in the audio info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '100.0 %',
        isAudioVolumeUpButtonDisabled: true,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 100.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 100.0 %). Disabled when minimum volume is reached.",
      );

      // Tap once on the volume down button to set the audio volume to 90 %
      await tester.tap(volumeDownButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the first audio volume is set to 90 % in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '90.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 90.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 90.0 %). Disabled when minimum volume is reached.",
      );

      // Now, open the AudioPlayableListDialog by tapping on the
      // audio title
      await tester.tap(find.text("$firstModifiedAudioTitle\n9:51"));
      await tester.pumpAndSettle();

      // Select an Audio in the AudioPlayableListDialog
      await IntegrationTestUtil.selectAudioInAudioPlayableDialog(
        tester: tester,
        audioToSelectTitle: secondModifiedAudioTitle,
      );

      volumeUpButtonFinder = find.byKey(
        Key(volumeUpIconButtonKey),
      );

      volumeDownButtonFinder = find.byKey(
        Key(volumeDownIconButtonKey),
      );

      // Verify that the previously modified second audio volume is set to
      // 100 % in the audio info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '10.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: true,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 10.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 10.0 %). Disabled when minimum volume is reached.",
      );

      // Tap once on the volume up button to set the audio volume to 20 %
      await tester.tap(volumeUpButtonFinder);
      await tester.pumpAndSettle();

      // Verify that the second audio volume is set to 20 % in the audio
      // info dialog
      await _verifyAudioVolume(
        tester: tester,
        volumeUpButtonFinder: volumeUpButtonFinder,
        volumeUpIconButtonKey: volumeUpIconButtonKey,
        volumeDownButtonFinder: volumeDownButtonFinder,
        volumeDownIconButtonKey: volumeDownIconButtonKey,
        audioVolumeStr: '20.0 %',
        isAudioVolumeUpButtonDisabled: false,
        isAudioVolumeDownButtonDisabled: false,
        volumeUpIconButtonTooltipMessage:
            "Increase the audio volume (currently 20.0 %). Disabled when maximum volume is reached.",
        volumeDownIconButtonTooltipMessage:
            "Decrease the audio volume (currently 20.0 %). Disabled when minimum volume is reached.",
      );

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPathWindowsTest,
      );
    });
  });
}

void _verifyPositionValueAfterCommentWasPlayed({
  required WidgetTester tester,
  required int commentPositionTextButtonInTenthSecondsMin,
  required int commentPositionTextButtonInTenthSecondsMax,
  required String audioPlayerViewAudioPositionMin,
  required String audioPlayerViewAudioPositionMax,
}) {
  // Find the Text child of the selectCommentPosition TextButton
  Finder selectCommentPositionTextButtonFinder =
      find.byKey(const Key('selectCommentPositionTextButton'));
  Finder selectCommentPositionTextOfButtonFinder = find.descendant(
    of: selectCommentPositionTextButtonFinder,
    matching: find.byType(Text),
  );
  String selectCommentPositionTextOfButton =
      tester.widget<Text>(selectCommentPositionTextOfButtonFinder).data!;

  // Verify the value of the position text button

  // Extract tenth of seconds from format "m:ss.tenthSeconds"
  List<String> parts = selectCommentPositionTextOfButton.split(':');
  int hours;
  int minutes;
  List<String> secondsParts;

  if (parts.length == 3) {
    // Format is "h:mm:ss.tenthSeconds"
    hours = int.parse(parts[0]);
    minutes = int.parse(parts[1]);

    // Split seconds and tenth of seconds by the decimal point
    secondsParts = parts[2].split('.');
  } else {
    // Format is "m:ss.tenthSeconds"
    hours = 0;
    minutes = int.parse(parts[0]);

    // Split seconds and tenth of seconds by the decimal point
    secondsParts = parts[1].split('.');
  }

  final int seconds = int.parse(secondsParts[0]);
  final int tenthSeconds =
      secondsParts.length > 1 ? int.parse(secondsParts[1]) : 0;
  final int totalTenthSeconds =
      (hours * 3600 + minutes * 60 + seconds) * 10 + tenthSeconds;

  expect(
      totalTenthSeconds,
      inInclusiveRange(
        commentPositionTextButtonInTenthSecondsMin,
        commentPositionTextButtonInTenthSecondsMax,
      ),
      reason:
          'Real comment position button text value is $selectCommentPositionTextOfButton');

  Finder audioPositionTextWidgetFinder =
      find.byKey(const Key('audioPlayerViewAudioPosition'));

  // Verify that the audio position is now 0:02 or 0:03
  audioPositionTextWidgetFinder =
      find.byKey(const Key('audioPlayerViewAudioPosition'));
  expect(
      tester.widget<Text>(audioPositionTextWidgetFinder).data,
      anyOf([
        audioPlayerViewAudioPositionMin,
        audioPlayerViewAudioPositionMax,
      ]));
}

Future<void> _verifyAudioVolume({
  required WidgetTester tester,
  required Finder volumeUpButtonFinder,
  required String volumeUpIconButtonKey,
  required Finder volumeDownButtonFinder,
  required String volumeDownIconButtonKey,
  required String audioVolumeStr,
  required bool isAudioVolumeUpButtonDisabled,
  required bool isAudioVolumeDownButtonDisabled,
  required String volumeUpIconButtonTooltipMessage,
  required String volumeDownIconButtonTooltipMessage,
}) async {
  // Verify the audio volume in the audio info dialog
  await IntegrationTestUtil.verifyAudioInfoDialog(
    tester: tester,
    youtubeChannelValue: '',
    copiedToPlaylistTitle: 'local_several_played_unplayed_audios',
    inAudioPlayerView: true,
    audioVolume: audioVolumeStr,
  );

  // Verify the volume up icon button state

  if (isAudioVolumeUpButtonDisabled) {
    // is disabled if the volume was set to min
    // or to max
    IntegrationTestUtil.verifyWidgetIsDisabled(
      tester: tester,
      widgetKeyStr: volumeUpIconButtonKey,
    );
  } else {
    IntegrationTestUtil.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: volumeUpIconButtonKey,
    );
  }

  // Verify the volume down icon button state

  if (isAudioVolumeDownButtonDisabled) {
    // is disabled if the volume was set to min
    // or to max
    IntegrationTestUtil.verifyWidgetIsDisabled(
      tester: tester,
      widgetKeyStr: volumeDownIconButtonKey,
    );
  } else {
    IntegrationTestUtil.verifyWidgetIsEnabled(
      tester: tester,
      widgetKeyStr: volumeDownIconButtonKey,
    );
  }

  // Verify the tooltip message of the volume up icon
  // button

  // Find the tooltip text
  final Finder buttonUpTooltipFinder = find.ancestor(
    of: volumeUpButtonFinder,
    matching: find.byType(Tooltip),
  );
  Tooltip tooltipWidget = tester.widget<Tooltip>(buttonUpTooltipFinder);

  expect(tooltipWidget.message, volumeUpIconButtonTooltipMessage);

  // Verify the tooltip message of the volume down icon
  // button

  // Find the tooltip text
  final Finder buttonDownTooltipFinder = find.ancestor(
    of: volumeDownButtonFinder,
    matching: find.byType(Tooltip),
  );
  tooltipWidget = tester.widget<Tooltip>(buttonDownTooltipFinder);

  expect(tooltipWidget.message, volumeDownIconButtonTooltipMessage);
}

void _verifyPlaylistIsSelectedInPlaylistDownloadView({
  required WidgetTester tester,
  required String selectedPlaylistTitle,
}) {
  // Verify that the selectedPlaylistTitle playlist is now selected in the
  // playlist download view since it was selected in the audio player view.

  // Find the S8 audio playlist ListTile Text widget
  Finder selectedPlaylistListTileTextWidgetFinder =
      find.text(selectedPlaylistTitle);

  // Then obtain the playlist ListTile widget enclosing the Text widget
  // by finding its ancestor
  Finder selectedPlaylistListTileWidgetFinder = find.ancestor(
    of: selectedPlaylistListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the Checkbox widget located in the playlist ListTile
  // and verify that it is checked

  Finder selectedPlaylistListTileCheckboxWidgetFinder = find.descendant(
    of: selectedPlaylistListTileWidgetFinder,
    matching: find.byType(Checkbox),
  );

  final Checkbox checkboxWidget =
      tester.widget<Checkbox>(selectedPlaylistListTileCheckboxWidgetFinder);

  expect(checkboxWidget.value!, true);

  // Verify the displayed playlist title
  Text selectedPlaylistTitleText =
      tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
  expect(
    selectedPlaylistTitleText.data,
    selectedPlaylistTitle,
  );
}

Future<void> deleteComment({
  required WidgetTester tester,
  required Finder gestureDetectorsFinder,
  required int deletedCommentIndex,
  required String deletedCommentTitle,
}) async {
  // Now tap on the delete comment icon button to delete the comment
  final Finder deleteIconButtonFinder = find.descendant(
    of: gestureDetectorsFinder.at(deletedCommentIndex),
    matching: find.byKey(const Key('deleteCommentIconButton')),
  );

  await tester.tap(deleteIconButtonFinder);
  await tester.pumpAndSettle();

  // Verify the delete comment dialog title
  expect(find.text('Delete Comment'), findsOneWidget);

  // Verify the delete comment dialog message
  expect(
      find.text("Deleting comment \"$deletedCommentTitle\"."), findsOneWidget);

  // Confirm the deletion of the comment
  await tester.tap(find.byKey(const Key('confirmButton')));
  await tester.pumpAndSettle();
}

Future<void> deleteAudio({
  required WidgetTester tester,
  required String audioToDeleteTitle,
}) async {
  // First, find the Audio sublist ListTile Text widget
  final Finder uniqueAudioListTileTextWidgetFinder =
      find.text(audioToDeleteTitle);

  // Then obtain the Audio ListTile widget enclosing the Text widget by
  // finding its ancestor
  final Finder uniqueAudioListTileWidgetFinder = find.ancestor(
    of: uniqueAudioListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the leading menu icon button of the Audio ListTile
  // and tap on it
  final Finder uniqueAudioListTileLeadingMenuIconButton = find.descendant(
    of: uniqueAudioListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu
  await tester.tap(uniqueAudioListTileLeadingMenuIconButton);
  await tester.pumpAndSettle(); // Wait for popup menu to appear

  // Now find the delete audio popup menu item and tap on it
  final Finder popupCopyMenuItem =
      find.byKey(const Key("popup_menu_delete_audio"));

  await tester.tap(popupCopyMenuItem);
  await tester.pumpAndSettle();
}

Future<void> simulateEnteringTooBigAndTooSmallAudioPosition({
  required WidgetTester tester,
  required Finder setValueToTargetDialogEditTextFinder,
  required bool doSetStartOrEndCheckbox,
}) async {
  // Now enter a new time position which is bigger than the audio
  // total duration (1:17:53.7)

  // Modify the position in the dialog with tenth of seconds
  String positionTextToEnterWithTenthOfSeconds = '2:15:45.9';
  tester
      .widget<TextField>(setValueToTargetDialogEditTextFinder)
      .controller!
      .text = positionTextToEnterWithTenthOfSeconds;
  await tester.pumpAndSettle();

  if (doSetStartOrEndCheckbox) {
    // Select the second checkbox (End position)
    await tester.tap(find.byKey(const Key('checkbox_1_key')));
    await tester.pumpAndSettle();
  }

  // Tap on the Ok button to set the new position in the comment
  // previous dialog

  await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
  await tester.pumpAndSettle();

  // Since the entered position exceeds the audio total duration,
  // a warning will be displayed, even if no start or end checkbox
  // was checked ...

  // Verify the displayed warning or confirn dialog
  await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
    tester: tester,
    warningDialogMessage:
        "The entered value exceeds the maximal value (1:17:53.7). Please correct it and retry ...",
    isWarningConfirming: false,
  );

  // Check that the too big invalid value in the set value to target
  // dialog was replaced by the maximum possible value, i.e. the
  // audio total duration (1:17:53.7)
  expect(
    tester
        .widget<TextField>(setValueToTargetDialogEditTextFinder)
        .controller!
        .text,
    '1:17:53.7',
  );

  // Now, do the same simulation, but with entering a negative
  // position, i.e. a position < 0:00.

  // Modify the position in the dialog with tenth of seconds
  positionTextToEnterWithTenthOfSeconds = '-0:55.4';
  tester
      .widget<TextField>(setValueToTargetDialogEditTextFinder)
      .controller!
      .text = positionTextToEnterWithTenthOfSeconds;
  await tester.pumpAndSettle();

  if (doSetStartOrEndCheckbox) {
    // Select the first checkbox (Start position)
    await tester.tap(find.byKey(const Key('checkbox_0_key')));
    await tester.pumpAndSettle();
  }

  // Tap on the Ok button to set the new position in the comment
  // previous dialog

  await tester.tap(find.byKey(const Key('setValueToTargetOkButton')));
  await tester.pumpAndSettle();

  // Since the entered position is smaller than the audio start
  // position (0:00), a warning will be displayed, even if no start
  // or end checkbox was checked ...

  // Verify the displayed warning or confirn dialog
  await IntegrationTestUtil.verifyWarningDisplayAndCloseIt(
    tester: tester,
    warningDialogMessage:
        "The entered value is below the minimal value (0:00.0). Please correct it and retry ...",
    isWarningConfirming: false,
  );

  // Check that the too small invalid value in the set value to target
  // dialog was replaced by the minimum possible value, i.e. the
  // audio start position (0:00.0)
  expect(
    tester
        .widget<TextField>(setValueToTargetDialogEditTextFinder)
        .controller!
        .text,
    '0:00.0',
  );
}

/// The conditional {audioPausedDateTimeSecBeforeNowModification}
/// parameter is useful to simulate the case where the audio was
/// paused n seconds before now. This is useful to test the rewind
/// feature of the audio player which depends on the time between
/// now and the last time the audio was paused.
Future<void> _applyRewindTesting({
  required WidgetTester tester,
  required String audioPlaylistTitle,
  required String audioToListenTitle,
  required int audioToListenIndex,
  required String audioDurationStr,
  int audioPausedDateTimeSecBeforeNowModification = 0,
  required String audioPositionBeforePlayingStr,
  required String expectedMinPositionTimeStr,
  required String expectedMaxPositionTimeStr,
}) async {
  if (audioPausedDateTimeSecBeforeNowModification > 0) {
    // Modifing the audio paused date time in the playlist JSON file

    DateTime audioModifiedDateTime = DateTime.now().subtract(
      Duration(seconds: audioPausedDateTimeSecBeforeNowModification),
    );

    await IntegrationTestUtil.modifyAudioInPlaylistJsonFileAndUpgradePlaylists(
      tester: tester,
      playlistTitle: audioPlaylistTitle,
      playableAudioLstAudioIndex: audioToListenIndex,
      modifiedAudioPausedDateTime: audioModifiedDateTime,
    );
  }

  // Playing the audio. First, get the audio ListTile Text widget finder
  // and tap on it to open the AudioPlayerView displaying the audio.

  final Finder audioToListenTitleTextWidgetFinder =
      find.text(audioToListenTitle);

  await tester.tap(audioToListenTitleTextWidgetFinder);
  await IntegrationTestUtil.pumpAndSettleDueToAudioPlayers(
    tester: tester,
  );

  Finder audioPlayerViewAudioPositionFinder =
      find.byKey(const Key('audioPlayerViewAudioPosition'));

  expect(
    tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!,
    audioPositionBeforePlayingStr,
  );

  // Playing the audio during 1 second. Clicking on the play button
  // rewind the audio of n seconds depending on how long the audio was
  // not listened.

  await tester.tap(find.byIcon(Icons.play_arrow));
  await tester.pumpAndSettle();

  await Future.delayed(const Duration(seconds: 1));
  await tester.pumpAndSettle();

  // Click on the pause button to stop the last downloaded audio
  Finder pauseIconButtonFinder = find.byIcon(Icons.pause);

  if (pauseIconButtonFinder.evaluate().isNotEmpty) {
    await tester.tap(pauseIconButtonFinder);
    await tester.pumpAndSettle();
  }

  // Verify the played audio title
  String audioToListenTitleWithDuration =
      '$audioToListenTitle\n$audioDurationStr';
  expect(find.text(audioToListenTitleWithDuration), findsOneWidget);

  IntegrationTestUtil.verifyPositionBetweenMinMax(
    tester: tester,
    textWidgetFinder: audioPlayerViewAudioPositionFinder,
    minPositionTimeStr: expectedMinPositionTimeStr,
    maxPositionTimeStr: expectedMaxPositionTimeStr,
  );
}

/// The conditional {audioPausedDateTimeSecBeforeNowModification}
/// parameter is useful to simulate the case where the audio was
/// paused n seconds before now. This is useful to test the rewind
/// feature of the audio player which depends on the time between
/// now and the last time the audio was paused.
Future<void> _applyRewindExcludedTesting({
  required WidgetTester tester,
  required String audioPlaylistTitle,
  required String audioToListenTitle,
  required int audioToListenIndex,
  required String audioDurationStr,
  int audioPausedDateTimeSecBeforeNowModification = 0,
  required AudioPositionModification audioPositionModification,
  required String audioPositionBeforePlayingStr,
  required String expectedMinPositionTimeStr,
  required String expectedMaxPositionTimeStr,
}) async {
  if (audioPausedDateTimeSecBeforeNowModification > 0) {
    // Modifing the audio paused date time in the playlist JSON file

    DateTime audioModifiedDateTime = DateTime.now().subtract(
      Duration(seconds: audioPausedDateTimeSecBeforeNowModification),
    );

    await IntegrationTestUtil.modifyAudioInPlaylistJsonFileAndUpgradePlaylists(
      tester: tester,
      playlistTitle: audioPlaylistTitle,
      playableAudioLstAudioIndex: audioToListenIndex,
      modifiedAudioPausedDateTime: audioModifiedDateTime,
    );
  }

  // Playing the audio. First, get the audio ListTile Text widget finder
  // and tap on it to open the AudioPlayerView displaying the audio.

  final Finder audioToListenTitleTextWidgetFinder =
      find.text(audioToListenTitle);

  await tester.tap(audioToListenTitleTextWidgetFinder);
  await tester.pumpAndSettle();

  await Future.delayed(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();

  switch (audioPositionModification) {
    case AudioPositionModification.backward10sec:
      await tester.tap(find.byKey(const Key('audioPlayerViewRewind10sButton')));
      await tester.pumpAndSettle();

      break;
    case AudioPositionModification.backward1min:
      await tester.tap(find.byKey(const Key('audioPlayerViewRewind1mButton')));
      await tester.pumpAndSettle();

      break;
    case AudioPositionModification.forward10sec:
      await tester
          .tap(find.byKey(const Key('audioPlayerViewForward10sButton')));
      await tester.pumpAndSettle();

      break;
    case AudioPositionModification.forward1min:
      await tester.tap(find.byKey(const Key('audioPlayerViewForward1mButton')));
      await tester.pumpAndSettle();

      break;
  }

  Finder audioPlayerViewAudioPositionFinder =
      find.byKey(const Key('audioPlayerViewAudioPosition'));

  expect(
    tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!,
    audioPositionBeforePlayingStr,
  );

  // Playing the audio during 1 second. Clicking on the play button
  // rewind the audio of n seconds depending on how long the audio was
  // not listened.

  await tester.tap(find.byIcon(Icons.play_arrow));
  await tester.pumpAndSettle();

  await Future.delayed(const Duration(seconds: 1));
  await tester.pumpAndSettle();

  // Click on the pause button to stop the last downloaded audio
  Finder pauseIconButtonFinder = find.byIcon(Icons.pause);

  if (pauseIconButtonFinder.evaluate().isNotEmpty) {
    await tester.tap(pauseIconButtonFinder);
    await tester.pumpAndSettle();
  }

  // Verify the played audio title
  String audioToListenTitleWithDuration =
      '$audioToListenTitle\n$audioDurationStr';
  expect(find.text(audioToListenTitleWithDuration), findsOneWidget);

  audioPlayerViewAudioPositionFinder =
      find.byKey(const Key('audioPlayerViewAudioPosition'));

  IntegrationTestUtil.verifyPositionBetweenMinMax(
    tester: tester,
    textWidgetFinder: audioPlayerViewAudioPositionFinder,
    minPositionTimeStr: expectedMinPositionTimeStr,
    maxPositionTimeStr: expectedMaxPositionTimeStr,
  );
}

/// Returns the tenth of seconds of the passed audio position text
/// displayed in the format HH:MM:SS.t which is converted to
/// HH:MM:SS and then converted to tenths of seconds.
///
/// Since the audio position displayed in the audio player view is
/// in format HH:MM:SS, in order to compare a position displayed in
/// the format HH:MM:SS.t to a position displayed in the format HH:MM:SS,
/// comparison done in tenth of seconds, the corresponding tenth seconds
/// value of position displayed in the format HH:MM:SS.t is rounded by
/// the method.
int roundUpTenthOfSeconds({
  required String audioPositionHHMMSSWithTenthSecText,
}) {
  int audioPositionTenthSecRounded;
  int audioPositionTenthSec = DateTimeUtil.convertToTenthsOfSeconds(
    timeString: audioPositionHHMMSSWithTenthSecText,
  );

  audioPositionTenthSecRounded = (audioPositionTenthSec / 10).round() * 10;
  return audioPositionTenthSecRounded;
}

Matcher inInclusiveRange(int min, int max) => predicate(
    (int value) => value >= min && value <= max,
    'is in the range [$min, $max]');

Future<void> _goBackToPlaylistDownloadViewToCheckAudioStateAndIcon({
  required WidgetTester tester,
  required String audioTitle,
  required String audioStateExpectedValue,
  required IconData expectedAudioRightIcon,
  required Color expectedAudioRightIconColor,
  required Color expectedAudioRightIconSurroundedColor,
}) async {
  // Go back to playlist download view without pausing audio
  final Finder audioPlayerNavButtonFinder =
      find.byKey(const ValueKey('playlistDownloadViewIconButton'));
  await tester.tap(audioPlayerNavButtonFinder);
  await tester.pumpAndSettle();

  // Now we want to tap the popup menu of the Audio audioTitle
  // ListTile

  // First, find the Audio sublist ListTile Text widget
  final Finder targetAudioListTileTextWidgetFinder = find.text(
    audioTitle,
  );

  // Then obtain the Audio ListTile widget enclosing the Text widget
  // by finding its ancestor
  final Finder targetAudioListTileWidgetFinder = find.ancestor(
    of: targetAudioListTileTextWidgetFinder,
    matching: find.byType(ListTile),
  );

  // Now find the leading menu icon button of the Audio ListTile
  // and tap on it
  final Finder targetAudioListTileLeadingMenuIconButtonFinder = find.descendant(
    of: targetAudioListTileWidgetFinder,
    matching: find.byIcon(Icons.menu),
  );

  // Tap the leading menu icon button to open the popup menu items
  await tester.tap(targetAudioListTileLeadingMenuIconButtonFinder);
  await tester.pumpAndSettle(); // Wait for popup menu to appear

  // Now find the display audio info popup menu item and tap on it
  final Finder popupDisplayAudioInfoMenuItemFinder =
      find.byKey(const Key("popup_menu_display_audio_info"));

  await tester.tap(popupDisplayAudioInfoMenuItemFinder);
  await tester.pumpAndSettle();

  // Now verifying the audio info state

  Text audioStateTextWidget =
      tester.widget<Text>(find.byKey(const Key('audioStateKey')));

  expect(audioStateTextWidget.data, audioStateExpectedValue);

  // Now click on Close button to close the audio info dialog
  await tester.tap(find.byKey(const Key('audio_info_close_button_key')));
  await tester.pumpAndSettle();

  // Now verifying the audio right button state

  // First, get the currently listening Audio item InkWell widget
  // finder. The InkWell widget contains the play or pause icon
  // and tapping on it plays or pauses the audio.
  final Finder lastDownloadedAudioListTileInkWellFinder =
      IntegrationTestUtil.findAudioItemInkWellWidget(
    audioTitle,
  );

  // Find the Icon within the InkWell
  final Finder iconFinder = find.descendant(
    of: lastDownloadedAudioListTileInkWellFinder,
    matching: find.byType(Icon),
  );
  Icon iconWidget = tester.widget<Icon>(iconFinder);

  // Assert Icon type
  expect(iconWidget.icon, equals(expectedAudioRightIcon));

  // Assert Icon color
  expect(iconWidget.color, equals(expectedAudioRightIconColor));

  // Find the CircleAvatar within the InkWell which surround the
  // audio right icon
  final Finder circleAvatarFinder = find.descendant(
    of: lastDownloadedAudioListTileInkWellFinder,
    matching: find.byType(CircleAvatar),
  );
  CircleAvatar circleAvatarWidget =
      tester.widget<CircleAvatar>(circleAvatarFinder);

  // Assert CircleAvatar background color
  expect(circleAvatarWidget.backgroundColor,
      equals(expectedAudioRightIconSurroundedColor));
}

void _verifyCommentDataStoredInCommentJsonFile({
  required String playlistTitle,
  required String audioFileNameNoExt,
  required String commentTitle,
  required String commentContent,
  required String commentStartPositionTenthOfSecondsStr,
  required String commentEndPositionTenthOfSecondsStr,
}) {
  final String commentPath =
      "$kApplicationPathWindowsTest${path.separator}$playlistTitle${path.separator}$kCommentDirName";

  final commentPathFileName = path.join(
    commentPath,
    '$audioFileNameNoExt.json',
  );

  // Load comment from the json file
  List<Comment> loadedCommentLst = JsonDataService.loadListFromFile(
    jsonPathFileName: commentPathFileName,
    type: Comment,
  );

  int commentStartPositionTenthOfSeconds =
      DateTimeUtil.convertToTenthsOfSeconds(
          timeString: commentStartPositionTenthOfSecondsStr);
  int commentEndPositionTenthOfSeconds = DateTimeUtil.convertToTenthsOfSeconds(
      timeString: commentEndPositionTenthOfSecondsStr);
  Comment loadedComment = loadedCommentLst.first;

  expect(loadedComment.title, commentTitle);
  expect(loadedComment.content, commentContent);
  expect(
    loadedComment.commentStartPositionInTenthOfSeconds,
    commentStartPositionTenthOfSeconds,
    reason:
        "json commentStartPositionInTenthOfSeconds: ${loadedComment.commentStartPositionInTenthOfSeconds}, expected $commentStartPositionTenthOfSeconds for $commentStartPositionTenthOfSecondsStr",
  );
  expect(
    loadedComment.commentEndPositionInTenthOfSeconds,
    commentEndPositionTenthOfSeconds,
    reason:
        "json commentEndPositionInTenthOfSeconds: ${loadedComment.commentEndPositionInTenthOfSeconds}, expected $commentEndPositionTenthOfSeconds for $commentEndPositionTenthOfSecondsStr",
  );
}

String? getActualText(final Finder textWidgetFinder) {
  final elements = textWidgetFinder.evaluate();

  if (elements.isNotEmpty) {
    final textElement = elements.first.widget as Text;
    return textElement.data;
  }

  return null;
}

Duration parseDuration(String hhmmString) {
  List<String> parts = hhmmString.split(':');
  if (parts.length != 2) {
    throw const FormatException("Invalid duration format");
  }

  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);

  return Duration(hours: hours, minutes: minutes);
}

Future<void> _verifyAudioPlayerViewPlaylistSelectionImpact({
  required WidgetTester tester,
  required String playlistDownloadViewCurrentlySelectedPlaylistTitle,
  required String playlistToSelectTitle,
  required String playlistCurrentlyPlayableAudioTitleWithDuration,
  required String expectedAudioPositionTimeString,
  required String expectedAudioRemainingDurationTimeString,
  Duration? selectPlaylistPumpAndSettleDuration,
  int positionSecondsDifference = 0,
}) async {
  // Now tap on audio player view playlist button to display the playlists
  await tester.tap(find.byKey(const Key('playlist_toggle_button')));
  await tester.pumpAndSettle();

  // Verify that the playlist list is displayed
  expect(
    find.byKey(const Key('expandable_playlist_list')),
    findsOneWidget,
  );

  // Verify that the playlist download view currently selected
  // playlist is also selected in the playlist download view.

  if (playlistDownloadViewCurrentlySelectedPlaylistTitle == '') {
    await IntegrationTestUtil.verifyNoPlaylistCheckboxSelected(
      tester: tester,
    );
  } else {
    // Find the currently selected playlist ListTile Text widget
    Finder
        playlistDownloadViewCurrentlySelectedPlaylistListTileTextWidgetFinder =
        find.text(playlistDownloadViewCurrentlySelectedPlaylistTitle);

    // Then obtain the playlist ListTile widget enclosing the Text widget
    // by finding its ancestor
    Finder playlistDownloadViewCurrentlySelectedPlaylistListTileWidgetFinder =
        find.ancestor(
      of: playlistDownloadViewCurrentlySelectedPlaylistListTileTextWidgetFinder,
      matching: find.byType(ListTile),
    );

    // Now find the Checkbox widget located in the playlist ListTile
    // and verify that it is checked

    Finder
        playlistDownloadViewCurrentlySelectedPlaylistListTileCheckboxWidgetFinder =
        find.descendant(
      of: playlistDownloadViewCurrentlySelectedPlaylistListTileWidgetFinder,
      matching: find.byType(Checkbox),
    );

    final Checkbox checkboxWidget = tester.widget<Checkbox>(
        playlistDownloadViewCurrentlySelectedPlaylistListTileCheckboxWidgetFinder);

    expect(checkboxWidget.value!, true);
  }

  // Select the passed playlistToSelectTitle playlist

  await IntegrationTestUtil.selectPlaylist(
    tester: tester,
    playlistToSelectTitle: playlistToSelectTitle,
    selectPlaylistPumpAndSettleDuration: selectPlaylistPumpAndSettleDuration,
  );

  // Verify that the audio player view list of playlists was closed
  // after selecting the playlist
  expect(
    find.byKey(const Key('expandable_playlist_list')),
    findsNothing,
  );

  // Verify the displayed selected playlist current playable audio title

  Finder audioPlayerViewAudioTitleFinder =
      find.byKey(const Key('audioPlayerViewCurrentAudioTitle'));
  String audioTitleWithDurationString =
      tester.widget<Text>(audioPlayerViewAudioTitleFinder).data!;

  expect(
    audioTitleWithDurationString,
    playlistCurrentlyPlayableAudioTitleWithDuration,
  );

  // Retrieving the current audio position
  Finder audioPlayerViewAudioPositionFinder =
      find.byKey(const Key('audioPlayerViewAudioPosition'));
  String audioPositionTimeString =
      tester.widget<Text>(audioPlayerViewAudioPositionFinder).data!;
  Finder audioPlayerViewAudioRemainingDurationFinder =
      find.byKey(const Key('audioPlayerViewAudioRemainingDuration'));

  if (positionSecondsDifference == 0) {
    expect(
      audioPositionTimeString,
      expectedAudioPositionTimeString,
    );
  } else {
    IntegrationTestUtil.verifyPositionWithAcceptableDifferenceSeconds(
      tester: tester,
      actualPositionTimeStr: audioPositionTimeString,
      expectedPositionTimeStr: expectedAudioPositionTimeString,
      plusMinusSeconds: positionSecondsDifference,
    );
  }

  // Retrieving the current audio remaining duration
  String audioRemainingDurationTimeString =
      tester.widget<Text>(audioPlayerViewAudioRemainingDurationFinder).data!;

  if (positionSecondsDifference == 0) {
    expect(
      audioRemainingDurationTimeString,
      expectedAudioRemainingDurationTimeString,
    );
  } else {
    IntegrationTestUtil.verifyPositionWithAcceptableDifferenceSeconds(
      tester: tester,
      actualPositionTimeStr: audioRemainingDurationTimeString,
      expectedPositionTimeStr: expectedAudioRemainingDurationTimeString,
      plusMinusSeconds: positionSecondsDifference,
    );
  }

  // Verify the displayed playlist title at top of the the audio player
  // view
  Text selectedPlaylistTitleText =
      tester.widget(find.byKey(const Key('selectedPlaylistTitleText')));
  expect(
    selectedPlaylistTitleText.data,
    playlistToSelectTitle,
  );

  // Verify the audio player view top buttons state

  if (playlistCurrentlyPlayableAudioTitleWithDuration == 'No audio selected') {
    await IntegrationTestUtil.verifyTopButtonsState(
      tester: tester,
      areEnabled: false,
      audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      setAudioSpeedTextButtonValue: '1.00x',
    );
  }
}
