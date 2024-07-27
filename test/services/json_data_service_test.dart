import 'package:audiolearn/models/comment.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/models/playlist.dart';
import 'package:audiolearn/services/json_data_service.dart';
import 'package:audiolearn/services/sort_filter_parameters.dart';

class UnsupportedClass {}

class MyUnsupportedTestClass {
  final String name;
  final int value;

  MyUnsupportedTestClass({required this.name, required this.value});

  factory MyUnsupportedTestClass.fromJson(Map<String, dynamic> json) {
    return MyUnsupportedTestClass(
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

void main() {
  const jsonPath = 'test.json';

  group('JsonDataService individual', () {
    test(
        'saveToFile and loadFromFile for one Audio instance, audioPausedDateTime == null',
        () async {
      // Create a temporary directory to store the serialized Audio
      // object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'audio.json');

      // Create an Audio instance
      Audio originalAudio = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video Title',
        compactVideoDescription: '',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );

      // Save the Audio instance to a file
      JsonDataService.saveToFile(model: originalAudio, path: filePath);

      // Load the Audio instance from the file
      Audio deserializedAudio =
          JsonDataService.loadFromFile(jsonPathFileName: filePath, type: Audio);

      // Compare the deserialized Audio instance with the original
      // Audio instance
      compareDeserializedWithOriginalAudio(
        deserializedAudio: deserializedAudio,
        originalAudio: originalAudio,
      );

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test(
        'saveToFile and loadFromFile for one Audio instance, audioPausedDateTime not null',
        () async {
      // Create a temporary directory to store the serialized Audio
      // object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'audio.json');

      // Create an Audio instance
      Audio originalAudio = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video Title',
        compactVideoDescription: '',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 50, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
        isPaused: true,
        audioPausedDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioPositionSeconds: 1800,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: true,
      );

      // Save the Audio instance to a file
      JsonDataService.saveToFile(model: originalAudio, path: filePath);

      // Load the Audio instance from the file
      Audio deserializedAudio =
          JsonDataService.loadFromFile(jsonPathFileName: filePath, type: Audio);

      // Compare the deserialized Audio instance with the original
      // Audio instance
      compareDeserializedWithOriginalAudio(
        deserializedAudio: deserializedAudio,
        originalAudio: originalAudio,
      );

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });

    test('loadFromFile one Audio instance file not exist', () async {
      // Create a temporary directory to store the serialized Audio object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'audio.json');
      // Load the Audio instance from the file
      dynamic deserializedAudio =
          JsonDataService.loadFromFile(jsonPathFileName: filePath, type: Audio);

      expect(deserializedAudio, null);

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test(
        'saveToFile and loadFromFile for one Audio instance with null audioDuration',
        () async {
      // Create a temporary directory to store the serialized Audio object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'audio.json');

      // Create an Audio instance
      Audio originalAudio = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video Title',
        compactVideoDescription: '',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 1, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: null,
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false
      );

      // Save the Audio instance to a file
      JsonDataService.saveToFile(model: originalAudio, path: filePath);

      // Load the Audio instance from the file
      Audio deserializedAudio =
          JsonDataService.loadFromFile(jsonPathFileName: filePath, type: Audio);

      // Compare the deserialized Audio instance with the original
      // Audio instance
      compareDeserializedWithOriginalAudio(
        deserializedAudio: deserializedAudio,
        originalAudio: originalAudio,
      );

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test('saveToFile and loadFromFile for one Playlist instance', () async {
      // Create a temporary directory to store the serialized Audio object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'playlist.json');

      const String testFromPlaylistTitle = 'testFromPlaylist1ID';
      const String testToPlaylistTitle = 'testToPlaylist1ID';

      // Create a Playlist with 2 Audio instances
      Playlist testPlaylist = Playlist(
        id: 'testPlaylist1ID',
        title: 'Test Playlist',
        url: 'https://www.example.com/playlist-url',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
        isSelected: true,
      );

      testPlaylist.downloadPath = 'path/to/downloads';

      Audio audio1 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylist,
        movedFromPlaylistTitle: testFromPlaylistTitle,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video 1',
        compactVideoDescription: 'Test Video 1 Description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-1',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 10)),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false
      );

      Audio audio2 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: testToPlaylistTitle,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: testToPlaylistTitle,
        originalVideoTitle: 'Test Video 2',
        compactVideoDescription: 'Test Video 2 Description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-2',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 38),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 5)),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: true,
      );

      testPlaylist.downloadedAudioLst = [audio1, audio2];
      testPlaylist.playableAudioLst = [audio2];

      testPlaylist.audioSortFilterParmsForPlaylistDownloadView =
          createAudioSortFilterParameters();
      testPlaylist.audioSortFilterParmsForAudioPlayerView =
          createAudioSortFilterParameters();

      // Save Playlist to a file
      JsonDataService.saveToFile(model: testPlaylist, path: filePath);

      // Load Playlist from the file
      Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: filePath, type: Playlist);

      // Compare original and loaded Playlist
      compareDeserializedWithOriginalPlaylist(
        deserializedPlaylist: loadedPlaylist,
        originalPlaylist: testPlaylist,
      );

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test('saveToFile and loadFromFile for one Playlist instance without Audio',
        () async {
      // Create a temporary directory to store the serialized Audio object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'playlist.json');

      // Create a Playlist with 2 Audio instances
      Playlist testPlaylist = Playlist(
        id: 'testPlaylist1ID',
        title: 'Test Playlist',
        url: 'https://www.example.com/playlist-url',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
        isSelected: true,
      );

      testPlaylist.downloadPath = 'path/to/downloads';

      testPlaylist.audioSortFilterParmsForPlaylistDownloadView =
          createAudioSortFilterParameters();
      testPlaylist.audioSortFilterParmsForAudioPlayerView =
          createAudioSortFilterParameters();

      // Save Playlist to a file
      JsonDataService.saveToFile(model: testPlaylist, path: filePath);

      // Load Playlist from the file
      Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: filePath, type: Playlist);

      // Compare original and loaded Playlist
      compareDeserializedWithOriginalPlaylist(
        deserializedPlaylist: loadedPlaylist,
        originalPlaylist: testPlaylist,
      );

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test(
        'saveToFile and loadFromFile for one Playlist instance without AudioSortFilterParameters',
        () async {
      // Create a temporary directory to store the serialized Audio object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'playlist.json');

      const String testFromPlaylistTitle = 'testFromPlaylist1ID';
      const String testToPlaylistTitle = 'testToPlaylist1ID';

      // Create a Playlist with 2 Audio instances
      Playlist testPlaylist = Playlist(
        id: 'testPlaylist1ID',
        title: 'Test Playlist',
        url: 'https://www.example.com/playlist-url',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
        isSelected: true,
      );

      testPlaylist.downloadPath = 'path/to/downloads';

      Audio audio1 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylist,
        movedFromPlaylistTitle: testFromPlaylistTitle,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video 1',
        compactVideoDescription: 'Test Video 1 Description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-1',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 10)),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );

      Audio audio2 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylist,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: testToPlaylistTitle,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: testToPlaylistTitle,
        originalVideoTitle: 'Test Video 2',
        compactVideoDescription: 'Test Video 2 Description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-2',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 38),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 5)),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: true,
      );

      testPlaylist.downloadedAudioLst = [audio1, audio2];
      testPlaylist.playableAudioLst = [audio2];

      // Save Playlist to a file
      JsonDataService.saveToFile(model: testPlaylist, path: filePath);

      // Load Playlist from the file
      Playlist loadedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: filePath, type: Playlist);

      // Compare original and loaded Playlist
      compareDeserializedWithOriginalPlaylist(
        deserializedPlaylist: loadedPlaylist,
        originalPlaylist: testPlaylist,
      );

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test('loadFromFile one Playlist instance file not exist', () async {
      // Create a temporary directory to store the serialized Playlist
      // object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'playlist.json');
      // Load the Playlist instance from the file
      dynamic deserializedPlaylist = JsonDataService.loadFromFile(
          jsonPathFileName: filePath, type: Playlist);

      expect(deserializedPlaylist, null);

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test('saveToFile and loadFromFile for one SortingItem instance', () async {
      // Create a temporary directory to store the serialized SortingItem
      // object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'sorting_item.json');

      SortingItem testSortingItem = SortingItem(
        sortingOption: SortingOption.audioDownloadDate,
        isAscending: true,
      );

      // Save SortingItem to a file
      JsonDataService.saveToFile(model: testSortingItem, path: filePath);

      // Load SortingItem from the file
      SortingItem loadedSortingItem = JsonDataService.loadFromFile(
          jsonPathFileName: filePath, type: SortingItem);

      // Compare original and loaded SortingItem
      compareDeserializedWithOriginalSortingItem(
        deserializedSortingItem: loadedSortingItem,
        originalSortingItem: testSortingItem,
      );

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test('loadFromFile one SortingItem instance file not exist', () async {
      // Create a temporary directory to store the serialized
      // SortingItem object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath = path.join(tempDir.path, 'sorting_item.json');
      // Load the SortingItem instance from the file
      dynamic deserializedSortingItem = JsonDataService.loadFromFile(
          jsonPathFileName: filePath, type: SortingItem);

      expect(deserializedSortingItem, null);

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test(
        'saveToFile and loadFromFile for one AudioSortFilterParameters instance',
        () async {
      // Create a temporary directory to store the serialized
      // AudioSortFilterParameters object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath =
          path.join(tempDir.path, 'audio_sort_filter_parameters.json');

      AudioSortFilterParameters testAudioSortFilterParameters =
          createAudioSortFilterParameters();

      // Save AudioSortFilterParameters to a file
      JsonDataService.saveToFile(
          model: testAudioSortFilterParameters, path: filePath);

      // Load AudioSortFilterParameters from the file
      AudioSortFilterParameters loadedAudioSortFilterParameters =
          JsonDataService.loadFromFile(
              jsonPathFileName: filePath, type: AudioSortFilterParameters);

      // Compare original and loaded AudioSortFilterParameters
      compareDeserializedWithOriginalAudioSortFilterParameters(
        deserializedAudioSortFilterParameters: loadedAudioSortFilterParameters,
        originalAudioSortFilterParameters: testAudioSortFilterParameters,
      );

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test('loadFromFile one AudioSortFilterParameters instance file not exist',
        () async {
      // Create a temporary directory to store the serialized
      // AudioSortFilterParameters object
      Directory tempDir = await Directory.systemTemp.createTemp('AudioTest');
      String filePath =
          path.join(tempDir.path, 'audio_sort_filter_parameters.json');
      // Load the AudioSortFilterParameters instance from the file
      dynamic deserializedSortingItem = JsonDataService.loadFromFile(
          jsonPathFileName: filePath, type: SortingItem);

      expect(deserializedSortingItem, null);

      // Cleanup the temporary directory
      await tempDir.delete(recursive: true);
    });
    test('saveToFile and loadFromFile for one Comment instance', () async {
      // Create a temporary directory to store the serialized SortingItem
      // object
      String testPathStr =
          '$kPlaylistDownloadRootPathWindowsTest\\audiolearn_test_comment';
      const String commentFilePathName =
          '$kPlaylistDownloadRootPathWindowsTest\\audiolearn_test_comment\\comment.json';
      await DirUtil.createDirIfNotExist(pathStr: testPathStr);

      Comment testComment = Comment(
        title: 'Test Title',
        content: 'Test Content',
        commentStartPositionInTenthOfSeconds: 0,
      );

      // Save Comment to a file
      JsonDataService.saveToFile(model: testComment, path: commentFilePathName);

      // Load Comment from the file
      Comment loadedCommentItem = JsonDataService.loadFromFile(
          jsonPathFileName: commentFilePathName, type: Comment);

      // Compare original and loaded SortingItem
      compareDeserializedWithOriginalComment(
        deserializedComment: loadedCommentItem,
        originalComment: testComment,
      );

      // Cleanup the temporary directory
      DirUtil.deleteDirAndSubDirsIfExist(
        rootPath: testPathStr,
      );
    });
    test('ClassNotContainedInJsonFileException', () {
      // Prepare a temporary file
      File tempFile = File('temp.json');
      tempFile.writeAsStringSync(jsonEncode({'test': 'data'}));

      try {
        // Try to load a MyClass instance from the temporary file, which
        // should throw an exception
        JsonDataService.loadFromFile(
            jsonPathFileName: 'temp.json', type: Audio);
      } catch (e) {
        expect(e, isA<ClassNotContainedInJsonFileException>());
      } finally {
        tempFile.deleteSync(); // Clean up the temporary file
      }
    });

    test('loadFomFile on empty file', () {
      // Prepare a temporary file
      String fileName = 'temp.json';
      File tempEmptyJsonFile = File(fileName);
      tempEmptyJsonFile.writeAsStringSync("");

      // Try to load a MyClass instance from the temporary file, which
      // should throw an exception
      expect(
          () => JsonDataService.loadFromFile(
              jsonPathFileName: fileName, type: Comment),
          throwsA(predicate((e) =>
              e is ClassNotContainedInJsonFileException &&
              e.toString().contains(fileName))));
    });
    test('loadFomFile on empty file', () {
      // Prepare a temporary file
      String fileName = 'temp.json';
      File tempEmptyJsonFile = File(fileName);
      tempEmptyJsonFile.writeAsStringSync("");

      // Try to load a MyClass instance from the temporary file, which
      // should throw an exception
      expect(
          () => JsonDataService.loadFromFile(
              jsonPathFileName: fileName, type: Comment),
          throwsA(predicate((e) =>
              e is ClassNotContainedInJsonFileException &&
              e.toString().contains(fileName))));
    });
    test('ClassNotSupportedByToJsonDataServiceException', () {
      // Create a class not supported by JsonDataService

      try {
        // Try to encode an instance of UnsupportedClass, which should throw an exception
        JsonDataService.encodeJson(UnsupportedClass());
      } catch (e) {
        expect(e, isA<ClassNotSupportedByToJsonDataServiceException>());
      }
    });
  });
  group('JsonDataService list', () {
    test('saveListToFile() ClassNotSupportedByToJsonDataServiceException', () {
      // Prepare test data
      List<MyUnsupportedTestClass> testList = [
        MyUnsupportedTestClass(name: 'Test1', value: 1),
        MyUnsupportedTestClass(name: 'Test2', value: 2),
      ];

      // Save the list to a file
      try {
        // Try to decode the JSON string into an instance of UnsupportedClass, which should throw an exception
        JsonDataService.saveListToFile(
            jsonPathFileName: jsonPath, data: testList);
      } catch (e) {
        expect(e, isA<ClassNotSupportedByToJsonDataServiceException>());
      }
    });
    test('saveListToFile() ClassNotSupportedByFromJsonDataServiceException',
        () {
      // Create an Audio instance
      Audio originalAudio = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video Title',
        compactVideoDescription: '',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );

      // Save the Audio instance to a file
      JsonDataService.saveToFile(model: originalAudio, path: jsonPath);

      // Load the list from the file
      try {
        JsonDataService.loadListFromFile(
            jsonPathFileName: jsonPath, type: MyUnsupportedTestClass);
      } catch (e) {
        expect(e, isA<ClassNotSupportedByFromJsonDataServiceException>());
      }

      // Clean up the test file
      File(jsonPath).deleteSync();
    });
    test('saveListToFile() and loadListFromFile() for Audio list', () async {
      // Create an Audio instance
      Audio audioOne = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video One Title',
        compactVideoDescription: '',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );

      Audio audioTwo = Audio.fullConstructor(
        enclosingPlaylist: null,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video Title',
        compactVideoDescription: '',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.youtube.com/watch?v=testVideoID',
        audioDownloadDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioDownloadDuration: const Duration(minutes: 50, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime(2023, 3, 1),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: true,
        isPaused: true,
        audioPausedDateTime: DateTime(2023, 3, 24, 20, 5, 32),
        audioPositionSeconds: 1800,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: true,
      );

      // Prepare test data
      List<Audio> testList = [audioOne, audioTwo];

      // Save the list to a file
      JsonDataService.saveListToFile(
          data: testList, jsonPathFileName: jsonPath);

      // Load the list from the file
      List<Audio> loadedList = JsonDataService.loadListFromFile(
          jsonPathFileName: jsonPath, type: Audio);

      // Check if the loaded list matches the original list
      expect(loadedList.length, testList.length);

      for (int i = 0; i < loadedList.length; i++) {
        compareDeserializedWithOriginalAudio(
          deserializedAudio: loadedList[i],
          originalAudio: testList[i],
        );
      }

      // Clean up the test file
      File(jsonPath).deleteSync();
    });
    test('loadListFromFile() for Audio list file not exist', () {
      // Load the list from the file
      List<Audio> loadedList = JsonDataService.loadListFromFile(
          jsonPathFileName: jsonPath, type: Audio);

      // Check if the loaded list matches the original list
      expect(loadedList.length, 0);
    });
    test('saveListToFile() and loadListFromFile() for Playlist list', () {
      // Create an Playlist instance
      Playlist testPlaylistOne = Playlist(
        id: 'testPlaylistID1',
        title: 'Test Playlist One',
        url: 'https://www.example.com/playlist-url',
        playlistType: PlaylistType.local,
        playlistQuality: PlaylistQuality.music,
        isSelected: true,
      );

      testPlaylistOne.downloadPath = 'path/to/downloads';

      Audio audio1 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylistOne,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video 1',
        compactVideoDescription: 'Test Video 1 compact description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-1',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 10)),
        audioDuration: null,
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );

      Audio audio2 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylistOne,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video 2',
        compactVideoDescription: 'Test Video 2 compact description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-2',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 5)),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: true,
      );

      testPlaylistOne.addDownloadedAudio(audio1);
      testPlaylistOne.addDownloadedAudio(audio2);

      Playlist testPlaylistTwo = Playlist(
        id: 'testPlaylistID2',
        title: 'Test Playlist Two',
        url: 'https://www.example.com/playlist-url',
        playlistType: PlaylistType.youtube,
        playlistQuality: PlaylistQuality.voice,
        isSelected: false,
      );

      testPlaylistTwo.downloadPath = 'path/to/downloads';

      Audio audio3 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylistTwo,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video 1',
        compactVideoDescription: 'Test Video 1 compact description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-1',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 10)),
        audioDuration: null,
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: false,
      );

      Audio audio4 = Audio.fullConstructor(
        enclosingPlaylist: testPlaylistTwo,
        movedFromPlaylistTitle: null,
        movedToPlaylistTitle: null,
        copiedFromPlaylistTitle: null,
        copiedToPlaylistTitle: null,
        originalVideoTitle: 'Test Video 2',
        compactVideoDescription: 'Test Video 2 compact description',
        validVideoTitle: 'Test Video Title',
        videoUrl: 'https://www.example.com/video-url-2',
        audioDownloadDateTime: DateTime.now(),
        audioDownloadDuration: const Duration(minutes: 0, seconds: 30),
        audioDownloadSpeed: 1000000,
        videoUploadDate: DateTime.now().subtract(const Duration(days: 5)),
        audioDuration: const Duration(minutes: 5, seconds: 30),
        isAudioMusicQuality: false,
        audioPlaySpeed: kAudioDefaultPlaySpeed,
        audioPlayVolume: kAudioDefaultPlayVolume,
        isPlayingOrPausedWithPositionBetweenAudioStartAndEnd: false,
        isPaused: true,
        audioPausedDateTime: null,
        audioPositionSeconds: 0,
        audioFileName: 'Test Video Title.mp3',
        audioFileSize: 330000000,
        isAudioImported: true,
      );

      testPlaylistTwo.addDownloadedAudio(audio3);
      testPlaylistTwo.addDownloadedAudio(audio4);

      // Prepare test data
      List<Playlist> testList = [testPlaylistOne, testPlaylistTwo];

      // Save the list to a file
      JsonDataService.saveListToFile(
          data: testList, jsonPathFileName: jsonPath);

      // Load the list from the file
      List<Playlist> loadedList = JsonDataService.loadListFromFile(
          jsonPathFileName: jsonPath, type: Playlist);

      // Check if the loaded list matches the original list
      expect(loadedList.length, testList.length);

      for (int i = 0; i < loadedList.length; i++) {
        compareDeserializedWithOriginalPlaylist(
          deserializedPlaylist: loadedList[i],
          originalPlaylist: testList[i],
        );
      }

      // Clean up the test file
      File(jsonPath).deleteSync();
    });
    test('loadListFromFile() for Playlist list file not exist', () {
      // Load the list from the file
      List<Audio> loadedList = JsonDataService.loadListFromFile(
          jsonPathFileName: jsonPath, type: Playlist);

      // Check if the loaded list matches the original list
      expect(loadedList.length, 0);
    });
    test('saveListToFile() and loadListFromFile() for Comment list', () {
      // Create an Comment instance
      Comment testCommentOne = Comment(
        title: 'Test Title 1',
        content: 'Test Content 1',
        commentStartPositionInTenthOfSeconds: 0,
      );

      Comment testCommentTwo = Comment(
        title: 'Test Title 2',
        content: 'Test Content 2',
        commentStartPositionInTenthOfSeconds: 0,
      );

      // Prepare test data
      List<Comment> testList = [testCommentOne, testCommentTwo];

      // Save the list to a file
      JsonDataService.saveListToFile(
          data: testList, jsonPathFileName: jsonPath);

      // Load the list from the file
      List<Comment> loadedList = JsonDataService.loadListFromFile(
          jsonPathFileName: jsonPath, type: Comment);

      // Check if the loaded list matches the original list
      expect(loadedList.length, testList.length);

      for (int i = 0; i < loadedList.length; i++) {
        compareDeserializedWithOriginalComment(
          deserializedComment: loadedList[i],
          originalComment: testList[i],
        );
      }

      // Clean up the test file
      File(jsonPath).deleteSync();
    });
    test('loadListFomFile on empty file', () {
      // Prepare a temporary file
      String fileName = 'temp.json';
      File tempEmptyJsonFile = File(fileName);
      tempEmptyJsonFile.writeAsStringSync("");

      // Try to load a MyClass instance from the temporary file, which
      // should throw an exception
      expect(
          JsonDataService.loadListFromFile(
              jsonPathFileName: fileName, type: Comment),
          []);
    });
  });
}

