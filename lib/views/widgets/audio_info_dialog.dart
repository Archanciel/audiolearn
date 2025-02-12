import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../services/settings_data_service.dart';
import '../../utils/duration_expansion.dart';
import '../../viewmodels/date_format_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../models/audio.dart';
import '../../utils/ui_util.dart';

/// This dialog is used to display audio informations. It is used
/// in the AudioListItemWidget left (leading:) menu.
class AudioInfoDialog extends StatelessWidget with ScreenMixin {
  final Audio audio;
  final FocusNode focusNodeDialog = FocusNode();

  AudioInfoDialog({
    required this.audio,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      focusNodeDialog,
    );

    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Ok'
            // TextButton onPressed callback
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: (audio.isAudioImported)
            ? Text(AppLocalizations.of(context)!.audioImportedInfoDialogTitle)
            : Text(AppLocalizations.of(context)!.audioInfoDialogTitle),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: ListBody(
            children: (audio.isAudioImported)
                ? _createImportedAudioInfoLines(
                    context,
                  )
                : _createDownloadedAudioInfoLines(
                    context,
                  ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('audio_info_close_button_key'),
            child: Text(
              AppLocalizations.of(context)!.closeTextButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// Creates the list of audio information lines for downloaded audio.
  List<Widget> _createDownloadedAudioInfoLines(BuildContext context) {
    final CommentVM commentVMlistenFalse = Provider.of<CommentVM>(
      context,
      listen: false,
    );
    final DateFormatVM dateFormatVMlistenFalse = Provider.of<DateFormatVM>(
      context,
      listen: false,
    );

    return <Widget>[
      createInfoRowFunction(
          valueTextWidgetKey: const Key('youtubeChannelKey'),
          context: context,
          label: AppLocalizations.of(context)!.youtubeChannelLabel,
          value: audio.youtubeVideoChannel),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('originalVideoTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.originalVideoTitleLabel,
          value: audio.originalVideoTitle),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('videoUploadDateKey'),
          context: context,
          label: AppLocalizations.of(context)!.videoUploadDateLabel,
          value: dateFormatVMlistenFalse.formatDate(audio.videoUploadDate)),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('audioDownloadDateTimeKey'),
          context: context,
          label: AppLocalizations.of(context)!.audioDownloadDateTimeLabel,
          value: dateFormatVMlistenFalse
              .formatDateTime(audio.audioDownloadDateTime)),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.videoUrlLabel,
          value: audio.videoUrl),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.compactVideoDescription,
          value: audio.compactVideoDescription),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('validVideoTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.validVideoTitleLabel,
          value: audio.validVideoTitle),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('enclosingPlaylistTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.enclosingPlaylistLabel,
          value: (audio.enclosingPlaylist == null)
              ? ''
              : audio.enclosingPlaylist!.title),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('movedFromPlaylistTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.movedFromPlaylistLabel,
          value: (audio.movedFromPlaylistTitle == null)
              ? ''
              : audio.movedFromPlaylistTitle!),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('movedToPlaylistTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.movedToPlaylistLabel,
          value: (audio.movedToPlaylistTitle == null)
              ? ''
              : audio.movedToPlaylistTitle!),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('copiedFromPlaylistTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.copiedFromPlaylistLabel,
          value: (audio.copiedFromPlaylistTitle == null)
              ? ''
              : audio.copiedFromPlaylistTitle!),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('copiedToPlaylistTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.copiedToPlaylistLabel,
          value: (audio.copiedToPlaylistTitle == null)
              ? ''
              : audio.copiedToPlaylistTitle!),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioDownloadDurationLabel,
          value: audio.audioDownloadDuration!.HHmmss()),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioDownloadSpeedLabel,
          value: formatDownloadSpeed(
            context: context,
            audio: audio,
          )),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('audioDurationKey'),
          context: context,
          label: AppLocalizations.of(context)!.audioDurationLabel,
          value: audio.audioDuration.HHmmss(
            addRemainingOneDigitTenthOfSecond: true,
          )),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioPositionLabel,
          value: Duration(seconds: audio.audioPositionSeconds).HHmmss()),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('audioStateKey'),
          context: context,
          label: AppLocalizations.of(context)!.audioStateLabel,
          value: defineAudioStateStr(
            context: context,
            audio: audio,
          )),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioPausedDateTimeLabel,
          value: (audio.audioPausedDateTime != null)
              ? frenchDateTimeFormat.format(audio.audioPausedDateTime!)
              : ''),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('audioFileNameKey'),
          context: context,
          label: AppLocalizations.of(context)!.audioFileNameLabel,
          value: audio.audioFileName),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioFileSizeLabel,
          value: UiUtil.formatLargeSizeToKbOrMb(
            context: context,
            sizeInBytes: audio.audioFileSize,
          )),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.isMusicQualityLabel,
          value: (audio.isAudioMusicQuality)
              ? AppLocalizations.of(context)!.yes
              : AppLocalizations.of(context)!.no),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('audioPlaySpeedKey'),
          context: context,
          label: AppLocalizations.of(context)!.audioPlaySpeedLabel,
          value: audio.audioPlaySpeed.toString()),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioPlayVolumeLabel,
          value: '${(audio.audioPlayVolume * 100).toStringAsFixed(1)} %'),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.commentsDialogTitle,
          value:
              commentVMlistenFalse.getCommentNumber(audio: audio).toString()),
    ];
  }

  /// Creates the list of audio information lines for imported audio.
  List<Widget> _createImportedAudioInfoLines(BuildContext context) {
    CommentVM commentVMlistenFalse =
        Provider.of<CommentVM>(context, listen: false);

    return <Widget>[
      createInfoRowFunction(
          valueTextWidgetKey: const Key('importedAudioTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.audioTitleLabel,
          value: audio.validVideoTitle),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.importedAudioDateTimeLabel,
          value: frenchDateTimeFormat.format(audio.audioDownloadDateTime)),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.importedAudioUrlLabel,
          value: audio.videoUrl),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.importedAudioDescriptionLabel,
          value: audio.compactVideoDescription),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('enclosingPlaylistTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.enclosingPlaylistLabel,
          value: (audio.enclosingPlaylist == null)
              ? ''
              : audio.enclosingPlaylist!.title),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('movedFromPlaylistTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.movedFromPlaylistLabel,
          value: (audio.movedFromPlaylistTitle == null)
              ? ''
              : audio.movedFromPlaylistTitle!),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('movedToPlaylistTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.movedToPlaylistLabel,
          value: (audio.movedToPlaylistTitle == null)
              ? ''
              : audio.movedToPlaylistTitle!),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('copiedFromPlaylistTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.copiedFromPlaylistLabel,
          value: (audio.copiedFromPlaylistTitle == null)
              ? ''
              : audio.copiedFromPlaylistTitle!),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('copiedToPlaylistTitleKey'),
          context: context,
          label: AppLocalizations.of(context)!.copiedToPlaylistLabel,
          value: (audio.copiedToPlaylistTitle == null)
              ? ''
              : audio.copiedToPlaylistTitle!),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioDurationLabel,
          value: audio.audioDuration.HHmmss()),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioPositionLabel,
          value: Duration(seconds: audio.audioPositionSeconds).HHmmss()),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('audioStateKey'),
          context: context,
          label: AppLocalizations.of(context)!.audioStateLabel,
          value: defineAudioStateStr(
            context: context,
            audio: audio,
          )),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioPausedDateTimeLabel,
          value: (audio.audioPausedDateTime != null)
              ? frenchDateTimeFormat.format(audio.audioPausedDateTime!)
              : ''),
      createInfoRowFunction(
          valueTextWidgetKey: const Key('audioFileNameKey'),
          context: context,
          label: AppLocalizations.of(context)!.audioFileNameLabel,
          value: audio.audioFileName),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioFileSizeLabel,
          value: UiUtil.formatLargeSizeToKbOrMb(
            context: context,
            sizeInBytes: audio.audioFileSize,
          )),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioPlaySpeedLabel,
          value: audio.audioPlaySpeed.toString()),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.audioPlayVolumeLabel,
          value: '${(audio.audioPlayVolume * 100).toStringAsFixed(1)} %'),
      createInfoRowFunction(
          context: context,
          label: AppLocalizations.of(context)!.commentsDialogTitle,
          value:
              commentVMlistenFalse.getCommentNumber(audio: audio).toString()),
    ];
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
          '${UiUtil.formatLargeSizeToKbOrMb(context: context, sizeInBytes: audioDownloadSpeed)}/sec';
    }

    return audioDownloadSpeedStr;
  }

  String defineAudioStateStr({
    required BuildContext context,
    required Audio audio,
  }) {
    if (audio.audioPositionSeconds == 0) {
      return AppLocalizations.of(context)!.audioStateNotListened;
    } else if (audio.wasFullyListened()) {
      return AppLocalizations.of(context)!.audioStateTerminated;
    } else if (audio.isPaused) {
      return AppLocalizations.of(context)!.audioStatePaused;
    } else {
      return AppLocalizations.of(context)!.audioStatePlaying;
    }
  }
}
