import 'dart:io';

import '../services/sort_filter_parameters.dart';
import 'audio.dart';

enum PlaylistType { youtube, local }

enum PlaylistQuality { music, voice }

/// This class
class Playlist {
  String id = '';
  String title = '';
  String url;
  PlaylistType playlistType;
  PlaylistQuality playlistQuality;

  // If the audioPlaySpeed is 0, then the audio is played at the
  // application settings play speed.
  double audioPlaySpeed = 0;

  String downloadPath = '';
  bool isSelected;

  // Contains the audios once referenced in the Youtube playlist
  // which were downloaded.
  //
  // List order: [first downloaded audio, ..., last downloaded audio]
  List<Audio> downloadedAudioLst = [];

  // Contains the downloaded audios currently available on the
  // device.
  //
  // List order: [available audio last downloaded, ..., first
  //              available downloaded audio]
  List<Audio> playableAudioLst = [];

  // This variable contains the index of the audio in the
  // playableAudioLst which is currently playing. The effect is that
  // this value is the index of the audio that was the last played
  // audio from the playlist. This means that if the AudioPlayerView
  // is opened without having clicked on a playlist audio item, then
  // this audio will be playing. This happens only if the audio
  // playlist is selected in the PlaylistDownloadView, i.e. referenced
  // in the app settings.json file. The value -1 means that no
  // playlist audio has been played.
  int currentOrPastPlayableAudioIndex = -1;

  AudioSortFilterParameters? audioSortFilterParmsForPlaylistDownloadView;
  bool applyAutomaticallySortFilterParmsForPlaylistDownloadView = false;
  AudioSortFilterParameters? audioSortFilterParmsForAudioPlayerView;
  bool applyAutomaticallySortFilterParmsForAudioPlayerView = false;

  Playlist({
    this.url = '',
    this.id = '',
    this.title = '',
    required this.playlistType,
    required this.playlistQuality,
    this.isSelected = false,
  });

  /// This constructor requires all instance variables
  Playlist.fullConstructor({
    required this.id,
    required this.title,
    required this.url,
    required this.playlistType,
    required this.playlistQuality,
    required this.audioPlaySpeed,
    required this.downloadPath,
    required this.isSelected,
    required this.currentOrPastPlayableAudioIndex,
    required this.audioSortFilterParmsForPlaylistDownloadView,
    required this.applyAutomaticallySortFilterParmsForPlaylistDownloadView,
    required this.audioSortFilterParmsForAudioPlayerView,
    required this.applyAutomaticallySortFilterParmsForAudioPlayerView,
  });

  /// Factory constructor: creates an instance of Playlist from a
  /// JSON object
  factory Playlist.fromJson(Map<String, dynamic> json) {
    Playlist playlist = Playlist.fullConstructor(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      playlistType: PlaylistType.values.firstWhere(
        (e) => e.toString().split('.').last == json['playlistType'],
        orElse: () => PlaylistType.youtube,
      ),
      playlistQuality: PlaylistQuality.values.firstWhere(
        (e) => e.toString().split('.').last == json['playlistQuality'],
        orElse: () => PlaylistQuality.voice,
      ),
      audioPlaySpeed: json['audioPlaySpeed'] ?? 0,
      downloadPath: json['downloadPath'],
      isSelected: json['isSelected'],
      currentOrPastPlayableAudioIndex:
          json['currentOrPastPlayableAudioIndex'] ?? -1,
      audioSortFilterParmsForPlaylistDownloadView:
          (json['audioSortFilterParmsPlaylistDownloadView'] != null)
              ? AudioSortFilterParameters.fromJson(
                  json['audioSortFilterParmsPlaylistDownloadView'])
              : null,
      applyAutomaticallySortFilterParmsForPlaylistDownloadView:
          json['applySortFilterParmsForPlaylistDownloadView'] ?? false,
      audioSortFilterParmsForAudioPlayerView:
          (json['audioSortFilterParamAudioPlayerView'] != null)
              ? AudioSortFilterParameters.fromJson(
                  json['audioSortFilterParamAudioPlayerView'])
              : null,
      applyAutomaticallySortFilterParmsForAudioPlayerView:
          json['applySortFilterParmsForAudioPlayerView'] ?? false,
    );

    // Deserialize the Audio instances in the
    // downloadedAudioLst
    if (json['downloadedAudioLst'] != null) {
      for (var audioJson in json['downloadedAudioLst']) {
        Audio audio = Audio.fromJson(audioJson);
        audio.enclosingPlaylist = playlist;
        playlist.downloadedAudioLst.add(audio);
      }
    }

    playlist.applyAutomaticallySortFilterParmsForPlaylistDownloadView =
        json['applySortFilterParmsForPlaylistDownloadView'] ?? false;

    // Deserialize the Audio instances in the
    // playableAudioLst
    if (json['playableAudioLst'] != null) {
      for (var audioJson in json['playableAudioLst']) {
        Audio audio = Audio.fromJson(audioJson);
        audio.enclosingPlaylist = playlist;
        playlist.playableAudioLst.add(audio);
      }
    }

    playlist.applyAutomaticallySortFilterParmsForAudioPlayerView =
        json['applySortFilterParmsForAudioPlayerView'] ?? false;

    return playlist;
  }