AudioSortFilterParameters createAudioSortFilterParameters() {
  SortingItem sortingItem1 = SortingItem(
    sortingOption: SortingOption.audioDownloadDate,
    isAscending: true,
  );
  SortingItem sortingItem2 = SortingItem(
    sortingOption: SortingOption.audioDuration,
    isAscending: true,
  );

  return AudioSortFilterParameters(
    selectedSortItemLst: [sortingItem1, sortingItem2],
    filterSentenceLst: ['Janco', 'Hello world'],
    sentencesCombination: SentencesCombination.AND,
    ignoreCase: true,
    searchAsWellInVideoCompactDescription: true,
    filterMusicQuality: false,
    filterFullyListened: false,
    filterPartiallyListened: false,
    filterNotListened: false,
    downloadDateStartRange: DateTime(2023, 2, 24, 20, 5, 32),
    downloadDateEndRange: DateTime(2023, 3, 24, 20, 5, 32),
    uploadDateStartRange: DateTime(2023, 2, 4, 20, 5, 32),
    uploadDateEndRange: DateTime(2023, 3, 4, 20, 5, 32),
    fileSizeStartRangeMB: 0.1,
    fileSizeEndRangeMB: 20.235,
    durationStartRangeSec: 1000,
    durationEndRangeSec: 2000,
  );
}

