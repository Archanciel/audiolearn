import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '/../utils/duration_expansion.dart';
import '../../constants.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../utils/ui_util.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';

class PlaylistInfoDialogWidget extends StatelessWidget with ScreenMixin {
  final SettingsDataService settingsDataService;
  final Playlist playlist;
  final int playlistJsonFileSize;
  final FocusNode focusNodeDialog = FocusNode();

  PlaylistInfoDialogWidget({
    required this.settingsDataService,
    required this.playlist,
    required this.playlistJsonFileSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);
    DateTime? lastDownloadDateTime = playlist.getLastDownloadDateTime();
    String lastDownloadDateTimeStr = (lastDownloadDateTime != null)
        ? frenchDateTimeFormat.format(lastDownloadDateTime)
        : '';

    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      focusNodeDialog,
    );

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
        title: Text(AppLocalizations.of(context)!.playlistInfoDialogTitle),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              createInfoRowFunction(
                  context: context,
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
                  label: AppLocalizations.of(context)!.playlistIdLabel,
                  value: playlist.id),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.playlistUrlLabel,
                  value: playlist.url),
              createInfoRowFunction(
                  context: context,
                  label:
                      AppLocalizations.of(context)!.playlistDownloadPathLabel,
                  value: playlist.downloadPath),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistLastDownloadDateTimeLabel,
                  value: lastDownloadDateTimeStr),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.playlistQualityLabel,
                  value: (playlist.playlistQuality == PlaylistQuality.music)
                      ? AppLocalizations.of(context)!.playlistQualityMusic
                      : AppLocalizations.of(context)!.playlistQualityAudio),
              createInfoRowFunction(
                context: context,
                label:
                    AppLocalizations.of(context)!.playlistAudioPlaySpeedLabel,
                value: (playlist.audioPlaySpeed != 0)
                    ? playlist.audioPlaySpeed.toString()
                    : settingsDataService
                        .get(
                          settingType: SettingType.playlists,
                          settingSubType: Playlists.playSpeed,
                        )
                        .toString(),
              ),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!.playlistIsSelectedLabel,
                  value: (playlist.isSelected)
                      ? AppLocalizations.of(context)!.yes
                      : AppLocalizations.of(context)!.no),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistTotalAudioNumberLabel,
                  value: playlist.downloadedAudioLst.length.toString()),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistPlayableAudioNumberLabel,
                  value: playlist.playableAudioLst.length.toString()),
              createInfoRowFunction(
                  context: context,
                  label: AppLocalizations.of(context)!
                      .playlistPlayableAudioTotalDurationLabel,
                  value: playlist.getPlayableAudioLstTotalDuration().HHmmss()),
              createInfoRowFunction(
                context: context,
                label: AppLocalizations.of(context)!
                    .playlistPlayableAudioTotalSizeLabel,
                value: UiUtil.formatLargeIntValue(
                  context: context,
                  value: playlist.getPlayableAudioLstTotalFileSize(),
                ),
              ),
              createInfoRowFunction(
                context: context,
                label: AppLocalizations.of(context)!.playlistJsonFileSizeLabel,
                value: UiUtil.formatLargeIntValue(
                  context: context,
                  value: playlistJsonFileSize,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
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
