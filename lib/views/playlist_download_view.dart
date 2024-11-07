import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/settings_data_service.dart';
import '../services/sort_filter_parameters.dart';
import '../utils/ui_util.dart';
import '../viewmodels/audio_download_vm.dart';
import '../viewmodels/playlist_list_vm.dart';
import '../viewmodels/theme_provider_vm.dart';
import '../viewmodels/warning_message_vm.dart';
import 'screen_mixin.dart';
import 'widgets/playlist_add_dialog.dart';
import 'widgets/application_snackbar.dart';
import 'widgets/audio_list_item_widget.dart';
import 'widgets/confirm_action_dialog.dart';
import 'widgets/playlist_list_item.dart';
import 'widgets/playlist_one_selectable_dialog.dart';
import 'widgets/audio_sort_filter_dialog.dart';
import 'widgets/playlist_add_remove_sort_filter_options_dialog.dart';

class PlaylistDownloadView extends StatefulWidget {
  final SettingsDataService settingsDataService;

  // this instance variable stores the function defined in
  // _MyHomePageState which causes the PageView widget to drag
  // to another screen according to the passed index.
  // This function is necessary since it is passed to the
  // constructor of AudioListItemWidget.
  final Function(int) onPageChangedFunction;
  final double audioItemHeight = (ScreenMixin.isHardwarePc() ? 73 : 85);
  final double playlistNotExpamdedScrollAugmentation =
      (ScreenMixin.isHardwarePc()) ? 1.38 : 1.55;
  final double playlistItemHeight = (ScreenMixin.isHardwarePc() ? 48 : 85);

  PlaylistDownloadView({
    super.key,
    required this.settingsDataService,
    required this.onPageChangedFunction,
  });

  @override
  State<PlaylistDownloadView> createState() => _PlaylistDownloadViewState();
}

