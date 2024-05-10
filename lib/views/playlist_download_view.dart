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
import 'widgets/add_playlist_dialog_widget.dart';
import 'widgets/audio_learn_snackbar.dart';
import 'widgets/audio_list_item_widget.dart';
import 'widgets/action_confirm_dialog_widget.dart';
import 'widgets/playlist_list_item_widget.dart';
import 'widgets/playlist_one_selectable_dialog_widget.dart';
import 'widgets/audio_sort_filter_dialog_widget.dart';
import 'widgets/playlist_sort_filter_options_save_to_dialog_widget.dart';

class PlaylistDownloadView extends StatefulWidget {
  final SettingsDataService settingsDataService;

  // this instance variable stores the function defined in
  // _MyHomePageState which causes the PageView widget to drag
  // to another screen according to the passed index.
  // This function is necessary since it is passed to the
  // constructor of AudioListItemWidget.
  final Function(int) onPageChangedFunction;

  const PlaylistDownloadView({
    super.key,
    required this.settingsDataService,
    required this.onPageChangedFunction,
  });

  @override
  State<PlaylistDownloadView> createState() => _PlaylistDownloadViewState();
}

class _PlaylistDownloadViewState extends State<PlaylistDownloadView>
    with ScreenMixin {
  final TextEditingController _playlistUrlController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Audio> _selectedPlaylistsPlayableAudios = [];

  bool _wasSortFilterAudioSettingsApplied = false;

  String? _selectedSortFilterParametersName;

  //request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    // enabling to download a playlist in the emulator in which
    // pasting a URL is not possible
    // if (kPastedPlaylistUrl.isNotEmpty) {
    //   _playlistUrlController.text = kPastedPlaylistUrl;
    // }
  }

  @override
  void dispose() {
    _playlistUrlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AudioDownloadVM audioDownloadViewModel = Provider.of<AudioDownloadVM>(
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
      children: <Widget>[
        buildWarningMessageVMConsumer(
          context: context,
          urlController: _playlistUrlController,
        ),
        _buildFirstLine(
          context: context,
          audioDownloadViewModel: audioDownloadViewModel,
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
        _buildExpandedPlaylistList(),
        _buildExpandedAudioList(
          warningMessageVMlistenFalse: warningMessageVMlistenFalse,
        ),
      ],
    );
  }

  Expanded _buildExpandedAudioList({
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    return Expanded(
      child: Consumer<PlaylistListVM>(
        builder: (context, expandablePlaylistListVM, child) {
          if (_wasSortFilterAudioSettingsApplied) {
            // if the sort and filter audio settings have been applied
            // then the sortedFilteredSelectedPlaylistsPlayableAudios
            // list is used to display the audio list. Otherwise, even
            // if the sort and filter audio settings have been applied,
            // the possibly saved sorted and filtered options of the
            // selected playlist are used to display the audio list !
            _selectedPlaylistsPlayableAudios = expandablePlaylistListVM
                .sortedFilteredSelectedPlaylistsPlayableAudios!;
            _wasSortFilterAudioSettingsApplied = false;
          } else {
            _selectedPlaylistsPlayableAudios = expandablePlaylistListVM
                .getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
              audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
            );
          }
          if (expandablePlaylistListVM.isAudioListFilteredAndSorted()) {
            // Scroll the sublist to the top when the audio
            // list is filtered and/or sorted
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });
          }

          return ListView.builder(
            key: const Key('audio_list'),
            controller: _scrollController,
            itemCount: _selectedPlaylistsPlayableAudios.length,
            itemBuilder: (BuildContext context, int index) {
              final audio = _selectedPlaylistsPlayableAudios[index];
              return AudioListItemWidget(
                audio: audio,
                warningMessageVM: warningMessageVMlistenFalse,
                onPageChangedFunction: widget.onPageChangedFunction,
              );
            },
          );
        },
      ),
    );
  }

  Consumer<PlaylistListVM> _buildExpandedPlaylistList() {
    return Consumer<PlaylistListVM>(
      builder: (context, expandablePlaylistListVM, child) {
        if (expandablePlaylistListVM.isListExpanded) {
          List<Playlist> upToDateSelectablePlaylists =
              expandablePlaylistListVM.getUpToDateSelectablePlaylists();
          return Expanded(
            child: ListView.builder(
              key: const Key('expandable_playlist_list'),
              itemCount: upToDateSelectablePlaylists.length,
              itemBuilder: (context, index) {
                Playlist playlist = upToDateSelectablePlaylists[index];
                return Builder(
                  builder: (listTileContext) {
                    return PlaylistListItemWidget(
                      settingsDataService: widget.settingsDataService,
                      playlist: playlist,
                      index: index,
                    );
                  },
                );
              },
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

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

  Row _buildSecondLine({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
    required PlaylistListVM playlistListVMlistenFalse,
    required PlaylistListVM playlistListVMlistenTrue,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    final AudioDownloadVM audioDownloadViewModel = Provider.of<AudioDownloadVM>(
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
            message: AppLocalizations.of(context)!.playlistToggleButtonTooltip,
            child: TextButton(
              key: const Key('playlist_toggle_button'),
              style: ButtonStyle(
                shape: getButtonRoundedShape(
                  currentTheme: themeProviderVM.currentTheme,
                ),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding,
                    vertical: 0,
                  ),
                ),
                overlayColor: textButtonTapModification, // Tap feedback color
              ),
              onPressed: () {
                playlistListVMlistenFalse.toggleList();
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
        (playlistListVMlistenTrue.isListExpanded)
            ? _buildPlaylistMoveIconButtons(
                playlistListVMlistenFalse,
              )
            : (playlistListVMlistenTrue.isOnePlaylistSelected)
                ? _buildSortFilterParmsDropdownButton(
                    playlistListVMlistenFalse: playlistListVMlistenFalse,
                    warningMessageVMlistenFalse: warningMessageVMlistenFalse,
                  )
                : _buildPlaylistMoveIconButtons(playlistListVMlistenFalse),
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
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
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
                      // downloading audios of selected playlists so that
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
                      await Provider.of<AudioDownloadVM>(context, listen: false)
                          .downloadPlaylistAudios(
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
              fillColor: MaterialStateColor.resolveWith(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.grey.shade800;
                  }
                  return kDarkAndLightEnabledIconColor;
                },
              ),
              value: audioDownloadViewModel.isHighQuality,
              onChanged: (arePlaylistDownloadWidgetsEnabled)
                  ? (bool? value) {
                      bool isHighQuality = value ?? false;
                      audioDownloadViewModel.setAudioQuality(
                          isHighQuality: isHighQuality);
                      String snackBarMessage = isHighQuality
                          ? AppLocalizations.of(context)!
                              .audioQualityHighSnackBarMessage
                          : AppLocalizations.of(context)!
                              .audioQualityLowSnackBarMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        AudioLearnSnackBar(
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
  /// AND if a playlist is selected.
  ///
  /// This method return a row containing the sort filter
  /// dropdown button. This button contains the list of sort
  /// filter parameters dropdown items which were saved by the
  /// user.
  Row _buildSortFilterParmsDropdownButton({
    required PlaylistListVM playlistListVMlistenFalse,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    String hintDefault =
        AppLocalizations.of(context)!.sortFilterParametersDefaultName;

    bool wasLanguageChanged = false;

    if (hintDefault == "défaut") {
      if (playlistListVMlistenFalse.deleteAudioSortFilterParameters(
              audioSortFilterParametersName: "default") !=
          null) {
        wasLanguageChanged = true;
        if (_selectedSortFilterParametersName == "default") {
          // avoids UI problem since the currently selected sort and
          // filter parameters name (default) is no longer available
          // since it was deleted
          _selectedSortFilterParametersName = "défaut";
        }
      }
    } else if (hintDefault == "default") {
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
        _selectedSortFilterParametersName != hintDefault) {
      // if the selected sort and filter parameters name is not the
      // default name, then the sort and filter parameters are applied
      // to the selected playlist playable audios. Otherwise, when the
      // user change the language, the default sort and filter parameters
      // are applied to the selected playlist playable audios instead of
      // the currently selected sort and filter parameters.
      _updatePlaylistSortedFilteredAudioList(
        playlistListVMlistenFalse: playlistListVMlistenFalse,
        notifyListeners: false,
      );
    }

    Map<String, AudioSortFilterParameters> audioSortFilterParametersMap =
        playlistListVMlistenFalse.getAudioSortFilterParametersMap();

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: kDropdownButtonMaxWidth,
          ),
          child: DropdownButton<String>(
            value: _selectedSortFilterParametersName,
            items: dropdownMenuItems,
            onChanged: (value) {
              // here, the user has selected a sort/filter option;
              // ontap code was executed before the onChanged code !
              // The onTap code is now deleted.
              _selectedSortFilterParametersName = value;
              _updatePlaylistSortedFilteredAudioList(
                  playlistListVMlistenFalse: playlistListVMlistenFalse);
            },
            hint: Text(
              hintDefault,
            ),
            underline: Container(), // suppresses the underline
          ),
        ),
      ],
    );
  }

  void _updatePlaylistSortedFilteredAudioList({
    required PlaylistListVM playlistListVMlistenFalse,
    bool notifyListeners = true,
  }) {
    AudioSortFilterParameters audioSortFilterParameters =
        playlistListVMlistenFalse.getAudioSortFilterParameters(
      audioSortFilterParametersName: _selectedSortFilterParametersName!,
    );
    playlistListVMlistenFalse
        .setSortedFilteredSelectedPlaylistPlayableAudiosAndParms(
      sortedFilteredSelectedPlaylistsPlayableAudios: playlistListVMlistenFalse
          .getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
        audioSortFilterParameters: audioSortFilterParameters,
      ),
      audioSortFilterParameters: audioSortFilterParameters,
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
                                playlistListVMlistenFalse,
                                audioSortFilterParametersName,
                                audioSortFilterParametersMap,
                                audioSortFilterParametersNamesLst,
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
  /// and then save them to a the existing name or to new name or
  /// delete them.
  Widget _buildSortFilterParmsDropdownItemEditIconButton(
      PlaylistListVM playlistListVMlistenFalse,
      String audioSortFilterParametersName,
      Map<String, AudioSortFilterParameters> audioSortFilterParametersMap,
      List<String> audioSortFilterParametersNamesLst,
      WarningMessageVM warningMessageVMlistenFalse) {
    return SizedBox(
      width: kDropdownItemEditIconButtonWidth,
      child: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          // Using FocusNode to enable clicking on Enter to close
          // the dialog
          final FocusNode focusNode = FocusNode();

          showDialog<List<dynamic>>(
            context: context,
            barrierDismissible: false, // This line prevents the dialog from
            // closing when tapping outside the dialog
            builder: (BuildContext context) {
              return AudioSortFilterDialogWidget(
                selectedPlaylistAudioLst: playlistListVMlistenFalse
                    .getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
                  audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
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
              // on sort and filter dialog opened by editing
              // a sort and filter dropdown menu item
              if (filterSortAudioAndParmLst == 'delete') {
                // user clicked on Delete button

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
                // user clicked on Save button
                List<Audio> returnedAudioList = filterSortAudioAndParmLst[0];
                AudioSortFilterParameters audioSortFilterParameters =
                    filterSortAudioAndParmLst[1];
                String sortFilterParametersSaveAsName =
                    filterSortAudioAndParmLst[2];

                playlistListVMlistenFalse
                    .setSortedFilteredSelectedPlaylistPlayableAudiosAndParms(
                  sortedFilteredSelectedPlaylistsPlayableAudios:
                      returnedAudioList,
                  audioSortFilterParameters: audioSortFilterParameters,
                );
                _wasSortFilterAudioSettingsApplied = true;

                // selecting the sort and filter parameters drop down
                // button item corresponding to the saved sort and
                // filter parameters
                _selectedSortFilterParametersName =
                    sortFilterParametersSaveAsName;
              }
            }
          });
          focusNode.requestFocus();
        },
      ),
    );
  }

  Row _buildPlaylistMoveIconButtons(
    PlaylistListVM playlistListVMlistenFalse,
  ) {
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
            padding: const EdgeInsets.all(0),
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
            padding: const EdgeInsets.all(0),
            icon: const Icon(
              Icons.arrow_drop_up,
              size: kUpDownButtonSize,
            ),
          ),
        ),
      ],
    );
  }

  SizedBox _buildFirstLine({
    required BuildContext context,
    required AudioDownloadVM audioDownloadViewModel,
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
          _buildPlaylistUrlAndTitle(
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
            audioDownloadViewModel: audioDownloadViewModel,
            themeProviderVM: themeProviderVM,
            playlistListVMlistenFalse: playlistListVMlistenFalse,
            warningMessageVMlistenFalse: warningMessageVMlistenFalse,
          ),
          const SizedBox(
            width: kRowSmallWidthSeparator,
          ),
          _buildStopDownloadButton(
            context: context,
            audioDownloadViewModel: audioDownloadViewModel,
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
                  'clear_sort_and_filter_audio_options_history_menu_item'),
              enabled: (playlistListVMlistenFalse
                  .getSearchHistoryAudioSortFilterParametersLst()
                  .isNotEmpty),
              value: PopupMenuButtonType.clearSortFilterAudioParmsHistory,
              child: Text(AppLocalizations.of(context)!
                  .clearSortFilterAudiosParmsHistoryMenu),
            ),
            PopupMenuItem<PopupMenuButtonType>(
              key: const Key(
                  'save_sort_and_filter_audio_options_in_playlist_menu_item'),
              enabled: (playlistListVMlistenFalse
                  .areButtonsApplicableToAudioEnabled),
              value: PopupMenuButtonType.saveSortFilterAudioParmsToPlaylist,
              child: Text(AppLocalizations.of(context)!
                  .saveSortFilterAudiosOptionsToPlaylistMenu),
            ),
            PopupMenuItem<PopupMenuButtonType>(
              key: const Key('update_playlist_json_dialog_item'),
              value: PopupMenuButtonType.updatePlaylistJson,
              child: Tooltip(
                message: AppLocalizations.of(context)!
                    .updatePlaylistJsonFilesMenuTooltip,
                child: Text(
                    AppLocalizations.of(context)!.updatePlaylistJsonFilesMenu),
              ),
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
                  return AudioSortFilterDialogWidget(
                    selectedPlaylistAudioLst: playlistListVMlistenFalse
                        .getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters(
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
                  playlistListVMlistenFalse
                      .setSortedFilteredSelectedPlaylistPlayableAudiosAndParms(
                    sortedFilteredSelectedPlaylistsPlayableAudios:
                        returnedAudioList,
                    audioSortFilterParameters: audioSortFilterParameters,
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
                  return ActionConfirmDialogWidget(
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
              showDialog<bool>(
                context: context,
                barrierDismissible:
                    false, // This line prevents the dialog from closing
                // when tapping outside the dialog
                builder: (BuildContext context) {
                  return PlaylistSortFilterOptionsSaveToDialogWidget(
                    playlistTitle:
                        playlistListVMlistenFalse.uniqueSelectedPlaylist!.title,
                    applicationViewType:
                        AudioLearnAppViewType.playlistDownloadView,
                  );
                },
              ).then((isSortFilterParmsApplicationAutomatic) {
                if (isSortFilterParmsApplicationAutomatic != null) {
                  // if the user clicked on Save, not on Cancel button
                  playlistListVMlistenFalse
                      .savePlaylistAudioSortFilterParmsToPlaylist(
                    audioLearnAppView:
                        AudioLearnAppViewType.playlistDownloadView,
                    isSortFilterParmsApplicationAutomatic:
                        isSortFilterParmsApplicationAutomatic,
                  );
                }
              });
              break;
            case PopupMenuButtonType.updatePlaylistJson:
              playlistListVMlistenFalse.updateSettingsAndPlaylistJsonFiles();
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
    required AudioDownloadVM audioDownloadViewModel,
    required ThemeProviderVM themeProviderVM,
  }) {
    bool isButtonEnabled = audioDownloadViewModel.isDownloading &&
        !audioDownloadViewModel.isDownloadStopping;

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
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
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
                  audioDownloadViewModel.stopDownload();
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
    required AudioDownloadVM audioDownloadViewModel,
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
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(
                  horizontal: kSmallButtonInsidePadding,
                  // necessary to display english text
                  vertical: 0),
            ),
            overlayColor: textButtonTapModification, // Tap feedback color
          ),
          onPressed: () {
            // disabling the sorted filtered playable audio list
            // downloading audios of selected playlists so that
            // the currently displayed audio list is not sorted
            // or/and filtered. This way, the newly downloaded
            // audio will be added at top of the displayed audio
            // list.
            playlistListVMlistenFalse.disableSortedFilteredPlayableAudioLst();

            Playlist? selectedTargetPlaylist;

            showDialog<dynamic>(
              context: context,
              builder: (context) => PlaylistOneSelectableDialogWidget(
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

              selectedTargetPlaylist = value["selectedPlaylist"];

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
                      AppLocalizations.of(context)!
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
                  bool isSingleVideoAudioCorrectlyDownloaded =
                      await audioDownloadViewModel.downloadSingleVideoAudio(
                    videoUrl: _playlistUrlController.text.trim(),
                    singleVideoTargetPlaylist: selectedTargetPlaylist!,
                  );

                  if (isSingleVideoAudioCorrectlyDownloaded) {
                    // if the single video audio has been
                    // correctly downloaded, then the playlistUrl
                    // field is cleared
                    _playlistUrlController.clear();
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

  Expanded _buildPlaylistUrlAndTitle({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenTrue,
  }) {
    return Expanded(
      // necessary to avoid Exception
      child: Column(
        children: [
          Expanded(
            flex: 6, // controls the height ratio
            child: TextField(
              key: const Key('playlistUrlTextField'),
              controller: _playlistUrlController,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.ytPlaylistLinkLabel,
                hintText: AppLocalizations.of(context)!.ytPlaylistLinkHintText,
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.all(2),
              ),
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 4, // controls the height ratio
            child: TextField(
              key: const Key('selectedPlaylistTextField'),
              readOnly: true,
              controller: TextEditingController(
                // using playlistListVM with listen:True guaranties
                // that the selected playlist title is updated when
                // the selected playlist changes
                text: playlistListVMlistenTrue.uniqueSelectedPlaylist?.title ??
                    '',
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.all(2),
              ),
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
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(
                horizontal: kSmallButtonInsidePadding,
                vertical: 0,
              ),
            ),
            overlayColor: textButtonTapModification, // Tap feedback color
          ),
          onPressed: () {
            final String playlistUrl = _playlistUrlController.text.trim();
            showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AddPlaylistDialogWidget(
                  playlistUrl: playlistUrl,
                );
              },
            ).then((value) {
              // not null value is boolean
              if (value ?? false) {
                // if value is null, value is false. Value is null if
                // clicking on Cancel or if the dialog is dismissed
                // by clicking outside the dialog.
                //
                // If a Youtube playlist has been added, then the
                // playlistUrlController is cleared.
                _playlistUrlController.clear();
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
