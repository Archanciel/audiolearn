import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/sort_filter_parameters.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../models/audio.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

/// This dialog is used in the AudioPlayerView to display the list
/// of playable audios of the selected playlist and to enable the
/// user to select another audio to listen.
///
/// The listed audios are displayed with different colors according
/// to their status (not yet listened, currently listened, fully or partially
/// listened).
class AudioPlayableListDialogWidget extends StatefulWidget {
  const AudioPlayableListDialogWidget({
    super.key,
  });

  @override
  _AudioPlayableListDialogWidgetState createState() =>
      _AudioPlayableListDialogWidgetState();
}

class _AudioPlayableListDialogWidgetState
    extends State<AudioPlayableListDialogWidget> with ScreenMixin {
  // Using FocusNode to enable clicking on Enter to close
  // the dialog
  final FocusNode _focusNodeDialog = FocusNode();

  bool _excludeFullyPlayedAudios = false;

  final ScrollController _scrollController = ScrollController();

  late int _currentAudioIndex;

  final double _itemHeight = 70.0;

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
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);
    bool isDarkTheme = themeProviderVM.currentTheme == AppTheme.dark;
    AudioPlayerVM audioGlobalPlayerVM =
        Provider.of<AudioPlayerVM>(context, listen: false);
    Audio? currentAudio = audioGlobalPlayerVM.currentAudio;

    List<Audio> playableAudioLst;

    if (_excludeFullyPlayedAudios) {
      playableAudioLst = audioGlobalPlayerVM
          .getNotFullyPlayedAudiosApplyingSortFilterParameters(
        AudioLearnAppViewType.audioPlayerView,
      );
    } else {
      playableAudioLst =
          audioGlobalPlayerVM.getPlayableAudiosApplyingSortFilterParameters(
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
            // executing the same code as in the 'Cancel' TextButton
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            Tooltip(
                message: _determineDialogTitleAudioSortTooltip(
                  context: context,
                  audioPlayerVM: audioGlobalPlayerVM,
                ),
                child: Text(
                    AppLocalizations.of(context)!.audioOneSelectedDialogTitle)),
            Tooltip(
              message:
                  AppLocalizations.of(context)!.audioPlayedInThisOrderTooltip,
              child: IconTheme(
                data: (themeProviderVM.currentTheme == AppTheme.dark
                        ? ScreenMixin.themeDataDark
                        : ScreenMixin.themeDataLight)
                    .iconTheme,
                child: const Icon(
                  Icons.arrow_drop_up,
                  size: 80.0,
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
              Expanded(
                child: ListView.builder(
                  key: const Key('audioPlayableListKey'),
                  controller: _scrollController,
                  itemCount: playableAudioLst.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    Audio audio = playableAudioLst[index];
                    return ListTile(
                      title: GestureDetector(
                        onTap: () async {
                          await audioGlobalPlayerVM.setCurrentAudio(audio);
                          Navigator.of(context).pop();
                        },
                        child: _buildAudioTitleTextWidget(
                          audio,
                          index,
                          isDarkTheme,
                        ),
                      ),
                    );
                  },
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
            key: const Key('cancelButton'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.cancelButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
        ],
      ),
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
                    TextSpan(text: AppLocalizations.of(context)!.audios),
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
  Widget _buildAudioTitleTextWidget(
    Audio audio,
    int index,
    bool isDarkTheme,
  ) {
    Color? audioTitleTextColor;
    Color? audioTitleBackgroundColor;

    if (index == _currentAudioIndex) {
      audioTitleTextColor = Colors.white;
      audioTitleBackgroundColor = Colors.blue;
    } else if (audio.wasFullyListened()) {
      audioTitleTextColor = (isDarkTheme)
          ? kSliderThumbColorInDarkMode
          : kSliderThumbColorInLightMode;
      audioTitleBackgroundColor = null;
    } else if (audio.isPartiallyListened()) {
      audioTitleTextColor = Colors.blue;
      audioTitleBackgroundColor = null;
    } else {
      audioTitleTextColor = null;
      audioTitleBackgroundColor = null;
    }

    return SizedBox(
      height: _itemHeight,
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
    double multiplier = _currentAudioIndex.toDouble();

    if (_currentAudioIndex > 300) {
      multiplier *= 1.23;
    } else if (_currentAudioIndex > 200) {
      multiplier *= 1.21;
    } else if (_currentAudioIndex > 120) {
      multiplier *= 1.2;
    }

    double offset = multiplier * _itemHeight;

    if (_backToAllAudios) {
      // improves the scrolling when the user goes back to
      // the list of all audios
      offset *= 1.4;
      _backToAllAudios = false;
    }

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
      _scrollController.animateTo(
        offset,
        duration: const Duration(seconds: 1),
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
