import 'package:audiolearn/views/widgets/comment_list_add_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../services/sort_filter_parameters.dart';
import '../services/settings_data_service.dart';
import '../utils/duration_expansion.dart';
import '../viewmodels/audio_player_vm.dart';
import '../viewmodels/comment_vm.dart';
import '../viewmodels/playlist_list_vm.dart';
import '../viewmodels/warning_message_vm.dart';
import '../viewmodels/theme_provider_vm.dart';
import 'screen_mixin.dart';
import 'widgets/confirm_action_dialog_widget.dart';
import 'widgets/audios_playable_list_dialog_widget.dart';
import 'widgets/playlist_list_item_widget.dart';
import 'widgets/playlist_sort_filter_options_save_to_dialog_widget.dart';
import 'widgets/audio_set_speed_dialog_widget.dart';
import 'widgets/audio_sort_filter_dialog_widget.dart';

/// Screen enabling the user to play an audio, change the playing
/// position or go to a previous, next or selected audio.
class AudioPlayerView extends StatefulWidget {
  final SettingsDataService settingsDataService;

  const AudioPlayerView({
    super.key,
    required this.settingsDataService,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AudioPlayerViewState createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView>
    with WidgetsBindingObserver, ScreenMixin {
  final double _audioIconSizeSmall = 35;
  final double _audioIconSizeMedium = 40;
  final double _audioIconSizeLarge = 80;
  late double _audioPlaySpeed;

  // final bool _wasSortFilterAudioSettingsApplied = false;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PlaylistListVM playlistListVM = Provider.of<PlaylistListVM>(
        context,
        listen: false,
      );

      // When the audio player view is displayed, playlist list is
      // collapsed
      playlistListVM.isListExpanded = false;
    });

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
  ///
  /// ChatGPT info: when to Save State ?
  ///
  /// inactive: This state occurs when the app is transitioning, such as
  /// when the user receives a call or an alert dialog is shown. It is
  /// typically brief and not an ideal place for saving persistent state
  /// as the app might return to the resumed state quickly.
  ///
  /// paused: This state is more stable than inactive for saving state
  /// because it indicates the app is no longer in the foreground but
  /// still running. It is a suitable place to save the current state as
  /// the app might stay in this state for an extended period.
  ///
  /// detached: This state indicates the app is being removed from memory,
  /// making it an appropriate place to save the state before termination.
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
        // The app is not visible to the user but still running in the
        // background. This is the state when the audio is playing and
        // the screen is turned off.

        // Good for regular state-saving when the app goes to the
        // background.
        Provider.of<AudioPlayerVM>(
          context,
          listen: false,
        ).updateAndSaveCurrentAudio();
      case AppLifecycleState.inactive:
        // writeToLogFile(
        //     message:
        //         'WidgetsBinding didChangeAppLifecycleState(): app inactive, paused or closed');
        break;
      case AppLifecycleState.detached:
        // This state usually occurs just before the app is terminated.

