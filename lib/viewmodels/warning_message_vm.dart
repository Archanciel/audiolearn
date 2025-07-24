import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/playlist.dart';
import '../utils/dir_util.dart';
import '../views/widgets/set_value_to_target_dialog.dart';

enum WarningMessageType {
  none,
  errorMessage, // An error message depending on error type is
  // displayed.

  updatedPlaylistUrlTitle, // This means that the playlist
  // was not added, but that its url was updated. The case
  // when a new Voutube playlist with the identical title was
  // created in order to replace the old one which contained
  // too many videos.

  addPlaylistTitle, // The playlist with this title is added
  // to the application.

  privatePlaylistAddition, // A private Youtube playlist is
  // added to the application. Such playlist can not be
  // downloaded

  invalidValueWarning, // The value entered in the SetValueToTargetDialog
  // text field is invalid.

  invalidPlaylistUrl, // The case if the url is a video url and the
  // user clicked on the Add button instead of the Download
  // button or if the String pasted to the url text field
  // is not a valid Youtube playlist url.

  invalidLocalPlaylistTitle, // The case if local playlist title
  // contains one or more commas.

  invalidYoutubePlaylistTitle, // The case if Youtube playlist title
  // contains one or more commas.

  renameFileNameInvalid, // The case if the file name proposed
  // for renaming an audio file has not .mp3 extension.

  confirmYoutubeChannelModifications, // The case if the user
  // selected the app 'Youtube channel setting' menu item.

  correctedYoutubePlaylistTitle, // The case if the user
  // added a Youtube playlist whose title contains one or several
  // invalid characters, '/' for example.

  renameFileNameAlreadyUsed, // The case if the file name proposed
  // for renaming an audio file is the name of an existing
  // file.

  renameCommentFileNameAlreadyUsed, // The case if the comment file
  // name proposed for renaming a comment file is the name of an existing
  // file.

  renameAudioFileConfirm, // The case if an audio file was renamed.

  renameAudioAndCommentFileConfirm, // The case if both audio and comment
  // files were renamed.

  addRemoveSortFilterParmsToPlaylistConfirm, // The case if the a sort/filter
  // parms was added or removed from a playlist.

  playlistWithUrlAlreadyInListOfPlaylists, // User clicked on Add
  // button but the playlist with this url was already downloaded.

  localPlaylistWithTitleAlreadyInListOfPlaylists, // User clicked on
  // Add button but the local playlist with this title was already
  // created.

  youtubePlaylistWithTitleAlreadyInListOfPlaylists, // User clicked on
  // Add button but a Youtube playlist with a title equal to the title
  // of the new local playlist already exits.

  deleteAudioFromPlaylistAswellWarning, // User selected the audio
  // menu item "Delete audio from playlist aswell".

  invalidSingleVideoUrl, // The case if the url is a playlist url
  // and the Download button was clicked instead of the Add button,
  // or if the String pasted to the url text field is not a valid
  // Youtube video url.

  updatedPlayableAudioLst, // The case if the playable audio list
  // was updated. This happens when the user clicks on the update
  // playable audio list playlist menu item.

  confirmMovedUnmovedAudioNumber, // The case if the user clicked on
  // Move Filtered Audio to Playlist ... menu item

  notApplyingDefaultSFparmsToMoveWarning, // The case if the user clicked on
  // Move Filtered Audio to Playlist ... menu item with the default sort/filter
  // parameters selected.

  notApplyingDefaultSFparmsToCopyWarning, // The case if the user clicked on
  // Move Filtered Audio to Playlist ... menu item with the default sort/filter
  // parameters selected.

  confirmCopiedNotCopiedAudioNumber, // The case if the user clicked on
  // Copy Filtered Audio to Playlist ... menu item

  rewindedPlayableAudioToStart, // The case if the playable audio's
  // were rewinded to start position. This happens when the user clicks
  // on the Rewind Audio to Start playlist menu item.

  redownloadedAudioNumbersConfirmation, // The case if the sort
  // filtered deleted audio's were redownloaded. This happens when
  // the user clicks on the playlist submenu 'Redownload filtered
  // Audio's'.

  redownloadingAudioConfirmationOrWarning, // The case if the deleted
  // audio was redownloaded or if the deleted audio was not redownloaded
  // since it is already present in the target playlist directory. This
  // happens when the user clicks on the audio list item or audio player
  // viewn left appbar 'Redownload deleted Audio' menu.

  notRedownloadAudioFilesInPlaylistDirectory, // The case if the
  // audio files in the playlist directory were not redownloaded
  // since they are already in the target playlist directory.

  noSortFilterSaveAsName, // The case if the user clicks on the
  // save as button after selecting the sort and filter options
  // but the name of the new sort and filter is empty.

  noSortFilterParameterWasModified, // The case if the user clicks
  // on the apply button without having set a sort/filter
  // parameter.

  deletedHistoricalSortFilterParameterNotExist, // The case if the user clicks
  // on the delete button after having set a sort/filter parameter
  // which does not exist in the sort/filter parameter history.

  historicalSortFilterParameterWasDeleted, // The case if the user clicks
  // on the delete button after having selected an historical sort/filter
  // parameter which does  exist in the sort/filter parameter history.

  noCheckboxSelected, // The case if the user clicks
  // on the ok button of the SetValueToTargetDialog without
  // having selected at least one checkbox.

  playlistRootPathNotExist, // The case if the user enters a playlist
  // root path which does not exist in the application settings dialog