class _PlaylistDownloadViewState extends State<PlaylistDownloadView>
    with ScreenMixin {
  final TextEditingController _playlistUrlOrSearchController =
      TextEditingController();
  final ScrollController _audioScrollController = ScrollController();
  final ScrollController _playlistScrollController = ScrollController();

  List<Audio> _selectedPlaylistsPlayableAudios = [];

  bool _wasSortFilterAudioSettingsApplied = false;

  String? _selectedSortFilterParametersName;

  bool _doNotScroll = false;

  // @override
  // void initState() {
  //   super.initState();
  //   // enabling to download a playlist in the emulator in which
  //   // pasting a URL is not possible
  //   // if (kPastedPlaylistUrl.isNotEmpty) {
  //   //   _playlistUrlController.text = kPastedPlaylistUrl;
  //   // }
  // }

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        PlaylistListVM playlistListVM = Provider.of<PlaylistListVM>(
          context,
          listen: false,
        );

        // When the download playlist view is displayed, the playlist list
        // is collapsed or expanded corresponding to the state stored in the
        // settings file. This state is modified by the user when he clicks
        // on the playlist toggle button.
        playlistListVM.isPlaylistListExpanded = widget.settingsDataService.get(
                settingType: SettingType.playlists,
                settingSubType:
                    Playlists.arePlaylistsDisplayedInPlaylistDownloadView) ??
            false;
      }
    });
  }

  @override
  void dispose() {
    _playlistUrlOrSearchController.dispose();
    _audioScrollController.dispose();
    _playlistScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AudioDownloadVM audioDownloadVMlistenfalse =
        Provider.of<AudioDownloadVM>(
      context,
      listen: false,
    );
    final ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );
    final PlaylistListVM playlistListVMlistenFalse =
        Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );
    final PlaylistListVM playlistListVMlistenTrue = Provider.of<PlaylistListVM>(
      context,
      listen: true,
    );
    final WarningMessageVM warningMessageVMlistenFalse =
        Provider.of<WarningMessageVM>(
      context,
      listen: false,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildWarningMessageVMConsumer(
          context: context,
          urlController: _playlistUrlOrSearchController,
        ),
        _buildFirstLine(
          context: context,
          audioDownloadVMlistenFalse: audioDownloadVMlistenfalse,
          themeProviderVM: themeProviderVM,
          playlistListVMlistenFalse: playlistListVMlistenFalse,
          playlistListVMlistenTrue: playlistListVMlistenTrue,
          warningMessageVMlistenFalse: warningMessageVMlistenFalse,
        ),
        // displaying the currently downloading audiodownload
        // informations.
        _buildDisplayDownloadProgressionInfo(),
        _buildSecondLine(
            context: context,
            themeProviderVM: themeProviderVM,
            playlistListVMlistenFalse: playlistListVMlistenFalse,
            playlistListVMlistenTrue: playlistListVMlistenTrue,
            warningMessageVMlistenFalse: warningMessageVMlistenFalse),
        _buildExpandedPlaylistList(
          playlistListVMlistenFalse: playlistListVMlistenFalse,
        ),
        (playlistListVMlistenFalse.isPlaylistListExpanded)
            ? const Divider(
                color:
                    kDarkAndLightEnabledIconColor, // Set the color of the divider
                thickness: 1.0, // Set the thickness of the divider
              )
            : const SizedBox.shrink(), // the list of playlists is collapsed
        _buildExpandedAudioList(
          playlistListVMlistenTrue: playlistListVMlistenTrue,
          warningMessageVMlistenFalse: warningMessageVMlistenFalse,
        ),
      ],
    );
  }

  Widget _buildExpandedAudioList({
    required PlaylistListVM playlistListVMlistenTrue,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    if (_wasSortFilterAudioSettingsApplied) {
      // if the sort and filter audio settings have been applied
      // then the sortedFilteredSelectedPlaylistsPlayableAudios
      // list is used to display the audio list. Otherwise, even
      // if the sort and filter audio settings have been applied,
      // the possibly saved sorted and filtered options of the
      // selected playlist are used to display the audio list !
      _selectedPlaylistsPlayableAudios = playlistListVMlistenTrue
          .sortedFilteredSelectedPlaylistsPlayableAudios!;
      _wasSortFilterAudioSettingsApplied = false;
    } else {
      _selectedPlaylistsPlayableAudios = playlistListVMlistenTrue
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      );
    }

    Playlist? playlist = playlistListVMlistenTrue.uniqueSelectedPlaylist;
    Audio? currentAudio;

    if (playlist != null &&
        playlist.playableAudioLst.isNotEmpty &&
        playlist.currentOrPastPlayableAudioIndex > -1 &&
        playlist.currentOrPastPlayableAudioIndex <
            playlist.playableAudioLst.length) {
      currentAudio =
          playlist.playableAudioLst[playlist.currentOrPastPlayableAudioIndex];
    }

    Expanded expanded = Expanded(
      child: ListView.builder(
        key: const Key('audio_list'),
        controller: _audioScrollController,
        itemCount: _selectedPlaylistsPlayableAudios.length,
        itemBuilder: (BuildContext context, int index) {
          final audio = _selectedPlaylistsPlayableAudios[index];
          return AudioListItemWidget(
            audio: audio,
            isAudioCurrent:
                (currentAudio != null) ? audio == currentAudio : false,
            warningMessageVM: warningMessageVMlistenFalse,
            onPageChangedFunction: widget.onPageChangedFunction,
          );
        },
      ),
    );

    final AudioDownloadVM audioDownloadVMlistenTrue =
        Provider.of<AudioDownloadVM>(
      context,
      listen: true,
    );

    _scrollToCurrentAudioItem(
      playlistListVMlistenTrue: playlistListVMlistenTrue,
      audioDownloadVMlistenTrue: audioDownloadVMlistenTrue,
    );

    return expanded;
  }

  void _scrollToCurrentAudioItem({
    required PlaylistListVM playlistListVMlistenTrue,
    required AudioDownloadVM audioDownloadVMlistenTrue,
  }) {
    if (audioDownloadVMlistenTrue.isDownloading) {
      // When an audio is downloading, the list is not scrolled to the
      // current audio item. This enables the newly downloaded audio to
      // be displayed at the top of the audio list.
      _doNotScroll = true;
    }

    if (_doNotScroll) {
      // In this case, the default sort and filter parameters are applied.
      // This guarantees that the newly downloaded audio will be displayed
      // at the top of the audio list.
      _applyDefaultAudioSortFilterParms(
        playlistListVMlistenFalseOrTrue: playlistListVMlistenTrue,
        notifyListeners: true,
      );

      if (_audioScrollController.hasClients) {
        _audioScrollController.jumpTo(0.0);
        _audioScrollController.animateTo(
          0.0, // offset
          duration: kScrollDuration,
          curve: Curves.easeInOut,
        );
      }

      return;
    }

    int audioToScrollPosition =
        playlistListVMlistenTrue.determineAudioToScrollPosition();

    // When the download playlist view is displayed, the playlist list
    // is collapsed or expanded. This corresponds to the state stored in the
    // app settings file. This state is modified by the user when he clicks
    // on the playlist toggle button.
    bool isPlaylistListExpanded = widget.settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType:
                Playlists.arePlaylistsDisplayedInPlaylistDownloadView) ??
        false;

    if (isPlaylistListExpanded && audioToScrollPosition <= 2) {
      // This avoids scrolling down when the current audio is
      // in the top part of the audio list. Without that, the
      // list is unusefully scrolled down and the user has to scroll
      // up to see a selected top audio.
      return;
    }

    double scrollPositionNumber = audioToScrollPosition.toDouble();

    if (audioToScrollPosition > 300) {
      scrollPositionNumber *= 1.23;
    } else if (audioToScrollPosition > 200) {
      scrollPositionNumber *= 1.21;
    } else if (audioToScrollPosition > 120) {
      scrollPositionNumber *= 1.125;
    }

    if (!isPlaylistListExpanded) {
      // the list of playlists is collapsed ...
      scrollPositionNumber *= widget.playlistNotExpamdedScrollAugmentation;
    }

    double offset = scrollPositionNumber * widget.audioItemHeight;

    if (_audioScrollController.hasClients) {
      _audioScrollController.jumpTo(0.0);
      _audioScrollController.animateTo(
        offset,
        duration: kScrollDuration,
        curve: Curves.easeInOut,
      );
    } else {
      // The scroll controller isn't attached to any scroll views.
      // Schedule a callback to try again after the next frame.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToCurrentAudioItem(
                playlistListVMlistenTrue: playlistListVMlistenTrue,
                audioDownloadVMlistenTrue: audioDownloadVMlistenTrue,
              ));
    }
  }

  Widget _buildExpandedPlaylistList({
    required PlaylistListVM playlistListVMlistenFalse,
  }) {
    if (playlistListVMlistenFalse.isPlaylistListExpanded) {
      List<Playlist> upToDateSelectablePlaylists =
          playlistListVMlistenFalse.getUpToDateSelectablePlaylists();
      Expanded expanded = Expanded(
        child: ListView.builder(
          key: const Key('expandable_playlist_list'),
          controller: _playlistScrollController,
          itemCount: upToDateSelectablePlaylists.length,
          itemBuilder: (context, index) {
            Playlist playlist = upToDateSelectablePlaylists[index];
            return Builder(
              builder: (listTileContext) {
                return PlaylistListItem(
                  settingsDataService: widget.settingsDataService,
                  playlist: playlist,
                );
              },
            );
          },
        ),
      );

      _scrollToSelectedPlaylist(
        playlistListVMlistenFalse: playlistListVMlistenFalse,
      );

      return expanded;
    } else {
      // the list of playlists is collapsed
      return const SizedBox.shrink();
    }
  }

  void _scrollToSelectedPlaylist({
    required PlaylistListVM playlistListVMlistenFalse,
  }) {
    List<Playlist> selectablePlaylists;
    String searchSentence = playlistListVMlistenFalse.searchSentence;
    int playlistToScrollPosition = 0;
    int noScrollPositionValue = 0; // position value avoiding scrolling down

    if (playlistListVMlistenFalse.wasSearchButtonClicked &&
        searchSentence.isNotEmpty) {
      noScrollPositionValue = -1;
      selectablePlaylists = playlistListVMlistenFalse
          .getUpToDateSelectablePlaylists()
          .where((playlist) => playlist.title
              .toLowerCase()
              .contains(searchSentence.toLowerCase()))
          .toList();
      for (int i = 0; i < selectablePlaylists.length; i++) {
        if (selectablePlaylists[i].isSelected) {
          playlistToScrollPosition = i;
          break;
        }
      }
    } else {
      noScrollPositionValue = 3;
      playlistToScrollPosition =
          playlistListVMlistenFalse.determinePlaylistToScrollPosition();
    }

    // When the download playlist view is displayed, the playlist list
    // is collapsed or expanded. This corresponds to the state stored in the
    // app settings file. This state is modified by the user when he clicks
    // on the playlist toggle button.
    bool isPlaylistListExpanded = widget.settingsDataService.get(
            settingType: SettingType.playlists,
            settingSubType:
                Playlists.arePlaylistsDisplayedInPlaylistDownloadView) ??
        false;

    if (isPlaylistListExpanded && playlistToScrollPosition <= noScrollPositionValue) {
      // This avoids scrolling down when the selected playlist is
      // in the top part of the list of playlists. Without that, the
      // list is unusefully scrolled down and the user has to scroll
      // up to see a selected top playlist.
      return;
    }

    double scrollPositionNumber = playlistToScrollPosition.toDouble();

    if (playlistToScrollPosition > 50) {
      scrollPositionNumber *= 0.675;
    } else if (playlistToScrollPosition > 25) {
      scrollPositionNumber *= 0.68;
    } else if (playlistToScrollPosition > 20) {
      scrollPositionNumber *= 0.69;
    } else if (playlistToScrollPosition > 10) {
      scrollPositionNumber *= 0.67;
    } else if (playlistToScrollPosition > noScrollPositionValue) {
      scrollPositionNumber *= 0.6;
    }

    double offset = scrollPositionNumber * widget.playlistItemHeight;

    if (_playlistScrollController.hasClients) {
      _playlistScrollController.jumpTo(0.0);
      _playlistScrollController.animateTo(
        offset,
        duration: kScrollDuration,
        curve: Curves.easeInOut,
      );
    } else {
      // The scroll controller isn't attached to any scroll views.
      // Schedule a callback to try again after the next frame.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToSelectedPlaylist(
                playlistListVMlistenFalse: playlistListVMlistenFalse,
              ));
    }
  }

  ///
  Consumer<AudioDownloadVM> _buildDisplayDownloadProgressionInfo() {
    return Consumer<AudioDownloadVM>(
      builder: (context, audioDownloadVM, child) {
        if (audioDownloadVM.isDownloading) {
          String downloadProgressPercent =
              '${(audioDownloadVM.downloadProgress * 100).toStringAsFixed(1)}%';
          String downloadFileSize = UiUtil.formatLargeIntValue(
            context: context,
            value: audioDownloadVM.currentDownloadingAudio.audioFileSize,
          );
          String downloadSpeed = '${UiUtil.formatLargeIntValue(
            context: context,
            value: audioDownloadVM.lastSecondDownloadSpeed,
          )}/sec';
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  audioDownloadVM.currentDownloadingAudio.validVideoTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                LinearProgressIndicator(
                    value: audioDownloadVM.downloadProgress),
                const SizedBox(height: 10.0),
                Text(
                  '$downloadProgressPercent ${AppLocalizations.of(context)!.ofPreposition} $downloadFileSize ${AppLocalizations.of(context)!.atPreposition} $downloadSpeed',
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// Builds the second line of the playlist download view. This line
  /// contains the playlists toggle button, the sort filter dropdown
  /// button, the download selected playlists button, the audio quality
  /// checkbox and the audio popup menu button.
  Row _buildSecondLine({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
    required PlaylistListVM playlistListVMlistenFalse,
    required PlaylistListVM playlistListVMlistenTrue,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    final AudioDownloadVM audioDownloadVMlistenTrue =
        Provider.of<AudioDownloadVM>(
      context,
      listen: true,
    );

    bool arePlaylistDownloadWidgetsEnabled =
        playlistListVMlistenFalse.isButtonDownloadSelPlaylistsEnabled &&
            !Provider.of<AudioDownloadVM>(context).isDownloading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(
          // sets the rounded TextButton size improving the distance
          // between the button text and its boarder
          width: kGreaterButtonWidth,
          height: kNormalButtonHeight,
          child: Tooltip(
            message: AppLocalizations.of(context)!
                .playlistToggleButtonInPlaylistDownloadViewTooltip,
            child: TextButton(
              key: const Key('playlist_toggle_button'),
              style: ButtonStyle(
                shape: getButtonRoundedShape(
                  currentTheme: themeProviderVM.currentTheme,
                ),
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding,
                    vertical: 0,
                  ),
                ),
                overlayColor: textButtonTapModification, // Tap feedback color
              ),
              onPressed: () {
                playlistListVMlistenFalse.togglePlaylistsList();

                // Storing in the settings file the state of the playlist list
                widget.settingsDataService.set(
                  settingType: SettingType.playlists,
                  settingSubType:
                      Playlists.arePlaylistsDisplayedInPlaylistDownloadView,
                  value: playlistListVMlistenFalse.isPlaylistListExpanded,
                );
                widget.settingsDataService.saveSettings();

                if (!playlistListVMlistenFalse.isPlaylistListExpanded &&
                    playlistListVMlistenFalse.wasSearchButtonClicked) {
                  playlistListVMlistenFalse.isSearchSentenceApplied = true;
                  _applySortFilterParmsNameChange(
                    playlistListVMlistenFalseOrTrue: playlistListVMlistenFalse,
                    notifyListeners: true,
                  );
                }
              },
              child: Text(
                'Playlists',
                style: (themeProviderVM.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode,
              ),
            ),
          ),
        ),
        SizedBox(
          width: kSmallIconButtonWidth,
          child: IconButton(
            key: const Key('search_icon_button'),
            onPressed: (playlistListVMlistenTrue.isSearchButtonEnabled)
                ? () {
                    playlistListVMlistenFalse.wasSearchButtonClicked = true;
                    if (!playlistListVMlistenTrue.isPlaylistListExpanded) {
                      // the list of playlists is collapsed
                      playlistListVMlistenFalse.isSearchSentenceApplied = true;
                      _applySortFilterParmsNameChange(
                        playlistListVMlistenFalseOrTrue:
                            playlistListVMlistenFalse,
                        notifyListeners: true,
                      );
                    }
                  }
                : null,
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(
              Icons.search,
              size: kSmallIconButtonWidth,
            ),
          ),
        ),
        (playlistListVMlistenTrue.isPlaylistListExpanded)
            ? _buildPlaylistMoveIconButtons(
                playlistListVMlistenFalse: playlistListVMlistenFalse,
              )
            : (playlistListVMlistenTrue.isOnePlaylistSelected)
                ? _buildSortFilterParmsDropdownButton(
                    playlistListVMlistenFalse: playlistListVMlistenFalse,
                    playlistListVMlistenTrue: playlistListVMlistenTrue,
                    warningMessageVMlistenFalse: warningMessageVMlistenFalse,
                  )
                : _buildPlaylistMoveIconButtons(
                    playlistListVMlistenFalse: playlistListVMlistenFalse,
                  ),
        SizedBox(
          // sets the rounded TextButton size improving the distance
          // between the button text and its boarder
          width: kGreaterButtonWidth + 10,
          height: kNormalButtonHeight,
          child: Tooltip(
            message:
                AppLocalizations.of(context)!.downloadSelPlaylistsButtonTooltip,
            child: TextButton(
              key: const Key('download_sel_playlists_button'),
              style: ButtonStyle(
                shape: getButtonRoundedShape(
                    currentTheme: themeProviderVM.currentTheme,
                    isButtonEnabled: arePlaylistDownloadWidgetsEnabled,
                    context: context),
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding,
                    vertical: 0,
                  ),
                ),
                overlayColor: textButtonTapModification, // Tap feedback color
              ),
              onPressed: (arePlaylistDownloadWidgetsEnabled)
                  ? () async {
                      // disable the sorted filtered playable audio list
                      // downloading audio of selected playlists so that
                      // the currently displayed audio list is not sorted
                      // or/and filtered. This way, the newly downloaded
                      // audio will be added at top of the displayed audio
                      // list.
                      playlistListVMlistenFalse
                          .disableSortedFilteredPlayableAudioLst();

                      List<Playlist> selectedPlaylists =
                          playlistListVMlistenFalse.getSelectedPlaylists();

                      // currently only one playlist can be selected and
                      // downloaded at a time.
                      await Provider.of<AudioDownloadVM>(
                        context,
                        listen: false,
                      ).downloadPlaylistAudio(
                          playlistUrl: selectedPlaylists[0].url);
                    }
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize
                    .min, // Pour s'assurer que le Row n'occupe pas plus d'espace que nécessaire
                children: <Widget>[
                  const Icon(
                    Icons.download_outlined,
                    size: 18,
                  ),
                  Text(
                    AppLocalizations.of(context)!.downloadSelectedPlaylist,
                    style: (arePlaylistDownloadWidgetsEnabled)
                        ? (themeProviderVM.currentTheme == AppTheme.dark)
                            ? kTextButtonStyleDarkMode
                            : kTextButtonStyleLightMode
                        : const TextStyle(
                            // required to display the button in grey if
                            // the button is disabled
                            fontSize: kTextButtonFontSize,
                          ),
                  ), // Texte
                ],
              ),
            ),
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(context)!.musicalQualityTooltip,
          child: SizedBox(
            width: 20,
            child: Checkbox(
              key: const Key('audio_quality_checkbox'),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              fillColor: WidgetStateColor.resolveWith(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey.shade800;
                  }
                  return kDarkAndLightEnabledIconColor;
                },
              ),
              value: audioDownloadVMlistenTrue.isHighQuality,
              onChanged: (arePlaylistDownloadWidgetsEnabled)
                  ? (bool? value) {
                      bool isHighQuality = value ?? false;
                      audioDownloadVMlistenTrue.setAudioQuality(
                          isAudioDownloadHighQuality: isHighQuality);
                      String snackBarMessage = isHighQuality
                          ? AppLocalizations.of(context)!
                              .audioQualityHighSnackBarMessage
                          : AppLocalizations.of(context)!
                              .audioQualityLowSnackBarMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        ApplicationSnackBar(
                          message: snackBarMessage,
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ),
        _buildAudioPopupMenuButtonAndMenuItems(
          context: context,
          playlistListVMlistenFalse: playlistListVMlistenFalse,
          warningMessageVMlistenFalse: warningMessageVMlistenFalse,
        ),
      ],
    );
  }

  /// Method called only if the list of playlists is NOT expanded
  /// AND if a playlist is selected. If the list of playlists is
  /// expanded, the user can select a playlist by clicking on it
  /// and instead of displaying the sort and filter dropdown button,
  /// Up and Down icon buttons are displayed enabling the user to move
  /// the selected playlist up or down in the playlist list.
  ///
  /// This method return a row containing the sort filter
  /// dropdown button. This button contains the list of sort
  /// filter parameters dropdown items which were saved by the
  /// user.
  Row _buildSortFilterParmsDropdownButton({
    required PlaylistListVM playlistListVMlistenFalse,
    required PlaylistListVM playlistListVMlistenTrue,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    String sortFilterDefaultMenuItemNameCorrespondingToLanguage =
        AppLocalizations.of(context)!.sortFilterParametersDefaultName;

    bool wasLanguageChanged = false;

    // If the user changed the language, the default sort and filter
    // parameters name is changed to the corresponding language.
    // The problem is that the default sort and filter parameters named
    // in the previous language is still in the sort and filter
    // parameters list. This default sort and filter parameters name
    // must be deleted from the list since that the named in current
    // language default sort and filter parameters is in the list.
    if (sortFilterDefaultMenuItemNameCorrespondingToLanguage == "défaut") {
      if (playlistListVMlistenFalse.deleteAudioSortFilterParameters(
              audioSortFilterParametersName: "default") !=
          null) {
        // The sort and filter parameters named "default" was
        // deleted from the sort and filter parameters list.
        wasLanguageChanged = true;
        if (_selectedSortFilterParametersName == "default") {
          // avoids UI problem since the currently selected sort and
          // filter parameters name (default) is no longer available
          // since it was deleted
          _selectedSortFilterParametersName = "défaut";
        }
      }
    } else if (sortFilterDefaultMenuItemNameCorrespondingToLanguage ==
        "default") {
      if (playlistListVMlistenFalse.deleteAudioSortFilterParameters(
              audioSortFilterParametersName: 'défaut') !=
          null) {
        wasLanguageChanged = true;
        if (_selectedSortFilterParametersName == "défaut") {
          // avoids UI problem since the currently selected sort and
          // filter parameters name (défaut) is no longer available
          // since it was deleted
          _selectedSortFilterParametersName = "default";
        }
      }
    }

    if (wasLanguageChanged &&
        _selectedSortFilterParametersName != null &&
        _selectedSortFilterParametersName !=
            sortFilterDefaultMenuItemNameCorrespondingToLanguage) {
      // When the language was changed and the selected sort and filter
      // parameters name is not the default name, then, the selected
      // sort and filter parameters are applied again to the selected
      // playlist. Without that, the default sort and filter parameters
      // are applied to the selected playlist after the language changed
      _updatePlaylistSortedFilteredAudioList(
        playlistListVMlistenTrue: playlistListVMlistenFalse,
        notifyListeners: false,
      );
    }

    Map<String, AudioSortFilterParameters> audioSortFilterParametersMap =
        widget.settingsDataService.namedAudioSortFilterParametersMap;

    String selectedPlaylistAudioSortFilterParmsName =
        playlistListVMlistenFalse.getSelectedPlaylistAudioSortFilterParmsName(
      audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      translatedAppliedSortFilterParmsName:
          AppLocalizations.of(context)!.sortFilterParametersAppliedName,
    );

    // If the selected playlist sort and filter parameters name is
    // the translated sortFilterParametersAppliedName, which is
    // the case if the user clicked on the Apply button of the
    // sort and filter dialog, then the sort and filter parameters
    // must be added to the sort and filter parameters map, otherwise
    // building the dropdown menu items list will fail.
    if (selectedPlaylistAudioSortFilterParmsName ==
            AppLocalizations.of(context)!.sortFilterParametersAppliedName &&
        playlistListVMlistenFalse.audioSortFilterParameters != null) {
      // Executing the following instruction ensures that the sort/filter
      // parameters map is saved in the settings file.
      widget.settingsDataService.addOrReplaceNamedAudioSortFilterParameters(
        audioSortFilterParametersName: selectedPlaylistAudioSortFilterParmsName,
        audioSortFilterParameters:
            playlistListVMlistenFalse.audioSortFilterParameters!,
      );
    }

    // When going to audio player view, then back to  playlisz download view,
    // the applied sf parm is not retrieved. Idea: get the last historical
    // sf parm since applied parn is added to history ! NOT WORKING !
    // if (selectedPlaylistAudioSortFilterParmsName ==
    //     AppLocalizations.of(context)!.sortFilterParametersAppliedName) {
    //   List<AudioSortFilterParameters>
    //       searchHistoryAudioSortFilterParametersLst = playlistListVMlistenFalse
    //           .getSearchHistoryAudioSortFilterParametersLst();
    //   audioSortFilterParametersMap[selectedPlaylistAudioSortFilterParmsName] =
    //       playlistListVMlistenFalse.audioSortFilterParameters ??
    //           searchHistoryAudioSortFilterParametersLst[
    //               searchHistoryAudioSortFilterParametersLst.length - 1];
    // }

    List<String> audioSortFilterParametersNamesLst =
        audioSortFilterParametersMap.keys.toList();
    audioSortFilterParametersNamesLst
        .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    List<DropdownMenuItem<String>> dropdownMenuItems =
        _buildSortFilterParmsDropdownMenuItemsLst(
      audioSortFilterParametersNamesLst: audioSortFilterParametersNamesLst,
      playlistListVMlistenFalse: playlistListVMlistenFalse,
      audioSortFilterParametersMap: audioSortFilterParametersMap,
      warningMessageVMlistenFalse: warningMessageVMlistenFalse,
    );

    if (selectedPlaylistAudioSortFilterParmsName.isEmpty) {
      selectedPlaylistAudioSortFilterParmsName =
          AppLocalizations.of(context)!.sortFilterParametersDefaultName;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: kDropdownButtonMaxWidth,
          ),
          child: DropdownButton<String>(
            key: const Key('sort_filter_parms_dropdown_button'),
            value: (playlistListVMlistenTrue
                    .getSelectedPlaylistAudioSortFilterParmsName(
                      audioLearnAppViewType:
                          AudioLearnAppViewType.playlistDownloadView,
                      translatedAppliedSortFilterParmsName:
                          AppLocalizations.of(context)!
                              .sortFilterParametersAppliedName,
                    )
                    .isEmpty)
                ? null // causes the default sort filter parms to be applied
                //        and its name to be displayed
                : _applySortFilterParmsNameChange(
                    playlistListVMlistenFalseOrTrue: playlistListVMlistenTrue,
                  ),
            items: dropdownMenuItems,
            onChanged: (value) {
              _selectedSortFilterParametersName = value;
              _updatePlaylistSortedFilteredAudioList(
                  playlistListVMlistenTrue: playlistListVMlistenFalse);
            },
            hint: Text(
              sortFilterDefaultMenuItemNameCorrespondingToLanguage,
            ),
            underline: Container(), // suppresses the underline
          ),
        ),
      ],
    );
  }

  /// Method called when the user select a sort/filter parameters in the
  /// sort/filter dropdown button list. The selected sort/ilter parameters
  /// are applied to the selected playlist audio list.
  String _applySortFilterParmsNameChange({
    required PlaylistListVM playlistListVMlistenFalseOrTrue,
    notifyListeners = false,
  }) {
    _selectedSortFilterParametersName = playlistListVMlistenFalseOrTrue
        .getSelectedPlaylistAudioSortFilterParmsName(
      audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      translatedAppliedSortFilterParmsName:
          AppLocalizations.of(context)!.sortFilterParametersAppliedName,
    );

    String searchSentence = '';

    if (playlistListVMlistenFalseOrTrue.isSearchSentenceApplied) {
      // _isSearchSentenceApplied is true means that the user clicked on
      // the searchSentence button. Its value is set to false only after the
      // youtubeUrlOrSearchTextField was emptied by the user of if the
      // user did paste a URL on it.
      searchSentence = _playlistUrlOrSearchController.text;
    }

    _updatePlaylistSortedFilteredAudioList(
        playlistListVMlistenTrue: playlistListVMlistenFalseOrTrue,
        searchSentence: searchSentence,
        notifyListeners: notifyListeners); // If true, causes displayed audio
    //                                    list update.
    //                         If false, avoids rebuilding the widget and
    //                         avoids integration test failure

    return _selectedSortFilterParametersName!; // is not null
  }

  /// This method is called by the _scrollToCurrentAudioItem() method when the
  /// application is downloading new playlist audio. In this situation, the
  /// scroll to the current audio item is disabled so that the newly downloaded
  /// audio are displayed at the top of the audio list. The display at the top
  /// of the audio list is only possible if the sort and filter audio settings
  /// are set to the default settings, what is done by this method.
  String _applyDefaultAudioSortFilterParms({
    required PlaylistListVM playlistListVMlistenFalseOrTrue,
    notifyListeners = false,
  }) {
    _selectedSortFilterParametersName =
        AppLocalizations.of(context)!.sortFilterParametersDefaultName;

    _updatePlaylistSortedFilteredAudioList(
        playlistListVMlistenTrue: playlistListVMlistenFalseOrTrue,
        searchSentence: '',
        notifyListeners: notifyListeners); // If true, causes displayed audio
    //                                    list update.
    //                         If false, avoids rebuilding the widget and
    //                         avoids integration test failure

    return _selectedSortFilterParametersName!; // is not null
  }

  /// Updates the sorted and filtered audio list of the selected playlist
  /// according to the sort and filter parameters selected in the dropdown
  /// button list.
  void _updatePlaylistSortedFilteredAudioList({
    required PlaylistListVM playlistListVMlistenTrue,
    String searchSentence = '',
    bool notifyListeners = true,
  }) {
    AudioSortFilterParameters audioSortFilterParameters =
        playlistListVMlistenTrue.getAudioSortFilterParameters(
      audioSortFilterParametersName: _selectedSortFilterParametersName!,
    );

    playlistListVMlistenTrue
        .setSortFilterForSelectedPlaylistPlayableAudiosAndParms(
      audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      sortFilteredSelectedPlaylistPlayableAudio: playlistListVMlistenTrue
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
        audioSortFilterParameters: audioSortFilterParameters,
      ),
      audioSortFilterParms: audioSortFilterParameters,
      audioSortFilterParmsName: _selectedSortFilterParametersName!,
      searchSentence: searchSentence,
      doNotifyListeners: notifyListeners,
    );

    _wasSortFilterAudioSettingsApplied = true;
  }

  List<DropdownMenuItem<String>> _buildSortFilterParmsDropdownMenuItemsLst({
    required List<String> audioSortFilterParametersNamesLst,
    required PlaylistListVM playlistListVMlistenFalse,
    required Map<String, AudioSortFilterParameters>
        audioSortFilterParametersMap,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    List<DropdownMenuItem<String>> dropdownMenuItems =
        audioSortFilterParametersNamesLst
            .map(
              (String audioSortFilterParametersName) => DropdownMenuItem(
                value: audioSortFilterParametersName,
                child: Tooltip(
                  message: audioSortFilterParametersName,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: kDropdownMenuItemMaxWidth,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(audioSortFilterParametersName),
                        ),
                        (audioSortFilterParametersName ==
                                _selectedSortFilterParametersName)
                            ? _buildSortFilterParmsDropdownItemEditIconButton(
                                playlistListVMlistenFalse:
                                    playlistListVMlistenFalse,
                                audioSortFilterParametersName:
                                    audioSortFilterParametersName,
                                audioSortFilterParametersMap:
                                    audioSortFilterParametersMap,
                                audioSortFilterParametersNamesLst:
                                    audioSortFilterParametersNamesLst,
                                warningMessageVMlistenFalse:
                                    warningMessageVMlistenFalse,
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList();
    return dropdownMenuItems;
  }

  /// Builds the edit icon button located on the right of the
  /// dropdown menu item. This button allows the user to edit the
  /// sort and filter parameters referenced by the dropdown menu
  /// item. Choosing the edit button opens the sort and filter
  /// dialog. The user can then modify the sort and filter parameters
  /// and then save them to the existing name or to new name or
  /// delete them.
  Widget _buildSortFilterParmsDropdownItemEditIconButton({
    required PlaylistListVM playlistListVMlistenFalse,
    required String audioSortFilterParametersName,
    required Map<String, AudioSortFilterParameters>
        audioSortFilterParametersMap,
    required List<String> audioSortFilterParametersNamesLst,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    return SizedBox(
      width: kDropdownItemEditIconButtonWidth,
      child: IconButton(
        key: const Key('sort_filter_parms_dropdown_item_edit_icon_button'),
        icon: const Icon(Icons.edit),
        onPressed: () {
          // Using FocusNode to enable clicking on Enter to close
          // the dialog
          final FocusNode focusNode = FocusNode();

          showDialog<List<dynamic>>(
            context: context,
            barrierDismissible: false, // This line prevents the dialog from
            //                            closing when tapping outside it
            builder: (BuildContext context) {
              return AudioSortFilterDialog(
                selectedPlaylistAudioLst: playlistListVMlistenFalse
                    .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
                  audioLearnAppViewType:
                      AudioLearnAppViewType.playlistDownloadView,
                ),
                audioSortFilterParametersName: audioSortFilterParametersName,
                audioSortFilterParameters:
                    audioSortFilterParametersMap[audioSortFilterParametersName]!
                        .copy(), // copy() is necessary to avoid modifying the
                // original if saving the AudioSortFilterParameters to
                // a new name
                audioSortPlaylistFilterParameters:
                    audioSortFilterParametersMap[audioSortFilterParametersName]!
                        .copy(), // copy() is necessary to avoid modifying the
                // original if saving the AudioSortFilterParameters to
                // a new name
                audioLearnAppViewType:
                    AudioLearnAppViewType.playlistDownloadView,
                focusNode: focusNode,
                warningMessageVM: warningMessageVMlistenFalse,
                calledFrom: CalledFrom.playlistDownloadView,
              );
            },
          ).then((filterSortAudioAndParmLst) {
            if (filterSortAudioAndParmLst != null) {
              // user clicked on Save or Apply or on Delete button
              // on sort and filter dialog OPENED BY EDITING A
              // SORT AND FILTER DROPDOWN MENU ITEM
              if (filterSortAudioAndParmLst[0] == 'delete') {
                // user clicked on Delete button. The deleted sort
                // filter parameters was removed from the settings
                // in the audio sort filter dialog.

                // selecting the default sort and filter
                // parameters drop down button item
                _selectedSortFilterParametersName =
                    AppLocalizations.of(context)!
                        .sortFilterParametersDefaultName;
                setState(() {
                  audioSortFilterParametersNamesLst.removeWhere(
                      (element) => element == audioSortFilterParametersName);
                });
              } else {
                // user clicked on Save or Apply button (the Apply button
                // was displayed after the user deleted the sort and filter
                // parameters 'Save as' name)
                List<Audio> returnedAudioList = filterSortAudioAndParmLst[0];
                AudioSortFilterParameters audioSortFilterParameters =
                    filterSortAudioAndParmLst[1];
                String sortFilterParametersSaveAsName =
                    filterSortAudioAndParmLst[2];

                playlistListVMlistenFalse
                    .setSortFilterForSelectedPlaylistPlayableAudiosAndParms(
                  audioLearnAppViewType:
                      AudioLearnAppViewType.playlistDownloadView,
                  sortFilteredSelectedPlaylistPlayableAudio: returnedAudioList,
                  audioSortFilterParms: audioSortFilterParameters,
                  audioSortFilterParmsName: sortFilterParametersSaveAsName,
                );
                _wasSortFilterAudioSettingsApplied = true;

                // selecting the sort and filter parameters drop down
                // button item corresponding to the saved sort and
                // filter parameters
                _selectedSortFilterParametersName =
                    sortFilterParametersSaveAsName;
              }
            } // else filterSortAudioAndParmLst == null if user clicked on
            //   Cancel button
          });
          focusNode.requestFocus();
        },
      ),
    );
  }

  Row _buildPlaylistMoveIconButtons({
    required PlaylistListVM playlistListVMlistenFalse,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: kSmallButtonWidth,
          child: IconButton(
            key: const Key('move_down_playlist_button'),
            onPressed: playlistListVMlistenFalse.isButtonMovePlaylistEnabled
                ? () {
                    playlistListVMlistenFalse.moveSelectedItemDown();
                  }
                : null,
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(
              Icons.arrow_drop_down,
              size: kUpDownButtonSize,
            ),
          ),
        ),
        SizedBox(
          width: kSmallButtonWidth,
          child: IconButton(
            key: const Key('move_up_playlist_button'),
            onPressed: playlistListVMlistenFalse.isButtonMovePlaylistEnabled
                ? () {
                    playlistListVMlistenFalse.moveSelectedItemUp();
                  }
                : null,
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(
              Icons.arrow_drop_up,
              size: kUpDownButtonSize,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the first line of the playlist download view. This line
  /// contains the playlist URL text field under which is added the
  /// selected playlist title, the add playlist button, the download
  /// single video button and the stop download button.
  Widget _buildFirstLine({
    required BuildContext context,
    required AudioDownloadVM audioDownloadVMlistenFalse,
    required ThemeProviderVM themeProviderVM,
    required PlaylistListVM playlistListVMlistenFalse,
    required PlaylistListVM playlistListVMlistenTrue,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildYoutubeUrlOrSearchPlusSelPlaylistTitle(
            context: context,
            playlistListVMlistenTrue: playlistListVMlistenTrue,
          ),
          const SizedBox(
            width: kRowSmallWidthSeparator,
          ),
          _buildAddPlaylistButton(
            context: context,
            themeProviderVM: themeProviderVM,
          ),
          const SizedBox(
            width: kRowSmallWidthSeparator,
          ),
          _buildDownloadSingleVideoButton(
            context: context,
            audioDownloadVMlistenFalse: audioDownloadVMlistenFalse,
            themeProviderVM: themeProviderVM,
            playlistListVMlistenFalse: playlistListVMlistenFalse,
            warningMessageVMlistenFalse: warningMessageVMlistenFalse,
          ),
          const SizedBox(
            width: kRowSmallWidthSeparator,
          ),
          _buildStopDownloadButton(
            context: context,
            audioDownloadVMlistenFalse: audioDownloadVMlistenFalse,
            themeProviderVM: themeProviderVM,
          ),
        ],
      ),
    );
  }

  /// Builds the audio popup menu button located on the right of the
  /// screen. This button allows the user to sort and filter the
  /// displayed audio list, to save the sort and filter settings to
  /// the selected playlist and to update the playlist json files.
  Widget _buildAudioPopupMenuButtonAndMenuItems({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenFalse,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    return SizedBox(
      width: kRowButtonGroupWidthSeparator,
      child: PopupMenuButton<PopupMenuButtonType>(
        key: const Key('audio_popup_menu_button'),
        icon: const Icon(Icons.filter_list),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<PopupMenuButtonType>(
              key: const Key('define_sort_and_filter_audio_menu_item'),
              enabled: (playlistListVMlistenFalse
                  .areButtonsApplicableToAudioEnabled),
              value: PopupMenuButtonType.openSortFilterAudioDialog,
              child: Text(
                  AppLocalizations.of(context)!.defineSortFilterAudiosMenu),
            ),
            PopupMenuItem<PopupMenuButtonType>(
              key: const Key(
                  'clear_sort_and_filter_audio_parms_history_menu_item'),
              enabled: (playlistListVMlistenFalse
                  .getSearchHistoryAudioSortFilterParametersLst()
                  .isNotEmpty),
              value: PopupMenuButtonType.clearSortFilterAudioParmsHistory,
              child: Text(AppLocalizations.of(context)!
                  .clearSortFilterAudiosParmsHistoryMenu),
            ),
            PopupMenuItem<PopupMenuButtonType>(
              key: const Key(
                  'save_sort_and_filter_audio_parms_in_playlist_item'),
              enabled: (_selectedSortFilterParametersName != null &&
                  _selectedSortFilterParametersName !=
                      AppLocalizations.of(context)!
                          .sortFilterParametersAppliedName &&
                  _selectedSortFilterParametersName !=
                      AppLocalizations.of(context)!
                          .sortFilterParametersDefaultName &&
                  playlistListVMlistenFalse
                      .isSortFilterAudioParmsAlreadySavedInPlaylistForAllViews(
                    selectedSortFilterParametersName:
                        _selectedSortFilterParametersName!,
                  )),
              value: PopupMenuButtonType.saveSortFilterAudioParmsToPlaylist,
              child: Text(AppLocalizations.of(context)!
                  .saveSortFilterAudiosOptionsToPlaylistMenu),
            ),
            PopupMenuItem<PopupMenuButtonType>(
              key: const Key(
                  'remove_sort_and_filter_audio_parms_from_playlist_item'),
              enabled: (_selectedSortFilterParametersName != null &&
                  playlistListVMlistenFalse
                      .getSortFilterParmsNameApplicationValuesToCurrentPlaylist(
                        selectedSortFilterParmsName:
                            _selectedSortFilterParametersName!,
                      )[0]
                      .isNotEmpty), // this menu item is enabled if a sort filter
              //                   parms is applied to the one or two views of
              //                   the selected playlist
              value: PopupMenuButtonType.removeSortFilterAudioParmsFromPlaylist,
              child: Text(AppLocalizations.of(context)!
                  .removeSortFilterAudiosOptionsFromPlaylistMenu),
            ),
          ];
        },
        onSelected: (PopupMenuButtonType value) {
          // Handle menu item selection
          switch (value) {
            case PopupMenuButtonType.openSortFilterAudioDialog:
              // Using FocusNode to enable clicking on Enter to close
              // the dialog
              final FocusNode focusNode = FocusNode();
              showDialog<List<dynamic>>(
                context: context,
                barrierDismissible: false, // This line prevents the dialog from
                // closing when tapping outside the dialog
                builder: (BuildContext context) {
                  return AudioSortFilterDialog(
                    selectedPlaylistAudioLst: playlistListVMlistenFalse
                        .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
                      audioLearnAppViewType:
                          AudioLearnAppViewType.audioPlayerView,
                    ),
                    audioSortFilterParameters: AudioSortFilterParameters
                        .createDefaultAudioSortFilterParameters(),
                    audioSortPlaylistFilterParameters: playlistListVMlistenFalse
                        .getSelectedPlaylistAudioSortFilterParamForView(
                          AudioLearnAppViewType.playlistDownloadView,
                        )
                        .copy(), // copy() is necessary to avoid modifying the
                    // original if saving the AudioSortFilterParameters to
                    // a new name
                    audioLearnAppViewType:
                        AudioLearnAppViewType.playlistDownloadView,
                    focusNode: focusNode,
                    warningMessageVM: warningMessageVMlistenFalse,
                    calledFrom: CalledFrom.playlistDownloadViewAudioMenu,
                  );
                },
              ).then((filterSortAudioAndParmLst) {
                if (filterSortAudioAndParmLst != null) {
                  // user clicked on Save or Apply button on sort and filter
                  // dialog opened by the popup menu button item
                  List<Audio> returnedAudioList = filterSortAudioAndParmLst[0];
                  AudioSortFilterParameters audioSortFilterParameters =
                      filterSortAudioAndParmLst[1];
                  String audioSortFilterParametersName =
                      filterSortAudioAndParmLst[2];
                  playlistListVMlistenFalse
                      .setSortFilterForSelectedPlaylistPlayableAudiosAndParms(
                    audioLearnAppViewType:
                        AudioLearnAppViewType.playlistDownloadView,
                    sortFilteredSelectedPlaylistPlayableAudio:
                        returnedAudioList,
                    audioSortFilterParms: audioSortFilterParameters,
                    audioSortFilterParmsName: audioSortFilterParametersName,
                  );
                  _wasSortFilterAudioSettingsApplied = true;
                }
              });
              focusNode.requestFocus();
              break;
            case PopupMenuButtonType.clearSortFilterAudioParmsHistory:
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmActionDialog(
                    actionFunction: playlistListVMlistenFalse
                        .clearAudioSortFilterSettingsSearchHistory,
                    actionFunctionArgs: const [],
                    dialogTitle: AppLocalizations.of(context)!
                        .clearSortFilterAudiosParmsHistoryMenu,
                    dialogContent: AppLocalizations.of(context)!
                        .allHistoricalSortFilterParametersDeleteConfirmation,
                  );
                },
              );
              break;
            case PopupMenuButtonType.saveSortFilterAudioParmsToPlaylist:
              List<dynamic> sortFilterParmsNameAppliedToCurrentPlaylist =
                  playlistListVMlistenFalse
                      .getSortFilterParmsNameApplicationValuesToCurrentPlaylist(
                selectedSortFilterParmsName: _selectedSortFilterParametersName!,
              );
              bool isAudioSortFilterParmsNameAppliedToPlaylistDownloadView =
                  false;
              bool isAudioSortFilterParmsNameAppliedToAudioPlayerView = false;

              if (sortFilterParmsNameAppliedToCurrentPlaylist[0] ==
                  _selectedSortFilterParametersName) {
                // The currently selected in the dropdown menu sort and filter
                // parameters are already applied to the selected playlist.
                isAudioSortFilterParmsNameAppliedToPlaylistDownloadView =
                    sortFilterParmsNameAppliedToCurrentPlaylist[1];
                isAudioSortFilterParmsNameAppliedToAudioPlayerView =
                    sortFilterParmsNameAppliedToCurrentPlaylist[2];
              }
              showDialog<List<dynamic>>(
                context: context,
                barrierDismissible:
                    false, // This line prevents the dialog from closing
                //            when tapping outside the dialog
                builder: (BuildContext context) {
                  return PlaylistAddRemoveSortFilterOptionsDialog(
                    playlistTitle:
                        playlistListVMlistenFalse.uniqueSelectedPlaylist!.title,
                    sortFilterParmsName:
                        _selectedSortFilterParametersName ?? '',
                    isSortFilterParmsNameAlreadyAppliedToPlaylistDownloadView:
                        isAudioSortFilterParmsNameAppliedToPlaylistDownloadView,
                    isSortFilterParmsNameAlreadyAppliedToAudioPlayerView:
                        isAudioSortFilterParmsNameAppliedToAudioPlayerView,
                  );
                },
              ).then((forViewLst) {
                bool isForPlaylistDownloadView;
                bool isForAudioPlayerView;

                if (forViewLst == null) {
                  // the user clicked on Cancel button
                  return;
                } else {
                  // the user clicked on Save button
                  isForPlaylistDownloadView = forViewLst[1];
                  isForAudioPlayerView = forViewLst[2];

                  if (!isForPlaylistDownloadView && !isForAudioPlayerView) {
                    // the user did not select any checkbox. In this case,
                    // the playlist json files are not updated.
                    return;
                  }
                }

                // The user clicked on Save, not on Cancel button and at
                // least one checkbox was selected ...

                playlistListVMlistenFalse
                    .savePlaylistAudioSortFilterParmsToPlaylist(
                  sortFilterParmsNameToSave:
                      forViewLst[0], // sort filter parms name
                  forPlaylistDownloadView: isForPlaylistDownloadView,
                  forAudioPlayerView: isForAudioPlayerView,
                );
              });
              break;
            case PopupMenuButtonType.removeSortFilterAudioParmsFromPlaylist:
              showDialog<List<dynamic>>(
                context: context,
                barrierDismissible:
                    false, // This line prevents the dialog from closing
                // when tapping outside the dialog
                builder: (BuildContext context) {
                  List<dynamic> sortFilterParmsNameAppliedToCurrentPlaylist =
                      playlistListVMlistenFalse
                          .getSortFilterParmsNameApplicationValuesToCurrentPlaylist(
                    selectedSortFilterParmsName:
                        _selectedSortFilterParametersName!,
                  );
                  return PlaylistAddRemoveSortFilterOptionsDialog(
                    playlistTitle:
                        playlistListVMlistenFalse.uniqueSelectedPlaylist!.title,
                    sortFilterParmsName:
                        sortFilterParmsNameAppliedToCurrentPlaylist[0],
                    isSortFilterParmsNameAlreadyAppliedToPlaylistDownloadView:
                        sortFilterParmsNameAppliedToCurrentPlaylist[1],
                    isSortFilterParmsNameAlreadyAppliedToAudioPlayerView:
                        sortFilterParmsNameAppliedToCurrentPlaylist[2],
                    isSaveApplied: false, // SF options remove is applied ...
                  );
                },
              ).then((forViewLst) {
                bool isForPlaylistDownloadView;
                bool isForAudioPlayerView;

                if (forViewLst == null) {
                  // the user clicked on Cancel button
                  return;
                } else {
                  isForPlaylistDownloadView = forViewLst[1];
                  isForAudioPlayerView = forViewLst[2];
                  if (!isForPlaylistDownloadView && !isForAudioPlayerView) {
                    // the user did not select any checkbox
                    return;
                  }
                }

                // The user clicked on Remove, not on Cancel button and
                // at least one checkbox was selected ...

                playlistListVMlistenFalse
                    .removeAudioSortFilterParmsFromPlaylist(
                  fromPlaylistDownloadView: isForPlaylistDownloadView,
                  fromAudioPlayerView: isForAudioPlayerView,
                );

                if (isForPlaylistDownloadView) {
                  // selecting the default sort and filter parameters drop
                  // down button item. Necessary so that the 'Save sort filter
                  // options to playlist' menu item is now disabled.
                  _selectedSortFilterParametersName =
                      AppLocalizations.of(context)!
                          .sortFilterParametersDefaultName;
                }
              });
              break;
            default:
              break;
          }
        },
      ),
    );
  }

  SizedBox _buildStopDownloadButton({
    required BuildContext context,
    required AudioDownloadVM audioDownloadVMlistenFalse,
    required ThemeProviderVM themeProviderVM,
  }) {
    bool isButtonEnabled = audioDownloadVMlistenFalse.isDownloading &&
        !audioDownloadVMlistenFalse.isDownloadStopping;

    return SizedBox(
      // sets the rounded TextButton size improving the distance
      // between the button text and its boarder
      width: kNormalButtonWidth - 24,
      height: kNormalButtonHeight,
      child: Tooltip(
        message: AppLocalizations.of(context)!.stopDownloadingButtonTooltip,
        child: TextButton(
          key: const Key('stopDownloadingButton'),
          style: ButtonStyle(
            shape: getButtonRoundedShape(
              currentTheme: themeProviderVM.currentTheme,
              isButtonEnabled: isButtonEnabled,
              context: context,
            ),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(
                horizontal: kSmallButtonInsidePadding,
                vertical: 0,
              ),
            ),
            overlayColor: textButtonTapModification, // Tap feedback color
          ),
          onPressed: (isButtonEnabled)
              ? () {
                  // Flushbar creation must be located before calling
                  // the stopDownload method, otherwise the flushbar
                  // will be located higher.
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    message:
                        AppLocalizations.of(context)!.audioDownloadingStopping,
                    duration: const Duration(seconds: 8),
                    backgroundColor: Colors.purple.shade900,
                    messageColor: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ).show(context);
                  audioDownloadVMlistenFalse.stopDownload();
                }
              : null,
          child: Text(
            AppLocalizations.of(context)!.stopDownload,
            style: (isButtonEnabled)
                ? (themeProviderVM.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode
                : const TextStyle(
                    // required to display the button in grey if
                    // the button is disabled
                    fontSize: kTextButtonFontSize,
                  ),
          ),
        ),
      ),
    );
  }

  SizedBox _buildDownloadSingleVideoButton({
    required BuildContext context,
    required AudioDownloadVM audioDownloadVMlistenFalse,
    required ThemeProviderVM themeProviderVM,
    required PlaylistListVM playlistListVMlistenFalse,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    return SizedBox(
      // sets the rounded TextButton size improving the distance
      // between the button text and its boarder
      width: kSmallButtonWidth + 8, // necessary to display english text
      height: kNormalButtonHeight,
      child: Tooltip(
        message: AppLocalizations.of(context)!.downloadSingleVideoButtonTooltip,
        child: TextButton(
          key: const Key('downloadSingleVideoButton'),
          style: ButtonStyle(
            shape: getButtonRoundedShape(
                currentTheme: themeProviderVM.currentTheme),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(
                  horizontal: kSmallButtonInsidePadding,
                  // necessary to display english text
                  vertical: 0),
            ),
            overlayColor: textButtonTapModification, // Tap feedback color
          ),
          onPressed: () {
            // disabling the sorted filtered playable audio list
            // downloading audio of selected playlists so that
            // the currently displayed audio list is not sorted
            // or/and filtered. This way, the newly downloaded
            // audio will be added at top of the displayed audio
            // list.
            playlistListVMlistenFalse.disableSortedFilteredPlayableAudioLst();

            showDialog<dynamic>(
              context: context,
              builder: (context) => PlaylistOneSelectableDialog(
                usedFor:
                    PlaylistOneSelectableDialogUsedFor.downloadSingleVideoAudio,
                warningMessageVM: warningMessageVMlistenFalse,
              ),
            ).then((value) {
              if (value == 'cancel') {
                // Fixes bug which happened when downloading a single
                // video audio and clicking on the cancel button of
                // the single selection playlist dialog. Without
                // this fix, the confirm dialog was displayed although
                // the user clicked on the cancel button.
                return;
              }

              Playlist? selectedTargetPlaylist = value["selectedPlaylist"];
              bool isMusicQuality =
                  value["downloadSingleVideoAudioAtMusicQuality"] ?? false;

              // Using FocusNode to enable clicking on Enter to close
              // the dialog
              final FocusNode newFocusNode = FocusNode();

              // confirming or not the addition of the single video
              // audio to the selected playlist
              showDialog<String>(
                context: context,
                builder: (context) => KeyboardListener(
                  // Using FocusNode to enable clicking on Enter to close
                  // the dialog
                  focusNode: newFocusNode,
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.enter ||
                          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                        // executing the same code as in the 'Ok'
                        // ElevatedButton onPressed callback
                        Navigator.of(context).pop('ok');
                      }
                    }
                  },
                  child: AlertDialog(
                    title: Text(
                      AppLocalizations.of(context)!.confirmDialogTitle,
                      key: const Key('confirmationDialogTitleKey'),
                    ),
                    actionsPadding:
                        // reduces the top vertical space between the buttons
                        // and the content
                        const EdgeInsets.fromLTRB(
                            10, 0, 10, 10), // Adjust the value as needed
                    content: Text(
                      key: const Key('confirmationDialogMessageKey'),
                      (isMusicQuality)
                          ? AppLocalizations.of(context)!
                              .confirmSingleVideoAudioAtMusicQualityPlaylistTitle(
                              selectedTargetPlaylist!.title,
                            )
                          : AppLocalizations.of(context)!
                              .confirmSingleVideoAudioPlaylistTitle(
                              selectedTargetPlaylist!.title,
                            ),
                      style: kDialogTextFieldStyle,
                    ),
                    actions: [
                      TextButton(
                        key: const Key('okButtonKey'),
                        child: Text(
                          'Ok',
                          style: (themeProviderVM.currentTheme == AppTheme.dark)
                              ? kTextButtonStyleDarkMode
                              : kTextButtonStyleLightMode,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop('ok');
                        },
                      ),
                      TextButton(
                        key: const Key('cancelButtonKey'),
                        child: Text(AppLocalizations.of(context)!.cancelButton,
                            style:
                                (themeProviderVM.currentTheme == AppTheme.dark)
                                    ? kTextButtonStyleDarkMode
                                    : kTextButtonStyleLightMode),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ).then((value) async {
                if (value != null) {
                  // the case if the user clicked on Ok button
                  ErrorType errorType =
                      await audioDownloadVMlistenFalse.downloadSingleVideoAudio(
                    videoUrl: _playlistUrlOrSearchController.text.trim(),
                    singleVideoTargetPlaylist: selectedTargetPlaylist!,
                    downloadAtMusicQuality: isMusicQuality,
                  );

                  if (errorType == ErrorType.noError) {
                    // if the single video audio has been
                    // correctly downloaded, then the playlistUrl
                    // field is cleared
                    _playlistUrlOrSearchController.clear();
                  }
                }
              });
              // required so that clicking on Enter to close the dialog
              // works. This intruction must be located after the
              // .then() method of the showDialog() method !
              newFocusNode.requestFocus();
            });
          },
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Make sure that the Row doesn't occupy
            //                       more space than necessary
            children: <Widget>[
              const Icon(
                Icons.download_outlined,
                size: 18,
              ), // Icône
              Text(
                AppLocalizations.of(context)!.downloadSingleVideoAudio,
                style: (themeProviderVM.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Youtube URL or search text field and the selected playlist
  /// title text. The Youtube URL or search text field allows the user to enter
  /// the URL of a Youtube playlist or single video as well as a search word or
  /// sentence. The selected playlist title text displays the title of the
  /// selected playlist.
  ///
  /// {playlistListVMlistenTrue} is the PlaylistListVM with listen set to
  /// true. This is necessary to update the selected playlist title when
  /// the user selects another playlist.
  Expanded _buildYoutubeUrlOrSearchPlusSelPlaylistTitle({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenTrue,
  }) {
    return Expanded(
      // necessary to avoid Exception
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6, // controls the height ratio
            child: TextField(
              key: const Key('youtubeUrlOrSearchTextField'),
              controller: _playlistUrlOrSearchController,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.ytPlaylistLinkLabel,
                hintText: AppLocalizations.of(context)!.ytPlaylistLinkHintText,
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.all(2),
              ),
              maxLines: 1,
              onChanged: (String value) {
                if (value.isEmpty ||
                    value.toLowerCase().contains('https://') ||
                    value.toLowerCase().contains('http://')) {
                  if (playlistListVMlistenTrue.isSearchButtonEnabled) {
                    playlistListVMlistenTrue.disableSearchSentence();
                  }
                } else {
                  playlistListVMlistenTrue.isSearchButtonEnabled = true;
                }

                if (playlistListVMlistenTrue.isPlaylistListExpanded) {
                  playlistListVMlistenTrue.searchSentence = value;
                } else {
                  playlistListVMlistenTrue.searchSentence = value;
                  _applySortFilterParmsNameChange(
                    playlistListVMlistenFalseOrTrue: playlistListVMlistenTrue,
                    notifyListeners: true,
                  );
                }
              },
            ),
          ),
          Expanded(
            flex: 4, // controls the height ratio
            child: Text(
              key: const Key('selectedPlaylistTitleText'),
              // using playlistListVM with listen:True guaranties
              // that the selected playlist title is updated when
              // the selected playlist changes
              playlistListVMlistenTrue.uniqueSelectedPlaylist?.title ?? '',
              style: const TextStyle(
                fontSize: 12,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _buildAddPlaylistButton({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
  }) {
    return SizedBox(
      // sets the rounded TextButton size improving the distance
      // between the button text and its boarder
      width: kNormalButtonWidth - 18,
      height: kNormalButtonHeight,
      child: Tooltip(
        message: AppLocalizations.of(context)!.addPlaylistButtonTooltip,
        child: TextButton(
          key: const Key('addPlaylistButton'),
          style: ButtonStyle(
            shape: getButtonRoundedShape(
                currentTheme: themeProviderVM.currentTheme),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(
                horizontal: kSmallButtonInsidePadding,
                vertical: 0,
              ),
            ),
            overlayColor: textButtonTapModification, // Tap feedback color
          ),
          onPressed: () {
            final String playlistUrl =
                _playlistUrlOrSearchController.text.trim();
            showDialog<bool>(
              context: context,
              barrierDismissible:
                  false, // This line prevents the dialog from closing when
              //            tapping outside the dialog
              builder: (BuildContext context) {
                return PlaylistAddDialog(
                  playlistUrl: playlistUrl,
                );
              },
            ).then((value) {
              if (value ?? false) {
                // Value is null if the Youtube playlist title is invalid
                // (contains comma) or if the user clicked on Cancel.
                //
                // The value is true if a Youtube playlist has been added.
                // Then, in this case the playlist url TextField is cleared.
                _playlistUrlOrSearchController.clear();
              }
            });
          },
          child: Text(
            AppLocalizations.of(context)!.addPlaylist,
            style: (themeProviderVM.currentTheme == AppTheme.dark)
                ? kTextButtonStyleDarkMode
                : kTextButtonStyleLightMode,
          ),
        ),
      ),
    );
  }
}
