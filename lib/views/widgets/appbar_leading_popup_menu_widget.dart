import 'package:audiolearn/models/comment.dart';
import 'package:file_picker/file_picker.dart';
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
import 'confirm_action_dialog.dart';
import 'application_settings_dialog.dart';
import 'audio_info_dialog.dart';
import 'audio_modification_dialog.dart';
import 'comment_list_add_dialog.dart';
import 'playlist_one_selectable_dialog.dart';

enum AppBarPopupMenu {
  openSettingsDialog,
  updatePlaylistJson,
  savePlaylistAndCommentsToZip,
  setYoutubeChannel,
}

/// The AppBarLeadingPopupMenuWidget is used to display the leading
/// popup menu icon of the AppBar. The displayed items are specific
/// to the currently displayed screen.
class AppBarLeadingPopupMenuWidget extends StatelessWidget with ScreenMixin {
  final ThemeProviderVM themeProvider;
  final SettingsDataService settingsDataService;
  final AudioLearnAppViewType audioLearnAppViewType;

  /// The AppBarLeadingPopupMenuWidget key is defined in the parent
  /// widget, i.e. MyHomePageState instance, to facilitate the widget
  /// test.
  AppBarLeadingPopupMenuWidget({
    required super.key,
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
    AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    if (audioPlayerVMlistenFalse.currentAudio == null) {
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
              url: audioPlayerVMlistenFalse.currentAudio!.videoUrl,
              warningMessageVM: Provider.of<WarningMessageVM>(
                context,
                listen: false,
              ),
            );
            break;
          case AudioPopupMenuAction.copyYoutubeVideoUrl:
            Clipboard.setData(ClipboardData(
                text: audioPlayerVMlistenFalse.currentAudio!.videoUrl));
            break;
          case AudioPopupMenuAction.displayAudioInfo:
            showDialog<void>(
              context: context,
              builder: (BuildContext context) => AudioInfoDialog(
                audio: audioPlayerVMlistenFalse.currentAudio!,
              ),
            );
            break;
          case AudioPopupMenuAction.audioComment:
            Audio audio = audioPlayerVMlistenFalse.currentAudio!;
            audioPlayerVMlistenFalse
                .setCurrentAudio(
              audio: audio,
            )
                .then((value) {
              showDialog<void>(
                context: context,
                // passing the current audio to the dialog instead
                // of initializing a private _currentAudio variable
                // in the dialog avoid integr test problems
                builder: (context) => CommentListAddDialog(
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
                builder: (BuildContext context) => AudioModificationDialog(
                      audio: audioPlayerVMlistenFalse.currentAudio!,
                      audioModificationType:
                          AudioModificationType.renameAudioFile,
                    ));
            break;
          case AudioPopupMenuAction.modifyAudioTitle:
            Audio audio = audioPlayerVMlistenFalse.currentAudio!;
            showDialog<void>(
              context: context,
              barrierDismissible:
                  false, // This line prevents the dialog from closing when
              //            tapping outside the dialog
              builder: (BuildContext context) {
                return AudioModificationDialog(
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
              await audioGlobalPlayerVM.setCurrentAudio(
                audio: audio,
              );
            });
            break;
          case AudioPopupMenuAction.moveAudioToPlaylist:
            PlaylistListVM playlistVMlistnedFalse = Provider.of<PlaylistListVM>(
              context,
              listen: false,
            );
            Audio audio = audioPlayerVMlistenFalse.currentAudio!;

            showDialog<dynamic>(
              context: context,
              builder: (context) => PlaylistOneSelectableDialog(
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
                // the case if no playlist was selected and Confirm button was
                // pressed. In this case, the PlaylistOneSelectableDialog
                // uses the WarningMessageVM to display the right warning
                return;
              }

              bool keepAudioDataInSourcePlaylist =
                  resultMap['keepAudioDataInSourcePlaylist'];
              Audio? nextAudio =
                  playlistVMlistnedFalse.moveAudioAndCommentToPlaylist(
                audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
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
            Audio audio = audioPlayerVMlistenFalse.currentAudio!;

            showDialog<dynamic>(
              context: context,
              builder: (context) => PlaylistOneSelectableDialog(
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

              expandablePlaylistVM.copyAudioAndCommentToPlaylist(
                audio: audio,
                targetPlaylist: targetPlaylist,
              );
            });
            break;
          case AudioPopupMenuAction.deleteAudio:
            Audio audioToDelete = audioPlayerVMlistenFalse.currentAudio!;
            Audio? nextAudio;

            List<Comment> audioToDeleteCommentLst =
                Provider.of<CommentVM>(context, listen: false)
                    .loadAudioComments(audio: audioToDelete);
            if (audioToDeleteCommentLst.isNotEmpty) {
              // await must be applied to showDialog() so that the nextAudio
              // variable is assigned according to the result returned by the
              // dialog. Otherwise, _replaceCurrentAudioByNextAudio() will be
              // called before the dialog is closed and the nextAudio variable
              // will be null, which will result in the audio title displayed
              // in the audio player view to be "No selected audio" !
              await showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmActionDialog(
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
              ).deleteAudioFile(
                audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
                audio: audioToDelete,
              );
            }

            // if the passed nextAudio is null, the displayed audio
            // title will be "No selected audio"
            await _replaceCurrentAudioByNextAudio(
              context: context,
              nextAudio: nextAudio,
            );
            break;
          case AudioPopupMenuAction.deleteAudioFromPlaylistAswell:
            Audio audioToDelete = audioPlayerVMlistenFalse.currentAudio!;
            Audio? nextAudio;
            final PlaylistListVM playlistListVMlistenFalse =
                Provider.of<PlaylistListVM>(
              context,
              listen: false,
            );

            final List<Comment> audioToDeleteCommentLst =
                playlistListVMlistenFalse.getAudioComments(
              audio: audioToDelete,
            );

            if (audioToDeleteCommentLst.isNotEmpty) {
              // await must be applied to showDialog() so that the nextAudio
              // variable is assigned according to the result returned by the
              // dialog. Otherwise, _replaceCurrentAudioByNextAudio() will be
              // called before the dialog is closed and the nextAudio variable
              // will be null, which will result in the audio title displayed
              // in the audio player view to be "No selected audio" !
              //
              // If the audio has comments, the ConfirmActionDialog is
              // displayed. Otherwise, the audio is deleted from the
              // playlist download and playable audio list.
              await showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmActionDialog(
                    actionFunction: deleteAudioFromPlaylistAsWell,
                    actionFunctionArgs: [
                      playlistListVMlistenFalse,
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
              ).deleteAudioFromPlaylistAsWell(
                audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
                audio: audioToDelete,
              );
            }

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

  /// Public method passed to the ConfirmActionDialog to be executd
  /// when the Confirm button is pressed. The method deletes the audio
  /// file and its comments.
  Audio? deleteAudio(BuildContext context, Audio audio) {
    return Provider.of<PlaylistListVM>(
      context,
      listen: false,
    ).deleteAudioFile(
      audioLearnAppViewType: AudioLearnAppViewType.audioPlayerView,
      audio: audio,
    );
  }

  /// Public method passed to the ConfirmActionDialog to be executd
  /// when the Confirm button is pressed. The method deletes the audio
  /// file and its comments as well as the audio reference in the playlist
  /// json file.
  Audio? deleteAudioFromPlaylistAsWell(
    PlaylistListVM playlistListVMlistenFalse,
    Audio audio,
  ) {
    return playlistListVMlistenFalse.deleteAudioFromPlaylistAsWell(
      audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
      audio: audio,
    );
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
      // audio player view is updated with the modified title.
      //
      // doNotifyListeners is set to false to avoid that the
      // Confirm warning is displayed twice when the audio
      // moved to another playlist.
      await audioGlobalPlayerVM.setCurrentAudio(
        audio: nextAudio,
        doNotifyListeners: false,
      );
    } else {
      // Calling handleNoPlayableAudioAvailable() is necessary
      // to update the audio title in the audio player view to
      // "No selected audio"
      await audioGlobalPlayerVM.handleNoPlayableAudioAvailable();
    }
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
          PopupMenuItem<AppBarPopupMenu>(
            key: const Key('update_playlist_json_dialog_item'),
            value: AppBarPopupMenu.updatePlaylistJson,
            child: Tooltip(
              message: AppLocalizations.of(context)!
                  .updatePlaylistJsonFilesMenuTooltip,
              child: Text(
                  AppLocalizations.of(context)!.updatePlaylistJsonFilesMenu),
            ),
          ),
          PopupMenuItem<AppBarPopupMenu>(
            key: const Key('appBarMenuCopyPlaylistsAndCommentsToZip'),
            value: AppBarPopupMenu.savePlaylistAndCommentsToZip,
            child: Tooltip(
              message: AppLocalizations.of(context)!
                  .savePlaylistAndCommentsToZipTooltip,
              child: Text(AppLocalizations.of(context)!
                  .savePlaylistAndCommentsToZipMenu),
            ),
          ),
          // This functionality is no longer used since now the Youtube channel
          // is set when the audio is downloaded from the Youtube playlist.
          //
          // PopupMenuItem<AppBarPopupMenu>(
          //   key: const Key('setYoutubeChannel'),
          //   value: AppBarPopupMenu.setYoutubeChannel,
          //   child: Text(AppLocalizations.of(context)!
          //       .setYoutubeChannelMenu),
          // ),
        ];
      },
      icon: const Icon(Icons.menu),
      onSelected: (AppBarPopupMenu value) async {
        switch (value) {
          case AppBarPopupMenu.openSettingsDialog:
            showDialog<void>(
              context: context,
              barrierDismissible: false, // This line prevents the dialog from
              // closing when tapping outside the dialog
              builder: (BuildContext context) {
                return ApplicationSettingsDialog(
                  settingsDataService: settingsDataService,
                );
              },
            );
            break;
          case AppBarPopupMenu.updatePlaylistJson:
            Provider.of<PlaylistListVM>(
              context,
              listen: false,
            ).updateSettingsAndPlaylistJsonFiles();
            break;
          case AppBarPopupMenu.savePlaylistAndCommentsToZip:
            String? selectedFilePathNameLst =
                await _filePickerSelectTargetDir();

            if (selectedFilePathNameLst == null) {
              return;
            }

            await Provider.of<PlaylistListVM>(
              context,
              listen: false,
            ).savePlaylistsCommentsAndSettingsJsonFilesToZip(
              targetDirectoryPath: selectedFilePathNameLst,
            );
            break;
          // case AppBarPopupMenu.setYoutubeChannel:
          //
          // This functionality is no longer used since now the Youtube channel
          // is set when the audio is downloaded from the Youtube playlist.
          //
          //   await Provider.of<AudioDownloadVM>(
          //     context,
          //     listen: false,
          //   ).ensureAllAudioYoutubeChannelOfAllPlaylistsAreSet();
          //   break;
          default:
            break;
        }
      },
    );
  }

  Future<String?> _filePickerSelectTargetDir() async {
    return await FilePicker.platform.getDirectoryPath();
  }
}
