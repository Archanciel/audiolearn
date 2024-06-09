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
class PlaylistSortFilterOptionsSaveToDialogWidget extends StatefulWidget {
  final String playlistTitle;
  final AudioLearnAppViewType applicationViewType;

  const PlaylistSortFilterOptionsSaveToDialogWidget({
    required this.playlistTitle,
    required this.applicationViewType,
    super.key,
  });

  @override
  State<PlaylistSortFilterOptionsSaveToDialogWidget> createState() =>
      _PlaylistSortFilterOptionsSaveToDialogWidgetState();
}

class _PlaylistSortFilterOptionsSaveToDialogWidgetState
    extends State<PlaylistSortFilterOptionsSaveToDialogWidget>
    with ScreenMixin {
  final FocusNode _focusNodeDialog = FocusNode();

  bool _isAutomaticApplicationChecked = false;

  @override
  Widget build(BuildContext context) {
    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      _focusNodeDialog,
    );

    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);
    String viewNameTranslatedLabelStr = '';

    switch (widget.applicationViewType) {
      case AudioLearnAppViewType.playlistDownloadView:
        viewNameTranslatedLabelStr = AppLocalizations.of(context)!
            .saveSortFilterOptionsForView(
                AppLocalizations.of(context)!.appBarTitleDownloadAudio);
        break;
      case AudioLearnAppViewType.audioPlayerView:
        viewNameTranslatedLabelStr = AppLocalizations.of(context)!
            .saveSortFilterOptionsForView(
                AppLocalizations.of(context)!.appBarTitleAudioPlayer);
        break;
      case AudioLearnAppViewType.audioExtractorView:
        viewNameTranslatedLabelStr = AppLocalizations.of(context)!
            .saveSortFilterOptionsForView(
                AppLocalizations.of(context)!.appBarTitleAudioExtractor);
        break;
      default:
        break;
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
            Navigator.of(context).pop(_isAutomaticApplicationChecked);
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('saveSortFilterOptionsToPlaylistDialogTitleKey'),
          AppLocalizations.of(context)!
              .saveSortFilterOptionsToPlaylistDialogTitle,
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
              createLabelRowFunction(
                // displaying the view for which the sort and filter
                // options are saved
                valueTextWidgetKey:
                    const Key('saveSortFilterOptionsForViewNameKey'),
                context: context,
                label: viewNameTranslatedLabelStr,
              ),
              Tooltip(
                message: (widget.applicationViewType ==
                        AudioLearnAppViewType.audioPlayerView)
                    ? AppLocalizations.of(context)!
                        .saveSortFilterOptionsAutomaticApplicationAudioPlayerViewTooltip
                    : AppLocalizations.of(context)!
                        .saveSortFilterOptionsAutomaticApplicationTooltip,
                child: createCheckboxRowFunction(
                  // displaying the checkbox to automatically apply the
                  // sort and filter options when the playlist is opened
                  checkBoxWidgetKey:
                      const Key('saveSortFilterOptionsAutomaticApplicationKey'),
                  context: context,
                  label: AppLocalizations.of(context)!
                      .saveSortFilterOptionsAutomaticApplication,
                  value: _isAutomaticApplicationChecked,
                  onChangedFunction: (bool? value) {
                    setState(() {
                      _isAutomaticApplicationChecked = value ?? false;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('saveSortFilterOptionsToPlaylistSaveButton'),
            onPressed: () async {
              Navigator.of(context).pop(_isAutomaticApplicationChecked);
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
