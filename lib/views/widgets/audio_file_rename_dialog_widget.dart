import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../models/audio.dart';
import '../../services/settings_data_service.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/audio_download_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';

class AudioFileRenameDialogWidget extends StatefulWidget {
  final Audio audio;

  const AudioFileRenameDialogWidget({
    required this.audio,
    super.key,
  });

  @override
  State<AudioFileRenameDialogWidget> createState() =>
      _AudioFileRenameDialogWidgetState();
}

class _AudioFileRenameDialogWidgetState
    extends State<AudioFileRenameDialogWidget> with ScreenMixin {
  final TextEditingController _audioFileNameTextEditingController =
      TextEditingController();
  final FocusNode _focusNodeDialog = FocusNode();
  final FocusNode _focusNodeAudioFileTextField = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioFileNameTextEditingController.text = widget.audio.audioFileName;
    });
  }

  @override
  void dispose() {
    _audioFileNameTextEditingController.dispose();
    _focusNodeDialog.dispose();
    _focusNodeAudioFileTextField.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    FocusScope.of(context).requestFocus(
      _focusNodeAudioFileTextField,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Rename'
            // TextButton onPressed callback
            _renameAudioFile(context);
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Text(
          key: const Key('renameAudioFileDialogTitleKey'),
          AppLocalizations.of(context)!.renameAudioFileDialogTitle,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createTitleCommentRowFunction(
                titleTextWidgetKey: const Key('renameAudioFileDialogKey'),
                context: context,
                commentStr:
                    AppLocalizations.of(context)!.renameAudioFileDialogComment,
              ),
              createEditableRowFunction(
                valueTextFieldWidgetKey:
                    const Key('renameAudioFileDialogTextField'),
                context: context,
                label: AppLocalizations.of(context)!.renameAudioFileLabel,
                controller: _audioFileNameTextEditingController,
                textFieldFocusNode: _focusNodeAudioFileTextField,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('renameAudioFileButton'),
            onPressed: () {
              _renameAudioFile(context);
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.renameAudioFileButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
          TextButton(
            key: const Key('renameAudioFileCancelButton'),
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

  void _renameAudioFile(BuildContext context) {
    String audioFileName = _audioFileNameTextEditingController.text;
    AudioDownloadVM audioDownloadVM =
        Provider.of<AudioDownloadVM>(context, listen: false);

    audioDownloadVM.renameAudioFile(
      audio: widget.audio,
      modifiedAudioFileName: audioFileName,
    );
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