void compareDeserializedWithOriginalPlaylist({
  required Playlist deserializedPlaylist,
  required Playlist originalPlaylist,
}) {
  expect(deserializedPlaylist.id, originalPlaylist.id);
  expect(deserializedPlaylist.title, originalPlaylist.title);
  expect(deserializedPlaylist.url, originalPlaylist.url);
  expect(deserializedPlaylist.playlistType, originalPlaylist.playlistType);
  expect(
      deserializedPlaylist.playlistQuality, originalPlaylist.playlistQuality);
  expect(deserializedPlaylist.downloadPath, originalPlaylist.downloadPath);
  expect(deserializedPlaylist.isSelected, originalPlaylist.isSelected);

  // Compare Audio instances in original and loaded Playlist
  expect(deserializedPlaylist.downloadedAudioLst.length,
      originalPlaylist.downloadedAudioLst.length);
  expect(deserializedPlaylist.playableAudioLst.length,
      originalPlaylist.playableAudioLst.length);

  for (int i = 0; i < deserializedPlaylist.downloadedAudioLst.length; i++) {
    Audio originalAudio = originalPlaylist.downloadedAudioLst[i];
    Audio loadedAudio = deserializedPlaylist.downloadedAudioLst[i];

    compareDeserializedWithOriginalAudio(
      deserializedAudio: loadedAudio,
      originalAudio: originalAudio,
    );
  }

  for (int i = 0; i < deserializedPlaylist.playableAudioLst.length; i++) {
    Audio originalAudio = originalPlaylist.playableAudioLst[i];
    Audio loadedAudio = deserializedPlaylist.playableAudioLst[i];

    compareDeserializedWithOriginalAudio(
      deserializedAudio: loadedAudio,
      originalAudio: originalAudio,
    );
  }
}