  noPlaylistSelectedForSingleVideoDownload, // The case if the user
  // clicks on the single video download button but no playlist
  // to which the downloaded audio will be added is selected.

  isNoPlaylistSelectedForAudioCopy, // The case if the user
  // clicks on the single video download button but no playlist
  // to which the downloaded audio will be copied is selected.

  isNoPlaylistSelectedForAudioMove, // The case if the user
  // clicks on the single video download button but no playlist
  // to which the downloaded audio will be moved is selected.

  tooManyPlaylistSelectedForSingleVideoDownload, // The case if the
  // user clicks on the single video download button but more than
  // one playlist to which the downloaded audio will be added is
  // selected.

  ok, // The case if the user clicks on the Ok button after a
  // confirmation message is displayed.

  confirmSingleVideoDownload, // The case if the user clicks on the
  // single video download button after selecting a target playlist.

  audioCopiedOrMovedFromPlaylistToPlaylist, // The case if the user clicks
  // on the copy/move audio to playlist menu item.

  savedUniquePlaylistOrAllPlaylistsAndAppDataToZip, // The case if the user
  // clicks on the 'Save Playlists, Comments and Pictures to Zip File' menu
  // item located in the appbar leading popup menu or on the 'Save Playlist,
  // Comments and Pictures to Zip File' menu item located in the playlist
  // popup menu.

  savedUniquePlaylistOrAllPlaylistsAudioMp3ToZip, // The case if the user
  // clicks on the 'Save Playlists Audio MP3 to Zip File' menu
  // item located in the appbar leading popup menu or on the 'Save Playlist
  // Audio MP3 to Zip File' menu item located in the playlist popup menu.

  restoreAppDataFromZip, // The case if the user clicks on the
  // 'Restore Playlist, Comments and Settings from Zip File' menu
  // item located in the appbar leading popup menu.

  audioNotImportedToPlaylist, // The case if the user clicks on
  // the import audio to playlist menu item and the audio was not
  // imported to the target playlist since the target playlist
  // already contains the audio

  audioImportedToPlaylist, // The case if the user clicks on
  // the import audio to playlist menu item and the audio was
  // imported to the target playlist

  videoTitleNotWrittenInOccidentalLetters, // The case if the video
  // title is not written in occidental letters.
}

enum ErrorType {
  noError,

  downloadAudioYoutubeError, // In case of a Youtube error.

  downloadAudioYoutubeErrorDueToLiveVideoInPlaylist, // In case of a
  // Youtube error caused by the fact that the playlist contains a
  // live video.

  downloadAudioFileAlreadyOnAudioDirectory, // In case the audio file
  // is already on the audio directory and will not be redownloaded.

  noInternet, // device not connected. Happens when trying to
  // download a playlist or a single video or to add a new playlist
  // or update an existing playlist.

  errorInPlaylistJsonFile, // Error in the playlist json file.

  dateFormatError, // Error in the date format.
}

/// This VM (View Model) class is part of the MVVM architecture.
///
class WarningMessageVM extends ChangeNotifier {
  WarningMessageType warningMessageType = WarningMessageType.none;

  // The next two variables are used to handle the display of multiple
  // warnings. The _warningElementsQueue is a queue of warningElements
  // for a multiple warning to be displayed.
  // The _isDisplaying variable is used to determine if a message is
  // currently being displayed.
  final Queue<String> _warningMessageElementsQueue = Queue<String>();
  bool _isDisplaying = false;

  String _errorArgOne = '';
  String get errorArgOne => _errorArgOne;
  String _errorArgTwo = '';
  String get errorArgTwo => _errorArgTwo;
  String _errorArgThree = '';
  String get errorArgThree => _errorArgThree;

  ErrorType _errorType = ErrorType.noError;
  ErrorType get errorType => _errorType;
  void setError({
    required ErrorType errorType,
    String? errorArgOne,
    String? errorArgTwo,
    String? errorArgThree,
  }) {
    _errorType = errorType;

    if (errorType != ErrorType.noError) {
      warningMessageType = WarningMessageType.errorMessage;

      if (errorArgOne != null) {
        _errorArgOne = errorArgOne;
      }

      if (errorArgTwo != null) {
        _errorArgTwo = errorArgTwo;
      }

      if (errorArgThree != null) {
        _errorArgThree = errorArgThree;
      }

      // Causes the display warning message widget to be displayed.
      notifyListeners();
    } else {
      _errorArgOne = '';
    }
  }

  /// Adds a warning message elements string to the queue of warning message
  /// elements to be displayed.
  ///
  /// Example of {warningMessageElements}:
  ///
  /// For a warning message indicating that 2 audio files were not imported
  /// due to the fact that they already exist in the target playlist,
  /// this warning is displayed:
  ///
  /// Audio(s) "audio1, audio2" not imported to
  /// Youtube playlist "S8 audio" since the playlist directory already
  /// contains the audio(s).
  ///
  /// In this example, the {warningMessageElements} value is "audio1, audio2".
  void _addWarningMessageElements({
    required String warningMessageElements,
  }) {
    _warningMessageElementsQueue.add(warningMessageElements);
    if (!_isDisplaying) {
      _isDisplaying = true;
      _displayNextMessage();
    }
  }

  /// Called when the user clicks on the Ok button of the warning message.
  /// This method is used to display the next warning message if there are
  /// multiple warning messages to be displayed.
  void warningFromMultipleWarningsWasDisplayed() {
    _displayNextMessage();
  }

