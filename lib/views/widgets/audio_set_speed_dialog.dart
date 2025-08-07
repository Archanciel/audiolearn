import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../models/help_item.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../views/screen_mixin.dart';
import 'help_dialog.dart';

/// This widget displays a dialog to set the audio play speed. The dialog
/// is used in the application settings view, in the audio player view
/// and in the playlist set speed item menu.
///
/// The dialog can display a help icon button if it was called from the
/// application settings view or from the playlist set speed item menu.
/// If called from the audio player view, the help icon button is not
/// displayed.
class AudioSetSpeedDialog extends StatefulWidget {
  final double audioPlaySpeed;

  final bool displayApplyToExistingPlaylistCheckbox;
  final bool displayApplyToAudioAlreadyDownloadedCheckbox;
  final bool updateCurrentPlayAudioSpeed;
  final List<HelpItem> helpItemsLst;

  /// The non required parameters are so since the dialog can be used
  /// in different contexts. When the dialog is used in the audio player,
  /// the 3 non required parameters are not used.
  ///
  /// When the dialog is used in the application settings view, the
  /// 3 non required parameters are not set by the caller.
  ///
  /// When the dialog is used in the playlist set speed item menu, the
  /// only {displayApplyToExistingPlaylistCheckbox} and {helpItemsLst}
  /// parameters are set by the caller.
  const AudioSetSpeedDialog({
    super.key,
    required this.audioPlaySpeed,
    required this.updateCurrentPlayAudioSpeed,
    this.displayApplyToExistingPlaylistCheckbox = false,
    this.displayApplyToAudioAlreadyDownloadedCheckbox = false,
    this.helpItemsLst = const [],
  });

  @override
  _AudioSetSpeedDialogState createState() => _AudioSetSpeedDialogState();
}

