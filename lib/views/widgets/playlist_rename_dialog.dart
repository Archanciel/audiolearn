import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../constants.dart';
import '../../models/help_item.dart';
import '../../models/playlist.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../views/screen_mixin.dart';
import '../../services/settings_data_service.dart';
import 'help_dialog.dart';

/// This dialog allows the user to rename the audio file or modify its title
class PlaylistRenameDialog extends StatefulWidget {
  final SettingsDataService settingsDataService;
  final Playlist playlist;
  final List<HelpItem> helpItemsLst;

  const PlaylistRenameDialog({
    required this.settingsDataService,
    required this.playlist,
    this.helpItemsLst = const [],
    super.key,
  });

  @override
  State<PlaylistRenameDialog> createState() => _PlaylistRenameDialogState();
}

class _PlaylistRenameDialogState extends State<PlaylistRenameDialog>
    with ScreenMixin {
  final TextEditingController _audioModificationTextEditingController =
      TextEditingController();
  final FocusNode _focusNodeDialog = FocusNode();
  final FocusNode _focusNodeAudioModificationTextField = FocusNode();

  @override
  void initState() {
    super.initState();

    // This enable the Modify or Rename button to be disabled when
    // the text field is empty
    _audioModificationTextEditingController.addListener(() {
      setState(() {}); // Rebuild when text changes
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioModificationTextEditingController.text = widget.playlist.title;
    });
  }

  @override
  void dispose() {
    _audioModificationTextEditingController.removeListener(() {});
    _audioModificationTextEditingController.dispose();
    _focusNodeDialog.dispose();
    _focusNodeAudioModificationTextField.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true

    FocusScope.of(context).requestFocus(
      _focusNodeAudioModificationTextField,
    );

    String titleStr;
    String commentStr;
    String labelStr;
    String labelAndTextFieldTooltipStr;
    String modificationButtonStr;
    int flexibleValue;

    titleStr = AppLocalizations.of(context)!.renamePlaylist;
    commentStr = AppLocalizations.of(context)!.renameAudioFileDialogComment;
    labelStr = AppLocalizations.of(context)!.renamePlaylistLabel;
    labelAndTextFieldTooltipStr =
        AppLocalizations.of(context)!.renamePlaylistTooltip;
    modificationButtonStr = AppLocalizations.of(context)!.renamePlaylistButton;
    flexibleValue = 4;

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the audioModification
            // TextButton onPressed callback
            _handlePlaylistModification(context);

            Navigator.of(context)
                .pop(_audioModificationTextEditingController.text);
          }
        }
      },
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                key: const Key('audioModificationDialogTitleKey'),
                titleStr,
              ),
            ),
            if (widget.helpItemsLst.isNotEmpty)
              IconButton(
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
              ),
          ],
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              (commentStr.isNotEmpty)
                  ? createTitleCommentRowFunction(
                      titleTextWidgetKey:
                          const Key('audioModificationTitleCommentKey'),
                      context: context,
                      commentStr: commentStr,
                    )
                  : const SizedBox.shrink(),
              createFlexibleEditableRowFunction(
                valueTextFieldWidgetKey:
                    const Key('audioModificationTextField'),
                context: context,
                label: labelStr,
                labelAndTextFieldTooltip: labelAndTextFieldTooltipStr,
                controller: _audioModificationTextEditingController,
                textFieldFocusNode: _focusNodeAudioModificationTextField,
                editableFieldFlexValue: flexibleValue,
                isCursorAtStart:
                    false, // if true, cursor set at start at every text modification
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('audioModificationButton'),
            onPressed:
                _audioModificationTextEditingController.text.trim().isEmpty
                    ? null // This disables the button
                    : () {
                        _handlePlaylistModification(context);
                        Navigator.of(context)
                            .pop(_audioModificationTextEditingController.text);
                      },
            child: Text(
              modificationButtonStr,
              style: _audioModificationTextEditingController.text.trim().isEmpty
                  ? const TextStyle(
                      fontSize: kTextButtonFontSize) // Disabled style
                  : (themeProviderVM.currentTheme == AppTheme.dark)
                      ? kTextButtonStyleDarkMode
                      : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            key: const Key('audioModificationCancelButton'),
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

  void _handlePlaylistModification(BuildContext context) {
    _modifyPlaylistTitle(context);
  }

  void _modifyPlaylistTitle(BuildContext context) {
    String playlistTitle = _audioModificationTextEditingController.text;
    PlaylistListVM playlistListVMlistendFalse = Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );

    // audioDownloadVM.modifyAudioTitle(
    //   playlist: widget.playlist,
    //   modifiedPlaylistTitle: playlistTitle,
    // );
  }
}