  void _displayNextMessage() {
    if (_warningMessageElementsQueue.isNotEmpty) {
      notifyListeners(); // Causes the display warning message widget to be
      //                    informed that a next warning is displayable.
    } else {
      _isDisplaying = false;
    }
  }

  /// Return the warning message elements string of the next warning to be
  /// displayed.
  ///
  /// Example of {warningMessageElements}:
  ///
  /// For a warning message indicating that 2 audio files were not imported
  /// due to the fact that they already exist in the target playlist,
  /// this warning is displayed:
  ///
  /// Audio(s) "audio1, audio2" not imported to
  /// Youtube playlist "S8 audio" since the playlist directory already
  /// contains the audio(s).
  ///
  /// In this example, the {warningMessageElements} value is "audio1, audio2".
  String getNextWarningMessageElements() {
    return _warningMessageElementsQueue.isNotEmpty
        ? _warningMessageElementsQueue.removeFirst()
        : '';
  }

  String _updatedPlaylistTitle = '';
  String get updatedPlaylistTitle => _updatedPlaylistTitle;
  set updatedPlaylistTitle(String updatedPlaylistTitle) {
    _updatedPlaylistTitle = updatedPlaylistTitle;

    if (updatedPlaylistTitle.isNotEmpty) {
      warningMessageType = WarningMessageType.updatedPlaylistUrlTitle;

      // Causes the display warning message widget to be displayed.
      notifyListeners();
    }
  }

  String _addedPlaylistTitle = '';
  String get addedPlaylistTitle => _addedPlaylistTitle;

  PlaylistQuality _addedPlaylistQuality = PlaylistQuality.voice;
  PlaylistQuality get addedPlaylistQuality => _addedPlaylistQuality;

  late PlaylistType _addedPlaylistType;
  PlaylistType get addedPlaylistType => _addedPlaylistType;

  void annoncePlaylistAddition({
    required String playlistTitle,
    required PlaylistQuality playlistQuality,
    required PlaylistType playlistType,
  }) {
    _addedPlaylistTitle = playlistTitle;
    _addedPlaylistQuality = playlistQuality;
    _addedPlaylistType = playlistType;

    if (playlistTitle.isNotEmpty) {
      warningMessageType = WarningMessageType.addPlaylistTitle;

      // Causes the display warning message widget to be displayed.
      notifyListeners();
    }
  }

