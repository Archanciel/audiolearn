import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/audio_sort_filter_service.dart';
import '../services/json_data_service.dart';
import '../services/settings_data_service.dart';
import '../services/sort_filter_parameters.dart';
import 'audio_download_vm.dart';
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
  bool _isListExpanded = false;
  set isListExpanded(bool isListExpanded) {
    _isListExpanded = isListExpanded;

    notifyListeners();
  }

  bool _isButtonDownloadSelPlaylistsEnabled = false;
  bool _isButtonMovePlaylistEnabled = false;
  bool _areButtonsApplicableToAudioEnabled = false;

  bool get isListExpanded => _isListExpanded;
  bool get isButtonDownloadSelPlaylistsEnabled =>
      _isButtonDownloadSelPlaylistsEnabled;
  bool get isButtonMovePlaylistEnabled => _isButtonMovePlaylistEnabled;
  bool get areButtonsApplicableToAudioEnabled =>
      _areButtonsApplicableToAudioEnabled;

  final AudioDownloadVM _audioDownloadVM;
  final CommentVM _commentVM;
  final WarningMessageVM _warningMessageVM;
  final SettingsDataService _settingsDataService;

  bool _isOnePlaylistSelected = true;
  bool get isOnePlaylistSelected => _isOnePlaylistSelected;

  List<Playlist> _listOfSelectablePlaylists = [];
  List<Audio>? _sortedFilteredSelectedPlaylistsPlayableAudios;
  List<Audio>? get sortedFilteredSelectedPlaylistsPlayableAudios =>
      _sortedFilteredSelectedPlaylistsPlayableAudios;
  AudioSortFilterParameters? _audioSortFilterParameters;
  AudioSortFilterParameters? get audioSortFilterParameters =>
      _audioSortFilterParameters;
  final Map<String, String>
      _playlistAudioSFparmsNamesForPlaylistDownloadViewMap = {};
  final Map<String, String> _playlistAudioSFparmsNamesForAudioPlayerViewMap =
      {};

  Playlist? _uniqueSelectedPlaylist;
  Playlist? get uniqueSelectedPlaylist => _uniqueSelectedPlaylist;

  final AudioSortFilterService _audioSortFilterService =
      AudioSortFilterService();

  PlaylistListVM({
    required WarningMessageVM warningMessageVM,
    required AudioDownloadVM audioDownloadVM,
    required CommentVM commentVM,
    required SettingsDataService settingsDataService,
  })  : _warningMessageVM = warningMessageVM,
        _audioDownloadVM = audioDownloadVM,
        _commentVM = commentVM,
        _settingsDataService = settingsDataService;

  List<Playlist> getUpToDateSelectablePlaylistsExceptExcludedPlaylist({
    required Playlist excludedPlaylist,
  }) {
    List<Playlist> upToDateSelectablePlaylists =
        getUpToDateSelectablePlaylists();

    List<Playlist> listOfSelectablePlaylistsCopy =
        List.from(upToDateSelectablePlaylists);

    listOfSelectablePlaylistsCopy.remove(excludedPlaylist);

    return listOfSelectablePlaylistsCopy;
  }

  /// Method called when the user choose the "Update playlist
  /// JSON files" menu item. The method is also executed when
  /// the user modifies the application settings through the
  /// ApplicationSettingsWidget opened by clicking on the
  /// Application settings menu item.
  void updateSettingsAndPlaylistJsonFiles() {
    _audioDownloadVM.updatePlaylistJsonFiles();

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
    // download view is updated only after having tapped on the Playlists
    // button !

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

    _updateAndSavePlaylistOrder();

    notifyListeners();
  }

  /// Thanks to this method, when restarting the app, the playlists
  /// are displayed in the same order as when the app was closed. This
  /// is done by saving the playlist order in the settings file.
  List<Playlist> getUpToDateSelectablePlaylists() {
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
        try {
          _listOfSelectablePlaylists.add(audioDownloadVMlistOfPlaylist
              .firstWhere((playlist) => playlist.title == playlistTitle));
        } catch (_) {
          // If the playlist with this title is not found, it means that
          // the playlist json file has been deleted. So, we don't add it
          // to the selectable playlist list and we will remove it from
          // the ordered playlist title list and update the settings data.
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

    int selectedPlaylistIndex = _getSelectedIndex();

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
        // Here, the playlist with this url was not found. This means that
        // the Youtube playlist must be added. Since the _audioDownloadVM.
        // addPlaylist() method is asynchronous, the code which uses it can
        // not be included on the firstWhere.onElse: parameter and instead
        // is located after this if {...} block.
      }
    } else if (localPlaylistTitle.isNotEmpty) {
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
      _listOfSelectablePlaylists.add(addedPlaylist);
      _updateAndSavePlaylistOrder();

      notifyListeners();

      return true;
    } else {
      // If addedPlaylist is null, it means that the passed
      // url is not a valid playlist url. It is useful to not
      // delete the invalid url so that the user can analyse
      // why this url is invalid.
      return false;
    }
  }

  void toggleList() {
    _isListExpanded = !_isListExpanded;

    if (!_isListExpanded) {
      _disableExpandedListButtons();
    } else {
      int selectedPlaylistIndex = _getSelectedIndex();
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
    _sortedFilteredSelectedPlaylistsPlayableAudios = null;

    notifyListeners();
  }

  /// Method used by PlaylistOneSelectedDialogWidget to select
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
  /// Since currently only one playlist can be selected at a time,
  /// this method unselects all the other playlists if the playlist
  /// whose index is passed is selected, i.e. if {isPlaylistSelected}
  /// is true.
  void setPlaylistSelection({
    required int playlistIndex,
    required bool isPlaylistSelected,
  }) {
    // selecting another playlist or unselecting the currently
    // selected playlist nullifies the filtered and sorted audio list
    _sortedFilteredSelectedPlaylistsPlayableAudios = null;
    _audioSortFilterParameters = null; // required to reset the sort and
    //                                    filter parameters, otherwise
    //                                    the previous sort and filter
    //                                    parameters will be applioed to
    //                                    the newly selected playlist

    Playlist playlistSelectedOrUnselected =
        _listOfSelectablePlaylists[playlistIndex];

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

      // TODO fix handling the right app view !!!
      // if (_uniqueSelectedPlaylist!.applySortFilterParmsForAudioPlayerView) {
      //   _audioSortFilterParameters =
      //       _uniqueSelectedPlaylist!.audioSortFilterParmsForAudioPlayerView;
      // }
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
    int selectedIndex = _getSelectedIndex();
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

  /// Thanks to this method, when restarting the app, the playlists
  /// are displayed in the same order as when the app was closed. This
  /// is done by saving the playlist order in the settings file.
  void _updateAndSavePlaylistOrder() {
    List<String> playlistOrder =
        _listOfSelectablePlaylists.map((playlist) => playlist.title).toList();

    _settingsDataService.savePlaylistOrder(playlistOrder: playlistOrder);
  }

  void moveSelectedItemDown() {
    int selectedIndex = _getSelectedIndex();
    if (selectedIndex != -1) {
      moveItemDown(selectedIndex);
      _updateAndSavePlaylistOrder();
      notifyListeners();
    }
  }

  Future<void> downloadSelectedPlaylist(BuildContext context) async {
    List<Playlist> selectedPlaylists = getSelectedPlaylists();

    for (Playlist playlist in selectedPlaylists) {
      await _audioDownloadVM.downloadPlaylistAudios(playlistUrl: playlist.url);
    }
  }

  /// Currently, only one playlist is selectable. So, this method
  /// returns a list of Playlists containing the unique selected
  /// playlist.
  List<Playlist> getSelectedPlaylists() {
    return _listOfSelectablePlaylists
        .where((playlist) => playlist.isSelected)
        .toList();
  }

  /// Returns the selected playlist audio list. If the user clicked
  /// on a sort filter item in the sort filter dropdown button located
  /// in the playlist download view or if the user taped on the Apply
  /// button in the SortAndFilterAudioDialogWidget, then the filtered
  /// and sorted audio list is returned.
  ///
  /// As well, if the selected playlist has a sort filter parameters
  /// saved in its json file, then the sort filter parameters are applied
  /// to the returned audio list, unless the user has changed the sort
  /// filter parameters in the SortAndFilterAudioDialogWidget or in
  /// the playlist download view sort filter dropdown menu.
  List<Audio> getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters({
    required AudioLearnAppViewType audioLearnAppViewType,
    AudioSortFilterParameters? audioSortFilterParameters,
  }) {
    List<Playlist> selectedPlaylists = getSelectedPlaylists();

    if (selectedPlaylists.isEmpty) {
      return [];
    }

    Playlist selectedPlaylist =
        selectedPlaylists[0]; // currently, only one playlist can be selected
    List<Audio> selectedPlaylistsAudios = selectedPlaylist.playableAudioLst;

    _audioSortFilterParameters = null;

    String selectedPlaylistTitle = selectedPlaylist.title;
    String selectedPlaylistSortFilterParmsName;

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
            // file to be automatically applyed in the playlist download view.
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
            // file to be automatically applyed in the audio player view.
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
      // defined sort and filter parameters for the playlist, then
      // the default sort and filter parameters are applied to the
      // playlist audio list.
      _audioSortFilterParameters =
          _settingsDataService.namedAudioSortFilterParametersMap[
              selectedPlaylistSortFilterParmsName];
    }

    _audioSortFilterParameters ??= audioSortFilterParameters;

    _sortedFilteredSelectedPlaylistsPlayableAudios =
        _audioSortFilterService.filterAndSortAudioLst(
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

    return _sortedFilteredSelectedPlaylistsPlayableAudios!;
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

  List<Audio>
      getSelectedPlaylistNotFullyPlayedAudiosApplyingSortFilterParameters(
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    List<Audio> playlistPlayableAudioLst =
        getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
      audioLearnAppViewType: audioLearnAppViewType,
    );

    return playlistPlayableAudioLst
        .where((audio) => !audio.wasFullyListened())
        .toList();
  }

  /// Used to display the audio list of the selected playlist
  /// starting at the beginning.
  bool isAudioListFilteredAndSorted() {
    return _sortedFilteredSelectedPlaylistsPlayableAudios != null;
  }

  /// Method called when the user selects a Sort and Filter
  /// item in the download playlist view Sort and Filter dropdown
  /// menu or after the user clicked on the Save or Apply button
  /// contained in the SortAndFilterAudioDialogWidget. The
  /// SortAndFilterAudioDialogWidget can be opened by clicking
  /// on a the Sort and Filter dropdown item edit icon button
  /// or on Sort Filter menu item in the audio menu located in the
  /// playlist download view or in the audio player view.
  ///
  /// {audioSortFilterParameters} is the sort and filter parameters
  /// selected by the user in the download playlist view Sort and
  /// Filter dropdown menu or is the sort and filter parameters
  /// the user set in the SortAndFilterAudioDialogWidget.
  void setSortedFilteredSelectedPlaylistPlayableAudiosAndParms({
    required AudioLearnAppViewType audioLearnAppViewType,
    required List<Audio> sortedFilteredSelectedPlaylistsPlayableAudios,
    required AudioSortFilterParameters audioSortFilterParameters,
    required String audioSortFilterParametersName,
    bool doNotifyListeners = true,
  }) {
    _sortedFilteredSelectedPlaylistsPlayableAudios =
        sortedFilteredSelectedPlaylistsPlayableAudios;
    _audioSortFilterParameters = audioSortFilterParameters;

    if (audioLearnAppViewType == AudioLearnAppViewType.playlistDownloadView) {
      _playlistAudioSFparmsNamesForPlaylistDownloadViewMap[
          getSelectedPlaylists()[0].title] = audioSortFilterParametersName;
    } else {
      // for AudioLearnAppViewType.audioPlayerView
      _playlistAudioSFparmsNamesForAudioPlayerViewMap[
          getSelectedPlaylists()[0].title] = audioSortFilterParametersName;
    }

    if (doNotifyListeners) {
      notifyListeners();
    }
  }

  void backToPlaylistDownloadView() {
    notifyListeners();
  }

  /// Method called when the user clicks on the playlist menu
  /// item "Sort filter audio" in the audio popup menu button
  /// in PlaylistDownloadView or in the AudioPlayerView.
  AudioSortFilterParameters getSelectedPlaylistAudioSortFilterParamForView(
    AudioLearnAppViewType audioLearnAppViewType,
  ) {
    Playlist selectedPlaylist = getSelectedPlaylists()[0];
    AudioSortFilterParameters? playlistAudioSortFilterParameters;

    switch (audioLearnAppViewType) {
      case AudioLearnAppViewType.playlistDownloadView:
        playlistAudioSortFilterParameters = _settingsDataService
                .namedAudioSortFilterParametersMap[
            selectedPlaylist.audioSortFilterParmsNameForPlaylistDownloadView];
        break;
      case AudioLearnAppViewType.audioPlayerView:
        playlistAudioSortFilterParameters =
            _settingsDataService.namedAudioSortFilterParametersMap[
                selectedPlaylist.audioSortFilterParmsNameForAudioPlayerView];
        break;
      default:
        break;
    }

    if (playlistAudioSortFilterParameters != null) {
      return playlistAudioSortFilterParameters;
    }

    // if the user has not yet selected sort and filter parameters,
    // then the default sort and filter parameters which don't
    // filter and only sort by audio download date descending
    // are returned.
    return AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
  }

  String getSelectedPlaylistAudioSortFilterParmsName({
    required AudioLearnAppViewType audioLearnAppViewType,
    required String translatedAppliedSortFilterParmsName,
  }) {
    Playlist selectedPlaylist = getSelectedPlaylists()[0];
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
  Audio? moveAudioAndCommentToPlaylist({
    required AudioLearnAppViewType audioLearnAppViewType,
    required Audio audio,
    required Playlist targetPlaylist,
    required bool keepAudioInSourcePlaylistDownloadedAudioLst,
  }) {
    Audio? nextAudio = _getNextSortFilteredNotFullyPlayedAudio(
      audioLearnAppViewType: audioLearnAppViewType,
      currentAudio: audio,
    );

    bool wasAudioMoved = _audioDownloadVM.moveAudioToPlaylist(
        audio: audio,
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

    notifyListeners();

    return nextAudio;
  }

  /// Method called when the user clicks on the 'Copy audio to
  /// playlist' menu item in the audio item menu button or in
  /// the audio player screen leading popup menu.
  void copyAudioAndCommentToPlaylist({
    required Audio audio,
    required Playlist targetPlaylist,
  }) {
    bool wasAudioCopied = _audioDownloadVM.copyAudioToPlaylist(
      audio: audio,
      targetPlaylist: targetPlaylist,
    );

    if (!wasAudioCopied) {
      return;
    }

    _commentVM.copyAudioCommentFileToTargetPlaylist(
      audio: audio,
      targetPlaylistPath: targetPlaylist.downloadPath,
    );

    notifyListeners();
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

      _sortedFilteredSelectedPlaylistsPlayableAudios = null;

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
      _sortedFilteredSelectedPlaylistsPlayableAudios =
          _audioSortFilterService.filterAndSortAudioLst(
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

  /// Method called when the user clicks on the 'delete audio'
  /// menu item in the audio item menu button or in
  /// the audio player screen leading popup menu.
  ///
  /// Physically deletes the audio mp3 file from the audio
  /// playlist directory.
  ///
  /// The method returns the next playable audio. The returned
  /// value is only useful when the user is in the audio player
  /// screen and so that the audio to move is the currently
  /// playable audio.
  ///
  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
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

    _removeAudioFromSortedFilteredPlayableAudioList(
      audioLearnAppViewType: audioLearnAppViewType,
      audio: audio,
    );

    _setStateOfButtonsApplicableToAudio(
      selectedPlaylist: audio.enclosingPlaylist!,
    );

    _commentVM.deleteAllAudioComments(
      commentedAudio: audio,
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
  Audio? deleteAudioFromPlaylistAswell({
    required AudioLearnAppViewType audioLearnAppViewType,
    required Audio audio,
  }) {
    Audio? nextAudio = _getNextSortFilteredNotFullyPlayedAudio(
      audioLearnAppViewType: audioLearnAppViewType,
      currentAudio: audio,
    );

    _audioDownloadVM.deleteAudioPhysicallyAndFromAllAudioLists(audio: audio);

    _removeAudioFromSortedFilteredPlayableAudioList(
      audioLearnAppViewType: audioLearnAppViewType,
      audio: audio,
    );

    _commentVM.deleteAllAudioComments(
      commentedAudio: audio,
    );

    notifyListeners();

    return nextAudio;
  }

  /// playableAudioLst order: [available audio last downloaded, ...,
  ///                          available audio first downloaded]
  Audio? _removeAudioFromSortedFilteredPlayableAudioList({
    required AudioLearnAppViewType audioLearnAppViewType,
    required Audio audio,
  }) {
    if (_sortedFilteredSelectedPlaylistsPlayableAudios != null) {
      Audio? nextAudio = _getNextSortFilteredNotFullyPlayedAudio(
        audioLearnAppViewType: audioLearnAppViewType,
        currentAudio: audio,
      );
      _sortedFilteredSelectedPlaylistsPlayableAudios!
          .removeWhere((audioInList) => audioInList == audio);
      return nextAudio;
    }

    return null;
  }

  int _getSelectedIndex() {
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
    if (_isListExpanded) {
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
    _disableExpandedListButtons();
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
  void _disableExpandedListButtons() {
    if (_isOnePlaylistSelected) {
      Playlist selectedPlaylist =
          _listOfSelectablePlaylists[_getSelectedIndex()];
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
    // download date descending (the de3fault sorting).
    List<Audio> sortedAndFilteredPlayableAudioLst =
        getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
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
        getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
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
        getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
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

  /// This method updates the playlists audio play speed or/and
  /// the audio play speed of the playable audio contained in
  /// the playlists.
  ///
  /// Updating the playlists audio play speed only implies that
  /// the next downloaded audio of this playlist will be set
  /// to the audioPlaySpeed value.
  void updateExistingPlaylistsAndOrAudiosPlaySpeed({
    required double audioPlaySpeed,
    required bool applyAudioPlaySpeedToExistingPlaylists,
    required bool applyAudioPlaySpeedToAlreadyDownloadedAudios,
  }) {
    for (Playlist playlist in _listOfSelectablePlaylists) {
      // updating the playlist audio play speed. This will imply the
      // next downloaded audio of this playlist.
      if (applyAudioPlaySpeedToExistingPlaylists) {
        playlist.audioPlaySpeed = audioPlaySpeed;
      }

      if (applyAudioPlaySpeedToAlreadyDownloadedAudios) {
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
  }

  void updateIndividualPlaylistAndOrPlaylistAudiosPlaySpeed({
    required double audioPlaySpeed,
    required int playlistIndex,
    required bool applyAudioPlaySpeedToPlayableAudios,
  }) {
    Playlist playlist = _listOfSelectablePlaylists[playlistIndex];
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
    String audioSortFilterParmsName =
        selectedPlaylist.audioSortFilterParmsNameForAudioPlayerView;

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

  /// Method called when the user opens the
  /// PlaylistManageSortFilterOptionsDialogWidget. The Method returns
  /// a list of one String possibly empty two bool's.
  ///
  /// The returned list content is
  /// [
  ///   the sort and filter parameters name applied to the playlist download
  ///   view or/and to the audio player view or uniquely to the audio player
  ///   view,
  ///   is audioSortFilterParmsName applied to playlist download view,
  ///   is audioSortFilterParmsName applied to audio player view,
  /// ]
  List<dynamic> getSortFilterParmsNameApplicationValuesToCurrentPlaylist() {
    String appliedAudioSortFilterParmsName = _uniqueSelectedPlaylist!
        .audioSortFilterParmsNameForPlaylistDownloadView;
    bool isAudioSortFilterParmsNameAppliedToPlaylistDownloadView = false;
    bool isAudioSortFilterParmsNameAppliedToAudioPlayerView = false;

    if (appliedAudioSortFilterParmsName.isNotEmpty) {
      isAudioSortFilterParmsNameAppliedToPlaylistDownloadView = true;
      if (_uniqueSelectedPlaylist!.audioSortFilterParmsNameForAudioPlayerView ==
          appliedAudioSortFilterParmsName) {
        isAudioSortFilterParmsNameAppliedToAudioPlayerView = true;
      }
    } else {
      // isAudioSortFilterParmsNameAppliedToPlaylistDownloadView == false
      appliedAudioSortFilterParmsName =
          _uniqueSelectedPlaylist!.audioSortFilterParmsNameForAudioPlayerView;
      if (appliedAudioSortFilterParmsName.isNotEmpty) {
        isAudioSortFilterParmsNameAppliedToAudioPlayerView = true;
      }
    }

    final List<dynamic> returnedResults = [
      appliedAudioSortFilterParmsName,
      isAudioSortFilterParmsNameAppliedToPlaylistDownloadView,
      isAudioSortFilterParmsNameAppliedToAudioPlayerView,
    ];

    return returnedResults;
  }
}
