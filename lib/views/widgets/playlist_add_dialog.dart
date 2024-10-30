import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';
import '../../models/audio.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

class PlaylistAddDialog extends StatefulWidget {
  final String playlistUrl;

  const PlaylistAddDialog({
    required this.playlistUrl,
    super.key,
  });

  @override
  State<PlaylistAddDialog> createState() => _PlaylistAddDialogState();
}

class _PlaylistAddDialogState extends State<PlaylistAddDialog>
    with ScreenMixin {
  final TextEditingController _localPlaylistTitleTextEditingController =
      TextEditingController();
  final FocusNode _focusNodeDialog = FocusNode();
  final FocusNode _focusNodeLocalPlaylistTitle = FocusNode();

  bool _isChecked = false;

  @override
  void dispose() {
    _focusNodeDialog.dispose();
    _localPlaylistTitleTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true

    if (widget.playlistUrl.isEmpty) {
      // If the playlist URL is empty, a local playlist is
      // created. Then, focus on the local playlist TextField.
      // If this test does not exist, then when creating a
      // Youtube playlist, clicking on Enter does not close
      // the dialog.
      FocusScope.of(context).requestFocus(
        _focusNodeLocalPlaylistTitle,
      );
    } else {
      // If the playlist URL is not empty, focus on the
      // _focusNodeDialog to enable clicking on Enter to
      // close the dialog.
      FocusScope.of(context).requestFocus(
        _focusNodeDialog,
      );
    }

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) async {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Add'
            // TextButton onPressed callback
            dynamic isYoutubePlaylistAdded = await _addPlaylist(
              context: context,
            );

            if (isYoutubePlaylistAdded == null) {
              return;
            }

            Navigator.of(context).pop(isYoutubePlaylistAdded);
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('playlistConfirmDialogTitleKey'),
          (widget.playlistUrl.isNotEmpty)
              ? AppLocalizations.of(context)!.addYoutubePlaylistDialogTitle
              : AppLocalizations.of(context)!.addLocalPlaylistDialogTitle,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              (widget.playlistUrl.isNotEmpty)
                  ? createInfoRowFunction(
                      // displaying the playlist URL
                      valueTextWidgetKey:
                          const Key('playlistUrlConfirmDialogText'),
                      context: context,
                      label:
                          AppLocalizations.of(context)!.youtubePlaylistUrlLabel,
                      value: widget.playlistUrl)
                  : createFlexibleEditableRowFunction(
                      // displaying the local playlist title TextField
                      valueTextFieldWidgetKey:
                          const Key('playlistLocalTitleConfirmDialogTextField'),
                      context: context,
                      label:
                          AppLocalizations.of(context)!.localPlaylistTitleLabel,
                      controller: _localPlaylistTitleTextEditingController,
                      textFieldFocusNode: _focusNodeLocalPlaylistTitle,
                      flexValue: 3,
                    ),
              createCheckboxRowFunction(
                // displaying music quality checkbox
                checkBoxWidgetKey:
                    const Key('playlistQualityConfirmDialogCheckBox'),
                context: context,
                label: AppLocalizations.of(context)!.isMusicQualityLabel,
                value: _isChecked,
                onChangedFunction: (bool? value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('addPlaylistConfirmDialogAddButton'),
            onPressed: () async {
              dynamic isYoutubePlaylistAdded = await _addPlaylist(
                context: context,
              );

              if (isYoutubePlaylistAdded == null) {
                return;
              }

              Navigator.of(context).pop(isYoutubePlaylistAdded);
            },
            child: Text(
              AppLocalizations.of(context)!.add,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            key: const Key('addPlaylistConfirmDialogCancelButton'),
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
  }

  /// Calls the [PlaylistListVM.addPlaylist] method to add the
  /// Youtube or local playlist.
  ///
  /// Returns true if the Youtube playlist was added, false
  /// otherwise. This will be used to empty the playlist URL
  /// TextField if a Youtube playlist was added.
  Future<dynamic> _addPlaylist({
    required BuildContext context,
  }) async {
    String localPlaylistTitle = _localPlaylistTitleTextEditingController.text;
    PlaylistListVM playlistListVM =
        Provider.of<PlaylistListVM>(context, listen: false);

    if (localPlaylistTitle.isNotEmpty) {
      // if the local playlist title is not empty, then add the local
      // playlist
      if (await playlistListVM.addPlaylist(
            localPlaylistTitle: localPlaylistTitle,
            playlistQuality:
                _isChecked ? PlaylistQuality.music : PlaylistQuality.voice,
          ) ==
          null) {
        return null;
      }

      return false; // the playlist URL TextField will not be cleared
    } else {
      // if the local playlist title is empty, then add the Youtube
      // playlist if the Youtube playlist URL is not empty
      if (widget.playlistUrl.isNotEmpty) {
        dynamic isYoutubePlaylistAdded = await playlistListVM.addPlaylist(
          playlistUrl: widget.playlistUrl,
          playlistQuality:
              _isChecked ? PlaylistQuality.music : PlaylistQuality.voice,
        );

        return isYoutubePlaylistAdded; // if true, this will clear the playlist
        //                                URL TextField. If null or false. the
        //                                playlist URL TextField will not be
        //                                cleared
      }
    }

    return false; // the playlist URL TextField will not be cleared
  }

  String formatDownloadSpeed({
    required BuildContext context,
    required Audio audio,
  }) {
    int audioDownloadSpeed = audio.audioDownloadSpeed;
    String audioDownloadSpeedStr;

    if (audioDownloadSpeed.isInfinite) {
      audioDownloadSpeedStr =
          AppLocalizations.of(context)!.infiniteBytesPerSecond;
    } else {
      audioDownloadSpeedStr =
          '${UiUtil.formatLargeIntValue(context: context, value: audioDownloadSpeed)}/sec';
    }

    return audioDownloadSpeedStr;
  }
}
