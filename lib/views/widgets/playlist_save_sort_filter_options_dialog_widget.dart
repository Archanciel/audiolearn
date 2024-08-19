import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../views/screen_mixin.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';

/// Dialog widget that allows the user to save the sort and
/// filter options to a playlist so that they can be applied
/// when the playlist is opened.
class PlaylistSaveSortFilterOptionsDialogWidget extends StatefulWidget {
  final String playlistTitle;
  final String sortFilterParametersName;

  const PlaylistSaveSortFilterOptionsDialogWidget({
    super.key,
    required this.playlistTitle,
    required this.sortFilterParametersName,
  });

  @override
  State<PlaylistSaveSortFilterOptionsDialogWidget> createState() =>
      _PlaylistSaveSortFilterOptionsDialogWidgetState();
}

class _PlaylistSaveSortFilterOptionsDialogWidgetState
    extends State<PlaylistSaveSortFilterOptionsDialogWidget> with ScreenMixin {
  final FocusNode _focusNodeDialog = FocusNode();

  bool _applySortFilterToAudioPlayerView = false;
  bool _applySortFilterToPlaylistDownloadView = false;

  @override
  Widget build(BuildContext context) {
    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      _focusNodeDialog,
    );

    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

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
            Navigator.of(context).pop([
              _applySortFilterToPlaylistDownloadView,
              _applySortFilterToAudioPlayerView,
            ]);
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('saveSortFilterOptionsToPlaylistDialogTitleKey'),
          AppLocalizations.of(context)!
              .saveSortFilterOptionsToPlaylistDialogTitle(
                  widget.sortFilterParametersName),
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
                label: AppLocalizations.of(context)!
                    .saveSortFilterOptionsToPlaylist(widget.playlistTitle),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.forScreen(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.forScreen(
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
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('saveSortFilterOptionsToPlaylistSaveButton'),
            onPressed: () async {
              Navigator.of(context).pop([
                _applySortFilterToPlaylistDownloadView,
                _applySortFilterToAudioPlayerView,
              ]);
            },
            child: Text(
              AppLocalizations.of(context)!.saveButton,
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
    );
  }
}
