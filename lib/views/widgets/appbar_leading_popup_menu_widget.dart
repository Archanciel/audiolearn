import 'package:audiolearn/models/comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/audio.dart';
import '../../models/playlist.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../screen_mixin.dart';
import 'action_confirm_dialog_widget.dart';
import 'application_settings_dialog_widget.dart';
import 'audio_info_dialog_widget.dart';
import 'audio_modification_dialog_widget.dart';
import 'comment_list_add_dialog_widget.dart';
import 'playlist_one_selectable_dialog_widget.dart';

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

    if (audioGlobalPlayerVM.currentAudio == null) {
      // In this case, the appbar leading popup menu has no menu items
      return PopupMenuButton<AudioPopupMenuAction>(
        itemBuilder: (BuildContext context) {
          return [];
        },
        icon: const Icon(Icons.menu),
        onSelected: (AudioPopupMenuAction value) {},
      );
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
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_menu_move_audio_to_playlist'),
            value: AudioPopupMenuAction.moveAudioToPlaylist,
            child: Text(AppLocalizations.of(context)!.moveAudioToPlaylist),
          ),
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_menu_copy_audio_to_playlist'),
            value: AudioPopupMenuAction.copyAudioToPlaylist,
            child: Text(AppLocalizations.of(context)!.copyAudioToPlaylist),
          ),
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_menu_delete_audio'),
            value: AudioPopupMenuAction.deleteAudio,
            child: Text(AppLocalizations.of(context)!.deleteAudio),
          ),
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_menu_delete_audio_from_playlist_aswell'),
            value: AudioPopupMenuAction.deleteAudioFromPlaylistAswell,
            child: Text(
                AppLocalizations.of(context)!.deleteAudioFromPlaylistAswell),
          ),
        ];
      },
      icon: const Icon(Icons.menu),
      onSelected: (AudioPopupMenuAction value) async {
        switch (value) {
          case AudioPopupMenuAction.openYoutubeVideo:
            openUrlInExternalApp(
              url: audioGlobalPlayerVM.currentAudio!.videoUrl,
              warningMessageVM: Provider.of<WarningMessageVM>(
                context,
                listen: false,
              ),
            );
            break;
          case AudioPopupMenuAction.copyYoutubeVideoUrl:
            Clipboard.setData(ClipboardData(
                text: audioGlobalPlayerVM.currentAudio!.videoUrl));
            break;
          case AudioPopupMenuAction.displayAudioInfo:
            showDialog<void>(
              context: context,
              builder: (BuildContext context) => AudioInfoDialogWidget(
                audio: audioGlobalPlayerVM.currentAudio!,
              ),
            );
            break;
          case AudioPopupMenuAction.audioComment:
            Audio audio = audioGlobalPlayerVM.currentAudio!;
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
                      audio: audioGlobalPlayerVM.currentAudio!,
                      audioModificationType:
                          AudioModificationType.renameAudioFile,
                    ));
            break;
          case AudioPopupMenuAction.modifyAudioTitle:
            Audio audio = audioGlobalPlayerVM.currentAudio!;
            showDialog<void>(
              context: context,
              barrierDismissible:
                  false, // This line prevents the dialog from closing when
              //            tapping outside the dialog
              builder: (BuildContext context) {
                return AudioModificationDialogWidget(
                  audio: audio,
                  audioModificationType: AudioModificationType.modifyAudioTitle,
                );
              },
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
          case AudioPopupMenuAction.moveAudioToPlaylist:
            PlaylistListVM expandablePlaylistVM = Provider.of<PlaylistListVM>(
              context,
              listen: false,
            );
            Audio audio = audioGlobalPlayerVM.currentAudio!;

            showDialog<dynamic>(
              context: context,
              builder: (context) => PlaylistOneSelectableDialogWidget(
                usedFor: PlaylistOneSelectableDialogUsedFor.moveAudioToPlaylist,
                warningMessageVM: Provider.of<WarningMessageVM>(
                  context,
                  listen: false,
                ),
                excludedPlaylist: audio.enclosingPlaylist!,
              ),
            ).then((resultMap) async {
              if (resultMap is String && resultMap == 'cancel') {
                // the case if the Cancel button was pressed
                return;
              }

              Playlist? targetPlaylist = resultMap['selectedPlaylist'];

              if (targetPlaylist == null) {
                // the case if no playlist was selected and
                // Confirm button was pressed
                return;
              }

              bool keepAudioDataInSourcePlaylist =
                  resultMap['keepAudioDataInSourcePlaylist'];

              Audio? nextAudio =
                  expandablePlaylistVM.moveAudioAndCommentToPlaylist(
                audio: audio,
                targetPlaylist: targetPlaylist,
                keepAudioInSourcePlaylistDownloadedAudioLst:
                    keepAudioDataInSourcePlaylist,
              );

              // if the passed nextAudio is null, the displayed audio
              // title will be "No selected audio"
              await _replaceCurrentAudioByNextAudio(
                context: context,
                nextAudio: nextAudio,
              );
            });
            break;
          case AudioPopupMenuAction.copyAudioToPlaylist:
            PlaylistListVM expandablePlaylistVM = Provider.of<PlaylistListVM>(
              context,
              listen: false,
            );
            Audio audio = audioGlobalPlayerVM.currentAudio!;

            showDialog<dynamic>(
              context: context,
              builder: (context) => PlaylistOneSelectableDialogWidget(
                usedFor: PlaylistOneSelectableDialogUsedFor.copyAudioToPlaylist,
                warningMessageVM: Provider.of<WarningMessageVM>(
                  context,
                  listen: false,
                ),
                excludedPlaylist: audio.enclosingPlaylist!,
              ),
            ).then((resultMap) {
              if (resultMap is String && resultMap == 'cancel') {
                // the case if the Cancel button was pressed
                return;
              }

              Playlist? targetPlaylist = resultMap['selectedPlaylist'];

              if (targetPlaylist == null) {
                // the case if no playlist was selected and
                // Confirm button was pressed
                return;
              }

              expandablePlaylistVM.copyAudioToPlaylist(
                audio: audio,
                targetPlaylist: targetPlaylist,
              );
            });
            break;
          case AudioPopupMenuAction.deleteAudio:
            Audio audioToDelete = audioGlobalPlayerVM.currentAudio!;
            Audio? nextAudio;

            List<Comment> audioToDeleteCommentLst =
                Provider.of<CommentVM>(context, listen: false)
                    .loadAudioComments(audio: audioToDelete);
            if (audioToDeleteCommentLst.isNotEmpty) {
              showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmActionDialogWidget(
                    actionFunction: deleteAudio,
                    actionFunctionArgs: [
                      context,
                      audioToDelete,
                    ],
                    dialogTitle: _createDeleteAudioDialogTitle(
                      context,
                      audioToDelete,
                    ),
                    dialogContent: AppLocalizations.of(context)!
                        .confirmCommentedAudioDeletionComment(
                      audioToDeleteCommentLst.length,
                    ),
                  );
                },
              ).then((result) {
                if (result == ConfirmAction.cancel) {
                  nextAudio = audioToDelete;
                } else {
                  nextAudio = result as Audio?;
                }
              });
            } else {
              nextAudio = Provider.of<PlaylistListVM>(
                context,
                listen: false,
              ).deleteAudioFile(audio: audioToDelete);
            }

            // if the passed nextAudio is null, the displayed audio
            // title will be "No selected audio"
            await _replaceCurrentAudioByNextAudio(
              context: context,
              nextAudio: nextAudio,
            );
            break;
          case AudioPopupMenuAction.deleteAudioFromPlaylistAswell:
            Audio audio = audioGlobalPlayerVM.currentAudio!;
            Audio? nextAudio = Provider.of<PlaylistListVM>(
              context,
              listen: false,
            ).deleteAudioFromPlaylistAswell(audio: audio);

            // if the passed nextAudio is null, the displayed audio
            // title will be "No selected audio"
            await _replaceCurrentAudioByNextAudio(
              context: context,
              nextAudio: nextAudio,
            );
            break;
          default:
            break;
        }
      },
    );
  }

  Audio? deleteAudio(BuildContext context, Audio audio) {
    return Provider.of<PlaylistListVM>(
      context,
      listen: false,
    ).deleteAudioFile(audio: audio);
  }

  /// Replaces the current audio by the next audio in the audio player
  /// view. If the next audio is null, the audio title displayed in the
  /// audio player view will be "No selected audio".
  Future<void> _replaceCurrentAudioByNextAudio({
    required BuildContext context,
    required Audio? nextAudio,
  }) async {
    AudioPlayerVM audioGlobalPlayerVM = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    if (nextAudio != null) {
      // Required so that the audio title displayed in the
      // audio player view is updated with the modified title

      await audioGlobalPlayerVM.setCurrentAudio(nextAudio);
    } else {
      // Calling handleNoPlayableAudioAvailable() is necessary
      // to update the audio title in the audio player view to
      // "No selected audio"
      await audioGlobalPlayerVM.handleNoPlayableAudioAvailable();
    }
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

  String _createDeleteAudioDialogTitle(
    BuildContext context,
    Audio audioToDelete,
  ) {
    String deleteAudioDialogTitle;

    deleteAudioDialogTitle = AppLocalizations.of(context)!
        .confirmCommentedAudioDeletionTitle(audioToDelete.validVideoTitle);

    return deleteAudioDialogTitle;
  }
}
