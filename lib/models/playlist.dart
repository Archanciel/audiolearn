import 'dart:io';

import 'audio.dart';

enum PlaylistType {
  youtube,
  local,
}

enum PlaylistQuality {
  music,
  voice,
}

enum AudioPlayingOrder {
  ascending, // in the audio playable list dialog, last to first with ^ button
  descending, // in the audio playable list dialog, first to last
}

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

  // Contains the audio once referenced in the Youtube playlist
  // which were downloaded.
  //
  // List order: [first downloaded audio, ..., last downloaded audio]
  List<Audio> downloadedAudioLst = [];

  // Contains the downloaded audio currently available on the
  // device.
  //
  // List order: [available audio last downloaded, ..., first
  //              available downloaded audio]
  List<Audio> playableAudioLst = [];

  // This variable contains the index of the audio in the
  // playableAudioLst which is currently playing. The effect is that
  // this value indicates the index of the audio that was the last played
  // audio from the playlist. This means that if the AudioPlayerView
  // is opened without having clicked on a playlist audio item, then
  // this audio will be playable. This happens only if the audio
  // playlist is selected in the PlaylistDownloadView, i.e. referenced
  // in the app settings.json file. The value -1 means that no
  // playlist audio has been played.
  int currentOrPastPlayableAudioIndex = -1;

  // A sort filter parameters instance can be associated to a playlist
  // in order to sort and filter its audio.
  //
  // 1. Selecting or defining a named sort filter parameters instance
  //    in the SortFilterParametersView and then associating this
  //    named instance to the playlist. In this case, the named
  //    instance is stored in the app settings.json file, not in the
  //    playlist json file.

  String audioSortFilterParmsNameForPlaylistDownloadView = '';
  String audioSortFilterParmsNameForAudioPlayerView = '';

  AudioPlayingOrder audioPlayingOrder = AudioPlayingOrder.ascending;

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
    required this.audioSortFilterParmsNameForPlaylistDownloadView,
    required this.audioSortFilterParmsNameForAudioPlayerView,
    required this.audioPlayingOrder,
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
      audioSortFilterParmsNameForPlaylistDownloadView:
          json['audioSortFilterParmsNamePlaylistDownloadView'] ?? '',
      audioSortFilterParmsNameForAudioPlayerView:
          json['audioSortFilterParmsNameAudioPlayerView'] ?? '',
      audioPlayingOrder: AudioPlayingOrder.values.firstWhere(
        (e) => e.toString().split('.').last == json['audioPlayingOrder'],
        orElse: () => AudioPlayingOrder.ascending,
      ),
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

    // Deserialize the Audio instances in the
    // playableAudioLst
    if (json['playableAudioLst'] != null) {
      for (var audioJson in json['playableAudioLst']) {
        Audio audio = Audio.fromJson(audioJson);
        audio.enclosingPlaylist = playlist;
        playlist.playableAudioLst.add(audio);
      }
    }

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
      'audioSortFilterParmsNamePlaylistDownloadView':
          audioSortFilterParmsNameForPlaylistDownloadView,
      'audioSortFilterParmsNameAudioPlayerView':
          audioSortFilterParmsNameForAudioPlayerView,
      'audioPlayingOrder': audioPlayingOrder.toString().split('.').last,
    };
  }

  Playlist copy() {
    return Playlist.fullConstructor(
      id: id,
      title: title,
      url: url,
      playlistType: playlistType,
      playlistQuality: playlistQuality,
      audioPlaySpeed: audioPlaySpeed,
      downloadPath: downloadPath,
      isSelected: isSelected,
      currentOrPastPlayableAudioIndex: currentOrPastPlayableAudioIndex,
      audioSortFilterParmsNameForPlaylistDownloadView:
          audioSortFilterParmsNameForPlaylistDownloadView,
      audioSortFilterParmsNameForAudioPlayerView:
          audioSortFilterParmsNameForAudioPlayerView,
      audioPlayingOrder: audioPlayingOrder,
    )
      ..downloadedAudioLst =
          downloadedAudioLst.map((audio) => audio.copy()).toList()
      ..playableAudioLst =
          playableAudioLst.map((audio) => audio.copy()).toList();
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

  /// Adds the imported audio to the downloadedAudioLst and to
  /// the playableAudioLst. The imported audio is added to the
  /// lists only if it is not already in the lists.
  /// 
  /// The imported audio is in the downloadedAudioLst if it was
  /// previously imported or downloaded and was deleted (not
  /// deleted from playlist as well)).
  ///
  /// The imported audio is in the playableAudioLst if it was
  /// previously imported or downloaded and was only physically
  /// deleted (not deleted using one of the two audio item delete
  /// menu).
  ///
  /// downloadedAudioLst order: [first downloaded audio, ...,
  ///                            last downloaded audio]
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  void addImportedAudio(Audio importedAudio) {
    importedAudio.enclosingPlaylist = this;
    String importedAAudioTitle = importedAudio.validVideoTitle;

    if (!downloadedAudioLst
        .any((audio) => audio.validVideoTitle == importedAAudioTitle)) {
      downloadedAudioLst.add(importedAudio);
    }

    if (!playableAudioLst
        .any((audio) => audio.validVideoTitle == importedAAudioTitle)) {
      _insertAudioInPlayableAudioList(importedAudio);
    }
  }

  /// Adds the copied audio to the playableAudioLst. The audio
  /// mp3 file was copied to the download path of this playlist
  /// by the AudioDownloadVM.
  ///
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  void addCopiedAudioToDownloadAndPlayableLst({
    required Audio audioToCopy,
    required String copiedFromPlaylistTitle,
  }) {
    // Creating a copy of the audio to be copied so that the
    // original audio will not be modified by this method.
    Audio copiedAudioCopy = audioToCopy.copy();

    Audio? existingPlayableAudio;

    try {
      existingPlayableAudio = downloadedAudioLst.firstWhere(
        (audio) => audio == audioToCopy,
      );
    } catch (e) {
      existingPlayableAudio = null;
    }

    if (existingPlayableAudio != null) {
      // the case if the audio was deleted from this playlist and
      // then copied to this playlist.
      playableAudioLst.remove(audioToCopy);
    }

    copiedAudioCopy.enclosingPlaylist = this;
    copiedAudioCopy.copiedFromPlaylistTitle = copiedFromPlaylistTitle;
    copiedAudioCopy.audioPlaySpeed = audioPlaySpeed;

    downloadedAudioLst.add(copiedAudioCopy);
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
  void addMovedAudioToDownloadAndPlayableLst({
    required Audio movedAudio,
    required String movedFromPlaylistTitle,
  }) {
    Audio movedAudioCopy = movedAudio.copy();
    Audio? existingDownloadedAudio;

    try {
      existingDownloadedAudio = downloadedAudioLst.firstWhere(
        //        This is the old version of the audio == operator
        (audio) => audio.audioFileName == movedAudio.audioFileName,
      );
    } catch (e) {
      existingDownloadedAudio = null;
    }

    movedAudioCopy.enclosingPlaylist = this;
    movedAudioCopy.movedFromPlaylistTitle = movedFromPlaylistTitle;
    movedAudioCopy.audioPlaySpeed = audioPlaySpeed;

    if (existingDownloadedAudio != null) {
      // the case if the audio was moved to this playlist a first
      // time and then moved back to the source playlist or moved
      // to another playlist and then moved back to this playlist.
      Audio existingDownloadedAudioCopy = existingDownloadedAudio.copy();

      // Step 1: Update the movedToPlaylistTitle in the movedAudioCopy

      existingDownloadedAudioCopy.movedFromPlaylistTitle =
          movedFromPlaylistTitle;
      existingDownloadedAudioCopy.movedToPlaylistTitle = title; // this.title
      existingDownloadedAudioCopy.enclosingPlaylist = this;
      existingDownloadedAudioCopy.audioPlaySpeed =
          audioPlaySpeed; // this.audioPlaySpeed

      // Step 2: Find the index of the audio in downloadedAudioLst that
      // matches movedAudio
      //                                                   This is the old version of the audio == operator
      int index = downloadedAudioLst.indexWhere(
          (audio) => audio.audioFileName == movedAudio.audioFileName);

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
  void removeAudioFromDownloadAndPlayableAudioLst({
    required Audio downloadedAudio,
  }) {
    downloadedAudioLst.removeWhere((Audio audio) => audio == downloadedAudio);

    // Modifies as well the playlist currentOrPastPlayableAudioIndex
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

    // Step 4: Find the index of the audio in downloadedAudioLst that matches copiedAudio
    index = downloadedAudioLst.indexWhere((audio) => audio == copiedAudio);

    // Step 5: Replace the audio at the found index in
    // downloadedAudioLst with the updated copiedAudioCopy
    if (index != -1) {
      downloadedAudioLst[index] = copiedAudioCopy;
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

  /// Method called when physically deleting the audio file
  /// from the device.
  void removeAudioLstFromPlayableAudioLstOnly({
    required List<Audio> playableAudioToRemoveLst,
  }) {
    for (Audio playableAudio in playableAudioToRemoveLst) {
      _removeAudioFromPlayableAudioList(playableAudio);
    }
  }

  /// Method called when physically deleting the audio file
  /// from the device.
  void removeAudioLstFromDownloadedAndPlayableAudioLsts({
    required List<Audio> audioToRemoveLst,
  }) {
    for (Audio audioToRemove in audioToRemoveLst) {
      // removes from the list all audio with the same audioFileName
      downloadedAudioLst.removeWhere((Audio audio) => audio == audioToRemove);
      _removeAudioFromPlayableAudioList(audioToRemove);
    }
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
      totalDuration += audio.audioDuration;
    }

    return totalDuration;
  }

  Duration getPlayableAudioLstTotalRemainingDuration() {
    Duration totalRemainingDuration = Duration.zero;

    for (Audio audio in playableAudioLst) {
      totalRemainingDuration +=
          (audio.audioDuration - Duration(seconds: audio.audioPositionSeconds));
    }

    return totalRemainingDuration;
  }

  int getPlayableAudioLstTotalFileSize() {
    int totalFileSize = 0;

    for (Audio audio in playableAudioLst) {
      totalFileSize += audio.audioFileSize;
    }

    return totalFileSize;
  }

  /// Removes from the playableAudioLst the audio that are no longer
  /// in the playlist download path.
  ///
  /// Returns the number of audio removed from the playable audio
  /// list.
  ///
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  int updatePlayableAudioLst() {
    int removedPlayableAudioNumber = 0;
    int currentOrPastPlayableAudioIndexReduction = 0;

    // Since we are removing items from the list, we need to make a
    // copy of the list because we cannot iterate over a list that
    // is being modified.
    List<Audio> playableAudioLstCopy = List<Audio>.from(playableAudioLst);
    int playableAudioIndex = 0;

    for (Audio audio in playableAudioLstCopy) {
      if (!File(audio.filePathName).existsSync()) {
        playableAudioLst.remove(audio);
        removedPlayableAudioNumber++;
        if (playableAudioIndex <= currentOrPastPlayableAudioIndex) {
          // If the removed audio is before the current or past
          // playable audio or if the removed audio IS the current
          // or past playable audio, then the current or past playable
          // audio index reduction is improved by 1.
          currentOrPastPlayableAudioIndexReduction++;
        }
      }

      playableAudioIndex++;
    }

    // If no audio were removed from the playable audio list, then
    // the current or past playable audio index is not modified.
    //
    // If n audio located before ot at the current or past playable
    // audio index were removed from the playable audio list, then the
    // current or past playable audio index is reduced by n.
    //
    // If the removed audio were located after the current or past
    // playable audio index, then the current or past playable audio
    // index is not impacted.
    currentOrPastPlayableAudioIndex -= currentOrPastPlayableAudioIndexReduction;

    return removedPlayableAudioNumber;
  }

  /// Updates the audio file name of the Audio contained in the downloaded
  /// audio list and updates the audio file name of the Audio contained in
  /// the playable audio list.
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

  // The currentOrPastPlayableAudioIndex contains the index of the audio
  // in this playlist playableAudioList which is currently playing or was the
  // last playlist played audio. The utility is that if the AudioPlayerView
  // is opened without having clicked on a playlist audio item, then
  // this audio will be playable. This happens only if the audio playlist
  // is selected in the PlaylistDownloadView, i.e. referenced in the app
  // settings.json file. The value -1 means that up to now, no playlist audio
  // has been played.
  void setCurrentOrPastPlayableAudio({
    required Audio audio,
  }) {
    currentOrPastPlayableAudioIndex = playableAudioLst
        .indexWhere((item) => item == audio); // using Audio == operator
  }

  void updateCurrentOrPastPlayableAudio({
    required Audio audioCopy,
    required int previousAudioIndex,
  }) {
    int audioIndex = playableAudioLst.indexWhere((item) => item == audioCopy);

    // Only replace if the audio equal to the audioCopy exists in
    // the list
    if (audioIndex != -1) {
      playableAudioLst[audioIndex] = audioCopy;
    }

    currentOrPastPlayableAudioIndex = previousAudioIndex;
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

  /// Returns the audio contained in the playableAudioLst which
  /// has the same audioFileName as the passed audioFileName.
  ///
  /// File name example: "240528-130636-Interview de Chat GPT  -
  /// IA, intelligence, philosophie, géopolitique, post-vérité...
  /// 24-01-12"
  Audio? getAudioByFileNameNoExt({
    required String audioFileNameNoExt,
  }) {
    Audio? audio;

    try {
      audio = playableAudioLst.firstWhere(
        (audio) => audio.audioFileName == "$audioFileNameNoExt.mp3",
      );
    } catch (e) {
      audio = null;
    }

    return audio;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  void setAudioPlaySpeedToAllPlayableAudios({
    required double audioPlaySpeed,
  }) {
    for (Audio audio in playableAudioLst) {
      audio.audioPlaySpeed = audioPlaySpeed;
    }
  }

  /// This method is used in case where the Youtube playlist was deleted or
  /// renamed and then recreated with the same name. In this situation, the
  /// current playlist was created with the same title as the replaced playlist
  /// and a new url and Youtube playlist id.
  ///
  /// In this method, the data of the replaced playlist is integrated into the
  /// current playlist, which will then replace the replaced playlist in the
  /// AudioDownloadVM playlist list.
  ///
  /// Why did the user delete or rename a Yoiutube playlist and then recreate
  /// a Youtiube playlist with the same name ? The reason is that the Youtube
  /// playlist may contain too many videos. Removing manually the already
  /// listened videos from the Youtube playlist would take too much time.
  /// Instead, the too big Youtube playlist is deleted or is renamed and a new
  /// Youtube playlist with the same title is created. The new Youtube playlist
  /// is then added to the application, which in this case creates a new
  /// playlist and then integrates to it the data of the replaced playlist.
  void integrateReplacedPlaylistData({
    required Playlist replacedPlaylist,
  }) {
    downloadedAudioLst = replacedPlaylist.downloadedAudioLst;
    playableAudioLst = replacedPlaylist.playableAudioLst;
    playlistQuality = replacedPlaylist.playlistQuality;
    audioPlaySpeed = replacedPlaylist.audioPlaySpeed;
    isSelected = replacedPlaylist.isSelected;
    currentOrPastPlayableAudioIndex =
        replacedPlaylist.currentOrPastPlayableAudioIndex;
    audioSortFilterParmsNameForPlaylistDownloadView =
        replacedPlaylist.audioSortFilterParmsNameForPlaylistDownloadView;
    audioSortFilterParmsNameForAudioPlayerView =
        replacedPlaylist.audioSortFilterParmsNameForAudioPlayerView;
  }

  int rewindPlayableAudioToStart() {
    int rewindedAudioNumber = 0;

    for (Audio audio in playableAudioLst) {
      if (audio.audioPositionSeconds > 0 ||
          audio.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd) {
        audio.audioPositionSeconds = 0;
        audio.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd = false;
        rewindedAudioNumber++;
      }
    }

    return rewindedAudioNumber;
  }
}
