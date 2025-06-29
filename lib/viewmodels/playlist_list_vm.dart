import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:audiolearn/viewmodels/picture_vm.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../models/comment.dart';
import '../models/picture.dart';
import '../models/playlist.dart';
import '../services/audio_sort_filter_service.dart';
import '../services/json_data_service.dart';
import '../services/settings_data_service.dart';
import '../services/sort_filter_parameters.dart';
import '../utils/dir_util.dart';
import 'audio_download_vm.dart';
import 'audio_player_vm.dart';
import 'comment_vm.dart';
import 'warning_message_vm.dart';

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
        // containing on or more commas will be divided in two or more
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
  /// where the'Replace existing playlists' checkbox was set to true
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
        .indexWhere((playlist) => playlist.id == playlistToDelete.id);

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
      if (playlistOrder[0] == '' ||
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
  Future<void> downloadSelectedPlaylists() async {
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
  }) {
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

    Playlist selectedPlaylist =
        selectedPlaylists[0]; // currently, only one playlist can be selected
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
  }) async {
    String savedZipFilePathName = await _saveAllJsonFilesToZip(
      targetDir: targetDirectoryPath,
    );

    if (savedZipFilePathName.isEmpty) {
      // The case if the target directory does not exist or is invalid.
      // In this situation, since the passed savedZipFilePathName is empty,
      // a warning message is displayed instead of a confirmation message.
      _warningMessageVM.confirmSavingToZip(
        zipFilePathName: savedZipFilePathName,
        savedPictureNumber: 0,
      );

      return savedZipFilePathName;
    }

    // Saving the picture jpg files to the 'pictures' directory
    // located in the target directory where the zip file is saved.
    int savedPictureNumber = _pictureVM.savePictureJpgFilesToTargetDirectory(
      targetDirectoryPath: targetDirectoryPath,
    );

    _warningMessageVM.confirmSavingToZip(
        zipFilePathName: savedZipFilePathName,
        savedPictureNumber: savedPictureNumber);

    return savedZipFilePathName;
  }

  /// Returns the saved zip file path name, '' if the playlists source dir or the
  /// target dir in which to save the zip does not exist.
  Future<String> _saveAllJsonFilesToZip({
    required String targetDir,
  }) async {
    String playlistsRootPath = _settingsDataService.get(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath);
    String applicationPath = _settingsDataService.get(
      settingType: SettingType.dataLocation,
      settingSubType: DataLocation.appSettingsPath,
    );

    Directory sourceDir = Directory(playlistsRootPath);

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
    }

    // Save the archive to a zip file in the target directory
    String zipFileName =
        "audioLearn_${yearMonthDayDateTimeFormatForFileName.format(DateTime.now())}.zip";

    String zipFilePathName = path.join(targetDir, zipFileName);

    File zipFile = File(zipFilePathName);
    zipFile.writeAsBytesSync(ZipEncoder().encode(archive), flush: true);

    return zipFilePathName;
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
        savedPictureNumber: savedPictureNumber,
        uniquePlaylistIsSaved: true);
    return savedZipFilePathName;
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
  }) async {
    String selectedPlaylistBeforeRestoreTitle = '';

    if (_uniqueSelectedPlaylist != null) {
      selectedPlaylistBeforeRestoreTitle = _uniqueSelectedPlaylist!.title;
    }

    // Restoring the playlists, comments and settings json files
    // from the zip file. The dynamic list restoredInfoLst list
    // contains the list of restored playlist titles and the number
    // of restored comments.
    List<dynamic> restoredInfoLst = await _restoreFilesFromZip(
      zipFilePathName: zipFilePathName,
      doReplaceExistingPlaylists: doReplaceExistingPlaylists,
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

    // Does not work, so is temporaryly commented out.

    // String? pictureSourceDirectoryPath =
    //     await FilePicker.platform.getDirectoryPath();

    // // Saving the picture jpg files to the 'pictures' directory
    // // located in the target directory where the zip file is saved.
    // int restoredPictureNumber =
    //     _pictureVM.restorePictureJpgFilesFromSourceDirectory(
    //   sourceDirectoryPath: pictureSourceDirectoryPath ?? '',
    // );

    // Will be set to false if the zip file was created from the
    // appbar 'Save Playlist, Comments, Pictures and Settings to Zip
    // File' menu item.
    bool wasIndividualPlaylistRestored = restoredInfoLst[4];

    // Display a confirmation message to the user.
    _warningMessageVM.confirmRestorationFromZip(
      zipFilePathName: zipFilePathName,
      playlistsNumber: restoredInfoLst[0].length,
      audioReferencesNumber: restoredInfoLst[5],
      commentJsonFilesNumber: restoredInfoLst[1],
      pictureJsonFilesNumber: restoredInfoLst[2],
      pictureJpgFilesNumber: restoredInfoLst[3],
      wasIndividualPlaylistRestored: wasIndividualPlaylistRestored,
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
        SettingsDataService(
      sharedPreferences: await SharedPreferences.getInstance(),
    );

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

  /// Method called when the user clicks on the 'Restore Playlist, Comments and
  /// Settings from Zip File' menu. It extracts the playlist json files as well
  /// as the commen json files of the playlists and writes them to the playlists
  /// root path.
  ///
  /// The returned list contains
  /// [
  ///  list of restored playlist titles,
  ///  number of restored comments JSON files,
  ///  number of restored pictures JSON files,
  ///  number of restored pictures JPG files,
  ///  was the zip file created from the playlist item 'Save Playlist, Comments,
  ///  Pictures and Settings to Zip File' menu item (true/false),
  ///  restoredAudioReferencesNumber
  /// ]
  Future<List<dynamic>> _restoreFilesFromZip({
    required String zipFilePathName,
    required bool doReplaceExistingPlaylists,
  }) async {
    Map<String, String> zipPlaylistJsonContentsMap = {};
    List<String> existingPlaylistTitlesLst =
        _listOfSelectablePlaylists.map((playlist) => playlist.title).toList();
    List<dynamic> restoredInfoLst = []; // restored info returned list
    List<String> restoredPlaylistTitlesLst = [];
    int restoredCommentsNumber = 0;
    int restoredPicturesJsonNumber = 0;
    int restoredPicturesJpgNumber = 0;

    // Check if the provided zip file exists.
    final File zipFile = File(zipFilePathName);

    if (!zipFile.existsSync()) {
      // Can not happen since the zip file is selected by the user
      // with the file picker and so the file must exist.
      restoredInfoLst.add(restoredPlaylistTitlesLst);
      restoredInfoLst.add(restoredCommentsNumber);
      restoredInfoLst.add(restoredPicturesJsonNumber);
      restoredInfoLst.add(restoredPicturesJpgNumber);
      restoredInfoLst.add(false); // wasIndividualPlaylistRestored
      restoredInfoLst.add(0); // adding 0 to the
      //                         restoredAudioReferencesNumber
      //                         position

      return restoredInfoLst;
    }

    // Retrieve the application path.
    final String applicationPath = _settingsDataService.get(
      settingType: SettingType.dataLocation,
      settingSubType: DataLocation.appSettingsPath,
    );

    // Retrieve the playlist root path. Normally, this value contains
    // /playlists or \playlists depending on the platform.
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
    // appbar 'Save Playlist, Comments, Pictures and Settings to Zip
    // File' menu item. In this case, the settings file is included
    // in the zip file.
    bool wasIndividualPlaylistRestored = true;

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
        // In this case, the zip file was created from the appbar
        // 'Save Playlist, Comments, Pictures and Settings to Zip
        // File' menu item. If the similar menu was selected from
        // the playlist item menu, the settings file does not
        // exist in the zip file.
        wasIndividualPlaylistRestored = false;
      }

      // Capturing the playlists contained in the zip.
      if (path.extension(destinationPathFileName) == '.json' &&
          !destinationPathFileName.contains(kSettingsFileName) &&
          !destinationPathFileName.contains(kPictureAudioMapFileName) &&
          !destinationPathFileName.contains(kCommentDirName)) {
        // This is a playlist JSON file.
        String playlistTitle =
            path.basenameWithoutExtension(destinationPathFileName);

        if (existingPlaylistTitlesLst.contains(playlistTitle)) {
          // This playlist already exists in the application. As
          // consequence, store JSON content for later processing.
          final String jsonContent =
              utf8.decode(archiveFile.content as List<int>);
          zipPlaylistJsonContentsMap[playlistTitle] = jsonContent;
        }
      }

      if (!doReplaceExistingPlaylists &&
          !destinationPathFileName.contains(kSettingsFileName) &&
          !destinationPathFileName.contains(kPictureAudioMapFileName)) {
        // Check if this is a playlist JSON file to merge.
        if (path.extension(destinationPathFileName) == '.json' &&
            !destinationPathFileName.contains(kCommentDirName)) {
          String playlistTitle =
              path.basenameWithoutExtension(destinationPathFileName);

          if (existingPlaylistTitlesLst.contains(playlistTitle)) {
            // This playlist already exists - we will add the missing audios
            // instead of replacing the file.
            continue; // Skip writing the JSON file.
          }
        }

        // For other files (audio .mp3, etc.).
        if (existingPlaylistTitlesLst.any((title) =>
            RegExp(r'\b' + RegExp.escape(title) + r'\b')
                .hasMatch(destinationPathFileName))) {
          // In mode 'not replace', skip the file if it already exists
          // and do not replace it.

          // In mode 'not replace playlist', skip the file if its about
          // the existing playlist and so do not replace it or do not
          // add it if it is not in the playlist.
          continue;
        }
      }

      final Directory destinationDir = Directory(
        // Extracting the directory from the path file name.
        path.dirname(destinationPathFileName),
      );

      if (!destinationDir.existsSync()) {
        await destinationDir.create(recursive: true);
      }

      // Write the file's bytes to the computed destination.
      final File outputFile = File(destinationPathFileName);

      if (destinationPathFileName.contains(kCommentDirName) &&
          outputFile.existsSync()) {
        // If the comment json file already exists, skip it. This is
        // useful if a new comment was added before the restoration.
        // Otherwise, the new comment would be lost.
        continue;
      }

      // if (destinationPathFileName.contains(kPictureDirName) &&
      //     outputFile.existsSync()) {
      //   // If the picture json file already exists, skip it. This
      //   // useful if a new picture was added before the restoration.
      //   continue;
      // }

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

      await outputFile.writeAsBytes(
        archiveFile.content as List<int>,
        flush: true,
      );

      if (!destinationPathFileName.contains(kSettingsFileName) &&
          !destinationPathFileName.contains(kPictureAudioMapFileName)) {
        // Second condition guarantees that the picture json files
        // number is correctly calculated.
        if (destinationPathFileName.contains(kCommentDirName)) {
          restoredCommentsNumber++;
        } else if (destinationPathFileName.contains(kPictureDirName)) {
          if (destinationPathFileName.endsWith('.jpg')) {
            // The jpg file is a physical picture file.
            restoredPicturesJpgNumber++;
          } else {
            // The json file is an audio picture reference file.
            restoredPicturesJsonNumber++;
          }
        } else {
          // Adding the restored playlist title to the list
          // of restored playlist titles.
          restoredPlaylistTitlesLst.add(
            path.basenameWithoutExtension(destinationPathFileName),
          );
        }
      }
    } // End of for loop iterating over the archive files.

    // Add missing audios + their comments + their pictures
    // from the zip playlists with the existing playlists.
    //
    // The returned list of integers contains:
    //   [0] number of added audio references,
    //   [1] number of added comments,
    //   [2] number of added pictures,
    List<int> restoredNumberLst = await _mergeZipPlaylistsWithExistingPlaylists(
      zipPlaylistJsonContentsMap: zipPlaylistJsonContentsMap,
      archive: archive,
    );

    restoredInfoLst.add(restoredPlaylistTitlesLst);
    restoredInfoLst.add(restoredCommentsNumber + restoredNumberLst[1]);
    restoredInfoLst.add(restoredPicturesJsonNumber + restoredNumberLst[2]);
    restoredInfoLst.add(restoredPicturesJpgNumber);
    restoredInfoLst.add(wasIndividualPlaylistRestored);
    restoredInfoLst.add(restoredNumberLst[0]);

    return restoredInfoLst;
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
  /// The returned list of integers contains:
  ///   [0] number of added audio references,
  ///   [1] number of added comments,
  ///   [2] number of added pictures,
  Future<List<int>> _mergeZipPlaylistsWithExistingPlaylists({
    required Map<String, String> zipPlaylistJsonContentsMap,
    required Archive archive,
  }) async {
    int addedAudiosCount = 0;
    int addedCommentsCount = 0;
    int addedPicturesCount = 0;
    List<int> restoredNumberLst = []; // restored number returned list

    for (String playlistTitle in zipPlaylistJsonContentsMap.keys) {
      // Find the existing playlist in the application.
      Playlist? existingPlaylist;
      try {
        existingPlaylist = _listOfSelectablePlaylists.firstWhere(
          (playlist) => playlist.title == playlistTitle,
        );
      } catch (e) {
        continue; // Playlist not found, skip to next.
      }

      // Parse the playlist from the zip.
      final Map<String, dynamic> zipPlaylistJson =
          jsonDecode(zipPlaylistJsonContentsMap[playlistTitle]!);

      Playlist zipPlaylist = Playlist.fromJson(zipPlaylistJson);

      // Add missing audios + their comments + their picture(s)
      // to existing playlists.
      restoredNumberLst = await _mergeAudiosFromZipPlaylist(
        existingPlaylist: existingPlaylist,
        zipPlaylist: zipPlaylist,
        archive: archive,
      );

      addedAudiosCount += restoredNumberLst[0];
      addedCommentsCount += restoredNumberLst[1];
      addedPicturesCount += restoredNumberLst[2];
    }

    restoredNumberLst.clear();
    restoredNumberLst.add(addedAudiosCount);
    restoredNumberLst.add(addedCommentsCount);
    restoredNumberLst.add(addedPicturesCount);

    return restoredNumberLst;
  }

  /// This method adds audio's of playlists corresponding to existing playlists which are
  /// available in the zip file and are not already present in the existing playlists.
  /// Additionally, the comments and pictures off the added audios are added to the existing
  /// playlists.
  ///
  /// The returned list of integers contains:
  ///   - The number of added audio references.
  ///   - The number of added comments.
  ///   - The number of added pictures.
  Future<List<int>> _mergeAudiosFromZipPlaylist({
    required Playlist existingPlaylist,
    required Playlist zipPlaylist,
    required Archive archive,
  }) async {
    int addedAudiosCount = 0;
    int addedCommentsCount = 0;
    int addedPicturesCount = 0;
    List<int> restoredNumberLst = []; // restored number returned list

    // Iterate through audios from the zip playlist.
    for (Audio zipAudio in zipPlaylist.downloadedAudioLst) {
      // Check if this audio already exists in the existing playlist
      bool audioExists = existingPlaylist.downloadedAudioLst.any(
        (existingAudio) =>
            existingAudio.audioFileName == zipAudio.audioFileName,
      );

      if (!audioExists) {
        // This audio doesn't exist in the existing playlist.
        // Add it even if the physical file doesn't exist (can be
        // downloaded later).

        // Create a copy of the audio and add it to the lists.
        Audio audioToAdd = zipAudio.copy();
        audioToAdd.enclosingPlaylist = existingPlaylist;
        audioToAdd.audioPlaySpeed = existingPlaylist.audioPlaySpeed;

        // Add to the downloaded audio list.
        existingPlaylist.downloadedAudioLst.add(audioToAdd);

        // Check if the audio should also be added to the playable list.
        bool isInPlayableList = existingPlaylist.playableAudioLst.any(
          (playableAudio) =>
              playableAudio.audioFileName == zipAudio.audioFileName,
        );

        if (!isInPlayableList) {
          // Add to the playable audio list using the method that
          // correctly handles the currentOrPastPlayableAudioIndex.
          existingPlaylist.playableAudioLst.insert(0, audioToAdd);
          existingPlaylist.currentOrPastPlayableAudioIndex++;
        }

        addedAudiosCount++;

        // Restore comment file for this audio if it exists in the zip
        if (await _restoreAudioCommentFileFromZip(
          archive: archive,
          audioToAdd: audioToAdd,
          existingPlaylist: existingPlaylist,
        )) {
          addedCommentsCount++;
        }

        // Restore picture files for this audio if they exist in the zip
        int restoredPicturesForAudio = await _restoreAudioPictureFilesFromZip(
          archive: archive,
          audioToAdd: audioToAdd,
          existingPlaylist: existingPlaylist,
        );

        addedPicturesCount += restoredPicturesForAudio;

        if (addedAudiosCount > 0) {
          await _writePlaylistToFile(
            playlist: existingPlaylist,
          );
        }
      }
    }

    restoredNumberLst.add(addedAudiosCount);
    restoredNumberLst.add(addedCommentsCount);
    restoredNumberLst.add(addedPicturesCount);

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
    // Build the expected comment file name in the zip
    String commentFileName =
        audioToAdd.audioFileName.replaceAll('.mp3', '.json');
    String zipCommentFilePath = path.join(
      kCommentDirName,
      commentFileName,
    );

    // Normalize the zip comment file path to ensure consistent formatting
    zipCommentFilePath = zipCommentFilePath
        .replaceAll('\\', '/') // Convert all backslashes to forward slashes
        .split('/')
        .map((segment) => segment.trim())
        .join('/');

    // Search for the comment file in the zip archive
    for (ArchiveFile archiveFile in archive) {
      if (archiveFile.isFile &&
          archiveFile.name
              .replaceAll(
                  '\\', '/') // First convert all backslashes to forward slashes
              .split('/')
              .map((segment) => segment.trim())
              .join('/')
              .endsWith(zipCommentFilePath)) {
        // Create target comment directory if it doesn't exist
        String targetCommentDirPath = path.join(
          existingPlaylist.downloadPath,
          kCommentDirName,
        );

        Directory targetCommentDir = Directory(targetCommentDirPath);
        if (!targetCommentDir.existsSync()) {
          await targetCommentDir.create(recursive: true);
        }

        // Write the comment file to the target playlist
        String targetCommentFilePath = path.join(
          targetCommentDirPath,
          commentFileName,
        );

        File targetCommentFile = File(targetCommentFilePath);

        // Only restore if the comment file doesn't already exist
        if (!targetCommentFile.existsSync()) {
          await targetCommentFile.writeAsBytes(
            archiveFile.content as List<int>,
            flush: true,
          );
          return true;
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
        .replaceAll('\\', '/') // Convert all backslashes to forward slashes
        .split('/')
        .map((segment) => segment.trim())
        .join('/');

    // Search for the picture JSON file in the zip archive
    for (ArchiveFile archiveFile in archive) {
      if (archiveFile.isFile &&
          archiveFile.name
              .replaceAll(
                  '\\', '/') // First convert all backslashes to forward slashes
              .split('/')
              .map((segment) => segment.trim())
              .join('/')
              .endsWith(zipPictureJsonFilePath)) {
        // Parse the picture JSON file to get the list of pictures
        String jsonContent = utf8.decode(archiveFile.content as List<int>);
        List<dynamic> pictureJsonList = jsonDecode(jsonContent);

        List<Picture> pictureLst =
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

          // Only restore if the picture JSON file doesn't already exist
          if (!targetPictureJsonFile.existsSync()) {
            await targetPictureJsonFile.writeAsBytes(
              archiveFile.content as List<int>,
              flush: true,
            );

            // Update the pictureAudioMap.json file for each picture
            for (Picture picture in pictureLst) {
              // Associates a picture with an audio file name in the application
              // picture audio map.
              _pictureVM.addPictureAudioAssociationToAppPictureAudioMap(
                pictureFileName: picture.fileName,
                audioFileName: audioToAdd.audioFileName,
                audioPlaylistTitle: existingPlaylist.title,
              );
            }

            restoredPicturesCount = pictureLst.length;
          }
        }
        break;
      }
    }

    return restoredPicturesCount;
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
    int rewindedAudioNumber = playlist.rewindPlayableAudioToStart();

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
  }) {
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

    _settingsDataService.restorePlaylistTitleOrderIfExistAndSaveSettings(
      directoryContainingPreviouslySavedPlaylistTitleOrder:
          modifiedPlaylistRootPath,
    );

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
}
