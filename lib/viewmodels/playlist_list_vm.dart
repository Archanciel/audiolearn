import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../models/comment.dart';
import '../models/picture.dart';
import '../models/playlist.dart';
import '../models/sort_filter_parameters.dart';
import '../services/audio_sort_filter_service.dart';
import '../services/json_data_service.dart';
import '../services/settings_data_service.dart';
import '../utils/dir_util.dart';
import '../utils/date_time_expansion.dart';
import 'date_format_vm.dart';
import 'picture_vm.dart';
import 'audio_download_vm.dart';
import 'audio_player_vm.dart';
import 'comment_vm.dart';
import 'warning_message_vm.dart';

// Top-level function for isolate (place OUTSIDE your class)
Map<String, dynamic> _createZipInIsolate(Map<String, dynamic> params) {
  try {
    final List<Map<String, dynamic>> audioFilesData = params['audioFiles'];
    final String zipFilePath = params['zipFilePath'];

    // Create archive
    Archive archive = Archive();

    for (final audioData in audioFilesData) {
      final String filePath = audioData['filePath'];
      final String relativePath = audioData['relativePath'];

      // Read file
      File audioFile = File(filePath);
      if (audioFile.existsSync()) {
        List<int> audioBytes = audioFile.readAsBytesSync();
        archive.addFile(ArchiveFile(
          relativePath,
          audioBytes.length,
          audioBytes,
        ));
      }
    }

    // Encode ZIP (this heavy operation runs in background isolate)
    List<int> zipData = ZipEncoder().encode(archive);

    // Write ZIP file
    File(zipFilePath).writeAsBytesSync(zipData, flush: true);

    return {'success': true, 'zipPath': zipFilePath};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}

// Helper class to store audio file information
class AudioFileInfo {
  final Audio audio;
  final File audioFile;
  final String relativePath;
  final Playlist playlist;

  AudioFileInfo({
    required this.audio,
    required this.audioFile,
    required this.relativePath,
    required this.playlist,
  });
}

/// This VM (View Model) class is part of the MVVM architecture.
///
/// It is used in the PlaylistDownloadView screen in order to
/// provide the list of selectable playlists. Once a playlist
/// is selected, it can be moved up or down by clicking on the
/// corresponding button. The PlaylistListVM stores the list
/// of selectable playlists in the order they are displayed.
///
/// The PlaylistListVM also stores the selected playlist.
/// It manages as well the filtered and sorted selected
/// playlist audio. Using the general playlist menu located
/// at right of the PlaylistDownloadView screen, the user can
/// sort and filter the selected playlist audio. When the
/// selected playlist audio is asked to the PlaylistListVM,
/// either the full playable audio list of the selected playlist
/// or the filtered and sorted audio list is returned.
///
/// The class is also used in the AudioPlayerVM to obtain the
/// next or previous playable audio.
///
/// It is also used by several widgets in order to display or
/// manage the playlists.
class PlaylistListVM extends ChangeNotifier {
  bool _isPlaylistListExpanded = false;
  set isPlaylistListExpanded(bool isListExpanded) {
    _isPlaylistListExpanded = isListExpanded;

    notifyListeners();
  }

  bool _isButtonDownloadSelPlaylistsEnabled = false;
  bool _isButtonMovePlaylistEnabled = false;
  bool _areButtonsApplicableToAudioEnabled = false;

  bool get isPlaylistListExpanded => _isPlaylistListExpanded;
  bool get isButtonDownloadSelPlaylistsEnabled =>
      _isButtonDownloadSelPlaylistsEnabled;
  bool get isButtonMovePlaylistEnabled => _isButtonMovePlaylistEnabled;
  bool get areButtonsApplicableToAudioEnabled =>
      _areButtonsApplicableToAudioEnabled;

  final AudioDownloadVM _audioDownloadVM;
  final CommentVM _commentVM;
  final PictureVM _pictureVM;
  final WarningMessageVM _warningMessageVM;
  final SettingsDataService _settingsDataService;

  bool _isOnePlaylistSelected = true;
  bool get isOnePlaylistSelected => _isOnePlaylistSelected;

  List<Playlist> _listOfSelectablePlaylists = [];
  List<Playlist> get listOfSelectablePlaylists =>
      List<Playlist>.from(_listOfSelectablePlaylists);

  // This list is used to store the filtered and sorted audio list.
  // Its content corresponds to the sorted and filtered parms selected
  // by the user in the sf parms button or to a sf parms defined in
  // the SortAndFilterAudioDialog and applied or saved.
  List<Audio>? _sortedFilteredSelectedPlaylistPlayableAudioLst;
  List<Audio>? get sortedFilteredSelectedPlaylistPlayableAudioLst =>
      _sortedFilteredSelectedPlaylistPlayableAudioLst;

  AudioSortFilterParameters? _audioSortFilterParameters;
  AudioSortFilterParameters? get audioSortFilterParameters =>
      _audioSortFilterParameters;

  final Map<String, String>
      _playlistAudioSFparmsNamesForPlaylistDownloadViewMap = {};

  final Map<String, String> _playlistAudioSFparmsNamesForAudioPlayerViewMap =
      {};

  Playlist? _uniqueSelectedPlaylist;
  Playlist? get uniqueSelectedPlaylist => _uniqueSelectedPlaylist;

  final AudioSortFilterService _audioSortFilterService;

  // The next fields are used to manage the search sentence entered
  // by the user in the 'Youtube URL or search sentence' field of the
  // PlaylistDownloadView screen.

  bool isSearchButtonEnabled = false;

  String _searchSentence = '';
  String get searchSentence => _searchSentence;
  set searchSentence(String searchSentence) {
    _searchSentence = searchSentence;

    youtubeLinkOrSearchSentenceNotifier.value = searchSentence;

    String searchSentenceInLowerCase = _searchSentence.toLowerCase();

    if (searchSentenceInLowerCase.contains('https://') ||
        searchSentenceInLowerCase.contains('http://')) {
      // Single video download text button is enabled
      urlContainedInYoutubeLinkNotifier.value = true;
    } else {
      // Single video download text button is disabled
      urlContainedInYoutubeLinkNotifier.value = false;
    }

    if (searchSentence.isEmpty) {
      // If the search sentence is empty, the search button is not
      // clickable and the search icon button will be displayed with
      // its default color.
      wasSearchButtonClickedNotifier.value = false;
      youtubeLinkOrSearchSentenceNotifier.value = null;
    }

    if (_wasSearchButtonClicked) {
      // When the search sentence is set, if he search button was clicked,
      // the list of selectable playlists or the list of audio of the selected
      // playlist must be updated.
      notifyListeners();
    }
  }

  // Set to true when the user clicks on the search icon button and to
  // false when the user empty the 'Youtube link or Search' field or if
  // a URL is pasted in the field.
  bool _isSearchSentenceApplied = false;
  bool get isSearchSentenceApplied => _isSearchSentenceApplied;
  set isSearchSentenceApplied(bool isSearchSentenceApplied) {
    _isSearchSentenceApplied = isSearchSentenceApplied;
    notifyListeners();
  }

  bool _wasSearchButtonClicked = false;
  bool get wasSearchButtonClicked => _wasSearchButtonClicked;
  set wasSearchButtonClicked(bool wasSearchButtonClicked) {
    _wasSearchButtonClicked = wasSearchButtonClicked;
    // the search icon button will be displayed with an updated
    // forground and background color or not.
    wasSearchButtonClickedNotifier.value = wasSearchButtonClicked;

    notifyListeners();
  }

  // This field is used to store the title of the selected playlist
  // before applying the search sentence. This title is used to
  // avoid that the default sort filtered parameters is displayed
  // instead of tha applied one when the user clicks on the playlist
  // button to display the list of playlists. Since this list will be
  // empty if the search sentence is not empty and the search button
  // is applied, the sort filtered parameters would be empty an so set
  // to the default one if this field was not available.
  String _selectedPlaylistTitleBeforeApplyingSearchSentence = '';

  // This notifier is used to update the list of playlists
  // or the list of audio's in the playlist download view.
  final ValueNotifier<String?> youtubeLinkOrSearchSentenceNotifier =
      ValueNotifier<String?>(null);

  // This notifier is used to update the single video download
  // text button displayed in the playlist download view.
  final ValueNotifier<bool> urlContainedInYoutubeLinkNotifier =
      ValueNotifier(false); // false means that the download text
  //                           button will be disabled.

  // This notifier is used to update the single video download
  // text button displayed in the playlist download view.
  final ValueNotifier<bool> wasSearchButtonClickedNotifier =
      ValueNotifier(false); // true means that the search icon
  //                           button was clicked and so will be
  //                           displayed with an updated forground
  //                           and background color.

  final Logger _logger = Logger();

  // Playlist(s) MP3 save progression display on playlist
  // download view fields.

  bool _isSavingMp3 = false;
  bool get isSavingMp3 => _isSavingMp3;

  // Playlist name displayed only if unique playlist is saved
  String _audioMp3SaveUniquePlaylistName = '';
  String get audioMp3SaveUniquePlaylistName => _audioMp3SaveUniquePlaylistName;

  // After the playlist(s) MP3 were saved to ZIP's, ZIP's are
  // moved to the selected save dir. This takes time and so
  // the move progression is displayed on the playlist download
  // view fields.

  bool _isMovingMp3Zip = false;
  bool get isMovingMp3Zip => _isMovingMp3Zip;

  String _audioMp3MovedCurrentZipName = '';
  String get audioMp3MovedCurrentZipName => _audioMp3MovedCurrentZipName;

  // Playlist(s) MP3 restoration progression display on playlist
  // download view fields.

  bool _isRestoringMp3 = false;
  bool get isRestoringMp3 => _isRestoringMp3;

  String _audioMp3RestorationCurrentPlaylistName = '';
  String get audioMp3RestorationCurrentPlaylistName =>
      _audioMp3RestorationCurrentPlaylistName;

  Duration _savingAudioMp3FileToZipDuration = Duration.zero;
  Duration get savingAudioMp3FileToZipDuration =>
      _savingAudioMp3FileToZipDuration;

  int _numberOfCreatedZipFiles = 0;
  int get numberOfCreatedZipFiles => _numberOfCreatedZipFiles;

  PlaylistListVM({
    required WarningMessageVM warningMessageVM,
    required AudioDownloadVM audioDownloadVM,
    required CommentVM commentVM,
    required PictureVM pictureVM,
    required SettingsDataService settingsDataService,
  })  : _warningMessageVM = warningMessageVM,
        _audioDownloadVM = audioDownloadVM,
        _commentVM = commentVM,
        _pictureVM = pictureVM,
        _settingsDataService = settingsDataService,
        _isPlaylistListExpanded = settingsDataService.get(
              settingType: SettingType.playlists,
              settingSubType:
                  Playlists.arePlaylistsDisplayedInPlaylistDownloadView,
            ) ??
            false,
        _audioSortFilterService = AudioSortFilterService(
          settingsDataService: settingsDataService,
        );

  List<Playlist> getUpToDateSelectablePlaylistsExceptExcludedPlaylist({
    required Playlist excludedPlaylist,
    bool ignoreSearchSentence = false,
  }) {
    List<Playlist> upToDateSelectablePlaylists = getUpToDateSelectablePlaylists(
      ignoreSearchSentence: ignoreSearchSentence,
    );

    List<Playlist> listOfSelectablePlaylistsCopy =
        List.from(upToDateSelectablePlaylists);

    listOfSelectablePlaylistsCopy.remove(excludedPlaylist);

    return listOfSelectablePlaylistsCopy;
  }

  /// Method called when the user chooses the "Update playlist JSON files" menu
  /// item after having manually added playlists in the playlist root dir. The
  /// method is also executed when the user modifies the application settings
  /// through the ApplicationSettingsDialog opened by clicking on the Application
  /// settings menu item. Finally, the method is also called when the user clicks
  /// on the 'Restore Playlist, Comments and Settings from Zip File' menu item
  /// located in the appbar leading popup menu.
  ///
  /// When the user selects the "Update playlist JSON files" menu, the playlists
  /// which were manually added to the playlist root dir are unselected by default.
  ///
  /// When the user modifies the application settings, unselecting added playlist
  /// is not adequate since no playlist was manually added.
  ///
  /// For restoring from zip file, the method is called by the method
  /// restorePlaylistsCommentsAndSettingsJsonFilesFromZip(). In this case,
  /// [restoringPlaylistsCommentsAndSettingsJsonFilesFromZip] is set to true.
  /// The application settings won't be updated since they were correctly adapted
  /// in the method _mergeRestoredFromZipSettingsWithCurrentAppSettings().
  void updateSettingsAndPlaylistJsonFiles({
    bool unselectAddedPlaylist = true,
    required bool updatePlaylistPlayableAudioList,
    bool restoringPlaylistsCommentsAndSettingsJsonFilesFromZip = false,
    bool managePlaylistOrder = false,
  }) {
    _audioDownloadVM.updatePlaylistJsonFiles(
        unselectAddedPlaylist: unselectAddedPlaylist,
        updatePlaylistPlayableAudioList: updatePlaylistPlayableAudioList,
        restoringPlaylistsCommentsAndSettingsJsonFilesFromZip:
            restoringPlaylistsCommentsAndSettingsJsonFilesFromZip);

    List<Playlist> updatedListOfPlaylist = _audioDownloadVM.listOfPlaylist;

    for (Playlist playlist in updatedListOfPlaylist) {
      int index = _listOfSelectablePlaylists
          .indexWhere((element) => element == playlist);
      if (index == -1) {
        // If the playlist does not exist in the list, add it. This is
        // the case when the playlist dir was added manually to the app
        // playlist dir.
        _listOfSelectablePlaylists.add(playlist);
      } else {
        // If the playlist exists, replace it
        _listOfSelectablePlaylists[index] = playlist;
      }
    }

    List<Playlist> copyOfList = List<Playlist>.from(_listOfSelectablePlaylists);

    for (Playlist playlist in copyOfList) {
      if (!updatedListOfPlaylist.any((element) => element == playlist)) {
        // the case if the playlist dir was removed from the app
        // audio dir
        _listOfSelectablePlaylists.remove(playlist);
      }
    }

    // Updating the playable audio list of the selected playlist with the
    // audio list of the AudioDownloadVM list of playlists. This causes the
    // displayed audio of the selected playlist to be updated in case
    // audio were manually deleted in the directory of the selected
    // playlist. Without this code, the displayed audio list in the playlist
    // download view is updated only after having tapped on the playlist
    // menu 'Update playable Audio's list' !

    Playlist? playlistListVMselectedPlaylist =
        _listOfSelectablePlaylists.firstWhereOrNull(
      (element) => element.isSelected,
    );

    if (playlistListVMselectedPlaylist != null) {
      // required so that the selected playlist title text field
      // of the playlist download view is updated
      _uniqueSelectedPlaylist = playlistListVMselectedPlaylist;

      Playlist audioDownloadVMcorrespondingPlaylist =
          _audioDownloadVM.listOfPlaylist.firstWhere(
        (element) => element == playlistListVMselectedPlaylist,
      );

      playlistListVMselectedPlaylist.playableAudioLst =
          audioDownloadVMcorrespondingPlaylist.playableAudioLst;

      // buttons applicable to an audio are enabled if audio are
      // available in the selected playlist
      _setStateOfButtonsApplicableToAudio(
        selectedPlaylist: playlistListVMselectedPlaylist,
      );
    } else {
      // playlistListVMselectedPlaylist is null if the selected
      // playlist was manually deleted from the audio app root dir or
      // if no playlist is selected.
      //
      // if no playlist is selected, the playable audio list of the
      // selected playlist is emptied

      _setUniqueSelectedPlaylistToFalse();

      _setStateOfButtonsApplicableToAudio(
        // since no playlist is selected, no audio are displayed and
        // the buttons applicable to an audio are disabled
        selectedPlaylist: null,
      );
    }

    // If restoringPlaylistsCommentsAndSettingsJsonFilesFromZip is
    // true, the settings json file is not updated since it was
    // correctly adapted in the method
    // _mergeRestoredFromZipSettingsWithCurrentAppSettings().
    if (!restoringPlaylistsCommentsAndSettingsJsonFilesFromZip) {
      _updateAndSavePlaylistOrder(
          addExistingSettingsAudioSortFilterData:
              restoringPlaylistsCommentsAndSettingsJsonFilesFromZip,
          managePlaylistOrder: managePlaylistOrder);
    }

    notifyListeners();
  }

  /// This method is called when an audio to listen is selected and then
  /// the playlist download view is displayed. The method calculate the
  /// distance to which the playlist audio list must be scrolled so that the
  /// current or past audio is visible in the list of audio.
  int determineAudioToScrollPosition() {
    if (_uniqueSelectedPlaylist == null) {
      // If no playlist is selected, the audio list is empty and no
      // scrolling is required.
      return 0;
    }

    int currentOrPastPlayableAudioIndex =
        uniqueSelectedPlaylist!.currentOrPastPlayableAudioIndex;

    if (currentOrPastPlayableAudioIndex == -1) {
      // No audio is selected in the audio list of the selected playlist,
      // so no scrolling is required.
      return 0;
    }

    List<Audio> selectedPlaylisPlayableAudios =
        uniqueSelectedPlaylist!.playableAudioLst;

    if (selectedPlaylisPlayableAudios.isEmpty) {
      // If the audio list is empty, no scrolling is required.
      return 0;
    }

    if (currentOrPastPlayableAudioIndex >
        selectedPlaylisPlayableAudios.length) {
      // Exceptional case.
      return 0;
    }

    Audio currentOrPastPlayableAudio =
        selectedPlaylisPlayableAudios[currentOrPastPlayableAudioIndex];

    // Getting the currently displayed audio list of the selected playlist
    List<Audio> selectedPlaylistSortFiltertPlayableAudios =
        getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
      audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
    );

    // getting the index of the current or past audio in the displayed
    // audio list of the selected playlist
    int audioToScrollPosition = selectedPlaylistSortFiltertPlayableAudios
        .indexWhere((Audio audio) => audio == currentOrPastPlayableAudio);

    return audioToScrollPosition;
  }

  /// This method is called when the playlist download view is displayed. The
  /// method calculate the distance to which the playlist list must be scrolled
  /// so that the selected playlist is visible in the list of playlists.
  int determinePlaylistToScrollPosition() {
    if (_uniqueSelectedPlaylist == null) {
      // If no playlist is selected, no scrolling is required.
      return 0;
    }

    int selectedPlaylistIndex = _getSelectedPlaylistIndex();

    if (selectedPlaylistIndex == -1) {
      // No playlist is selected, so no scrolling is required.
      return 0;
    }

    if (_listOfSelectablePlaylists.isEmpty) {
      // If the list of playlists is empty, no scrolling is required.
      return 0;
    }

    if (selectedPlaylistIndex > _listOfSelectablePlaylists.length) {
      // Exceptional case.
      return 0;
    }

    // getting the index of the current or past audio in the displayed
    // audio list of the selected playlist
    int playlistToScrollPosition = _listOfSelectablePlaylists
        .indexWhere((Playlist playlist) => playlist == _uniqueSelectedPlaylist);

    return playlistToScrollPosition;
  }

  /// Due to this method, when restarting the app, the playlists
  /// are displayed in the same order as when the app was closed. This
  /// is done by saving the playlist order in the settings file.
  List<Playlist> getUpToDateSelectablePlaylists({
    bool ignoreSearchSentence = false,
  }) {
    List<Playlist> audioDownloadVMlistOfPlaylist =
        _audioDownloadVM.listOfPlaylist;
    List<dynamic>? orderedPlaylistTitleLst = _settingsDataService.get(
      settingType: SettingType.playlists,
      settingSubType: Playlists.orderedTitleLst,
    );

    if (orderedPlaylistTitleLst == null) {
      // If orderedPlaylistTitleLst is null, it means that the
      // user has not yet modified the order of the playlists.
      // So, we use the default order.
      _listOfSelectablePlaylists = audioDownloadVMlistOfPlaylist;
    } else {
      bool doUpdateSettings = false;
      _listOfSelectablePlaylists = [];

      for (String playlistTitle in orderedPlaylistTitleLst) {
        Playlist? foundPlaylist = audioDownloadVMlistOfPlaylist
            .where((playlist) => playlist.title == playlistTitle)
            .firstOrNull; // Extension method from collection package

        if (foundPlaylist != null) {
          _listOfSelectablePlaylists.add(foundPlaylist);
        } else {
          // The playlist is missing, so update settings accordingly
          doUpdateSettings = true;
        }
      }

      if (doUpdateSettings) {
        // Once some playlists have been deleted from the audio app root
        // dir, the next time the app is started, the ordered playlist
        // title list in the settings json file will be updated.
        _updateAndSavePlaylistOrder();
      }
    }

    int selectedPlaylistIndex = _getSelectedPlaylistIndex();

    if (selectedPlaylistIndex != -1) {
      _isOnePlaylistSelected = true;

      // required so that the Text keyed by 'selectedPlaylistTitleText'
      // below the playlist URL TextField is initialized at app startup
      _uniqueSelectedPlaylist =
          _listOfSelectablePlaylists[selectedPlaylistIndex];

      _setPlaylistButtonsStateIfOnePlaylistIsSelected(
        selectedPlaylist: _listOfSelectablePlaylists[selectedPlaylistIndex],
      );
    } else {
      _setUniqueSelectedPlaylistToFalse();

      _disableAllButtonsIfNoPlaylistIsSelected();
    }

    // Must be performed even if no playlist is selected since the
    // displayed playlists can all be unselected.
    if (!ignoreSearchSentence &&
        _wasSearchButtonClicked &&
        _searchSentence.isNotEmpty) {
      if (selectedPlaylistIndex != -1) {
        _selectedPlaylistTitleBeforeApplyingSearchSentence =
            _listOfSelectablePlaylists[selectedPlaylistIndex].title;
      } else {
        _selectedPlaylistTitleBeforeApplyingSearchSentence = '';
      }

      // If the search sentence is not empty, we filter the list of
      // selectable playlists according to the search sentence.
      return _listOfSelectablePlaylists
          .where((playlist) => playlist.title
              .toLowerCase()
              .contains(_searchSentence.toLowerCase()))
          .toList();
    }

    return _listOfSelectablePlaylists;
  }

  /// Returns true if the playlist was added, false otherwise and null
  /// if the local playlist title is invalid.
  Future<dynamic> addPlaylist({
    String playlistUrl = '',
    String localPlaylistTitle = '',
    required PlaylistQuality playlistQuality,
  }) async {
    if (localPlaylistTitle.isEmpty && playlistUrl.isNotEmpty) {
      try {
        final Playlist playlistWithThisUrlAlreadyDownloaded =
            _listOfSelectablePlaylists
                .firstWhere((element) => element.url == playlistUrl);
        // User clicked on Add button but the playlist with this url
        // was already downloaded since it is in the selectable playlist
        // list. Since orElse is not defined, firstWhere throws an exception
        // if the playlist with this url is not found.
        _warningMessageVM.setPlaylistAlreadyDownloadedTitle(
            playlistTitle: playlistWithThisUrlAlreadyDownloaded.title);

        return false;
      } catch (_) {
        // Here, the playlist with this url was not found in the application
        // list of playlists. This means that the Youtube playlist must be
        // added. Since the _audioDownloadVM.addPlaylist() method is
        // asynchronous, the code which uses it can not be included on the
        // firstWhere.onElse: parameter and instead is located after this if
        // {...} block.
      }
    } else if (localPlaylistTitle.isNotEmpty) {
      localPlaylistTitle = localPlaylistTitle.trim();

      if (localPlaylistTitle.contains(',')) {
        // A playlist title containing one or several commas can not
        // be handled by the application due to the fact that when
        // this playlist title will be added in the  playlist ordered
        // title list of the SettingsDataService, since the elements
        // of this list are separated by a comma, the playlist title
        // containing one or more commas will be divided in two or more
        // titles which will then not be findable in the playlist
        // directory. For this reason, adding such a playlist is refused
        // by the method.
        _warningMessageVM.invalidLocalPlaylistTitle = localPlaylistTitle;

        return null;
      }

      try {
        final Playlist playlistWithThisTitleAlreadyDownloaded =
            _listOfSelectablePlaylists
                .firstWhere((element) => element.title == localPlaylistTitle);
        // User clicked on Add button but the playlist with this title
        // was already defined since it is in the selectable playlist
        // list. Since orElse is not defined, firstWhere throws an exception
        // if the playlist with this title is not found.
        _warningMessageVM.setLocalPlaylistAlreadyCreatedTitle(
            playlistTitle: playlistWithThisTitleAlreadyDownloaded.title,
            playlistType: playlistWithThisTitleAlreadyDownloaded.playlistType);
        return false;
      } catch (_) {
        // If the playlist with this title is not found, it means that
        // the playlist must be added. Since the _audioDownloadVM.
        // addPlaylist() method is asynchronous, the code which uses it can
        // not be included on the firstWhere.onElse: parameter and instead
        // is located after this if {...} block.
      }
    } else {
      // If both playlistUrl and localPlaylistTitle are empty, it means
      // that the user clicked on the Add button without entering any
      // playlist url or local playlist title. So, we don't add the
      // playlist.
      return false;
    }

    // This code here is executed if the Youtube playlist url or the
    // local playlist title was not found in the _listOfSelectablePlaylists
    // and an exception was thrown (see above the 2 empty firstWhere catch
    // blocks).
    Playlist? addedPlaylist = await _audioDownloadVM.addPlaylist(
      playlistUrl: playlistUrl,
      localPlaylistTitle: localPlaylistTitle,
      playlistQuality: playlistQuality,
    );

    if (addedPlaylist != null) {
      int playlistIndex = _listOfSelectablePlaylists
          .indexWhere((playlist) => playlist.title == addedPlaylist.title);

      if (playlistIndex == -1) {
        // In this situation, the playlist was added to the application
        // and so must be added to the playlist list the settings playlist
        // order must be updated and saved.
        //
        // Else, the playlist is already in the list of selectable playlists
        // but its url was updated. This the case when a new playlist with the
        // same title is created on Youtube in order to replace the old one
        // which contains too many videos.
        _listOfSelectablePlaylists.add(addedPlaylist);
        _updateAndSavePlaylistOrder();

        // This method ensures that the list of playlists is
        // displayed
        if (!_isPlaylistListExpanded) {
          togglePlaylistsList();

          _settingsDataService.set(
              settingType: SettingType.playlists,
              settingSubType:
                  Playlists.arePlaylistsDisplayedInPlaylistDownloadView,
              value: true);

          _settingsDataService.saveSettings();
        }
      }

      notifyListeners();

      return true; // the playlist URL TextField will be cleared
    } else {
      // If addedPlaylist is null, it means that the passed
      // url is not a valid playlist url. It is useful to not
      // delete the invalid url so that the user can analyse
      // why this url is invalid.
      return false;
    }
  }

  /// Method called when the user clicks on the "Playlists" button of the
  /// PlaylistDownloadView screen. This method display or hide the list
  /// of playlists.
  ///
  /// The method is also called when the user add a playlist.
  void togglePlaylistsList() {
    _isPlaylistListExpanded = !_isPlaylistListExpanded;

    if (!_isPlaylistListExpanded) {
      _disableExpandedPaylistListButtons();
    } else {
      if (_isSearchSentenceApplied) {
        _listOfSelectablePlaylists = getUpToDateSelectablePlaylists();
      }

      int selectedPlaylistIndex = _getSelectedPlaylistIndex();

      if (selectedPlaylistIndex != -1) {
        _setPlaylistButtonsStateIfOnePlaylistIsSelected(
          selectedPlaylist: _listOfSelectablePlaylists[selectedPlaylistIndex],
        );
      } else {
        _disableAllButtonsIfNoPlaylistIsSelected();
      }
    }

    notifyListeners();
  }

  /// To be called before asking to download audio of selected
  /// playlists so that the currently displayed audio list is not
  /// sorted or/and filtered. This way, the newly downloaded
  /// audio will be added at top of the displayed audio list.
  void disableSortedFilteredPlayableAudioLst() {
    _sortedFilteredSelectedPlaylistPlayableAudioLst = null;

    notifyListeners();
  }

  /// Method used by PlaylistOneSelectedDialog to select
  /// only one playlist to which the audio will be moved or
  /// copied.
  void setUniqueSelectedPlaylist({
    Playlist? selectedPlaylist,
  }) {
    _uniqueSelectedPlaylist = selectedPlaylist;

    notifyListeners();
  }

  /// Method called by PlaylistItemWidget when the user clicks on
  /// the playlist item checkbox to select or unselect the playlist.
  ///
  /// The method is also called when the user restores the playlists
  /// from a zip file. In this case, the playlist title of the playlist
  /// which was selected before the restoration is passed in order to be
  /// selected again.
  ///
  /// Passing the playlist itself was causing a bug in the situation
  /// where the'Replace existing playlist(s)' checkbox was set to true
  /// since in this case, the old playlist was replaced by the restored
  /// one and asking _audioDownloadVM.updatePlaylistSelection() to update
  /// the playlist selection state was modifying the old playlist instead
  /// of modifying the restored playlist.
  ///
  /// Since currently only one playlist can be selected at a time,
  /// this method unselects all other playlists if the passed playlist
  /// is selected, i.e. if {isPlaylistSelected} is true.
  void setPlaylistSelection({
    Playlist? playlistSelectedOrUnselected,
    String playlistTitle = '',
    required bool isPlaylistSelected,
  }) {
    playlistSelectedOrUnselected ??= _listOfSelectablePlaylists
        .firstWhereOrNull((playlist) => playlist.title == playlistTitle);

    if (playlistSelectedOrUnselected == null) {
      // The playlist was not found in the list of selectable playlists.
      // This should not happen since the playlist is passed as a parameter
      // of the method. So, we do nothing and return.
      return;
    }

    // selecting another playlist or unselecting the currently
    // selected playlist nullifies the filtered and sorted audio list
    _sortedFilteredSelectedPlaylistPlayableAudioLst = null;
    _audioSortFilterParameters = null; // required to reset the sort and
    //                                    filter parameters, otherwise
    //                                    the previous sort and filter
    //                                    parameters will be applioed to
    //                                    the newly selected playlist

    if (isPlaylistSelected) {
      // since only one playlist can be selected at a time, we
      // unselect all the other playlists
      for (Playlist playlist in _listOfSelectablePlaylists) {
        if (playlist == playlistSelectedOrUnselected) {
          _audioDownloadVM.updatePlaylistSelection(
            playlist: playlistSelectedOrUnselected,
            isPlaylistSelected: true,
          );
        } else {
          _audioDownloadVM.updatePlaylistSelection(
            playlist: playlist,
            isPlaylistSelected: false,
          );
        }
      }
    }

    // BUG FIX: when the user unselects the playlist, the
    // playlist json file will not be updated in the AudioDownloadVM
    // updatePlaylistSelection method if the following line is not
    // commented out
    // _listOfSelectablePlaylists[playlistIndex].isSelected = isPlaylistSelected;
    _isOnePlaylistSelected = isPlaylistSelected;

    if (!_isOnePlaylistSelected) {
      _disableAllButtonsIfNoPlaylistIsSelected();

      // if no playlist is selected, the quality checkbox is
      // disabled and so must be unchecked
      _audioDownloadVM.isHighQuality = false;

      // BUG FIX: when the user unselects the playlist, the
      // playlist json file must be updated !
      _audioDownloadVM.updatePlaylistSelection(
        playlist: playlistSelectedOrUnselected,
        isPlaylistSelected: false,
      );

      // required so that the Text keyed by 'selectedPlaylistTitleText'
      // below the playlist URL TextField is updated (emptied)
      _uniqueSelectedPlaylist = null;
    } else {
      _setPlaylistButtonsStateIfOnePlaylistIsSelected(
        selectedPlaylist: playlistSelectedOrUnselected,
      );

      // required so that the Text keyed by 'selectedPlaylistTitleText'
      // below the playlist URL TextField is updated
      _uniqueSelectedPlaylist = playlistSelectedOrUnselected;

      // Required, otherwise when the user selects a playlist, the
      // audio list of the selected playlist is not displayed in the
      // playlist download view.
      getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );
    }

    notifyListeners();
  }

  /// Method called when the user confirms deleting the playlist.
  void deletePlaylist({
    required Playlist playlistToDelete,
  }) {
    // if the playlist to delete is local, then its id is its title ...
    int playlistToDeleteIndex = _listOfSelectablePlaylists
        .indexWhere((playlist) => playlist == playlistToDelete);

    if (playlistToDeleteIndex != -1) {
      if (playlistToDelete.isSelected) {
        _setUniqueSelectedPlaylistToFalse();
      }

      // When deleting the playlist, its related entries in the
      // application picture audio map are deleted as well.
      _pictureVM
          .removePlaylistRelatedAudioPictureEntriesFromApplicationPictureAudioMap(
        playlistTitle: playlistToDelete.title,
      );

      _audioDownloadVM.deletePlaylist(
        playlistToDelete: playlistToDelete,
      );
      _listOfSelectablePlaylists.removeAt(playlistToDeleteIndex);
      _updateAndSavePlaylistOrder();

      if (!_isOnePlaylistSelected) {
        _disableAllButtonsIfNoPlaylistIsSelected();
      }

      notifyListeners();
    }
  }

  void _setUniqueSelectedPlaylistToFalse() {
    _isOnePlaylistSelected = false;

    // required so that the Text keyed by 'selectedPlaylistTitleText'
    // below the playlist URL TextField is updated (emptied)
    _uniqueSelectedPlaylist = null;
  }

  void moveSelectedItemUp() {
    int selectedIndex = _getSelectedPlaylistIndex();

    if (selectedIndex != -1) {
      moveItemUp(selectedIndex);
      _updateAndSavePlaylistOrder();
      notifyListeners();
    }
  }

  int getPlaylistJsonFileSize({
    required Playlist playlist,
  }) {
    return _audioDownloadVM.getPlaylistJsonFileSize(
      playlist: playlist,
    );
  }

  bool doesAudioSortFilterParmsNameAlreadyExist({
    required String audioSortFilterParmrsName,
  }) {
    return _settingsDataService.namedAudioSortFilterParametersMap
        .containsKey(audioSortFilterParmrsName);
  }

  AudioSortFilterParameters getAudioSortFilterParameters({
    required String audioSortFilterParametersName,
  }) {
    if (audioSortFilterParametersName.isEmpty ||
        !_settingsDataService.namedAudioSortFilterParametersMap
            .containsKey(audioSortFilterParametersName)) {
      return AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
    } else {
      return _settingsDataService
          .namedAudioSortFilterParametersMap[audioSortFilterParametersName]!;
    }
  }

  List<AudioSortFilterParameters>
      getSearchHistoryAudioSortFilterParametersLst() {
    return _settingsDataService.searchHistoryAudioSortFilterParametersLst;
  }

  void addSearchHistoryAudioSortFilterParameters({
    required AudioSortFilterParameters audioSortFilterParameters,
  }) {
    _settingsDataService.addAudioSortFilterParametersToSearchHistory(
      audioSortFilterParameters: audioSortFilterParameters,
    );
  }

  void clearAudioSortFilterSettingsSearchHistory() {
    _settingsDataService.clearAudioSortFilterParametersSearchHistory();
  }

  /// Remove the audio sort/filter parameters from the search history list.
  /// Return true if the audio sort/filter parameters was found and removed,
  /// false otherwise.
  bool clearAudioSortFilterSettingsSearchHistoryElement(
    AudioSortFilterParameters audioSortFilterParameters,
  ) {
    return _settingsDataService
        .clearAudioSortFilterParametersSearchHistoryElement(
      audioSortFilterParameters,
    );
  }

  void saveAudioSortFilterParameters({
    required String audioSortFilterParametersName,
    required AudioSortFilterParameters audioSortFilterParameters,
  }) {
    _settingsDataService.addOrReplaceNamedAudioSortFilterParameters(
      audioSortFilterParametersName: audioSortFilterParametersName,
      audioSortFilterParameters: audioSortFilterParameters,
    );
  }

  /// This method returns the list of playlists which use the passed audio sort/filter
  /// parms name either for the playlist download view or for the audio player view.
  List<Playlist> getPlaylistsUsingSortFilterParmsName({
    required String audioSortFilterParmsName,
  }) {
    List<Playlist> returnedPlaylistsList = [];

    for (Playlist playlist in _listOfSelectablePlaylists) {
      if (playlist.audioSortFilterParmsNameForPlaylistDownloadView ==
              audioSortFilterParmsName ||
          playlist.audioSortFilterParmsNameForAudioPlayerView ==
              audioSortFilterParmsName) {
        returnedPlaylistsList.add(playlist);
      }
    }

    return returnedPlaylistsList;
  }

  /// Return the deleted audio sort/filter parameters if it existed,
  /// null otherwise.
  AudioSortFilterParameters? deleteAudioSortFilterParameters({
    required String audioSortFilterParametersName,
  }) {
    // Since the audio sort/filter parameters is deleted from the
    // settings named audio sort/filter parameters map, it must be
    // deleted from the playlist audio sort/filter parameters names
    // for playlist download view map and from the playlist audio
    // sort/filter parameters names for audio player view map as well.
    _playlistAudioSFparmsNamesForPlaylistDownloadViewMap.removeWhere(
        (key, mapValue) => mapValue == audioSortFilterParametersName);
    _playlistAudioSFparmsNamesForAudioPlayerViewMap.removeWhere(
        (key, mapValue) => mapValue == audioSortFilterParametersName);

    return _settingsDataService.deleteNamedAudioSortFilterParameters(
      audioSortFilterParametersName: audioSortFilterParametersName,
    );
  }

  /// Method called when the user select the left appbar menu 'Restore Playlists,
  /// Comments and Settings from Zip File' in the playlist download view.
  ///
  /// [addExistingSettingsAudioSortFilterData] is set to true when the
  /// playlist order is updated and the existing audio sort/filter
  /// parameters data (_namedAudioSortFilterParametersMap and
  /// _searchHistoryAudioSortFilterParametersLst) is extracted from the existing
  /// settings file and added to the corresponding settings map.
  void _updateAndSavePlaylistOrder({
    bool addExistingSettingsAudioSortFilterData = false,
    bool managePlaylistOrder = false,
  }) {
    List<String> playlistOrderFromListOfSelectablePlaylists =
        _listOfSelectablePlaylists.map((playlist) => playlist.title).toList();
    List<String> playlistOrder = (_settingsDataService.get(
      settingType: SettingType.playlists,
      settingSubType: Playlists.orderedTitleLst,
    ) as List<dynamic>)
        .cast<String>();

    // playlistOrder[0] == '' in situation of restoring an
    // individual playlist zip file in an empty application.
    //
    // If restoring a multiple playlists zip file in an empty
    // or not empty application, the playlistOrder must not
    // be updated since its content is correctly ordered and
    // the playlistOrderFromListOfSelectablePlaylists is not
    // correctly ordered.
    //
    // If restoring an individual playlist zip file in a not
    // empty application, the playlistOrder must be updated
    // by playlistOrderFromListOfSelectablePlaylists.
    if (managePlaylistOrder) {
      if (playlistOrder.isEmpty ||
          playlistOrder[0] == '' ||
          playlistOrderFromListOfSelectablePlaylists.length >
              playlistOrder.length) {
        playlistOrder = playlistOrderFromListOfSelectablePlaylists;
      }
    } else {
      // If not managing playlist order, we can simply use the
      // existing order
      playlistOrder = playlistOrderFromListOfSelectablePlaylists;
    }

    if (addExistingSettingsAudioSortFilterData) {
      _settingsDataService
          .updatePlaylistOrderAddExistingAudioSortFilterSettingsAndSave(
              playlistOrder: playlistOrder);
    } else {
      _settingsDataService.updatePlaylistOrderAndSaveSettings(
          playlistOrder: playlistOrder);
    }
  }

  void moveSelectedItemDown() {
    int selectedIndex = _getSelectedPlaylistIndex();

    if (selectedIndex != -1) {
      moveItemDown(selectedIndex);
      _updateAndSavePlaylistOrder();
      notifyListeners();
    }
  }

  /// This method is called when tapping on the playlist download view selected
  /// playlist download text button. Currently, only one playlist can be selected.
  Future<void> downloadSelectedPlaylist() async {
    List<Playlist> selectedPlaylists = getSelectedPlaylists();

    for (Playlist playlist in selectedPlaylists) {
      await _audioDownloadVM.downloadPlaylistAudio(playlistUrl: playlist.url);
    }

    getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
      audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
    );

    notifyListeners();
  }

  /// Currently, only one playlist is selectable. So, this method
  /// returns a list of Playlists containing the unique selected
  /// playlist.
  List<Playlist> getSelectedPlaylists() {
    return _listOfSelectablePlaylists
        .where((playlist) => playlist.isSelected)
        .toList();
  }

  /// This method is called when the user executes the playlist submenu 'Delete
  /// filtered Audio's ...' after having selected (and defined) a named Sort/Filter
  /// parameters. For example, it makes sense to define a filter only parameters
  /// which select fully listened audio's which are not commented. With this filter
  /// parameters applied to the playlist, using the playlist menu 'Delete filtered
  /// Audio ...' deletes the audio files and removes the deleted audio's from the
  /// playlist playable audio list.
  void deleteSortFilteredAudioLstAndTheirCommentsAndPicture() {
    List<Audio> filteredAudioToDelete =
        _sortedFilteredSelectedPlaylistPlayableAudioLst!;

    _audioDownloadVM.deleteAudioLstPhysicallyAndFromPlayableAudioLstOnly(
      audioToDeleteLst: filteredAudioToDelete,
    );

    // Deleting the comments of commented audio. This deletes comments
    // in case the applied sort/filter parameters selected commented audio
    // as well
    for (Audio audio in filteredAudioToDelete) {
      _commentVM.deleteAllAudioComments(commentedAudio: audio);

      // deleting the audio picture json file if it exists
      _pictureVM.deleteAudioPictureJsonFileIfExist(
        audio: audio,
      );
    }

    notifyListeners();
  }

  /// This method is called when the user executes the playlist submenu 'Re-download
  /// filtered Audio's' after having selected (and defined) a named Sort/Filter
  /// parameters. For example, it makes sense to define a filter only parameters
  /// which select audio's which are commented. With this filter parameters applied
  /// to the playlist, using the playlist menu 'Redownload filtered Audio's'
  /// redownload the audio files which were deleted, setting the file names to
  /// the initial downloaded file name.
  ///
  /// The method returns a list of two integers or an empty list:
  ///   [
  ///    number of audio files which were redownloaded,
  ///    number of audio files which were not redownloaded because the audio
  ///                        file(s) already exist in the playlist directory
  ///   ]. In case ErrorType.noInternet was returned as second element by
  /// _audioDownloadVM.redownloadPlaylistFilteredAudio(), then an empty list is
  /// returned.
  Future<List<int>> redownloadSortFilteredAudioLst({
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) async {
    List<Audio> filteredAudioToRedownload =
        _sortedFilteredSelectedPlaylistPlayableAudioLst!;

    // Storing the sort/filter parameters name of the selected
    // playlist before redownloading the audio. This name will be
    // used to restore the sort/filter parameters name after the
    // audio were redownloaded. This enables PlaylistDownloadView.
    // _buildExpandedAudioList() to display the empty sort/filter
    // audio list instead of the full default SF audio list.
    String sortFilterParmsName =
        _playlistAudioSFparmsNamesForPlaylistDownloadViewMap[
                _uniqueSelectedPlaylist!.title] ??
            '';

    List<dynamic> resultLst =
        await _audioDownloadVM.redownloadPlaylistFilteredAudio(
      targetPlaylist: _uniqueSelectedPlaylist!,
      filteredAudioToRedownload: filteredAudioToRedownload,
    );

    int existingAudioFilesNotRedownloadedCount = resultLst[0];

    // Restoring the sort/filter parameters name ...
    _playlistAudioSFparmsNamesForPlaylistDownloadViewMap[
        _uniqueSelectedPlaylist!.title] = sortFilterParmsName;

    notifyListeners();

    if (resultLst.length == 2) {
      // An ErrorType was returned as second element by
      // _audioDownloadVM.redownloadPlaylistFilteredAudio().
      // Returning an empty list will avoid that a confirmation
      // warning will be displayed, which will prevent the error
      // message of the AudioDownloadVM to be displayed.
      return [];
    } else {
      // If the audio was redownloaded, setting audioWasRedownloaded
      // to true prevents that the audio slider and the audio position
      // fields in the audio player view are not updated when playing
      // an audio the first time after having redownloaded it or having
      // redownloaded several filtered audio's.
      audioPlayerVMlistenFalse.setCurrentAudio(
        audio: filteredAudioToRedownload[0],
        audioWasRedownloaded: true,
      );

      return [
        filteredAudioToRedownload.length -
            existingAudioFilesNotRedownloadedCount,
        existingAudioFilesNotRedownloadedCount,
      ];
    }
  }

  void setSortFilterParmsNameForSelectedPlaylist({
    required AudioLearnAppViewType audioLearnAppViewType,
    required String audioSortFilterParmsName,
  }) {
    List<Playlist> selectedPlaylists = getSelectedPlaylists();

    if (audioLearnAppViewType == AudioLearnAppViewType.playlistDownloadView) {
      _playlistAudioSFparmsNamesForPlaylistDownloadViewMap[
          selectedPlaylists[0].title] = audioSortFilterParmsName;
    } else {
      // for AudioLearnAppViewType.audioPlayerView
      _playlistAudioSFparmsNamesForAudioPlayerViewMap[
          selectedPlaylists[0].title] = audioSortFilterParmsName;
    }

    notifyListeners();
  }

  /// This method is called when the user executes the audio list item menu
  /// 'Redownload deleted Audio' or the audio player view left appbar menu of the
  /// same name. Once the file is redownloaded, its name is set to the initial
  /// downloaded file name.
  ///
  /// The method returns:
  ///   0 if the audio file was not redownloaded because the audio
  ///     file already exist in the playlist directory.
  ///   1 if the audio file was redownloaded,
  ///  -1 if a download error happened.
  Future<int> redownloadDeletedAudio({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required Audio audio,
  }) async {
    List<Audio> filteredAudioToRedownload = [audio];

    // Storing the sort/filter parameters name of the selected
    // playlist before redownloading the audio. This name will be
    // used to restore the sort/filter parameters name after the
    // audio were redownloaded. This enables PlaylistDownloadView.
    // _buildExpandedAudioList() to display sort/filtered audio
    // list instead of the full default SF audio list.
    String sortFilterParmsName =
        _playlistAudioSFparmsNamesForPlaylistDownloadViewMap[
                _uniqueSelectedPlaylist!.title] ??
            '';

    List<dynamic> resultLst =
        await _audioDownloadVM.redownloadPlaylistFilteredAudio(
      targetPlaylist: _uniqueSelectedPlaylist!,
      filteredAudioToRedownload: filteredAudioToRedownload,
    );

    // Restoring the sort/filter parameters name ...
    _playlistAudioSFparmsNamesForPlaylistDownloadViewMap[
        _uniqueSelectedPlaylist!.title] = sortFilterParmsName;

    notifyListeners();

    if (resultLst.length == 2) {
      // ErrorType.noInternet or ErrorType.downloadAudioYoutubeError
      // was returned as second element by _audioDownloadVM.
      // redownloadPlaylistFilteredAudio(). Returning -1 will avoid
      // that a warning will be displayed, which will prevent the error
      // message of the AudioDownloadVM to be displayed.
      return -1;
    } else {
      // If the audio was redownloaded, setting audioWasRedownloaded
      // to true prevents that the audio slider and the audio position
      // fields in the audio player view are not updated when playing
      // an audio the first time after having redownloaded it or having
      // redownloaded several filtered audio's.
      audioPlayerVMlistenFalse.setCurrentAudio(
        audio: audio,
        audioWasRedownloaded: true,
      );

      return 1 - resultLst[0] as int;
    }
  }

  /// This method is called when the user executes the playlist submenu 'Delete
  /// Filtered Audio ...' after having selected (and defined) a named Sort/Filter
  /// parameters. For example, it makes sense to define a filter only parameters
  /// which select fully listened audio which are not commented. With this filter
  /// parameters applied to the playlist, using the playlist menu 'Delete filtered
  /// Audio's from Playlist as well ...' deletes the audio files and removes the
  /// deleted audio's from both the playlist downloaded and playable audio lists.
  ///
  /// The consequence is that the deleted audio's will later be re-downloaded.
  void deleteSortFilteredAudioLstFromPlaylistAsWell() {
    List<Audio> filteredAudioToDelete =
        _sortedFilteredSelectedPlaylistPlayableAudioLst!;

    _audioDownloadVM.deleteAudioLstPhysicallyAndFromDownloadedAndPlayableLst(
      audioToDeleteLst: filteredAudioToDelete,
    );

    notifyListeners();
  }

  /// This method is called when the user executes the playlist submenu 'Move
  /// filtered Audio's ...' after having selected (and defined) a named Sort/Filter
  /// parameters. Using the playlist menu 'Move filtered Audio's ...' moves the
  /// audio files to the target playlist directory, removes the moved audio's from
  /// the source playlist playable audio list and add them to the target playlist
  /// playable audio list. The moved audio's remain in the source playlist downloaded
  /// audio list and so will not be redownloaded !
  ///
  /// Returned list: [
  ///    movedAudioNumber,
  ///    movedCommentedAudioNumber,
  ///    unmovedAudioNumber,
  /// ].
  List<int> moveSortFilteredAudioAndCommentAndPictureLstToPlaylist({
    required Playlist targetPlaylist,
  }) {
    List<Audio> filteredAudioToMove =
        _sortedFilteredSelectedPlaylistPlayableAudioLst ?? [];

    if (filteredAudioToMove.isEmpty) {
      return [0, 0, 0];
    }

    int movedAudioNumber = 0;
    int movedCommentedAudioNumber = 0;
    int unmovedAudioNumber = 0;

    for (Audio audio in filteredAudioToMove) {
      if (_audioDownloadVM.moveAudioToPlaylist(
        audioToMove: audio,
        targetPlaylist: targetPlaylist,
        keepAudioInSourcePlaylistDownloadedAudioLst: true,
        displayWarningIfAudioAlreadyExists: false,
        displayWarningWhenAudioWasMoved: false,
      )) {
        movedAudioNumber++;

        // Moving the comments of commented audio. This moves comments
        // to the target playlist in case the applied sort/filter
        // parameters selected commented audio as well
        if (_commentVM.moveAudioCommentFileToTargetPlaylist(
          audio: audio,
          targetPlaylistPath: targetPlaylist.downloadPath,
        )) {
          movedCommentedAudioNumber++;
        }

        // Moving the audio picture file if it exists
        _pictureVM.moveAudioPictureJsonFileToTargetPlaylist(
          audio: audio,
          targetPlaylist: targetPlaylist,
        );
      } else {
        unmovedAudioNumber++;
      }
    }

    notifyListeners();

    return [
      movedAudioNumber,
      movedCommentedAudioNumber,
      unmovedAudioNumber,
    ];
  }

  /// This method is called when the user executes the playlist submenu 'Copy
  /// filtered Audio's ...' after having selected (and defined) a named Sort/Filter
  /// parameters. Using the playlist menu 'Copy filtered Audio's ...' copies the
  /// audio files to the target playlist directory and add them to the target
  /// playlist playable audio list. The copied audio's remain in the source playlist
  /// downloaded audio list and in its playable audio list !
  ///
  /// Returned list: [
  ///    copiedAudioNumber,
  ///    copiedCommentedAudioNumber,
  ///    notCopiedAudioNumber,
  /// ].
  List<int> copySortFilteredAudioAndCommentAndPictureLstToPlaylist({
    required Playlist targetPlaylist,
  }) {
    List<Audio> filteredAudioToCopy =
        _sortedFilteredSelectedPlaylistPlayableAudioLst!;
    int copiedAudioNumber = 0;
    int copiedCommentedAudioNumber = 0;
    int notCopiedAudioNumber = 0;

    for (Audio audio in filteredAudioToCopy) {
      if (_audioDownloadVM.copyAudioToPlaylist(
        audioToCopy: audio,
        targetPlaylist: targetPlaylist,
        displayWarningIfAudioAlreadyExists: false,
        displayWarningWhenAudioWasCopied: false,
      )) {
        copiedAudioNumber++;

        // Copying the comments of commented audio. This copies
        // comments to the target playlist in case the applied
        // sort/filter parameters selected commented audio as well
        if (_commentVM.copyAudioCommentFileToTargetPlaylist(
          audio: audio,
          targetPlaylistPath: targetPlaylist.downloadPath,
        )) {
          copiedCommentedAudioNumber++;
        }

        // Copying the audio picture file if it exists
        _pictureVM.copyAudioPictureJsonFileToTargetPlaylist(
          audio: audio,
          targetPlaylist: targetPlaylist,
        );
      } else {
        notCopiedAudioNumber++;
      }
    }

    notifyListeners();

    return [
      copiedAudioNumber,
      copiedCommentedAudioNumber,
      notCopiedAudioNumber,
    ];
  }

  /// Returns this int list:
  ///  [
  ///    numberOfDeletedAudio,
  ///    numberOfDeletedCommentedAudio,
  ///    deletedAudioFileSizeBytes,
  ///    deletedAudioDurationTenthSec,
  ///  ]
  List<int> getFilteredAudioQuantities() {
    int numberOfDeletedAudio =
        _sortedFilteredSelectedPlaylistPlayableAudioLst!.length;
    int numberOfDeletedCommentedAudio = _getNumberOfCommentedAudio(
      audioLst: _sortedFilteredSelectedPlaylistPlayableAudioLst!,
    );
    int deletedAudioFileSizeBytes = 0;
    int deletedAudioDurationTenthSec = 0;

    for (Audio audio in _sortedFilteredSelectedPlaylistPlayableAudioLst!) {
      deletedAudioFileSizeBytes += audio.audioFileSize;
      deletedAudioDurationTenthSec += audio.audioDuration.inMilliseconds ~/ 100;
    }

    return [
      numberOfDeletedAudio,
      numberOfDeletedCommentedAudio,
      deletedAudioFileSizeBytes,
      deletedAudioDurationTenthSec,
    ];
  }

  int _getNumberOfCommentedAudio({
    required List<Audio> audioLst,
  }) {
    int numberOfCommentedAudio = 0;

    for (Audio audio in audioLst) {
      if (_commentVM.getCommentNumber(audio: audio) > 0) {
        numberOfCommentedAudio++;
      }
    }

    return numberOfCommentedAudio;
  }

  /// Returns the selected playlist audio list. If the user clicked
  /// on a sort filter item in the sort filter dropdown button located
  /// in the playlist download view or if the user taped on the Apply
  /// button in the AudioSortFilterDialog, then the filtered
  /// and sorted audio list is returned.
  ///
  /// As well, if the selected playlist has a sort filter parameters name
  /// saved in its json file, then this sort filter parameters obtained
  /// from the settings data service are applied to the returned audio list,
  /// unless the user has changed the sort filter parameters in the
  /// AudioSortFilterDialog or in the playlist download view sort filter
  /// dropdown menu.
  List<Audio> getSelectedPlaylistPlayableAudioApplyingSortFilterParameters({
    required AudioLearnAppViewType audioLearnAppViewType,
    AudioSortFilterParameters? passedAudioSortFilterParameters,
    String passedAudioSortFilterParametersName = '',
    Playlist? playlist,
  }) {
    Playlist selectedPlaylist;

    if (playlist != null) {
      selectedPlaylist = playlist;
    } else {
      List<Playlist> selectedPlaylists = getSelectedPlaylists();

      if (selectedPlaylists.isEmpty) {
        return [];
      }

      if (!_isPlaylistListExpanded && _isSearchSentenceApplied) {
        // This test fixes a bug which made impossible to search an
        // audio in the audio list displayed in the situation where
        // the playlist list was collapsed.
        return _sortedFilteredSelectedPlaylistPlayableAudioLst ?? [];
      }

      selectedPlaylist =
          selectedPlaylists[0]; // currently, only one playlist can be selected
    }

    List<Audio> selectedPlaylistsAudios = selectedPlaylist.playableAudioLst;

    _audioSortFilterParameters = null;

    String selectedPlaylistTitle = selectedPlaylist.title;
    String selectedPlaylistSortFilterParmsName;

    // trying to obtain the sort and filter parameters name saved in the
    // view type PlaylistListVM map for the selected playlist
    if (passedAudioSortFilterParametersName.isEmpty) {
      if (audioLearnAppViewType == AudioLearnAppViewType.playlistDownloadView) {
        selectedPlaylistSortFilterParmsName =
            _playlistAudioSFparmsNamesForPlaylistDownloadViewMap[
                    selectedPlaylistTitle] ??
                '';
      } else {
        selectedPlaylistSortFilterParmsName =
            _playlistAudioSFparmsNamesForAudioPlayerViewMap[
                    selectedPlaylistTitle] ??
                '';
      }
    } else {
      selectedPlaylistSortFilterParmsName = passedAudioSortFilterParametersName;
    }

    // if the user has not selected a sort and filter parameters for the
    // selected playlist, then the sort and filter parameters whose name
    // is stored in the selected playlist json file is obtained.
    if (selectedPlaylistSortFilterParmsName.isEmpty) {
      switch (audioLearnAppViewType) {
        case AudioLearnAppViewType.playlistDownloadView:
          String audioSortFilterParmsNameForPlaylistDownloadView =
              selectedPlaylist.audioSortFilterParmsNameForPlaylistDownloadView;

          if (audioSortFilterParmsNameForPlaylistDownloadView.isNotEmpty) {
            // This means that the user has defined a sort filter parameters
            // instance applicable to any playlist, which is stored the
            // application settings json file. This named sort filter
            // parameters instance was saved in the current playlist json
            // file to be automatically applyed in the playlist download
            // view if the user has not selected a sort filter parameters
            // in the sort filter parameters download button.
            _audioSortFilterParameters =
                _settingsDataService.namedAudioSortFilterParametersMap[
                    audioSortFilterParmsNameForPlaylistDownloadView];
          }
          break;
        case AudioLearnAppViewType.audioPlayerView:
          String audioSortFilterParmsNameForAudioPlayerView =
              selectedPlaylist.audioSortFilterParmsNameForAudioPlayerView;

          if (audioSortFilterParmsNameForAudioPlayerView.isNotEmpty) {
            // This means that the user has defined a sort filter parameters
            // instance applicable to any playlist, which is stored the
            // application settings json file. This named sort filter
            // parameters instance was saved in the current playlist json
            // file to be automatically applyed in the playlist download
            // view if the user has not selected a sort filter parameters
            // in the sort filter parameters download button.
            _audioSortFilterParameters =
                _settingsDataService.namedAudioSortFilterParametersMap[
                    audioSortFilterParmsNameForAudioPlayerView];
          }
          break;
        default:
          break;
      }
    } else {
      // If the playlist has been selected and the user has not yet
      // defined a sort and filter parameters for the playlist, then
      // the default sort and filter parameters will be applied to the
      // playlist audio list.
      _audioSortFilterParameters =
          _settingsDataService.namedAudioSortFilterParametersMap[
              selectedPlaylistSortFilterParmsName];
    }

    _audioSortFilterParameters ??= passedAudioSortFilterParameters;

    _sortedFilteredSelectedPlaylistPlayableAudioLst =
        _audioSortFilterService.filterAndSortAudioLst(
      selectedPlaylist: selectedPlaylist,
      audioLst: selectedPlaylistsAudios,
      audioSortFilterParameters: _audioSortFilterParameters ??
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
    );

    // currently, only one playlist can be selected at a time !
    // so, the following code is not useful
    //
    // for (Playlist playlist in _listOfSelectablePlaylists) {
    //   if (playlist.isSelected) {
    //     selectedPlaylistsAudios.addAll(playlist.playableAudioLst);
    //   }
    // }

    return _sortedFilteredSelectedPlaylistPlayableAudioLst!;
  }

  /// Returns an audio file name no ext list of the selected playlist, sorted and
  /// filtered according to the passed sort and filter parameters.
  List<String>
      getSortedPlaylistAudioCommentFileNamesApplyingSortFilterParameters({
    required Playlist selectedPlaylist,
    required AudioLearnAppViewType audioLearnAppViewType,
    required List<String> commentFileNameNoExtLst,
    required String audioSortFilterParametersName,
  }) {
    List<Audio> selectedPlaylistSortedAudioLst =
        getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
      audioLearnAppViewType: audioLearnAppViewType,
      passedAudioSortFilterParametersName: audioSortFilterParametersName,
    );

    // First step: create a map associating each comment file name to
    // its position in the audio list of the selected playlist.

    Map<String, int> audioFileNameNoExtToIndexMap = {};
    int position = 0;

    for (Audio audio in selectedPlaylistSortedAudioLst) {
      audioFileNameNoExtToIndexMap[DirUtil.getFileNameWithoutMp3Extension(
        mp3FileName: audio.audioFileName,
      )] = position++;
    }

    // Second step: filter out the audio = comment file name no ext
    // not present in the audioFileNameNoExtToIndexMap
    List<String> filteredAudioFileNameNoExtLst = commentFileNameNoExtLst
        .where(
          (commentFileNameNoExt) => audioFileNameNoExtToIndexMap.containsKey(
            commentFileNameNoExt,
          ),
        )
        .toList();

    // Third step: sort the filtered audio file name no ext list
    // according to the position of the corresponding audio in
    // the audio list of the selected playlist
    filteredAudioFileNameNoExtLst.sort(
      (a, b) => audioFileNameNoExtToIndexMap[a]!.compareTo(
        audioFileNameNoExtToIndexMap[b]!,
      ),
    );

    return filteredAudioFileNameNoExtLst;
  }

  List<SortingItem> getSortingItemLstForViewType(
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    Playlist selectedPlaylist = getSelectedPlaylists()[0];
    List<SortingItem> playlistSortingItemLst;

    switch (audioLearnAppViewType) {
      case AudioLearnAppViewType.playlistDownloadView:
        playlistSortingItemLst = _settingsDataService
                .namedAudioSortFilterParametersMap[selectedPlaylist
                    .audioSortFilterParmsNameForPlaylistDownloadView]
                ?.selectedSortItemLst ??
            // if the user has not yet set and saved sort and filter
            // parameters for the playlist, then the default sorting
            // item is returned
            [AudioSortFilterParameters.getDefaultSortingItem()];
        break;
      case AudioLearnAppViewType.audioPlayerView:
        playlistSortingItemLst = _settingsDataService
                .namedAudioSortFilterParametersMap[
                    selectedPlaylist.audioSortFilterParmsNameForAudioPlayerView]
                ?.selectedSortItemLst ??
            // if the user has not yet set and saved sort and filter
            // parameters for the playlist, then the default sorting
            // item is returned
            [AudioSortFilterParameters.getDefaultSortingItem()];
        break;
      default:
        playlistSortingItemLst = [];
        break;
    }

    return playlistSortingItemLst;
  }

  /// Method related to the need of the AudioPlayableListDialog to obtain the
  /// sort an filtered not fully played audios of the selected playlist.
  List<Audio>
      getSelectedPlaylistNotFullyPlayedAudioApplyingSortFilterParameters({
    required AudioLearnAppViewType audioLearnAppViewType,
  }) {
    List<Audio> playlistPlayableAudioLst =
        getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
      audioLearnAppViewType: audioLearnAppViewType,
    );

    return playlistPlayableAudioLst
        .where((audio) => !audio.wasFullyListened())
        .toList();
  }

  /// Used to display the audio list of the selected playlist
  /// starting at the beginning.
  bool isAudioListFilteredAndSorted() {
    return _sortedFilteredSelectedPlaylistPlayableAudioLst != null;
  }

  /// Returns true if the passed selected sort and filter parameters name is
  /// already saved in the selected playlist json file for the playlist download
  /// view and for the audio player view. In this case, the Save sort/filter to
  /// playlist menu item is not enabled.
  bool isSortFilterAudioParmsAlreadySavedInPlaylistForAllViews({
    required String selectedSortFilterParametersName,
  }) {
    Playlist selectedPlaylist = getSelectedPlaylists()[0];

    if (selectedPlaylist.audioSortFilterParmsNameForPlaylistDownloadView ==
            selectedSortFilterParametersName &&
        selectedPlaylist.audioSortFilterParmsNameForAudioPlayerView ==
            selectedSortFilterParametersName) {
      return true;
    }

    return false;
  }

  /// Method called when the user selects a Sort and Filter
  /// item in the download playlist view Sort and Filter dropdown
  /// menu or after the user clicked on the Save or Apply button
  /// contained in the AudioSortFilterDialog. The AudioSortFilterDialog
  /// can be opened by clicking on a the Sort and Filter dropdown item
  /// edit icon button or on Sort Filter menu item in the audio menu
  /// located in the playlist download view or in the audio player view.
  ///
  /// {audioSortFilterParameters} is the sort and filter parameters
  /// selected by the user in the download playlist view Sort and
  /// Filter dropdown menu or is the sort and filter parameters
  /// the user did set in the SortAndFilterAudioDialog.
  void setSortFilterForSelectedPlaylistPlayableAudiosAndParms({
    required AudioLearnAppViewType audioLearnAppViewType,
    required List<Audio> sortFilteredSelectedPlaylistPlayableAudio,
    required AudioSortFilterParameters audioSortFilterParms,
    required String audioSortFilterParmsName,
    String translatedAppliedSortFilterParmsName = '',
    String searchSentence = '',
    bool doNotifyListeners = true,
  }) {
    if (audioSortFilterParmsName != '' &&
        audioSortFilterParmsName == translatedAppliedSortFilterParmsName) {
      // This is required to avoid that if an applied SF parm was
      // defined in the playlist download view in the situation where
      // the list of playlists was expanded and then the user clicks
      // on the playlists button to hide the list of playlists, the
      // application fails due to a SF parms dropdown button exception.
      _settingsDataService.addOrReplaceNamedAudioSortFilterParameters(
        audioSortFilterParametersName: audioSortFilterParmsName,
        audioSortFilterParameters: audioSortFilterParms,
      );
    }
    _sortedFilteredSelectedPlaylistPlayableAudioLst =
        sortFilteredSelectedPlaylistPlayableAudio;
    _audioSortFilterParameters = audioSortFilterParms;

    if (searchSentence.isNotEmpty) {
      // Required so that changing the search sentence by reducing
      // or modifying it updates correctly the filtered audio list.
      _sortedFilteredSelectedPlaylistPlayableAudioLst =
          _audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: _uniqueSelectedPlaylist!,
        audioLst: _uniqueSelectedPlaylist!.playableAudioLst,
        audioSortFilterParameters: _audioSortFilterParameters ??
            AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
      );

      searchSentence = searchSentence.toLowerCase();
      _sortedFilteredSelectedPlaylistPlayableAudioLst =
          _sortedFilteredSelectedPlaylistPlayableAudioLst!
              .where((audio) =>
                  audio.validVideoTitle.toLowerCase().contains(searchSentence))
              .toList();
    }

    List<Playlist> selectedPlaylists = getSelectedPlaylists();

    if (selectedPlaylists.isNotEmpty) {
      if (audioLearnAppViewType == AudioLearnAppViewType.playlistDownloadView) {
        _playlistAudioSFparmsNamesForPlaylistDownloadViewMap[
            selectedPlaylists[0].title] = audioSortFilterParmsName;
      } else {
        // for AudioLearnAppViewType.audioPlayerView
        _playlistAudioSFparmsNamesForAudioPlayerViewMap[
            selectedPlaylists[0].title] = audioSortFilterParmsName;
      }
    }

    if (doNotifyListeners) {
      notifyListeners();
    }
  }

  /// Method called by the home page when the user clicks on the 'Playlist Download View'
  /// button at the bottom of the application.
  ///
  /// This method simply notifies the listeners of the PlaylistListVM
  /// in order to update them.
  void backToPlaylistDownloadView() {
    notifyListeners();
  }

  /// Method used to disable the search button as well as to clear the search
  /// sentence.
  void disableSearchSentence() {
    isSearchButtonEnabled = false;
    _isSearchSentenceApplied = false;
    _wasSearchButtonClicked = false;

    // Causes the search icon button to be disabled
    searchSentence = '';

    // Necessary so that displayed audio list is updated to
    // the valid list when the search sentence was cleared.
    notifyListeners();
  }

  /// Method called when the user clicked on the audio popup menu button in the
  /// PlaylistDownloadView or in the AudioPlayerView and then clicked on the menu
  /// item "Sort filter Audio ...". This opens the AudioSortFilterDialog.
  ///
  /// The returned list content is
  /// [
  ///   the sort and filter parameters name applied to the playlist download
  ///   view or to the audio player view,
  ///   the sort and filter parameters applied to the playlist download view
  ///   or to the audio player view,
  /// ]
  List<dynamic> getSelectedPlaylistAudioSortFilterParmsForView(
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    Playlist selectedPlaylist = getSelectedPlaylists()[0];
    AudioSortFilterParameters? playlistAudioSortFilterParameters;
    String playlistAudioSortFilterParametersName;

    switch (audioLearnAppViewType) {
      case AudioLearnAppViewType.playlistDownloadView:
        playlistAudioSortFilterParametersName =
            selectedPlaylist.audioSortFilterParmsNameForPlaylistDownloadView;
        playlistAudioSortFilterParameters =
            _settingsDataService.namedAudioSortFilterParametersMap[
                playlistAudioSortFilterParametersName];
        break;
      case AudioLearnAppViewType.audioPlayerView:
        playlistAudioSortFilterParametersName =
            selectedPlaylist.audioSortFilterParmsNameForAudioPlayerView;
        playlistAudioSortFilterParameters =
            _settingsDataService.namedAudioSortFilterParametersMap[
                playlistAudioSortFilterParametersName];
        break;
      default:
        playlistAudioSortFilterParametersName = '';
        break;
    }

    if (playlistAudioSortFilterParameters != null) {
      return [
        playlistAudioSortFilterParametersName,
        playlistAudioSortFilterParameters,
      ];
    }

    // if the user has not yet selected sort and filter parameters,
    // then the default sort and filter parameters which don't
    // filter and only sort by audio download date descending
    // are returned.
    return [
      playlistAudioSortFilterParametersName,
      AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
    ];
  }

  String getSelectedPlaylistAudioSortFilterParmsNameForView({
    required AudioLearnAppViewType audioLearnAppViewType,
    required String translatedAppliedSortFilterParmsName,
  }) {
    List<Playlist> selectedPlaylists = getSelectedPlaylists();

    if (selectedPlaylists.isEmpty) {
      if (_isSearchSentenceApplied && _wasSearchButtonClicked) {
        // This test fixes a bug which made impossible to search an
        // audio in the audio list displayed in the situation where
        // the playlist list was collapsed.

        String audioSortFilterParmsName =
            _playlistAudioSFparmsNamesForPlaylistDownloadViewMap[
                    _selectedPlaylistTitleBeforeApplyingSearchSentence] ??
                '';

        return audioSortFilterParmsName;
      }

      return '';
    }

    Playlist selectedPlaylist = selectedPlaylists[0];
    String selectedPlaylistAudioSortFilterParmsNameSetByUser = '';

    if (audioLearnAppViewType == AudioLearnAppViewType.playlistDownloadView) {
      selectedPlaylistAudioSortFilterParmsNameSetByUser =
          _playlistAudioSFparmsNamesForPlaylistDownloadViewMap[
                  selectedPlaylist.title] ??
              '';
    } else {
      // for AudioLearnAppViewType.audioPlayerView
      selectedPlaylistAudioSortFilterParmsNameSetByUser =
          _playlistAudioSFparmsNamesForAudioPlayerViewMap[
                  selectedPlaylist.title] ??
              '';
    }

    if (selectedPlaylistAudioSortFilterParmsNameSetByUser.isEmpty) {
      // The sort and filter parameters name returned here was saved
      // in the playlist json file using the 'Save sort/filter options
      // to playlist' audio menu item. If the user has not saved a
      // sort and filter parameters name to the playlist json file, then
      // '' is returned.
      if (audioLearnAppViewType == AudioLearnAppViewType.playlistDownloadView) {
        selectedPlaylistAudioSortFilterParmsNameSetByUser =
            selectedPlaylist.audioSortFilterParmsNameForPlaylistDownloadView;
      } else {
        // for AudioLearnAppViewType.audioPlayerView
        selectedPlaylistAudioSortFilterParmsNameSetByUser =
            selectedPlaylist.audioSortFilterParmsNameForAudioPlayerView;
      }
    }

    if (selectedPlaylistAudioSortFilterParmsNameSetByUser ==
        translatedAppliedSortFilterParmsName) {
      return translatedAppliedSortFilterParmsName;
    }

    if (_settingsDataService.namedAudioSortFilterParametersMap
        .containsKey(selectedPlaylistAudioSortFilterParmsNameSetByUser)) {
      return selectedPlaylistAudioSortFilterParmsNameSetByUser;
    } else {
      return '';
    }
  }

  /// Method called when the user clicks on the 'Move audio to
  /// playlist' menu item in the audio item menu button or in
  /// the audio player screen leading popup menu.
  ///
  /// The method returns the next playable audio. The returned
  /// value is only useful when the user is in the audio player
  /// screen and so that the audio to move is the currently
  /// playable audio. In case the audio was not moved - the
  /// case if the audio already exist in the target playlist -
  /// null is returned
  Audio? moveAudioAndCommentAndPictureToPlaylist({
    required AudioLearnAppViewType audioLearnAppViewType,
    required Audio audio,
    required Playlist targetPlaylist,
    required bool keepAudioInSourcePlaylistDownloadedAudioLst,
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) {
    // Obtaining the audio which will replace the moved audio
    // in the audio player view.
    Audio? nextAudio = _getNextSortFilteredNotFullyPlayedAudio(
      audioLearnAppViewType: audioLearnAppViewType,
      currentAudio: audio,
    );

    bool wasAudioMoved = _audioDownloadVM.moveAudioToPlaylist(
        audioToMove: audio,
        targetPlaylist: targetPlaylist,
        keepAudioInSourcePlaylistDownloadedAudioLst:
            keepAudioInSourcePlaylistDownloadedAudioLst);

    if (!wasAudioMoved) {
      return null;
    }

    _commentVM.moveAudioCommentFileToTargetPlaylist(
      audio: audio,
      targetPlaylistPath: targetPlaylist.downloadPath,
    );

    // Moving the audio picture file if it exists
    _pictureVM.moveAudioPictureJsonFileToTargetPlaylist(
      audio: audio,
      targetPlaylist: targetPlaylist,
    );

    // Required, otherwise, when opening the audio in the audio
    // player view, the picture is not displayed since the
    // audioPlayerVM current audio is the moved audio and so
    // the audio pictures json file is not available since it
    // has been moved !
    audioPlayerVMlistenFalse.clearCurrentAudio();

    notifyListeners();

    return nextAudio;
  }

  /// Method called when the user clicks on the 'Copy audio to
  /// playlist' menu item in the audio item menu button or in
  /// the audio player screen leading popup menu.
  ///
  /// True is returned if the audio file was copied to the target
  /// playlist directory, false otherwise. If the audio file already
  /// exist in the target playlist directory, the copy operation does
  /// not happen and false is returned.
  bool copyAudioAndCommentAndPictureToPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
  }) {
    bool wasAudioCopied = _audioDownloadVM.copyAudioToPlaylist(
      audioToCopy: audio,
      targetPlaylist: targetPlaylist,
    );

    if (!wasAudioCopied) {
      return false;
    }

    _commentVM.copyAudioCommentFileToTargetPlaylist(
      audio: audio,
      targetPlaylistPath: targetPlaylist.downloadPath,
    );

    // Copying the audio picture file if it exists
    _pictureVM.copyAudioPictureJsonFileToTargetPlaylist(
      audio: audio,
      targetPlaylist: targetPlaylist,
    );

    notifyListeners();

    return true;
  }

  /// Method called when the user selected the Update playable
  /// audio list menu displayed by the playlist item menu button.
  /// This method updates the playlist playable audio list
  /// by removing the audio that are no longer present in the
  /// audio playlist directory. Those audio were manually deleted
  /// from the playlist directory by the user.
  ///
  /// The method is useful when the user has deleted some audio
  /// mp3 files from the audio playlist directory.
  int updatePlayableAudioLst({
    required Playlist playlist,
  }) {
    int removedPlayableAudioNumber = playlist.updatePlayableAudioLst();

    if (removedPlayableAudioNumber > 0) {
      JsonDataService.saveToFile(
        model: playlist,
        path: playlist.getPlaylistDownloadFilePathName(),
      );

      _sortedFilteredSelectedPlaylistPlayableAudioLst = null;

      notifyListeners();
    }

    return removedPlayableAudioNumber;
  }

  /// Method called after the user clicked on the 'Save sort/filter options
  /// to playlist' menu item in the audio item menu button present in the
  /// playlist download view and in the audio player view.
  ///
  /// The sort/filter parms name was selected by the user in the sort/filter
  /// dropdown button. The selected sort/filter parms name is saved in the
  /// playlist json file.
  ///
  /// The actions above are done for the playlist download view and/or for the
  /// audio player view.
  ///
  /// Finally, the playlist json file is saved.
  void savePlaylistAudioSortFilterParmsToPlaylist({
    String sortFilterParmsNameToSave = '',
    bool forPlaylistDownloadView = false,
    bool forAudioPlayerView = false,
  }) {
    Playlist playlist = getSelectedPlaylists()[0];

    // A named sort/filter parms is saved in the playlist json file ...
    if (forPlaylistDownloadView) {
      playlist.audioSortFilterParmsNameForPlaylistDownloadView =
          sortFilterParmsNameToSave;
    }

    if (forAudioPlayerView) {
      // If a SF parms was created in the audio player view, and so
      // was added to _playlistAudioSFparmsNamesForAudioPlayerViewMap,
      // when the user clicks on the 'Save sort/filter options to
      // playlist' menu item in the playlist download dialog, then
      // the previously applied SF parms name is replaced in
      // _playlistAudioSFparmsNamesForAudioPlayerViewMap.
      _playlistAudioSFparmsNamesForAudioPlayerViewMap[playlist.title] =
          sortFilterParmsNameToSave;

      playlist.audioSortFilterParmsNameForAudioPlayerView =
          sortFilterParmsNameToSave;

      AudioSortFilterParameters audioSortFilterParms =
          getAudioSortFilterParameters(
              audioSortFilterParametersName: sortFilterParmsNameToSave);

      _improveDefaultAudioPlayingOrder(
        playlist: playlist,
        audioSortFilterParms: audioSortFilterParms,
      );
    }

    JsonDataService.saveToFile(
      model: playlist,
      path: playlist.getPlaylistDownloadFilePathName(),
    );

    notifyListeners();
  }

  void removeAudioSortFilterParmsFromPlaylist({
    bool fromPlaylistDownloadView = false,
    bool fromAudioPlayerView = false,
  }) {
    Playlist playlist = getSelectedPlaylists()[0];
    String playlistTitle = playlist.title;

    if (fromPlaylistDownloadView) {
      _playlistAudioSFparmsNamesForPlaylistDownloadViewMap
          .remove(playlistTitle);
      playlist.audioSortFilterParmsNameForPlaylistDownloadView = '';

      // necessary so that the default sort filter parameters is applied
      // to the playlist audio list. Causes the displayed playlist download
      // view audio list to be sorted and filtered by the default sort
      // filter parameters. Also necessary so the sort filter dropdown
      // button selects the default sort filter parameters.
      _sortedFilteredSelectedPlaylistPlayableAudioLst =
          _audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: playlist,
        audioLst: playlist.playableAudioLst,
        audioSortFilterParameters:
            AudioSortFilterParameters.createDefaultAudioSortFilterParameters(),
      );
    }

    if (fromAudioPlayerView) {
      _playlistAudioSFparmsNamesForAudioPlayerViewMap.remove(playlistTitle);
      playlist.audioSortFilterParmsNameForAudioPlayerView = '';
    }

    JsonDataService.saveToFile(
      model: playlist,
      path: playlist.getPlaylistDownloadFilePathName(),
    );

    notifyListeners();
  }

  /// Method called only if the saved SF parms are applied to the audio
  /// player view. The method improves the default audio playing order
  /// if the selected sort item is 'valid audio title' ascending.
  ///
  /// This makes sense: if audio title ascecding is selected, then the
  /// audio list is sorted by audio title ascendingly: chapter 1, chapter 2,
  /// chapter 3, ... But it is logic that such a list is played in the
  /// descending order: chapter 1 first, then down the list chapter 2, then
  /// chapter 3 etc ! So, the audio playing order is set to descending in the
  /// playlist json file.
  void _improveDefaultAudioPlayingOrder({
    required Playlist playlist,
    required AudioSortFilterParameters audioSortFilterParms,
  }) {
    SortingItem selectedSortItem = audioSortFilterParms.selectedSortItemLst[0];

    if (selectedSortItem.sortingOption == SortingOption.validAudioTitle &&
        selectedSortItem.isAscending) {
      playlist.audioPlayingOrder = AudioPlayingOrder.descending;
    } else {
      playlist.audioPlayingOrder = AudioPlayingOrder.ascending;
    }
  }

  List<Comment> getAudioComments({
    required Audio audio,
  }) {
    return _commentVM.loadAudioComments(audio: audio);
  }

  /// Method called when the user clicks on the 'delete audio'
  /// menu item in the audio item menu button or in
  /// the audio player screen leading popup menu.
  ///
  /// Physically deletes the audio mp3 file from the audio
  /// playlist directory.
  ///
  /// The method removes the deleted audio from the playlist
  /// playable audio list. The deleted audio remain in the playlist
  /// downloaded audio list and so will not be redownloaded !
  ///
  /// The method returns the next playable audio. The returned
  /// value is only useful when the user is in the audio player
  /// screen and so that the audio to move is the currently
  /// playable audio.
  Audio? deleteAudioFile({
    required AudioLearnAppViewType audioLearnAppViewType,
    required Audio audio,
  }) {
    Audio? nextAudio = _getNextSortFilteredNotFullyPlayedAudio(
      audioLearnAppViewType: audioLearnAppViewType,
      currentAudio: audio,
    );

    // delete the audio file from the audio playlist directory
    // and removes the audio from the its playlist playable audio list
    _audioDownloadVM.deleteAudioPhysicallyAndFromPlayableAudioListOnly(
        audio: audio);
    _remainingAudioDeletionExecution(
      audio: audio,
      audioLearnAppViewType: audioLearnAppViewType,
    );

    _setStateOfButtonsApplicableToAudio(
      selectedPlaylist: audio.enclosingPlaylist!,
    );

    notifyListeners();

    return nextAudio;
  }

  /// Method called when the user clicks on the 'delete audio
  /// from playlist aswell' menu item in the audio item menu button
  /// or in the audio player screen leading popup menu.
  ///
  /// This method deletes the audio from the playlist json file and
  /// deletes the audio mp3 file from the audio playlist directory.
  ///
  /// The method returns the next playable audio. The returned
  /// value is only useful when the user is in the audio player
  /// screen and so that the audio to move is the currently
  /// playable audio.
  ///
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  Audio? deleteAudioFromPlaylistAsWell({
    required AudioLearnAppViewType audioLearnAppViewType,
    required Audio audio,
  }) {
    Audio? nextAudio = _getNextSortFilteredNotFullyPlayedAudio(
      audioLearnAppViewType: audioLearnAppViewType,
      currentAudio: audio,
    );

    _audioDownloadVM.deleteAudioPhysicallyAndFromAllAudioLists(audio: audio);
    _remainingAudioDeletionExecution(
      audio: audio,
      audioLearnAppViewType: audioLearnAppViewType,
    );

    notifyListeners();

    return nextAudio;
  }

  /// Method called by deleteAudioFile() and deleteAudioFromPlaylistAsWell().
  void _remainingAudioDeletionExecution({
    required Audio audio,
    required AudioLearnAppViewType audioLearnAppViewType,
  }) {
    _removeAudioFromSortedFilteredPlayableAudioList(
      audioLearnAppViewType: audioLearnAppViewType,
      audio: audio,
    );

    _commentVM.deleteAllAudioComments(
      commentedAudio: audio,
    );

    // deleting the audio picture json file if it exists
    _pictureVM.deleteAudioPictureJsonFileIfExist(
      audio: audio,
    );
  }

  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  Audio? _removeAudioFromSortedFilteredPlayableAudioList({
    required AudioLearnAppViewType audioLearnAppViewType,
    required Audio audio,
  }) {
    if (_sortedFilteredSelectedPlaylistPlayableAudioLst != null) {
      Audio? nextAudio = _getNextSortFilteredNotFullyPlayedAudio(
        audioLearnAppViewType: audioLearnAppViewType,
        currentAudio: audio,
      );
      _sortedFilteredSelectedPlaylistPlayableAudioLst!
          .removeWhere((audioInList) => audioInList == audio);

      return nextAudio;
    }

    return null;
  }

  int _getSelectedPlaylistIndex() {
    for (int i = 0; i < _listOfSelectablePlaylists.length; i++) {
      if (_listOfSelectablePlaylists[i].isSelected) {
        return i;
      }
    }

    return -1;
  }

  void _setPlaylistButtonsStateIfOnePlaylistIsSelected({
    required Playlist selectedPlaylist,
  }) {
    if (_isPlaylistListExpanded) {
      _isButtonMovePlaylistEnabled = true;
    }

    if (selectedPlaylist.playlistType == PlaylistType.local) {
      _isButtonDownloadSelPlaylistsEnabled = false;
    } else {
      _isButtonDownloadSelPlaylistsEnabled = true;
    }

    _setStateOfButtonsApplicableToAudio(
      selectedPlaylist: selectedPlaylist,
    );
  }

  /// If the selected playlist is null or if it has no audio,
  /// then the buttons applicable to an audio are disabled.
  void _setStateOfButtonsApplicableToAudio({
    required Playlist? selectedPlaylist,
  }) {
    if (selectedPlaylist != null &&
        selectedPlaylist.playableAudioLst.isNotEmpty) {
      _areButtonsApplicableToAudioEnabled = true;
    } else {
      _areButtonsApplicableToAudioEnabled = false;
    }
  }

  void _disableAllButtonsIfNoPlaylistIsSelected() {
    _disableExpandedPaylistListButtons();
    _setStateOfButtonsApplicableToAudio(
      selectedPlaylist: null,
    );
  }

  /// If the selected playlist is local, then the download
  /// playlist audio button is disabled.
  ///
  /// If the selected playlist is remote, then the download
  /// playlist audio button is enabled.
  ///
  /// If no playlist is selected, then the download playlist
  /// audio button is disabled.
  ///
  /// Finally, the move up and down buttons are disabled.
  void _disableExpandedPaylistListButtons() {
    if (_isOnePlaylistSelected) {
      int selectedPlaylistIndex = _getSelectedPlaylistIndex();

      if (selectedPlaylistIndex == -1) {
        _isButtonDownloadSelPlaylistsEnabled = false;
        _isButtonMovePlaylistEnabled = false;

        return;
      }

      Playlist selectedPlaylist =
          _listOfSelectablePlaylists[selectedPlaylistIndex];
      if (selectedPlaylist.playlistType == PlaylistType.local) {
        // if the selected playlist is local, the download
        // playlist audio button is disabled
        _isButtonDownloadSelPlaylistsEnabled = false;
      } else {
        _isButtonDownloadSelPlaylistsEnabled = true;
      }
    } else {
      // if no playlist is selected, the download playlist
      // audio button is disabled
      _isButtonDownloadSelPlaylistsEnabled = false;
    }

    _isButtonMovePlaylistEnabled = false;
  }

  void moveItemUp(int index) {
    int newIndex = (index - 1 + _listOfSelectablePlaylists.length) %
        _listOfSelectablePlaylists.length;
    Playlist item = _listOfSelectablePlaylists.removeAt(index);
    _listOfSelectablePlaylists.insert(newIndex, item);

    notifyListeners();
  }

  void moveItemDown(int index) {
    int newIndex = (index + 1) % _listOfSelectablePlaylists.length;
    Playlist item = _listOfSelectablePlaylists.removeAt(index);
    _listOfSelectablePlaylists.insert(newIndex, item);

    notifyListeners();
  }

  /// If no sort/filter parameter is applyed to the playlist containing
  /// the audio, returns the audio contained in the playlist playableAudioLst
  /// which has been downloaded after the current audio and is not fully
  /// played.
  ///
  /// Otherwise, if sort and filter parameters were saved in the playlist
  /// json file, then the returned next not fully played audio is obtained
  /// from the sorted and filtered playlist playableAudioLst.
  Audio? getNextDownloadedOrSortFilteredNotFullyPlayedAudio({
    required AudioLearnAppViewType audioLearnAppViewType,
    required Audio currentAudio,
  }) {
    // If the current audio is not fully listened, null is returned.
    // This test is required, otherwise the method will be
    // executed so much time that the last downloaded audio
    // will be selected
    if (!currentAudio.wasFullyListened()) {
      return null;
    }

    return _getNextSortFilteredNotFullyPlayedAudio(
        audioLearnAppViewType: audioLearnAppViewType,
        currentAudio: currentAudio);
  }

  Audio? _getNextSortFilteredNotFullyPlayedAudio({
    required AudioLearnAppViewType audioLearnAppViewType,
    required Audio currentAudio,
  }) {
    // If sort and filter parameters were saved in the playlist json
    // file, then the audio list returned by
    // getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters()
    // is sorted and filtered. Otherwise, the returned audio list is the
    // full playable audio list of the selected playlist sorted by audio
    // download date descending (the default sorting).
    List<Audio> sortedAndFilteredPlayableAudioLst =
        getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
      audioLearnAppViewType: audioLearnAppViewType,
    );

    int currentAudioIndex = sortedAndFilteredPlayableAudioLst.indexWhere(
        (audio) => audio == currentAudio); // using Audio == operator

    if (currentAudioIndex == -1) {
      // the case if the sort and filter parameters contained
      // "Fully listened" unchecked and "Partially listened" checked.
      // In this case, the current audio is not in the
      // sortedAndFilteredPlayableAudioLst since it was fully listened.

      currentAudioIndex = _determineCurrentAudioIndexBeforeItWasFullyPlayed(
        currentAudio: currentAudio,
      );
    }

    if (currentAudio.enclosingPlaylist!.audioPlayingOrder ==
        AudioPlayingOrder.ascending) {
      if (currentAudioIndex == 0) {
        // means the current audio is the last downloaded audio
        // available in the playableAudioLst and so there is no
        // subsequently downloaded audio !
        return null;
      }

      for (int i = currentAudioIndex - 1; i >= 0; i--) {
        Audio audio = sortedAndFilteredPlayableAudioLst[i];
        if (audio.wasFullyListened()) {
          continue;
        } else {
          return audio;
        }
      }
    } else {
      // the audio playing order of the playlist containing the audio
      // is AudioPlayingOrder.descending
      int sortedAndFilteredPlayableAudioNumber =
          sortedAndFilteredPlayableAudioLst.length - 1;

      if (currentAudioIndex == sortedAndFilteredPlayableAudioNumber) {
        // means the current audio is the last listenable audio available
        // in the sortedAndFilteredPlayableAudioLst and so there is no
        // subsequently listenable audio !
        return null;
      }

      for (int i = currentAudioIndex + 1;
          i <= sortedAndFilteredPlayableAudioNumber;
          i++) {
        Audio audio = sortedAndFilteredPlayableAudioLst[i];
        if (audio.wasFullyListened()) {
          continue;
        } else {
          return audio;
        }
      }
    }

    return null;
  }

  /// Since the current audio is not in the previously obtained
  /// sorted and filtered playable audio list since it was fully
  /// listened, the current audio must be set to not fully played
  /// and the sort and filter audio list must be re-obtained.
  int _determineCurrentAudioIndexBeforeItWasFullyPlayed({
    required Audio currentAudio,
  }) {
    // In order to obtain the current audio index before the audio
    // was fully listened, we decrement the audio position by 10
    // seconds and we then search again the sorted and filtered audio.
    currentAudio.audioPositionSeconds = currentAudio.audioPositionSeconds - 10;
    List<Audio> sortedAndFilteredPlayableAudioLstWithCurrentAudio =
        getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
      audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
    );

    // obtaining the current audio index before the audio was fully
    // listened ...
    int currentAudioIndex =
        sortedAndFilteredPlayableAudioLstWithCurrentAudio.indexWhere(
            (audio) => audio == currentAudio); // using Audio == operator

    // restoring the current audio position to fully listened
    currentAudio.audioPositionSeconds = currentAudio.audioPositionSeconds + 10;

    return currentAudioIndex;
  }

  /// Returns the audio contained in the playableAudioLst which
  /// has been downloaded right before the current audio.
  Audio? getPreviouslyDownloadedOrSortFilteredAudio({
    required AudioLearnAppViewType audioLearnAppViewType,
    required Audio currentAudio,
  }) {
    // If sort and filter parameters were saved in the playlist json
    // file, then the audio list returned by
    // getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters()
    // is sorted and filtered. Otherwise, the returned audio list is the
    // full playable audio list of the selected playlist sorted by audio
    // download date descending (the de3fault sorting).
    List<Audio> sortedAndFilteredPlayableAudioLst =
        getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
      audioLearnAppViewType: audioLearnAppViewType,
    );

    int currentAudioIndex = sortedAndFilteredPlayableAudioLst.indexWhere(
        (audio) => audio == currentAudio); // using Audio == operator

    if (currentAudioIndex == -1) {
      // the case if the sort and filter parameters contained
      // "Fully listened" unchecked and "Partially listened" checked.
      // In this case, the current audio is not in the
      // sortedAndFilteredPlayableAudioLst since it was fully listened.

      currentAudioIndex = _determineCurrentAudioIndexBeforeItWasFullyPlayed(
        currentAudio: currentAudio,
      );
    }

    if (currentAudio.enclosingPlaylist!.audioPlayingOrder ==
        AudioPlayingOrder.descending) {
      if (currentAudioIndex == 0) {
        // means the current audio is the last downloaded audio
        // available in the playableAudioLst and so there is no
        // subsequently downloaded audio !
        return null;
      }

      return sortedAndFilteredPlayableAudioLst[currentAudioIndex - 1];
    } else {
      // the audio playing order of the playlist containing the audio
      // is AudioPlayingOrder.ascending
      int sortedAndFilteredPlayableAudioNumber =
          sortedAndFilteredPlayableAudioLst.length - 1;

      if (currentAudioIndex == sortedAndFilteredPlayableAudioNumber) {
        // means the current audio is the last listenable audio available
        // in the sortedAndFilteredPlayableAudioLst and so there is no
        // subsequently listenable audio !
        return null;
      }

      return sortedAndFilteredPlayableAudioLst[currentAudioIndex + 1];
    }
  }

  /// This method is called when the user chooses to change the
  /// playback speed in the application settings dialog and choose
  /// to apply this modification to the existing playlists and/or to the
  /// already downloaded audio contained in the playlists.
  ///
  /// This method updates the playlists audio play speed or/and
  /// the audio play speed of the playable audio contained in
  /// the playlists.
  ///
  /// Updating the playlists audio play speed only implies that
  /// the next downloaded audio's of this playlist will be set
  /// to the audioPlaySpeed value.
  ///
  /// The method modifies the playlist default play speed in the
  /// application settings file and saves the file.
  void updateExistingPlaylistsAndOrAlreadyDownloadedAudioPlaySpeed({
    required double audioPlaySpeed,
    required bool applyAudioPlaySpeedToExistingPlaylists,
    required bool applyAudioPlaySpeedToAlreadyDownloadedAudio,
  }) {
    for (Playlist playlist in _listOfSelectablePlaylists) {
      // updating the playlist audio play speed. This will imply the
      // next downloaded audio of this playlist.
      if (applyAudioPlaySpeedToExistingPlaylists) {
        playlist.audioPlaySpeed = audioPlaySpeed;
      }

      if (applyAudioPlaySpeedToAlreadyDownloadedAudio) {
        // updating the audio play speed of the playable audio
        // contained in the playlist.
        playlist.setAudioPlaySpeedToAllPlayableAudios(
          audioPlaySpeed: audioPlaySpeed,
        );
      }

      // saving the playlist in its json file
      JsonDataService.saveToFile(
        model: playlist,
        path: playlist.getPlaylistDownloadFilePathName(),
      );
    }

    // Updating the application settings file with the new default
    // audio play speed (this play speed will be applied to the next
    // created playlist).
    _settingsDataService.set(
        settingType: SettingType.playlists,
        settingSubType: Playlists.playSpeed,
        value: audioPlaySpeed);

    _settingsDataService.saveSettings();
  }

  void updateIndividualPlaylistAndOrAlreadyDownloadedAudioPlaySpeed({
    required double audioPlaySpeed,
    required Playlist playlist,
    required bool applyAudioPlaySpeedToPlayableAudios,
  }) {
    // updating the playlist audio play speed. This will imply the
    // next downloaded audio of this playlist.
    playlist.audioPlaySpeed = audioPlaySpeed;

    if (applyAudioPlaySpeedToPlayableAudios) {
      // updating the audio play speed of the playable audio
      // contained in the playlist.
      playlist.setAudioPlaySpeedToAllPlayableAudios(
        audioPlaySpeed: audioPlaySpeed,
      );
    }

    // saving the playlist in its json file
    JsonDataService.saveToFile(
      model: playlist,
      path: playlist.getPlaylistDownloadFilePathName(),
    );
  }

  /// Method called when the user clicks on the Ascending/Descending
  /// icon button in the audio playable list dialog.
  void invertSelectedPlaylistAudioPlayingOrder() {
    Playlist selectedPlaylist = getSelectedPlaylists()[0];

    if (selectedPlaylist.audioPlayingOrder == AudioPlayingOrder.ascending) {
      selectedPlaylist.audioPlayingOrder = AudioPlayingOrder.descending;
    } else {
      selectedPlaylist.audioPlayingOrder = AudioPlayingOrder.ascending;
    }

    JsonDataService.saveToFile(
      model: selectedPlaylist,
      path: selectedPlaylist.getPlaylistDownloadFilePathName(),
    );

    notifyListeners();
  }

  /// Method called when the user opens the audio playable list dialog.
  /// This method returns the name of the sort and filter parameters
  /// which has been saved in the playlist json file.
  ///
  /// If no sort filter parameters were saved in the playlist json file,
  /// then the translated name of the default sort filter parameter
  /// is returned.
  String getAudioPlayerViewSortFilterName({
    required String translatedDefaultSFparmsName,
  }) {
    Playlist selectedPlaylist = getSelectedPlaylists()[0];

    // Necessary for displaying the SF parms name of the SF parms
    // created in the audio player view.
    //
    // When the user clicked on the 'Save sort/filter options to
    // playlist' menu item available in the playlist download
    // dialog, then the previously applied SF parms name is replaced
    // in _playlistAudioSFparmsNamesForAudioPlayerViewMap by the
    // selected SF parms name.
    String audioSortFilterParmsName =
        _playlistAudioSFparmsNamesForAudioPlayerViewMap[
                selectedPlaylist.title] ??
            '';

    if (audioSortFilterParmsName.isEmpty) {
      audioSortFilterParmsName =
          selectedPlaylist.audioSortFilterParmsNameForAudioPlayerView;
    }

    if (audioSortFilterParmsName.isEmpty) {
      audioSortFilterParmsName = translatedDefaultSFparmsName;
    } else {
      if (_settingsDataService.namedAudioSortFilterParametersMap
          .containsKey(audioSortFilterParmsName)) {
        return audioSortFilterParmsName;
      } else {
        audioSortFilterParmsName = translatedDefaultSFparmsName;
      }
    }

    return audioSortFilterParmsName;
  }

  /// Method called when the user opens PlaylistAddRemoveSortFilterOptionsDialog.
  /// The passed parameter [selectedSortFilterParmsName] contains the name of
  /// the sort filter parameters selected by the user in the dropdown button.
  ///
  /// The returned list content is
  /// [
  ///   the sort and filter parameters name applied to the playlist download
  ///   view or/and to the audio player view or uniquely to the audio player
  ///   view,
  ///   is audioSortFilterParmsName applied to playlist download view,
  ///   is audioSortFilterParmsName applied to audio player view,
  /// ]
  List<dynamic> getSortFilterParmsNameApplicationValuesToCurrentPlaylist({
    required String selectedSortFilterParmsName,
  }) {
    // String selectedSortFilterParmsName = _uniqueSelectedPlaylist!
    //     .audioSortFilterParmsNameForPlaylistDownloadView;
    bool isAudioSortFilterParmsNameAppliedToPlaylistDownloadView = false;
    bool isAudioSortFilterParmsNameAppliedToAudioPlayerView = false;

    if (_uniqueSelectedPlaylist!
            .audioSortFilterParmsNameForPlaylistDownloadView ==
        selectedSortFilterParmsName) {
      isAudioSortFilterParmsNameAppliedToPlaylistDownloadView = true;
    }

    if (_uniqueSelectedPlaylist!.audioSortFilterParmsNameForAudioPlayerView ==
        selectedSortFilterParmsName) {
      isAudioSortFilterParmsNameAppliedToAudioPlayerView = true;
    }

    if (!isAudioSortFilterParmsNameAppliedToAudioPlayerView &&
        !isAudioSortFilterParmsNameAppliedToPlaylistDownloadView) {
      selectedSortFilterParmsName = '';
    }

    final List<dynamic> returnedResults = [
      selectedSortFilterParmsName,
      isAudioSortFilterParmsNameAppliedToPlaylistDownloadView,
      isAudioSortFilterParmsNameAppliedToAudioPlayerView,
    ];

    return returnedResults;
  }

  SortingOption getAppliedSortingOption() {
    if (_audioSortFilterParameters != null) {
      if (_audioSortFilterParameters!.uploadDateStartRange != null &&
          _audioSortFilterParameters!.uploadDateEndRange != null) {
        // returning the video upload date sorting option enables the
        // audio list item widget to display the video upload date
        // in its sub title, the same if the displayed audio are sorted
        // by video upload date.
        return SortingOption.videoUploadDate;
      }

      return _audioSortFilterParameters!.selectedSortItemLst[0].sortingOption;
    } else {
      return SortingOption.audioDownloadDate;
    }
  }

  /// This method is called when the user closes the playlist comment list dialog.
  /// It is used to undo the change made to the playlist current audio index
  /// as well as the position of the listened comments audio.
  ///
  /// Using this method located in the PlaylistListVM is necessary in order to
  /// notify the listeners of the undone modification of the audio position.
  void updateCurrentOrPastPlayableAudio({
    required Audio audioCopy,
    required int previousAudioIndex,
  }) {
    _uniqueSelectedPlaylist!.updateCurrentOrPastPlayableAudio(
      audioCopy: audioCopy,
      previousAudioIndex: previousAudioIndex,
    );

    notifyListeners();
  }

  /// This method simply notifies the listeners of the PlaylistListVM
  /// in order to update the displayed playable audio list.
  void updateCurrentAudio() {
    notifyListeners();
  }

  /// Method called when the user clicks on the 'Save Playlist, Comments, Pictures
  /// and Settings to Zip File' menu item located in the appbar leading popup menu.
  ///
  /// Returns the saved zip file path name, '' if the playlists source dir or the
  /// zip save to target dir do not exist. The returned value is only used in
  /// the playlistListVM unit test.
  Future<String> savePlaylistsCommentPictureAndSettingsJsonFilesToZip({
    required String targetDirectoryPath,
    required bool addPictureJpgFilesToZip,
  }) async {
    List<dynamic> returnedResults = await _saveAllJsonFilesToZip(
      targetDir: targetDirectoryPath,
      addPictureJpgFilesToZip: addPictureJpgFilesToZip,
    );

    if (returnedResults.isEmpty) {
      // The case if the target directory does not exist or is invalid.
      // In this situation, since the passed savedZipFilePathName is empty,
      // a warning message is displayed instead of a confirmation message.
      _warningMessageVM.confirmSavingToZip(
        zipFilePathName: '',
        savedPictureNumber: 0,
      );

      return '';
    }

    int savedPictureNumber = returnedResults[0];

    if (!addPictureJpgFilesToZip) {
      // Saving the picture jpg files to the 'pictures' directory
      // located in the target directory where the zip file is saved.
      savedPictureNumber =
          _pictureVM.saveUnexistingPictureJpgFilesToTargetDirectory(
        targetDirectoryPath: targetDirectoryPath,
      );
    }

    String savedZipFilePathName = returnedResults[1] as String;

    _warningMessageVM.confirmSavingToZip(
        zipFilePathName: savedZipFilePathName,
        savedPictureNumber: savedPictureNumber, // if the picture number is > 0,
        // then a picture number sentence is added to the confirmation message.
        addPictureJpgFilesToZip: addPictureJpgFilesToZip);

    return savedZipFilePathName;
  }

  /// Returns a dynamic list containing the number of picture jpg files added to the zip and
  /// the saved zip file path name. An empty list is returned if the playlists source dir or the
  /// target dir in which to save the zip does not exist.
  Future<List<dynamic>> _saveAllJsonFilesToZip({
    required String targetDir,
    required bool addPictureJpgFilesToZip,
  }) async {
    List<dynamic> returnedResults = [];
    String playlistsRootPath = _settingsDataService.get(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath);
    String applicationPath = _settingsDataService.get(
      settingType: SettingType.dataLocation,
      settingSubType: DataLocation.appSettingsPath,
    );

    Directory sourceDir = Directory(playlistsRootPath);

    if (!sourceDir.existsSync() || targetDir == '/') {
      return returnedResults; // returning an empty list
    }

    // Create a zip encoder
    final archive = Archive();

    // Traverse the source directory and find matching files
    await for (FileSystemEntity entity
        in sourceDir.list(recursive: true, followLinks: false)) {
      if (entity is File && path.extension(entity.path) == '.json') {
        String relativePath = path.relative(entity.path, from: applicationPath);

        // Add the file to the archive, preserving the relative path
        List<int> fileBytes = await entity.readAsBytes();
        archive.addFile(ArchiveFile(
          relativePath,
          fileBytes.length,
          fileBytes,
        ));
      }
    }

    if (applicationPath != playlistsRootPath) {
      // Path to the settings.json file
      File settingsFile = File(path.join(applicationPath, kSettingsFileName));

      // Check if settings.json exists before attempting to add it
      if (settingsFile.existsSync()) {
        // Get the relative path of the settings.json file
        String settingsRelativePath = kSettingsFileName;

        // Read the file and add it to the archive
        List<int> settingsBytes = await settingsFile.readAsBytes();
        archive.addFile(ArchiveFile(
          settingsRelativePath,
          settingsBytes.length,
          settingsBytes,
        ));
      }
    }

    // Now, adding the pictures/pictureAudioMap.json file to the archive
    File pictureAudioMapFile = File(
        path.join(applicationPath, kPictureDirName, kPictureAudioMapFileName));
    if (pictureAudioMapFile.existsSync()) {
      String pictureAudioMapRelativePath =
          path.join(kPictureDirName, kPictureAudioMapFileName);

      // Read the file and add it to the archive
      List<int> pictureAudioMapBytes = await pictureAudioMapFile.readAsBytes();

      archive.addFile(ArchiveFile(
        pictureAudioMapRelativePath,
        pictureAudioMapBytes.length,
        pictureAudioMapBytes,
      ));

      if (addPictureJpgFilesToZip) {
        // Get the list of JPG files in the application pictures
        // directory
        String applicationPicturePath =
            '$applicationPath${path.separator}$kPictureDirName';

        List<String> pictureJpgPathFileNamesLst =
            DirUtil.listPathFileNamesInDir(
          directoryPath: applicationPicturePath,
          fileExtension: 'jpg',
        );

        int addedPictureJpgNumberToZip = 0;

        // Add all the JPG files to the archive in the pictures directory
        for (String pictureJpgPathFileName in pictureJpgPathFileNamesLst) {
          // Extract the filename from the full path
          String pictureFileName = DirUtil.getFileNameFromPathFileName(
            pathFileName: pictureJpgPathFileName,
          );

          // Read the JPG file
          File pictureFile = File(pictureJpgPathFileName);

          if (pictureFile.existsSync()) {
            List<int> pictureBytes = await pictureFile.readAsBytes();

            // Add the JPG file to the archive in the pictures directory
            String pictureRelativePath =
                path.join(kPictureDirName, pictureFileName);

            archive.addFile(ArchiveFile(
              pictureRelativePath,
              pictureBytes.length,
              pictureBytes,
            ));

            addedPictureJpgNumberToZip++;
          }
        }

        // returnedResults[1] contains the number of picture jpg files
        returnedResults.add(addedPictureJpgNumberToZip);
      } else {
        returnedResults.add(0);
      }
    } else {
      returnedResults.add(0);
    }

    // Save the archive to a zip file in the target directory
    String zipFileName =
        "audioLearn_${yearMonthDayDateTimeFormatForFileName.format(DateTime.now())}.zip";

    String zipFilePathName = path.join(targetDir, zipFileName);

    File zipFile = File(zipFilePathName);
    zipFile.writeAsBytesSync(ZipEncoder().encode(archive), flush: true);

    returnedResults.add(zipFilePathName);

    return returnedResults;
  }

  /// Method called when the user clicks on the 'Save Playlist, Comments, Pictures
  /// Json files to Zip File' playlist menu item.
  ///
  /// Contrary to the savePlaylistsCommentPictureAndSettingsJsonFilesToZip()
  /// method, this method add as well to the zip file the playlist picture JPG files.
  ///
  /// Returns the saved zip file path name, '' if the  target dir in which to save
  /// the zip does not exist.
  Future<String> saveUniquePlaylistCommentAndPictureJsonFilesToZip({
    required Playlist playlist,
    required String targetDir,
  }) async {
    String applicationPath = _settingsDataService.get(
      settingType: SettingType.dataLocation,
      settingSubType: DataLocation.appSettingsPath,
    );

    Directory sourceDir = Directory(playlist.downloadPath);

    if (!sourceDir.existsSync() || targetDir == '/') {
      return '';
    }

    // Create a zip encoder
    final archive = Archive();

    // Traverse the source directory and find matching files
    await for (FileSystemEntity entity
        in sourceDir.list(recursive: true, followLinks: false)) {
      if (entity is File && path.extension(entity.path) == '.json') {
        String relativePath = path.relative(entity.path, from: applicationPath);
        // Add the file to the archive, preserving the relative path
        List<int> fileBytes = await entity.readAsBytes();
        archive.addFile(ArchiveFile(
          relativePath,
          fileBytes.length,
          fileBytes,
        ));
      }
    }

    final String playlistTitle = playlist.title;

    // Obtain the playlist picture audio map from the
    // application picture audio map json file.
    Map<String, List<String>> playlistPictureAudioMap = _pictureVM
        .createPictureAudioMapForPlaylistFromApplicationPictureAudioMap(
      audioPlaylistTitle: playlistTitle,
    );

    // Convert the map to JSON string
    String jsonString = json.encode(playlistPictureAudioMap);

    // Convert the JSON string to bytes (List<int>)
    List<int> pictureAudioMapBytes = utf8.encode(jsonString);

    // Create the relative path for the pictureAudioMap file
    // within the archive
    String pictureAudioMapRelativePath =
        path.join(kPictureDirName, kPictureAudioMapFileName);

    // Add the file to the archive
    archive.addFile(ArchiveFile(
      pictureAudioMapRelativePath,
      pictureAudioMapBytes.length,
      pictureAudioMapBytes,
    ));

    // Get the list of JPG files in the application pictures
    // directory
    String applicationPicturePath = DirUtil.getApplicationPicturePath(
      isTest: _settingsDataService.isTest,
    );

    List<String> pictureJpgPathFileNamesLst = DirUtil.listPathFileNamesInDir(
      directoryPath: applicationPicturePath,
      fileExtension: 'jpg',
    );

    // Only add to the archive the JPG files that are associated with
    // this playlist
    int savedPictureNumber = 0;

    for (String pictureJpgPathFileName in pictureJpgPathFileNamesLst) {
      // Extract the filename from the full path
      String pictureFileName = DirUtil.getFileNameFromPathFileName(
        pathFileName: pictureJpgPathFileName,
      );

      // Check if this picture is associated with the playlist in
      // its picture-audio map
      if (playlistPictureAudioMap.containsKey(pictureFileName)) {
        // Read the JPG file
        File pictureFile = File(pictureJpgPathFileName);

        if (pictureFile.existsSync()) {
          List<int> pictureBytes = await pictureFile.readAsBytes();

          // Add the JPG file to the archive in the pictures directory
          String pictureRelativePath =
              path.join(kPictureDirName, pictureFileName);
          archive.addFile(ArchiveFile(
            pictureRelativePath,
            pictureBytes.length,
            pictureBytes,
          ));

          savedPictureNumber++;
        }
      }
    }

    // Save the archive to a zip file in the target directory
    String zipFileName = "$playlistTitle.zip";
    String savedZipFilePathName = path.join(targetDir, zipFileName);
    File zipFile = File(savedZipFilePathName);
    zipFile.writeAsBytesSync(ZipEncoder().encode(archive), flush: true);

    _warningMessageVM.confirmSavingToZip(
        zipFilePathName: savedZipFilePathName,
        savedPictureNumber: savedPictureNumber, // if the picture number is > 0,
        // then a picture number sentence is added to the confirmation message.
        uniquePlaylistIsSaved: true);
    return savedZipFilePathName;
  }

  /// This method saves the audio MP3 files located in the passed playlist(s) which were downloaded
  /// at or after the passed [fromAudioDownloadDateTime] in ZIP file(s) located in the passed
  /// [targetDirStrOnWindows].
  ///
  /// Since creating a MP3 ZIP file on an Android device can't exceed a certain size, the passed
  /// [zipFileSizeLimitInMb] parameter value is used to limit the size of each created ZIP file.
  /// If the total size exceeds this limit, multiple ZIP files will be created with sequential
  /// numbering. Also, restoring a MP3 ZIP file on an Android device is limited to a certain size.
  /// This is the second reason for the [zipFileSizeLimitInMb] parameter.
  ///
  /// The returned list contains
  /// [
  ///  the base zip file path name (without part number),
  ///  the number of saved audio files,
  ///  the total unzipped size of the saved audio files in bytes,
  ///  the total duration of the saved audio files,
  ///  the total duration of saving the audio files to zip,
  ///  the real quantity of bytes saved to zip in one second,
  ///  the number of created zip files,
  ///  the list of excluded files String
  /// ]
  Future<List<dynamic>> savePlaylistsAudioMp3FilesToZip({
    required List<Playlist> listOfPlaylists,
    String targetDirStrOnWindows = '',
    required DateTime fromAudioDownloadDateTime,
    required double zipFileSizeLimitInMb,
    bool uniquePlaylistIsSaved = false,
  }) async {
    if (targetDirStrOnWindows == '/') {
      return [];
    }

    List<dynamic> savedMp3InfoLst =
        await _saveAllAudioMp3FilesToZipWithZipSizeLimit(
      listOfPlaylists: listOfPlaylists,
      targetDirStrOnWindows: targetDirStrOnWindows,
      fromAudioDownloadDateTime: fromAudioDownloadDateTime,
      zipFileSizeLimitInMb: zipFileSizeLimitInMb,
      uniquePlaylistIsSaved: uniquePlaylistIsSaved,
    );

    DateFormatVM dateFormatVM = DateFormatVM(
      settingsDataService: _settingsDataService,
    );

    if (savedMp3InfoLst.isEmpty) {
      // The case if no audio file was downloaded at or after the
      // passed fromAudioDownloadDateTime. In this case, a warning
      // message is displayed instead of a confirmation message.

      const Duration zeroDuration = Duration(seconds: 0);

      _warningMessageVM.confirmSavingAudioMp3ToZip(
        zipFilePathName: '',
        fromAudioDownloadDateTime:
            dateFormatVM.formatDateTime(fromAudioDownloadDateTime),
        savedAudioMp3Number: 0,
        savedTotalAudioFileSize: 0,
        savedTotalAudioDuration: zeroDuration,
        savingAudioToZipOperationDuration: zeroDuration,
        realNumberOfBytesSavedToZipPerSecond: 0,
        uniquePlaylistIsSaved: uniquePlaylistIsSaved,
        numberOfCreatedZipFiles: 0,
        excludedTooLargeAudioFilesLst: [],
      );

      return savedMp3InfoLst;
    }

    if (!Platform.isAndroid) {
      _warningMessageVM.confirmSavingAudioMp3ToZip(
        zipFilePathName: savedMp3InfoLst[0],
        fromAudioDownloadDateTime:
            dateFormatVM.formatDateTime(fromAudioDownloadDateTime),
        savedAudioMp3Number: savedMp3InfoLst[1],
        savedTotalAudioFileSize: savedMp3InfoLst[2],
        savedTotalAudioDuration: savedMp3InfoLst[3],
        savingAudioToZipOperationDuration: savedMp3InfoLst[4],
        realNumberOfBytesSavedToZipPerSecond: savedMp3InfoLst[5],
        uniquePlaylistIsSaved: uniquePlaylistIsSaved,
        numberOfCreatedZipFiles: savedMp3InfoLst[6], // New parameter
        excludedTooLargeAudioFilesLst: savedMp3InfoLst[7],
      );
    }

    return savedMp3InfoLst;
  }

  /// Returns the list described in the main method or [] if no audio file was downloaded at or
  /// after the passed [fromAudioDownloadDateTime].
  ///
  /// The returned list contains
  /// [
  ///  the base zip file path name (without part number),
  ///  the number of saved audio files,
  ///  the total unzipped size of the saved audio files in bytes,
  ///  the total duration of the saved audio files,
  ///  the total duration of saving the audio files to zip,
  ///  the real quantity of bytes saved to zip in one second,
  ///  the number of created zip files,
  ///  the list of excluded files String
  /// ]
  Future<List<dynamic>> _saveAllAudioMp3FilesToZipWithZipSizeLimit({
    required List<Playlist> listOfPlaylists,
    required String targetDirStrOnWindows,
    required DateTime fromAudioDownloadDateTime,
    required double zipFileSizeLimitInMb,
    required bool uniquePlaylistIsSaved,
  }) async {
    int savedAudioNumber = 0;
    int savedAudioFileSize = 0;
    Duration savedAudioDuration = Duration.zero;
    DateTime oldestAudioSavedToZipDownloadDateTime = DateTime.now();

    // Convert MB limit to bytes
    double zipFileSizeLimitInBytes = zipFileSizeLimitInMb * 1000000;

    // Collect all audio files to be saved
    List<AudioFileInfo> audioFilesToSave = [];

    String playlistTitle;

    if (uniquePlaylistIsSaved) {
      playlistTitle = listOfPlaylists[0].title;
      _audioMp3SaveUniquePlaylistName = playlistTitle;
    } else {
      playlistTitle = 'audioLearn';
      _audioMp3SaveUniquePlaylistName = '';
    }

    final stopwatch = Stopwatch()..start();

    // Start the timer and saving state before processing files
    _isSavingMp3 = true;
    notifyListeners();

    // Determine the actual target directory early
    String actualTargetDir;

    if (Platform.isAndroid) {
      Directory? externalDir =
          await getExternalStorageDirectory(); // Method from path_provider package
      if (externalDir != null) {
        Directory mp3Dir =
            Directory('${externalDir.path}/downloads/AudioLearn');
        if (!await mp3Dir.exists()) {
          await mp3Dir.create(recursive: true);
        }
        actualTargetDir = mp3Dir.path;
      } else {
        throw Exception('Could not access external storage');
      }
    } else {
      actualTargetDir = targetDirStrOnWindows;
    }

    // Collect all audio files that need to be saved (WITHOUT loading them into memory)
    for (Playlist playlist in listOfPlaylists) {
      Directory playlistDir = Directory(playlist.downloadPath);
      if (!playlistDir.existsSync()) {
        continue;
      }

      List<Audio> filteredAudioLst = playlist.playableAudioLst.where((audio) {
        // Include downloaded and imported audios based on download date
        if (audio.audioType == AudioType.downloaded ||
            audio.audioType == AudioType.imported) {
          return audio.audioDownloadDateTime
              .isAtOrAfter(fromAudioDownloadDateTime);
        }

        // Include converted audios based on most recent comment creation date
        if (audio.audioType == AudioType.textToSpeech) {
          // This enables to put the mp3 of a modified text to speech audio in
          // a mp3 zip if download date is before or at last created comment
          // date which is the date of the last modification of the text to
          // speech audio.

          // Load comments for this audio
          List<Comment> comments = _commentVM.loadAudioComments(audio: audio);

          if (comments.isEmpty) {
            return audio.audioDownloadDateTime.isAtOrAfter(
                fromAudioDownloadDateTime); // No comments, so use the
            // audio download date to decide the mp3 inclusion. This date is the
            // text to speech audio creation date. This avoids to exclude the text
            // to speech audio mp3 if its created comment was deleted.
          }

          // Find the most recent comment modification date
          DateTime mostRecentCommentDate = comments
              .map((comment) => comment.lastUpdateDateTime)
              .reduce((a, b) => a.isAfter(b) ? a : b);

          return mostRecentCommentDate.isAtOrAfter(fromAudioDownloadDateTime);
        } else {
          return false; // Exclude other audio types
        }
      }).toList();

      for (Audio audio in filteredAudioLst) {
        File audioFile = File(audio.filePathName);
        if (audioFile.existsSync()) {
          String relativePath = path.join(
            kImposedPlaylistsSubDirName,
            playlist.title,
            audio.audioFileName,
          );

          audioFilesToSave.add(
            AudioFileInfo(
              audio: audio,
              audioFile: audioFile,
              relativePath: relativePath,
              playlist: playlist,
            ),
          );

          savedAudioNumber++;
          savedAudioFileSize += audio.audioFileSize;
          savedAudioDuration += audio.audioDuration;

          if (audio.audioDownloadDateTime
              .isBefore(oldestAudioSavedToZipDownloadDateTime)) {
            oldestAudioSavedToZipDownloadDateTime = audio.audioDownloadDateTime;
          }
        }
      }
    }

    if (audioFilesToSave.isEmpty) {
      _isSavingMp3 = false;
      notifyListeners();
      return [];
    }

    // Create ZIP files with size limit using streaming approach
    _numberOfCreatedZipFiles = 0;

    if (oldestAudioSavedToZipDownloadDateTime
        .isBefore(fromAudioDownloadDateTime)) {
      // The case if the audio is a text to speech audio which was
      // created before the fromAudioDownloadDateTime but modified
      // at or after this date and so its mp3 must be saved to zip.
      oldestAudioSavedToZipDownloadDateTime = fromAudioDownloadDateTime;
    }

    // If Unique playlist is saved, use its title in the base zip file
    // name. Otherwise, playlistTitle == 'audioLearn'.
    String baseZipFileName =
        "${playlistTitle}_mp3_from_${yearMonthDayDateTimeFormatForFileName.format(oldestAudioSavedToZipDownloadDateTime)}_on_${yearMonthDayDateTimeFormatForFileName.format(DateTime.now())}";

    List<AudioFileInfo> currentBatch = [];
    int currentBatchSize = 0;
    List<String> excludedTooLargeAudioFilesLst = [];
    List<dynamic> excludedTooLargeAudioFilesValueLst = [
      0, // excluded files total size in bytes
      Duration(seconds: 0), // excluded files total duration
    ];
    List<dynamic> resultLst = [];

    for (AudioFileInfo audioInfo in audioFilesToSave) {
      // Check if adding this file would exceed the size limit
      // SECTION 1: When saving current batch
      if (currentBatchSize + audioInfo.audio.audioFileSize >
              zipFileSizeLimitInBytes &&
          currentBatch.isNotEmpty) {
        // FIXED: Increment BEFORE calling _saveArchiveBatchToFile
        _numberOfCreatedZipFiles++;

        // Save current batch
        resultLst = await _saveArchiveBatchToFile(
          audioBatch: currentBatch,
          zipFileSizeLimitInBytes: zipFileSizeLimitInBytes,
          targetDir: actualTargetDir,
          baseFileName: baseZipFileName,
          partNumber: _numberOfCreatedZipFiles, // Now correctly incremented
          totalParts: _calculateTotalParts(
            audioFileInfoLst: audioFilesToSave,
            sizeLimitInBytes: zipFileSizeLimitInBytes,
          ),
        );

        if (resultLst[0] == false) {
          // If no files were saved, reduce the count of created zip files
          _numberOfCreatedZipFiles--;
        }

        // If files were saved, add the excluded files to the list
        excludedTooLargeAudioFilesLst.addAll(
          resultLst[1],
        );
        excludedTooLargeAudioFilesValueLst[0] +=
            resultLst[2][0]; // Accumulate excluded files size in MB
        excludedTooLargeAudioFilesValueLst[1] +=
            resultLst[2][1]; // Accumulate excluded files duration

        // Clear memory and start new batch
        currentBatch.clear();
        currentBatchSize = 0;

        // Force garbage collection
        await Future.delayed(Duration(milliseconds: 100));
      }

      currentBatch.add(audioInfo);
      currentBatchSize += audioInfo.audio.audioFileSize;
    }

    // SECTION 2: When saving the last batch
    // Save the last batch if it has files
    if (currentBatch.isNotEmpty) {
      // FIXED: Increment BEFORE calling _saveArchiveBatchToFile
      _numberOfCreatedZipFiles++;

      resultLst = await _saveArchiveBatchToFile(
        audioBatch: currentBatch,
        zipFileSizeLimitInBytes: zipFileSizeLimitInBytes,
        targetDir: actualTargetDir,
        baseFileName: baseZipFileName,
        partNumber: _numberOfCreatedZipFiles, // Now correctly incremented
        totalParts: _calculateTotalParts(
          audioFileInfoLst: audioFilesToSave,
          sizeLimitInBytes: zipFileSizeLimitInBytes,
        ),
      );

      if (resultLst[0] == false) {
        // If no files were saved, reduce the count of created zip files
        _numberOfCreatedZipFiles--;
      }

      // If files were saved, add the excluded files to the list
      excludedTooLargeAudioFilesLst.addAll(
        resultLst[1],
      );
      excludedTooLargeAudioFilesValueLst[0] +=
          resultLst[2][0]; // Accumulate excluded files size in MB
      excludedTooLargeAudioFilesValueLst[1] +=
          resultLst[2][1]; // Accumulate excluded files duration
    }

    // Rename single file if needed
    if (_numberOfCreatedZipFiles == 1) {
      String originalPath =
          path.join(actualTargetDir, "${baseZipFileName}_part1.zip");
      String newPath = path.join(actualTargetDir, "$baseZipFileName.zip");
      File originalFile = File(originalPath);

      if (await originalFile.exists()) {
        await originalFile.rename(newPath);
      }
    }

    stopwatch.stop();
    Duration savingAudioToZipDuration = stopwatch.elapsed;
    int realSavingAudioToZipBytesPerSecond =
        ((savedAudioFileSize / savingAudioToZipDuration.inMicroseconds) *
                1000000)
            .round();

    _isSavingMp3 = false;
    notifyListeners();

    // FIXED: Use actualTargetDir instead of targetDirStr for final path
    String finalZipPathStr;

    if (_numberOfCreatedZipFiles > 1) {
      finalZipPathStr = path.join(actualTargetDir,
          "${baseZipFileName}_part 1 to $_numberOfCreatedZipFiles.zip");
    } else {
      finalZipPathStr = path.join(actualTargetDir, "$baseZipFileName.zip");
    }

    return [
      finalZipPathStr,
      savedAudioNumber - excludedTooLargeAudioFilesLst.length,
      savedAudioFileSize - excludedTooLargeAudioFilesValueLst[0],
      savedAudioDuration - excludedTooLargeAudioFilesValueLst[1],
      savingAudioToZipDuration,
      realSavingAudioToZipBytesPerSecond,
      _numberOfCreatedZipFiles,
      excludedTooLargeAudioFilesLst, // Return the list of excluded files
    ];
  }

  /// The returned list contains
  /// [
  ///   wasZipFileCreated,
  ///   excludedTooLargeAudioFilesLst,
  ///   excludedTooLargeAudioFilesValueLst, contains
  ///      [
  ///         excluded files total size in bytes,
  ///         excluded files total duration,
  ///      ]
  /// ]
  Future<List<dynamic>> _saveArchiveBatchToFile({
    required List<AudioFileInfo> audioBatch,
    required double zipFileSizeLimitInBytes,
    required String targetDir,
    required String baseFileName,
    required int partNumber,
    required int totalParts,
  }) async {
    bool wasZipFileCreated = false;
    List<String> excludedTooLargeAudioFilesLst = [];
    List<dynamic> excludedTooLargeAudioFilesValueLst = [
      0, // excluded files total size in bytes
      Duration(seconds: 0), // excluded files total duration
    ];

    try {
      String zipFileName;

      if (totalParts > 1) {
        zipFileName = "${baseFileName}_part$partNumber.zip";
      } else {
        zipFileName = "$baseFileName.zip";
      }

      // Note: targetDir is now already the correct directory (passed from main method)
      String zipFilePathName = path.join(targetDir, zipFileName);

      // Prepare data for isolate (don't load files into memory here)
      List<Map<String, dynamic>> audioFilesData = [];

      for (AudioFileInfo audioInfo in audioBatch) {
        int audioFileSize = audioInfo.audio.audioFileSize;

        if (audioFileSize > zipFileSizeLimitInBytes) {
          excludedTooLargeAudioFilesLst.add(
              "${audioInfo.playlist.title}${path.separator}${audioInfo.audio.audioFileName}, ${(audioFileSize / 1000000).toStringAsFixed(2)}");
          excludedTooLargeAudioFilesValueLst[0] +=
              audioFileSize; // Convert to MB and accumulate
          excludedTooLargeAudioFilesValueLst[1] +=
              audioInfo.audio.audioDuration; // Accumulate duration
          continue; // Skip files that are larger than the limit
        }

        // Only pass file paths and metadata to isolate, not the actual bytes
        if (audioInfo.audioFile.existsSync()) {
          audioFilesData.add({
            'filePath': audioInfo.audioFile.path,
            'relativePath': audioInfo.relativePath,
            'audioFileSize': audioFileSize,
          });
        }
      }

      if (audioFilesData.isEmpty) {
        _logger.i('No valid files to add to ZIP: $zipFilePathName');
        return [
          wasZipFileCreated, // This will be false
          excludedTooLargeAudioFilesLst,
          excludedTooLargeAudioFilesValueLst,
        ];
      }

      // Prepare parameters for isolate
      Map<String, dynamic> isolateParams = {
        'audioFiles': audioFilesData,
        'zipFilePath': zipFilePathName,
      };

      // Run ZIP creation in background isolate to prevent ANR
      Map<String, dynamic> result =
          await compute(_createZipInIsolate, isolateParams);

      if (result['success']) {
        wasZipFileCreated = true;
        _logger.i(
            'ZIP file saved successfully in isolate: ${result['zipPath']}: ${_computeAudioFileDataTotalSize(audioFilesData)} bytes');
      } else {
        _logger.i(
            'Total size of saved audio files in $zipFileName is too large: ${_computeAudioFileDataTotalSize(audioFilesData)} bytes');
        _warningMessageVM.setError(
          errorType: ErrorType.androidZipFileCreationError,
          errorArgOne: zipFileName,
          errorArgTwo:
              _computeAudioFileDataTotalSize(audioFilesData).toString(),
        );

        _isSavingMp3 = false;

        notifyListeners();
        throw Exception('Isolate ZIP creation failed: ${result['error']}');
      }

      // Force garbage collection after each ZIP file
      await Future.delayed(Duration(milliseconds: 200));
      notifyListeners();
    } catch (e) {
      _logger.i('Error saving ZIP file: $e');
      rethrow;
    }

    return [
      wasZipFileCreated,
      excludedTooLargeAudioFilesLst,
      excludedTooLargeAudioFilesValueLst
    ];
  }

  /// Computes the total size in bytes of all audio files in the provided data list
  ///
  /// [audioFilesData] - List of maps containing audio file metadata
  /// Each map should have an 'audioFileSize' key with the file size in bytes
  ///
  /// Returns the total size in bytes as an int
  int _computeAudioFileDataTotalSize(
      List<Map<String, dynamic>> audioFilesData) {
    int totalSize = 0;

    for (Map<String, dynamic> audioFileData in audioFilesData) {
      // Get the audioFileSize from the map, defaulting to 0 if not found or null
      int fileSize = audioFileData['audioFileSize'] as int? ?? 0;
      totalSize += fileSize;
    }

    return totalSize;
  }

  int _calculateTotalParts({
    required List<AudioFileInfo> audioFileInfoLst,
    required double sizeLimitInBytes,
  }) {
    int parts = 1;
    int currentPartSize = 0;

    for (AudioFileInfo audioInfo in audioFileInfoLst) {
      if (currentPartSize + audioInfo.audio.audioFileSize > sizeLimitInBytes &&
          currentPartSize > 0) {
        parts++;
        currentPartSize = audioInfo.audio.audioFileSize;
      } else {
        currentPartSize += audioInfo.audio.audioFileSize;
      }
    }

    return parts;
  }

  /// Moves the generated MP3 ZIP file(s) to a directory where they are
  /// accessible by Android file explorers.
  ///
  /// The files are copied to the accessible directory and then deleted
  /// from the source directory (move operation).
  ///
  /// Parameters:
  /// - [baseZipFileName]: The base name of the ZIP file (without part numbers)
  /// - [numberOfZipFiles]: The number of ZIP files created
  /// - [sourceDir]: The directory where the ZIP files were originally created
  ///
  /// Returns a list containing:
  /// [
  ///   success (bool),
  ///   public directory path (String),
  ///   list of moved file names (List of String's),
  ///   error message if any (String)
  /// ]
  Future<List<dynamic>> _moveMp3ZipFilesToAccessibleAndroidDirectory({
    required String baseZipFileName,
    required String targetSaveDirStr,
    required int numberOfZipFiles,
    required String sourceDir,
  }) async {
    List<String> movedFileNames = [];
    String errorMessage = '';
    String publicPath = '';

    try {
      if (!Platform.isAndroid) {
        // On non-Android platforms, no need to move
        return [true, sourceDir, [], 'Not needed on this platform'];
      }

      _isMovingMp3Zip = true;
      notifyListeners();

      // Move the ZIP file(s) (copy then delete source)
      for (int i = 1; i <= numberOfZipFiles; i++) {
        String sourceFileName;

        if (numberOfZipFiles == 1) {
          sourceFileName = '$baseZipFileName.zip';
        } else {
          sourceFileName = '${baseZipFileName}_part$i.zip';
        }

        String sourceFilePath = path.join(sourceDir, sourceFileName);
        File sourceFile = File(sourceFilePath);

        _logger.i('Attempting to move: $sourceFilePath');

        if (await sourceFile.exists()) {
          // Used to show the moved current MP* ZIP name in the audio download view
          _audioMp3MovedCurrentZipName = sourceFileName;
          notifyListeners();

          String targetFilePath = path.join(targetSaveDirStr, sourceFileName);
          File targetFile = File(targetFilePath);

          try {
            // Delete target if it already exists to avoid conflicts
            if (await targetFile.exists()) {
              await targetFile.delete();
              _logger.i('Deleted existing target file: $targetFilePath');
            }

            // Copy the file to public Downloads
            await sourceFile.copy(targetFilePath);
            _logger.i('Copied to: $targetFilePath');

            // Verify the copy was successful by checking file size
            int sourceSize = await sourceFile.length();
            int targetSize = await targetFile.length();

            if (sourceSize == targetSize) {
              // Delete the source file after successful copy (move operation)
              await sourceFile.delete();
              _logger.i('Deleted source file: $sourceFilePath');

              movedFileNames.add(sourceFileName);
              publicPath = targetSaveDirStr;
            } else {
              errorMessage +=
                  'File size mismatch for $sourceFileName (source: $sourceSize, target: $targetSize)\n';
              _logger.e('File size mismatch for $sourceFileName');
              // Don't delete source if sizes don't match
            }
          } catch (e) {
            errorMessage += 'Failed to move $sourceFileName: $e\n';
            _logger.e('Error moving file $sourceFileName: $e');
          }
        } else {
          errorMessage +=
              'Source file not found: $sourceFileName at $sourceFilePath\n';
          _logger.w('Source file not found: $sourceFilePath');
        }
      }

      if (movedFileNames.isEmpty) {
        String finalError =
            errorMessage.isEmpty ? 'No files were moved' : errorMessage;
        _logger.e('Move operation failed: $finalError');
        return [false, publicPath, [], finalError];
      }

      _logger.i(
          'Successfully moved ${movedFileNames.length} file(s) to $publicPath');

      // Update the UI to show saving is complete
      _isMovingMp3Zip = false;
      notifyListeners();

      return [true, publicPath, movedFileNames, ''];
    } catch (e) {
      errorMessage = 'Error moving ZIP files: $e';
      _logger.e(errorMessage);

      _isMovingMp3Zip = false;
      notifyListeners();

      return [false, '', [], errorMessage];
    }
  }

  /// This method is called when the user clicks on the appbar menu item
  /// 'Save Playlists Audio MP3 Files to Zip File' menu item or on the playlist
  /// item 'Save the Playlist Audio MP3 to Zip File' menu item. In this case, the
  /// [listOfPlaylists] parameter contains only one playlist and the
  /// [uniquePlaylistIsSaved] parameter is set to true.
  ///
  /// Enhanced version of savePlaylistsAudioMp3FilesToZip that automatically
  /// moves the ZIP files to a selected public accessible directory on Android.
  ///
  /// This method wraps the existing savePlaylistsAudioMp3FilesToZip and adds
  /// the public accessible directory move functionality. The files are moved
  /// (not copied) from the app's private directory.
  Future<List<dynamic>> savePlaylistsAudioMp3FilesToZipWithPublicCopy({
    required List<Playlist> listOfPlaylists,
    required String targetSaveDirStr,
    required DateTime fromAudioDownloadDateTime,
    required double zipFileSizeLimitInMb,
    bool uniquePlaylistIsSaved = false,
  }) async {
    // Call the original method to create the ZIP files
    List<dynamic> savedMp3InfoLst = await savePlaylistsAudioMp3FilesToZip(
      listOfPlaylists: listOfPlaylists,
      targetDirStrOnWindows: targetSaveDirStr,
      fromAudioDownloadDateTime: fromAudioDownloadDateTime,
      zipFileSizeLimitInMb: zipFileSizeLimitInMb,
      uniquePlaylistIsSaved: uniquePlaylistIsSaved,
    );

    // If no files were saved, return early
    if (savedMp3InfoLst.isEmpty || savedMp3InfoLst[0] == '') {
      return savedMp3InfoLst;
    }

    // Extract information from the result
    String zipFilePathName = savedMp3InfoLst[0];
    int numberOfCreatedZipFiles = savedMp3InfoLst[6];

    // Extract base file name from the full path
    String baseFileName = path.basenameWithoutExtension(zipFilePathName);

    // Remove the "part 1 to X" suffix if present
    if (baseFileName.contains('_part')) {
      baseFileName = baseFileName.split('_part')[0];
    }

    String sourceDir = path.dirname(zipFilePathName);

    _logger.i(
        'Attempting to move $numberOfCreatedZipFiles ZIP file(s) from $sourceDir');

    // Move to public Downloads directory on Android
    if (Platform.isAndroid) {
      List<dynamic> moveResult =
          await _moveMp3ZipFilesToAccessibleAndroidDirectory(
        baseZipFileName: baseFileName,
        targetSaveDirStr: targetSaveDirStr,
        numberOfZipFiles: numberOfCreatedZipFiles,
        sourceDir: sourceDir,
      );

      bool moveSuccess = moveResult[0];
      String publicDirPath = moveResult[1];
      List<String> movedFileNames = moveResult[2];
      String errorMessage = moveResult[3];

      if (moveSuccess && movedFileNames.isNotEmpty) {
        _logger.i('Successfully moved to public directory: $publicDirPath');

        // Update the return value with the public directory path
        savedMp3InfoLst[0] = numberOfCreatedZipFiles > 1
            ? path.join(publicDirPath,
                '${baseFileName}_part 1 to $numberOfCreatedZipFiles.zip')
            : path.join(publicDirPath, '$baseFileName.zip');

        // Update the confirmation message to include the public directory path
        DateFormatVM dateFormatVM = DateFormatVM(
          settingsDataService: _settingsDataService,
        );

        // Show confirmation with the public directory location
        _warningMessageVM.confirmSavingAudioMp3ToZip(
          zipFilePathName: savedMp3InfoLst[0],
          fromAudioDownloadDateTime:
              dateFormatVM.formatDateTime(fromAudioDownloadDateTime),
          savedAudioMp3Number: savedMp3InfoLst[1],
          savedTotalAudioFileSize: savedMp3InfoLst[2],
          savedTotalAudioDuration: savedMp3InfoLst[3],
          savingAudioToZipOperationDuration: savedMp3InfoLst[4],
          realNumberOfBytesSavedToZipPerSecond: savedMp3InfoLst[5],
          uniquePlaylistIsSaved: uniquePlaylistIsSaved,
          numberOfCreatedZipFiles: numberOfCreatedZipFiles,
          excludedTooLargeAudioFilesLst: savedMp3InfoLst[7],
        );
      } else if (errorMessage.isNotEmpty) {
        _logger.w('Could not move to public Downloads: $errorMessage');
        // Still return success since the files are in the app directory
      }
    }

    return savedMp3InfoLst;
  }

  String getOldestAudioDownloadDateFormattedStr({
    required List<Playlist> listOfPlaylists,
  }) {
    DateTime oldestAudioDownloadDateTime = DateTime.now();

    // Iterate through passed playlists
    for (Playlist playlist in listOfPlaylists) {
      for (Audio audio in playlist.playableAudioLst) {
        if (audio.audioDownloadDateTime.isBefore(oldestAudioDownloadDateTime)) {
          oldestAudioDownloadDateTime = audio.audioDownloadDateTime;
        }
      }
    }

    DateFormatVM dateFormatVM = DateFormatVM(
      settingsDataService: _settingsDataService,
    );

    return dateFormatVM.formatDateTime(oldestAudioDownloadDateTime);
  }

  String getNewestAudioDownloadDateFormattedStr() {
    DateTime newestAudioDownloadDateTime = DateTime(2020, 1, 1);

    // Iterate through passed playlists
    for (Playlist playlist in _listOfSelectablePlaylists) {
      for (Audio audio in playlist.playableAudioLst) {
        if (audio.audioDownloadDateTime.isAfter(newestAudioDownloadDateTime)) {
          newestAudioDownloadDateTime = audio.audioDownloadDateTime;
        }
      }
    }

    DateFormatVM dateFormatVM = DateFormatVM(
      settingsDataService: _settingsDataService,
    );

    return dateFormatVM.formatDateTime(newestAudioDownloadDateTime);
  }

  Future<Duration> evaluateSavingAudioMp3FileToZipDuration({
    required List<Playlist> listOfPlaylists,
    required DateTime fromAudioDownloadDateTime,
  }) async {
    int savedAudiosFileSize = 0;
    double savedAudioBytesNumberToZipInOneMicroSecond = 0.0;

    // Iterate through all playlists
    for (Playlist playlist in listOfPlaylists) {
      Directory playlistDir = Directory(playlist.downloadPath);

      if (!playlistDir.existsSync()) {
        continue;
      }

      // Get all audio files from the playlist that match the date criteria
      List<Audio> filteredAudioLst = playlist.playableAudioLst
          .where((audio) => audio.audioDownloadDateTime
              .isAtOrAfter(fromAudioDownloadDateTime))
          .toList();

      for (Audio audio in filteredAudioLst) {
        File audioFile = File(audio.filePathName);

        // Calculate zip rate only once using the first valid audio file
        if (savedAudioBytesNumberToZipInOneMicroSecond == 0 &&
            audioFile.existsSync()) {
          try {
            savedAudioBytesNumberToZipInOneMicroSecond =
                await _calculateHowManyMp3BytesAreIncludedInZipInOneSecond(
              audio: audio,
              audioFile: audioFile,
            );
          } catch (e) {
            // If calculation fails, use a default rate (e.g., 1MB/second)
            savedAudioBytesNumberToZipInOneMicroSecond =
                1024 * 1024; // 1MB/s fallback
          }
        }

        if (audioFile.existsSync()) {
          savedAudiosFileSize += audio.audioFileSize;
        }
      }
    }

    // Handle edge cases
    if (savedAudiosFileSize == 0) {
      return Duration.zero; // No files to process
    }

    // Multiplying by 1200000 instead of 1000000 is due to the fact that
    // the savedAudioBytesNumberToZipInOneMicroSecond is 1.2 times too
    // big on Android.
    double evaluatedSeconds = (savedAudiosFileSize /
        (savedAudioBytesNumberToZipInOneMicroSecond * 1200000));
    evaluatedSeconds /= 3.57; // the estimated seconds are 3.57 times too big

    _savingAudioMp3FileToZipDuration =
        Duration(seconds: evaluatedSeconds.ceil());

    return _savingAudioMp3FileToZipDuration;
  }

  Future<double> _calculateHowManyMp3BytesAreIncludedInZipInOneSecond({
    required Audio audio,
    required File audioFile,
  }) async {
    final archive = Archive();
    int savedAudioFileSize = audio.audioFileSize;
    Duration savingAudioToZipDuration = Duration.zero;

    if (audioFile.existsSync()) {
      // Start timing the zip creation process
      final stopwatch = Stopwatch()..start();

      // Read the file and add it to the archive
      List<int> audioBytes = await audioFile.readAsBytes();
      archive.addFile(ArchiveFile(
        audio.audioFileName,
        audioBytes.length,
        audioBytes,
      ));
      String applicationPath = _settingsDataService.get(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.appSettingsPath,
      );
      String zipFilePathName = path.join(applicationPath, 'temp.zip');
      File zipFile = File(zipFilePathName);

      zipFile.writeAsBytesSync(ZipEncoder().encode(archive), flush: true);

      // Stop timing and calculate duration
      stopwatch.stop();
      savingAudioToZipDuration = stopwatch.elapsed;

      DirUtil.deleteFileIfExist(
        pathFileName: zipFilePathName,
      );
    }

    return (savedAudioFileSize / savingAudioToZipDuration.inMicroseconds);
  }

  /// Method called when the user clicks on the 'Restore Playlist, Comments,
  /// Pictures and Settings from Zip File' menu item located in the appbar
  /// leading popup menu.
  ///
  /// Returns the zip file path name from which the playlist, comments, pictures
  /// and the application settings is restored. Returns empty String if the zip
  /// file does not exist. The returned value is only used in the playlistListVM
  /// unit test.
  Future<String> restorePlaylistsCommentsAndSettingsJsonFilesFromZip({
    required String zipFilePathName,
    required bool doReplaceExistingPlaylists,
    required bool doDeleteExistingPlaylists,
  }) async {
    String selectedPlaylistBeforeRestoreTitle = '';

    if (_uniqueSelectedPlaylist != null) {
      selectedPlaylistBeforeRestoreTitle = _uniqueSelectedPlaylist!.title;
    }

    // Restoring the playlists, comments and settings json files
    // from the zip file. The dynamic list restoredInfoLst list
    // contains the list of restored playlist titles and the number
    // of restored comments.
    // The returned list contains:
    //  0 list of restored playlist titles,
    //  1 number of restored comments JSON files,
    //  2 number of restored pictures JSON files,
    //  3 number of restored pictures JPG files,
    //  4 was the zip file created from the playlist item 'Save the Playlist, its Comments,
    //    and its Pictures to Zip File' (true, false if multiple playlists are restored),
    //  5 restoredAudioReferencesNumber,
    //  6 updated comment number,
    //  7 added comment number,
    //  8 deleted audio titles list,
    //  9 were new playlists added at end of non empty playlist list,
    //  10 deleted existing playlist title list,
    //  11 deleted comment number.
    List<dynamic> restoredInfoLst = await _restoreFilesFromZip(
      zipFilePathName: zipFilePathName,
      doReplaceExistingPlaylists: doReplaceExistingPlaylists,
      doDeleteExistingPlaylists: doDeleteExistingPlaylists,
    );

    // Combining the restored app settings with the current app
    // settings
    await _mergeRestoredFromZipSettingsWithCurrentAppSettings();

    updateSettingsAndPlaylistJsonFiles(
      unselectAddedPlaylist:
          false, // fix bug when restoring unique selected playlist from Windows zip on android
      updatePlaylistPlayableAudioList: false,
      managePlaylistOrder: true,
    );

    // Necessary so that, in the playlist download view in the situation
    // where the playlists are not expanded, the selected playlist SF
    // parms name is displayed in the SF parms dropdown button.
    if (!_isPlaylistListExpanded) {
      getUpToDateSelectablePlaylists();
    }

    // Will be set to false if the zip file was created from the
    // appbar 'Save Playlist, Comments, Pictures and Settings to Zip
    // File' menu item.
    bool wasIndividualPlaylistRestored = restoredInfoLst[4];

    // Display a confirmation message to the user.
    _warningMessageVM.confirmRestorationFromZip(
      zipFilePathName: zipFilePathName,
      playlistTitlesLst: restoredInfoLst[0],
      audioReferencesNumber: restoredInfoLst[5],
      commentJsonFilesNumber: restoredInfoLst[1],
      updatedCommentNumber: restoredInfoLst[6],
      addedCommentNumber: restoredInfoLst[7],
      pictureJsonFilesNumber: restoredInfoLst[2],
      pictureJpgFilesNumber: restoredInfoLst[3],
      deletedAudioTitlesLst: restoredInfoLst[8],
      wasIndividualPlaylistRestored: wasIndividualPlaylistRestored,
      newPlaylistsAddedAtEndOfPlaylistLst: restoredInfoLst[9],
      deletedExistingPlaylistTitlesLst: restoredInfoLst[10],
      deletedCommentNumber: restoredInfoLst[11],
    );

    if (doReplaceExistingPlaylists &&
            selectedPlaylistBeforeRestoreTitle != '' ||
        getSelectedPlaylists().length > 1) {
      setPlaylistSelection(
        playlistTitle: selectedPlaylistBeforeRestoreTitle,
        isPlaylistSelected: true,
      );
    } else if (wasIndividualPlaylistRestored) {
      if (selectedPlaylistBeforeRestoreTitle != '') {
        // In this case, the playlist which was selected
        // before the restoration is selected. The advantage is
        // that if the User executes the 'Update Playlist JSON
        // Files' menu of the appbar, only one playlist is
        // displayed as selected.
        setPlaylistSelection(
          playlistTitle: selectedPlaylistBeforeRestoreTitle,
          isPlaylistSelected: true,
        );
        // setPlaylistSelection(
        //   playlistTitle: restoredInfoLst[0][0].title,
        //   isPlaylistSelected: false,
        // );
      }
    }

    // This ensures that after restoring unique or multiple
    // playlists from a zip file, the Playlist Download View
    // left audio popup menu is active if a playlist is selected.
    if (_uniqueSelectedPlaylist != null) {
      setPlaylistSelection(
        playlistSelectedOrUnselected: _uniqueSelectedPlaylist,
        isPlaylistSelected: true,
      );
    }

    // Return the zip file path name used for restoration.
    return zipFilePathName;
  }

  /// The method loads the restored zip version of the application settings. This
  /// will enable to add the playlist order list, the sort/filter named parameters
  /// map and the unnamed sort/filter history list of the restored app settings
  /// zip version to the corresponding list or map of the current app settings
  /// version.
  ///
  /// When this method is called, the application settings version before executing
  /// the restoration from the zip file was already loaded and is in the private
  /// variable _settingsDataService. Now, the app settings file is the settings
  /// file restored from the zip file.
  Future<void> _mergeRestoredFromZipSettingsWithCurrentAppSettings() async {
    final SettingsDataService settingsDataServiceZipVersion =
        SettingsDataService();

    // Load the restored settings whose corresponding list or map will
    // be merged with the current app settings.

    String applicationPath = _settingsDataService.get(
      settingType: SettingType.dataLocation,
      settingSubType: DataLocation.appSettingsPath,
    );

    // Loading settingsDataServiceZipVersion from settings.json file
    // which was extracted from the restored zip file.
    await settingsDataServiceZipVersion.loadSettingsFromFile(
      settingsJsonPathFileName:
          '$applicationPath${Platform.pathSeparator}$kSettingsFileName',
    );

    // Merge the playlist order list
    List<String> restoredPlaylistTitleOrder =
        (settingsDataServiceZipVersion.get(
      settingType: SettingType.playlists,
      settingSubType: Playlists.orderedTitleLst,
    ) as List<dynamic>)
            .cast<String>();

    List<String> currentPlaylistTitleOrder = (_settingsDataService.get(
      settingType: SettingType.playlists,
      settingSubType: Playlists.orderedTitleLst,
    ) as List<dynamic>)
        .cast<String>();

    List<String> mergedPlaylistTitleOrder = [];

    if (currentPlaylistTitleOrder.isNotEmpty) {
      mergedPlaylistTitleOrder = List.from(currentPlaylistTitleOrder);
    }

    if (restoredPlaylistTitleOrder.isNotEmpty) {
      // Combine both lists while preserving uniqueness and order
      for (String playlistTitle in restoredPlaylistTitleOrder) {
        if (!mergedPlaylistTitleOrder.contains(playlistTitle)) {
          mergedPlaylistTitleOrder.add(playlistTitle);
        }
      }

      _settingsDataService.set(
        settingType: SettingType.playlists,
        settingSubType: Playlists.orderedTitleLst,
        value: mergedPlaylistTitleOrder,
      );
    }

    // Merge the named audio sort/filter parameters map
    settingsDataServiceZipVersion.namedAudioSortFilterParametersMap
        .forEach((key, value) {
      _settingsDataService.namedAudioSortFilterParametersMap
          .putIfAbsent(key, () => value);
    });

    // Merge the unnamed sort/filter history list
    List<AudioSortFilterParameters> restoredHistory =
        settingsDataServiceZipVersion.searchHistoryAudioSortFilterParametersLst;

    for (var filterParam in restoredHistory) {
      _settingsDataService.addAudioSortFilterParametersToSearchHistory(
          audioSortFilterParameters: filterParam);
    }

    // Save the updated settings
    _settingsDataService.saveSettings();
  }

  /// Method called when the user clicks on the 'Restore Playlist, Comments and Settings
  /// from Zip File' menu. It extracts the playlist json files as well as the commen json
  /// files of the playlists and writes them to the playlists root path.
  ///
  /// The returned list contains
  /// [
  ///  0 list of restored playlist titles,
  ///  1 number of restored comments JSON files,
  ///  2 number of restored pictures JSON files,
  ///  3 number of restored pictures JPG files,
  ///  4 was the zip file created from the playlist item 'Save the Playlist, its Comments,
  ///    and its Pictures to Zip File' (true, false if multiple playlists are restored),
  ///  5 restoredAudioReferencesNumber,
  ///  6 updated comment number,
  ///  7 added comment number,
  ///  8 deleted audio titles list,
  ///  9 were new playlists added at end of non empty playlist list
  ///  10 deleted existing playlist title list
  ///  11 deleted comment number,
  /// ]
  Future<List<dynamic>> _restoreFilesFromZip({
    required String zipFilePathName,
    required bool doReplaceExistingPlaylists,
    required bool doDeleteExistingPlaylists,
  }) async {
    Map<String, String> zipExistingPlaylistJsonContentsMap = {};
    List<String> existingPlaylistTitlesLst =
        _listOfSelectablePlaylists.map((playlist) => playlist.title).toList();
    List<dynamic> restoredInfoLst = []; // restored info returned list
    List<String> restoredPlaylistTitlesLst = [];
    List<String> playlistInZipTitleLst = [];
    int restoredCommentsJsonNumber = 0;
    int restoredPicturesJsonNumber = 0;
    int restoredPicturesJpgNumber = 0;
    int restoredAudioReferencesNumber = 0;

    // Check if the provided zip file exists.
    final File zipFile = File(zipFilePathName);

    if (!zipFile.existsSync()) {
      // Can not happen since the zip file is selected by the user
      // with the file picker and so the file must exist.
      restoredInfoLst.add(restoredPlaylistTitlesLst);
      restoredInfoLst.add(restoredCommentsJsonNumber);
      restoredInfoLst.add(restoredPicturesJsonNumber);
      restoredInfoLst.add(restoredPicturesJpgNumber);
      restoredInfoLst.add(false); // wasIndividualPlaylistRestored
      restoredInfoLst.add(restoredAudioReferencesNumber);
      restoredInfoLst.add(0); // adding 0 to the updated comment number
      restoredInfoLst.add(0); // adding 0 to the added comment number
      restoredInfoLst.add([]); // adding [] to deleted audio titles list
      restoredInfoLst.add(false); // newPlaylistsAddedAtEndOfPlaylistLst
      restoredInfoLst.add([]); // deleted existing playlist titles list

      return restoredInfoLst;
    }

    // Retrieve the application path.
    final String applicationPath = _settingsDataService.get(
      settingType: SettingType.dataLocation,
      settingSubType: DataLocation.appSettingsPath,
    );

    // Retrieve the playlist root path. Normally, this value contains
    // '/playlists' or '\playlists' depending on the platform.
    final String playlistRootPath = _settingsDataService.get(
      settingType: SettingType.dataLocation,
      settingSubType: DataLocation.playlistRootPath,
    );

    // Read the entire zip file as bytes.
    final List<int> zipBytes = await zipFile.readAsBytes();

    // Decode the zip archive.
    final Archive archive = ZipDecoder().decodeBytes(zipBytes);
    final String zipFilePlaylistDir = _getPlaylistZipRootDir(
      archive: archive,
    );
    ArchiveFile? archiveFile;

    // Will be set to false if the zip file was created from the
    // appbar 'Save Playlists, Comments, Pictures and Settings to Zip
    // File' menu item. In this case, the settings file is included
    // in the zip file.
    bool wasIndividualPlaylistRestored = true;

    // Will be used to indicate that the created playlist(s) were
    // positioned at the end of the playlist list. If it is true,
    // the confirmation message built in WarningMessageDisplayDialog
    // displayed to the user lists the title of the added playlist(s).
    //
    // Set to true if a new playlist is not added to an empty playlist
    // list.
    bool newPlaylistsAddedAtEndOfPlaylistLst = false;

    // Iterate over each file in the archive.
    for (archiveFile in archive) {
      // Skip directories.
      if (!archiveFile.isFile) {
        continue;
      }

      // Compute the destination path by joining the application path
      // with the relative path stored in the archive.
      // Note: The relative path may include '..' segments which will be
      // normalized.

      final String sanitizedArchiveFilePathName = archiveFile.name
          .replaceAll(
              '\\', '/') // First convert all backslashes to forward slashes
          .split('/')
          .map((segment) => segment.trim())
          .join('/');

      // Applying sanitizedArchiveFileName.replaceFirst('playlists/', '')
      // enables to restore unique or multiple playlists located
      // in the audio/playlists directory and saved to the zip file,
      // to an app whose playlists root path contains /playlists
      // or not.
      String destinationPathFileName;

      if (sanitizedArchiveFilePathName.startsWith(kPictureDirName) ||
          sanitizedArchiveFilePathName.contains(kSettingsFileName)) {
        // The first condition guarantees that the zip verion of
        // the pictureAudioMap.json file is restored. It will then
        // be combined with the app current pictureAudioMap.json file.
        //
        // The second condition guarantees that the zip settings
        // file is restored. It will then be combined with the
        // current settings file in the method below
        // _mergeRestoredFromZipSettingsWithCurrentAppSettings.
        destinationPathFileName = path.normalize(
          path.join(applicationPath, sanitizedArchiveFilePathName),
        );
      } else {
        destinationPathFileName = path.normalize(
          path.join(
              playlistRootPath,
              sanitizedArchiveFilePathName.replaceFirst(
                  zipFilePlaylistDir, '')),
        );
      }

      if (destinationPathFileName.contains(kSettingsFileName)) {
        // In this case, the zip file was created from the left
        // appbar 'Save Playlists, Comments, Pictures and Settings
        // to Zip File' menu item. If the similar menu was selected
        // from the playlist item menu, the settings file does not
        // exist in the zip file.
        wasIndividualPlaylistRestored = false;
      }

      // Capturing the playlists contained in the zip.
      if (path.extension(destinationPathFileName) == '.json' &&
          !destinationPathFileName.contains(kSettingsFileName) &&
          !destinationPathFileName.contains(kCommentDirName) &&
          !destinationPathFileName.contains(kPictureDirName)) {
        // This is a playlist JSON file.
        String playlistInZipTitle =
            path.basenameWithoutExtension(destinationPathFileName);
        playlistInZipTitleLst.add(playlistInZipTitle);

        if (existingPlaylistTitlesLst.contains(playlistInZipTitle)) {
          // This playlist already exists in the application. As
          // consequence, store JSON content for later processing.
          final String jsonContent =
              utf8.decode(archiveFile.content as List<int>);
          zipExistingPlaylistJsonContentsMap[playlistInZipTitle] = jsonContent;
        } else {
          if (existingPlaylistTitlesLst.isNotEmpty) {
            // New playlist added to not empty playlist list.
            // If the playlist list is empty, the new playlist(s)
            // is//are automatically positioned at the top of the
            // playlist list.
            newPlaylistsAddedAtEndOfPlaylistLst = true;
          }
        }
      }

      // File's bytes to be written later the computed destination.
      final File outputFile = File(destinationPathFileName);

      if (!doReplaceExistingPlaylists &&
          !destinationPathFileName.contains(kSettingsFileName) &&
          !destinationPathFileName.contains(kPictureAudioMapFileName)) {
        // Check if this is a playlist JSON file to merge.
        if (path.extension(destinationPathFileName) == '.json' &&
            !destinationPathFileName.contains(kCommentDirName) &&
            !destinationPathFileName.contains(kPictureDirName)) {
          String playlistTitle =
              path.basenameWithoutExtension(destinationPathFileName);

          if (existingPlaylistTitlesLst.contains(playlistTitle)) {
            // This playlist already exists - we will add the missing audios
            // instead of replacing the file.
            continue; // Skip writing the JSON file.
          }
        }

        // For other files (comments, pictures). existingPlaylistTitlesLst is
        // empty if restoring unique or multiple playlists to empty app.
        if (existingPlaylistTitlesLst.any((title) =>
            RegExp(r'\b' + RegExp.escape(title) + r'\b')
                .hasMatch(destinationPathFileName))) {
          // In mode 'not replace playlist', skip the file if its about
          // the existing playlist and so do not replace it or do not
          // add it if it is not in the playlist.
          if (destinationPathFileName.contains(kPictureDirName)) {
            if (destinationPathFileName.endsWith('.jpg')) {
              if (outputFile.existsSync()) {
                // This can happen if the picture jpg file is already
                // present in the picture directory.
                continue;
              }

              restoredPicturesJpgNumber++;
            } else if (!File(destinationPathFileName).existsSync()) {
              // The json file is an audio picture reference file.
              restoredPicturesJsonNumber++;
            }
            continue;
          }
        }
      }

      final Directory destinationDir = Directory(
        // Extracting the directory from the path file name.
        path.dirname(destinationPathFileName),
      );

      if (!destinationDir.existsSync()) {
        await destinationDir.create(recursive: true);
      }

      if (destinationPathFileName.contains(kCommentDirName) &&
          outputFile.existsSync()) {
        if (doReplaceExistingPlaylists) {
          restoredCommentsJsonNumber++;
          // If the comment json file already exists and
          // doReplaceExistingPlaylists is true, it is replaced
          // with the comment json file contained in the restoration
          // zip file.
        }
        // If the comment json file already exists, skip it. This is
        // useful if a new comment was added before the restoration.
        // Otherwise, the new comment would be lost.
        continue;
      }

      if (destinationPathFileName.contains(kPictureAudioMapFileName) &&
          outputFile.existsSync()) {
        // If the pictureAudioMap.json file already exists, it is merged
        // with the pictureAudioMap.json file contained in the restoration
        // zip file.

        // Convert the byte content to a string.
        final String jsonContent =
            utf8.decode(archiveFile.content as List<int>);

        // Parse the string as JSON to get the Map.
        final Map<String, dynamic> jsonMap = jsonDecode(jsonContent);

        // Convert to the required type.
        final Map<String, List<String>> pictureAudioMap = {};
        jsonMap.forEach((key, value) {
          if (value is List) {
            pictureAudioMap[key] = List<String>.from(value);
          }
        });

        // Now call the merge method with the correctly parsed map.
        _pictureVM.mergeAndSaveRestoredPictureAudioMapJsonFile(
          restoredPictureAudioMap: pictureAudioMap,
        );

        continue;
      }

      if (!destinationPathFileName.contains(kSettingsFileName) &&
          !destinationPathFileName.contains(kPictureAudioMapFileName)) {
        // Second condition guarantees that the picture json files
        // number is correctly calculated.
        if (destinationPathFileName.contains(kCommentDirName) &&
            !File(destinationPathFileName).existsSync()) {
          restoredCommentsJsonNumber++;
        } else if (destinationPathFileName.contains(kPictureDirName)) {
          if (destinationPathFileName.endsWith('.jpg')) {
            if (outputFile.existsSync()) {
              // This can happen if the picture jpg file is already
              // present in the picture directory.
              continue;
            }

            restoredPicturesJpgNumber++;
          } else {
            // The json file is an audio picture reference file.
            restoredPicturesJsonNumber++;
          }
        } else {
          // Get the playableAudioLst length from the just-written playlist file
          try {
            // Read the JSON content that will be written below
            final String jsonContent =
                utf8.decode(archiveFile.content as List<int>);
            final Map<String, dynamic> playlistJson = jsonDecode(jsonContent);

            // Get the playableAudioLst length
            final List<dynamic>? playableAudioLst =
                playlistJson['playableAudioLst'];

            restoredAudioReferencesNumber += playableAudioLst?.length ?? 0;

            // Adding the restored playlist title to the list
            // of restored playlist titles.
            restoredPlaylistTitlesLst.add(
              path.basenameWithoutExtension(destinationPathFileName),
            );
          } catch (e) {
            // Handle JSON parsing error
            _logger.i('Error parsing playlist JSON: $e');
          }
        }
      }

      // Writting the json content
      await outputFile.writeAsBytes(
        archiveFile.content as List<int>,
        flush: true,
      );
    } // End of for loop iterating over the archive files.

    List<String> deletedExistingPlaylistTitlesLst = [];

    if (!wasIndividualPlaylistRestored && doDeleteExistingPlaylists) {
      deletedExistingPlaylistTitlesLst =
          await _deleteExistingPlaylistsNotContainedInMultiplePlaylistsZip(
        existingPlaylistTitlesLst: existingPlaylistTitlesLst,
        playlistInZipTitleLst: playlistInZipTitleLst,
        restoreZipDateTime:
            _getZipCreationDateFromFileName(path.basename(zipFilePathName)) ??
                zipFile.lastModifiedSync(),
        playlistRootPath: playlistRootPath,
      );
    }

    // Add missing audios references + their comments +
    // their pictures from the zip playlists to the existing
    // playlists.
    //
    // The returned list of integers contains:
    //   [0] number of added audio references,
    //   [1] number of added comment json files,
    //   [2] number of added pictures,
    //   [3] number of modified comments,
    //   [4] number of added comments,
    //   [5] deleted audio titles list,
    //   [6] number of deleted comments.
    List<dynamic> restoredNumberLst =
        await _mergeZipPlaylistsWithExistingPlaylists(
      zipExistingPlaylistJsonContentsMap: zipExistingPlaylistJsonContentsMap,
      archive: archive,
      doReplaceExistingPlaylists: doReplaceExistingPlaylists,
    );

    restoredInfoLst.add(restoredPlaylistTitlesLst);
    restoredInfoLst.add(
        restoredCommentsJsonNumber + restoredNumberLst[1]); // adding number
    //                                       of restored comments json files
    restoredInfoLst.add(restoredPicturesJsonNumber); // Number of restored
    //                                                 pictures json files
    restoredInfoLst.add(restoredPicturesJpgNumber);
    restoredInfoLst.add(wasIndividualPlaylistRestored);
    restoredInfoLst.add(restoredAudioReferencesNumber +
        restoredNumberLst[0]); // restored audio references number
    restoredInfoLst.add(restoredNumberLst[3]); // updated comment number
    restoredInfoLst.add(restoredNumberLst[4]); // added comment number
    restoredInfoLst
        .add(restoredNumberLst[5]); // adding deleted audio and mp3 files number
    restoredInfoLst.add(
        newPlaylistsAddedAtEndOfPlaylistLst); // were new playlists added at
    //                                       end of non empty playlist list
    restoredInfoLst.add(deletedExistingPlaylistTitlesLst);
    restoredInfoLst.add(restoredNumberLst[6]); // number of deleted comments

    return restoredInfoLst;
  }

  /// When restoring playlists from a zip file this method deletes existing playlists
  /// which are not contained in the zip file. However, a playlist is only deleted
  /// its creation date time is before the zip file creation date time or if the newest
  /// audio download date time of its audio's or the last text to speech comment is before
  /// the zip file creation date time.
  ///
  /// This method is called with doReplaceExistingPlaylists checkbox set to true or
  /// false. It is only called when restoring multiple playlists and not unique playlist
  /// from a zip file.
  ///
  /// The method returns a list containing the deleted existing playlist titles.
  Future<List<String>>
      _deleteExistingPlaylistsNotContainedInMultiplePlaylistsZip({
    required List<String> existingPlaylistTitlesLst,
    required List<String> playlistInZipTitleLst,
    required DateTime restoreZipDateTime,
    required String playlistRootPath,
  }) async {
    List<String> deletedExistingPlaylistTitlesLst = [];

    for (String existingPlaylistTitle in existingPlaylistTitlesLst) {
      if (!playlistInZipTitleLst.contains(existingPlaylistTitle)) {
        // This existing playlist is not contained in the zip file
        // and so will be deleted if it was no created or modified
        // at or after the restore zip file creation date time.
        Playlist? existingPlaylistNotContainedInZipFile;

        try {
          existingPlaylistNotContainedInZipFile =
              _listOfSelectablePlaylists.firstWhere(
                  (playlist) => playlist.title == existingPlaylistTitle);
        } catch (e) {
          continue;
        }

        FileStat fileStat = await File(
                "${existingPlaylistNotContainedInZipFile.downloadPath}${path.separator}${existingPlaylistNotContainedInZipFile.title}.json")
            .stat();

        if (fileStat.modified.isAtOrAfter(restoreZipDateTime)) {
          // The existing playlist json file was created after the
          // zip file creation date time. As consequence, do not
          // delete the existing playlist.
          continue;
        }

        DateTime newestAudioDateTime = DateTime(2020, 1, 1);

        // Iterate through passed playlists
        for (Audio audio
            in existingPlaylistNotContainedInZipFile.playableAudioLst) {
          if (audio.audioType == AudioType.textToSpeech) {
            // If the existing audio is a text-to-speech audio,
            // its newest date time is the last comment update
            // date time
            Comment? lastComment = _commentVM.getLastCommentOfAudio(
              audio: audio,
            );

            if (lastComment != null) {
              if (lastComment.lastUpdateDateTime.isAfter(newestAudioDateTime)) {
                newestAudioDateTime = lastComment.lastUpdateDateTime;
              }
            }
          } else if (audio.audioDownloadDateTime.isAfter(newestAudioDateTime)) {
            newestAudioDateTime = audio.audioDownloadDateTime;
          }
        }

        if (newestAudioDateTime.isBefore(restoreZipDateTime)) {
          deletePlaylist(
            playlistToDelete: existingPlaylistNotContainedInZipFile,
          );
          deletedExistingPlaylistTitlesLst.add(existingPlaylistTitle);
        }
      }
    }

    notifyListeners();

    return deletedExistingPlaylistTitlesLst;
  }

  DateTime? _getZipCreationDateFromFileName(String zipFileName) {
    // Matches any zip with the timestamp pattern
    final RegExp dateRegex =
        RegExp(r'(\d{4})-(\d{2})-(\d{2})_(\d{2})_(\d{2})_(\d{2})\.zip');
    final Match? match = dateRegex.firstMatch(zipFileName);

    if (match != null) {
      return DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
      );
    }
    return null;
  }

  /// When restoring playlists from a zip file in situation where the playlists
  /// are not replaced by the zip playlists, this method adds audio's of playlists
  /// corresponding to existing playlists which are available in the zip file and
  /// are not already present in the existing playlists.
  ///
  /// The fact that an audio is not already present in the existing playlist is due
  /// to two reasons:
  ///   1. The audio was deleted from the existing playlist.
  ///   2. The audio was added to the playlist saved in the zip file.
  ///
  /// The returned list dynamic contains:
  ///   [0] number of added audio references,
  ///   [1] number of added comment json files,
  ///   [2] number of added pictures,
  ///   [3] number of modified comments,
  ///   [4] number of added comments,
  ///   [5] deleted audio titles list.
  ///   [6] number of deleted comments,
  Future<List<dynamic>> _mergeZipPlaylistsWithExistingPlaylists({
    required Map<String, String> zipExistingPlaylistJsonContentsMap,
    required Archive archive,
    required bool doReplaceExistingPlaylists,
  }) async {
    int addedAudioReferencesCount = 0;
    int addedCommentJsonFilesCount = 0;
    int addedPicturesCount = 0;
    int updatedCommentsCount = 0;
    int addedCommentsCount = 0;
    int deletedCommentsCount = 0;
    List<String> deletedAudioTitlesLst = [];
    List<dynamic> restoredResultsLst = [];

    // Collect audio to delete instead of deleting immediately
    List<Audio> audioToDeleteLater = [];

    for (String playlistTitle in zipExistingPlaylistJsonContentsMap.keys) {
      Playlist? existingPlaylist;

      try {
        existingPlaylist = _listOfSelectablePlaylists
            .firstWhere((playlist) => playlist.title == playlistTitle);
      } catch (e) {
        continue;
      }

      final Map<String, dynamic> zipPlaylistJson =
          jsonDecode(zipExistingPlaylistJsonContentsMap[playlistTitle]!);

      Playlist zipPlaylist = Playlist.fromJson(zipPlaylistJson);

      List<int> resultLst = await _addNewAudioReferencesAvailableInZipPlaylist(
        existingPlaylist: existingPlaylist,
        zipPlaylist: zipPlaylist,
        archive: archive,
        doReplaceExistingPlaylists: doReplaceExistingPlaylists,
      );

      addedAudioReferencesCount += resultLst[0];
      addedCommentJsonFilesCount += resultLst[1];
      addedPicturesCount += resultLst[2];
      updatedCommentsCount += resultLst[3];
      addedCommentsCount += resultLst[4];
      deletedCommentsCount += resultLst[5];

      // Collect audio to delete instead of deleting immediately
      List<Audio> audioToDelete =
          _getAudioToDelete(existingPlaylist, zipPlaylist);
      audioToDeleteLater.addAll(audioToDelete);
    }

    // Now delete all collected audio after the main loop
    for (Audio audio in audioToDeleteLater) {
      deleteAudioFile(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
        audio: audio,
      );

      deletedAudioTitlesLst.add(audio.validVideoTitle);
    }

    restoredResultsLst.clear();
    restoredResultsLst.add(addedAudioReferencesCount);
    restoredResultsLst.add(addedCommentJsonFilesCount);
    restoredResultsLst.add(addedPicturesCount);
    restoredResultsLst.add(updatedCommentsCount);
    restoredResultsLst.add(addedCommentsCount);
    restoredResultsLst.add(deletedAudioTitlesLst);
    restoredResultsLst.add(deletedCommentsCount);

    return restoredResultsLst;
  }

  /// This method returns the audio which are in the existing playlist playable audio list and aren't
  /// in the zip playlist playable audio list and are in the zip playlist downloaded audio list. These
  /// audio are to be deleted as well as their comments, picture and mp3 file.
  List<Audio> _getAudioToDelete(
      Playlist existingPlaylist, Playlist zipPlaylist) {
    List<Audio> audioToDelete = [];

    for (Audio existingPlaylistPlayableAudio
        in existingPlaylist.playableAudioLst) {
      bool audioExistsInZipPlaylistPlayableLst =
          zipPlaylist.playableAudioLst.any(
        (zipPlayableAudio) =>
            zipPlayableAudio.audioFileName ==
            existingPlaylistPlayableAudio.audioFileName,
      );
      bool audioExistsInZipPlaylistDownloadedLst =
          zipPlaylist.downloadedAudioLst.any(
        (zipDownloadedAudio) =>
            zipDownloadedAudio.audioFileName ==
            existingPlaylistPlayableAudio.audioFileName,
      );

      if (!audioExistsInZipPlaylistPlayableLst &&
          audioExistsInZipPlaylistDownloadedLst) {
        audioToDelete.add(existingPlaylistPlayableAudio);
      }
    }

    return audioToDelete;
  }

  /// This method adds Audio instances of playlists corresponding to existing playlists which are
  /// available in the zip file and are not already present in the existing playlists.
  /// Additionally, the comments and pictures off the added audios are added to the existing
  /// playlists.
  ///
  /// The returned list of integers contains:
  ///   - The number of added audio references.
  ///   - The number of added comment json files.
  ///   - The number of added pictures.
  ///   - The number of modified comments.
  ///   - The number of added comments.
  ///   - The number of deleted comments.
  Future<List<int>> _addNewAudioReferencesAvailableInZipPlaylist({
    required Playlist existingPlaylist,
    required Playlist zipPlaylist,
    required Archive archive,
    required bool doReplaceExistingPlaylists,
  }) async {
    int addedAudioReferencesCount = 0;
    int addedCommentJsonFilesCount = 0;
    int addedPicturesCount = 0;
    List<int> restoredNumberLst = []; // restored number returned list
    List<int> commentUpdateNumberLst = [
      0,
      0,
      0,
      0
    ]; // [0] is the number of modified comments,
    //    [1] is the number of added comments,
    //    [2] is the number of deleted comments,
    //    [3] is the number of added comment
    //        json file (0 or 1 for an audio).

    // Iterate through downloaded audios from the zip playlist.
    for (Audio zipAudio in zipPlaylist.downloadedAudioLst) {
      // Check if this audio already exists in the existing playlist
      bool audioExistsInDownloadedAudioLst =
          existingPlaylist.downloadedAudioLst.any(
        (existingAudio) =>
            existingAudio.audioFileName == zipAudio.audioFileName,
      );

      if (!audioExistsInDownloadedAudioLst) {
        // This audio doesn't exist in the existing playlist.
        // Add it even if the physical file doesn't exist (can be
        // downloaded later).

        // Create a copy of the audio and add it to the downloaded
        // and playable audio lists.
        Audio audioToAdd = zipAudio.copy();
        audioToAdd.enclosingPlaylist = existingPlaylist;
        audioToAdd.audioPlaySpeed = existingPlaylist.audioPlaySpeed;

        // Add to the downloaded audio list.
        existingPlaylist.downloadedAudioLst.add(audioToAdd);

        // Add to the playable audio list using the method that
        // correctly handles the currentOrPastPlayableAudioIndex.
        existingPlaylist.playableAudioLst.insert(0, audioToAdd);
        existingPlaylist.currentOrPastPlayableAudioIndex++;

        if (!doReplaceExistingPlaylists) {
          // If doReplaceExistingPlaylists is true, the audio references
          // number were added to restoredAudioReferencesNumber before
          // the playlist json file was written. THIS CORRECTS A ENORMOUS
          // BUG.
          addedAudioReferencesCount++;
        }

        // Restore comment file for this audio if it exists in the zip
        if (await _restoreAudioCommentFileFromZip(
          archive: archive,
          audioToAdd: audioToAdd,
          existingPlaylist: existingPlaylist,
        )) {
          addedCommentJsonFilesCount++;
        }

        int restoredPicturesForAudio = await _restoreAudioPictureFilesFromZip(
          archive: archive,
          audioToAdd: audioToAdd,
          existingPlaylist: existingPlaylist,
          doReplaceExistingPlaylists: doReplaceExistingPlaylists,
        );

        addedPicturesCount += restoredPicturesForAudio;

        if (addedAudioReferencesCount > 0) {
          await _writePlaylistToFile(
            playlist: existingPlaylist,
          );
        }
      } else {
        // The audio already exists in the existing playlist.
        // Retrieve the existing audio instance.
        Audio existingAudio = existingPlaylist.downloadedAudioLst.firstWhere(
          (audio) => audio.audioFileName == zipAudio.audioFileName,
        );

        // ------------------ COMMENT RESTORATION ------------------
        String audioCommentFileName =
            zipAudio.audioFileName.replaceAll('.mp3', '.json');
        String zipAudioCommentFilePath = path.join(
          zipPlaylist.title, // root dir for the audio comment file in the zip
          kCommentDirName,
          audioCommentFileName,
        );

        // Normalize path
        zipAudioCommentFilePath = zipAudioCommentFilePath
            .replaceAll('\\', '/')
            .split('/')
            .map((segment) => segment.trim())
            .join('/');

        List<Comment>? zipAudioCommentsLst;

        // Search for the audio comment file in the zip archive
        for (ArchiveFile archiveFile in archive) {
          if (archiveFile.isFile &&
              archiveFile.name
                  .replaceAll('\\', '/')
                  .split('/')
                  .map((segment) => segment.trim())
                  .join('/')
                  .endsWith(zipAudioCommentFilePath)) {
            // Parse the JSON content from the archive file to get the list of comments
            String jsonContent = utf8.decode(archiveFile.content as List<int>);
            List<dynamic> jsonList = jsonDecode(jsonContent);
            zipAudioCommentsLst =
                jsonList.map((json) => Comment.fromJson(json)).toList();

            // Merge/update comments (adds + updates)
            List<int> audioCommentUpdateNumberLst =
                _commentVM.updateAudioComments(
              commentedAudio: existingAudio,
              updateCommentsLst: zipAudioCommentsLst,
            );

            commentUpdateNumberLst[0] +=
                audioCommentUpdateNumberLst[0]; // Updated comments
            commentUpdateNumberLst[1] +=
                audioCommentUpdateNumberLst[1]; // Added comments
            addedCommentJsonFilesCount +=
                audioCommentUpdateNumberLst[2]; // Added comment json file
            break;
          }
        }

        // In "Replace existing playlist(s)" mode, if we have a comment file
        // in the zip for this audio, we also remove comments that are no
        // longer present in the zip.
        if (doReplaceExistingPlaylists && zipAudioCommentsLst != null) {
          final Set<String> zipCommentIds =
              zipAudioCommentsLst.map((c) => c.id).toSet();

          // Comments AFTER the merge (updateAudioComments)
          final List<Comment> existingAfterMerge =
              _commentVM.loadAudioComments(audio: existingAudio);

          // How many comments will be deleted?
          final int deletedForThisAudio = existingAfterMerge
              .where((c) => !zipCommentIds.contains(c.id))
              .length;

          commentUpdateNumberLst[2] += deletedForThisAudio;

          // Keep only comments still present in the zip
          final List<Comment> finalExistingComments = existingAfterMerge
              .where((c) => zipCommentIds.contains(c.id))
              .toList()
            ..sort((a, b) => a.commentStartPositionInTenthOfSeconds
                .compareTo(b.commentStartPositionInTenthOfSeconds));

          JsonDataService.saveListToFile(
            data: finalExistingComments,
            jsonPathFileName: CommentVM.buildCommentFilePathName(
              playlistDownloadPath: existingPlaylist.downloadPath,
              audioFileName: existingAudio.audioFileName,
            ),
          );
        }

        // ------------------ PICTURE RESTORATION / DELETION ------------------

        if (doReplaceExistingPlaylists) {
          // Check whether the zip contains a picture JSON file for this audio.
          final String pictureJsonFileName =
              zipAudio.audioFileName.replaceAll('.mp3', '.json');
          String zipPictureJsonFilePath = path.join(
            kPictureDirName,
            pictureJsonFileName,
          );

          zipPictureJsonFilePath = zipPictureJsonFilePath
              .replaceAll('\\', '/')
              .split('/')
              .map((segment) => segment.trim())
              .join('/');

          bool zipHasPictureJson = false;

          for (ArchiveFile archiveFile in archive) {
            if (archiveFile.isFile &&
                archiveFile.name
                    .replaceAll('\\', '/')
                    .split('/')
                    .map((segment) => segment.trim())
                    .join('/')
                    .endsWith(zipPictureJsonFilePath)) {
              zipHasPictureJson = true;
              break;
            }
          }

          if (!zipHasPictureJson) {
            // In "replace" mode, if the zip has no picture JSON for this
            // audio at all, we must delete any local picture JSON file and
            // its associations in pictureAudioMap.json.
            _pictureVM.deleteAudioPictureJsonFileIfExist(
              audio: existingAudio,
            );
          }
        }

        // In both modes, try to restore picture files from the zip
        // (this will only add or update missing ones; deletion of obsolete
        // associations is handled inside _restoreAudioPictureFilesFromZip
        // when doReplaceExistingPlaylists is true).
        int restoredPicturesForExistingAudio =
            await _restoreAudioPictureFilesFromZip(
          archive: archive,
          audioToAdd: existingAudio,
          existingPlaylist: existingPlaylist,
          doReplaceExistingPlaylists: doReplaceExistingPlaylists,
        );

        addedPicturesCount += restoredPicturesForExistingAudio;
      }
    }

    restoredNumberLst.add(addedAudioReferencesCount);
    restoredNumberLst.add(addedCommentJsonFilesCount);
    restoredNumberLst.add(addedPicturesCount);
    restoredNumberLst
        .add(commentUpdateNumberLst[0]); // Number of modified comments
    restoredNumberLst
        .add(commentUpdateNumberLst[1]); // Number of added comments
    restoredNumberLst
        .add(commentUpdateNumberLst[2]); // Number of deleted comments

    return restoredNumberLst;
  }

  /// This method returns the playlist root directory of the playlist(s) included in the
  /// playlist zip file.
  String _getPlaylistZipRootDir({
    required Archive archive,
  }) {
    for (ArchiveFile archiveFile in archive) {
      if (!archiveFile.isFile || !archiveFile.name.endsWith('.json')) {
        continue;
      }

      String sanitizedPath = archiveFile.name.replaceAll('\\', '/');
      List<String> pathParts = sanitizedPath.split('/');

      if (pathParts.length >= 2) {
        String fileName = path.basenameWithoutExtension(sanitizedPath);
        String directoryName = pathParts[pathParts.length - 2];

        // Check if this is a playlist file (JSON name matches directory name)
        if (fileName == directoryName) {
          // Found a matching playlist file, determine the root directory
          if (pathParts.length == 2) {
            // Example "S8 audio.json". Playlist root directory is ''
            return '';
          } else if (pathParts.length >= 3) {
            // Example: "playlists/S8 audio/S8 audio.json" or
            // "myChooseName/S8 audio/S8 audio.json". Playlist root directory
            // is 'playlists/' or 'myChooseName/'
            return '${pathParts[0]}/';
          }
        }
      }
    }

    // Default fallback if no matching playlist file is found
    return '';
  }

  /// Save modified playlists.
  Future<void> _writePlaylistToFile({
    required Playlist playlist,
  }) async {
    try {
      final File playlistFile =
          File(playlist.getPlaylistDownloadFilePathName());
      final String playlistJson = jsonEncode(playlist.toJson());
      await playlistFile.writeAsString(playlistJson, flush: true);
    } catch (e) {
      _logger.i('Error saving playlist ${playlist.title}: $e');
    }
  }

  /// Restores the comment file for a specific audio from the zip if it exists.
  /// Returns true if a comment file was restored, false otherwise.
  Future<bool> _restoreAudioCommentFileFromZip({
    required Archive archive,
    required Audio audioToAdd,
    required Playlist existingPlaylist,
  }) async {
    // Build the comment file name expected in the zip
    String audioCommentFileName =
        audioToAdd.audioFileName.replaceAll('.mp3', '.json');
    String zipAudioCommentFilePath = path.join(
      kCommentDirName,
      audioCommentFileName,
    );

    // Normalize the zip audio comment file path to ensure consistent formatting
    zipAudioCommentFilePath = zipAudioCommentFilePath
        .replaceAll('\\', '/') // Convert all backslashes to forward slashes
        .split('/')
        .map((segment) => segment.trim())
        .join('/');

    // Search for the audio comment file in the zip archive
    for (ArchiveFile archiveFile in archive) {
      if (archiveFile.isFile &&
          archiveFile.name
              .replaceAll(
                  '\\', '/') // First convert all backslashes to forward slashes
              .split('/')
              .map((segment) => segment.trim())
              .join('/')
              .endsWith(zipAudioCommentFilePath)) {
        // Create target comment directory if it doesn't exist
        String targetCommentDirPath = path.join(
          existingPlaylist.downloadPath,
          kCommentDirName,
        );

        Directory targetCommentDir = Directory(targetCommentDirPath);

        // Ensure the target comment directory exists
        if (!targetCommentDir.existsSync()) {
          await targetCommentDir.create(recursive: true);
        }

        // Write the comment file to the target playlist

        String targetCommentFilePath = path.join(
          targetCommentDirPath,
          audioCommentFileName,
        );

        File targetCommentFile = File(targetCommentFilePath);

        try {
          // Parse the JSON content from the archive file to get the list of comments
          String jsonContent = utf8.decode(archiveFile.content as List<int>);
          List<dynamic> jsonList = jsonDecode(jsonContent);
          List<Comment> zipComments =
              jsonList.map((json) => Comment.fromJson(json)).toList();

          // Only restore if the comment file doesn't already exist
          if (!targetCommentFile.existsSync()) {
            // Write the comment file to disk
            await targetCommentFile.writeAsBytes(
              archiveFile.content as List<int>,
              flush: true,
            );

            // Update the audio comments using CommentVM
            _commentVM.updateAudioComments(
              commentedAudio: audioToAdd,
              updateCommentsLst: zipComments,
            );

            return true;
          } else {
            // Comment file already exists, just update the comments
            _commentVM.updateAudioComments(
              commentedAudio: audioToAdd,
              updateCommentsLst: zipComments,
            );
          }
        } catch (e) {
          _logger.e('Error parsing comment file from zip: $e');
          // If parsing fails, still try to write the raw file
          if (!targetCommentFile.existsSync()) {
            await targetCommentFile.writeAsBytes(
              archiveFile.content as List<int>,
              flush: true,
            );
          }
        }
        break;
      }
    }

    return false;
  }

  /// Restores picture files for a specific audio from the zip if they exist.
  /// Returns the number of picture files restored.
  Future<int> _restoreAudioPictureFilesFromZip({
    required Archive archive,
    required Audio audioToAdd,
    required Playlist existingPlaylist,
    required bool doReplaceExistingPlaylists,
  }) async {
    int restoredPicturesCount = 0;

    // Build the expected picture JSON file name in the zip
    String pictureJsonFileName =
        audioToAdd.audioFileName.replaceAll('.mp3', '.json');
    String zipPictureJsonFilePath = path.join(
      kPictureDirName,
      pictureJsonFileName,
    );

    // Normalize the zip picture JSON file path to ensure consistent formatting
    zipPictureJsonFilePath = zipPictureJsonFilePath
        .replaceAll('\\', '/')
        .split('/')
        .map((segment) => segment.trim())
        .join('/');

    List<Picture>? pictureLst;

    // Search for the picture JSON file in the zip archive
    for (ArchiveFile archiveFile in archive) {
      if (archiveFile.isFile &&
          archiveFile.name
              .replaceAll('\\', '/')
              .split('/')
              .map((segment) => segment.trim())
              .join('/')
              .endsWith(zipPictureJsonFilePath)) {
        // Parse the picture JSON file to get the list of pictures
        String jsonContent = utf8.decode(archiveFile.content as List<int>);
        List<dynamic> pictureJsonList = jsonDecode(jsonContent);

        pictureLst =
            pictureJsonList.map((json) => Picture.fromJson(json)).toList();

        if (pictureLst.isNotEmpty) {
          // Create target picture directory if it doesn't exist
          String targetPictureDirPath = path.join(
            existingPlaylist.downloadPath,
            kPictureDirName,
          );

          Directory targetPictureDir = Directory(targetPictureDirPath);
          if (!targetPictureDir.existsSync()) {
            await targetPictureDir.create(recursive: true);
          }

          // Write the picture JSON file to the target playlist
          String targetPictureJsonFilePath = path.join(
            targetPictureDirPath,
            pictureJsonFileName,
          );

          File targetPictureJsonFile = File(targetPictureJsonFilePath);

          if (doReplaceExistingPlaylists) {
            // In "Replace" mode, the zip version is the single source of truth:
            // overwrite the JSON file so that it matches exactly the pictures
            // contained in the zip.
            JsonDataService.saveListToFile(
              data: pictureLst,
              jsonPathFileName: targetPictureJsonFilePath,
            );

            // Ensure pictureAudioMap.json no longer contains associations
            // for pictures that are no longer present for this audio.
            _pictureVM.synchronizePictureAudioAssociationsForAudio(
              playlistTitle: existingPlaylist.title,
              audioFileName: audioToAdd.audioFileName,
              currentPictures: pictureLst,
            );

            // And ensure that all current pictures are associated (idempotent).
            for (Picture picture in pictureLst) {
              _pictureVM.addPictureAudioAssociationToAppPictureAudioMap(
                pictureFileName: picture.fileName,
                audioFileName: audioToAdd.audioFileName,
                audioPlaylistTitle: existingPlaylist.title,
              );
            }
          } else {
            // "Merge" mode: keep existing JSON if present, only create if missing
            if (!targetPictureJsonFile.existsSync()) {
              await targetPictureJsonFile.writeAsBytes(
                archiveFile.content as List<int>,
                flush: true,
              );
            }

            // Add associations for all pictures in the zip; this is idempotent
            for (Picture picture in pictureLst) {
              _pictureVM.addPictureAudioAssociationToAppPictureAudioMap(
                pictureFileName: picture.fileName,
                audioFileName: audioToAdd.audioFileName,
                audioPlaylistTitle: existingPlaylist.title,
              );
            }
          }

          restoredPicturesCount = pictureLst.length;
        }
        break;
      }
    }

    return restoredPicturesCount;
  }

  /// Restores MP3 audio files from a ZIP file to their respective playlist directories.
  /// Only copies MP3 files that correspond to Audio objects present in the
  /// playlist.playableAudioLst and that don't already exist in the playlist directory.
  ///
  /// Returns a dynamic list containing
  ///   the number of MP3 files that were successfully restored
  ///   the number of playlists to which a MP3 file was restored
  ///   if the MP3 zip file was a unique playlist restoration (true) or a multiple
  ///   playlist restoration (false).
  Future<List<dynamic>> restorePlaylistsAudioMp3FilesFromUniqueZip({
    required String zipFilePathName,
    required List<Playlist> listOfPlaylists,
    bool uniquePlaylistIsRestored = false,
  }) async {
    int restoredAudioCount = 0;
    List<String> playlistTitlesPresentInMp3ZipFileLst = [];
    List<String> restoredPlaylistTitlesLst = [];

    if (uniquePlaylistIsRestored) {
      // Used to show the restored unique playlist name in the audio download view
      _audioMp3RestorationCurrentPlaylistName = listOfPlaylists[0].title;
    }

    // Check if zip file exists
    File zipFile = File(zipFilePathName);

    if (!zipFile.existsSync()) {
      return [0, 0, false];
    }

    try {
      // Read and decode the ZIP file
      List<int> zipBytes = await zipFile.readAsBytes();
      Archive archive = ZipDecoder().decodeBytes(zipBytes);

      // Create a map of playlist titles to playlists for efficient lookup
      Map<String, Playlist> playlistMap = {};

      for (Playlist playlist in listOfPlaylists) {
        playlistMap[playlist.title] = playlist;
      }

      _isRestoringMp3 = true;
      notifyListeners();

      // Process each file in the archive
      for (ArchiveFile archiveFile in archive) {
        // Skip directories
        if (archiveFile.isFile && archiveFile.name.endsWith('.mp3')) {
          // ... code existant pour extraire playlistTitle et audioFileName ...

          final String sanitizedArchiveFilePathName = archiveFile.name
              .replaceAll('\\', '/')
              .split('/')
              .map((segment) => segment.trim())
              .join('/');

          List<String> pathParts = sanitizedArchiveFilePathName.split('/');

          if (pathParts.length >= 3 &&
              pathParts[0] == kImposedPlaylistsSubDirName) {
            String playlistTitle = pathParts[1];
            String audioFileName = pathParts[2];

            if (!playlistTitlesPresentInMp3ZipFileLst.contains(playlistTitle)) {
              playlistTitlesPresentInMp3ZipFileLst.add(playlistTitle);
            }

            // Find the corresponding playlist
            Playlist? playlist = playlistMap[playlistTitle];

            if (playlist != null) {
              // Check if this audio file corresponds to an Audio in playableAudioLst
              bool shouldRestore = false;
              for (Audio audio in playlist.playableAudioLst) {
                if (audio.audioFileName == audioFileName) {
                  shouldRestore = true;
                  break;
                }
              }

              if (shouldRestore) {
                String targetFilePath =
                    path.join(playlist.downloadPath, audioFileName);
                File targetFile = File(targetFilePath);

                if (!targetFile.existsSync()) {
                  restoredAudioCount = await _addMp3FileToPlaylist(
                    archiveFile: archiveFile,
                    targetFile: targetFile,
                    playlist: playlist,
                    playlistTitle: playlistTitle,
                    audioFileName: audioFileName,
                    restoredPlaylistTitlesLst: restoredPlaylistTitlesLst,
                    restoredAudioCount: restoredAudioCount,
                  );
                } else {
                  // File already exists
                  Audio existingAudio = playlist.playableAudioLst.firstWhere(
                    (audio) => audio.audioFileName == audioFileName,
                  );

                  if (existingAudio.audioType == AudioType.textToSpeech) {
                    // If the existing audio is a text-to-speech audio,
                    // the most recent comment end position is used to
                    // check if the audio restored from the zip file
                    // has the same duration as the last comment end position.
                    // If it is the case, the existing audio is replaced by
                    // the audio restored from the zip file.
                    //
                    // The most recent comment was added by restoring the
                    // multiple playlists, comments, pictures and settings
                    // from a zip file or restoring a unique playlist, comments
                    // and picture from a zip file. Without first restoring
                    // the multiple playlists, comments, pictures and settings
                    // from a zip file or restoring a unique playlist before
                    // restoring the MP3 files from a zip file, the last comment
                    // end position cannot be used to determine if the audio
                    // restored from the zip file has the same duration as the
                    // last comment end position and so the text to speech audio
                    // will not be replaced to the last generated one.
                    Comment? lastComment = _commentVM.getLastCommentOfAudio(
                      audio: existingAudio,
                    );

                    if (lastComment != null) {
                      int commentEndPositionInTenthOfSeconds =
                          lastComment.commentEndPositionInTenthOfSeconds;
                      List<dynamic> audioInZipDurationAndSizeLst =
                          await _audioDownloadVM.getAudioMp3DurationAndSize(
                        audioMp3ArchiveFile: archiveFile,
                        playlistDownloadPath: playlist.downloadPath,
                      );

                      Duration audioInZipDuration =
                          audioInZipDurationAndSizeLst[0] as Duration;
                      int audioInZipDurationInTenthOfSeconds =
                          (audioInZipDuration.inMilliseconds / 100).round();

                      AudioPlayer? audioPlayer =
                          _audioDownloadVM.instanciateAudioPlayer();

                      Duration existingAudioMp3Duration =
                          await _audioDownloadVM.getMp3DurationWithAudioPlayer(
                        audioPlayer: audioPlayer, // RÉUTILISER ICI
                        filePathName: existingAudio.filePathName,
                      );

                      if (audioPlayer != null) {
                        // Dispose the audio player after using it, otherwise an
                        // exception prevents to access to the audio file to restore
                        // it in _addMp3FileToPlaylist.
                        await audioPlayer.dispose();
                      }

                      int existingAudioDurationInTenthOfSeconds =
                          (existingAudioMp3Duration.inMilliseconds / 100)
                              .round();

                      if ((commentEndPositionInTenthOfSeconds ==
                              audioInZipDurationInTenthOfSeconds) &&
                          (existingAudioDurationInTenthOfSeconds !=
                              audioInZipDurationInTenthOfSeconds)) {
                        restoredAudioCount = await _addMp3FileToPlaylist(
                          archiveFile: archiveFile,
                          targetFile: targetFile,
                          playlist: playlist,
                          playlistTitle: playlistTitle,
                          audioFileName: audioFileName,
                          restoredPlaylistTitlesLst:
                              restoredPlaylistTitlesLst, // this list is updated in
                          //                                _addMp3FileToPlaylist() !
                          restoredAudioCount: restoredAudioCount,
                          isTextToSpeechMp3: true,
                          audioDuration: audioInZipDuration,
                          audioFileSize: audioInZipDurationAndSizeLst[1] as int,
                        );
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      _isRestoringMp3 = false;
      notifyListeners();
    } catch (e) {
      _logger.i(
          'In restorePlaylistsAudioMp3FilesFromUniqueZip(), error processing ZIP file $zipFilePathName: $e');
    }

    return [
      restoredAudioCount,
      restoredPlaylistTitlesLst.length,
      uniquePlaylistIsRestored,
    ];
  }

  /// Restores MP3 audio files from multiple ZIP files located in a directory.
  /// All ZIP files in the specified directory are processed.
  ///
  /// Only copies MP3 files that correspond to Audio objects present in the
  /// playlist.playableAudioLst and that don't already exist in the playlist directory.
  ///
  /// Parameters:
  /// - [zipDirectoryPath]: The directory path containing one or more ZIP files
  /// - [listOfPlaylists]: List of all application playlists
  ///
  /// Returns a dynamic list containing:
  /// [
  ///   total number of MP3 files that were successfully restored (int),
  ///   number of ZIP files processed (int),
  ///   list of playlist titles that received restored files (List of String's)
  /// ]
  Future<List<dynamic>> _restorePlaylistsAudioMp3FilesFromMultipleZips({
    required String zipDirectoryPath,
    required List<Playlist> listOfPlaylists,
  }) async {
    int totalRestoredAudioCount = 0;
    Set<String> restoredPlaylistTitlesSet = {};
    int processedZipCount = 0;
    List<dynamic> emptyDynamicLst = [0, 0, []];

    try {
      // Check if the directory exists
      Directory zipDirectory = Directory(zipDirectoryPath);

      if (!await zipDirectory.exists()) {
        _logger.e('ZIP directory does not exist: "$zipDirectoryPath"');
        return emptyDynamicLst;
      }

      // Find all ZIP files in the directory
      List<FileSystemEntity> entities = await zipDirectory.list().toList();
      List<File> zipFiles = entities
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.zip'))
          .toList();

      if (zipFiles.isEmpty) {
        _logger.w('No ZIP files found in directory: $zipDirectoryPath');
        return emptyDynamicLst;
      }

      _logger.i('Found ${zipFiles.length} ZIP file(s) in $zipDirectoryPath');

      // Create a map of playlist titles to playlists for efficient lookup
      Map<String, Playlist> playlistMap = {};
      for (Playlist playlist in listOfPlaylists) {
        playlistMap[playlist.title] = playlist;
      }

      _isRestoringMp3 = true;
      notifyListeners();

      // Process each ZIP file
      for (File zipFile in zipFiles) {
        String zipFileName = path.basename(zipFile.path);
        _logger.i('Processing ZIP file: $zipFileName');

        try {
          // Read and decode the ZIP file
          List<int> zipBytes = await zipFile.readAsBytes();
          Archive archive = ZipDecoder().decodeBytes(zipBytes);

          int zipRestoredCount = 0;

          // Process each file in the archive
          for (ArchiveFile archiveFile in archive) {
            // Skip directories
            if (!archiveFile.isFile || !archiveFile.name.endsWith('.mp3')) {
              continue;
            }

            // Normalize path separators (handles both Windows and Android zips)
            final String sanitizedArchiveFilePathName = archiveFile.name
                .replaceAll('\\', '/')
                .split('/')
                .map((segment) => segment.trim())
                .join('/');

            // Extract playlist name and audio file name from the path
            // Expected path format: playlists/PlaylistTitle/audioFileName.mp3
            List<String> pathParts = sanitizedArchiveFilePathName.split('/');

            if (pathParts.length >= 3 &&
                pathParts[0] == kImposedPlaylistsSubDirName) {
              String playlistTitle = pathParts[1];
              String audioFileName = pathParts[2];

              // Find the corresponding playlist
              Playlist? playlist = playlistMap[playlistTitle];

              if (playlist == null) {
                _logger.w(
                    'Playlist not found: $playlistTitle (from $zipFileName)');
                continue;
              }

              // Check if this audio file corresponds to an Audio in playableAudioLst
              Audio? targetAudio;
              for (Audio audio in playlist.playableAudioLst) {
                if (audio.audioFileName == audioFileName) {
                  targetAudio = audio;
                  break;
                }
              }

              if (targetAudio == null) {
                _logger.d('Audio not in playableAudioLst: $audioFileName');
                continue;
              }

              // Create the target file path
              String targetFilePath =
                  path.join(playlist.downloadPath, audioFileName);
              File targetFile = File(targetFilePath);

              // Only restore if the file doesn't already exist
              if (!targetFile.existsSync()) {
                // Used to show the restored current playlist name in the audio download view
                _audioMp3RestorationCurrentPlaylistName = playlist.title;
                notifyListeners();

                int addResult = await _addMp3FileToPlaylist(
                  archiveFile: archiveFile,
                  targetFile: targetFile,
                  playlist: playlist,
                  playlistTitle: playlistTitle,
                  audioFileName: audioFileName,
                  restoredPlaylistTitlesLst: [], // Not used in this context
                  restoredAudioCount: 0, // Not used in this context
                );

                if (addResult > 0) {
                  zipRestoredCount++;
                  totalRestoredAudioCount++;
                  restoredPlaylistTitlesSet.add(playlistTitle);
                  _logger.d('Restored: $audioFileName to $playlistTitle');
                }
              } else {
                // Handle text-to-speech audio replacement logic
                if (targetAudio.audioType == AudioType.textToSpeech) {
                  // If the existing audio is a text-to-speech audio,
                  // the most recent comment end position is used to
                  // check if the audio restored from the zip file
                  // has the same duration as the last comment end position.
                  // If it is the case, the existing audio is replaced by
                  // the audio restored from the zip file.
                  //
                  // The most recent comment was added by restoring the
                  // multiple playlists, comments, pictures and settings
                  // from a zip file or restoring a unique playlist, comments
                  // and picture from a zip file. Without first restoring
                  // the multiple playlists, comments, pictures and settings
                  // from a zip file or restoring a unique playlist before
                  // restoring the MP3 files from a zip file, the last comment
                  // end position cannot be used to determine if the audio
                  // restored from the zip file has the same duration as the
                  // last comment end position and so the text to speech audio
                  // will not be replaced to the last generated one.
                  Comment? lastComment = _commentVM.getLastCommentOfAudio(
                    audio: targetAudio,
                  );

                  if (lastComment != null) {
                    int commentEndPositionInTenthOfSeconds =
                        lastComment.commentEndPositionInTenthOfSeconds;

                    List<dynamic> audioInZipDurationAndSizeLst =
                        await _audioDownloadVM.getAudioMp3DurationAndSize(
                      audioMp3ArchiveFile: archiveFile,
                      playlistDownloadPath: playlist.downloadPath,
                    );

                    Duration audioInZipDuration =
                        audioInZipDurationAndSizeLst[0] as Duration;
                    int audioInZipDurationInTenthOfSeconds =
                        (audioInZipDuration.inMilliseconds / 100).round();

                    AudioPlayer? audioPlayer =
                        _audioDownloadVM.instanciateAudioPlayer();

                    Duration existingAudioMp3Duration =
                        await _audioDownloadVM.getMp3DurationWithAudioPlayer(
                      audioPlayer: audioPlayer, // RÉUTILISER ICI
                      filePathName: targetAudio.filePathName,
                    );

                    if (audioPlayer != null) {
                      // Dispose the audio player after using it, otherwise an
                      // exception prevents to access to the audio file to restore
                      // it in _addMp3FileToPlaylist.
                      await audioPlayer.dispose();
                    }

                    int existingAudioDurationInTenthOfSeconds =
                        (existingAudioMp3Duration.inMilliseconds / 100).round();

                    if ((commentEndPositionInTenthOfSeconds ==
                            audioInZipDurationInTenthOfSeconds) &&
                        (existingAudioDurationInTenthOfSeconds !=
                            audioInZipDurationInTenthOfSeconds)) {
                      // Used to show the restored current playlist name in the audio download view
                      _audioMp3RestorationCurrentPlaylistName = playlist.title;
                      notifyListeners();

                      int addResult = await _addMp3FileToPlaylist(
                        archiveFile: archiveFile,
                        targetFile: targetFile,
                        playlist: playlist,
                        playlistTitle: playlistTitle,
                        audioFileName: audioFileName,
                        restoredPlaylistTitlesLst: [],
                        restoredAudioCount: 0,
                        isTextToSpeechMp3: true,
                        audioDuration: audioInZipDuration,
                        audioFileSize: audioInZipDurationAndSizeLst[1] as int,
                      );

                      if (addResult > 0) {
                        zipRestoredCount++;
                        totalRestoredAudioCount++;
                        restoredPlaylistTitlesSet.add(playlistTitle);
                        _logger.d('Replaced text-to-speech: $audioFileName');
                      }
                    }
                  }
                }
              }
            }
          }

          processedZipCount++;
          _logger
              .i('Completed $zipFileName: $zipRestoredCount file(s) restored');
        } catch (e) {
          _logger.e('Error processing ZIP file $zipFileName: $e');
          // Continue with next ZIP file
        }
      }

      _isRestoringMp3 = false;
      notifyListeners();

      _logger.i(
          'Restoration complete: $totalRestoredAudioCount file(s) from $processedZipCount ZIP(s)');

      return [
        totalRestoredAudioCount,
        processedZipCount,
        restoredPlaylistTitlesSet.toList(),
      ];
    } catch (e) {
      _logger.e('Error in restorePlaylistsAudioMp3FilesFromMultipleZips: $e');

      _isRestoringMp3 = false;
      notifyListeners();

      return [0, 0, 0, [], []];
    }
  }

  /// Convenience method that calls restorePlaylistsAudioMp3FilesFromMultipleZips
  /// and displays a confirmation message to the user.
  ///
  /// This wraps the core restoration logic and handles UI feedback.
  Future<void> restoreAndConfirmPlaylistsAudioMp3FilesFromMultipleZips({
    required String zipDirectoryPath,
    required List<Playlist> listOfPlaylists,
  }) async {
    List<dynamic> resultLst =
        await _restorePlaylistsAudioMp3FilesFromMultipleZips(
      zipDirectoryPath: zipDirectoryPath,
      listOfPlaylists: listOfPlaylists,
    );

    int totalRestoredAudioCount = resultLst[0];
    int processedZipCount = resultLst[1];
    List<String> restoredPlaylistTitles =
        resultLst[2].isNotEmpty ? resultLst[2] as List<String> : [];

    // Display confirmation message via WarningMessageVM
    _warningMessageVM.confirmRestoringAudioMp3FromMultipleZips(
      multipleZipsDirectoryPath: zipDirectoryPath,
      totalRestoredAudioCount: totalRestoredAudioCount,
      processedZipCount: processedZipCount,
      restoredPlaylistTitles: restoredPlaylistTitles,
    );

    notifyListeners();
  }

  Future<int> _addMp3FileToPlaylist({
    required ArchiveFile archiveFile,
    required File targetFile,
    required Playlist playlist,
    required String playlistTitle,
    required String audioFileName,
    required List<String> restoredPlaylistTitlesLst,
    required int restoredAudioCount,
    bool isTextToSpeechMp3 = false,
    Duration audioDuration = const Duration(),
    int audioFileSize = 0,
  }) async {
    try {
      // Ensure the playlist directory exists
      Directory playlistDir = Directory(playlist.downloadPath);

      if (!playlistDir.existsSync()) {
        await playlistDir.create(recursive: true);
      }

      // Extract and write the file

      // This is necessary, otherwise if the restored audio has been
      // played, then executing await targetFile.writeAsBytes(fileBytes)
      // causes an error because the audio player has the file opened in
      // it. But this only required with AudioPlayer 5.2.1 !
      // await audioPlayerVMlistenFalse.initializeAudioPlayer();

      List<int> fileBytes = archiveFile.content as List<int>;
      await targetFile.writeAsBytes(fileBytes);

      if (!restoredPlaylistTitlesLst.contains(playlistTitle)) {
        restoredPlaylistTitlesLst.add(playlistTitle);
      }

      restoredAudioCount++;

      if (isTextToSpeechMp3) {
        // If the restored MP3 file is a text-to-speech audio,
        // update its duration and size in the playlist's
        // playableAudioLst audio instance.
        Audio? restoredAudio;
        try {
          restoredAudio = playlist.playableAudioLst.firstWhere(
            (audio) => audio.audioFileName == audioFileName,
          );
        } catch (e) {
          // Audio not found, nothing to update
        }

        if (restoredAudio != null) {
          restoredAudio.audioDuration = audioDuration;
          restoredAudio.audioFileSize = audioFileSize;
        }
      }
    } catch (e) {
      // Log error but continue with other files
      _logger.i(
          'In _addMp3FileToPlaylist(), error restoring file $audioFileName to playlist $playlistTitle: $e');
    }

    return restoredAudioCount;
  }

  /// Method called when the user clicks on the 'Rewind audio to start' playlist
  /// menu item. The method rewinds the audio to start and saves the playlist
  /// to its json file.
  ///
  /// Passing the {audioPlayerVM} is necessary in order to rewind the current
  /// audio to start position. Otherwise, after clicking on the play audio view
  /// button, the current audio will be positioned to the last played position
  /// instead of the start position.
  int rewindPlayableAudioToStart({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required Playlist playlist,
  }) {
    // Obtaining the playable audio list ordered according to the
    // sort/filter parameters applied to the audio player view.
    List<Audio> audioPlayerViewAudioLst =
        getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
            audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
            playlist: playlist);

    int rewindedAudioNumber = 0;

    if (audioPlayerViewAudioLst.isNotEmpty) {
      rewindedAudioNumber = playlist.rewindPlayableAudioToStart(
          audioToRewindLst: audioPlayerViewAudioLst);

      // Obtaining the playable audio list ordered according to the
      // sort/filter parameters applied to the playlist download view.
      List<Audio> playlistDownloadViewAudioLst =
          getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );

      Audio currentAudioInAudioPlayableListDialog;

      if (playlist.audioPlayingOrder == AudioPlayingOrder.descending) {
        // If the audio playing order is descending, we need to
        // set the current audio to the first playable audio.
        currentAudioInAudioPlayableListDialog = audioPlayerViewAudioLst.first;
      } else {
        // If the audio playing order is ascending, we need to
        // set the current audio to the last playable audio.
        currentAudioInAudioPlayableListDialog = audioPlayerViewAudioLst.last;
      }

      audioPlayerVMlistenFalse.setCurrentAudio(
          audio: currentAudioInAudioPlayableListDialog);

      // Setting the current audio index in the download playlist
      // view audio list
      playlist.currentOrPastPlayableAudioIndex =
          playlistDownloadViewAudioLst.indexOf(
        currentAudioInAudioPlayableListDialog,
      );
    }

    if (playlist.currentOrPastPlayableAudioIndex != -1 &&
        audioPlayerVMlistenFalse.currentAudio != null) {
      audioPlayerVMlistenFalse.skipToStart(
        // This parameter value avoids that the current audio is
        // set the previous audio position after rewinding the
        // current audio to start position.
        isAfterRewindingAudioPosition: true,
      );
    }

    if (rewindedAudioNumber > 0) {
      JsonDataService.saveToFile(
        model: playlist,
        path: playlist.getPlaylistDownloadFilePathName(),
      );
    }

    notifyListeners();

    return rewindedAudioNumber;
  }

  /// Method called when the user clicks on the Save button in the application
  /// settings dialog.
  void updatePlaylistRootPathAndSavePlaylistTitleOrder({
    required String actualPlaylistRootPath,
    required String modifiedPlaylistRootPath,
    required String playlistTitleOrderPathFileName,
  }) {
    // if (!_settingsDataService.isTest && !actualPlaylistRootPath.endsWith(kImposedPlaylistsSubDirName)) {
    // if (!actualPlaylistRootPath.endsWith(kImposedPlaylistsSubDirName)) {
    //   // No change in the playlists root path.
    //   return;
    // } not working
    _settingsDataService.savePlaylistTitleOrder(
      directory: actualPlaylistRootPath,
    );

    _settingsDataService.set(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath,
        value: modifiedPlaylistRootPath);

    _settingsDataService.saveSettings();

    _audioDownloadVM.playlistsRootPath = modifiedPlaylistRootPath;

    // Since the playlists root path was changed, the playlists managed
    // by the application must be updated
    updateSettingsAndPlaylistJsonFiles(
      updatePlaylistPlayableAudioList: false,
      unselectAddedPlaylist: false,
    );

    if (playlistTitleOrderPathFileName.isNotEmpty) {
      _settingsDataService.restorePlaylistTitlesOrderAndSaveSettings(
        playlistTitleOrderPathFileName: playlistTitleOrderPathFileName,
      );
    }

    // The next instructions are necessary in order to select the
    // playlist which was in selection state before the playlists root path
    // was changed previously. Without these instructions, the playlist
    // selected before changing the playlists root path to a new root path
    // and displayed in the right order after changing the playlists root
    // path to the initial root path will not be selected.

    // Forcing audio download VM to reload the playlists, otherwise the
    // playlists contained in its list of playlists will all be unselected !
    _audioDownloadVM.loadExistingPlaylists();

    Playlist? playlistListVMselectedPlaylist =
        getSelectedPlaylists().firstWhereOrNull(
      (element) => element.isSelected,
    );

    if (playlistListVMselectedPlaylist != null) {
      // required so that the selected playlist title text field
      // of the playlist download view is updated
      _uniqueSelectedPlaylist = playlistListVMselectedPlaylist;
    }
  }

  /// Method called when the user click on the audio popup menu in order to
  /// enable or not the 'Save sort/filter parameters to playlist' menu item.
  bool isSaveSFparmsToPlaylistMenuEnabled({
    required AudioLearnAppViewType audioLearnAppViewType,
    required String translatedAppliedSortFilterParmsName,
    required String translatedDefaultSortFilterParmsName,
  }) {
    String selectedSortFilterParametersName =
        getSelectedPlaylistAudioSortFilterParmsNameForView(
      audioLearnAppViewType: audioLearnAppViewType,
      translatedAppliedSortFilterParmsName:
          translatedAppliedSortFilterParmsName,
    );

    if (selectedSortFilterParametersName.isEmpty) {
      return false;
    }

    if (selectedSortFilterParametersName !=
            translatedAppliedSortFilterParmsName &&
        selectedSortFilterParametersName !=
            translatedDefaultSortFilterParmsName &&
        !isSortFilterAudioParmsAlreadySavedInPlaylistForAllViews(
          selectedSortFilterParametersName: selectedSortFilterParametersName,
        )) {
      return true;
    }

    return false;
  }

  /// Method called when the user click on the audio popup menu in order to
  /// enable or not the 'Save sort/filter parameters to playlist' menu item.
  ///
  /// This menu item is enabled if a sort filter parms is applied to one or
  /// two views of the selected playlist
  bool isRemoveSFparmsFromPlaylistMenuEnabled({
    required AudioLearnAppViewType audioLearnAppViewType,
    required String translatedAppliedSortFilterParmsName,
  }) {
    String selectedSortFilterParametersName =
        getSelectedPlaylistAudioSortFilterParmsNameForView(
      audioLearnAppViewType: audioLearnAppViewType,
      translatedAppliedSortFilterParmsName:
          translatedAppliedSortFilterParmsName,
    );

    // The resultLst list content is
    // [
    //   the sort and filter parameters name applied to the playlist download
    //   view or/and to the audio player view or uniquely to the audio player
    //   view,
    //   is audioSortFilterParmsName applied to playlist download view,
    //   is audioSortFilterParmsName applied to audio player view,
    // ]
    List<dynamic> resultLst =
        getSortFilterParmsNameApplicationValuesToCurrentPlaylist(
      selectedSortFilterParmsName: selectedSortFilterParametersName,
    );

    return resultLst[0].isNotEmpty;
  }

  void setPlaylistAudioQuality({
    required Playlist playlist,
    required PlaylistQuality playlistQuality,
  }) {
    playlist.playlistQuality = playlistQuality;

    JsonDataService.saveToFile(
      model: playlist,
      path: playlist.getPlaylistDownloadFilePathName(),
    );

    // Necessary in order to update the playlist quality
    // checkbox in the playlist download view.
    _audioDownloadVM.updatePlaylistAudioQuality(
      playlist: playlist,
    );
  }

  int getPlaylistAudioPictureNumber({
    required Playlist playlist,
  }) {
    int playlistAudioPictureNumber = 0;

    List<Audio> playlistAudioLst = playlist.playableAudioLst;

    for (Audio audio in playlistAudioLst) {
      playlistAudioPictureNumber += _pictureVM.getAudioPicturesNumber(
        audio: audio,
      );
    }

    return playlistAudioPictureNumber;
  }

  bool renamePlaylist({
    required Playlist playlist,
    required String modifiedPlaylistTitle,
  }) {
    final String previousPlaylistTitle = playlist.title;

    if (previousPlaylistTitle == modifiedPlaylistTitle) {
      return false; // No change
    }

    if (modifiedPlaylistTitle.contains(',')) {
      // A playlist title containing one or several commas can not
      // be handled by the application due to the fact that when
      // this playlist title will be added in the  playlist ordered
      // title list of the SettingsDataService, since the elements
      // of this list are separated by a comma, the playlist title
      // containing one or more commas will be divided in two or more
      // titles which will then not be findable in the playlist
      // directory. For this reason, adding such a playlist is refused
      // by the method.
      _warningMessageVM.invalidModifiedPlaylistTitle = modifiedPlaylistTitle;

      return false;
    }

    try {
      final Playlist playlistWithThisTitleAlreadyExist =
          _listOfSelectablePlaylists
              .firstWhere((element) => element.title == modifiedPlaylistTitle);
      // User clicked on the 'Rename' button of the playlist rename dialog,
      // but the playlist with the entered modified title already exists in
      // in the selectable playlist list. This makes impossible to rename the
      // the playlist with this title.
      //
      // Since orElse is not defined, firstWhere throws an exception if no
      // playlist with this title is found.
      _warningMessageVM.setPlaylistWithTitleAlreadyExist(
          playlistTitle: playlistWithThisTitleAlreadyExist.title);

      return false;
    } catch (_) {
      // Here, the playlist with the entered modification title was not found
      // in the application list of playlists. This means that the title is
      // usable. Since the next code is asynchronous, it can not be included
      // on the firstWhere.onElse: parameter and instead is located after this
      // catch {...} block.
    }

    if (!DirUtil.renameFile(
      fileToRenameFilePathName:
          '${playlist.downloadPath}${path.separator}$previousPlaylistTitle.json',
      newFileName: '$modifiedPlaylistTitle.json',
    )) {
      _logger.e(
          'Error renaming playlist json file from $previousPlaylistTitle to $modifiedPlaylistTitle');
      return false;
    }

    final String renamedDirectoryPath = DirUtil.renameDirectory(
      directoryToRenamePath: playlist.downloadPath,
      newDirectoryName: modifiedPlaylistTitle,
    );

    if (renamedDirectoryPath.isEmpty) {
      // Suppress the renaming playlist json file
      DirUtil.renameFile(
        fileToRenameFilePathName:
            '${playlist.downloadPath}${path.separator}$modifiedPlaylistTitle.json',
        newFileName: '$previousPlaylistTitle.json',
      );
      return false;
    }

    playlist.title = modifiedPlaylistTitle;

    if (playlist.playlistType == PlaylistType.local) {
      playlist.id = modifiedPlaylistTitle;
    }

    playlist.downloadPath = renamedDirectoryPath;

    _pictureVM.applyPlaylistRenamedToAppPictureAudioMap(
      previousPlaylistTitle: previousPlaylistTitle,
      modifiedPlaylistTitle: modifiedPlaylistTitle,
    );

    JsonDataService.saveToFile(
      model: playlist,
      path: playlist.getPlaylistDownloadFilePathName(),
    );

    updateSettingsAndPlaylistJsonFiles(
      unselectAddedPlaylist: false,
      updatePlaylistPlayableAudioList: false,
    );

    return true;
  }

  /// Adds numeric prefixes (1_, 2_, 3_, ...) to all Audio.validVideoTitle
  /// in contained in the playlist playable audio list and saves the modified
  /// playlist back to its JSON file.
  ///
  /// The numbering starts from 1 at the end of the playable audio list and
  /// augment till the start of the list.
  ///
  /// Example: "Mon Titre" becomes "1_Mon Titre"
  void addNumericPrefixesToPlaylistAudioTitles({
    required String playlistJsonPathFileName,
  }) {
    // Check if the file exists
    if (!File(playlistJsonPathFileName).existsSync()) {
      _logger.i('Error: File not found: $playlistJsonPathFileName');
      return;
    }

    // Load the playlist from the JSON file
    Playlist? playlist = JsonDataService.loadFromFile(
      jsonPathFileName: playlistJsonPathFileName,
      type: Playlist,
    ) as Playlist?;

    if (playlist == null) {
      _logger.i('Error: Unable to load playlist from $playlistJsonPathFileName');
      return;
    }

    _logger.i('Processing playlist: ${playlist.title}');
    _logger.i('Playable audios: ${playlist.playableAudioLst.length}');

    // Add numeric prefixes to playableAudioLst
    // Reset counter or continue from downloadedAudioLst count
    int counter = 1;
    for (var audio in playlist.playableAudioLst.reversed) {
      // Only add prefix if it doesn't already start with a number followed by underscore
      if (!RegExp(r'^\d+_').hasMatch(audio.validVideoTitle)) {
        audio.validVideoTitle = '${counter}_${audio.validVideoTitle}';
        _logger.i('  [$counter] ${audio.validVideoTitle}');
      } else {
        _logger.i('  [$counter] ${audio.validVideoTitle} (already has prefix)');
      }
      counter++;
    }

    // Save the modified playlist back to the JSON file
    JsonDataService.saveToFile(
      model: playlist,
      path: playlistJsonPathFileName,
    );

    _logger.i('Successfully saved modified playlist to $playlistJsonPathFileName');

    updateSettingsAndPlaylistJsonFiles(
      updatePlaylistPlayableAudioList: true,
    );
  }
}
