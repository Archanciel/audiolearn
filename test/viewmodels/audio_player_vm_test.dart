import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/services/settings_data_service.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/warning_message_vm.dart';

import '../services/mock_shared_preferences.dart';
import 'audio_player_vm_test_version.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPlayerVM changeAudioPlayPosition undo/redo', () {
    test('Test single undo/redo of forward position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition = audioPlayerVM.currentAudioPosition;

      // change the current audio's play position

      int forwardChangePosition = 100;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration: Duration(seconds: forwardChangePosition));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePosition);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePosition);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('Test single undo/redo of backward position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition = audioPlayerVM.currentAudioPosition;

      // change the current audio's play position

      int backwardChangePosition = -100;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: backwardChangePosition));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          backwardChangePosition);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          backwardChangePosition);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test single undo/redo of multiple forward and backward position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition = audioPlayerVM.currentAudioPosition;

      // change three times the current audio's play position

      int forwardChangePositionOne = 100;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: forwardChangePositionOne));

      int backwardChangePositionOne = -60;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: backwardChangePositionOne));

      int forwardChangePositionTwo = 80;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: forwardChangePositionTwo));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne +
              backwardChangePositionOne +
              forwardChangePositionTwo);

      // undo the last change
      audioPlayerVM.undo();

      // obtain the current audio's position after the first undo
      Duration currentAudioPositionAfterFirstUndo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterFirstUndo.inSeconds,
          currentAudioInitialPosition.inSeconds +
              forwardChangePositionOne +
              backwardChangePositionOne);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the first redo
      Duration currentAudioPositionAfterFirstRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterFirstRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne +
              backwardChangePositionOne +
              forwardChangePositionTwo);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test multiple undo/redo of multiple forward and backward position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition = audioPlayerVM.currentAudioPosition;

      // change three times the current audio's play position

      int forwardChangePositionOne = 100;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: forwardChangePositionOne));

      int backwardChangePositionOne = -60;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: backwardChangePositionOne));

      int forwardChangePositionTwo = 80;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: forwardChangePositionTwo));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne +
              backwardChangePositionOne +
              forwardChangePositionTwo);

      // undo the last and previous change
      audioPlayerVM.undo();
      audioPlayerVM.undo();

      // obtain the current audio's position after the two undo's
      Duration currentAudioPositionAfterTwoUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterTwoUndo.inSeconds,
          currentAudioInitialPosition.inSeconds + forwardChangePositionOne);

      // redo the previous change
      audioPlayerVM.redo();

      // obtain the current audio's position after the first redo
      Duration currentAudioPositionAfterFirstRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterFirstRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne + backwardChangePositionOne);

      // redo the last change
      audioPlayerVM.redo();

      // obtain the current audio's position after the second redo
      Duration currentAudioPositionAfterSecondRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterSecondRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne +
              backwardChangePositionOne +
              forwardChangePositionTwo);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test insert a new command between multiple undo/redo of multiple forward and backward position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change three times the current audio's play position

      int forwardChangePositionOne = 100;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: forwardChangePositionOne)); // 700

      int backwardChangePositionOne = -60;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: backwardChangePositionOne)); // 640

      int forwardChangePositionTwo = 80;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: forwardChangePositionTwo)); // 720

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds - // 720
              currentAudioInitialPosition.inSeconds,
          forwardChangePositionOne + // 100 +
              backwardChangePositionOne + // -60 +
              forwardChangePositionTwo); // 80 --> 120

      // undo the last forward change (forward two)
      audioPlayerVM.undo();

      // enter a new command
      int forwardChangePositionThree = 125;
      audioPlayerVM.changeAudioPlayPosition(
          // 765
          positiveOrNegativeDuration:
              Duration(seconds: forwardChangePositionThree));

      // obtain the current audio's position after
      // the undo and the new command
      Duration currentAudioPositionAfterUndoAndCommand =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndoAndCommand.inSeconds,
          currentAudioInitialPosition.inSeconds + 165); // 765

      // redo the last forward change (forward two)
      audioPlayerVM.redo();

      // obtain the current audio's position after the redoing
      // the last forward change (forward two)
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          120);

      // undo the last forward change (forward two), the new
      // command and the previous backward change (backward one)
      audioPlayerVM.undo(); // 765
      audioPlayerVM.undo(); // 640
      audioPlayerVM.undo(); // 700

      // obtain the current audio's position after the second redo
      Duration currentAudioPositionAfterThreeUndo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterThreeUndo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          100); // 700 - 600

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('AudioPlayerVM goToAudioPlayPosition undo/redo', () {
    test('Test single undo/redo of forward slider position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change the current audio's play slider position

      int forwardNewSliderPosition = 700;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPosition));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          100);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds, 700);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test('Test single undo/redo of backward slider position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change the current audio's play slider position

      int backwardNewSliderPosition = 540;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPosition));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          -60);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          -60);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test single undo/redo of multiple forward and backward slider position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change three times the current audio's play slider position

      int forwardNewSliderPositionOne = 700;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionOne));

      int backwardNewSliderPositionOne = 640;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPositionOne));

      int forwardNewSliderPositionTwo = 720;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionTwo));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          120);

      // undo the last change
      audioPlayerVM.undo();

      // obtain the current audio's position after the first undo
      Duration currentAudioPositionAfterFirstUndo =
          audioPlayerVM.currentAudioPosition; // 640

      expect(currentAudioPositionAfterFirstUndo.inSeconds, 640);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the first redo
      Duration currentAudioPositionAfterFirstRedo =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioPositionAfterFirstRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          120);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test multiple undo/redo of multiple forward and backward slider position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change three times the current audio's slider play position

      int forwardNewSliderPositionOne = 700;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionOne));

      int backwardNewSliderPositionOne = 640;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPositionOne));

      int forwardNewSliderPositionTwo = 720;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionTwo));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          120);

      // undo the last and previous change
      audioPlayerVM.undo(); // undo 720 --> 640
      audioPlayerVM.undo(); // undo 640 --> 700

      // obtain the current audio's position after the two undo's
      Duration currentAudioPositionAfterTwoUndo =
          audioPlayerVM.currentAudioPosition; // 700

      expect(currentAudioPositionAfterTwoUndo.inSeconds, 700);

      // redo the previous change
      audioPlayerVM.redo(); // redo 640 --> 640

      // obtain the current audio's position after the first redo
      Duration currentAudioPositionAfterFirstRedo =
          audioPlayerVM.currentAudioPosition; // 640

      expect(
          currentAudioPositionAfterFirstRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          40);

      // redo the last change
      audioPlayerVM.redo(); // redo 720 --> 720

      // obtain the current audio's position after the second redo
      Duration currentAudioPositionAfterSecondRedo =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioPositionAfterSecondRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          120);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test insert a new slider command between multiple undo/redo of multiple forward and backward slider position changes',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change three times the current audio's play position

      int forwardNewSliderPositionOne = 700;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionOne));

      int backwardNewSliderPositionOne = 640;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPositionOne));

      int forwardNewSliderPositionTwo = 720;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionTwo));

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioChangedPosition.inSeconds -
              currentAudioInitialPosition.inSeconds,
          120);

      // undo the last slider change
      audioPlayerVM.undo(); // undo 720 --> 640

      // enter a new command
      int forwardNewSliderPositionThree = 825;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionThree));

      // obtain the current audio's position after
      // the undo and the new slider command
      Duration currentAudioPositionAfterUndoAndNewSliderCommand =
          audioPlayerVM.currentAudioPosition; // 825

      expect(currentAudioPositionAfterUndoAndNewSliderCommand.inSeconds,
          currentAudioInitialPosition.inSeconds + 225); // 825

      // redo the last slider forward change (forward two)
      audioPlayerVM.redo(); // redo 720 --> 720

      // obtain the current audio's position after the redoing
      // the last forward change (forward two)
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition; // 720

      expect(
          currentAudioPositionAfterRedo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          120);

      // undo the last forward change (forward two), the new
      // command and the previous backward change (backward one)
      audioPlayerVM.undo(); // 720 --> 640
      audioPlayerVM.undo(); // 825 --> 640
      audioPlayerVM.undo(); // 640 --> 700

      // obtain the current audio's position after the second redo
      Duration currentAudioPositionAfterThreeUndo =
          audioPlayerVM.currentAudioPosition; // 700

      expect(
          currentAudioPositionAfterThreeUndo.inSeconds -
              currentAudioInitialPosition.inSeconds,
          100); // 700 - 600

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        "Test insert a new slider command after first undo forward slider position change, then perform one undo before one redo. This test could not be done in the AudioPlayerView integration test because the moving the slider to a new position is not possible in the integration test.",
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // change one time the current audio's play position

      int forwardNewSliderPositionOne = 720;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionOne));

      // check the current audio's changed position
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 720);

      // undo the first slider forward change
      audioPlayerVM.undo(); // undo 720 --> 600

      // enter a new command. Entering a new command does not affect the
      // undo command list
      int backwardNewSliderPositionTwo = 560;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPositionTwo));

      // check the current audio's position after the first undo and the
      // new slider backward command
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 560);

      // redo the first slider undone change (forward one). Entering a new
      // command did not affect the redoing of the first undone slider change
      audioPlayerVM.redo(); // redo 720 --> 720

      // check the current audio's position after the redoing the first
      // forward change (forward one)
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 720);

      // undo the redone first forward change (forward one)
      audioPlayerVM.undo(); // 720 --> 600

      // check the current audio's position after the first undo
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 600);

      // redo the first slider change
      audioPlayerVM.redo(); // redo 720 --> 720

      // check the current audio's position after the redo
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 720);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        "Test insert a new slider command after first undo forward slider position change, then perform two undo's before one redo in order to redo the new slider backward command. This test could not be done in the AudioPlayerView integration test because the moving the slider to a new position is not possible in the integration test.",
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // change one time the current audio's play position

      int forwardNewSliderPositionOne = 720;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: forwardNewSliderPositionOne));

      // check the current audio's changed position
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 720);

      // undo the first slider forward change
      audioPlayerVM.undo(); // undo 720 --> 600

      // enter a new command. Entering a new command does not affect the
      // undo command list
      int backwardNewSliderPositionTwo = 560;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(seconds: backwardNewSliderPositionTwo));

      // check the current audio's position after the first undo and the
      // new slider backward command
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 560);

      // redo the first slider undone change (forward one). Entering a new
      // command did not affect the redoing of the first undone slider change
      audioPlayerVM.redo(); // redo 720 --> 720

      // check the current audio's position after the redoing the first
      // forward change (forward one)
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 720);

      // undo the redone first forward change (forward one)
      audioPlayerVM.undo(); // 720 --> 600

      // perform a second undo in order to be able to redo the slider new
      // backward command
      audioPlayerVM.undo(); // 600 --> 600

      // check the current audio's position after the first undo
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 600);

      // redo the first slider change
      audioPlayerVM.redo(); // redo 560 --> 560

      // check the current audio's position after the redo
      expect(audioPlayerVM.currentAudioPosition.inSeconds, 560);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('AudioPlayerVM bug', () {
    test(
        'Test bug single undo/redo of sliding backward to 3 seconds and then going 1 minute backward',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change the current audio's play slider position to 3
      // seconds

      int backwardNewSliderPositionThreeSeconds = 3;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition:
              Duration(seconds: backwardNewSliderPositionThreeSeconds));

      // obtain the current audio's new position
      Duration currentAudioNewPosition =
          audioPlayerVM.currentAudioPosition; // 3

      expect(
          currentAudioInitialPosition.inSeconds - // 600 - 3
              currentAudioNewPosition.inSeconds,
          597);

      // change the current audio's play position minus 1 minute

      int backwardChangePositionOneMinute = -60;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: backwardChangePositionOneMinute));

      // obtain the current audio's changed position (0 second)
      currentAudioNewPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioNewPosition.inSeconds, 0);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds, 3);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test bug single undo/redo of sliding backward to 3 seconds and then going 10 seconds backward',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // change the current audio's play slider position to 3
      // seconds

      int backwardNewSliderPositionThreeSeconds = 3;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition:
              Duration(seconds: backwardNewSliderPositionThreeSeconds));

      // obtain the current audio's new position
      Duration currentAudioNewPosition =
          audioPlayerVM.currentAudioPosition; // 3

      expect(
          currentAudioInitialPosition.inSeconds - // 600 - 3
              currentAudioNewPosition.inSeconds,
          597);

      // change the current audio's play position minus 1 minute

      int backwardChangePositionTenSeconds = -10;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: backwardChangePositionTenSeconds));

      // obtain the current audio's changed position (0 second)
      currentAudioNewPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioNewPosition.inSeconds, 0);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds, 3);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test bug single undo/redo of sliding forward to 20 minutes 25 seconds and then going 1 minute forward',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // change the current audio's play slider position to 3
      // seconds

      int forwardNewSliderPositionTwentyMinutesTwentyFiveSeconds = 1225;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(
              seconds: forwardNewSliderPositionTwentyMinutesTwentyFiveSeconds));

      // obtain the current audio's new position
      Duration currentAudioNewPosition =
          audioPlayerVM.currentAudioPosition; // 20 minutes 25 secs = 1225 secs

      expect(currentAudioNewPosition.inSeconds, 1225);

      // change the current audio's play position plus 1 minute

      int backwardChangePositionOneMinute = 60;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: backwardChangePositionOneMinute));

      // obtain the current audio's changed position (audio duration)
      currentAudioNewPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioNewPosition.inSeconds,
          audioPlayerVM.currentAudio!.audioDuration!.inSeconds);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds, 1225);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test bug single undo/redo of sliding forward to 20 minutes 25 seconds and then going 10 seconds forward',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // change the current audio's play slider position to 3
      // seconds

      int forwardNewSliderPositionTwentyMinutesTwentyFiveSeconds = 1225;
      audioPlayerVM.goToAudioPlayPosition(
          durationPosition: Duration(
              seconds: forwardNewSliderPositionTwentyMinutesTwentyFiveSeconds));

      // obtain the current audio's new position
      Duration currentAudioNewPosition =
          audioPlayerVM.currentAudioPosition; // 20 minutes 25 secs = 1225 secs

      expect(currentAudioNewPosition.inSeconds, 1225);

      // change the current audio's play position plus 1 minute

      int forwardChangePositionTenSeconds = 10;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: forwardChangePositionTenSeconds));

      // obtain the current audio's changed position (audio duration)
      currentAudioNewPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioNewPosition.inSeconds,
          audioPlayerVM.currentAudio!.audioDuration!.inSeconds);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds, 1225);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('AudioPlayerVM skipToStart undo/redo', () {
    test('Test single undo/redo of skipToStart position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // skip to the start of the current audio

      await audioPlayerVM.skipToStart();

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 0);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds, 0);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test multiple undo/redo of multiple forward and skipToStart position change',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // skip to the end of the current audio

      audioPlayerVM.skipToStart();

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 0);

      // change the current audio's play position from the start
      // to 100 seconds

      int forwardChangePosition = 100;
      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration: Duration(seconds: forwardChangePosition));

      // obtain the current audio's changed position
      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(
          currentAudioChangedPosition.inSeconds, forwardChangePosition); // 100

      // skip a second time to the start of the current audio

      audioPlayerVM.skipToStart();

      // obtain the current audio's changed position
      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 0);

      // undo the second skip to start
      audioPlayerVM.undo();

      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 100);

      // undo forward change to 100 seconds
      audioPlayerVM.undo();

      // obtain the current audio's position after the second undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds, 0);

      // undo the first skip to start
      audioPlayerVM.undo();

      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 600);

      // redo the first skip to start
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds, 0);

      // redo the first forward change to 100 seconds
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      currentAudioPositionAfterRedo = audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds, 100);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('AudioPlayerVM skipToEndAndPlay undo/redo', () {
    test('Test single undo/redo of skipToEnd position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // skip to the end of the current audio

      audioPlayerVM.skipToEndAndPlay();

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          audioPlayerVM.currentAudio!.audioDuration!.inSeconds);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds,
          audioPlayerVM.currentAudio!.audioDuration!.inSeconds);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test multiple undo/redo of multiple forward and skipToEnd position change',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // skip to the start of the current audio

      audioPlayerVM.skipToEndAndPlay();

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      int currentAudioTotalDurationInSeconds =
          audioPlayerVM.currentAudioTotalDuration.inSeconds;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds);

      // change the current audio's play position from the start
      // to 100 seconds

      int backwardChangePosition = -100;

      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: backwardChangePosition));

      // obtain the current audio's changed position
      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds - 100);

      // skip a second time to the end of the current audio

      audioPlayerVM.skipToEndAndPlay();

      // obtain the current audio's changed position
      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds);

      // undo the second skip to end
      audioPlayerVM.undo();

      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds - 100); // 100

      // undo backward change to -100 seconds
      audioPlayerVM.undo();

      // obtain the current audio's position after the second undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioTotalDurationInSeconds);

      // undo the first skip to end
      audioPlayerVM.undo();

      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 600);

      // redo the first skip to end
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds,
          currentAudioTotalDurationInSeconds);

      // redo the first backward change to -100 seconds
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      currentAudioPositionAfterRedo = audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds,
          currentAudioTotalDurationInSeconds - 100);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
  group('AudioPlayerVM skipToEndNoPlay (method not used) undo/redo', () {
    test('Test single undo/redo of skipToEnd position change', () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // obtain the current audio's initial position
      Duration currentAudioInitialPosition =
          audioPlayerVM.currentAudioPosition; // 600

      // skip to the end of the current audio

      audioPlayerVM.skipToEndNoPlay();

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          audioPlayerVM.currentAudio!.audioDuration!.inSeconds);

      // undo the change
      audioPlayerVM.undo();

      // obtain the current audio's position after the undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioInitialPosition.inSeconds);

      // redo the change
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds,
          audioPlayerVM.currentAudio!.audioDuration!.inSeconds);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
    test(
        'Test multiple undo/redo of multiple forward and skipToEnd position change',
        () async {
      AudioPlayerVM audioPlayerVM = await createAudioPlayerVM();

      // obtain the list of playable audios of the selected
      // playlist ordered by download date
      List<Audio> selectedPlaylistAudioList =
          audioPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.playlistDownloadView,
      );

      // set the current audio to the first audio in the list
      await audioPlayerVM.setCurrentAudio(selectedPlaylistAudioList[0]);

      // skip to the end of the current audio

      audioPlayerVM.skipToEndNoPlay();

      // obtain the current audio's changed position
      Duration currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      int currentAudioTotalDurationInSeconds =
          audioPlayerVM.currentAudioTotalDuration.inSeconds;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds);

      // change the current audio's play position from the start
      // to 100 seconds

      int backwardChangePosition = -100;

      audioPlayerVM.changeAudioPlayPosition(
          positiveOrNegativeDuration:
              Duration(seconds: backwardChangePosition));

      // obtain the current audio's changed position
      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds - 100);

      // skip a second time to the end of the current audio

      audioPlayerVM.skipToEndNoPlay();

      // obtain the current audio's changed position
      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds);

      // undo the second skip to end
      audioPlayerVM.undo();

      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds,
          currentAudioTotalDurationInSeconds - 100); // 100

      // undo backward change to -100 seconds
      audioPlayerVM.undo();

      // obtain the current audio's position after the second undo
      Duration currentAudioPositionAfterUndo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterUndo.inSeconds,
          currentAudioTotalDurationInSeconds);

      // undo the first skip to end
      audioPlayerVM.undo();

      currentAudioChangedPosition = audioPlayerVM.currentAudioPosition;

      expect(currentAudioChangedPosition.inSeconds, 600);

      // redo the first skip to end
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      Duration currentAudioPositionAfterRedo =
          audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds,
          currentAudioTotalDurationInSeconds);

      // redo the first backward change to -100 seconds
      audioPlayerVM.redo();

      // obtain the current audio's position after the redo
      currentAudioPositionAfterRedo = audioPlayerVM.currentAudioPosition;

      expect(currentAudioPositionAfterRedo.inSeconds,
          currentAudioTotalDurationInSeconds - 100);

      // Purge the test playlist directory so that the created test
      // files are not uploaded to GitHub
      DirUtil.deleteFilesInDirAndSubDirs(
          rootPath: kPlaylistDownloadRootPathWindowsTest);
    });
  });
}

