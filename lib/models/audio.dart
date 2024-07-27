// dart file located in lib\models

import 'dart:io';

import 'package:intl/intl.dart';

import '../constants.dart';
import 'playlist.dart';

/// Contains informations of the audio extracted from the video
/// referenced in the enclosing playlist. In fact, the audio is
/// directly downloaded from Youtube.
class Audio {
  static DateFormat downloadDatePrefixFormatter = DateFormat('yyMMdd');
  static DateFormat downloadDateTimePrefixFormatter =
      DateFormat('yyMMdd-HHmmss');
  static DateFormat uploadDateSuffixFormatter = DateFormat('yy-MM-dd');

  // Number of seconds to consider that the audio was fully listened:
  // If its current position is greater or equal to its total duration
  // minus fullyListenedBufferSeconds seconds, then the audio is considered
  // as being fully listened.
  static int fullyListenedBufferSeconds = 15;

  // Playlist in which the video is referenced
  Playlist? enclosingPlaylist;

  // Playlist from which the Audio was moved
  String? movedFromPlaylistTitle;

  // Playlist to which the Audio was moved
  String? movedToPlaylistTitle;

  // Playlist from which the Audio was copied
  String? copiedFromPlaylistTitle;

  // Playlist to which the Audio was copied
  String? copiedToPlaylistTitle;

  // Video title displayed on Youtube
  final String originalVideoTitle;

  // Video title which does not contain invalid characters which
  // would cause the audio file name to generate an file creation
  // exception
  String validVideoTitle;

  String compactVideoDescription;

  // Url referencing the video from which rhe audio was extracted
  final String videoUrl;

  // Audio download date time
  final DateTime audioDownloadDateTime;

  // Duration in which the audio was downloaded
  Duration? audioDownloadDuration;

  // Date at which the video containing the audio was added on
  // Youtube
  final DateTime videoUploadDate;

  // Stored audio file name
  String audioFileName;

  // Duration of downloaded audio
  final Duration? audioDuration;

  // Audio file size in bytes
  int audioFileSize = 0;
  set fileSize(int size) {
    audioFileSize = size;
    audioDownloadSpeed = (audioFileSize == 0 || audioDownloadDuration == null)
        ? 0
        : (audioFileSize / audioDownloadDuration!.inMicroseconds * 1000000)
            .round();
  }

  set downloadDuration(Duration downloadDuration) {
    audioDownloadDuration = downloadDuration;
    audioDownloadSpeed = (audioFileSize == 0 || audioDownloadDuration == null)
        ? 0
        : (audioFileSize / audioDownloadDuration!.inMicroseconds * 1000000)
            .round();
  }

  // Speed at which the audio was downloaded in bytes per second
  late int audioDownloadSpeed;

  // State of the audio

  // true if the audio is currently playing or if it is paused
  // with its position between 0 and its total duration.
  bool isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = false;
  int audioPositionSeconds = 0;

  bool isPaused = true;

  // Usefull in order to reduce the next play position according
  // to the value of the duration between the time the audio was
  // paused and the time the audio was played again.
  //
  // For example, if the audio was paused for less than 1 minute,
  // the next play position will be reduced by 2 seconds.
  // If the audio was paused for more than 1 minute and less than
  // 1 hour, the next play position will be reduced by 20 seconds.
  // If the audio was paused for more than 1 hour, the next play
  // position will be reduced by 30 seconds.
  DateTime? audioPausedDateTime;

  double audioPlaySpeed;
  double audioPlayVolume = kAudioDefaultPlayVolume;

  bool isAudioMusicQuality = false;

  // true if the audio file was imported from another directory
  bool isAudioImported = false;

  Audio({
    required this.enclosingPlaylist,
    required this.originalVideoTitle,
    required this.compactVideoDescription,
    required this.videoUrl,
    required this.audioDownloadDateTime,
    this.audioDownloadDuration,
    required this.videoUploadDate,
    this.audioDuration,
    required this.audioPlaySpeed,
  })  : validVideoTitle = createValidVideoTitle(originalVideoTitle),
        audioFileName =
            "${buildDownloadDatePrefix(audioDownloadDateTime)}${createValidVideoTitle(originalVideoTitle)} ${buildUploadDateSuffix(videoUploadDate)}.mp3";

