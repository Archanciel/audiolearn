import 'dart:async';
import 'dart:io';

// importing youtube_explode_dart as yt enables to name the app Model
// playlist class as Playlist so it does not conflict with
// youtube_explode_dart Playlist class name.
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/settings_data_service.dart';
import '../utils/dir_util.dart';
import 'warning_message_vm.dart';

class SingleVideoAudioDownloadVM extends ChangeNotifier {
  final yt.YoutubeExplode _youtubeExplode;

  final SettingsDataService settingsDataService;

  /// When unit testing SingleVideoAudioDownloadVM,
  /// a CustomMockYoutubeExplode instance is passed
  /// to the constructor instead of a yt.YoutubeExplode
  /// instance.
  SingleVideoAudioDownloadVM({
    required yt.YoutubeExplode youtubeExplode,
    required this.settingsDataService,
  }) : _youtubeExplode = youtubeExplode;

  Future<bool> downloadSingleVideoAudio({
    required String videoUrl,
    required Playlist singleVideoTargetPlaylist,
  }) async {
    final yt.VideoId videoId;

    try {
      videoId = yt.VideoId(videoUrl);
    } on SocketException catch (e) {
      notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorArgOne: e.toString(),
      );

      return false;
    } catch (_) {
      return false;
    }

    yt.Video youtubeVideo;

    try {
      youtubeVideo = await _youtubeExplode.videos.get(videoId);
    } on SocketException catch (e) {
      notifyDownloadError(
        errorType: ErrorType.noInternet,
        errorArgOne: e.toString(),
      );

      return false;
    } catch (e) {
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      return false;
    }

    final Duration? audioDuration = youtubeVideo.duration;
    DateTime? videoUploadDate = youtubeVideo.uploadDate;

    videoUploadDate ??= DateTime(00, 1, 1);

    final Audio audio = Audio(
      enclosingPlaylist: singleVideoTargetPlaylist,
      originalVideoTitle: youtubeVideo.title,
      compactVideoDescription: youtubeVideo.description,
      videoUrl: youtubeVideo.url,
      audioDownloadDateTime: DateTime.now(),
      videoUploadDate: videoUploadDate,
      audioDuration: audioDuration!,
      audioPlaySpeed: settingsDataService.get(
        settingType: SettingType.playlists,
        settingSubType: Playlists.playSpeed,
      ),
    );

    final List<String> downloadedAudioFileNameLst = DirUtil.listFileNamesInDir(
      path: singleVideoTargetPlaylist.downloadPath,
      extension: 'mp3',
    );

    try {
      String existingAudioFileName = downloadedAudioFileNameLst
          .firstWhere((fileName) => fileName.contains(audio.validVideoTitle));
      notifyDownloadError(
        errorType: ErrorType.downloadAudioFileAlreadyOnAudioDirectory,
        errorArgOne: audio.validVideoTitle,
        errorArgTwo: existingAudioFileName,
        errorArgThree: singleVideoTargetPlaylist.title,
      );

      return false;
    } catch (_) {
      // file was not found in the downloaded audio directory
    }

    try {
      await _downloadAudioFile(
        youtubeVideoId: youtubeVideo.id,
        audio: audio,
      );
    } catch (e) {
      _youtubeExplode.close();
      notifyDownloadError(
        errorType: ErrorType.downloadAudioYoutubeError,
        errorArgOne: e.toString(),
      );

      return false;
    }

    _youtubeExplode.close();

    singleVideoTargetPlaylist.addDownloadedAudio(audio);

    notifyListeners();

    return true;
  }

  notifyDownloadError({
    required ErrorType errorType,
    String? errorArgOne,
    String? errorArgTwo,
    String? errorArgThree,
  }) {
    print(
        '\n********* errorType: $errorType\n********* errorArgOne: $errorArgOne\n********* errorArgTwo: $errorArgTwo\n********* errorArgThree: $errorArgThree');

    notifyListeners();
  }

  Future<void> _downloadAudioFile({
    required yt.VideoId youtubeVideoId,
    required Audio audio,
  }) async {
    final yt.StreamManifest streamManifest;

    try {
      streamManifest = await _youtubeExplode.videos.streamsClient.getManifest(
        youtubeVideoId,
      );
    } catch (e) {
      return;
    }

    final yt.AudioOnlyStreamInfo audioStreamInfo =
        streamManifest.audioOnly.first;
    final int audioFileSize = audioStreamInfo.size.totalBytes;

    audio.audioFileSize = audioFileSize;

    await _youtubeDownloadAudioFile(
      audio,
      audioStreamInfo,
      audioFileSize,
    );
  }

  Future<void> _youtubeDownloadAudioFile(
    Audio audio,
    yt.AudioOnlyStreamInfo audioStreamInfo,
    int audioFileSize,
  ) async {
    final File file = File(audio.filePathName);
    final IOSink audioFileSink = file.openWrite();
    final Stream<List<int>> audioStream =
        _youtubeExplode.videos.streamsClient.get(audioStreamInfo);

    await for (var byteChunk in audioStream) {
      audioFileSink.add(byteChunk);
    }

    await audioFileSink.flush();
    await audioFileSink.close();
  }
}
