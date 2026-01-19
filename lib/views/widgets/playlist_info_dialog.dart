import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/picture_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '/../utils/duration_expansion.dart';
import '../../constants.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';

class PlaylistInfoDialog extends StatelessWidget with ScreenMixin {
  final SettingsDataService settingsDataService;
  final Playlist playlist;
  final int playlistJsonFileSize;
  final FocusNode focusNodeDialog = FocusNode();

  PlaylistInfoDialog({
    required this.settingsDataService,
    required this.playlist,
    required this.playlistJsonFileSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true
    final DateFormatVM dateFormatVMlistenFalse = Provider.of<DateFormatVM>(
      context,
      listen: false,
    );
    final WarningMessageVM warningMessageVMlistenFalse =
        Provider.of<WarningMessageVM>(
      context,
      listen: false,
    );
    final DateTime? lastDownloadDateTime = playlist.getLastDownloadDateTime();
    final String lastDownloadDateTimeStr = (lastDownloadDateTime != null)
        ? dateFormatVMlistenFalse.formatDateTime(lastDownloadDateTime)
        : '';

    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      focusNodeDialog,
    );

    final String audioSortFilterParmsNameForPlaylistDownloadView =
        playlist.audioSortFilterParmsNameForPlaylistDownloadView;
    final String audioSortFilterParmsNameForAudioPlayerView =
        playlist.audioSortFilterParmsNameForAudioPlayerView;

    final CommentVM commentVMlistenFalse =
        Provider.of<CommentVM>(context, listen: false);
    final PictureVM pictureVMlistenFalse =
        Provider.of<PictureVM>(context, listen: false);

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
        title: Text(
          AppLocalizations.of(context)!.playlistInfoDialogTitle,
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createInfoRowFunction(
                  context: context,
                  valueTextWidgetKey: Key('playlist_title_key'),
                  label: AppLocalizations.of(context)!.playlistTitleLabel,
                  value: playlist.title),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.playlistTypeLabel,
                  value: (playlist.playlistType == PlaylistType.local)
                      ? AppLocalizations.of(context)!.playlistTypeLocal
                      : AppLocalizations.of(context)!.playlistTypeYoutube),
              createInfoRowFunction(
                  context: context,
                  valueTextWidgetKey: Key('playlist_id_key'),
                  label: AppLocalizations.of(context)!.playlistIdLabel,
                  value: playlist.id),
              createInfoRowFunction(
                  valueTextWidgetKey: Key('playlist_url_key'),
                  context: context,
                  label: AppLocalizations.of(context)!.playlistUrlLabel,
                  value: playlist.url,
                  isValueSelectable: true),
              createInfoRowFunction(
                  valueTextWidgetKey: Key('playlist_download_path_key'),
                  context: context,
                  label:
                      AppLocalizations.of(context)!.playlistDownloadPathLabel,
                  value: playlist.downloadPath),
              createInfoRowFunction(
                  valueTextWidgetKey:
                      Key('playlist_last_download_date_time_key'),
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistLastDownloadDateTimeLabel,
                  value: lastDownloadDateTimeStr),
              createInfoRowFunction(
                  valueTextWidgetKey: Key('playlist_info_audio_quality_key'),
                  context: context,
                  label: AppLocalizations.of(context)!.playlistQualityLabel,
                  value: (playlist.playlistQuality == PlaylistQuality.music)
                      ? AppLocalizations.of(context)!.playlistQualityMusic
                      : AppLocalizations.of(context)!.playlistQualityAudio),
              createInfoRowFunction(
                context: context,
                label:
                    AppLocalizations.of(context)!.playlistAudioPlaySpeedLabel,
                value: playlist.audioPlaySpeed.toString(),
              ),
              createInfoRowFunction(
                valueTextWidgetKey: Key(
                    'playlist_info_download_audio_sort_filter_parameters_key'),
                context: context,
                label: AppLocalizations.of(context)!.playlistSortFilterLabel(
                  AppLocalizations.of(context)!.playlistInfoDownloadAudio,
                ),
                value: (audioSortFilterParmsNameForPlaylistDownloadView.isEmpty)
                    ? AppLocalizations.of(context)!
                        .sortFilterParametersDefaultName
                    : audioSortFilterParmsNameForPlaylistDownloadView,
              ),
              createInfoRowFunction(
                valueTextWidgetKey:
                    Key('playlist_info_play_audio_sort_filter_parameters_key'),
                context: context,
                label: AppLocalizations.of(context)!.playlistSortFilterLabel(
                  AppLocalizations.of(context)!.playlistInfoAudioPlayer,
                ),
                value: (audioSortFilterParmsNameForAudioPlayerView.isEmpty)
                    ? AppLocalizations.of(context)!
                        .sortFilterParametersDefaultName
                    : audioSortFilterParmsNameForAudioPlayerView,
              ),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.playlistIsSelectedLabel,
                  value: (playlist.isSelected)
                      ? AppLocalizations.of(context)!.yes
                      : AppLocalizations.of(context)!.no),
              createInfoRowFunction(
                  valueTextWidgetKey:
                      Key('playlist_info_total_audio_number_key'),
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistTotalAudioNumberLabel,
                  value: playlist.downloadedAudioLst.length.toString()),
              createInfoRowFunction(
                  valueTextWidgetKey:
                      Key('playlist_info_playable_audio_number_key'),
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistPlayableAudioNumberLabel,
                  value: playlist.playableAudioLst.length.toString()),
              createInfoRowFunction(
                  valueTextWidgetKey:
                      Key('playlist_info_audio_comment_number_key'),
                  context: context,
                  label:
                      AppLocalizations.of(context)!.playlistAudioCommentsLabel,
                  value: commentVMlistenFalse
                      .getPlaylistAudioCommentNumber(
                        playlist: playlist,
                      )
                      .toString()),
              createInfoRowFunction(
                  valueTextWidgetKey:
                      Key('playlist_info_audio_picture_number_key'),
                  context: context,
                  label:
                      AppLocalizations.of(context)!.playlistAudioPicturesLabel,
                  value: pictureVMlistenFalse
                      .getPlaylistAudioPictureNumber(
                        playlist: playlist,
                      )
                      .toString()),
              createInfoRowFunction(
                  valueTextWidgetKey:
                      Key('playlist_info_playable_audio_total_duration_key'),
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistPlayableAudioTotalDurationLabel,
                  value: playlist.getPlayableAudioLstTotalDuration().HHmmss()),
              createInfoRowFunction(
                  valueTextWidgetKey: Key(
                      'playlist_info_playable_audio_total_remaining_duration_key'),
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistPlayableAudioTotalRemainingDurationLabel,
                  value: playlist
                      .getPlayableAudioLstTotalRemainingDuration()
                      .HHmmss()),
              createInfoRowFunction(
                valueTextWidgetKey:
                    Key('playlist_info_playable_audio_total_file_size_key'),
                context: context,
                label: AppLocalizations.of(context)!
                    .playlistPlayableAudioTotalSizeLabel,
                value: UiUtil.formatLargeSizeToKbOrMb(
                  context: context,
                  sizeInBytes: playlist.getPlayableAudioLstTotalFileSize(),
                ),
              ),
              createInfoRowFunction(
                context: context,
                label: AppLocalizations.of(context)!.playlistJsonFileSizeLabel,
                value: UiUtil.formatLargeSizeToKbOrMb(
                  context: context,
                  sizeInBytes: playlistJsonFileSize,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            key: Key('playlist_info_ok_button_key'),
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
}
