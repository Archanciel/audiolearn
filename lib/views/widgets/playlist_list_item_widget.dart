import 'package:audiolearn/constants.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/help_item.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import 'application_snackbar.dart';
import 'confirm_action_dialog_widget.dart';
import 'playlist_comment_list_add_dialog_widget.dart';
import 'playlist_info_dialog_widget.dart';
import 'audio_set_speed_dialog_widget.dart';

enum PlaylistPopupMenuAction {
  openYoutubePlaylist,
  copyYoutubePlaylistUrl,
  displayPlaylistInfo,
  displayPlaylistAudioComments,
  importAudioFilesInPlaylist,
  updatePlaylistPlayableAudios, // useful if playlist audio files were
  //                               deleted from the app dir
  setPlaylistAudioPlaySpeed,
  deletePlaylist,
}

/// This widget is used to display a playlist in the
/// PlaylistDownloadView list of playlists. At left of the
/// playlist title, a menu button is displayed with menu items
/// created by this class. At right of the playlist title, a
/// checkbox is displayed to select the playlist.
class PlaylistListItemWidget extends StatelessWidget with ScreenMixin {
  final SettingsDataService settingsDataService;
  final Playlist playlist;
  final int index;
  final bool toggleListIfSelected;

  PlaylistListItemWidget({
    required this.settingsDataService,
    required this.playlist,
    required this.index,
    this.toggleListIfSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<HelpItem> helpItemsLst = [
      HelpItem(
        helpTitle: AppLocalizations.of(context)!
            .alreadyDownloadedAudiosPlaylistHelpTitle,
        helpContent: AppLocalizations.of(context)!
            .alreadyDownloadedAudiosPlaylistHelpContent,
      ),
    ];
    final WarningMessageVM warningMessageVM =
        Provider.of<WarningMessageVM>(context, listen: false);

    return Consumer2<PlaylistListVM, AudioPlayerVM>(
      builder: (context, playlistListVM, audioPlayerVM, child) {
        return ListTile(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              final RenderBox listTileBox =
                  context.findRenderObject() as RenderBox;
              final Offset listTilePosition =
                  listTileBox.localToGlobal(Offset.zero);
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  listTilePosition.dx - listTileBox.size.width,
                  listTilePosition.dy,
                  0,
                  0,
                ),
                items: [
                  if (playlist.playlistType == PlaylistType.youtube) ...[
                    PopupMenuItem<PlaylistPopupMenuAction>(
                      key: const Key('popup_menu_open_youtube_playlist'),
                      value: PlaylistPopupMenuAction.openYoutubePlaylist,
                      child: Text(
                          AppLocalizations.of(context)?.openYoutubePlaylist ??
                              'Open YouTube Playlist'),
                    ),
                    PopupMenuItem<PlaylistPopupMenuAction>(
                      key: const Key('popup_copy_youtube_video_url'),
                      value: PlaylistPopupMenuAction.copyYoutubePlaylistUrl,
                      child: Text(AppLocalizations.of(context)
                              ?.copyYoutubePlaylistUrl ??
                          'Copy YouTube Playlist URL'),
                    ),
                  ],
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_menu_display_playlist_info'),
                    value: PlaylistPopupMenuAction.displayPlaylistInfo,
                    child:
                        Text(AppLocalizations.of(context)!.displayPlaylistInfo),
                  ),
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_menu_playlist_audio_comments'),
                    value: PlaylistPopupMenuAction.displayPlaylistAudioComments,
                    child:
                        Text(AppLocalizations.of(context)!.playlistCommentMenu),
                  ),
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_menu_import_audio_in_playlist'),
                    value: PlaylistPopupMenuAction.importAudioFilesInPlaylist,
                    child: Tooltip(
                      message: AppLocalizations.of(context)!
                          .playlistImportAudioMenuTooltip,
                      child: Text(AppLocalizations.of(context)!
                          .playlistImportAudioMenu),
                    ),
                  ),
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_menu_update_playable_audio_list'),
                    value: PlaylistPopupMenuAction.updatePlaylistPlayableAudios,
                    child: Tooltip(
                      message: AppLocalizations.of(context)!
                          .updatePlaylistPlayableAudioListTooltip,
                      child: Text(AppLocalizations.of(context)!
                          .updatePlaylistPlayableAudioList),
                    ),
                  ),
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_menu_set_audio_play_speed'),
                    value: PlaylistPopupMenuAction.setPlaylistAudioPlaySpeed,
                    child: Tooltip(
                      message: AppLocalizations.of(context)!
                          .setPlaylistAudioPlaySpeedTooltip,
                      child:
                          Text(AppLocalizations.of(context)!.setAudioPlaySpeed),
                    ),
                  ),
                  PopupMenuItem<PlaylistPopupMenuAction>(
                    key: const Key('popup_menu_delete_playlist'),
                    value: PlaylistPopupMenuAction.deletePlaylist,
                    child: Text(AppLocalizations.of(context)!.deletePlaylist),
                  ),
                ],
                elevation: 8,
              ).then((value) async {
                if (value != null) {
                  switch (value) {
                    case PlaylistPopupMenuAction.openYoutubePlaylist:
                      openUrlInExternalApp(
                        url: playlist.url,
                        warningMessageVM: warningMessageVM,
                      );
                      break;
                    case PlaylistPopupMenuAction.copyYoutubePlaylistUrl:
                      Clipboard.setData(ClipboardData(text: playlist.url));
                      break;
                    case PlaylistPopupMenuAction.displayPlaylistInfo:
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return PlaylistInfoDialogWidget(
                            settingsDataService: settingsDataService,
                            playlist: playlist,
                            playlistJsonFileSize: playlistListVM
                                .getPlaylistJsonFileSize(playlist: playlist),
                          );
                        },
                      );
                      break;
                    case PlaylistPopupMenuAction.displayPlaylistAudioComments:
                      if (playlistListVM.getSelectedPlaylists()[0] !=
                          playlist) {
                        // the case if the user opens the playlist audio
                        // comment dialog on a playlist which is not currently
                        // selected
                        playlistListVM.setPlaylistSelection(
                          playlistIndex: index,
                          isPlaylistSelected: true,
                        );
                        String snackBarMessage = AppLocalizations.of(context)!
                            .playlistSelectedSnackBarMessage(playlist.title);
                        ScaffoldMessenger.of(context).showSnackBar(
                          ApplicationSnackBar(
                            message: snackBarMessage,
                          ),
                        );
                      }
                      showDialog<void>(
                        context: context,
                        // passing the current audio to the dialog instead
                        // of initializing a private _currentAudio variable
                        // in the dialog avoid integr test problems
                        builder: (context) =>
                            PlaylistCommentListAddDialogWidget(
                          currentPlaylist: playlist,
                        ),
                      );
                      break;
                    case PlaylistPopupMenuAction.importAudioFilesInPlaylist:
                      List<String> selectedFilePathNameLst =
                          await _filePickerSelectAudioFiles();

                      AudioDownloadVM audioDownloadVM =
                          Provider.of<AudioDownloadVM>(context, listen: false);

                      audioDownloadVM.importFilesInPlaylist(
                        targetPlaylist: playlist,
                        filePathNameToImportLst: selectedFilePathNameLst,
                      );
                      break;
                    case PlaylistPopupMenuAction.updatePlaylistPlayableAudios:
                      int removedPlayableAudioNumber =
                          playlistListVM.updatePlayableAudioLst(
                        playlist: playlist,
                      );

                      if (removedPlayableAudioNumber > 0) {
                        warningMessageVM
                            .setUpdatedPlayableAudioLstPlaylistTitle(
                                updatedPlayableAudioLstPlaylistTitle:
                                    playlist.title,
                                removedPlayableAudioNumber:
                                    removedPlayableAudioNumber);
                      }
                      break;
                    case PlaylistPopupMenuAction.setPlaylistAudioPlaySpeed:
                      showDialog<List<dynamic>>(
                        context: context,
                        builder: (BuildContext context) {
                          double playlistAudioPlaySpeed = (playlist
                                      .audioPlaySpeed !=
                                  0)
                              ? playlist
                                  .audioPlaySpeed // audio play speed is defined for the playlist
                              : settingsDataService.get(
                                      // get default audio play speed
                                      settingType: SettingType.playlists,
                                      settingSubType: Playlists.playSpeed) ??
                                  kAudioDefaultPlaySpeed;
                          return AudioSetSpeedDialogWidget(
                            audioPlaySpeed: playlistAudioPlaySpeed,
                            updateCurrentPlayAudioSpeed: false,
                            displayApplyToAudioAlreadyDownloadedCheckbox: true,
                            helpItemsLst: helpItemsLst,
                          );
                        },
                      ).then((value) {
                        // not null value is boolean
                        if (value != null) {
                          // value is null if clicking on Cancel or if the dialog
                          // is dismissed by clicking outside the dialog.

                          playlistListVM
                              .updateIndividualPlaylistAndOrPlaylistAudiosPlaySpeed(
                            audioPlaySpeed: value[0] as double,
                            playlistIndex: index,
                            applyAudioPlaySpeedToPlayableAudios:
                                value[2] as bool,
                          );
                        }
                      });
                      break;
                    case PlaylistPopupMenuAction.deletePlaylist:
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmActionDialogWidget(
                            actionFunction: deletePlaylist,
                            actionFunctionArgs: [
                              playlistListVM,
                              playlist,
                            ],
                            dialogTitle:
                                _createDeletePlaylistDialogTitle(context),
                            dialogContent: AppLocalizations.of(context)!
                                .deletePlaylistDialogComment,
                          );
                        },
                      );
                      break;
                    default:
                      break;
                  }
                }
              });
            },
          ),
          title: Text(playlist.title),
          trailing: Checkbox(
            value: playlist.isSelected,
            onChanged: (value) async {
              if (toggleListIfSelected) {
                playlistListVM.toggleList();
              }
              playlistListVM.setPlaylistSelection(
                playlistIndex: index,
                isPlaylistSelected: value!,
              );
              await audioPlayerVM.setCurrentAudioFromSelectedPlaylist();
            },
          ),
        );
      },
    );
  }

  /// Public method passed as parameter to the ActionConfirmDialogWidget
  /// which, in this case, asks the user to confirm the deletion of a
  /// playlist. This method is called when the user clicks on the
  /// 'Confirm' button.
  void deletePlaylist(
    PlaylistListVM playlistListVM,
    Playlist playlistToDelete,
  ) {
    playlistListVM.deletePlaylist(
      playlistToDelete: playlistToDelete,
    );
  }

  String _createDeletePlaylistDialogTitle(
    BuildContext context,
  ) {
    String deletePlaylistDialogTitle;

    if (playlist.url.isNotEmpty) {
      deletePlaylistDialogTitle = AppLocalizations.of(context)!
          .deleteYoutubePlaylistDialogTitle(playlist.title);
    } else {
      deletePlaylistDialogTitle = AppLocalizations.of(context)!
          .deleteLocalPlaylistDialogTitle(playlist.title);
    }

    return deletePlaylistDialogTitle;
  }

  Future<List<String>> _filePickerSelectAudioFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      allowMultiple: true,
      initialDirectory: await DirUtil.getApplicationPath(),
    );

    if (result != null) {
      return result.files.map((file) => file.path!).toList();
    }

    return [];
  }
}
