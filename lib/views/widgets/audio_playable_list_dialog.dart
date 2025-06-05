import 'package:audiolearn/utils/ui_util.dart';
import 'package:audiolearn/viewmodels/playlist_list_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/playlist.dart';
import '../../services/sort_filter_parameters.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../models/audio.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

/// This dialog is used in the AudioPlayerView to display the list
/// of playable audio of the selected playlist and to enable the
/// user to select another audio to listen.
///
/// The listed audio are displayed with different colors according
/// to their status (not yet listened, currently listened, fully or partially
/// listened).
class AudioPlayableListDialog extends StatefulWidget {
  const AudioPlayableListDialog({
    super.key,
  });

  @override
  _AudioPlayableListDialogState createState() =>
      _AudioPlayableListDialogState();
}

class _AudioPlayableListDialogState extends State<AudioPlayableListDialog>
    with ScreenMixin {
  // Using FocusNode to enable clicking on Enter to close
  // the dialog
  final FocusNode _focusNodeDialog = FocusNode();

  bool _excludeFullyPlayedAudios = false;
  final ScrollController _scrollController = ScrollController();
  late int _currentAudioIndex;
  final double _audioItemHeight = 70.0;
  bool _backToAllAudios = false;

  @override
  void dispose() {
    // Dispose the focus node when the widget is disposed
    _focusNodeDialog.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true
    bool isDarkTheme = themeProviderVM.currentTheme == AppTheme.dark;
    final AudioPlayerVM audioPlayerVMlistenFalse =
        Provider.of<AudioPlayerVM>(context, listen: false);
    Audio? currentAudio = audioPlayerVMlistenFalse.currentAudio;

    List<Audio> playableAudioLst;

    if (_excludeFullyPlayedAudios) {
      playableAudioLst = audioPlayerVMlistenFalse
          .getNotFullyPlayedAudiosApplyingSortFilterParameters(
        audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      );
    } else {
      playableAudioLst = audioPlayerVMlistenFalse
          .getPlayableAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.audioPlayerView,
      );
    }

    // avoid error when the dialog is opened and the current
    // audio is not yet set
    if (currentAudio == null) {
      _currentAudioIndex = -1;
    } else {
      _currentAudioIndex = playableAudioLst.indexOf(currentAudio);
    }

    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      _focusNodeDialog,
    );

    KeyboardListener keyboardListener = KeyboardListener(
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) async {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // Checking if you can pop first. Avoid rare pop() error.
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Consumer<PlaylistListVM>(
          builder: (context, playlistListVMlistenTrue, child) {
        return AlertDialog(
          title: Row(
            children: [
              Tooltip(
                message: _determineDialogTitleAudioSortTooltip(
                  context: context,
                  audioPlayerVM: audioPlayerVMlistenFalse,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth:
                        180, // Set the maximum width for the RichText here
                  ),
                  child: RichText(
                    key: const Key('audioPlayableListDialogTitle'),
                    text: TextSpan(
                      text: AppLocalizations.of(context)!
                          .audioOneSelectedDialogTitle,
                      style: const TextStyle(
                        fontSize: 24,
                      ),
                      children: [
                        const WidgetSpan(
                          child: SizedBox(width: 8),
                        ),
                        TextSpan(
                          text:
                              "(${playlistListVMlistenTrue.getAudioPlayerViewSortFilterName(
                            translatedDefaultSFparmsName:
                                AppLocalizations.of(context)!
                                    .sortFilterParametersDefaultName,
                          )})",
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Tooltip(
                message: AppLocalizations.of(context)!
                    .clickToSetAscendingOrDescendingPlayingOrderTooltip,
                child: IconButton(
                  key: const Key('play_order_ascending_or_descending_button'),
                  onPressed: () {
                    setState(() {
                      playlistListVMlistenTrue
                          .invertSelectedPlaylistAudioPlayingOrder();
                    });
                  },
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
                    (playlistListVMlistenTrue
                                .getSelectedPlaylists()[0]
                                .audioPlayingOrder ==
                            AudioPlayingOrder.ascending)
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down, // Conditional icon
                    size: 80,
                    color: kDarkAndLightEnabledIconColor,
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: kDialogActionsPadding,
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Use minimum space
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    key: const Key('audioPlayableListKey'),
                    controller: _scrollController,
                    child: ListBody(
                      children: playableAudioLst.map((audio) {
                        int index = playableAudioLst.indexOf(audio);
                        return GestureDetector(
                          onTap: () async {
                            await audioPlayerVMlistenFalse.setCurrentAudio(
                              audio: audio,
                            );
                            // Checking if you can pop first. Avoid rare pop() error.
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: _buildAudioTitleTextWidget(
                            audio: audio,
                            audioIndex: index,
                            isDarkTheme: isDarkTheme,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                _buildBottomTextAndCheckbox(
                  context,
                  isDarkTheme,
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              key: const Key('closeTextButton'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.closeTextButton,
                style: (themeProviderVM.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode,
              ),
            ),
          ],
        );
      }),
    );

    _scrollToCurrentAudioItem();

    return keyboardListener;
  }

  /// Determines the dialog title tooltip according to the sorting option
  String _determineDialogTitleAudioSortTooltip({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVM,
  }) {
    SortingItem sortingItem = audioPlayerVM
        .getSortingItemLstForViewType(AudioLearnAppViewType.audioPlayerView)
        .first;

    switch (sortingItem.sortingOption) {
      case SortingOption.audioDownloadDate:
        if (sortingItem.isAscending) {
          return AppLocalizations.of(context)!
              .playableAudioDialogSortDescriptionTooltipBottomDownloadAfter;
        } else {
          return AppLocalizations.of(context)!
              .playableAudioDialogSortDescriptionTooltipBottomDownloadBefore;
        }
      case SortingOption.videoUploadDate:
        if (sortingItem.isAscending) {
          return AppLocalizations.of(context)!
              .playableAudioDialogSortDescriptionTooltipBottomUploadAfter;
        } else {
          return AppLocalizations.of(context)!
              .playableAudioDialogSortDescriptionTooltipBottomUploadBefore;
        }
      case SortingOption.audioDuration:
        if (sortingItem.isAscending) {
          return AppLocalizations.of(context)!
              .playableAudioDialogSortDescriptionTooltipTopDurationSmaller;
        } else {
          return AppLocalizations.of(context)!
              .playableAudioDialogSortDescriptionTooltipTopDurationBigger;
        }
      case SortingOption.audioRemainingDuration:
        if (sortingItem.isAscending) {
          return AppLocalizations.of(context)!
              .playableAudioDialogSortDescriptionTooltipTopRemainingDurationSmaller;
        } else {
          return AppLocalizations.of(context)!
              .playableAudioDialogSortDescriptionTooltipTopRemainingDurationBigger;
        }
      case SortingOption.lastListenedDateTime:
        if (sortingItem.isAscending) {
          return AppLocalizations.of(context)!
              .playableAudioDialogSortDescriptionTooltipTopLastListenedDatrTimeSmaller;
        } else {
          return AppLocalizations.of(context)!
              .playableAudioDialogSortDescriptionTooltipTopLastListenedDatrTimeBigger;
        }
      default:
        break;
    }

    return '';
  }

  Widget _buildBottomTextAndCheckbox(
    BuildContext context,
    bool isDarkTheme,
  ) {
    return Column(
      children: [
        const SizedBox(
          height: ScreenMixin.dialogCheckboxSizeBoxHeight,
        ),
        Row(
          // in this case, the audio is moved from a Youtube
          // playlist and so the keep audio entry in source
          // playlist checkbox is displayed
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  // Default text style for the entire block
                  style: TextStyle(
                    fontSize: kListDialogBottomTextFontSize,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: AppLocalizations.of(context)!.exclude),
                    // TextSpan for the first word with a different color.
                    // Useful for the user to understand color meaning
                    TextSpan(
                      text: AppLocalizations.of(context)!.fullyPlayed,
                      style: TextStyle(
                        color: (isDarkTheme)
                            ? kSliderThumbColorInDarkMode
                            : kSliderThumbColorInLightMode,
                      ),
                    ),
                    TextSpan(text: AppLocalizations.of(context)!.audio),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
              height: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
              child: Checkbox(
                key: const Key('excludeFullyPlayedAudiosCheckbox'),
                value: _excludeFullyPlayedAudios,
                onChanged: (bool? newValue) {
                  setState(() {
                    if (newValue != null) {
                      if (newValue) {
                        _backToAllAudios = false;
                      } else {
                        _backToAllAudios = true;
                      }
                      _excludeFullyPlayedAudios = newValue;
                      _scrollToCurrentAudioItem();
                    }
                  });
                  // now clicking on Enter works since the
                  // Checkbox is not focused anymore
                  // _audioTitleSubStringFocusNode.requestFocus();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the text widget for the audio title. The text color
  /// is different according to the audio status (not yet listened,
  /// currently listening, fully or partially listened).
  Widget _buildAudioTitleTextWidget({
    required Audio audio,
    required int audioIndex,
    required bool isDarkTheme,
  }) {
    List<Color?> audioTitleForeAndBackgroundColors =
        UiUtil.generateAudioStateColors(
      audio: audio,
      audioIndex: audioIndex,
      currentAudioIndex: _currentAudioIndex,
      isDarkTheme: isDarkTheme,
    );

    Color? audioTitleTextColor = audioTitleForeAndBackgroundColors[0];
    Color? audioTitleBackgroundColor = audioTitleForeAndBackgroundColors[1];

    return SizedBox(
      height: _audioItemHeight,
      child: Text(
        audio.validVideoTitle,
        maxLines: 3,
        style: TextStyle(
          color: audioTitleTextColor,
          backgroundColor: audioTitleBackgroundColor,
          fontSize: kAudioTitleFontSize,
        ),
      ),
    );
  }

  void _scrollToCurrentAudioItem() {
    if (_currentAudioIndex <= 4) {
      // this avoids scrolling down when the current audio is
      // in the top part of the audio list. Without that, the
      // list is unusefully scrolled down and the user has to scroll
      // up to see top audio
      return;
    }

    double multiplier = _currentAudioIndex.toDouble();

    if (_currentAudioIndex > 300) {
      multiplier *= 1.23;
    } else if (_currentAudioIndex > 200) {
      multiplier *= 1.21;
    } else if (_currentAudioIndex > 120) {
      multiplier *= 1.2;
    }

    double offset = multiplier * _audioItemHeight;

    if (_backToAllAudios) {
      // improves the scrolling when the user goes back to
      // the list of all audio
      offset *= 1.4;
      _backToAllAudios = false;
    }

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
      _scrollController.animateTo(
        offset,
        duration: kScrollDuration,
        curve: Curves.easeInOut,
      );
    } else {
      // The scroll controller isn't attached to any scroll views.
      // Schedule a callback to try again after the next frame.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToCurrentAudioItem());
    }
  }
}