  // Method: converts an instance of Playlist to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'playlistType': playlistType.toString().split('.').last,
      'playlistQuality': playlistQuality.toString().split('.').last,
      'audioPlaySpeed': audioPlaySpeed,
      'downloadPath': downloadPath,
      'downloadedAudioLst':
          downloadedAudioLst.map((audio) => audio.toJson()).toList(),
      'playableAudioLst':
          playableAudioLst.map((audio) => audio.toJson()).toList(),
      'isSelected': isSelected,
      'currentOrPastPlayableAudioIndex': currentOrPastPlayableAudioIndex,
      'audioSortFilterParmsPlaylistDownloadView':
          audioSortFilterParmsForPlaylistDownloadView?.toJson(),
      'applySortFilterParmsForPlaylistDownloadView':
          applyAutomaticallySortFilterParmsForPlaylistDownloadView,
      'audioSortFilterParamAudioPlayerView':
          audioSortFilterParmsForAudioPlayerView?.toJson(),
      'applySortFilterParmsForAudioPlayerView':
          applyAutomaticallySortFilterParmsForAudioPlayerView,
    };
  }

  /// Adds the downloaded audio to the downloadedAudioLst and to
  /// the playableAudioLst.
  ///
  /// downloadedAudioLst order: [first downloaded audio, ...,
  ///                            last downloaded audio]
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  void addDownloadedAudio(Audio downloadedAudio) {
    downloadedAudio.enclosingPlaylist = this;
    downloadedAudioLst.add(downloadedAudio);
    _insertAudioInPlayableAudioList(downloadedAudio);
  }

  /// Adds the copied audio to the playableAudioLst. The audio
  /// mp3 file was copied to the download path of this playlist
  /// by the AudioDownloadVM.
  ///
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  void addCopiedAudio({
    required Audio copiedAudio,
    required String copiedFromPlaylistTitle,
  }) {
    // Creating a copy of the audio to be copied so that the
    // original audio will not be modified by this method.
    Audio copiedAudioCopy = copiedAudio.copy();

    Audio? existingPlayableAudio;

    try {
      existingPlayableAudio = downloadedAudioLst.firstWhere(
        (audio) => audio == copiedAudio,
      );
    } catch (e) {
      existingPlayableAudio = null;
    }

    if (existingPlayableAudio != null) {
      // the case if the audio was deleted from this playlist and
      // then copied to this playlist.
      playableAudioLst.remove(copiedAudio);
    }

    copiedAudioCopy.enclosingPlaylist = this;
    copiedAudioCopy.copiedFromPlaylistTitle = copiedFromPlaylistTitle;

    _insertAudioInPlayableAudioList(copiedAudioCopy);
  }

  /// This method fixes a bug which caused the currently playing
  /// audio to be modified when a new audio was added to the
  /// playlist. The bug was caused by the fact that the
  /// currentOrPastPlayableAudioIndex was not incremented when
  /// adding a new audio to the playlist.
  void _insertAudioInPlayableAudioList(Audio insertedAudio) {
    playableAudioLst.insert(0, insertedAudio);

    // since the inserted audio is inserted into the
    // playableAudioLst, the currentOrPastPlayableAudioIndex
    // must be incremented by 1 so that the currently playing
    // audio is not modified.
    currentOrPastPlayableAudioIndex++;
  }

  /// Adds the moved audio to the downloadedAudioLst and to the
  /// playableAudioLst. Adding the audio to the downloadedAudioLst
  /// is necessary even if the audio was not downloaded from this
  /// playlist so that if the audio is then moved to another
  /// playlist, the moving action will not fail since moving is
  /// done from the downloadedAudioLst.
  ///
  /// Before, sets the enclosingPlaylist to this as well as the
  /// movedFromPlaylistTitle.
  void addMovedAudio({
    required Audio movedAudio,
    required String movedFromPlaylistTitle,
  }) {
    Audio movedAudioCopy = movedAudio.copy();
    Audio? existingDownloadedAudio;

    try {
      existingDownloadedAudio = downloadedAudioLst.firstWhere(
        (audio) => audio == movedAudio,
      );
    } catch (e) {
      existingDownloadedAudio = null;
    }

    movedAudioCopy.enclosingPlaylist = this;
    movedAudioCopy.movedFromPlaylistTitle = movedFromPlaylistTitle;

    if (existingDownloadedAudio != null) {
      // the case if the audio was moved to this playlist a first
      // time and then moved back to the source playlist or moved
      // to another playlist and then moved back to this playlist.
      Audio existingDownloadedAudioCopy = existingDownloadedAudio.copy();

      // Step 1: Update the movedToPlaylistTitle in the movedAudioCopy

      existingDownloadedAudioCopy.movedFromPlaylistTitle =
          movedFromPlaylistTitle;
      existingDownloadedAudioCopy.movedToPlaylistTitle = title;
      existingDownloadedAudioCopy.enclosingPlaylist = this;

      // Step 2: Find the index of the audio in downloadedAudioLst that
      // matches movedAudio
      int index = downloadedAudioLst.indexWhere((audio) => audio == movedAudio);

      // Step 3: Replace the audio at the found index in
      // downloadedAudioLst with the updated movedAudioCopy
      if (index != -1) {
        downloadedAudioLst[index] = existingDownloadedAudioCopy;
      }

      _insertAudioInPlayableAudioList(existingDownloadedAudioCopy);
    } else {
      downloadedAudioLst.add(movedAudioCopy);
      _insertAudioInPlayableAudioList(movedAudioCopy);
    }
  }

  /// Removes the downloaded audio from the downloadedAudioLst
  /// and from the playableAudioLst.
  ///
  /// This is used when the downloaded audio is moved to another
  /// playlist and is not kept in downloadedAudioLst of the source
  /// playlist. In this case, the user is advised to remove the
  /// corresponding video from the playlist on Youtube.
  void removeDownloadedAudioFromDownloadAndPlayableAudioLst({
    required Audio downloadedAudio,
  }) {
    // removes from the list all audios with the same audioFileName
    downloadedAudioLst.removeWhere((Audio audio) => audio == downloadedAudio);

    _removeAudioFromPlayableAudioList(downloadedAudio);
  }

  /// Removes the removedAudio from the playableAudioLst and
  /// updates the currentOrPastPlayableAudioIndex so that the
  /// current playable audio in the AudioPlayerView is set to
  /// the next listenable audio.
  ///
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  void _removeAudioFromPlayableAudioList(Audio removedAudio) {
    int playableAudioIndex = playableAudioLst.indexOf(removedAudio);

    if (playableAudioIndex <= currentOrPastPlayableAudioIndex) {
      currentOrPastPlayableAudioIndex--;
    }

    playableAudioLst.removeAt(playableAudioIndex);
  }

  /// Removes the downloaded audio from the playableAudioLst only.
  ///
  /// This is used when the downloaded audio is moved to another
  /// playlist and is kept in downloadedAudioLst of the source
  /// playlist so that it will not be downloaded again.
  void removeDownloadedAudioFromPlayableAudioLstOnly({
    required Audio downloadedAudio,
  }) {
    _removeAudioFromPlayableAudioList(downloadedAudio);
  }

  /// In this method, a copy of the passed audio is created so that the
  /// passed original audio will not be modified by this method.
  void setMovedAudioToPlaylistTitle({
    required Audio movedAudio,
    required String movedToPlaylistTitle,
  }) {
    // Step 0: Make a copy of the movedAudio in order to
    // avoid modifying the passed audio.
    Audio movedAudioCopy = movedAudio.copy();

    // Step 1: Update the movedToPlaylistTitle in the movedAudioCopy
    movedAudioCopy.movedToPlaylistTitle = movedToPlaylistTitle;

    // Step 2: Find the index of the audio in downloadedAudioLst that
    // matches movedAudio
    int index = downloadedAudioLst.indexWhere((audio) => audio == movedAudio);

    // Step 3: Replace the audio at the found index in
    // downloadedAudioLst with the updated movedAudioCopy
    if (index != -1) {
      downloadedAudioLst[index] = movedAudioCopy;
    }
  }

  void setCopiedAudioToPlaylistTitle({
    required Audio copiedAudio,
    required String copiedToPlaylistTitle,
  }) {
    // Step 0: Make a copy of the copiedAudio in order to
    // avoid modifying the passed audio.
    Audio copiedAudioCopy = copiedAudio.copy();

    // Step 1: Update the copiedToPlaylistTitle in the copiedAudioCopy
    copiedAudioCopy.copiedToPlaylistTitle = copiedToPlaylistTitle;

    // Step 2: Find the index of the audio in playableAudioLst that matches copiedAudio
    int index = playableAudioLst.indexWhere((audio) => audio == copiedAudio);

    // Step 3: Replace the audio at the found index in
    // playableAudioLst with the updated copiedAudioCopy
    if (index != -1) {
      playableAudioLst[index] = copiedAudioCopy;
    }
  }

  /// Used when uploading the Playlist json file. Since the
  /// json file contains the playable audio list in the right
  /// order, i.e. [available audio last downloaded, ..., first
  ///              available downloaded audio]
  /// using add and not insert maintains the right order !
  void addPlayableAudio(Audio playableAudio) {
    playableAudio.enclosingPlaylist = this;
    playableAudioLst.add(playableAudio);
  }

  /// Method called when physically deleting the audio file
  /// from the device.
  void removePlayableAudio({
    required Audio playableAudio,
  }) {
    _removeAudioFromPlayableAudioList(playableAudio);
  }

  @override
  String toString() {
    return '$title isSelected: $isSelected';
  }

  String getPlaylistDownloadFilePathName() {
    return '$downloadPath${Platform.pathSeparator}$title.json';
  }

  DateTime? getLastDownloadDateTime() {
    Audio? lastDownloadedAudio =
        downloadedAudioLst.isNotEmpty ? downloadedAudioLst.last : null;

    return (lastDownloadedAudio != null)
        ? lastDownloadedAudio.audioDownloadDateTime
        : null;
  }

  Duration getPlayableAudioLstTotalDuration() {
    Duration totalDuration = Duration.zero;

    for (Audio audio in playableAudioLst) {
      totalDuration += audio.audioDuration ?? Duration.zero;
    }

    return totalDuration;
  }

  int getPlayableAudioLstTotalFileSize() {
    int totalFileSize = 0;

    for (Audio audio in playableAudioLst) {
      totalFileSize += audio.audioFileSize;
    }

    return totalFileSize;
  }

  /// Removes from the playableAudioLst the audios that are no longer
  /// in the playlist download path.
  ///
  /// Returns the number of audios removed from the playable audio
  /// list.
  ///
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  int updatePlayableAudioLst() {
    int removedPlayableAudioNumber = 0;

    // since we are removing items from the list, we need to make a
    // copy of the list because we cannot iterate over a list that
    // is being modified.
    List<Audio> copyAudioLst = List<Audio>.from(playableAudioLst);

    for (Audio audio in copyAudioLst) {
      if (!File(audio.filePathName).existsSync()) {
        playableAudioLst.remove(audio);
        removedPlayableAudioNumber++;
      }
    }

    return removedPlayableAudioNumber;
  }

  void renameDownloadedAndPlayableAudioFile({
    required String oldFileName,
    required String newFileName,
  }) {
    Audio? existingDownloadedAudio;

    try {
      existingDownloadedAudio = downloadedAudioLst.firstWhere(
        (audio) => audio.audioFileName == oldFileName,
      );
    } catch (e) {
      existingDownloadedAudio = null;
    }

    if (existingDownloadedAudio != null) {
      existingDownloadedAudio.audioFileName = newFileName;
    }

    Audio? existingPlayableAudio;

    try {
      existingPlayableAudio = playableAudioLst.firstWhere(
        (audio) => audio.audioFileName == oldFileName,
      );
    } catch (e) {
      existingPlayableAudio = null;
    }

    if (existingPlayableAudio != null) {
      existingPlayableAudio.audioFileName = newFileName;
    }
  }

  void setCurrentOrPastPlayableAudio(Audio audio) {
    currentOrPastPlayableAudioIndex = playableAudioLst
        .indexWhere((item) => item == audio); // using Audio == operator
  }

  /// Returns the currently playing audio or the playlist audio
  /// which was played the last time. If no valid audio index is
  /// found, returns null.
  Audio? getCurrentOrLastlyPlayedAudioContainedInPlayableAudioLst() {
    if (currentOrPastPlayableAudioIndex == -1) {
      return null;
    }

    return playableAudioLst[currentOrPastPlayableAudioIndex];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Playlist && other.id == id;
  }

  void setAudioPlaySpeedToAllPlayableAudios({
    required double audioPlaySpeed,
  }) {
    for (Audio audio in playableAudioLst) {
      audio.audioPlaySpeed = audioPlaySpeed;
    }
  }
}
