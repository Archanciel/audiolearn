import 'package:audiolearn/views/widgets/comment_list_add_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../services/sort_filter_parameters.dart';
import '../services/settings_data_service.dart';
import '../utils/duration_expansion.dart';
import '../viewmodels/audio_player_vm.dart';
import '../viewmodels/playlist_list_vm.dart';
import '../viewmodels/warning_message_vm.dart';
import '../viewmodels/theme_provider_vm.dart';
import 'screen_mixin.dart';
import 'widgets/action_confirm_dialog_widget.dart';
import 'widgets/audios_playable_list_dialog_widget.dart';
import 'widgets/playlist_sort_filter_options_save_to_dialog_widget.dart';
import 'widgets/audio_set_speed_dialog_widget.dart';
import 'widgets/audio_sort_filter_dialog_widget.dart';

/// Screen enabling the user to play an audio, change the playing
/// position or go to a previous, next or selected audio.
class AudioPlayerView extends StatefulWidget {
  const AudioPlayerView({super.key});

  @override
  _AudioPlayerViewState createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView>
    with WidgetsBindingObserver, ScreenMixin {
  final double _audioIconSizeSmall = 35;
  final double _audioIconSizeMedium = 40;
  final double _audioIconSizeLarge = 80;
  late double _audioPlaySpeed;

  late Audio _currentAudioForHotRestart;
  // final bool _wasSortFilterAudioSettingsApplied = false;

  @override
  initState() {
    super.initState();

    // This ensures that if the globalAudioPlayerVM.currentAudio becomes
    // null due to the app's state being reset (like during hot restarts),
    // the AudioPlayerView still have a reference to the last known audio
    // object.
    _currentAudioForHotRestart = globalAudioPlayerVM.currentAudio!;
    // Used in relation of audioplayers
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// WidgetsBindingObserver method called when the app's lifecycle
  /// state changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // writeToLogFile(
        //     message:
        //         'WidgetsBinding didChangeAppLifecycleState(): app resumed'); // Provider.of<AudioGlobalPlayerVM>(context, listen: false).resume();
        break;
      // App paused and sent to background
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // writeToLogFile(
        //     message:
        //         'WidgetsBinding didChangeAppLifecycleState(): app inactive, paused or closed');

        Provider.of<AudioPlayerVM>(
          context,
          listen: false,
        ).updateAndSaveCurrentAudio(forceSave: true);
        break;
      case AppLifecycleState.detached:
        // If the app is closed while an audio is playing, ensures
        // that the audio player is disposed. Otherwise, the audio
        // will continue playing. If we close the emulator, when
        // restarting it, the audio will be playing again, and the
        // only way to stop the audio play is to restart cold
        // version of the emulator !
        //
        // WARNING: must be positioned after calling
        // updateAndSaveCurrentAudio() method, otherwise the audio
        // player remains playing !
        Provider.of<AudioPlayerVM>(
          context,
          listen: false,
        ).disposeAudioPlayer(); // Calling this method instead of
        //                         the AudioPlayerVM dispose()
        //                         method enables audio player view
        //                         integr test to be ok even if the
        //                         test app is not the active Windows
        //                         app.
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    PlaylistListVM playlistListVMlistenFalse =
        Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );

    bool areAudioButtonsEnabled =
        playlistListVMlistenFalse.areButtonsApplicableToAudioEnabled;

    if (globalAudioPlayerVM.currentAudio == null) {
      _audioPlaySpeed = 1.0;
    } else {
      _audioPlaySpeed = globalAudioPlayerVM.currentAudio!.audioPlaySpeed;
    }

    Widget viewContent = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildWarningMessageVMConsumer(
          context: context,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildSetAudioVolumeIconButton(
              context: context,
              areAudioButtonsEnabled: areAudioButtonsEnabled,
            ),
            const SizedBox(
              width: kRowButtonGroupWidthSeparator,
            ),
            _buildSetAudioSpeedTextButton(
              context: context,
              areAudioButtonsEnabled: areAudioButtonsEnabled,
            ),
            _buildCommentsIconButton(
              context: context,
              areAudioButtonsEnabled: areAudioButtonsEnabled,
            ),
            _buildAudioPopupMenuButton(
              context: context,
              playlistListVMlistenFalse: playlistListVMlistenFalse,
              warningMessageVMlistenFalse: Provider.of<WarningMessageVM>(
                context,
                listen: false,
              ),
            ),
          ],
        ),
        // const SizedBox(height: 10.0),
        _buildPlayButton(),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildStartEndButtonsWithTitle(),
            _buildAudioSlider(),
            _buildPositionButtons(),
          ],
        ),
      ],
    );

    final bool isKeyboardVisible =
        MediaQuery.of(context).viewInsets.bottom != 0;

    return Column(
      children: [
        isKeyboardVisible
            ? SingleChildScrollView(
                child: viewContent,
              )
            : Expanded(
                child: viewContent,
              )
      ],
    );
  }

  Widget _buildSetAudioVolumeIconButton({
    required BuildContext context,
    required bool areAudioButtonsEnabled,
  }) {
    return Consumer2<ThemeProviderVM, AudioPlayerVM>(
      builder: (context, themeProviderVM, globalAudioPlayerVM, child) {
        _audioPlaySpeed =
            globalAudioPlayerVM.currentAudio?.audioPlaySpeed ?? _audioPlaySpeed;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Tooltip(
              message: AppLocalizations.of(context)!
                  .decreaseAudioVolumeIconButtonTooltip,
              child: SizedBox(
                width: kSmallButtonWidth,
                child: IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: kUpDownButtonSize,
                  onPressed: (!areAudioButtonsEnabled ||
                          globalAudioPlayerVM.isCurrentAudioVolumeMin())
                      ? null // Disable the button if no audio selected or
                      //        if the volume is min
                      : () {
                          globalAudioPlayerVM.changeAudioVolume(
                            volumeChangedValue: -0.1,
                          );
                        },
                ),
              ),
            ),
            Tooltip(
              message: AppLocalizations.of(context)!
                  .increaseAudioVolumeIconButtonTooltip,
              child: SizedBox(
                width: kSmallButtonWidth,
                child: IconButton(
                    icon: const Icon(Icons.arrow_drop_up),
                    iconSize: kUpDownButtonSize,
                    onPressed: (!areAudioButtonsEnabled ||
                            globalAudioPlayerVM.isCurrentAudioVolumeMax())
                        ? null // Disable the button if no audio selected or
                        //        if the volume is max
                        : () {
                            globalAudioPlayerVM.changeAudioVolume(
                              volumeChangedValue: 0.1,
                            );
                          }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSetAudioSpeedTextButton({
    required BuildContext context,
    required bool areAudioButtonsEnabled,
  }) {
    return Consumer2<ThemeProviderVM, AudioPlayerVM>(
      builder: (context, themeProviderVM, globalAudioPlayerVM, child) {
        _audioPlaySpeed =
            globalAudioPlayerVM.currentAudio?.audioPlaySpeed ?? _audioPlaySpeed;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              // sets the rounded TextButton size improving the distance
              // between the button text and its boarder
              width: kNormalButtonWidth - 18.0,
              height: kNormalButtonHeight,
              child: Tooltip(
                message: AppLocalizations.of(context)!.setAudioPlaySpeedTooltip,
                child: TextButton(
                  key: const Key('setAudioSpeedTextButton'),
                  style: ButtonStyle(
                    shape: getButtonRoundedShape(
                      currentTheme: themeProviderVM.currentTheme,
                      isButtonEnabled: areAudioButtonsEnabled,
                      context: context,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding, vertical: 0),
                    ),
                    overlayColor:
                        textButtonTapModification, // Tap feedback color
                  ),
                  onPressed: areAudioButtonsEnabled
                      ? () {
                          showDialog<List<dynamic>>(
                            context: context,
                            builder: (BuildContext context) {
                              return AudioSetSpeedDialogWidget(
                                audioPlaySpeed: _audioPlaySpeed,
                                updateCurrentPlayAudioSpeed: true,
                              );
                            },
                          ).then((value) {
                            // not null value is double
                            if (value != null) {
                              // value is null if clicking on Cancel or if the dialog
                              // is dismissed by clicking outside the dialog.
                              _audioPlaySpeed = value[0];
                            }
                          });
                        }
                      : null,
                  child: Tooltip(
                    message:
                        AppLocalizations.of(context)!.setAudioPlaySpeedTooltip,
                    child: Text(
                      '${_audioPlaySpeed.toStringAsFixed(2)}x',
                      textAlign: TextAlign.center,
                      style: (areAudioButtonsEnabled)
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
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentsIconButton({
    required BuildContext context,
    required bool areAudioButtonsEnabled,
  }) {
    return Consumer<ThemeProviderVM>(
      builder: (context, themeProviderVM, child) {
        return Tooltip(
          message: AppLocalizations.of(context)!.commentsIconButtonTooltip,
          child: SizedBox(
            width: kSmallButtonWidth,
            child: IconButton(
              key: const Key('commentsIconButton'),
              icon: const Icon(Icons.bookmark_outline_outlined),
              iconSize: kUpDownButtonSize - 15,
              onPressed: (!areAudioButtonsEnabled)
                  ? null // Disable the button if no audio selected
                  : () {
                      showDialog<void>(
                        context: context,
                        // passing the current audio to the dialog instead
                        // of initializing a private _currentAudio variable
                        // in the dialog avoid integr test problems
                        builder: (context) => CommentListAddDialogWidget(
                          currentAudio: globalAudioPlayerVM.currentAudio ?? _currentAudioForHotRestart,
                        ),
                      );
                    },
            ),
          ),
        );
      },
    );
  }

  /// Builds the audio popup menu button located on the right of the
  /// screen. This button allows the user to sort and filter the
  /// displayed audio list and to save the sort and filter settings to
  /// the selected playlist.
  Widget _buildAudioPopupMenuButton({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenFalse,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    return SizedBox(
      width: kRowButtonGroupWidthSeparator,
      child: PopupMenuButton<PopupMenuButtonType>(
        key: const Key('audio_popup_menu_button'),
        enabled: (playlistListVMlistenFalse.areButtonsApplicableToAudioEnabled),
        icon: const Icon(Icons.filter_list),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<PopupMenuButtonType>(
              key: const Key(
                  'define_sort_and_filter_audio_settings_dialog_item'),
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
                  'save_sort_and_filter_audio_settings_in_playlist_item'),
              value: PopupMenuButtonType.saveSortFilterAudioParmsToPlaylist,
              child: Text(AppLocalizations.of(context)!
                  .saveSortFilterAudiosOptionsToPlaylistMenu),
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
                barrierDismissible:
                    false, // This line prevents the dialog from closing when tapping outside
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
                          AudioLearnAppViewType.audioPlayerView,
                        )
                        .copy(), // copy() is necessary to avoid modifying the
                    // original if saving the AudioSortFilterParameters to
                    // a new name
                    audioLearnAppViewType:
                        AudioLearnAppViewType.audioPlayerView,
                    focusNode: focusNode,
                    warningMessageVM: warningMessageVMlistenFalse,
                    calledFrom: CalledFrom.audioPlayerViewAudioMenu,
                  );
                },
              ).then((filterSortAudioAndParmLst) {
                if (filterSortAudioAndParmLst != null) {
                  List<Audio> returnedAudioList = filterSortAudioAndParmLst[0];
                  AudioSortFilterParameters audioSortFilterParameters =
                      filterSortAudioAndParmLst[1];
                  playlistListVMlistenFalse
                      .setSortedFilteredSelectedPlaylistPlayableAudiosAndParms(
                    sortedFilteredSelectedPlaylistsPlayableAudios:
                        returnedAudioList,
                    audioSortFilterParameters: audioSortFilterParameters,
                  );
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
                    // Displaying a warning message after having cleared
                    // the sort and filter audio settings search history
                    // is not necessary
                    // warningFunction: warningMessageVMlistenFalse
                    //     .allHistoricalSortFilterParametersWereDeleted,
                  );
                },
              );
              break;
            case PopupMenuButtonType.saveSortFilterAudioParmsToPlaylist:
              showDialog<bool>(
                context: context,
                barrierDismissible: false, // This line prevents the dialog from
                // closing when tapping outside the dialog
                builder: (BuildContext context) {
                  return PlaylistSortFilterOptionsSaveToDialogWidget(
                    playlistTitle:
                        playlistListVMlistenFalse.uniqueSelectedPlaylist!.title,
                    applicationViewType: AudioLearnAppViewType.audioPlayerView,
                  );
                },
              ).then((isSortFilterParmsApplicationAutomatic) {
                if (isSortFilterParmsApplicationAutomatic != null) {
                  // if the user clicked on Save, not on Cancel button
                  playlistListVMlistenFalse
                      .savePlaylistAudioSortFilterParmsToPlaylist(
                    audioLearnAppView: AudioLearnAppViewType.audioPlayerView,
                    isSortFilterParmsApplicationAutomatic:
                        isSortFilterParmsApplicationAutomatic,
                  );
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

  Widget _buildPlayButton() {
    return Consumer<AudioPlayerVM>(
      builder: (context, globalAudioPlayerVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(90.0),
              child: IconButton(
                iconSize: _audioIconSizeLarge,
                onPressed: (() async {
                  globalAudioPlayerVM.isPlaying
                      ? await globalAudioPlayerVM.pause()
                      : await globalAudioPlayerVM.playFromCurrentAudioFile();
                }),
                icon: Icon(globalAudioPlayerVM.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStartEndButtonsWithTitle() {
    return Consumer<AudioPlayerVM>(
      builder: (context, globalAudioPlayerVM, child) {
        String? currentAudioTitleWithDuration =
            globalAudioPlayerVM.getCurrentAudioTitleWithDuration();

        // If the current audio title is null, set it to the
        // 'no current audio' translated title
        currentAudioTitleWithDuration ??=
            AppLocalizations.of(context)!.audioPlayerViewNoCurrentAudio;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              key: const Key('audioPlayerViewSkipToStartButton'),
              iconSize: _audioIconSizeMedium,
              onPressed: () async => await globalAudioPlayerVM.skipToStart(),
              icon: const Icon(Icons.skip_previous),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (globalAudioPlayerVM
                      .getPlayableAudiosApplyingSortFilterParameters(
                        AudioLearnAppViewType.audioPlayerView,
                      )
                      .isEmpty) {
                    // there is no audio to play
                    return;
                  }

                  _displayOtherAudiosDialog();
                },
                child: Text(
                  currentAudioTitleWithDuration,
                  style: const TextStyle(
                    fontSize: kAudioTitleFontSize,
                  ),
                  maxLines: 5,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            GestureDetector(
              onLongPress: () {
                if (globalAudioPlayerVM
                    .getPlayableAudiosApplyingSortFilterParameters(
                      AudioLearnAppViewType.audioPlayerView,
                    )
                    .isEmpty) {
                  // there is no audio to play
                  return;
                }

                _displayOtherAudiosDialog();
              },
              child: IconButton(
                key: const Key('audioPlayerViewSkipToEndButton'),
                iconSize: _audioIconSizeMedium,
                onPressed: () async =>
                    await globalAudioPlayerVM.skipToEndAndPlay(),
                icon: const Icon(Icons.skip_next),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudioSlider() {
    return Consumer<AudioPlayerVM>(
      builder: (context, globalAudioPlayerVM, child) {
        // Obtaining the slider values here (when globalAudioPlayerVM
        // call notifyListeners()) avoids that the slider generate
        // a 'Value xxx.x is not between minimum 0.0 and maximum 0.0'
        // error
        double sliderValue =
            globalAudioPlayerVM.currentAudioPosition.inSeconds.toDouble();
        double maxDuration =
            globalAudioPlayerVM.currentAudioTotalDuration.inSeconds.toDouble();

        // Ensure the slider value is within the range
        sliderValue = sliderValue.clamp(0.0, maxDuration);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                key: const Key('audioPlayerViewAudioPosition'),
                globalAudioPlayerVM.currentAudioPosition.HHmmssZeroHH(),
                style: kSliderValueTextStyle,
              ),
              Expanded(
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: kSliderThickness,
                    thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius:
                            6.0), // Adjust the radius as you need
                  ),
                  child: Slider(
                    min: 0.0,
                    max: maxDuration,
                    value: sliderValue,
                    onChanged: (double value) async {
                      await globalAudioPlayerVM.goToAudioPlayPosition(
                        durationPosition: Duration(seconds: value.toInt()),
                      );
                    },
                  ),
                ),
              ),
              Text(
                key: const Key('audioPlayerViewAudioRemainingDuration'),
                globalAudioPlayerVM.currentAudioRemainingDuration
                    .HHmmssZeroHH(),
                style: kSliderValueTextStyle,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPositionButtons() {
    return Consumer<AudioPlayerVM>(
      builder: (context, globalAudioPlayerVM, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: _audioIconSizeMedium - 7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: IconButton(
                            key: const Key('audioPlayerViewRewind1mButton'),
                            iconSize: _audioIconSizeMedium,
                            onPressed: () async => await globalAudioPlayerVM
                                .changeAudioPlayPosition(
                              positiveOrNegativeDuration:
                                  const Duration(minutes: -1),
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            key: const Key('audioPlayerViewRewind10sButton'),
                            iconSize: _audioIconSizeMedium,
                            onPressed: () async => await globalAudioPlayerVM
                                .changeAudioPlayPosition(
                              positiveOrNegativeDuration:
                                  const Duration(seconds: -10),
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            key: const Key('audioPlayerViewForward10sButton'),
                            iconSize: _audioIconSizeMedium,
                            onPressed: () async => await globalAudioPlayerVM
                                .changeAudioPlayPosition(
                              positiveOrNegativeDuration:
                                  const Duration(seconds: 10),
                            ),
                            icon: const Icon(Icons.fast_forward),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            key: const Key('audioPlayerViewForward1mButton'),
                            iconSize: _audioIconSizeMedium,
                            onPressed: () async => await globalAudioPlayerVM
                                .changeAudioPlayPosition(
                              positiveOrNegativeDuration:
                                  const Duration(minutes: 1),
                            ),
                            icon: const Icon(Icons.fast_forward),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              globalAudioPlayerVM.changeAudioPlayPosition(
                            positiveOrNegativeDuration:
                                const Duration(minutes: -1),
                          ),
                          child: const Text(
                            '1 m',
                            textAlign: TextAlign.center,
                            style: kPositionButtonTextStyle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              globalAudioPlayerVM.changeAudioPlayPosition(
                            positiveOrNegativeDuration:
                                const Duration(seconds: -10),
                          ),
                          child: const Text(
                            '10 s',
                            textAlign: TextAlign.center,
                            style: kPositionButtonTextStyle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              globalAudioPlayerVM.changeAudioPlayPosition(
                            positiveOrNegativeDuration:
                                const Duration(seconds: 10),
                          ),
                          child: const Text(
                            '10 s',
                            textAlign: TextAlign.center,
                            style: kPositionButtonTextStyle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              globalAudioPlayerVM.changeAudioPlayPosition(
                            positiveOrNegativeDuration:
                                const Duration(minutes: 1),
                          ),
                          child: const Text(
                            '1 m',
                            textAlign: TextAlign.center,
                            style: kPositionButtonTextStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildUndoRedoButtons(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUndoRedoButtons() {
    return Consumer<AudioPlayerVM>(
      builder: (context, globalAudioPlayerVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              key: const Key('audioPlayerViewUndoButton'),
              iconSize: _audioIconSizeSmall,
              onPressed: globalAudioPlayerVM.isUndoListEmpty()
                  ? null // Disable the button if the undo list is empty
                  : () {
                      globalAudioPlayerVM.undo();
                    },
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              key: const Key('audioPlayerViewRedoButton'),
              iconSize: _audioIconSizeSmall,
              onPressed: globalAudioPlayerVM.isRedoListEmpty()
                  ? null // Disable the button if the redo list is empty
                  : () {
                      globalAudioPlayerVM.redo();
                    },
              icon: const Icon(Icons.redo),
            ),
          ],
        );
      },
    );
  }

  void _displayOtherAudiosDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => const AudioPlayableListDialogWidget(),
    );
  }
}