void compareDeserializedWithOriginalAudio({
  required Audio deserializedAudio,
  required Audio originalAudio,
}) {
  (deserializedAudio.enclosingPlaylist != null)
      ? expect(deserializedAudio.enclosingPlaylist!.title,
          originalAudio.enclosingPlaylist!.title)
      : expect(
          deserializedAudio.enclosingPlaylist, originalAudio.enclosingPlaylist);
  (deserializedAudio.movedFromPlaylistTitle != null)
      ? expect(deserializedAudio.movedFromPlaylistTitle,
          originalAudio.movedFromPlaylistTitle)
      : expect(deserializedAudio.movedFromPlaylistTitle,
          originalAudio.movedFromPlaylistTitle);
  (deserializedAudio.movedToPlaylistTitle != null)
      ? expect(deserializedAudio.movedToPlaylistTitle,
          originalAudio.movedToPlaylistTitle)
      : expect(deserializedAudio.movedToPlaylistTitle,
          originalAudio.movedToPlaylistTitle);
  (deserializedAudio.copiedFromPlaylistTitle != null)
      ? expect(deserializedAudio.copiedFromPlaylistTitle,
          originalAudio.copiedFromPlaylistTitle)
      : expect(deserializedAudio.copiedFromPlaylistTitle,
          originalAudio.copiedFromPlaylistTitle);
  (deserializedAudio.copiedToPlaylistTitle != null)
      ? expect(deserializedAudio.copiedToPlaylistTitle,
          originalAudio.copiedToPlaylistTitle)
      : expect(deserializedAudio.copiedToPlaylistTitle,
          originalAudio.copiedToPlaylistTitle);
  expect(
      deserializedAudio.originalVideoTitle, originalAudio.originalVideoTitle);
  expect(deserializedAudio.validVideoTitle, originalAudio.validVideoTitle);
  expect(deserializedAudio.compactVideoDescription,
      originalAudio.compactVideoDescription);
  expect(deserializedAudio.videoUrl, originalAudio.videoUrl);
  expect(deserializedAudio.audioDownloadDateTime.toIso8601String(),
      originalAudio.audioDownloadDateTime.toIso8601String());
  expect(deserializedAudio.audioDownloadDuration,
      originalAudio.audioDownloadDuration ?? const Duration(milliseconds: 0));
  expect(
      deserializedAudio.audioDownloadSpeed, originalAudio.audioDownloadSpeed);
  expect(deserializedAudio.videoUploadDate.toIso8601String(),
      originalAudio.videoUploadDate.toIso8601String());

  // inMilliseconds is used because the duration is not exactly the same
  // when it is serialized and deserialized since it is stored in the json
  // file as a number of milliseconds
  expect(deserializedAudio.audioDownloadDuration!.inMilliseconds,
      originalAudio.audioDownloadDuration!.inMilliseconds);

  expect(
      deserializedAudio.isAudioMusicQuality, originalAudio.isAudioMusicQuality);
  expect(deserializedAudio.audioPlaySpeed, originalAudio.audioPlaySpeed);
  expect(deserializedAudio.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd,
      originalAudio.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd);
  expect(deserializedAudio.isPaused, originalAudio.isPaused);
  expect(deserializedAudio.audioPausedDateTime?.toIso8601String(),
      originalAudio.audioPausedDateTime?.toIso8601String());
  expect(deserializedAudio.audioPositionSeconds,
      originalAudio.audioPositionSeconds);
  expect(deserializedAudio.audioFileName, originalAudio.audioFileName);
  expect(deserializedAudio.audioFileSize, originalAudio.audioFileSize);
}

