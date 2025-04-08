import 'package:audiolearn/models/comment.dart';
import 'package:audiolearn/utils/ui_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/audio.dart';
import '../../models/playlist.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/picture_vm.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../screen_mixin.dart';
import 'battery_settings_dialog.dart';
import 'confirm_action_dialog.dart';
import 'application_settings_dialog.dart';
import 'audio_info_dialog.dart';
import 'audio_modification_dialog.dart';
import 'comment_list_add_dialog.dart';
import 'playlist_one_selectable_dialog.dart';

enum AppBarPopupMenu {
  openSettingsDialog,
  enableNextAudioAutoPlay,
  updatePlaylistJson,
  savePlaylistAndCommentsToZip,
  restorePlaylistAndCommentsFromZip,
}

/// The AppBarLeadingPopupMenuWidget is used to display the leading
/// popup menu icon of the AppBar. The displayed items are specific
/// to the currently displayed screen.
class AppBarLeftPopupMenuWidget extends StatelessWidget with ScreenMixin {
  final ThemeProviderVM themeProvider;
  final SettingsDataService settingsDataService;
  final AudioLearnAppViewType audioLearnAppViewType;

  /// The AppBarLeadingPopupMenuWidget key is defined in the parent
  /// widget, i.e. MyHomePageState instance, to facilitate the widget
  /// test.
  AppBarLeftPopupMenuWidget({
    required super.key,
    required this.audioLearnAppViewType,
    required this.themeProvider,
    required this.settingsDataService,
  });

