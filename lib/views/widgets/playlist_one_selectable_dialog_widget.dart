import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../viewmodels/warning_message_vm.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

enum PlaylistOneSelectableDialogUsedFor {
  downloadSingleVideoAudio,
  moveAudioToPlaylist,
  copyAudioToPlaylist,
}

/// This dialog is used to select a single playlist among the
/// displayed playlists.
class PlaylistOneSelectableDialogWidget extends StatefulWidget {
  final PlaylistOneSelectableDialogUsedFor usedFor;
  final Playlist? excludedPlaylist;

  // Displaying the audio only checkbox is useful when the dialog is
  // used in order to move an Audio file to a destination playlist.
  //
  // Setting the checkbox to true has the effect that the Audio entry in
  // the source playlist is not deleted, which has the advantage that it
  // is not necessary to remove the Audio video link from the Youtube
  // source playlist in order to avoid to redownload it the next time
  // download all is applyed to the source playlist.
  //
  // In any case, the moved Audio playlist entry is added to the
  // destination playlist.
  final bool isAudioOnlyCheckboxDisplayed;

  final WarningMessageVM warningMessageVM;

  const PlaylistOneSelectableDialogWidget({
    super.key,
    required this.usedFor,
    required this.warningMessageVM,
    this.excludedPlaylist,
    this.isAudioOnlyCheckboxDisplayed = false,
  });

  @override
  _PlaylistOneSelectableDialogWidgetState createState() =>
      _PlaylistOneSelectableDialogWidgetState();
}

class _PlaylistOneSelectableDialogWidgetState
    extends State<PlaylistOneSelectableDialogWidget> with ScreenMixin {
  Playlist? _selectedPlaylist;
  bool _keepAudioDataInSourcePlaylist = true;
  final FocusNode _focusNodeDialog = FocusNode();

  @override
  void dispose() {
    _focusNodeDialog.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProvider = Provider.of<ThemeProviderVM>(context);
    bool isDarkTheme = themeProvider.currentTheme == AppTheme.dark;
    PlaylistListVM expandablePlaylistVM = Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );
    List<Playlist> upToDateSelectablePlaylists;

    if (widget.excludedPlaylist == null) {
      upToDateSelectablePlaylists =
          expandablePlaylistVM.getUpToDateSelectablePlaylists();
    } else {
      upToDateSelectablePlaylists = expandablePlaylistVM
          .getUpToDateSelectablePlaylistsExceptExcludedPlaylist(
              excludedPlaylist: widget.excludedPlaylist!);
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
            // executing the same code as in the 'Confirm' ElevatedButton
            // onPressed callback
            _handleConfirmPressed(expandablePlaylistVM, context);
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('playlistOneSelectableDialogTitleKey'),
          AppLocalizations.of(context)!.playlistOneSelectedDialogTitle,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum space
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: upToDateSelectablePlaylists.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return RadioListTile<Playlist>(
                      title: Text(upToDateSelectablePlaylists[index].title),
                      value: upToDateSelectablePlaylists[index],
                      groupValue: _selectedPlaylist,
                      onChanged: (Playlist? value) {
                        setState(() {
                          _selectedPlaylist = value;
                        });
                      },
                    );
                  },
                ),
              ),
              (widget.usedFor ==
                          PlaylistOneSelectableDialogUsedFor
                              .moveAudioToPlaylist &&
                      widget.excludedPlaylist!.playlistType ==
                          PlaylistType.youtube) // when moving an audio
                  //                               from a playlist, the
                  //                               excluded playlist is
                  //                               the source playlist
                  ? _buildBottomTextAndCheckbox(
                      context,
                      isDarkTheme,
                    )
                  : Container(), // here, we are moving an audio from a
              //                    local playlist, or we are copying an
              //                    audio or downloading the audio of a
              //                    single video. In those situations,
              //                    displaying the keep audio entry in
              //                    source playlist checkbox is not
              //                    useful.
            ],
          ),
        ),
        actions: [
          // situation of downloading a single video
          // audio. This is tested by 'Bug fix
          // verification with partial download single
          // video audio' integration test
          TextButton(
            key: const Key('confirmButton'),
            onPressed: () {
              _handleConfirmPressed(expandablePlaylistVM, context);
            },
            child: Text(AppLocalizations.of(context)!.confirmButton,
                style: (themeProvider.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode),
          ),
          TextButton(
            key: const Key('cancelButton'),
            onPressed: () {
              // Fixes bug which happened when downloading a single
              // video audio and clicking on the cancel button of
              // the single selection playlist dialog. Without
              // this fix, the confirm dialog was displayed although
              // the user clicked on the cancel button.
              Navigator.of(context).pop("cancel");
            },
            child: Text(AppLocalizations.of(context)!.cancelButton,
                style: (themeProvider.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode),
          ),
        ],
      ),
    );
  }

  void _handleConfirmPressed(
      PlaylistListVM expandablePlaylistVM, BuildContext context) {
    switch (widget.usedFor) {
      case PlaylistOneSelectableDialogUsedFor.downloadSingleVideoAudio:
        if (_selectedPlaylist == null) {
          widget.warningMessageVM.isNoPlaylistSelectedForSingleVideoDownload =
              true;
          return;
        }
        break;
      case PlaylistOneSelectableDialogUsedFor.copyAudioToPlaylist:
        if (_selectedPlaylist == null) {
          widget.warningMessageVM.isNoPlaylistSelectedForAudioCopy = true;
          return;
        }
        break;
      case PlaylistOneSelectableDialogUsedFor.moveAudioToPlaylist:
        if (_selectedPlaylist == null) {
          widget.warningMessageVM.isNoPlaylistSelectedForAudioMove = true;
          return;
        }
        break;
      default:
        break;
    }

    Map<String, dynamic> resultMap = {
      'selectedPlaylist': _selectedPlaylist,
      'keepAudioDataInSourcePlaylist': _keepAudioDataInSourcePlaylist,
    };

    Navigator.of(context).pop(resultMap);
    return;
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
              child: Tooltip(
                message: AppLocalizations.of(context)!
                    .keepAudioEntryInSourcePlaylistTooltip,
                child: Text(
                  AppLocalizations.of(context)!.keepAudioEntryInSourcePlaylist,
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
              height: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
              child: Checkbox(
                key: const Key('keepAudioDataInSourcePlaylistCheckboxKey'),
                value: _keepAudioDataInSourcePlaylist,
                onChanged: (bool? newValue) {
                  setState(() {
                    _keepAudioDataInSourcePlaylist = newValue!;
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
}