  /// This constructor requires all instance variables. It is used
  /// by the fromJson factory constructor.
  Audio.fullConstructor({
    required this.enclosingPlaylist,
    required this.movedFromPlaylistTitle,
    required this.movedToPlaylistTitle,
    required this.copiedFromPlaylistTitle,
    required this.copiedToPlaylistTitle,
    required this.originalVideoTitle,
    required this.compactVideoDescription,
    required this.validVideoTitle,
    required this.videoUrl,
    required this.audioDownloadDateTime,
    required this.audioDownloadDuration,
    required this.audioDownloadSpeed,
    required this.videoUploadDate,
    required this.audioDuration,
    required this.isAudioMusicQuality,
    required this.audioPlaySpeed,
    required this.audioPlayVolume,
    required this.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd,
    required this.isPaused,
    required this.audioPausedDateTime,
    required this.audioPositionSeconds,
    required this.audioFileName,
    required this.audioFileSize,
    required this.isAudioImported,
  });

  /// Returns a copy of the current Audio instance
  Audio copy() {
    return Audio.fullConstructor(
      enclosingPlaylist: enclosingPlaylist,
      movedFromPlaylistTitle: movedFromPlaylistTitle,
      movedToPlaylistTitle: movedToPlaylistTitle,
      copiedFromPlaylistTitle: copiedFromPlaylistTitle,
      copiedToPlaylistTitle: copiedToPlaylistTitle,
      originalVideoTitle: originalVideoTitle,
      compactVideoDescription: compactVideoDescription,
      validVideoTitle: validVideoTitle,
      videoUrl: videoUrl,
      audioDownloadDateTime: audioDownloadDateTime,
      audioDownloadDuration: audioDownloadDuration,
      audioDownloadSpeed: audioDownloadSpeed,
      videoUploadDate: videoUploadDate,
      audioDuration: audioDuration,
      isAudioMusicQuality: isAudioMusicQuality,
      audioPlaySpeed: audioPlaySpeed,
      audioPlayVolume: audioPlayVolume,
      isPlayingOrPausedWithPositionBetweenAudioStartAndEnd:
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd,
      isPaused: isPaused,
      audioPausedDateTime: audioPausedDateTime,
      audioPositionSeconds: audioPositionSeconds,
      audioFileName: audioFileName,
      audioFileSize: audioFileSize,
      isAudioImported: isAudioImported,
    );
  }