  @override
  Widget build(BuildContext context) {
    switch (audioLearnAppViewType) {
      case AudioLearnAppViewType.playlistDownloadView:
        // The appbar left popup menu button key
        // 'appBarLeadingPopupMenuWidget' is defined
        // in the parent widget, i.e. MyHomePageState
        // instance,
        return _playListDownloadViewPopupMenuButton(context);
      case AudioLearnAppViewType.audioPlayerView:
        // The appbar left popup menu button key
        // 'appBarLeadingPopupMenuWidget' is defined
        // in the parent widget, i.e. MyHomePageState
        // instance,
        return _audioPlayerViewPopupMenuButton(
            context: context,
            commentVMlistenFalse: Provider.of<CommentVM>(
              context,
              listen: false,
            ));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _audioPlayerViewPopupMenuButton({
    required BuildContext context,
    required CommentVM commentVMlistenFalse,
  }) {
    final AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    return ValueListenableBuilder<String?>(
      // Using the currentAudioTitleNotifier is very useful in the
      // case the audio player view is opened by clicking on the
      // audio player view button when the current selected playlist
      // has audio's, but without any selected audio's. If the user
      // click on the 'No selected audio' title to open the audio
      // playable list dialog and select an available audio, without
      // using currentAudioTitleNotifier, the left appbar menu will
      // not be updated and remain empty. This problem is now solved.
      valueListenable: audioPlayerVMlistenFalse.currentAudioTitleNotifier,
      builder: (context, currentAudioTitle, child) {
        if (currentAudioTitle == null ||
            audioPlayerVMlistenFalse.currentAudio == null) {
          // No current audio set, return an empty menu
          return PopupMenuButton<AudioPopupMenuAction>(
            itemBuilder: (BuildContext context) {
              return [];
            },
            icon: const Icon(Icons.menu),
          );
        }

        final PlaylistListVM playlistListVMlistenFalse =
            Provider.of<PlaylistListVM>(
          context,
          listen: false,
        );

        final PictureVM pictureVMlistenFalse = Provider.of<PictureVM>(
          context,
          listen: false,
        );

        Audio audio = audioPlayerVMlistenFalse.currentAudio!;

        // Current audio is set, return a full menu
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
                key: const Key('appbar_popup_menu_audio_comment'),
                value: AudioPopupMenuAction.audioComment,
                child: Text(AppLocalizations.of(context)!.commentMenu),
              ),
              PopupMenuItem<AudioPopupMenuAction>(
                key: const Key('popup_menu_modify_audio_title'),
                value: AudioPopupMenuAction.modifyAudioTitle,
                child: Text(AppLocalizations.of(context)!.modifyAudioTitle),
              ),
              PopupMenuItem<AudioPopupMenuAction>(
                key: const Key('popup_menu_rename_audio_file'),
                value: AudioPopupMenuAction.renameAudioFile,
                child: Text(AppLocalizations.of(context)!.renameAudioFile),
              ),
              PopupMenuItem<AudioPopupMenuAction>(
                key: const Key('popup_menu_add_audio_picture'),
                value: AudioPopupMenuAction.addAudioPicture,
                child: Text(AppLocalizations.of(context)!.addAudioPicture),
              ),
              if (pictureVMlistenFalse.getAudioPictureFile(
                    // The remove picture menu item is only displayed if a
                    // picture file exist for the audio
                    audio: audio,
                  ) !=
                  null) ...[
                PopupMenuItem<AudioPopupMenuAction>(
                  key: const Key('popup_menu_remove_audio_picture'),
                  value: AudioPopupMenuAction.removeAudioPicture,
                  child: Text(AppLocalizations.of(context)!.removeAudioPicture),
                )
              ],
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
                child: Text(AppLocalizations.of(context)!
                    .deleteAudioFromPlaylistAswell),
              ),
              PopupMenuItem<AudioPopupMenuAction>(
                key: const Key('popup_menu_redownload_delete_audio'),
                value: AudioPopupMenuAction.redownloadDeletedAudio,
                child:
                    Text(AppLocalizations.of(context)!.redownloadDeletedAudio),
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
                Clipboard.setData(ClipboardData(
                    text: audioPlayerVMlistenFalse.currentAudio!.videoUrl));
                break;
              case AudioPopupMenuAction.displayAudioInfo:
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) => AudioInfoDialog(
                    audio: audio,
                  ),
                );
                break;
              case AudioPopupMenuAction.audioComment:
                // Using this method enables to minimize the comment list
                // add dialog.
                CommentListAddDialog.showCommentDialog(
                  context: context,
                  currentAudio: audio,
                );

                // Hides the second line play/pause button after opening
                // the comment dialog if a picture is displayed.
                commentVMlistenFalse.wasCommentDialogOpened = true;
                break;
              case AudioPopupMenuAction.modifyAudioTitle:
                await showDialog<String?>(
                  context: context,
                  barrierDismissible:
                      false, // This line prevents the dialog from closing when
                  //            tapping outside the dialog
                  builder: (BuildContext context) {
                    return AudioModificationDialog(
                      audio: audio,
                      audioModificationType:
                          AudioModificationType.modifyAudioTitle,
                    );
                  },
                ).then((String? modifiedAudioTitle) async {
                  // Required so that the audio title displayed in the
                  // audio player view is updated with the modified title
                  if (modifiedAudioTitle != null) {
                    audioPlayerVMlistenFalse.currentAudioTitleNotifier.value =
                        modifiedAudioTitle;
                  }
                });
                break;
              case AudioPopupMenuAction.renameAudioFile:
                showDialog<void>(
                  context: context,
                  barrierDismissible:
                      false, // This line prevents the dialog from closing when
                  //            tapping outside the dialog
                  builder: (BuildContext context) => AudioModificationDialog(
                    audio: audio,
                    audioModificationType:
                        AudioModificationType.renameAudioFile,
                  ),
                );
                break;
              case AudioPopupMenuAction.addAudioPicture:
                String selectedPictureFilePathName =
                    await UiUtil.filePickerSelectPictureFilePathName();

                if (selectedPictureFilePathName.isEmpty) {
                  return;
                }

                pictureVMlistenFalse.addPictureToAudio(
                  audio: audio,
                  pictureFilePathName: selectedPictureFilePathName,
                );

                // The next two lines cause the the audio picture to be
                // displayed in the audio player view. The first line is
                // necessary so that currentAudioTitleNotifier will update
                // the audio title displayed in the audio player view,
                // which will cause the audio picture to be displayed.

                audioPlayerVMlistenFalse.currentAudioTitleNotifier.value = '';
                audioPlayerVMlistenFalse.currentAudioTitleNotifier.value =
                    audioPlayerVMlistenFalse.getCurrentAudioTitleWithDuration();
                break;
              case AudioPopupMenuAction.removeAudioPicture:
                pictureVMlistenFalse.removeAudioPicture(
                  audio: audio,
                );

                // The next two lines cause the the audio picture to be
                // displayed in the audio player view. The first line is
                // necessary so that currentAudioTitleNotifier will update
                // the audio title displayed in the audio player view,
                // which will cause the audio picture to be displayed.

                audioPlayerVMlistenFalse.currentAudioTitleNotifier.value = '';
                audioPlayerVMlistenFalse.currentAudioTitleNotifier.value =
                    audioPlayerVMlistenFalse.getCurrentAudioTitleWithDuration();
                break;
              case AudioPopupMenuAction.moveAudioToPlaylist:
                PlaylistListVM playlistVMlistnedFalse =
                    Provider.of<PlaylistListVM>(
                  context,
                  listen: false,
                );
                Audio audio = audioPlayerVMlistenFalse.currentAudio!;

                showDialog<dynamic>(
                  context: context,
                  builder: (context) => PlaylistOneSelectableDialog(
                    usedFor: PlaylistOneSelectableDialogUsedFor
                        .moveSingleAudioToPlaylist,
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
                  Audio? nextAudio = playlistVMlistnedFalse
                      .moveAudioAndCommentAndPictureToPlaylist(
                    audioLearnAppViewType:
                        AudioLearnAppViewType.audioPlayerView,
                    audio: audio,
                    targetPlaylist: targetPlaylist,
                    keepAudioInSourcePlaylistDownloadedAudioLst:
                        keepAudioDataInSourcePlaylist,
                    audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
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
                PlaylistListVM playlistVMlistenFalse =
                    Provider.of<PlaylistListVM>(
                  context,
                  listen: false,
                );
                Audio audio = audioPlayerVMlistenFalse.currentAudio!;

                showDialog<dynamic>(
                  context: context,
                  builder: (context) => PlaylistOneSelectableDialog(
                    usedFor: PlaylistOneSelectableDialogUsedFor
                        .copySingleAudioToPlaylist,
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

                  playlistVMlistenFalse.copyAudioAndCommentAndPictureToPlaylist(
                    audio: audio,
                    targetPlaylist: targetPlaylist,
                  );
                });
                break;
              case AudioPopupMenuAction.deleteAudio:
                final Audio audioToDelete =
                    audioPlayerVMlistenFalse.currentAudio!;

                if (!audioToDelete.isPaused) {
                  audioPlayerVMlistenFalse.pause();
                }

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
                  // If the audio has comments, the ConfirmActionDialog is
                  // displayed. Otherwise, the audio is deleted from the
                  // playlist playable audio list.
                  //
                  // Await must be applied to showDialog() so that the nextAudio
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
                        dialogTitleOne: _createDeleteAudioDialogTitle(
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
                  nextAudio = playlistListVMlistenFalse.deleteAudioFile(
                    audioLearnAppViewType:
                        AudioLearnAppViewType.audioPlayerView,
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
                        dialogTitleOne: _createDeleteAudioDialogTitle(
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
                  nextAudio =
                      playlistListVMlistenFalse.deleteAudioFromPlaylistAsWell(
                    audioLearnAppViewType:
                        AudioLearnAppViewType.audioPlayerView,
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
              case AudioPopupMenuAction.redownloadDeletedAudio:
                // You cannot await here, but you can trigger an
                // action which will not block the widget tree
                // rendering.
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  int redownloadAudioNumber =
                      await playlistListVMlistenFalse.redownloadDeletedAudio(
                    audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                    audio: audio,
                  );

                  if (redownloadAudioNumber != -1) {
                    // The audio was redownloaded or not
                    Provider.of<WarningMessageVM>(
                      context,
                      listen: false,
                    ).redownloadAudioConfirmation(
                      targetPlaylistTitle: audio.enclosingPlaylist!.title,
                      redownloadAudioTitle: audio.validVideoTitle,
                      redownloadAudioNumber: redownloadAudioNumber,
                    );
                  } // else -1 is returned, since no confirmation warning
                  //   is displayed, the no internet or
                  //   downloadAudioYoutubeError warning thrown by
                  //   AudioDownloadVM.notifyDownloadError() can be displayed.
                });
                break;
            }
          },
        );
      },
    );
  }

  /// Public method passed to the ConfirmActionDialog to be executd
  /// when the Confirm button is pressed. The method deletes the audio
  /// file and its comments.
  Audio? deleteAudio(
    BuildContext context,
    Audio audio,
  ) {
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
    AudioPlayerVM audioPlayerVMlistenedFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    if (nextAudio != null) {
      // Required so that the audio title displayed in the
      // audio player view is updated with the modified title.
      await audioPlayerVMlistenedFalse.setCurrentAudio(
        audio: nextAudio,
      );
    } else {
      // Calling handleNoPlayableAudioAvailable() is necessary
      // to update the audio title in the audio player view to
      // "No selected audio"
      await audioPlayerVMlistenedFalse.handleNoPlayableAudioAvailable();
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
            key: const Key('appBarMenuEnableNextAudioAutoPlay'),
            value: AppBarPopupMenu.enableNextAudioAutoPlay,
            child: Text(AppLocalizations.of(context)!
                .appBarMenuEnableNextAudioAutoPlay),
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
          PopupMenuItem<AppBarPopupMenu>(
            key: const Key(
                'appBarMenuRestorePlaylistsCommentsAndSettingsFromZip'),
            value: AppBarPopupMenu.restorePlaylistAndCommentsFromZip,
            child: Tooltip(
              message: AppLocalizations.of(context)!
                  .restorePlaylistAndCommentsFromZipTooltip,
              child: Text(AppLocalizations.of(context)!
                  .restorePlaylistAndCommentsFromZipMenu),
            ),
          ),
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
          case AppBarPopupMenu.enableNextAudioAutoPlay:
            showDialog<void>(
              context: context,
              barrierDismissible: false, // This line prevents the dialog from
              // closing when tapping outside the dialog
              builder: (BuildContext context) {
                return BatterySettingsDialog();
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
            await UiUtil.savePlaylistsCommentsAndAppSettingsToZip(
              context: context,
            );
            break;
          case AppBarPopupMenu.restorePlaylistAndCommentsFromZip:
            await UiUtil.restorePlaylistsCommentsAndAppSettingsFromZip(
              context: context,
            );
            break;
        }
      },
    );
  }
}
