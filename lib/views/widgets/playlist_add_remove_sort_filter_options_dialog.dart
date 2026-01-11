import 'package:audiolearn/viewmodels/warning_message_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';

/// Dialog widget that allows the user to save the sort filter options to
/// a playlist so that they can be applied when the playlist is selected.
/// The application can be set to the playlist download view and/or the audio
/// player view.
///
/// The dialog also enables the user to remove the sort filter options from
/// the playlist download view and/or the audio player view.
class PlaylistAddRemoveSortFilterOptionsDialog extends StatefulWidget {
  final String playlistTitle;
  final String sortFilterParmsName;
  final bool isSaveApplied;
  final bool isSortFilterParmsNameAlreadyAppliedToPlaylistDownloadView;
  final bool isSortFilterParmsNameAlreadyAppliedToAudioPlayerView;

  const PlaylistAddRemoveSortFilterOptionsDialog({
    super.key,
    required this.playlistTitle,
    required this.sortFilterParmsName,
    this.isSaveApplied = true,
    this.isSortFilterParmsNameAlreadyAppliedToPlaylistDownloadView = false,
    this.isSortFilterParmsNameAlreadyAppliedToAudioPlayerView = false,
  });

  @override
  State<PlaylistAddRemoveSortFilterOptionsDialog> createState() =>
      _PlaylistAddRemoveSortFilterOptionsDialogState();
}

