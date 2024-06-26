import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/audio.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../screen_mixin.dart';
import 'application_settings_dialog_widget.dart';
import 'audio_info_dialog_widget.dart';
import 'audio_modification_dialog_widget.dart';
import 'comment_list_add_dialog_widget.dart';

enum AppBarPopupMenu {
  openSettingsDialog,
  option2,
}

/// The AppBarLeadingPopupMenuWidget is used to display the leading
/// popup menu icon of the AppBar. The displayed items are specific
/// to the currently displayed screen.
class AppBarLeadingPopupMenuWidget extends StatelessWidget with ScreenMixin {
  final ThemeProviderVM themeProvider;
  final SettingsDataService settingsDataService;
  final AudioLearnAppViewType audioLearnAppViewType;

  AppBarLeadingPopupMenuWidget({
    super.key,
    required this.audioLearnAppViewType,
    required this.themeProvider,
    required this.settingsDataService,
  });

  @override
  Widget build(BuildContext context) {
    switch (audioLearnAppViewType) {
      case AudioLearnAppViewType.audioPlayerView:
        return _audioPlayerViewPopupMenuButton(context);
      default:
        return _playListDownloadViewPopupMenuButton(context);
    }
  }

  PopupMenuButton<AudioPopupMenuAction> _audioPlayerViewPopupMenuButton(
      BuildContext context) {
    AudioPlayerVM audioGlobalPlayerVM = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    Audio audio;

    if (audioGlobalPlayerVM.currentAudio == null) {
      // In this case, the appbar leading popup menu has no menu items
      return PopupMenuButton<AudioPopupMenuAction>(
        itemBuilder: (BuildContext context) {
          return [];
        },
        icon: const Icon(Icons.menu),
        onSelected: (AudioPopupMenuAction value) {},
      );
    } else {
      audio = audioGlobalPlayerVM.currentAudio!;
    }

    return PopupMenuButton<AudioPopupMenuAction>(
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_menu_open_youtube_video'),
            value: AudioPopupMenuAction.openYoutubeVideo,
            child: Text(AppLocalizations.of(context)!.openYoutubeVideo),
          ),
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_copy_youtube_video_url'),
            value: AudioPopupMenuAction.copyYoutubeVideoUrl,
            child: Text(AppLocalizations.of(context)!.copyYoutubeVideoUrl),
          ),
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_menu_display_audio_info'),
            value: AudioPopupMenuAction.displayAudioInfo,
            child: Text(AppLocalizations.of(context)!.displayAudioInfo),
          ),
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_menu_audio_comment'),
            value: AudioPopupMenuAction.audioComment,
            child: Text(AppLocalizations.of(context)!.commentMenu),
          ),
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_menu_rename_audio_file'),
            value: AudioPopupMenuAction.renameAudioFile,
            child: Text(AppLocalizations.of(context)!.renameAudioFile),
          ),
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_menu_modify_audio_title'),
            value: AudioPopupMenuAction.modifyAudioTitle,
            child: Text(AppLocalizations.of(context)!.modifyAudioTitle),
          ),
        ];
      },
      icon: const Icon(Icons.menu),
      onSelected: (AudioPopupMenuAction value) async {
        switch (value) {
          case AudioPopupMenuAction.openYoutubeVideo:
            openUrlInExternalApp(
              url: audio.videoUrl,
              warningMessageVM: Provider.of<WarningMessageVM>(
                context,
                listen: false,
              ),
            );
            break;
          case AudioPopupMenuAction.copyYoutubeVideoUrl:
            Clipboard.setData(ClipboardData(text: audio.videoUrl));
            break;
          case AudioPopupMenuAction.displayAudioInfo:
            showDialog<void>(
              context: context,
              builder: (BuildContext context) => AudioInfoDialogWidget(
                audio: audio,
              ),
            );
            break;
          case AudioPopupMenuAction.audioComment:
            audioGlobalPlayerVM.setCurrentAudio(audio).then((value) {
              showDialog<void>(
                context: context,
                // passing the current audio to the dialog instead
                // of initializing a private _currentAudio variable
                // in the dialog avoid integr test problems
                builder: (context) => CommentListAddDialogWidget(
                  currentAudio: audio,
                ),
              );
            });
            break;
          case AudioPopupMenuAction.renameAudioFile:
            showDialog<void>(
                context: context,
                barrierDismissible:
                    false, // This line prevents the dialog from closing when
                //            tapping outside the dialog
                builder: (BuildContext context) =>
                    AudioModificationDialogWidget(
                      audio: audio,
                      audioModificationType:
                          AudioModificationType.renameAudioFile,
                    ));
            break;
          case AudioPopupMenuAction.modifyAudioTitle:
            showDialog<void>(
              context: context,
              barrierDismissible:
                  false, // This line prevents the dialog from closing when
              //            tapping outside the dialog
              builder: (BuildContext context) => AudioModificationDialogWidget(
                audio: audio,
                audioModificationType: AudioModificationType.modifyAudioTitle,
              ),
            ).then((resultMap) async {
              AudioPlayerVM audioGlobalPlayerVM = Provider.of<AudioPlayerVM>(
                context,
                listen: false,
              );

              // Required so that the audio title displayed in the
              // audio player view is updated with the modified title
              await audioGlobalPlayerVM.setCurrentAudio(audio);
            });
            break;
          default:
            break;
        }
      },
    );
  }

  PopupMenuButton<AppBarPopupMenu> _playListDownloadViewPopupMenuButton(
      BuildContext context) {
    return PopupMenuButton<AppBarPopupMenu>(
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<AppBarPopupMenu>(
            key: const Key('appBarMenuOpenSettingsDialog'),
            value: AppBarPopupMenu.openSettingsDialog,
            child: Text(
                AppLocalizations.of(context)!.appBarMenuOpenSettingsDialog),
          ),
        ];
      },
      icon: const Icon(Icons.menu),
      onSelected: (AppBarPopupMenu value) {
        switch (value) {
          case AppBarPopupMenu.openSettingsDialog:
            showDialog<void>(
              context: context,
              barrierDismissible: false, // This line prevents the dialog from
              // closing when tapping outside the dialog
              builder: (BuildContext context) {
                return ApplicationSettingsDialogWidget(
                  settingsDataService: settingsDataService,
                );
              },
            );
            break;
          default:
            break;
        }
      },
    );
  }
}