void compareDeserializedWithOriginalSortingItem({
  required SortingItem deserializedSortingItem,
  required SortingItem originalSortingItem,
}) {
  expect(
      deserializedSortingItem.sortingOption, originalSortingItem.sortingOption);
  expect(deserializedSortingItem.isAscending, originalSortingItem.isAscending);
}

void compareDeserializedWithOriginalComment({
  required Comment deserializedComment,
  required Comment originalComment,
}) {
  expect(deserializedComment.title, originalComment.title);
  expect(deserializedComment.content, originalComment.content);
  expect(deserializedComment.commentStartPositionInTenthOfSeconds,
      originalComment.commentStartPositionInTenthOfSeconds);
  expect(deserializedComment.creationDateTime.toIso8601String(),
      originalComment.creationDateTime.toIso8601String());
}

void compareDeserializedWithOriginalAudioSortFilterParameters({
  required AudioSortFilterParameters deserializedAudioSortFilterParameters,
  required AudioSortFilterParameters originalAudioSortFilterParameters,
}) {
  int length = deserializedAudioSortFilterParameters.selectedSortItemLst.length;

  expect(
    length == originalAudioSortFilterParameters.selectedSortItemLst.length,
    true,
  );

  for (int i = 0; i < length; i++) {
    compareDeserializedWithOriginalSortingItem(
      deserializedSortingItem:
          deserializedAudioSortFilterParameters.selectedSortItemLst[i],
      originalSortingItem:
          originalAudioSortFilterParameters.selectedSortItemLst[i],
    );
  }

  length = deserializedAudioSortFilterParameters.filterSentenceLst.length;

  expect(
    length == originalAudioSortFilterParameters.filterSentenceLst.length,
    true,
  );

  for (int i = 0; i < length; i++) {
    expect(
      deserializedAudioSortFilterParameters.filterSentenceLst[i] ==
          originalAudioSortFilterParameters.filterSentenceLst[i],
      true,
    );
  }

  expect(
    deserializedAudioSortFilterParameters.sentencesCombination,
    originalAudioSortFilterParameters.sentencesCombination,
  );

  expect(
    deserializedAudioSortFilterParameters.ignoreCase,
    originalAudioSortFilterParameters.ignoreCase,
  );

  expect(
    deserializedAudioSortFilterParameters.searchAsWellInVideoCompactDescription,
    originalAudioSortFilterParameters.searchAsWellInVideoCompactDescription,
  );

  expect(
    deserializedAudioSortFilterParameters.filterMusicQuality,
    originalAudioSortFilterParameters.filterMusicQuality,
  );

  expect(
    deserializedAudioSortFilterParameters.filterFullyListened,
    originalAudioSortFilterParameters.filterFullyListened,
  );

  expect(
    deserializedAudioSortFilterParameters.filterPartiallyListened,
    originalAudioSortFilterParameters.filterPartiallyListened,
  );

  expect(
    deserializedAudioSortFilterParameters.filterNotListened,
    originalAudioSortFilterParameters.filterNotListened,
  );

  expect(
    deserializedAudioSortFilterParameters.downloadDateStartRange,
    originalAudioSortFilterParameters.downloadDateStartRange,
  );

  expect(
    deserializedAudioSortFilterParameters.downloadDateEndRange,
    originalAudioSortFilterParameters.downloadDateEndRange,
  );

  expect(
    deserializedAudioSortFilterParameters.uploadDateStartRange,
    originalAudioSortFilterParameters.uploadDateStartRange,
  );
  expect(
    deserializedAudioSortFilterParameters.uploadDateEndRange,
    originalAudioSortFilterParameters.uploadDateEndRange,
  );

  expect(
    deserializedAudioSortFilterParameters.fileSizeStartRangeMB,
    originalAudioSortFilterParameters.fileSizeStartRangeMB,
  );

  expect(
    deserializedAudioSortFilterParameters.fileSizeEndRangeMB,
    originalAudioSortFilterParameters.fileSizeEndRangeMB,
  );

  expect(
    deserializedAudioSortFilterParameters.durationStartRangeSec,
    originalAudioSortFilterParameters.durationStartRangeSec,
  );

  expect(
    deserializedAudioSortFilterParameters.durationEndRangeSec,
    originalAudioSortFilterParameters.durationEndRangeSec,
  );
}
