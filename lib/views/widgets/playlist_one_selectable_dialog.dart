import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../viewmodels/warning_message_vm.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

enum PlaylistOneSelectableDialogUsedFor {
  downloadSingleVideoAudio,
  moveSingleAudioToPlaylist,
  moveMultipleAudioToPlaylist,
  copySingleAudioToPlaylist,
  copyMultipleAudioToPlaylist,
  fromCommentsExtractedMp3AddedToPlaylist,
}

/// This dialog is used to select a single playlist among the
/// displayed playlists.
class PlaylistOneSelectableDialog extends StatefulWidget {
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

  const PlaylistOneSelectableDialog({
    super.key,
    required this.usedFor,
    required this.warningMessageVM,
    this.excludedPlaylist,
    this.isAudioOnlyCheckboxDisplayed = false,
  });

  @override
  _PlaylistOneSelectableDialogState createState() =>
      _PlaylistOneSelectableDialogState();
}

class _PlaylistOneSelectableDialogState
    extends State<PlaylistOneSelectableDialog> with ScreenMixin {
  Playlist? _selectedPlaylist;
  bool _keepAudioDataInSourcePlaylist = true;
  bool _downloadSingleVideoAudioAtMusicQuality = false;
  final FocusNode _focusNodeDialog = FocusNode();

  @override
  void dispose() {
    _focusNodeDialog.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProvider =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true
    bool isDarkTheme = themeProvider.currentTheme == AppTheme.dark;
    final PlaylistListVM playlistVMlistenFalse = Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );
    List<Playlist> upToDateSelectablePlaylists;

    if (widget.excludedPlaylist == null) {
      upToDateSelectablePlaylists =
          playlistVMlistenFalse.getUpToDateSelectablePlaylists(
        ignoreSearchSentence: true,
      );
    } else {
      upToDateSelectablePlaylists = playlistVMlistenFalse
          .getUpToDateSelectablePlaylistsExceptExcludedPlaylist(
              excludedPlaylist: widget.excludedPlaylist!,
              ignoreSearchSentence: true);
    }

    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      _focusNodeDialog,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Confirm' ElevatedButton
            // onPressed callback
            _handleConfirmButtonPressed(
              playlistVMlistnedFalse: playlistVMlistenFalse,
            );
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('playlistOneSelectableDialogTitleKey'),
          AppLocalizations.of(context)!.playlistOneSelectedDialogTitle,
          textAlign: TextAlign.center, // Centered multi lines text
          maxLines: 2,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SizedBox(
          // Container can not be suppressed
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum space
            children: [
              Flexible(
                child: RadioGroup<Playlist>(
                  groupValue: _selectedPlaylist,
                  onChanged: (Playlist? value) {
                    setState(() {
                      _selectedPlaylist = value;
                      _downloadSingleVideoAudioAtMusicQuality =
                          (_selectedPlaylist!.playlistQuality ==
                              PlaylistQuality.music);
                    });
                  },
                  child: ListView.builder(
                    key: const Key('selectable_playlist_list'),
                    itemCount: upToDateSelectablePlaylists.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(upToDateSelectablePlaylists[index].title),
                        leading: Radio<Playlist>(
                          value: upToDateSelectablePlaylists[index],
                          // Remove groupValue and onChanged - they're now handled by RadioGroup
                        ),
                        onTap: () {
                          setState(() {
                            _selectedPlaylist =
                                upToDateSelectablePlaylists[index];
                            _downloadSingleVideoAudioAtMusicQuality =
                                (_selectedPlaylist!.playlistQuality ==
                                    PlaylistQuality.music);
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
              (widget.usedFor ==
                          PlaylistOneSelectableDialogUsedFor
                              .moveSingleAudioToPlaylist &&
                      widget.excludedPlaylist!.playlistType ==
                          PlaylistType.youtube)
                  ? _buildBottomTextAndCheckboxForMoveAudioToPlaylist(
                      isDarkTheme: isDarkTheme,
                    )
                  : (widget.usedFor ==
                          PlaylistOneSelectableDialogUsedFor
                              .downloadSingleVideoAudio)
                      ? _buildBottomTextAndCheckboxForDownloadSingleVideoAudio(
                          isDarkTheme: isDarkTheme,
                        )
                      : Container(), // here, we are moving an audio from a
              // local playlist or we are copying an audio. In those situations,
              // displaying the keep audio entry in source playlist or at music
              // quality is inadequate.
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                key: const Key('confirmButton'),
                onPressed: () {
                  _handleConfirmButtonPressed(
                    playlistVMlistnedFalse: playlistVMlistenFalse,
                  );
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
        ],
      ),
    );
  }

  void _handleConfirmButtonPressed({
    required PlaylistListVM playlistVMlistnedFalse,
  }) {
    switch (widget.usedFor) {
      case PlaylistOneSelectableDialogUsedFor.downloadSingleVideoAudio:
        if (_selectedPlaylist == null) {
          widget.warningMessageVM.isNoPlaylistSelectedForSingleVideoDownload();
          return;
        }
        break;
      case PlaylistOneSelectableDialogUsedFor.copySingleAudioToPlaylist:
        if (_selectedPlaylist == null) {
          widget.warningMessageVM.isNoPlaylistSelectedForAudioCopy();
          return;
        }
        break;
      case PlaylistOneSelectableDialogUsedFor.moveSingleAudioToPlaylist:
        if (_selectedPlaylist == null) {
          widget.warningMessageVM.isNoPlaylistSelectedForAudioMove();
          return;
        }
        break;
      case PlaylistOneSelectableDialogUsedFor
            .fromCommentsExtractedMp3AddedToPlaylist:
        if (_selectedPlaylist == null) {
          widget.warningMessageVM.isNoPlaylistSelectedForExtractedMp3Location();
          return;
        }
        break;
      default:
        break;
    }

    Map<String, dynamic> resultMap = {
      'selectedPlaylist': _selectedPlaylist,
      'keepAudioDataInSourcePlaylist': _keepAudioDataInSourcePlaylist,
      'downloadSingleVideoAudioAtMusicQuality':
          _downloadSingleVideoAudioAtMusicQuality,
    };

    Navigator.of(context).pop(resultMap);
    return;
  }

  Widget _buildBottomTextAndCheckboxForMoveAudioToPlaylist({
    required bool isDarkTheme,
  }) {
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
                    fontSize: kListDialogBottomTextFontSize,
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

  Widget _buildBottomTextAndCheckboxForDownloadSingleVideoAudio({
    required bool isDarkTheme,
  }) {
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
                  AppLocalizations.of(context)!
                      .downloadSingleVideoAudioAtMusicQuality,
                  style: TextStyle(
                    fontSize: kListDialogBottomTextFontSize,
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
              height: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
              child: Checkbox(
                key: const Key(
                    'downloadSingleVideoAudioAtMusicQualityCheckboxKey'),
                value: _downloadSingleVideoAudioAtMusicQuality,
                onChanged: (bool? newValue) {
                  setState(() {
                    _downloadSingleVideoAudioAtMusicQuality = newValue!;
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