class _AudioSetSpeedDialogState extends State<AudioSetSpeedDialog>
    with ScreenMixin {
  double _audioPlaySpeed = 1.0;
  bool _applyToAudioAlreadyDownloaded = false;
  bool _applyToExistingPlaylist = false;
  final FocusNode _focusNodeDialog = FocusNode();

  @override
  void initState() {
    super.initState();

    _audioPlaySpeed = widget.audioPlaySpeed;
  }

  @override
  void dispose() {
    _focusNodeDialog.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );
    final ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );

    if (widget.updateCurrentPlayAudioSpeed) {
      // Here, using the set audio speed dialog in the audio player
      // view
      Audio? currentAudio = audioPlayerVMlistenFalse.currentAudio;

      if (currentAudio != null) {
        _audioPlaySpeed = currentAudio.audioPlaySpeed;
      }
    }

    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      _focusNodeDialog,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // onPressed callback
            Navigator.of(context).pop([
              _audioPlaySpeed,
              _applyToExistingPlaylist,
              _applyToAudioAlreadyDownloaded,
            ]);
          }
        }
      },
      child: AlertDialog(
        // executing the same code as in the 'Ok' TextButton
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.setAudioPlaySpeedDialogTitle,
              ),
            ),
            (!widget.updateCurrentPlayAudioSpeed)
                // Help icon button is displayed only when the dialog is
                // used to set the audio play speed in the application
                // settings view or launched from the playlist set audio
                // play speed item menu. In the audio player view, the help
                // icon button is not displayed.
                ? IconButton(
                    icon: IconTheme(
                      data: (themeProviderVM.currentTheme == AppTheme.dark
                              ? ScreenMixin.themeDataDark
                              : ScreenMixin.themeDataLight)
                          .iconTheme,
                      child: const Icon(
                        Icons.help_outline,
                        size: 40.0,
                      ),
                    ),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => HelpDialog(
                          helpItemsLst: widget.helpItemsLst,
                        ),
                      );
                    },
                  )
                : Container(),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('${_audioPlaySpeed.toStringAsFixed(2)}x',
                  key: const Key('audioPlaySpeedTextKey'),
                  style: (themeProviderVM.currentTheme == AppTheme.dark)
                      ? kTextButtonStyleDarkMode
                      : kTextButtonStyleLightMode),
              _buildSliderAndPlusMinusButtons(
                audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
              ),
              _buildSpeedButtons(
                themeProviderVM: themeProviderVM,
                audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
              ),
              (widget.displayApplyToExistingPlaylistCheckbox)
                  ? _buildApplyToExistingPlaylistRow(context)
                  : Container(),
              (widget.displayApplyToAudioAlreadyDownloadedCheckbox)
                  ? _buildApplyToAudioAlreadyDownloadedRow(context)
                  : Container(),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('okButtonKey'),
            child: Text(
              'Ok',
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
            onPressed: () {
              // Updates the audio play speed value in the audio speed
              // text button displayed in the audio player view
              audioPlayerVMlistenFalse.currentAudioPlaySpeedNotifier.value =
                  _audioPlaySpeed;
              audioPlayerVMlistenFalse.wasPlaySpeedNotifierChanged = true;

              Navigator.of(context).pop([
                _audioPlaySpeed,
                _applyToExistingPlaylist,
                _applyToAudioAlreadyDownloaded,
              ]);
            },
          ),
          TextButton(
            key: const Key('cancelButtonKey'),
            child: Text(
              AppLocalizations.of(context)!.cancelButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
            onPressed: () async {
              // restoring the previous audio play speed when
              // cancel button is pressed. Otherwise, the audio
              // play speed is changed even if the user presses
              // the cancel button.
              await _setPlaybackSpeed(
                audioPlayerVMlistenedFalse: audioPlayerVMlistenFalse,
                newValue: widget.audioPlaySpeed,
              );

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApplyToExistingPlaylistRow(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        createCheckboxRowFunction(
          checkBoxWidgetKey: const Key('applyToExistingPlaylistsKey'),
          context: context,
          label: AppLocalizations.of(context)!.applyToExistingPlaylist,
          labelTooltip:
              AppLocalizations.of(context)!.applyToExistingPlaylistTooltip,
          value: _applyToExistingPlaylist,
          onChangedFunction: (bool? value) {
            setState(() {
              _applyToExistingPlaylist = value ?? false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildApplyToAudioAlreadyDownloadedRow(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        createCheckboxRowFunction(
          checkBoxWidgetKey: const Key('applyToAlreadyDownloadedAudioKey'),
          context: context,
          label: AppLocalizations.of(context)!.applyToAlreadyDownloadedAudio,
          labelTooltip: (widget.displayApplyToExistingPlaylistCheckbox)
              ? AppLocalizations.of(context)!
                  .applyToAlreadyDownloadedAudioTooltip
              : AppLocalizations.of(context)!
                  .applyToAlreadyDownloadedAudioOfCurrentPlaylistTooltip,
          value: _applyToAudioAlreadyDownloaded,
          onChangedFunction: (bool? value) {
            setState(() {
              _applyToAudioAlreadyDownloaded = value ?? false;

              if (widget.displayApplyToExistingPlaylistCheckbox) {
                if (_applyToAudioAlreadyDownloaded) {
                  // If this dialog was opened due to updating application
                  // settings, in this case the two checkbox are displayed.
                  //
                  // In this situation, if the user chooses to apply the
                  // modified audio play speed to the already dowmnloaded
                  // audio, then it makes sence that the apply to existing
                  // checkbox is set to true. The user can uncheck the apply
                  // to existing checkbox without the fact that the apply
                  // to already downloaded audio check box is implied.
                  setState(() {
                    _applyToExistingPlaylist = true;
                  });
                }
              }
            });
          },
        ),
      ],
    );
  }

  Row _buildSliderAndPlusMinusButtons({
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('minusButtonKey'),
          icon: const Icon(Icons.remove),
          onPressed: () async {
            double newSpeed = (_audioPlaySpeed == 1.25) ? 1.2 : _audioPlaySpeed - 0.1;
            if (newSpeed >= 0.5) {
              await _setPlaybackSpeed(
                audioPlayerVMlistenedFalse: audioPlayerVMlistenFalse,
                newValue: newSpeed,
              );
            } else {
              if (newSpeed >= 0.499) {
                // required since _audioPlaySpeed can be
                // 0.6. 0.6 is displayed and clicking on
                // '-' button could not change the speed
                // to 0.5, the bottom limit !
                //
                // Without this test, the app crashes when
                // clicking on '-' button when the speed
                // is 0.6.
                newSpeed = 0.5;
                await _setPlaybackSpeed(
                  audioPlayerVMlistenedFalse: audioPlayerVMlistenFalse,
                  newValue: newSpeed,
                );
              }
            }
          },
        ),
        Expanded(
          child: Slider(
            min: 0.5,
            max: 2.0,
            label: "${_audioPlaySpeed.toStringAsFixed(1)}x",
            value: _audioPlaySpeed,
            onChanged: (value) async {
              await _setPlaybackSpeed(
                audioPlayerVMlistenedFalse: audioPlayerVMlistenFalse,
                newValue: value,
              );
            },
          ),
        ),
        IconButton(
          key: const Key('plusButtonKey'),
          icon: const Icon(Icons.add),
          onPressed: () async {
            double newSpeed = (_audioPlaySpeed == 1.25) ? 1.3 : _audioPlaySpeed + 0.1;
            if (newSpeed <= 2.0) {
              await _setPlaybackSpeed(
                audioPlayerVMlistenedFalse: audioPlayerVMlistenFalse,
                newValue: newSpeed,
              );
            } else {
              if (newSpeed <= 2.001) {
                // required since _audioPlaySpeed can be
                // 1.9000000000000008. 1.9 is displayed
                // and clicking on '+' button could not
                // change the speed to 2.0, the top limit !
                newSpeed = 2.0;
                await _setPlaybackSpeed(
                  audioPlayerVMlistenedFalse: audioPlayerVMlistenFalse,
                  newValue: newSpeed,
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildSpeedButtons({
    required ThemeProviderVM themeProviderVM,
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) {
    final speeds = [0.7, 1.0, 1.25, 1.5]; // [0.7, 1.0, 1.25, 1.5, 2.0] is too
    //                                       large for the screen on S20
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: speeds.map((speed) {
        return TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(18, 18), // Set a minimum touch target size
            padding: const EdgeInsets.symmetric(horizontal: 0),
          ),
          child: Text(
            '${speed}x',
            style: (themeProviderVM.currentTheme == AppTheme.dark)
                ? kTextButtonSmallStyleDarkMode
                : kTextButtonSmallStyleLightMode,
          ),
          onPressed: () async {
            await _setPlaybackSpeed(
              audioPlayerVMlistenedFalse: audioPlayerVMlistenFalse,
              newValue: speed,
            );
          },
        );
      }).toList(),
    );
  }

  Future<void> _setPlaybackSpeed({
    required AudioPlayerVM audioPlayerVMlistenedFalse,
    required double newValue,
  }) async {
    setState(() {
      _audioPlaySpeed = newValue;
    });

    if (widget.updateCurrentPlayAudioSpeed) {
      // Here, using the set audio speed dialog in the audio player
      // view. In this case, each time the audio play speed is
      // changed in the dialog, the audio play speed value
      // of the audio play speed button at top of the audio
      // player view is also updated.
      await audioPlayerVMlistenedFalse.changeAudioPlaySpeed(_audioPlaySpeed);
    }
  }
}
