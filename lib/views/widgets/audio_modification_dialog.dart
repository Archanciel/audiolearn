import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/help_item.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../models/audio.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_download_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import 'help_dialog.dart';

enum AudioModificationType {
  renameAudioFile,
  modifyAudioTitle,
}

/// This dialog allows the user to rename the audio file or modify its title.
class AudioModificationDialog extends StatefulWidget {
  final Audio audio;
  final AudioModificationType audioModificationType;
  final List<HelpItem> helpItemsLst;

  const AudioModificationDialog({
    required this.audio,
    required this.audioModificationType,
    this.helpItemsLst = const [],
    super.key,
  });

  @override
  State<AudioModificationDialog> createState() =>
      _AudioModificationDialogState();
}

class _AudioModificationDialogState extends State<AudioModificationDialog>
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
      switch (widget.audioModificationType) {
        case AudioModificationType.renameAudioFile:
          _audioModificationTextEditingController.text =
              widget.audio.audioFileName;
          break;
        case AudioModificationType.modifyAudioTitle:
          _audioModificationTextEditingController.text =
              widget.audio.validVideoTitle;
          break;
      }
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

    switch (widget.audioModificationType) {
      case AudioModificationType.renameAudioFile:
        titleStr = AppLocalizations.of(context)!.renameAudioFileDialogTitle;
        commentStr = AppLocalizations.of(context)!.renameAudioFileDialogComment;
        labelStr = AppLocalizations.of(context)!.renameAudioFileLabel;
        labelAndTextFieldTooltipStr =
            AppLocalizations.of(context)!.renameAudioFileTooltip;
        modificationButtonStr =
            AppLocalizations.of(context)!.renameAudioFileButton;
        flexibleValue = 4;
        break;
      case AudioModificationType.modifyAudioTitle:
        titleStr = AppLocalizations.of(context)!.modifyAudioTitleDialogTitle;
        commentStr =
            AppLocalizations.of(context)!.modifyAudioTitleDialogComment;
        labelStr = AppLocalizations.of(context)!.modifyAudioTitleLabel;
        labelAndTextFieldTooltipStr =
            AppLocalizations.of(context)!.modifyAudioTitleTooltip;
        modificationButtonStr =
            AppLocalizations.of(context)!.modifyAudioTitleButton;
        flexibleValue = 6;
        break;
    }

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
            _handleAudioModification(context);

            Navigator.of(context)
                .pop(_audioModificationTextEditingController.text);
          }
        }
      },
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                key: const Key('audioModificationDialogTitleKey'),
                titleStr,
                textAlign: TextAlign.center,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                key: const Key('audioModificationButton'),
                onPressed: _audioModificationTextEditingController.text
                        .trim()
                        .isEmpty
                    ? null // This disables the button
                    : () {
                        _handleAudioModification(context);
                        Navigator.of(context)
                            .pop(_audioModificationTextEditingController.text);
                      },
                child: Text(
                  modificationButtonStr,
                  style: _audioModificationTextEditingController.text
                          .trim()
                          .isEmpty
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
        ],
      ),
    );
  }

  void _handleAudioModification(BuildContext context) {
    switch (widget.audioModificationType) {
      case AudioModificationType.renameAudioFile:
        _renameAudioFile(context);
        break;
      case AudioModificationType.modifyAudioTitle:
        _modifyAudioTitle(context);
        break;
    }
  }

  void _renameAudioFile(BuildContext context) {
    String audioFileName = _audioModificationTextEditingController.text;
    AudioDownloadVM audioDownloadVMlistenFalse = Provider.of<AudioDownloadVM>(
      context,
      listen: false,
    );

    audioDownloadVMlistenFalse.renameAudioFile(
      audio: widget.audio,
      audioModifiedFileName: audioFileName,
    );
  }

  void _modifyAudioTitle(BuildContext context) {
    String audioTitle = _audioModificationTextEditingController.text;
    AudioDownloadVM audioDownloadVMlistenFalse = Provider.of<AudioDownloadVM>(
      context,
      listen: false,
    );

    audioDownloadVMlistenFalse.modifyAudioTitle(
      audio: widget.audio,
      modifiedAudioTitle: audioTitle,
    );
  }
}
