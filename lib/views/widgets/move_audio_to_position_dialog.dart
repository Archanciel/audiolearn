import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../models/help_item.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../views/screen_mixin.dart';
import '../../services/settings_data_service.dart';
import 'help_dialog.dart';

/// This dialog allows the user to rename the audio file or modify its title
class MoveAudioToPositionDialog extends StatefulWidget {
  final Audio audio;
  final List<HelpItem> helpItemsLst;

  const MoveAudioToPositionDialog({
    required this.audio,
    this.helpItemsLst = const [],
    super.key,
  });

  @override
  State<MoveAudioToPositionDialog> createState() =>
      _MoveAudioToPositionDialogState();
}

class _MoveAudioToPositionDialogState extends State<MoveAudioToPositionDialog>
    with ScreenMixin {
  final TextEditingController _audioPositionTextEditingController =
      TextEditingController();
  final FocusNode _focusNodeDialog = FocusNode();
  final FocusNode _focusNodeAudioModificationTextField = FocusNode();

  @override
  void initState() {
    super.initState();

    // This enable the Modify or Rename button to be disabled when
    // the text field is empty
    _audioPositionTextEditingController.addListener(() {
      setState(() {}); // Rebuild when text changes
    });
  }

  @override
  void dispose() {
    _audioPositionTextEditingController.removeListener(() {});
    _audioPositionTextEditingController.dispose();
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
    String labelStr;
    String labelAndTextFieldTooltipStr;
    int flexibleValue;

    titleStr = AppLocalizations.of(context)!.moveAudioToPosition;
    labelStr = AppLocalizations.of(context)!.audioIntPositionLabel;
    labelAndTextFieldTooltipStr =
        AppLocalizations.of(context)!.audioPositionTooltip;
    flexibleValue = 1;

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
            _moveAudioToPosition(context);

            Navigator.of(context).pop(_audioPositionTextEditingController.text);
          }
        }
      },
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                key: const Key('audioPositionMoveDialogTitleKey'),
                titleStr,
                textAlign: TextAlign.center, // Centered multi lines text
                maxLines: 2,
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
              const SizedBox.shrink(),
              createFlexibleEditableRowFunction(
                valueTextFieldWidgetKey:
                    const Key('audioPositionModificationTextField'),
                context: context,
                label: labelStr,
                labelAndTextFieldTooltip: labelAndTextFieldTooltipStr,
                controller: _audioPositionTextEditingController,
                textFieldFocusNode: _focusNodeAudioModificationTextField,
                editableFieldFlexValue: flexibleValue,
                labelFlexValue: 3,
                isCursorAtStart:
                    false, // if true, cursor set at start at every text modification
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('moveAudioToPositionButton'),
            onPressed: _audioPositionTextEditingController.text.trim().isEmpty
                ? null // This disables the button
                : () {
                    _moveAudioToPosition(context);
                    Navigator.of(context)
                        .pop(_audioPositionTextEditingController.text);
                  },
            child: Text(
              AppLocalizations.of(context)!.moveAudioToPositionButton,
              style: _audioPositionTextEditingController.text.trim().isEmpty
                  ? const TextStyle(
                      fontSize: kTextButtonFontSize) // Disabled style
                  : (themeProviderVM.currentTheme == AppTheme.dark)
                      ? kTextButtonStyleDarkMode
                      : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            key: const Key('playlistRenameCancelButton'),
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

  void _moveAudioToPosition(BuildContext context) {
    PlaylistListVM playlistListVMlistendFalse = Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );

    return playlistListVMlistendFalse.moveAudioToPosition(
      audio: widget.audio,
      position: int.parse(_audioPositionTextEditingController.text.trim()),
      sortFilterParametersAppliedName:
          AppLocalizations.of(context)!.sortFilterParametersAppliedName,
      sortFilterParametersDefaultName:
          AppLocalizations.of(context)!.sortFilterParametersDefaultName,
    );
  }
}