  void signalPrivatePlaylistAddition() {
    warningMessageType = WarningMessageType.privatePlaylistAddition;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  InvalidValueState _invalidValueState = InvalidValueState.tooBig;
  InvalidValueState get invalidValueState => _invalidValueState;

  String _valueLimitStr = '';
  String get valueLimitStr => _valueLimitStr;

  void setInvalidValueWarning({
    required InvalidValueState invalidValueState,
    required String maxOrMinValueLimitStr,
  }) {
    _invalidValueState = invalidValueState;
    _valueLimitStr = maxOrMinValueLimitStr;

    if (invalidValueState != InvalidValueState.none) {
      warningMessageType = WarningMessageType.invalidValueWarning;

      // Causes the display warning message widget to be displayed.
      notifyListeners();
    }
  }

  bool _addAtListToWarningMessage = false;
  bool get addAtListToWarningMessage => _addAtListToWarningMessage;

  void setNoCheckboxSelected({
    required bool addAtListToWarningMessage,
  }) {
    _addAtListToWarningMessage = addAtListToWarningMessage;
    warningMessageType = WarningMessageType.noCheckboxSelected;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _invalidPlaylistUrl = '';
  String get invalidPlaylistUrl => _invalidPlaylistUrl;
  set invalidPlaylistUrl(String invalidPlaylistUrl) {
    _invalidPlaylistUrl = invalidPlaylistUrl;
    warningMessageType = WarningMessageType.invalidPlaylistUrl;

    // Causes the display warning message widget to be displayed.      // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _invalidLocalPlaylistTitle = '';
  String get invalidLocalPlaylistTitle => _invalidLocalPlaylistTitle;
  set invalidLocalPlaylistTitle(String invalidLocalPlaylistTitle) {
    _invalidLocalPlaylistTitle = invalidLocalPlaylistTitle;
    warningMessageType = WarningMessageType.invalidLocalPlaylistTitle;

    // Causes the display warning message widget to be displayed.      // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _invalidYoutubePlaylistTitle = '';
  String get invalidYoutubePlaylistTitle => _invalidYoutubePlaylistTitle;
  set invalidYoutubePlaylistTitle(String invalidYoutubePlaylistTitle) {
    _invalidYoutubePlaylistTitle = invalidYoutubePlaylistTitle;
    warningMessageType = WarningMessageType.invalidYoutubePlaylistTitle;

    // Causes the display warning message widget to be displayed.      // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _originalPlaylistTitle = '';
  String get originalPlaylistTitle => _originalPlaylistTitle;
  String _correctedPlaylistTitle = '';
  String get correctedPlaylistTitle => _correctedPlaylistTitle;

  void signalCorrectedYoutubePlaylistTitle({
    required String originalPlaylistTitle,
    required PlaylistQuality playlistQuality,
    required String correctedPlaylistTitle,
  }) {
    _originalPlaylistTitle = originalPlaylistTitle;
    _addedPlaylistQuality = playlistQuality;
    _correctedPlaylistTitle = correctedPlaylistTitle;

    warningMessageType = WarningMessageType.correctedYoutubePlaylistTitle;

    // Causes the display warning message widget to be displayed.      // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  int _numberOfModifiedDownloadedAudio = 0;
  int get numberOfModifiedDownloadedAudio => _numberOfModifiedDownloadedAudio;
  int _numberOfModifiedPlayableAudio = 0;
  int get numberOfModifiedPlayableAudio => _numberOfModifiedPlayableAudio;

  void confirmYoutubeChannelModifications({
    required int numberOfModifiedDownloadedAudio,
    required int numberOfModifiedPlayableAudio,
  }) {
    _numberOfModifiedDownloadedAudio = numberOfModifiedDownloadedAudio;
    _numberOfModifiedPlayableAudio = numberOfModifiedPlayableAudio;

    warningMessageType = WarningMessageType.confirmYoutubeChannelModifications;

    // Causes the display warning message widget to be displayed.      // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _renameFileNameInvalid = '';
  String get renameFileNameInvalid => _renameFileNameInvalid;

  void renameFileNameIsInvalid({
    required String invalidRenameFileName,
  }) {
    _renameFileNameInvalid = invalidRenameFileName;
    warningMessageType = WarningMessageType.renameFileNameInvalid;

    // Causes the display warning message widget to be displayed.      // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _renameFileNameAlreadyUsed = '';
  String get renameFileNameAlreadyUsed => _renameFileNameAlreadyUsed;

  void renameFileNameIsAlreadyUsed({
    required String invalidRenameFileName,
  }) {
    _renameFileNameAlreadyUsed = invalidRenameFileName;
    warningMessageType = WarningMessageType.renameFileNameAlreadyUsed;

    // Causes the display warning message widget to be displayed.      // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _renameCommentFileNameAlreadyUsed = '';
  String get renameCommentFileNameAlreadyUsed =>
      _renameCommentFileNameAlreadyUsed;

  void renameCommentFileNameIsAlreadyUsed({
    required String invalidRenameFileName,
  }) {
    _renameCommentFileNameAlreadyUsed = invalidRenameFileName;
    warningMessageType = WarningMessageType.renameCommentFileNameAlreadyUsed;

    // Causes the display warning message widget to be displayed.      // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _oldFileName = '';
  String get oldFileName => _oldFileName;
  String _newFileName = '';
  String get newFileName => _newFileName;

  void confirmRenameAudioFile({
    required String oldFileName,
    required String newFileName,
  }) {
    _oldFileName = oldFileName;
    _newFileName = newFileName;
    warningMessageType = WarningMessageType.renameAudioFileConfirm;

    // Causes the display warning message widget to be displayed.      // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  void confirmRenameAudioAndCommentFile({
    required String oldFileName,
    required String newFileName,
  }) {
    _oldFileName = oldFileName;
    _newFileName = newFileName;
    warningMessageType = WarningMessageType.renameAudioAndCommentFileConfirm;

    // Causes the display warning message widget to be displayed.      // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _playlistTitle = '';
  String get playlistTitle => _playlistTitle;
  String _sortFilterParmsName = '';
  String get sortFilterParmsName => _sortFilterParmsName;
  bool _isSaveApplied = false;
  bool get isSaveApplied => _isSaveApplied;
  bool _forPlaylistDownloadView = false;
  bool get forPlaylistDownloadView => _forPlaylistDownloadView;
  bool _forAudioPlayerView = false;
  bool get forAudioPlayerView => _forAudioPlayerView;

  void confirmAddRemoveSortFilterParmsToPlaylist({
    required String playlistTitle,
    required String sortFilterParmsName,
    required bool isSaveApplied,
    required bool forPlaylistDownloadView,
    required bool forAudioPlayerView,
  }) {
    _playlistTitle = playlistTitle;
    _sortFilterParmsName = sortFilterParmsName;
    _isSaveApplied = isSaveApplied;
    _forPlaylistDownloadView = forPlaylistDownloadView;
    _forAudioPlayerView = forAudioPlayerView;
    warningMessageType =
        WarningMessageType.addRemoveSortFilterParmsToPlaylistConfirm;

    // Causes the display warning message widget to be displayed.      // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  bool _isSingleVideoUrlInvalid = false;
  bool get isSingleVideoUrlInvalid => _isSingleVideoUrlInvalid;
  set isSingleVideoUrlInvalid(bool isSingleVideoUrlInvalid) {
    _isSingleVideoUrlInvalid = isSingleVideoUrlInvalid;

    if (isSingleVideoUrlInvalid) {
      warningMessageType = WarningMessageType.invalidSingleVideoUrl;

      // Causes the display warning message widget to be displayed.
      notifyListeners();
    }
  }

  String _playlistAlreadyDownloadedTitle = '';
  String get playlistAlreadyDownloadedTitle => _playlistAlreadyDownloadedTitle;
  void setPlaylistAlreadyDownloadedTitle({
    required String playlistTitle,
  }) {
    _playlistAlreadyDownloadedTitle = playlistTitle;

    warningMessageType =
        WarningMessageType.playlistWithUrlAlreadyInListOfPlaylists;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _localPlaylistAlreadyCreatedTitle = '';
  String get localPlaylistAlreadyCreatedTitle =>
      _localPlaylistAlreadyCreatedTitle;
  void setLocalPlaylistAlreadyCreatedTitle({
    required String playlistTitle,
    required PlaylistType playlistType,
  }) {
    _localPlaylistAlreadyCreatedTitle = playlistTitle;

    if (playlistType == PlaylistType.local) {
      warningMessageType =
          WarningMessageType.localPlaylistWithTitleAlreadyInListOfPlaylists;
    } else {
      warningMessageType =
          WarningMessageType.youtubePlaylistWithTitleAlreadyInListOfPlaylists;
    }

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _sortFilterSaveAsName = '';
  String get sortFilterSaveAsName => _sortFilterSaveAsName;
  set sortFilterSaveAsName(String sortFilterSaveAsName) {
    _sortFilterSaveAsName = sortFilterSaveAsName;

    if (sortFilterSaveAsName.isEmpty) {
      warningMessageType = WarningMessageType.noSortFilterSaveAsName;

      // Causes the display warning message widget to be displayed.
      notifyListeners();
    }
  }

  void noSortFilterParameterWasModified() {
    warningMessageType = WarningMessageType.noSortFilterParameterWasModified;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  void deletedHistoricalSortFilterParameterNotExist() {
    warningMessageType =
        WarningMessageType.deletedHistoricalSortFilterParameterNotExist;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  void historicalSortFilterParameterWasDeleted() {
    warningMessageType =
        WarningMessageType.historicalSortFilterParameterWasDeleted;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  void playlistRootPathNotExist() {
    warningMessageType = WarningMessageType.playlistRootPathNotExist;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  void isNoPlaylistSelectedForSingleVideoDownload() {
    warningMessageType =
        WarningMessageType.noPlaylistSelectedForSingleVideoDownload;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  void videoTitleNotWrittenInOccidentalLetters() {
    warningMessageType =
        WarningMessageType.videoTitleNotWrittenInOccidentalLetters;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  void isNoPlaylistSelectedForAudioCopy() {
    warningMessageType = WarningMessageType.isNoPlaylistSelectedForAudioCopy;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  void isNoPlaylistSelectedForAudioMove() {
    warningMessageType = WarningMessageType.isNoPlaylistSelectedForAudioMove;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  bool _isTooManyPlaylistSelectedForSingleVideoDownload = false;
  bool get isTooManyPlaylistSelectedForSingleVideoDownload =>
      _isTooManyPlaylistSelectedForSingleVideoDownload;
  set isTooManyPlaylistSelectedForSingleVideoDownload(
      bool isTooManyPlaylistSelectedForSingleVideoDownload) {
    _isTooManyPlaylistSelectedForSingleVideoDownload =
        isTooManyPlaylistSelectedForSingleVideoDownload;

    if (isTooManyPlaylistSelectedForSingleVideoDownload) {
      warningMessageType =
          WarningMessageType.tooManyPlaylistSelectedForSingleVideoDownload;

      // Causes the display warning message widget to be displayed.
      notifyListeners();
    }
  }

  String _deleteAudioFromPlaylistAswellAudioVideoTitle = '';
  String get deleteAudioFromPlaylistAswellAudioVideoTitle =>
      _deleteAudioFromPlaylistAswellAudioVideoTitle;
  String _deleteAudioFromPlaylistAswellTitle = '';
  String get deleteAudioFromPlaylistAswellTitle =>
      _deleteAudioFromPlaylistAswellTitle;
  void setDeleteAudioFromPlaylistAswellTitle({
    required String deleteAudioFromPlaylistAswellTitle,
    required String deleteAudioFromPlaylistAswellAudioVideoTitle,
  }) {
    _deleteAudioFromPlaylistAswellTitle = deleteAudioFromPlaylistAswellTitle;
    _deleteAudioFromPlaylistAswellAudioVideoTitle =
        deleteAudioFromPlaylistAswellAudioVideoTitle;

    if (deleteAudioFromPlaylistAswellTitle.isNotEmpty) {
      warningMessageType =
          WarningMessageType.deleteAudioFromPlaylistAswellWarning;

      // Causes the display warning message widget to be displayed.
      notifyListeners();
    }
  }

  String _audioValidVideoTitle = '';
  String get audioValidVideoTitle => _audioValidVideoTitle;
  bool _wasOperationSuccessful = true;
  bool get wasOperationSuccessful => _wasOperationSuccessful;
  bool _isAudioCopied = true; // if false, the audio was moved
  bool get isAudioCopied => _isAudioCopied;
  String _fromPlaylistTitle = '';
  String get fromPlaylistTitle => _fromPlaylistTitle;
  String _toPlaylistTitle = '';
  String get toPlaylistTitle => _toPlaylistTitle;
  late PlaylistType _fromPlaylistType;
  PlaylistType get fromPlaylistType => _fromPlaylistType;
  late PlaylistType _toPlaylistType;
  PlaylistType get toPlaylistType => _toPlaylistType;
  late CopyOrMoveFileResult _copyOrMoveFileResult =
      CopyOrMoveFileResult.sourceFileNotExist;
  CopyOrMoveFileResult get copyOrMoveFileResult => _copyOrMoveFileResult;
  void audioCopiedOrMovedFromToPlaylist({
    required String audioValidVideoTitle,
    required bool wasOperationSuccessful,
    required bool isAudioCopied, // if false, the audio was moved
    required PlaylistType fromPlaylistType,
    required String fromPlaylistTitle,
    required PlaylistType toPlaylistType,
    required String toPlaylistTitle,
    required CopyOrMoveFileResult copyOrMoveFileResult,
  }) {
    _audioValidVideoTitle = audioValidVideoTitle;
    _wasOperationSuccessful = wasOperationSuccessful;
    _isAudioCopied = isAudioCopied;
    _fromPlaylistTitle = fromPlaylistTitle;
    _fromPlaylistType = fromPlaylistType;
    _toPlaylistTitle = toPlaylistTitle;
    _toPlaylistType = toPlaylistType;
    _copyOrMoveFileResult = copyOrMoveFileResult;

    warningMessageType =
        WarningMessageType.audioCopiedOrMovedFromPlaylistToPlaylist;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _zipFilePathName = '';
  String get zipFilePathName => _zipFilePathName;
  int _savedOrRestoredPictureJpgNumber = 0;
  int get savedOrRestoredPictureJpgNumber => _savedOrRestoredPictureJpgNumber;
  bool _uniquePlaylistIsSaved = false;
  bool get uniquePlaylistIsSaved => _uniquePlaylistIsSaved;
  void confirmSavingToZip({
    required String zipFilePathName,
    required int savedPictureNumber,
    bool uniquePlaylistIsSaved = false,
  }) {
    _zipFilePathName = zipFilePathName;
    _savedOrRestoredPictureJpgNumber = savedPictureNumber;
    _uniquePlaylistIsSaved = uniquePlaylistIsSaved;

    warningMessageType =
        WarningMessageType.savedUniquePlaylistOrAllPlaylistsAndAppDataToZip;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _fromAudioDownloadDateTime = '';
  String get fromAudioDownloadDateTime => _fromAudioDownloadDateTime;
  int _savedAudioMp3Number = 0;
  int get savedAudioMp3Number => _savedAudioMp3Number;
  int _savedTotalAudioFileSize = 0;
  int get savedTotalAudioFileSize => _savedTotalAudioFileSize;
  late Duration _savedTotalAudioDuration;
  Duration get savedTotalAudioDuration => _savedTotalAudioDuration;
  late Duration _savingAudioToZipOperationDuration;
  Duration get savingAudioToZipOperationDuration =>
      _savingAudioToZipOperationDuration;
  int _realNumberOfBytesSavedToZipPerSecond = 0;
  int get realNumberOfBytesSavedToZipPerSecond =>
      _realNumberOfBytesSavedToZipPerSecond;
  void confirmSavingAudioMp3ToZip({
    required String zipFilePathName,
    required String fromAudioDownloadDateTime,
    required int savedAudioMp3Number,
    required int savedTotalAudioFileSize,
    required Duration savedTotalAudioDuration,
    required Duration savingAudioToZipOperationDuration,
    required int realNumberOfBytesSavedToZipPerSecond,
    required bool uniquePlaylistIsSaved,
  }) {
    _zipFilePathName = zipFilePathName;
    _fromAudioDownloadDateTime = fromAudioDownloadDateTime;
    _savedAudioMp3Number = savedAudioMp3Number;
    _savedTotalAudioFileSize = savedTotalAudioFileSize;
    _savedTotalAudioDuration = savedTotalAudioDuration;  
    _uniquePlaylistIsSaved = uniquePlaylistIsSaved;
    _savingAudioToZipOperationDuration = savingAudioToZipOperationDuration;
    _realNumberOfBytesSavedToZipPerSecond = realNumberOfBytesSavedToZipPerSecond;

    warningMessageType =
        WarningMessageType.savedUniquePlaylistOrAllPlaylistsAudioMp3ToZip;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  int _playlistsNumber = 0;
  int get playlistsNumber => _playlistsNumber;
  int _audioReferencesNumber = 0;
  int get audioReferencesNumber => _audioReferencesNumber;
  int _commentJsonFilesNumber = 0;
  int get commentJsonFilesNumber => _commentJsonFilesNumber;
  int _updatedCommentNumber = 0;
  int get updatedCommentNumber => _updatedCommentNumber;
  int _addedCommentNumber = 0;
  int get addedCommentNumber => _addedCommentNumber;
  int _pictureJsonFilesNumber = 0;
  int get pictureJsonFilesNumber => _pictureJsonFilesNumber;
  bool _wasIndividualPlaylistRestored = false;
  bool get wasIndividualPlaylistRestored => _wasIndividualPlaylistRestored;
  void confirmRestorationFromZip({
    required String zipFilePathName,
    required int playlistsNumber,
    required int audioReferencesNumber,
    required int commentJsonFilesNumber,
    required int updatedCommentNumber,
    required int addedCommentNumber,
    required int pictureJsonFilesNumber,
    required int pictureJpgFilesNumber,
    required bool wasIndividualPlaylistRestored,
  }) {
    _zipFilePathName = zipFilePathName;
    _playlistsNumber = playlistsNumber;
    _audioReferencesNumber = audioReferencesNumber;
    _commentJsonFilesNumber = commentJsonFilesNumber;
    _updatedCommentNumber = updatedCommentNumber;
    _pictureJsonFilesNumber = pictureJsonFilesNumber;
    _savedOrRestoredPictureJpgNumber = pictureJpgFilesNumber;
    _wasIndividualPlaylistRestored = wasIndividualPlaylistRestored;
    _addedCommentNumber = addedCommentNumber;

    warningMessageType = WarningMessageType.restoreAppDataFromZip;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _rejectedImportedAudioFileNames = '';
  String get rejectedImportedAudioFileNames => _rejectedImportedAudioFileNames;
  String _importedToPlaylistTitle = '';
  String get importedToPlaylistTitle => _importedToPlaylistTitle;
  late PlaylistType _importedToPlaylistType;
  PlaylistType get importedToPlaylistType => _importedToPlaylistType;
  void setAudioNotImportedToPlaylistTitles({
    required String rejectedImportedAudioFileNames,
    required String importedToPlaylistTitle,
    required PlaylistType importedToPlaylistType,
  }) {
    _isDisplaying = false; // Reset the display state for the next warning.
    _rejectedImportedAudioFileNames = rejectedImportedAudioFileNames;
    _importedToPlaylistTitle = importedToPlaylistTitle;
    _importedToPlaylistType = importedToPlaylistType;

    warningMessageType = WarningMessageType.audioNotImportedToPlaylist;

    _addWarningMessageElements(
      warningMessageElements: _rejectedImportedAudioFileNames,
    );
  }

  String _importedAudioFileNames = '';
  String get importedAudioFileNames => _importedAudioFileNames;
  void setAudioImportedToPlaylistTitles({
    required String importedAudioFileNames,
    required String importedToPlaylistTitle,
    required PlaylistType importedToPlaylistType,
  }) {
    _isDisplaying = false; // Reset the display state for the next warning.
    _importedAudioFileNames = importedAudioFileNames;
    _importedToPlaylistTitle = importedToPlaylistTitle;
    _importedToPlaylistType = importedToPlaylistType;

    warningMessageType = WarningMessageType.audioImportedToPlaylist;

    _addWarningMessageElements(
      warningMessageElements: _importedAudioFileNames,
    );
  }

  String _updatedPlayableAudioLstPlaylistTitle = '';
  String get updatedPlayableAudioLstPlaylistTitle =>
      _updatedPlayableAudioLstPlaylistTitle;
  int _removedPlayableAudioNumber = 0;
  int get removedPlayableAudioNumber => _removedPlayableAudioNumber;
  void setUpdatedPlayableAudioLstPlaylistTitle({
    required String updatedPlayableAudioLstPlaylistTitle,
    required int removedPlayableAudioNumber,
  }) {
    _updatedPlayableAudioLstPlaylistTitle =
        updatedPlayableAudioLstPlaylistTitle;
    _removedPlayableAudioNumber = removedPlayableAudioNumber;

    if (removedPlayableAudioNumber > 0) {
      warningMessageType = WarningMessageType.updatedPlayableAudioLst;

      // Causes the display warning message widget to be displayed.
      notifyListeners();
    }
  }

  String _audioMoveSourcePlaylistTitle = '';
  String get audioMoveSourcePlaylistTitle => _audioMoveSourcePlaylistTitle;
  late PlaylistType _movedFromSourcePlaylistType;
  PlaylistType get movedFromSourcePlaylistType => _movedFromSourcePlaylistType;
  String _audioMoveTargetPlaylistTitle = '';
  String get audioMoveTargetPlaylistTitle => _audioMoveTargetPlaylistTitle;
  late PlaylistType _movedToTargetPlaylistType;
  PlaylistType get movedToTargetPlaylistType => _movedToTargetPlaylistType;
  String _appliedToMoveSortFilterParmsName = '';
  String get appliedToMoveSortFilterParmsName =>
      _appliedToMoveSortFilterParmsName;
  int _movedAudioNumber = 0;
  int get movedAudioNumber => _movedAudioNumber;
  int _movedCommentedAudioNumber = 0;
  int get movedCommentedAudioNumber => _movedCommentedAudioNumber;
  int _unmovedAudioNumber = 0;
  int get unmovedAudioNumber => _unmovedAudioNumber;
  void confirmMovedUnmovedAudioNumber({
    required String sourcePlaylistTitle,
    required PlaylistType sourcePlaylistType,
    required String targetPlaylistTitle,
    required PlaylistType targetPlaylistType,
    required String appliedSortFilterParmsName,
    required int movedAudioNumber,
    required int movedCommentedAudioNumber,
    required int unmovedAudioNumber,
  }) {
    _audioMoveSourcePlaylistTitle = sourcePlaylistTitle;
    _movedFromSourcePlaylistType = sourcePlaylistType;
    _audioMoveTargetPlaylistTitle = targetPlaylistTitle;
    _movedToTargetPlaylistType = targetPlaylistType;
    _appliedToMoveSortFilterParmsName = appliedSortFilterParmsName;
    _movedAudioNumber = movedAudioNumber;
    _movedCommentedAudioNumber = movedCommentedAudioNumber;
    _unmovedAudioNumber = unmovedAudioNumber;

    warningMessageType = WarningMessageType.confirmMovedUnmovedAudioNumber;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  void displayNotApplyingDefaultSFparmsToMoveWarning({
    required String sourcePlaylistTitle,
    required PlaylistType sourcePlaylistType,
    required String targetPlaylistTitle,
    required PlaylistType targetPlaylistType,
    required String appliedSortFilterParmsName,
  }) {
    _audioMoveSourcePlaylistTitle = sourcePlaylistTitle;
    _movedFromSourcePlaylistType = sourcePlaylistType;
    _audioMoveTargetPlaylistTitle = targetPlaylistTitle;
    _movedToTargetPlaylistType = targetPlaylistType;
    _appliedToMoveSortFilterParmsName = appliedSortFilterParmsName;

    warningMessageType =
        WarningMessageType.notApplyingDefaultSFparmsToMoveWarning;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  void displayNotApplyingDefaultSFparmsToCopyWarning({
    required String sourcePlaylistTitle,
    required PlaylistType sourcePlaylistType,
    required String targetPlaylistTitle,
    required PlaylistType targetPlaylistType,
    required String appliedSortFilterParmsName,
  }) {
    _audioCopySourcePlaylistTitle = sourcePlaylistTitle;
    _copiedFromSourcePlaylistType = sourcePlaylistType;
    _audioCopyTargetPlaylistTitle = targetPlaylistTitle;
    _copiedToTargetPlaylistType = targetPlaylistType;
    _appliedToCopySortFilterParmsName = appliedSortFilterParmsName;

    warningMessageType =
        WarningMessageType.notApplyingDefaultSFparmsToCopyWarning;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _audioCopySourcePlaylistTitle = '';
  String get audioCopySourcePlaylistTitle => _audioCopySourcePlaylistTitle;
  late PlaylistType _copiedFromSourcePlaylistType;
  PlaylistType get copiedFromSourcePlaylistType =>
      _copiedFromSourcePlaylistType;
  String _audioCopyTargetPlaylistTitle = '';
  String get audioCopyTargetPlaylistTitle => _audioCopyTargetPlaylistTitle;
  late PlaylistType _copiedToTargetPlaylistType;
  PlaylistType get copiedToTargetPlaylistType => _copiedToTargetPlaylistType;
  String _appliedToCopySortFilterParmsName = '';
  String get appliedToCopySortFilterParmsName =>
      _appliedToCopySortFilterParmsName;
  int _copiedAudioNumber = 0;
  int get copiedAudioNumber => _copiedAudioNumber;
  int _copiedCommentedAudioNumber = 0;
  int get copiedCommentedAudioNumber => _copiedCommentedAudioNumber;
  int _notCopiedAudioNumber = 0;
  int get notCopiedAudioNumber => _notCopiedAudioNumber;
  void confirmCopiedNotCopiedAudioNumber({
    required String sourcePlaylistTitle,
    required PlaylistType sourcePlaylistType,
    required String targetPlaylistTitle,
    required PlaylistType targetPlaylistType,
    required String appliedSortFilterParmsName,
    required int copiedAudioNumber,
    required int copiedCommentedAudioNumber,
    required int notCopiedAudioNumber,
  }) {
    _audioCopySourcePlaylistTitle = sourcePlaylistTitle;
    _copiedFromSourcePlaylistType = sourcePlaylistType;
    _audioCopyTargetPlaylistTitle = targetPlaylistTitle;
    _copiedToTargetPlaylistType = targetPlaylistType;
    _appliedToCopySortFilterParmsName = appliedSortFilterParmsName;
    _copiedAudioNumber = copiedAudioNumber;
    _copiedCommentedAudioNumber = copiedCommentedAudioNumber;
    _notCopiedAudioNumber = notCopiedAudioNumber;

    warningMessageType = WarningMessageType.confirmCopiedNotCopiedAudioNumber;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  int _rewindedPlayableAudioNumber = 0;
  int get rewindedPlayableAudioNumber => _rewindedPlayableAudioNumber;
  void rewindedPlayableAudioToStart({
    required int rewindedPlayableAudioNumber,
  }) {
    _rewindedPlayableAudioNumber = rewindedPlayableAudioNumber;

    warningMessageType = WarningMessageType.rewindedPlayableAudioToStart;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  int _redownloadAudioNumber = 0;
  int get redownloadAudioNumber => _redownloadAudioNumber;
  int _notRedownloadAudioNumber = 0;
  int get notRedownloadAudioNumber => _notRedownloadAudioNumber;
  void redownloadAudioNumberConfirmation({
    required String targetPlaylistTitle,
    required int redownloadAudioNumberAudioNumber,
    required int notRedownloadAudioNumberAudioNumber,
  }) {
    _playlistTitle = targetPlaylistTitle;
    _redownloadAudioNumber = redownloadAudioNumberAudioNumber;
    _notRedownloadAudioNumber = notRedownloadAudioNumberAudioNumber;

    warningMessageType =
        WarningMessageType.redownloadedAudioNumbersConfirmation;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _redownloadAudioTitle = '';
  String get redownloadAudioTitle => _redownloadAudioTitle;
  void redownloadAudioConfirmation({
    required String targetPlaylistTitle,
    required String redownloadAudioTitle,
    required int redownloadAudioNumber,
  }) {
    _playlistTitle = targetPlaylistTitle;
    _redownloadAudioTitle = redownloadAudioTitle;
    _redownloadAudioNumber = redownloadAudioNumber;

    warningMessageType =
        WarningMessageType.redownloadingAudioConfirmationOrWarning;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }

  String _targetPlaylistTitle = '';
  String get targetPlaylistTitle => _targetPlaylistTitle;
  int _audioNumber = 0;
  int get audioNumber => _audioNumber;
  void setNotRedownloadAudioFilesInPlaylistDirectory({
    required String targetPlaylistTitle,
    required int existingAudioNumber,
  }) {
    _targetPlaylistTitle = targetPlaylistTitle;
    _audioNumber = existingAudioNumber;

    if (existingAudioNumber > 0) {
      warningMessageType =
          WarningMessageType.notRedownloadAudioFilesInPlaylistDirectory;

      // Causes the display warning message widget to be displayed.
      notifyListeners();
    }
  }

  String _playlistInexistingRootPath = '';
  String get playlistInexistingRootPath => _playlistInexistingRootPath;

  void setPlaylistInexistingRootPath({
    required String playlistInexistingRootPath,
  }) {
    _playlistInexistingRootPath = playlistInexistingRootPath;

    warningMessageType = WarningMessageType.playlistRootPathNotExist;

    // Causes the display warning message widget to be displayed.
    notifyListeners();
  }
}