Future<AudioPlayerVM> createAudioPlayerVM() async {
  final SettingsDataService settingsDataService =
      await initializeTestDataAndLoadSettingsDataService(
    savedTestDataDirName: 'audio_player_vm_play_position_undo_redo_test',
  );
  final WarningMessageVM warningMessageVM = WarningMessageVM();
  final AudioDownloadVM audioDownloadVM = AudioDownloadVM(
    warningMessageVM: warningMessageVM,
    settingsDataService: settingsDataService,
    isTest: true,
  );
  final PlaylistListVM playlistListVM = PlaylistListVM(
    warningMessageVM: warningMessageVM,
    audioDownloadVM: audioDownloadVM,
    settingsDataService: settingsDataService,
  );

  // calling getUpToDateSelectablePlaylists() loads all the
  // playlist json files from the app dir and so enables
  // playlistListVM to know which playlists are
  // selected and which are not
  playlistListVM.getUpToDateSelectablePlaylists();

  AudioPlayerVM audioPlayerVM = AudioPlayerVMTestVersion(
    playlistListVM: playlistListVM,
  );

  return audioPlayerVM;
}

Future<SettingsDataService> initializeTestDataAndLoadSettingsDataService({
  String? savedTestDataDirName,
}) async {
  // Purge the test playlist directory if it exists so that the
  // playlist list is empty
  DirUtil.deleteFilesInDirAndSubDirs(
    rootPath: kPlaylistDownloadRootPathWindowsTest,
    deleteSubDirectoriesAsWell:
        true, // reduce number of times the Flutter test fails. Not explanable.
  );

  if (savedTestDataDirName != null) {
    // Copy the test initial audio data to the app dir
    DirUtil.copyFilesFromDirAndSubDirsToDirectory(
      sourceRootPath:
          "$kDownloadAppTestSavedDataDir${Platform.pathSeparator}$savedTestDataDirName",
      destinationRootPath: kPlaylistDownloadRootPathWindowsTest,
    );
  }

      SettingsDataService settingsDataService = SettingsDataService(
        sharedPreferences: MockSharedPreferences(),
        isTest: true,
      );

  // Load the settings from the json file. This is necessary
  // otherwise the ordered playlist titles will remain empty
  // and the playlist list will not be filled with the
  // playlists available in the download app test dir
  await settingsDataService.loadSettingsFromFile(
      settingsJsonPathFileName:
          "$kPlaylistDownloadRootPathWindowsTest${Platform.pathSeparator}$kSettingsFileName");

  return settingsDataService;
}