  /// Factory constructor: creates an instance of Audio from a
  /// JSON object
  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio.fullConstructor(
      enclosingPlaylist:
          null, // the enclosing playlist is not stored in the Audio JSON
      // object. It is set when the Playlist is created from
      // the Playlist JSON file in the Playlist factory method
      // Playlist.fromJson(Map<String, dynamic> json).

      movedFromPlaylistTitle: json['movedFromPlaylistTitle'],
      movedToPlaylistTitle: json['movedToPlaylistTitle'],
      copiedFromPlaylistTitle: json['copiedFromPlaylistTitle'],
      copiedToPlaylistTitle: json['copiedToPlaylistTitle'],
      originalVideoTitle: json['originalVideoTitle'],
      compactVideoDescription: json['compactVideoDescription'] ?? '',
      validVideoTitle: json['validVideoTitle'],
      videoUrl: json['videoUrl'],
      audioDownloadDateTime: DateTime.parse(json['audioDownloadDateTime']),
      audioDownloadDuration:
          Duration(milliseconds: json['audioDownloadDurationMs']),
      audioDownloadSpeed: (json['audioDownloadSpeed'] < 0)
          ? double.infinity
          : json['audioDownloadSpeed'],
      videoUploadDate: DateTime.parse(json['videoUploadDate']),
      audioDuration: Duration(milliseconds: json['audioDurationMs'] ?? 0),
      isAudioMusicQuality: json['isAudioMusicQuality'] ?? false,
      audioPlaySpeed: json['audioPlaySpeed'] ?? kAudioDefaultPlaySpeed,
      audioPlayVolume: json['audioPlayVolume'] ?? kAudioDefaultPlayVolume,
      isPlayingOrPausedWithPositionBetweenAudioStartAndEnd:
          json['isPlayingOrPausedWithPositionBetweenAudioStartAndEnd'] ?? false,
      isPaused: json['isPaused'] ?? true,
      audioPausedDateTime: (json['audioPausedDateTime'] == null)
          ? null
          : DateTime.parse(json['audioPausedDateTime']),
      audioPositionSeconds: json['audioPositionSeconds'] ?? 0,
      audioFileName: json['audioFileName'],
      audioFileSize: json['audioFileSize'],
      isAudioImported: json['isAudioImported'] ?? false,
    );
  }

  // Method: converts an instance of Audio to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'movedFromPlaylistTitle': movedFromPlaylistTitle,
      'movedToPlaylistTitle': movedToPlaylistTitle,
      'copiedFromPlaylistTitle': copiedFromPlaylistTitle,
      'copiedToPlaylistTitle': copiedToPlaylistTitle,
      'originalVideoTitle': originalVideoTitle,
      'compactVideoDescription': compactVideoDescription,
      'validVideoTitle': validVideoTitle,
      'videoUrl': videoUrl,
      'audioDownloadDateTime': audioDownloadDateTime.toIso8601String(),
      'audioDownloadDurationMs': audioDownloadDuration?.inMilliseconds,
      'audioDownloadSpeed':
          (audioDownloadSpeed.isFinite) ? audioDownloadSpeed : -1.0,
      'videoUploadDate': videoUploadDate.toIso8601String(),
      'audioDurationMs': audioDuration?.inMilliseconds,
      'isAudioMusicQuality': isAudioMusicQuality,
      'audioPlaySpeed': audioPlaySpeed,
      'audioPlayVolume': audioPlayVolume,
      'isPlayingOrPausedWithPositionBetweenAudioStartAndEnd':
          isPlayingOrPausedWithPositionBetweenAudioStartAndEnd,
      'isPaused': isPaused,
      'audioPausedDateTime': (audioPausedDateTime == null)
          ? null
          : audioPausedDateTime!.toIso8601String(),
      'audioPositionSeconds': audioPositionSeconds,
      'audioFileName': audioFileName,
      'audioFileSize': audioFileSize,
      'isAudioImported': isAudioImported,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Audio && other.audioFileName == audioFileName;
  }

  @override
  int get hashCode => audioFileName.hashCode;

  String get filePathName {
    return '${enclosingPlaylist!.downloadPath}${Platform.pathSeparator}$audioFileName';
  }

  /// Returns true if the audio position is greater or equal to
  /// the audio duration minus 15 seconds.
  bool wasFullyListened() {
    return (audioDuration == null)
        ? false
        : (audioPositionSeconds >= audioDuration!.inSeconds - fullyListenedBufferSeconds);
  }

  bool isPartiallyListened() {
    return (audioPositionSeconds > 0) && !wasFullyListened();
  }

  static String buildDownloadDatePrefix(DateTime downloadDate) {
    String formattedDateStr = (kAudioFileNamePrefixIncludeTime)
        ? downloadDateTimePrefixFormatter.format(downloadDate)
        : downloadDatePrefixFormatter.format(downloadDate);

    return '$formattedDateStr-';
  }

  static String buildUploadDateSuffix(DateTime uploadDate) {
    String formattedDateStr = uploadDateSuffixFormatter.format(uploadDate);

    return formattedDateStr;
  }

  /// Removes illegal file name characters from the original
  /// video title aswell non-ascii characters. This causes
  /// the valid video title to be efficient when sorting
  /// the audio by their title.
  static String createValidVideoTitle(String originalVideoTitle) {
    // Replace '|' by ' if '|' is located at end of file name
    if (originalVideoTitle.endsWith('|')) {
      originalVideoTitle =
          originalVideoTitle.substring(0, originalVideoTitle.length - 1);
    }

    // Replace '||' by '_' since YoutubeDL replaces '||' by '_'
    originalVideoTitle = originalVideoTitle.replaceAll('||', '|');

    // Replace '//' by '_' since YoutubeDL replaces '//' by '_'
    originalVideoTitle = originalVideoTitle.replaceAll('//', '/');

    final charToReplace = {
      '\\': '',
      '/': '_', // since YoutubeDL replaces '/' by '_'
      ':': ' -', // since YoutubeDL replaces ':' by ' -'
      '*': ' ',
      // '.': '', point is not illegal in file name
      '?': '',
      '"': "'", // since YoutubeDL replaces " by '
      '<': '',
      '>': '',
      '|': '_', // since YoutubeDL replaces '|' by '_'
      // "'": '_', apostrophe is not illegal in file name
    };

    // Replace unauthorized characters
    originalVideoTitle = originalVideoTitle.replaceAllMapped(
        RegExp(r'[\\/:*?"<>|]'),
        (match) => charToReplace[match.group(0)] ?? '');

    // Replace 'œ' with 'oe'
    originalVideoTitle = originalVideoTitle.replaceAll(RegExp(r'[œ]'), 'oe');

    // Replace 'Œ' with 'OE'
    originalVideoTitle = originalVideoTitle.replaceAll(RegExp(r'[Œ]'), 'OE');

    // Remove any non-English or non-French characters
    originalVideoTitle =
        originalVideoTitle.replaceAll(RegExp(r'[^\x00-\x7FÀ-ÿ‘’]'), '');

    return originalVideoTitle.trim();
  }

  @override
  String toString() {
    return 'Audio: $validVideoTitle';
  }

  void setAudioToMusicQuality() {
    isAudioMusicQuality = true;
    audioPlaySpeed = 1.0;
  }
}
