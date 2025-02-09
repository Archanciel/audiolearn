import 'dart:io';

import 'package:audiolearn/views/widgets/comment_list_add_dialog.dart';
import 'package:flutter/foundation.dart';
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
import 'widgets/confirm_action_dialog.dart';
import 'widgets/audio_playable_list_dialog.dart';
import 'widgets/playlist_list_item.dart';
import 'widgets/audio_set_speed_dialog.dart';
import 'widgets/audio_sort_filter_dialog.dart';

/// Screen enabling the user to play an audio, change the playing
/// position or go to a previous, next or selected audio.
class AudioPlayerView extends StatefulWidget {
  final SettingsDataService settingsDataService;
  final double playlistItemHeight = (ScreenMixin.isHardwarePc() ? 45 : 85);

  AudioPlayerView({
    super.key,
    required this.settingsDataService,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AudioPlayerViewState createState() => _AudioPlayerViewState();
}

/// Adding WidgetsBindingObserver enables to listen to the app's
/// lifecycle state changes. This is necessary to save the current
/// audio when the app is paused (smartphone screen turns off or
/// the user switches to another app) or detached (AudioPLearn app
/// is closed). Currently, this only works for Android and iOS, not
/// on Windows.
class _AudioPlayerViewState extends State<AudioPlayerView>
    with WidgetsBindingObserver, ScreenMixin {
  final double _audioIconSizeSmall = 35;
  final double _audioIconSizeMedium = 40;
  final double _audioIconSizeLarge = 80;
  late double _audioPlaySpeed;

  final ScrollController _playlistScrollController = ScrollController();

  // final bool _wasSortFilterAudioSettingsApplied = false;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // This if test is necessary to avoid the following integration
        // test error:
        //
        // "The following assertion was thrown during a scheduler callback:
        // This widget has been unmounted, so the State no longer has a
        // context (and should be considered defunct)."
        PlaylistListVM playlistListVM = Provider.of<PlaylistListVM>(
          context,
          listen: false,
        );

        // When the audio player view is displayed, playlist list is
        // collapsed
        playlistListVM.isPlaylistListExpanded = false;
      }
    });

    // Used in relation of audioplayers
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playlistScrollController.dispose();

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
  /// This state is reached when the smartphone screen turns off or when
  /// the user switches to another app.
  ///
  /// detached: This state indicates the app is being removed from memory,
  /// making it an appropriate place to save the state before termination.
  ///
  /// This state is reached when the app is closed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // writeToLogFile(
        //     message:
        //         'WidgetsBinding didChangeAppLifecycleState(): app resumed');
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
    AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    final ThemeProviderVM themeProviderVMlistenFalse =
        Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );

    if (audioPlayerVMlistenFalse.currentAudio == null) {
      _audioPlaySpeed = 1.0;
    } else {
      _audioPlaySpeed = audioPlayerVMlistenFalse.currentAudio!.audioPlaySpeed;
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
          playlistListVMlistenFalse: playlistListVMlistenFalse,
          audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
        ),
        (playlistListVMlistenFalse.isPlaylistListExpanded)
            ? _buildExpandedPlaylistList(
                playlistListVMlistenFalse: playlistListVMlistenFalse)
            : const SizedBox.shrink(),
        _buildPlayButtonOrAudioPicture(
            playlistListVMlistenTrue: playlistListVMlistenTrue,
            audioPlayerVMlistenFalse: audioPlayerVMlistenFalse),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildStartEndButtonsWithTitle(
              context: context,
              audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
            ),
            _buildAudioSliderWithPositionTexts(
              audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
            ),
            _buildPositionAndUndoRedoButtons(
              audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
            ),
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

  Widget _buildPlayButtonOrAudioPicture({
    required PlaylistListVM playlistListVMlistenTrue,
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) {
    return ValueListenableBuilder<String?>(
      valueListenable: audioPlayerVMlistenFalse.currentAudioTitleNotifier,
      builder: (context, currentAudioTitle, child) {
        File? audioPictureFile;

        if (audioPlayerVMlistenFalse.currentAudio != null) {
          audioPictureFile = playlistListVMlistenTrue.getAudioPictureFile(
              audio: audioPlayerVMlistenFalse.currentAudio!);
        }

        return (audioPictureFile != null)
            ? _buildAudioPictureOnScreenCenter(
                audioPictureFile: audioPictureFile,
              )
            : _buildPlayOrPauseButtonOnScreenCenter(
                playlistListVMlistenTrue: playlistListVMlistenTrue,
                audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
              );
      },
    );
  }

  /// Builds the second line of the audio player view. This line contains
  /// the playlist toggle button, the audio volume buttons, the audio
  /// speed button, the comments button and the audio popup menu button.
  ///
  /// If a picture is displayed instead of the play button, then a play
  /// or pause button is included in the second line.
  Widget _buildSecondLine({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
    required PlaylistListVM playlistListVMlistenFalse,
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) {
    return ValueListenableBuilder<String?>(
      valueListenable: audioPlayerVMlistenFalse.currentAudioTitleNotifier,
      builder: (context, currentAudioTitle, child) {
        // Even though currentAudioTitle is not directly used,
        // this ensures that the second line part containing or
        // not a play//pause button as well as the audio speed
        // text button ate rebuilt whenever the audio title changes,
        // which is the case when a new audio is selected in the
        // audio playable list dialog.

        Audio? currentAudio = audioPlayerVMlistenFalse.currentAudio;
        File? audioPictureFile;
        bool areAudioButtonsEnabled;

        if (currentAudio != null) {
          audioPictureFile = playlistListVMlistenFalse.getAudioPictureFile(
              audio: currentAudio);
          areAudioButtonsEnabled = currentAudioTitle != null;
        } else {
          areAudioButtonsEnabled = false;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  // sets the rounded TextButton size improving the distance
                  // between the button text and its border
                  width: kGreaterButtonWidth,
                  height: kNormalButtonHeight,
                  child: Tooltip(
                    message: AppLocalizations.of(context)!
                        .playlistToggleButtonInAudioPlayerViewTooltip,
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
                        playlistListVMlistenFalse.togglePlaylistsList();
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
                if (audioPictureFile != null)
                  // if a picture is displayed instead of the play button,
                  // then a play or pause button is included in the second
                  // line
                  ValueListenableBuilder<bool>(
                    valueListenable:
                        audioPlayerVMlistenFalse.currentAudioPlayPauseNotifier,
                    builder: (context, isPaused, child) {
                      return IconButton(
                        key: const Key(
                            'picture_displayed_play_pause_button_key'),
                        iconSize: _audioIconSizeMedium,
                        onPressed: () async {
                          audioPlayerVMlistenFalse.isPlaying
                              ? await audioPlayerVMlistenFalse.pause()
                              : await audioPlayerVMlistenFalse.playCurrentAudio(
                                  isFromAudioPlayerView: true,
                                );
                        },
                        style: ButtonStyle(
                          // Highlight button when pressed
                          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: kSmallButtonInsidePadding,
                                vertical: 0),
                          ),
                          overlayColor:
                              iconButtonTapModification, // Tap feedback color
                        ),
                        // Display the play or pause button depending on the
                        // isPaused value which is updated by the audio player
                        // currentAudioPlayPauseNotifier
                        icon: Icon(isPaused ? Icons.pause : Icons.play_arrow),
                      );
                    },
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
                  audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                  areAudioButtonsEnabled: areAudioButtonsEnabled,
                ),
                _buildCommentsInkWellButton(
                  context: context,
                  audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                  areAudioButtonsEnabled: areAudioButtonsEnabled,
                ),
                _buildAudioPopupMenuButton(
                  context: context,
                  playlistListVMlistenFalse: playlistListVMlistenFalse,
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
      },
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
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required bool areAudioButtonsEnabled,
  }) {
    return Consumer<ThemeProviderVM>(
      builder: (context, themeProviderVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              // sets the rounded TextButton size improving the distance
              // between the button text and its border
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
                              return AudioSetSpeedDialog(
                                audioPlaySpeed: audioPlayerVMlistenFalse
                                        .currentAudio?.audioPlaySpeed ??
                                    _audioPlaySpeed,
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
                  child: ValueListenableBuilder<double>(
                    valueListenable:
                        audioPlayerVMlistenFalse.currentAudioPlaySpeedNotifier,
                    builder: (context, currentSpeed, child) {
                      String currentSpeedStr;

                      if (audioPlayerVMlistenFalse
                          .wasPlaySpeedNotifierChanged) {
                        currentSpeedStr = '${currentSpeed.toStringAsFixed(2)}x';
                        audioPlayerVMlistenFalse.wasPlaySpeedNotifierChanged =
                            false;
                      } else {
                        currentSpeedStr =
                            '${_audioPlaySpeed.toStringAsFixed(2)}x';
                      }

                      return Text(
                        key: const Key('audioSpeedButtonText'),
                        currentSpeedStr,
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
                      );
                    },
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
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required bool areAudioButtonsEnabled,
  }) {
    CircleAvatar circleAvatar;

    CommentVM commentVM = Provider.of<CommentVM>(
      context,
      listen: true,
    );

    Audio? currentAudio;

    if (areAudioButtonsEnabled) {
      currentAudio = audioPlayerVMlistenFalse.currentAudio;
    }

    if (currentAudio != null) {
      if (commentVM
          .loadAudioComments(audio: audioPlayerVMlistenFalse.currentAudio!)
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
                    builder: (context) => CommentListAddDialog(
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
            // PopupMenuItem<PopupMenuButtonType>(
            //   key: const Key(
            //       'save_sort_and_filter_audio_parms_in_playlist_item'),
            //   value: PopupMenuButtonType.saveSortFilterAudioParmsToPlaylist,
            //   child: Text(AppLocalizations.of(context)!
            //       .saveSortFilterAudiosOptionsToPlaylistMenu),
            // ),
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
                  // List content:
                  //   [
                  //     sort and filter parameters name applied to the
                  //     playlist download view or to the audio player view,
                  //     sort and filter parameters applied to the playlist
                  //      download view or to the audio player view,
                  // ]
                  List<dynamic> selectedPlaylistAudioSortFilterParmsLstForView =
                      playlistListVMlistenFalse
                          .getSelectedPlaylistAudioSortFilterParmsForView(
                    AudioLearnAppViewType.audioPlayerView,
                  );
                  return AudioSortFilterDialog(
                    selectedPlaylistAudioLst: playlistListVMlistenFalse
                        .getSelectedPlaylistPlayableAudioApplyingSortFilterParameters(
                      audioLearnAppViewType:
                          AudioLearnAppViewType.audioPlayerView,
                    ),
                    audioSortFilterParametersName:
                        selectedPlaylistAudioSortFilterParmsLstForView[0],
                    audioSortFilterParameters: AudioSortFilterParameters
                        .createDefaultAudioSortFilterParameters(),
                    audioSortPlaylistFilterParameters:
                        selectedPlaylistAudioSortFilterParmsLstForView[1]
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
                  String audioSortFilterParametersName =
                      filterSortAudioAndParmLst[2];
                  playlistListVMlistenFalse
                      .setSortFilterForSelectedPlaylistPlayableAudiosAndParms(
                    audioLearnAppViewType:
                        AudioLearnAppViewType.audioPlayerView,
                    sortFilteredSelectedPlaylistPlayableAudio:
                        returnedAudioList,
                    audioSortFilterParms: audioSortFilterParameters,
                    audioSortFilterParmsName: audioSortFilterParametersName,
                  );
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
                    // Displaying a warning message after having cleared
                    // the sort and filter audio settings search history
                    // is not necessary
                    // warningFunction: warningMessageVMlistenFalse
                    //     .allHistoricalSortFilterParametersWereDeleted,
                  );
                },
              );
              break;
            default:
              break;
          }
        },
      ),
    );
  }

  Widget _buildPlayOrPauseButtonOnScreenCenter({
    required PlaylistListVM playlistListVMlistenTrue,
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) {
    if (!playlistListVMlistenTrue.isPlaylistListExpanded) {
      // the list of playlists is collapsed, so the play button is
      // displayed
      return ValueListenableBuilder<bool>(
        valueListenable: audioPlayerVMlistenFalse.currentAudioPlayPauseNotifier,
        builder: (context, mustPlayPauseButtonBeSetToPaused, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(90.0),
                child: IconButton(
                  key: const Key('middleScreenPlayPauseButton'),
                  iconSize: _audioIconSizeLarge,
                  onPressed: (() async {
                    audioPlayerVMlistenFalse.isPlaying
                        ? await audioPlayerVMlistenFalse.pause()
                        : await audioPlayerVMlistenFalse.playCurrentAudio(
                            isFromAudioPlayerView: true,
                          );
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
                  icon: Icon(
                    mustPlayPauseButtonBeSetToPaused
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildAudioPictureOnScreenCenter({
    required File? audioPictureFile,
  }) {
    // Check if the audio picture file exists and read its bytes
    Uint8List? imageBytes;

    if (audioPictureFile != null) {
      imageBytes = audioPictureFile.readAsBytesSync();
    }

    // Get screen size
    double screenWidth = MediaQuery.of(context).size.width;

    // Set sizes relative to the screen width
    double circleAvatarRadius = screenWidth * 0.34; // 40% of screen width
    double imageWidthHeight = circleAvatarRadius * 2;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultMargin,
        vertical: kDefaultMargin,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: circleAvatarRadius,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      fit: BoxFit.cover,
                      width: imageWidthHeight,
                      height: imageWidthHeight,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartEndButtonsWithTitle({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) {
    return ValueListenableBuilder<String?>(
      valueListenable: audioPlayerVMlistenFalse.currentAudioTitleNotifier,
      builder: (context, currentAudioTitle, child) {
        // If the current audio title is null, set it to the default value
        currentAudioTitle ??=
            AppLocalizations.of(context)!.audioPlayerViewNoCurrentAudio;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              key: const Key('audioPlayerViewSkipToStartButton'),
              iconSize: _audioIconSizeMedium,
              onPressed: () async => await audioPlayerVMlistenFalse.skipToStart(
                // Setting isFromAudioPlayerView to true enables to
                // set the audioplayers source to the current audio
                // file if the audioplayers was stopped. This avoids
                // that the position buttons don't work after the audio
                // player was stopped.
                isFromAudioPlayerView: true,
              ),
              style: ButtonStyle(
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
                  if (audioPlayerVMlistenFalse
                      .getPlayableAudiosApplyingSortFilterParameters(
                        AudioLearnAppViewType.audioPlayerView,
                      )
                      .isEmpty) {
                    return;
                  }

                  showDialog<void>(
                    context: context,
                    builder: (context) => const AudioPlayableListDialog(),
                  );
                },
                child: Consumer<ThemeProviderVM>(
                  builder: (context, themeProviderVM, child) {
                    return Text(
                      key: const Key('audioPlayerViewCurrentAudioTitle'),
                      (audioPlayerVMlistenFalse.currentAudio == null)
                          ? AppLocalizations.of(context)!
                              .audioPlayerViewNoCurrentAudio
                          : currentAudioTitle!, // Display the title from ValueNotifier
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
            IconButton(
              key: const Key('audioPlayerViewSkipToEndButton'),
              iconSize: _audioIconSizeMedium,
              onPressed: () async =>
                  await audioPlayerVMlistenFalse.skipToEndAndPlay(),
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(
                      horizontal: kSmallButtonInsidePadding, vertical: 0),
                ),
                overlayColor: iconButtonTapModification, // Tap feedback color
              ),
              icon: const Icon(Icons.skip_next),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudioSliderWithPositionTexts({
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) {
    return ValueListenableBuilder<String?>(
      // The current audio title is used to update the slider
      // and positions values when the audio title changes.
      // This is useful in the situation when selecting a playlist
      // which has several audio's, but none being current. When
      // the user tap on the audio player view icon, then click
      // on the 'No audio selected' title and then select an audio
      // whose position is at the beginning, the remaining duration
      // would not be updated if the currentAudioTitleNotifier was
      // not used.
      valueListenable: audioPlayerVMlistenFalse.currentAudioTitleNotifier,
      builder: (context, currentAudioTitle, child) {
        return ValueListenableBuilder<Duration>(
          valueListenable:
              audioPlayerVMlistenFalse.currentAudioPositionNotifier,
          builder: (context, currentPosition, child) {
            // Obtaining the slider values here (when audioPlayerVM
            // calls notifyListeners()) avoids the slider generating
            // a 'Value xxx.x is not between minimum 0.0 and maximum 0.0' error
            double sliderValue = 0.0;
            double maxDuration = 0.0;
            String currentAudioPositionStr = Duration.zero.HHmmssZeroHH();
            String remainingAudioDurationStr = currentAudioPositionStr; // 0.0

            if (currentAudioTitle != null) {
              sliderValue = audioPlayerVMlistenFalse
                  .currentAudioPosition.inSeconds
                  .toDouble();
              maxDuration = audioPlayerVMlistenFalse
                  .currentAudioTotalDuration.inSeconds
                  .toDouble();
              currentAudioPositionStr =
                  audioPlayerVMlistenFalse.currentAudioPosition.HHmmssZeroHH();
              remainingAudioDurationStr = audioPlayerVMlistenFalse
                  .currentAudioRemainingDuration
                  .HHmmssZeroHH();
            }

            // Ensure the slider value is within the range
            sliderValue = sliderValue.clamp(0.0, maxDuration);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultMargin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    key: const Key('audioPlayerViewAudioPosition'),
                    currentAudioPositionStr,
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
                          await audioPlayerVMlistenFalse
                              .slideToAudioPlayPosition(
                            durationPosition: Duration(seconds: value.toInt()),
                          );
                        },
                      ),
                    ),
                  ),
                  Text(
                    key: const Key('audioPlayerViewAudioRemainingDuration'),
                    remainingAudioDurationStr,
                    style: kSliderValueTextStyle,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPositionAndUndoRedoButtons({
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) {
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
                        onPressed: () async => await audioPlayerVMlistenFalse
                            .changeAudioPlayPosition(
                          posOrNegPositionDurationChange:
                              const Duration(minutes: -1),
                        ),
                        style: ButtonStyle(
                          // Highlight button when pressed
                          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
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
                        onPressed: () async => await audioPlayerVMlistenFalse
                            .changeAudioPlayPosition(
                          posOrNegPositionDurationChange:
                              const Duration(seconds: -10),
                        ),
                        style: ButtonStyle(
                          // Highlight button when pressed
                          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
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
                        onPressed: () async => await audioPlayerVMlistenFalse
                            .changeAudioPlayPosition(
                          posOrNegPositionDurationChange:
                              const Duration(seconds: 10),
                        ),
                        style: ButtonStyle(
                          // Highlight button when pressed
                          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
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
                        onPressed: () async => await audioPlayerVMlistenFalse
                            .changeAudioPlayPosition(
                          posOrNegPositionDurationChange:
                              const Duration(minutes: 1),
                        ),
                        style: ButtonStyle(
                          // Highlight button when pressed
                          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
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
                      key: const Key('audioPlayerViewBackward1mButton'),
                      onTap: () async => await audioPlayerVMlistenFalse
                          .changeAudioPlayPosition(
                        posOrNegPositionDurationChange:
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
                      onTap: () async => await audioPlayerVMlistenFalse
                          .changeAudioPlayPosition(
                        posOrNegPositionDurationChange:
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
                      onTap: () async => await audioPlayerVMlistenFalse
                          .changeAudioPlayPosition(
                        posOrNegPositionDurationChange:
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
                      onTap: () async => await audioPlayerVMlistenFalse
                          .changeAudioPlayPosition(
                        posOrNegPositionDurationChange:
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
              _buildUndoRedoButtons(
                audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedPlaylistList({
    required PlaylistListVM playlistListVMlistenFalse,
  }) {
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
                toggleListIfSelected: true,
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
  }

  void _scrollToSelectedPlaylist({
    required PlaylistListVM playlistListVMlistenFalse,
  }) {
    int playlistToScrollPosition =
        playlistListVMlistenFalse.determinePlaylistToScrollPosition();

    int noScrollLimit = 4;

    if (playlistToScrollPosition <= noScrollLimit) {
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
    } else if (playlistToScrollPosition > noScrollLimit) {
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

  Widget _buildUndoRedoButtons({
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) {
    return ValueListenableBuilder<Duration>(
      valueListenable: audioPlayerVMlistenFalse.currentAudioPositionNotifier,
      builder: (context, currentPosition, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              key: const Key('audioPlayerViewUndoButton'),
              iconSize: _audioIconSizeSmall,
              onPressed: audioPlayerVMlistenFalse.isUndoListEmpty()
                  ? null // Disable the button if the undo list is empty
                  : () {
                      audioPlayerVMlistenFalse.undo();
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
              onPressed: audioPlayerVMlistenFalse.isRedoListEmpty()
                  ? null // Disable the button if the redo list is empty
                  : () {
                      audioPlayerVMlistenFalse.redo();
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
}
