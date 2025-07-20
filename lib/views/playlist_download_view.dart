import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:audiolearn/utils/duration_expansion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'package:window_size/window_size.dart';

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
import 'widgets/audio_list_item.dart';
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
  final double playlistNotExpandedScrollAugmentation =
      (ScreenMixin.isHardwarePc()) ? 1.38 : 1.55;
  final double playlistExpandedScrollAugmentation =
      (ScreenMixin.isHardwarePc()) ? 1 : 1.5;
  final double playlistItemHeight = (ScreenMixin.isHardwarePc() ? 51 : 85);
  final bool isTest;

  PlaylistDownloadView({
    super.key,
    required this.settingsDataService,
    required this.onPageChangedFunction,
    this.isTest = false, // false reduce the app size on Windows. True
    //                      increase it.
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
  List<Audio> _selectedPlaylistPlayableAudioLst = [];
  bool _wasSortFilterAudioSettingsApplied = false;
  String? _selectedSortFilterParametersName;
  bool _doNotScroll = false;
  String _selectedPlaylistAudioSortFilterParmsName = '';
  bool _containsURL = false;
  Timer? _debounce;
  late PlaylistListVM _playlistListVMlistenTrue;

  @override
  initState() {
    super.initState();

    _playlistUrlOrSearchController.addListener(_onTextChanged);

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

    if (widget.isTest) {
      setWindowsAppSizeAndPosition(
        isTest: true, // true increase the test app width on Windows
      );
    }
  }

  /// If app runs on Windows, Linux or MacOS, set the app size
  /// and position.
  Future<void> setWindowsAppSizeAndPosition({
    required bool isTest,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await getScreenList().then((List<Screen> screens) {
        // Assumez que vous voulez utiliser le premier écran (principal)
        final Screen screen = screens.first;
        final Rect screenRect = screen.visibleFrame;

        // Définissez la largeur et la hauteur de votre fenêtre
        double windowWidth = (isTest) ? 900 : 730;
        const double windowHeight = 1300;

        // Calculez la position X pour placer la fenêtre sur le côté droit de l'écran
        final double posX = screenRect.right - windowWidth + 10;
        // Optionnellement, ajustez la position Y selon vos préférences
        final double posY = (screenRect.height - windowHeight) / 2;

        final Rect windowRect =
            Rect.fromLTWH(posX, posY, windowWidth, windowHeight);
        setWindowFrame(windowRect);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _playlistUrlOrSearchController.removeListener(_onTextChanged);
    _playlistUrlOrSearchController.dispose();
    _audioScrollController.dispose();
    _playlistScrollController.dispose();

    super.dispose();
  }

  void _onTextChanged() {
    // Cancel any previous debounce timer
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // Set a new timer
    _debounce = Timer(const Duration(milliseconds: 100), () {
      // This code will run after 300ms of inactivity
      final value = _playlistUrlOrSearchController.text;

      if (value.toLowerCase().contains('https://') ||
          value.toLowerCase().contains('http://')) {
        _containsURL = true;
      } else {
        _containsURL = false;
      }

      if (value.isEmpty || _containsURL) {
        _playlistListVMlistenTrue.disableSearchSentence();
      } else {
        _playlistListVMlistenTrue.isSearchButtonEnabled = true;
      }

      _playlistListVMlistenTrue.searchSentence = value;

      if (!_playlistListVMlistenTrue.isPlaylistListExpanded &&
          _playlistListVMlistenTrue.wasSearchButtonClicked) {
        // Applying sort and filter parameters change if search
        // sentence was changed only if the search button was clicked.
        _applySortFilterParmsNameChange(
          playlistListVMlistenFalseOrTrue: _playlistListVMlistenTrue,
          notifyListeners: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AudioDownloadVM audioDownloadVMlistenfalse =
        Provider.of<AudioDownloadVM>(
      context,
      listen: false,
    );
    final AudioDownloadVM audioDownloadVMlistenTrue =
        Provider.of<AudioDownloadVM>(
      context,
      listen: true,
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
    _playlistListVMlistenTrue = Provider.of<PlaylistListVM>(
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
          playlistListVMlistenTrue: _playlistListVMlistenTrue,
          warningMessageVMlistenFalse: warningMessageVMlistenFalse,
        ),

        // displaying the currently downloading audiodownload
        // informations or nothing.
        _buildDisplayDownloadProgressionInfo(),

        // displaying the currently playlist(s) audio saved to
        // ZIP informations or nothing.
        _buildDisplayPlaylistsMp3SaveToZipProgressionInfo(),

        _buildSecondLine(
            context: context,
            themeProviderVM: themeProviderVM,
            playlistListVMlistenFalse: playlistListVMlistenFalse,
            playlistListVMlistenTrue: _playlistListVMlistenTrue,
            warningMessageVMlistenFalse: warningMessageVMlistenFalse),
        _buildExpandedPlaylistList(
          playlistListVMlistenFalse: playlistListVMlistenFalse,
          audioDownloadVMlistenTrue: audioDownloadVMlistenTrue,
        ),
        (playlistListVMlistenFalse.isPlaylistListExpanded)
            ? const Divider(
                color:
                    kDarkAndLightEnabledIconColor, // Set the color of the divider
                thickness: 1.0, // Set the thickness of the divider
              )
            : const SizedBox.shrink(), // the list of playlists is collapsed
        _buildExpandedAudioList(
          playlistListVMlistenTrue: _playlistListVMlistenTrue,
          audioDownloadVMlistenTrue: audioDownloadVMlistenTrue,
          warningMessageVMlistenFalse: warningMessageVMlistenFalse,
        ),
      ],
    );
  }

  Widget _buildExpandedAudioList({
    required PlaylistListVM playlistListVMlistenTrue,
    required AudioDownloadVM audioDownloadVMlistenTrue,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    if (_wasSortFilterAudioSettingsApplied) {
      List<Audio> sortedFilteredSelectedPlaylistPlayableAudioLst;

      sortedFilteredSelectedPlaylistPlayableAudioLst = playlistListVMlistenTrue
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
              audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
              passedAudioSortFilterParametersName:
                  _selectedPlaylistAudioSortFilterParmsName);

      if (sortedFilteredSelectedPlaylistPlayableAudioLst.isNotEmpty) {
        // Here, the user has selected a sort filter parameters
        // in (defined sf parms or default sf parms) in the sort
        // filter parameters button or he has defined a sf parms
        // in the sort filter dialog and clicked on the save or
        // on the apply button.
        //
        // If the sort and filter audio settings have been applied
        // then the sortedFilteredSelectedPlaylistPlayableAudioLst
        // which contains the audio sorted and filtered by the sf
        // parms selected or defined by the user is used to display
        // the audio list.
        _selectedPlaylistPlayableAudioLst =
            sortedFilteredSelectedPlaylistPlayableAudioLst;
        _wasSortFilterAudioSettingsApplied = false;
      } else {
        _selectedPlaylistPlayableAudioLst = [];
      }
    } else {
      _selectedPlaylistPlayableAudioLst = playlistListVMlistenTrue
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
        passedAudioSortFilterParametersName:
            _selectedPlaylistAudioSortFilterParmsName,
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
        itemCount: _selectedPlaylistPlayableAudioLst.length,
        itemBuilder: (BuildContext context, int index) {
          final audio = _selectedPlaylistPlayableAudioLst[index];
          return AudioListItem(
            audio: audio,
            isAudioCurrent:
                (currentAudio != null) ? audio == currentAudio : false,
            warningMessageVM: warningMessageVMlistenFalse,
            onPageChangedFunction: widget.onPageChangedFunction,
          );
        },
      ),
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
    } else {
      // necessary, otherwise _selectedSortFilterParametersName will be set
      // to default after an audio was downloaded. It will not be possible
      // to add a selected SF parm to the current playlist.
      _doNotScroll = false;
    }

    if (_doNotScroll) {
      // In this case, the default sort and filter parameters are applied.
      // This guarantees that the newly downloaded audio will be displayed
      // at the top of the audio list.
      _applyDefaultAudioSortFilterParms(
        playlistListVMlistenFalseOrTrue: playlistListVMlistenTrue,
        notifyListeners: false, // was true, but caused error in the
        //                         application due to the fact that the
        //                         audio list was updated while the
        //                         audio list was being built.
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

    double scrollPositionNumber = audioToScrollPosition.toDouble();

    if (audioToScrollPosition > 300) {
      if (!isPlaylistListExpanded) {
        scrollPositionNumber *= 1.23 / 1.29;
      } else {
        scrollPositionNumber *= 1.23 / 1.244;
      }
    } else if (audioToScrollPosition > 200) {
      scrollPositionNumber *= 1.21;
    } else if (audioToScrollPosition > 120) {
      scrollPositionNumber *= 1.125;
    }

    if (!isPlaylistListExpanded) {
      // the list of playlists is collapsed ...
      scrollPositionNumber *= widget.playlistNotExpandedScrollAugmentation;
    } else {
      // the list of playlists is expanded ...
      scrollPositionNumber *= widget.playlistExpandedScrollAugmentation;
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
    required AudioDownloadVM audioDownloadVMlistenTrue,
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
        audioDownloadVMlistenTrue: audioDownloadVMlistenTrue,
      );

      return expanded;
    } else {
      // the list of playlists is collapsed
      return const SizedBox.shrink();
    }
  }

  void _scrollToSelectedPlaylist({
    required PlaylistListVM playlistListVMlistenFalse,
    required AudioDownloadVM audioDownloadVMlistenTrue,
  }) {
    List<Playlist> selectablePlaylists;
    String searchSentence = playlistListVMlistenFalse.searchSentence;
    int playlistToScrollPosition = 0;
    int noScrollPositionValue = 0; // position value avoiding scrolling down

    if (audioDownloadVMlistenTrue.isDownloading) {
      // When an audio is downloading, the list of playlist must not
      // scrolled to the current playlist, what happens if this test
      // is not performed.
      return;
    }

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

    if (isPlaylistListExpanded &&
        playlistToScrollPosition != 0 && // the case if aplaylist located
        //                                  at the bottom of the list is
        //                                  moved at top by typing on the
        //                                  moved down icon button
        playlistToScrollPosition <= noScrollPositionValue) {
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
                audioDownloadVMlistenTrue: audioDownloadVMlistenTrue,
              ));
    }
  }

  /// If an audio is downloading, the download progression is displayed.
  /// Otherwise, nothing is displayed.
  Consumer<AudioDownloadVM> _buildDisplayDownloadProgressionInfo() {
    return Consumer<AudioDownloadVM>(
      builder: (context, audioDownloadVMlistenTrue, child) {
        if (audioDownloadVMlistenTrue.isDownloading) {
          String downloadProgressPercent =
              '${(audioDownloadVMlistenTrue.downloadProgress * 100).toStringAsFixed(1)}%';
          String downloadFileSize = UiUtil.formatLargeSizeToKbOrMb(
            context: context,
            sizeInBytes:
                audioDownloadVMlistenTrue.currentDownloadingAudio.audioFileSize,
          );
          String downloadSpeed = '${UiUtil.formatLargeSizeToKbOrMb(
            context: context,
            sizeInBytes: audioDownloadVMlistenTrue.lastSecondDownloadSpeed,
          )}/sec';
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  audioDownloadVMlistenTrue
                      .currentDownloadingAudio.validVideoTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                LinearProgressIndicator(
                    value: audioDownloadVMlistenTrue.downloadProgress),
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

  /// If an audio is downloading, the download progression is displayed.
  /// Otherwise, nothing is displayed.
  Consumer<PlaylistListVM> _buildDisplayPlaylistsMp3SaveToZipProgressionInfo() {
    return Consumer<PlaylistListVM>(
      builder: (context, playlistListVMlistenTrue, child) {
        if (playlistListVMlistenTrue.isSaving) {
          String audioMp3SaveUniquePlaylistName =
              playlistListVMlistenTrue.audioMp3SaveUniquePlaylistName;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  (audioMp3SaveUniquePlaylistName.isNotEmpty)
                      ? AppLocalizations.of(context)!
                          .savingUniquePlaylistAudioMp3(
                          audioMp3SaveUniquePlaylistName,
                        )
                      : AppLocalizations.of(context)!
                          .savingMultiplePlaylistsAudioMp3,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                LinearProgressIndicator(), // Indeterminate progress bar
                const SizedBox(height: 10.0),
                Text(
                  AppLocalizations.of(context)!.savingApproximativeTime(
                      playlistListVMlistenTrue.savingAudioMp3FileToZipDuration
                          .HHmmss()),
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
  /// button, the download selected playlist button, the audio quality
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
        _buildSearchIconButton(
            playlistListVMlistenTrue, playlistListVMlistenFalse),
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

                      await playlistListVMlistenFalse
                          .downloadSelectedPlaylists();
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
          isAudioPopumMenuEnabled:
              playlistListVMlistenTrue.isOnePlaylistSelected,
        ),
      ],
    );
  }

  SizedBox _buildSearchIconButton(PlaylistListVM playlistListVMlistenTrue,
      PlaylistListVM playlistListVMlistenFalse) {
    return SizedBox(
      width: kSmallIconButtonWidth,
      child: ValueListenableBuilder<String?>(
        valueListenable:
            playlistListVMlistenTrue.youtubeLinkOrSearchSentenceNotifier,
        builder: (context, currentUrlOrSearchSentence, child) {
          CircleAvatar circleAvatar;
          const Icon searchIconButton = Icon(
            Icons.search,
            size: kSmallIconButtonWidth,
          );

          return ValueListenableBuilder<bool>(
            valueListenable:
                playlistListVMlistenTrue.urlContainedInYoutubeLinkNotifier,
            builder: (context, isUrlContainedInYoutubeLink, child) {
              // Enables to disable the search button if an url is entered
              // in the Youtube link text field.
              return ValueListenableBuilder<bool>(
                valueListenable:
                    playlistListVMlistenTrue.wasSearchButtonClickedNotifier,
                builder: (context, wasSearchButtonClicked, child) {
                  if (wasSearchButtonClicked) {
                    circleAvatar = formatIconBackAndForgroundColor(
                      context: context,
                      iconToFormat: searchIconButton,
                      isIconHighlighted:
                          true, // since the search icon was clicked, it is
                      //           highlighted
                      iconSize: kSmallIconButtonWidth * 0.8,
                      radius: 11,
                    );
                  } else if (currentUrlOrSearchSentence == null ||
                      isUrlContainedInYoutubeLink) {
                    circleAvatar = formatIconBackAndForgroundColor(
                      context: context,
                      iconToFormat: searchIconButton,
                      isIconHighlighted: false, // since the search icon has not
                      //                            yet been clicked, it is not
                      //                            highlighted
                      isIconDisabled:
                          true, // since the search sentence is empty
                      //                       the search icon is disabled
                    );
                  } else {
                    circleAvatar = formatIconBackAndForgroundColor(
                      context: context,
                      iconToFormat: searchIconButton,
                      isIconHighlighted: false, // since the search icon has not
                      //                            yet been clicked, it is not
                      //                            highlighted
                    );
                  }

                  return InkWell(
                    key: const Key('search_icon_button'),
                    onTap: (currentUrlOrSearchSentence != null &&
                            currentUrlOrSearchSentence.isNotEmpty)
                        ? () {
                            // This if statement is used enables to click on the
                            // search icon button in order to disable the search
                            // sentence without clearing the text field.
                            //
                            // This enables to use the search sentence on another
                            // playlist without having to retype the search
                            // sentence in the text field.
                            if (playlistListVMlistenFalse
                                .wasSearchButtonClicked) {
                              playlistListVMlistenFalse.wasSearchButtonClicked =
                                  false; // the search button is set not clicked
                              playlistListVMlistenFalse
                                  .isSearchSentenceApplied = false;

                              return;
                            } else {
                              playlistListVMlistenFalse.wasSearchButtonClicked =
                                  true; // the search button was clicked
                            }

                            if (!playlistListVMlistenTrue
                                .isPlaylistListExpanded) {
                              // the list of playlists is collapsed
                              playlistListVMlistenFalse
                                  .isSearchSentenceApplied = true;
                              _applySortFilterParmsNameChange(
                                playlistListVMlistenFalseOrTrue:
                                    playlistListVMlistenFalse,
                                notifyListeners: true,
                              );
                            }
                          }
                        : null,
                    child: SizedBox(
                      width:
                          85, // Adjust this width based on the size of your largest icon
                      child: Center(child: circleAvatar),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
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
    // must be deleted from the list since the default sort and filter
    // parameters named in the current language is now in the list.
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
        playlistListVMlistenFalse: playlistListVMlistenFalse,
        notifyListeners: false,
      );
    }

    Map<String, AudioSortFilterParameters> audioSortFilterParametersMap =
        widget.settingsDataService.namedAudioSortFilterParametersMap;

    String selectedPlaylistAudioSortFilterParmsName = playlistListVMlistenTrue
        .getSelectedPlaylistAudioSortFilterParmsNameForView(
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
                    .getSelectedPlaylistAudioSortFilterParmsNameForView(
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
                    playlistListVMlistenFalseOrTrue: playlistListVMlistenFalse,
                  ),
            items: dropdownMenuItems,
            onChanged: (value) {
              _selectedSortFilterParametersName = value;
              _updatePlaylistSortedFilteredAudioList(
                  playlistListVMlistenFalse: playlistListVMlistenFalse);
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
  /// sort/filter dropdown button list. The selected sort/filter parameters
  /// are applied to the selected playlist audio list.
  String _applySortFilterParmsNameChange({
    required PlaylistListVM playlistListVMlistenFalseOrTrue,
    notifyListeners = false,
  }) {
    _selectedSortFilterParametersName = playlistListVMlistenFalseOrTrue
        .getSelectedPlaylistAudioSortFilterParmsNameForView(
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
        playlistListVMlistenFalse: playlistListVMlistenFalseOrTrue,
        searchSentence: searchSentence,
        notifyListeners: notifyListeners); // If true, causes displayed audio
    //                                        list update.
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
        playlistListVMlistenFalse: playlistListVMlistenFalseOrTrue,
        searchSentence: '',
        notifyListeners: notifyListeners); // If true, causes displayed audio
    //                                    list update.
    //                         If false, avoids rebuilding the widget and
    //                         avoids integration test failure

    return _selectedSortFilterParametersName!; // is not null
  }

  /// Updates the sorted and filtered audio list of the selected playlist
  /// according to the sort and filter parameters selected in the dropdown
  /// button list as well as the entered search sentence.
  void _updatePlaylistSortedFilteredAudioList({
    required PlaylistListVM playlistListVMlistenFalse,
    String searchSentence = '',
    bool notifyListeners = true,
  }) {
    if (_selectedSortFilterParametersName == null) {
      return;
    }

    AudioSortFilterParameters audioSortFilterParameters =
        playlistListVMlistenFalse.getAudioSortFilterParameters(
      audioSortFilterParametersName: _selectedSortFilterParametersName!,
    );

    playlistListVMlistenFalse
        .setSortFilterForSelectedPlaylistPlayableAudiosAndParms(
      audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      sortFilteredSelectedPlaylistPlayableAudio: playlistListVMlistenFalse
          .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
        passedAudioSortFilterParameters: audioSortFilterParameters,
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
                settingsDataService: widget.settingsDataService,
                warningMessageVM: warningMessageVMlistenFalse,
                selectedPlaylist:
                    playlistListVMlistenFalse.uniqueSelectedPlaylist!,
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
                audioLearnAppViewType:
                    AudioLearnAppViewType.playlistDownloadView,
                focusNode: focusNode,
                calledFrom: CalledFrom.playlistDownloadView,
              );
            },
          ).then((filterSortAudioAndParmLst) {
            if (filterSortAudioAndParmLst != null &&
                filterSortAudioAndParmLst.isNotEmpty) {
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
  /// selected playlist title and the applied SF parms name, the add
  /// playlist button, the download single video button and the stop
  /// download or delete playlist URL text field button.
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
          _buildSingleVideoDownloadButton(
            context: context,
            themeProviderVM: themeProviderVM,
            playlistListVMlistenFalse: playlistListVMlistenFalse,
            audioDownloadVMlistenFalse: audioDownloadVMlistenFalse,
            warningMessageVMlistenFalse: warningMessageVMlistenFalse,
          ),
          const SizedBox(
            width: kRowSmallWidthSeparator,
          ),
          _buildStopOrDeleteButton(
            context: context,
            playlistListVMlistenFalse: playlistListVMlistenFalse,
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
    required bool isAudioPopumMenuEnabled,
  }) {
    return SizedBox(
      width: kRowButtonGroupWidthSeparator,
      child: PopupMenuButton<PopupMenuButtonType>(
        key: const Key('audio_popup_menu_button'),
        enabled: isAudioPopumMenuEnabled,
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
              enabled: playlistListVMlistenFalse
                  .getSearchHistoryAudioSortFilterParametersLst()
                  .isNotEmpty,
              value: PopupMenuButtonType.clearSortFilterAudioParmsHistory,
              child: Text(AppLocalizations.of(context)!
                  .clearSortFilterAudiosParmsHistoryMenu),
            ),
            PopupMenuItem<PopupMenuButtonType>(
              key: const Key(
                  'save_sort_and_filter_audio_parms_in_playlist_item'),
              enabled:
                  playlistListVMlistenFalse.isSaveSFparmsToPlaylistMenuEnabled(
                audioLearnAppViewType:
                    AudioLearnAppViewType.playlistDownloadView,
                translatedAppliedSortFilterParmsName:
                    AppLocalizations.of(context)!
                        .sortFilterParametersAppliedName,
                translatedDefaultSortFilterParmsName:
                    AppLocalizations.of(context)!
                        .sortFilterParametersDefaultName,
              ),
              value: PopupMenuButtonType.saveSortFilterAudioParmsToPlaylist,
              child: Text(AppLocalizations.of(context)!
                  .saveSortFilterAudiosOptionsToPlaylistMenu),
            ),
            PopupMenuItem<PopupMenuButtonType>(
              key: const Key(
                  'remove_sort_and_filter_audio_parms_from_playlist_item'),
              enabled: playlistListVMlistenFalse
                  .isRemoveSFparmsFromPlaylistMenuEnabled(
                audioLearnAppViewType:
                    AudioLearnAppViewType.playlistDownloadView,
                translatedAppliedSortFilterParmsName:
                    AppLocalizations.of(context)!
                        .sortFilterParametersAppliedName,
              ), // this menu item is enabled if a sort filter parms is applied
              //     to  one or two views of the selected playlist
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
                    settingsDataService: widget.settingsDataService,
                    warningMessageVM: warningMessageVMlistenFalse,
                    selectedPlaylist:
                        playlistListVMlistenFalse.uniqueSelectedPlaylist!,
                    selectedPlaylistAudioLst: playlistListVMlistenFalse
                        .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
                      audioLearnAppViewType:
                          AudioLearnAppViewType.playlistDownloadView,
                    ),
                    audioSortFilterParametersName: '',
                    audioSortFilterParameters: AudioSortFilterParameters
                        .createDefaultAudioSortFilterParameters(),
                    audioLearnAppViewType:
                        AudioLearnAppViewType.playlistDownloadView,
                    focusNode: focusNode,
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
                    translatedAppliedSortFilterParmsName:
                        AppLocalizations.of(context)!
                            .sortFilterParametersAppliedName,
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
                    dialogTitleOne: AppLocalizations.of(context)!
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
                    sortFilterParmsName: playlistListVMlistenFalse
                        .getSelectedPlaylistAudioSortFilterParmsNameForView(
                      audioLearnAppViewType:
                          AudioLearnAppViewType.playlistDownloadView,
                      translatedAppliedSortFilterParmsName:
                          AppLocalizations.of(context)!
                              .sortFilterParametersDefaultName,
                    ),
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
                    selectedSortFilterParmsName: playlistListVMlistenFalse
                        .getSelectedPlaylistAudioSortFilterParmsNameForView(
                      audioLearnAppViewType:
                          AudioLearnAppViewType.playlistDownloadView,
                      translatedAppliedSortFilterParmsName:
                          AppLocalizations.of(context)!
                              .sortFilterParametersAppliedName,
                    ),
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
          }
        },
      ),
    );
  }

  Widget _buildStopOrDeleteButton({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenFalse,
    required AudioDownloadVM audioDownloadVMlistenFalse,
    required ThemeProviderVM themeProviderVM,
  }) {
    bool isAppDownloading = audioDownloadVMlistenFalse.isDownloading &&
        !audioDownloadVMlistenFalse.isDownloadStopping;

    return ValueListenableBuilder<String?>(
      valueListenable:
          playlistListVMlistenFalse.youtubeLinkOrSearchSentenceNotifier,
      builder: (context, currentUrlOrSearchSentence, child) {
        bool isUrlOrSearchEmpty = currentUrlOrSearchSentence == null ||
            currentUrlOrSearchSentence.isEmpty;

        if (isAppDownloading || isUrlOrSearchEmpty) {
          return SizedBox(
            // sets the rounded TextButton size improving the distance
            // between the button text and its boarder
            width: kNormalButtonWidth - 24,
            height: kNormalButtonHeight,
            child: Tooltip(
              message:
                  AppLocalizations.of(context)!.stopDownloadingButtonTooltip,
              child: TextButton(
                key: const Key('stopDownloadingButton'),
                style: ButtonStyle(
                  shape: getButtonRoundedShape(
                    currentTheme: themeProviderVM.currentTheme,
                    isButtonEnabled: isAppDownloading,
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
                onPressed: (isAppDownloading)
                    ? () {
                        // Flushbar creation must be located before calling
                        // the stopDownload method, otherwise the flushbar
                        // will be located higher.
                        Flushbar(
                          flushbarPosition: FlushbarPosition.TOP,
                          message: AppLocalizations.of(context)!
                              .audioDownloadingStopping,
                          duration: const Duration(seconds: 8),
                          backgroundColor: Colors.purple.shade900,
                          messageColor: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                        ).show(context);
                        audioDownloadVMlistenFalse.stopDownload();
                      }
                    : null,
                child: Text(
                  AppLocalizations.of(context)!.stopDownload,
                  style: (isAppDownloading)
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
        } else {
          return SizedBox(
            // sets the rounded TextButton size improving the distance
            // between the button text and its boarder
            width: kSmallIconButtonWidth - 2,
            child: Tooltip(
              message: AppLocalizations.of(context)!
                  .clearPlaylistUrlOrSearchButtonTooltip,
              child: IconButton(
                key: const Key('clearPlaylistUrlOrSearchButtonKey'),
                onPressed: () {
                  _playlistUrlOrSearchController.clear();
                  _containsURL = false;

                  // Disables the search button and call notifyListeners()
                  playlistListVMlistenFalse.disableSearchSentence();
                },
                style: ButtonStyle(
                  // Highlight button when pressed
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                        horizontal: kSmallButtonInsidePadding, vertical: 0),
                  ),
                  overlayColor: iconButtonTapModification, // Tap feedback color
                ),
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  size: kSmallIconButtonWidth - 2,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildSingleVideoDownloadButton({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
    required PlaylistListVM playlistListVMlistenFalse,
    required AudioDownloadVM audioDownloadVMlistenFalse,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          playlistListVMlistenFalse.urlContainedInYoutubeLinkNotifier,
      builder: (context, containsURL, child) {
        return SizedBox(
          // sets the rounded TextButton size improving the distance
          // between the button text and its boarder
          width: kSmallButtonWidth + 8, // necessary to display english text
          height: kNormalButtonHeight,
          child: Tooltip(
            message:
                AppLocalizations.of(context)!.downloadSingleVideoButtonTooltip,
            child: TextButton(
              key: const Key('downloadSingleVideoButton'),
              style: ButtonStyle(
                shape: getButtonRoundedShape(
                  currentTheme: themeProviderVM.currentTheme,
                  isButtonEnabled: containsURL,
                  context: context,
                ),
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(
                      horizontal: kSmallButtonInsidePadding,
                      // necessary to display english text
                      vertical: 0),
                ),
                overlayColor: textButtonTapModification, // Tap feedback color
              ),
              onPressed: containsURL
                  ? () {
                      // disabling the sorted filtered playable audio list
                      // downloading audio of selected playlists so that
                      // the currently displayed audio list is not sorted
                      // or/and filtered. This way, the newly downloaded
                      // audio will be added at top of the displayed audio
                      // list.
                      playlistListVMlistenFalse
                          .disableSortedFilteredPlayableAudioLst();

                      showDialog<dynamic>(
                        context: context,
                        builder: (context) => PlaylistOneSelectableDialog(
                          usedFor: PlaylistOneSelectableDialogUsedFor
                              .downloadSingleVideoAudio,
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

                        Playlist? selectedTargetPlaylist =
                            value["selectedPlaylist"];
                        bool isMusicQuality =
                            value["downloadSingleVideoAudioAtMusicQuality"] ??
                                false;

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
                                if (event.logicalKey ==
                                        LogicalKeyboardKey.enter ||
                                    event.logicalKey ==
                                        LogicalKeyboardKey.numpadEnter) {
                                  // executing the same code as in the 'Ok'
                                  // ElevatedButton onPressed callback
                                  Navigator.of(context).pop('ok');
                                }
                              }
                            },
                            child: AlertDialog(
                              title: Text(
                                AppLocalizations.of(context)!
                                    .confirmDialogTitle,
                                key: const Key('confirmationDialogTitleKey'),
                              ),
                              actionsPadding:
                                  // reduces the top vertical space between the buttons
                                  // and the content
                                  const EdgeInsets.fromLTRB(10, 0, 10,
                                      10), // Adjust the value as needed
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
                                    style: (themeProviderVM.currentTheme ==
                                            AppTheme.dark)
                                        ? kTextButtonStyleDarkMode
                                        : kTextButtonStyleLightMode,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop('ok');
                                  },
                                ),
                                TextButton(
                                  key: const Key('cancelButtonKey'),
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .cancelButton,
                                      style: (themeProviderVM.currentTheme ==
                                              AppTheme.dark)
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
                                await audioDownloadVMlistenFalse
                                    .downloadSingleVideoAudio(
                              videoUrl:
                                  _playlistUrlOrSearchController.text.trim(),
                              singleVideoTargetPlaylist:
                                  selectedTargetPlaylist!,
                              downloadAtMusicQuality: isMusicQuality,
                            );

                            if (errorType == ErrorType.noError) {
                              // if the single video audio has been
                              // correctly downloaded, then the playlistUrl
                              // field is cleared.
                              _playlistUrlOrSearchController.clear();

                              // Required, otherwise the audio list is not
                              // updated with the newly downloaded audio.
                              _updatePlaylistSortedFilteredAudioList(
                                playlistListVMlistenFalse:
                                    playlistListVMlistenFalse,
                              );
                            }
                          }
                        });
                        // required so that clicking on Enter to close the dialog
                        // works. This intruction must be located after the
                        // .then() method of the showDialog() method !
                        newFocusNode.requestFocus();
                      });
                    }
                  : null, // The button will be deactivated if containsURL is false
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // Make sure that the Row doesn't occupy
                //                       more space than necessary
                children: <Widget>[
                  Icon(
                    Icons.download_outlined,
                    size: 18,
                    // Changer la couleur de l'icône en fonction de l'état du bouton
                    color: containsURL ? null : Colors.grey,
                  ),
                  Text(
                    AppLocalizations.of(context)!.downloadSingleVideoAudio,
                    style: (containsURL)
                        ? (themeProviderVM.currentTheme == AppTheme.dark)
                            ? kTextButtonStyleDarkMode
                            : kTextButtonStyleLightMode
                        : const TextStyle(
                            // required to display the button in grey if
                            // the button is disabled
                            fontSize: kTextButtonFontSize,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    if (playlistListVMlistenTrue.isPlaylistListExpanded) {
      _selectedPlaylistAudioSortFilterParmsName = playlistListVMlistenTrue
          .getSelectedPlaylistAudioSortFilterParmsNameForView(
        audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
        translatedAppliedSortFilterParmsName:
            AppLocalizations.of(context)!.sortFilterParametersAppliedName,
      );

      if (_selectedPlaylistAudioSortFilterParmsName.isEmpty) {
        _selectedPlaylistAudioSortFilterParmsName =
            AppLocalizations.of(context)!.sortFilterParametersDefaultName;
      }
    } else {
      _selectedPlaylistAudioSortFilterParmsName = '';
    }

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
            ),
          ),
          Expanded(
            flex: 4, // controls the height ratio
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
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
                SizedBox(
                  width: kRowNormalWidthSeparator,
                ),
                Text(
                  key: const Key('selectedPlaylistSFparmNameText'),
                  // using playlistListVM with listen:True guaranties
                  // that the selected playlist title is updated when
                  // the selected playlist changes
                  _selectedPlaylistAudioSortFilterParmsName,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  maxLines: 1,
                ),
              ],
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
                // _playlistUrlOrSearchController.clear();
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