class _PlaylistAddRemoveSortFilterOptionsDialogState
    extends State<PlaylistAddRemoveSortFilterOptionsDialog> with ScreenMixin {
  final FocusNode _focusNodeDialog = FocusNode();

  bool _applySortFilterToPlaylistDownloadView = false;
  bool _applySortFilterToAudioPlayerView = false;

  @override
  Widget build(BuildContext context) {
    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      _focusNodeDialog,
    );

    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) async {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Save'
            // TextButton onPressed callback
            Navigator.of(context).pop(_displayConfirmAndCreateReturnedLst());
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('saveSortFilterOptionsToPlaylistDialogTitleKey'),
          (widget.isSaveApplied)
              ? AppLocalizations.of(context)!
                  .saveSortFilterOptionsToPlaylistDialogTitle(
                      widget.sortFilterParmsName)
              : AppLocalizations.of(context)!
                  .removeSortFilterOptionsFromPlaylistDialogTitle(
                      widget.sortFilterParmsName),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createLabelRowFunction(
                // displaying the playlist title in which to save the
                // sort and filter options
                valueTextWidgetKey:
                    const Key('saveSortFilterOptionsToPlaylistTitleKey'),
                context: context,
                label: (widget.isSaveApplied)
                    ? AppLocalizations.of(context)!
                        .saveSortFilterOptionsToPlaylist(widget.playlistTitle)
                    : AppLocalizations.of(context)!
                        .removeSortFilterOptionsFromPlaylist(
                            widget.playlistTitle),
              ),
              _buildPlaylistViewCheckboxColumn(),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                key: const Key('saveSortFilterOptionsToPlaylistSaveButton'),
                onPressed: () async {
                  Navigator.of(context)
                      .pop(_displayConfirmAndCreateReturnedLst());
                },
                child: Text(
                  (widget.isSaveApplied)
                      ? AppLocalizations.of(context)!.saveButton
                      : AppLocalizations.of(context)!.removeButton,
                  style: (themeProviderVM.currentTheme == AppTheme.dark)
                      ? kTextButtonStyleDarkMode
                      : kTextButtonStyleLightMode,
                ),
              ),
              TextButton(
                key: const Key('sortFilterOptionsToPlaylistCancelButton'),
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
        ],
      ),
    );
  }

  Column _buildPlaylistViewCheckboxColumn() {
    if (widget.isSaveApplied) {
      return Column(
        children: [
          (widget.isSortFilterParmsNameAlreadyAppliedToPlaylistDownloadView)
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (widget.isSaveApplied)
                          ? AppLocalizations.of(context)!.forScreen(
                              AppLocalizations.of(context)!
                                  .appBarTitleDownloadAudio)
                          : AppLocalizations.of(context)!.fromScreen(
                              AppLocalizations.of(context)!
                                  .appBarTitleDownloadAudio),
                    ),
                    Checkbox(
                      key: const Key('playlistDownloadViewCheckbox'),
                      fillColor: WidgetStateColor.resolveWith(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return kDarkAndLightDisabledIconColor;
                          }
                          return kDarkAndLightEnabledIconColor;
                        },
                      ),
                      value: _applySortFilterToPlaylistDownloadView,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _applySortFilterToPlaylistDownloadView = newValue!;
                        });
                      },
                    ),
                  ],
                ),
          (widget.isSortFilterParmsNameAlreadyAppliedToAudioPlayerView)
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      (widget.isSaveApplied)
                          ? AppLocalizations.of(context)!.forScreen(
                              AppLocalizations.of(context)!
                                  .appBarTitleAudioPlayer)
                          : AppLocalizations.of(context)!.fromScreen(
                              AppLocalizations.of(context)!
                                  .appBarTitleAudioPlayer),
                    ),
                    Checkbox(
                      key: const Key('audioPlayerViewCheckbox'),
                      fillColor: WidgetStateColor.resolveWith(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return kDarkAndLightDisabledIconColor;
                          }
                          return kDarkAndLightEnabledIconColor;
                        },
                      ),
                      value: _applySortFilterToAudioPlayerView,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _applySortFilterToAudioPlayerView = newValue!;
                        });
                      },
                    ),
                  ],
                ),
        ],
      );
    } else {
      // remove is applied
      return Column(
        children: [
          (!widget.isSortFilterParmsNameAlreadyAppliedToPlaylistDownloadView)
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (widget.isSaveApplied)
                          ? AppLocalizations.of(context)!.forScreen(
                              AppLocalizations.of(context)!
                                  .appBarTitleDownloadAudio)
                          : AppLocalizations.of(context)!.fromScreen(
                              AppLocalizations.of(context)!
                                  .appBarTitleDownloadAudio),
                    ),
                    Checkbox(
                      key: const Key('playlistDownloadViewCheckbox'),
                      fillColor: WidgetStateColor.resolveWith(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return kDarkAndLightDisabledIconColor;
                          }
                          return kDarkAndLightEnabledIconColor;
                        },
                      ),
                      value: _applySortFilterToPlaylistDownloadView,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _applySortFilterToPlaylistDownloadView = newValue!;
                        });
                      },
                    ),
                  ],
                ),
          (!widget.isSortFilterParmsNameAlreadyAppliedToAudioPlayerView)
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      (widget.isSaveApplied)
                          ? AppLocalizations.of(context)!.forScreen(
                              AppLocalizations.of(context)!
                                  .appBarTitleAudioPlayer)
                          : AppLocalizations.of(context)!.fromScreen(
                              AppLocalizations.of(context)!
                                  .appBarTitleAudioPlayer),
                    ),
                    Checkbox(
                      key: const Key('audioPlayerViewCheckbox'),
                      fillColor: WidgetStateColor.resolveWith(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return kDarkAndLightDisabledIconColor;
                          }
                          return kDarkAndLightEnabledIconColor;
                        },
                      ),
                      value: _applySortFilterToAudioPlayerView,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _applySortFilterToAudioPlayerView = newValue!;
                        });
                      },
                    ),
                  ],
                ),
        ],
      );
    }
  }

  List<Object> _displayConfirmAndCreateReturnedLst() {
    WarningMessageVM warningMessageVM = Provider.of<WarningMessageVM>(
      context,
      listen: false,
    );

    if (_applySortFilterToPlaylistDownloadView ||
        _applySortFilterToAudioPlayerView) {
      // The confirmation warning message is displayed only if
      // the user has selected at least one of the checkboxes
      warningMessageVM.confirmAddRemoveSortFilterParmsToPlaylist(
        playlistTitle: widget.playlistTitle,
        sortFilterParmsName: widget.sortFilterParmsName,
        isSaveApplied: widget.isSaveApplied,
        forPlaylistDownloadView: _applySortFilterToPlaylistDownloadView,
        forAudioPlayerView: _applySortFilterToAudioPlayerView,
      );
    }

    return [
      widget.sortFilterParmsName,
      _applySortFilterToPlaylistDownloadView,
      _applySortFilterToAudioPlayerView,
    ];
  }
}