        // Ensures the state is saved before the app is completely
        // terminated.
        Provider.of<AudioPlayerVM>(
          context,
          listen: false,
        ).updateAndSaveCurrentAudio();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    PlaylistListVM playlistListVMlistenFalse = Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );
    PlaylistListVM playlistListVMlistenTrue = Provider.of<PlaylistListVM>(
      context,
      listen: true,
    );
    AudioPlayerVM audioPlayerVMlistenTrue = Provider.of<AudioPlayerVM>(
      context,
      listen: true,
    );

    final ThemeProviderVM themeProviderVMlistenFalse =
        Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );

    bool areAudioButtonsEnabled = true;

    if (audioPlayerVMlistenTrue.currentAudio == null) {
      _audioPlaySpeed = 1.0;
      areAudioButtonsEnabled = false;
    } else {
      _audioPlaySpeed = audioPlayerVMlistenTrue.currentAudio!.audioPlaySpeed;
    }

    Widget viewContent = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildWarningMessageVMConsumer(
          context: context,
        ),
        _buildFirstLine(
          playlistListVMlistenTrue: playlistListVMlistenTrue,
        ),
        _buildSecondLine(
          context: context,
          themeProviderVM: themeProviderVMlistenFalse,
          playlistListVM: playlistListVMlistenFalse,
          audioPlayerVM: audioPlayerVMlistenTrue,
          areAudioButtonsEnabled: areAudioButtonsEnabled,
        ),
        _buildExpandedPlaylistList(
          playlistListVMListenTrue: playlistListVMlistenTrue,
        ),
        _buildPlayButton(),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildStartEndButtonsWithTitle(
              context: context,
              audioPlayerVMlistenTrue: audioPlayerVMlistenTrue,
            ),
            _buildAudioSliderWithPositionTexts(),
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

  /// Builds the second line of the audio player view. This line contains
  /// the playlist toggle button, the audio volume buttons, the audio
  /// speed button, the comments button and the audio popup menu button.
  Row _buildSecondLine({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
    required PlaylistListVM playlistListVM,
    required AudioPlayerVM audioPlayerVM,
    required bool areAudioButtonsEnabled,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              // sets the rounded TextButton size improving the distance
              // between the button text and its boarder
              width: kGreaterButtonWidth,
              height: kNormalButtonHeight,
              child: Tooltip(
                message:
                    AppLocalizations.of(context)!.playlistToggleButtonTooltip,
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
                    overlayColor:
                        textButtonTapModification, // Tap feedback color
                  ),
                  onPressed: () {
                    playlistListVM.toggleList();
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
          ],
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
            _buildCommentsInkWellButton(
              context: context,
              audioPlayerVMlistenTrue: audioPlayerVM,
              areAudioButtonsEnabled: areAudioButtonsEnabled,
            ),
            _buildAudioPopupMenuButton(
              context: context,
              playlistListVMlistenFalse: playlistListVM,
              warningMessageVMlistenFalse: Provider.of<WarningMessageVM>(
                context,
                listen: false,
              ),
              isAudioPopumMenuEnabled: areAudioButtonsEnabled,
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the first line of the audio player view. This line contains
  /// only the selected playlist title
  ///
  /// {playlistListVMlistenTrue} is the PlaylistListVM with listen set to
  /// true. This is necessary to update the selected playlist title when
  /// the user selects another playlist.
  Widget _buildFirstLine({
    required PlaylistListVM playlistListVMlistenTrue,
  }) {
    return Row(
      children: [
        Text(
          key: const Key('selectedPlaylistTitleText'),
          playlistListVMlistenTrue.uniqueSelectedPlaylist?.title ?? '',
          style: const TextStyle(
            fontSize: 12,
          ),
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildSetAudioVolumeIconButton({
    required BuildContext context,
    required bool areAudioButtonsEnabled,
  }) {
    return Consumer2<ThemeProviderVM, AudioPlayerVM>(
      builder: (context, themeProviderVM, audioPlayerVM, child) {
        _audioPlaySpeed =
            audioPlayerVM.currentAudio?.audioPlaySpeed ?? _audioPlaySpeed;

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
                  key: const Key('decreaseAudioVolumeIconButton'),
                  style: ButtonStyle(
                    // Highlight button when pressed
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding, vertical: 0),
                    ),
                    overlayColor:
                        iconButtonTapModification, // Tap feedback color
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: kUpDownButtonSize,
                  onPressed: (!areAudioButtonsEnabled ||
                          audioPlayerVM.isCurrentAudioVolumeMin())
                      ? null // Disable the button if no audio selected or
                      //        if the volume is min
                      : () async {
                          await audioPlayerVM.changeAudioVolume(
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
                    key: const Key('increaseAudioVolumeIconButton'),
                    style: ButtonStyle(
                      // Highlight button when pressed
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: kSmallButtonInsidePadding, vertical: 0),
                      ),
                      overlayColor:
                          iconButtonTapModification, // Tap feedback color
                    ),
                    icon: const Icon(Icons.arrow_drop_up),
                    iconSize: kUpDownButtonSize,
                    onPressed: (!areAudioButtonsEnabled ||
                            audioPlayerVM.isCurrentAudioVolumeMax())
                        ? null // Disable the button if no audio selected or
                        //        if the volume is max
                        : () async {
                            await audioPlayerVM.changeAudioVolume(
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
      builder: (context, themeProviderVM, audioPlayerVM, child) {
        _audioPlaySpeed =
            audioPlayerVM.currentAudio?.audioPlaySpeed ?? _audioPlaySpeed;

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
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
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
          ],
        );
      },
    );
  }

  /// Using InkWell instead of IconButton enables to use CircleAvatar
  /// as a button. IconButton doesn't allow to use CircleAvatar as a
  /// button. CircleAvatar is used to display the bookmark icon which
  /// can be highlighted or not and disabled or not and be enclosed in
  /// a colored circle.
  Widget _buildCommentsInkWellButton({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVMlistenTrue,
    required bool areAudioButtonsEnabled,
  }) {
    CircleAvatar circleAvatar;

    CommentVM commentVM = Provider.of<CommentVM>(
      context,
      listen: true,
    );

    Audio? currentAudio;

    if (areAudioButtonsEnabled) {
      currentAudio = audioPlayerVMlistenTrue.currentAudio;
    }

    if (currentAudio != null) {
      if (commentVM
          .loadAudioComments(audio: audioPlayerVMlistenTrue.currentAudio!)
          .isEmpty) {
        circleAvatar = formatIconBackAndForGroundColor(
          context: context,
          iconToFormat: const Icon(Icons.bookmark_outline_outlined),
          isIconHighlighted: false, // since no comments are defined
          //                           for the current audio the icon
          //                           isn,t highlighted
          isIconColorStronger: false, // sets the icon color to normal
        );
      } else {
        circleAvatar = formatIconBackAndForGroundColor(
            context: context,
            iconToFormat: const Icon(Icons.bookmark_outline_outlined),
            isIconHighlighted: true, // since comments are defined for
            //                          the current audio the icon is
            //                          highlighted
            iconSize: 21.0,
            radius: 13.0);
      }
    } else {
      circleAvatar = formatIconBackAndForGroundColor(
        context: context,
        iconToFormat: const Icon(Icons.bookmark_outline_outlined),
        isIconHighlighted: false,
        isIconDisabled: true, // since no audio is selected the icon
        //                       is disabled
      );
    }

    return Tooltip(
      message: AppLocalizations.of(context)!.commentsIconButtonTooltip,
      child: SizedBox(
        width: kSmallButtonWidth,
        child: InkWell(
          key: const Key('commentsInkWellButton'),
          onTap: (!areAudioButtonsEnabled)
              ? null // Disable the button if no audio selected
              : () {
                  showDialog<void>(
                    barrierDismissible:
                        false, // This line prevents the dialog from closing when
                    //            tapping outside the dialog
                    context: context,
                    // passing the current audio to the dialog instead
                    // of initializing a private _currentAudio variable
                    // in the dialog avoid integr test problems
                    builder: (context) => CommentListAddDialogWidget(
                      currentAudio: currentAudio!,
                    ),
                  );
                },
          child: circleAvatar,
        ),
      ),
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
                  return ConfirmActionDialogWidget(
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
    return Consumer2<AudioPlayerVM, PlaylistListVM>(
      builder: (context, audioPlayerVM, playlistListVM, child) {
        if (!playlistListVM.isListExpanded) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(90.0),
                child: IconButton(
                  iconSize: _audioIconSizeLarge,
                  onPressed: (() async {
                    audioPlayerVM.isPlaying
                        ? await audioPlayerVM.pause()
                        : await audioPlayerVM.playCurrentAudio();
                  }),
                  style: ButtonStyle(
                    // Highlight button when pressed
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding, vertical: 0),
                    ),
                    overlayColor:
                        iconButtonTapModification, // Tap feedback color
                  ),
                  icon: Icon(audioPlayerVM.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildStartEndButtonsWithTitle({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVMlistenTrue,
  }) {
    return Consumer<AudioPlayerVM>(
      // The reason why this widget is consumer of the AudioPlayerVM
      // that by clicking on the current audio title, the user can
      // select another audio to play. This action will require to
      // update the current audio title displayed in the audio player.
      builder: (context, audioPlayerVM, child) {
        String? currentAudioTitleWithDuration =
            audioPlayerVMlistenTrue.getCurrentAudioTitleWithDuration();

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
              onPressed: () async =>
                  await audioPlayerVMlistenTrue.skipToStart(),
              style: ButtonStyle(
                // Highlight button when pressed
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(
                      horizontal: kSmallButtonInsidePadding, vertical: 0),
                ),
                overlayColor: iconButtonTapModification, // Tap feedback color
              ),
              icon: const Icon(Icons.skip_previous),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (audioPlayerVMlistenTrue
                      .getPlayableAudiosApplyingSortFilterParameters(
                        AudioLearnAppViewType.audioPlayerView,
                      )
                      .isEmpty) {
                    // there is no audio to play, so tapping on the
                    // current audio title does not perform anything
                    return;
                  }

                  _displayOtherAudiosDialog();
                },
                child: Consumer<ThemeProviderVM>(
                  builder: (context, themeProviderVM, child) {
                    return Text(
                      currentAudioTitleWithDuration ?? '',
                      style: TextStyle(
                        fontSize: kAudioTitleFontSize,
                        color: (themeProviderVM.currentTheme == AppTheme.dark)
                            ? Colors.white
                            : Colors.black,
                      ),
                      maxLines: 5,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
            GestureDetector(
              onLongPress: () {
                if (audioPlayerVMlistenTrue
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
                    await audioPlayerVMlistenTrue.skipToEndAndPlay(),
                style: ButtonStyle(
                  // Highlight button when pressed
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                        horizontal: kSmallButtonInsidePadding, vertical: 0),
                  ),
                  overlayColor: iconButtonTapModification, // Tap feedback color
                ),
                icon: const Icon(Icons.skip_next),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudioSliderWithPositionTexts() {
    return Consumer<AudioPlayerVM>(
      builder: (context, audioPlayerVM, child) {
        // Obtaining the slider values here (when audioPlayerVM
        // call notifyListeners()) avoids that the slider generate
        // a 'Value xxx.x is not between minimum 0.0 and maximum 0.0'
        // error
        double sliderValue =
            audioPlayerVM.currentAudioPosition.inSeconds.toDouble();
        double maxDuration =
            audioPlayerVM.currentAudioTotalDuration.inSeconds.toDouble();

        // Ensure the slider value is within the range
        sliderValue = sliderValue.clamp(0.0, maxDuration);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                key: const Key('audioPlayerViewAudioPosition'),
                audioPlayerVM.currentAudioPosition.HHmmssZeroHH(),
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
                    key: const Key('audioPlayerViewAudioSlider'),
                    min: 0.0,
                    max: maxDuration,
                    value: sliderValue,
                    onChanged: (double value) async {
                      await audioPlayerVM.slideToAudioPlayPosition(
                        durationPosition: Duration(seconds: value.toInt()),
                      );
                    },
                  ),
                ),
              ),
              Text(
                key: const Key('audioPlayerViewAudioRemainingDuration'),
                audioPlayerVM.currentAudioRemainingDuration
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
      builder: (context, audioPlayerVM, child) {
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
                            onPressed: () async => await audioPlayerVM
                                .changeAudioPlayPosition(
                              posNegPositionDurationChange:
                                  const Duration(minutes: -1),
                            ),
                            style: ButtonStyle(
                              // Highlight button when pressed
                              padding:
                                  WidgetStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.symmetric(
                                    horizontal: kSmallButtonInsidePadding,
                                    vertical: 0),
                              ),
                              overlayColor:
                                  iconButtonTapModification, // Tap feedback color
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            key: const Key('audioPlayerViewRewind10sButton'),
                            iconSize: _audioIconSizeMedium,
                            onPressed: () async => await audioPlayerVM
                                .changeAudioPlayPosition(
                              posNegPositionDurationChange:
                                  const Duration(seconds: -10),
                            ),
                            style: ButtonStyle(
                              // Highlight button when pressed
                              padding:
                                  WidgetStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.symmetric(
                                    horizontal: kSmallButtonInsidePadding,
                                    vertical: 0),
                              ),
                              overlayColor:
                                  iconButtonTapModification, // Tap feedback color
                            ),
                            icon: const Icon(Icons.fast_rewind),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            key: const Key('audioPlayerViewForward10sButton'),
                            iconSize: _audioIconSizeMedium,
                            onPressed: () async => await audioPlayerVM
                                .changeAudioPlayPosition(
                              posNegPositionDurationChange:
                                  const Duration(seconds: 10),
                            ),
                            style: ButtonStyle(
                              // Highlight button when pressed
                              padding:
                                  WidgetStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.symmetric(
                                    horizontal: kSmallButtonInsidePadding,
                                    vertical: 0),
                              ),
                              overlayColor:
                                  iconButtonTapModification, // Tap feedback color
                            ),
                            icon: const Icon(Icons.fast_forward),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            key: const Key('audioPlayerViewForward1mButton'),
                            iconSize: _audioIconSizeMedium,
                            onPressed: () async => await audioPlayerVM
                                .changeAudioPlayPosition(
                              posNegPositionDurationChange:
                                  const Duration(minutes: 1),
                            ),
                            style: ButtonStyle(
                              // Highlight button when pressed
                              padding:
                                  WidgetStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.symmetric(
                                    horizontal: kSmallButtonInsidePadding,
                                    vertical: 0),
                              ),
                              overlayColor:
                                  iconButtonTapModification, // Tap feedback color
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
                          onTap: () async =>
                              await audioPlayerVM.changeAudioPlayPosition(
                            posNegPositionDurationChange:
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
                          onTap: () async =>
                              await audioPlayerVM.changeAudioPlayPosition(
                            posNegPositionDurationChange:
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
                          onTap: () async =>
                              await audioPlayerVM.changeAudioPlayPosition(
                            posNegPositionDurationChange:
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
                          onTap: () async =>
                              await audioPlayerVM.changeAudioPlayPosition(
                            posNegPositionDurationChange:
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

  Widget _buildExpandedPlaylistList({
    required PlaylistListVM playlistListVMListenTrue,
  }) {
    if (playlistListVMListenTrue.isListExpanded) {
      List<Playlist> upToDateSelectablePlaylists =
          playlistListVMListenTrue.getUpToDateSelectablePlaylists();
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
                  toggleListIfSelected: true,
                );
              },
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildUndoRedoButtons() {
    return Consumer<AudioPlayerVM>(
      builder: (context, audioPlayerVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              key: const Key('audioPlayerViewUndoButton'),
              iconSize: _audioIconSizeSmall,
              onPressed: audioPlayerVM.isUndoListEmpty()
                  ? null // Disable the button if the undo list is empty
                  : () {
                      audioPlayerVM.undo();
                    },
              style: ButtonStyle(
                // Highlight button when pressed
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(
                      horizontal: kSmallButtonInsidePadding, vertical: 0),
                ),
                overlayColor: iconButtonTapModification, // Tap feedback color
              ),
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              key: const Key('audioPlayerViewRedoButton'),
              iconSize: _audioIconSizeSmall,
              onPressed: audioPlayerVM.isRedoListEmpty()
                  ? null // Disable the button if the redo list is empty
                  : () {
                      audioPlayerVM.redo();
                    },
              style: ButtonStyle(
                // Highlight button when pressed
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(
                      horizontal: kSmallButtonInsidePadding, vertical: 0),
                ),
                overlayColor: iconButtonTapModification, // Tap feedback color
              ),
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
