import 'package:audiolearn/constants.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/utils/ui_util.dart';
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
import '../../utils/date_time_util.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import 'application_snackbar.dart';
import 'confirm_action_dialog.dart';
import 'playlist_comment_list_dialog.dart';
import 'playlist_info_dialog.dart';
import 'audio_set_speed_dialog.dart';
import 'playlist_one_selectable_dialog.dart';

enum PlaylistPopupMenuAction {
  openYoutubePlaylist,
  copyYoutubePlaylistUrl,
  displayPlaylistInfo,
  displayPlaylistAudioComments,
  importAudioFilesInPlaylist,
  downloadVideoUrlsFromTextFileInPlaylist,
  updatePlaylistPlayableAudios, // useful if playlist audio files were
  //                               deleted from the app dir
  rewindAudioToStart,
  setPlaylistAudioPlaySpeed,
  filteredAudioActions,
  deletePlaylist,
}

enum FilteredAudioAction {
  deleteFilteredAudio,
  moveFilteredAudio,
  copyFilteredAudio,
}

/// This widget is used to display a playlist in the
/// PlaylistDownloadView list of playlists. At left of the
/// playlist title, a menu button is displayed with menu items
/// created by this class. At right of the playlist title, a
/// checkbox is displayed to select the playlist.
class PlaylistListItem extends StatelessWidget with ScreenMixin {
  final SettingsDataService settingsDataService;
  final Playlist playlist;

  // If true, the playlist list is toggled (i.e. reduced) if a playlist is
  // selected. This makes sense only in the audio player view where the
  // user can click on the toggle playlist list button in order to display
  // the selectable playlist. Once a playlist is selected, the playlist list
  // is toggled (reduced) to make space for the audio player widget.
  final bool toggleListIfSelected;

  PlaylistListItem({
    required this.settingsDataService,
    required this.playlist,
    this.toggleListIfSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final WarningMessageVM warningMessageVMlistenFalse =
        Provider.of<WarningMessageVM>(
      context,
      listen: false,
    );

    return Consumer2<PlaylistListVM, AudioPlayerVM>(
      builder: (
        context,
        playlistListVMlistenTrue,
        audioPlayerVMlistenTrue,
        child,
      ) {
        return ListTile(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _buildPlaylistItemMenu(
                context: context,
                playlistListVMlistenTrue: playlistListVMlistenTrue,
                audioPlayerVMlistenTrue: audioPlayerVMlistenTrue,
                warningMessageVMlistenFalse: warningMessageVMlistenFalse,
              );
            },
          ),
          title: Text(playlist.title),
          trailing: Checkbox(
            key: const Key('playlist_checkbox_key'),
            value: playlist.isSelected,
            onChanged: (value) async {
              if (toggleListIfSelected) {
                // true in the audio player view. If a playlist is
                // selected, the playlist list is toggled (reduced)
                // and the new selected playlist current listenable
                // audio is set in the audio player view.
                playlistListVMlistenTrue.togglePlaylistsList();
              }
              playlistListVMlistenTrue.setPlaylistSelection(
                playlistSelectedOrUnselected: playlist,
                isPlaylistSelected: value!,
              );
              await audioPlayerVMlistenTrue
                  .setCurrentAudioFromSelectedPlaylist();
            },
          ),
        );
      },
    );
  }

  void _buildPlaylistItemMenu({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenTrue,
    required AudioPlayerVM audioPlayerVMlistenTrue,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    final RenderBox listTileBox = context.findRenderObject() as RenderBox;
    final Offset listTilePosition = listTileBox.localToGlobal(Offset.zero);

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
            child: Text(AppLocalizations.of(context)?.openYoutubePlaylist ??
                'Open YouTube Playlist'),
          ),
          PopupMenuItem<PlaylistPopupMenuAction>(
            key: const Key('popup_copy_youtube_video_url'),
            value: PlaylistPopupMenuAction.copyYoutubePlaylistUrl,
            child: Text(AppLocalizations.of(context)?.copyYoutubePlaylistUrl ??
                'Copy YouTube Playlist URL'),
          ),
        ],
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_display_playlist_info'),
          value: PlaylistPopupMenuAction.displayPlaylistInfo,
          child: Text(AppLocalizations.of(context)!.displayPlaylistInfo),
        ),
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_display_playlist_audio_comments'),
          value: PlaylistPopupMenuAction.displayPlaylistAudioComments,
          child: Text(AppLocalizations.of(context)!.playlistCommentMenu),
        ),
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_import_audio_in_playlist'),
          value: PlaylistPopupMenuAction.importAudioFilesInPlaylist,
          child: Tooltip(
            message:
                AppLocalizations.of(context)!.playlistImportAudioMenuTooltip,
            child: Text(AppLocalizations.of(context)!.playlistImportAudioMenu),
          ),
        ),
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_download_video_urls_in_playlist'),
          value:
              PlaylistPopupMenuAction.downloadVideoUrlsFromTextFileInPlaylist,
          child: Tooltip(
            message: AppLocalizations.of(context)!
                .downloadVideoUrlsFromTextFileInPlaylistTooltip,
            child: Text(AppLocalizations.of(context)!
                .downloadVideoUrlsFromTextFileInPlaylist),
          ),
        ),
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_update_playable_audio_list'),
          value: PlaylistPopupMenuAction.updatePlaylistPlayableAudios,
          child: Tooltip(
            message: AppLocalizations.of(context)!
                .updatePlaylistPlayableAudioListTooltip,
            child: Text(
                AppLocalizations.of(context)!.updatePlaylistPlayableAudioList),
          ),
        ),
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_rewind_audio_to_start'),
          value: PlaylistPopupMenuAction.rewindAudioToStart,
          child: Tooltip(
            message: AppLocalizations.of(context)!.rewindAudioToStartTooltip,
            child: Text(AppLocalizations.of(context)!.rewindAudioToStart),
          ),
        ),
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_set_audio_play_speed'),
          value: PlaylistPopupMenuAction.setPlaylistAudioPlaySpeed,
          child: Tooltip(
            message:
                AppLocalizations.of(context)!.setPlaylistAudioPlaySpeedTooltip,
            child: Text(AppLocalizations.of(context)!.setAudioPlaySpeed),
          ),
        ),
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_filtered_audio_actions'),
          value: PlaylistPopupMenuAction.filteredAudioActions,
          child: Text(AppLocalizations.of(context)!.filteredAudioActions),
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
              warningMessageVM: warningMessageVMlistenFalse,
            );
            break;
          case PlaylistPopupMenuAction.copyYoutubePlaylistUrl:
            Clipboard.setData(ClipboardData(text: playlist.url));
            break;
          case PlaylistPopupMenuAction.displayPlaylistInfo:
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return PlaylistInfoDialog(
                  settingsDataService: settingsDataService,
                  playlist: playlist,
                  playlistJsonFileSize: playlistListVMlistenTrue
                      .getPlaylistJsonFileSize(playlist: playlist),
                );
              },
            );
            break;
          case PlaylistPopupMenuAction.displayPlaylistAudioComments:
            if (playlistListVMlistenTrue.getSelectedPlaylists().isEmpty ||
                playlistListVMlistenTrue.getSelectedPlaylists()[0] !=
                    playlist) {
              // the case if the user opens the playlist audio
              // comment dialog on a playlist which is not currently
              // selected
              playlistListVMlistenTrue.setPlaylistSelection(
                playlistSelectedOrUnselected: playlist,
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
              builder: (context) => PlaylistCommentListDialog(
                currentPlaylist: playlist,
              ),
            );
            break;
          case PlaylistPopupMenuAction.importAudioFilesInPlaylist:
            List<String> selectedFilePathNameLst =
                await _filePickerSelectAudioFiles();

            AudioDownloadVM audioDownloadVM = Provider.of<AudioDownloadVM>(
              context,
              listen: false,
            );

            audioDownloadVM.importAudioFilesInPlaylist(
              targetPlaylist: playlist,
              filePathNameToImportLst: selectedFilePathNameLst,
            );
            break;
          case PlaylistPopupMenuAction.downloadVideoUrlsFromTextFileInPlaylist:
            String selectedFilePathName =
                await _filePickerSelectVideoUrlsTextFile();

            List<String> videoUrls =
                DirUtil.readUrlsFromFile(selectedFilePathName);

            AudioDownloadVM audioDownloadVM = Provider.of<AudioDownloadVM>(
              context,
              listen: false,
            );

            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return ConfirmActionDialog(
                  actionFunction:
                      downloadAudioFromVideoUrlsContainedInTextFileToPlaylist,
                  actionFunctionArgs: [
                    audioDownloadVM,
                    warningMessageVMlistenFalse,
                    playlist,
                    videoUrls,
                  ],
                  dialogTitleOne: AppLocalizations.of(context)!
                      .downloadAudioFromVideoUrlsInPlaylistTitle(
                          playlist.title),
                  dialogContent: AppLocalizations.of(context)!
                      .downloadAudioFromVideoUrlsInPlaylist(
                          videoUrls.length.toString()),
                );
              },
            );
            break;
          case PlaylistPopupMenuAction.updatePlaylistPlayableAudios:
            int removedPlayableAudioNumber =
                playlistListVMlistenTrue.updatePlayableAudioLst(
              playlist: playlist,
            );

            if (removedPlayableAudioNumber > 0) {
              warningMessageVMlistenFalse
                  .setUpdatedPlayableAudioLstPlaylistTitle(
                      updatedPlayableAudioLstPlaylistTitle: playlist.title,
                      removedPlayableAudioNumber: removedPlayableAudioNumber);
            }
            break;
          case PlaylistPopupMenuAction.rewindAudioToStart:
            int rewindedPlayableAudioNumber =
                playlistListVMlistenTrue.rewindPlayableAudioToStart(
              audioPlayerVM: audioPlayerVMlistenTrue,
              playlist: playlist,
            );

            warningMessageVMlistenFalse.rewindedPlayableAudioToStart(
                rewindedPlayableAudioNumber: rewindedPlayableAudioNumber);
            break;
          case PlaylistPopupMenuAction.setPlaylistAudioPlaySpeed:
            final List<HelpItem> audioSetSpeedDialogHelpItemsLst = [
              HelpItem(
                helpTitle: AppLocalizations.of(context)!
                    .alreadyDownloadedAudiosPlaylistHelpTitle,
                helpContent: AppLocalizations.of(context)!
                    .alreadyDownloadedAudiosPlaylistHelpContent,
                displayHelpItemNumber: false,
              ),
            ];

            showDialog<List<dynamic>>(
              context: context,
              builder: (BuildContext context) {
                double playlistAudioPlaySpeed = (playlist.audioPlaySpeed != 0)
                    ? playlist
                        .audioPlaySpeed // audio play speed is defined for the playlist
                    : settingsDataService.get(
                            // get default audio play speed
                            settingType: SettingType.playlists,
                            settingSubType: Playlists.playSpeed) ??
                        kAudioDefaultPlaySpeed;
                return AudioSetSpeedDialog(
                  audioPlaySpeed: playlistAudioPlaySpeed,
                  updateCurrentPlayAudioSpeed: false,
                  displayApplyToAudioAlreadyDownloadedCheckbox: true,
                  helpItemsLst: audioSetSpeedDialogHelpItemsLst,
                );
              },
            ).then((value) {
              // not null value is boolean
              if (value != null) {
                // value is null if clicking on Cancel or if the dialog
                // is dismissed by clicking outside the dialog.

                playlistListVMlistenTrue
                    .updateIndividualPlaylistAndOrAlreadyDownloadedAudioPlaySpeed(
                  audioPlaySpeed: value[0] as double,
                  playlist: playlist,
                  applyAudioPlaySpeedToPlayableAudios: value[2] as bool,
                );
              }
            });
            break;
          case PlaylistPopupMenuAction.filteredAudioActions:
            // Show the submenu for filtered audio actions
            _showFilteredAudioActionsMenu(
              context: context,
              playlistListVMlistenTrue: playlistListVMlistenTrue,
              warningMessageVMlistenFalse: warningMessageVMlistenFalse,
            );
            break;
          case PlaylistPopupMenuAction.deletePlaylist:
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return ConfirmActionDialog(
                  actionFunction: deletePlaylist,
                  actionFunctionArgs: [
                    playlistListVMlistenTrue,
                    playlist,
                  ],
                  dialogTitleOne: _createDeletePlaylistDialogTitle(context),
                  dialogContent:
                      AppLocalizations.of(context)!.deletePlaylistDialogComment,
                );
              },
            );
            break;
          default:
            break;
        }
      }
    });
  }

  void _showFilteredAudioActionsMenu({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenTrue,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);

    const double offsetY =
        300; // Increase this value to push the menu further down

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx - box.size.width, // Align horizontally with the parent menu
        position.dy + offsetY, // Push the submenu lower
        0,
        0,
      ),
      items: [
        PopupMenuItem<FilteredAudioAction>(
          value: FilteredAudioAction.moveFilteredAudio,
          child: Text(AppLocalizations.of(context)?.moveFilteredAudio ??
              'Move Filtered Audio'),
        ),
        PopupMenuItem<FilteredAudioAction>(
          value: FilteredAudioAction.copyFilteredAudio,
          child: Text(AppLocalizations.of(context)?.copyFilteredAudio ??
              'Copy Filtered Audio'),
        ),
        PopupMenuItem<FilteredAudioAction>(
          key: const Key('popup_menu_delete_filtered_audio'),
          value: FilteredAudioAction.deleteFilteredAudio,
          child: Text(AppLocalizations.of(context)!.deleteFilteredAudio),
        ),
      ],
    ).then((action) {
      if (action != null) {
        switch (action) {
          case FilteredAudioAction.moveFilteredAudio:
            showDialog<dynamic>(
              context: context,
              builder: (context) => PlaylistOneSelectableDialog(
                usedFor: PlaylistOneSelectableDialogUsedFor
                    .moveMultipleAudioToPlaylist,
                warningMessageVM: Provider.of<WarningMessageVM>(
                  context,
                  listen: false,
                ),
                excludedPlaylist: playlist,
              ),
            ).then((resultMap) {
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

              // Content of the list:
              //  [
              //    movedAudioNumber,
              //    unmovedAudioNumber,
              //  ]
              List<int> movedUnmovedAudioNumberLst = playlistListVMlistenTrue
                  .moveSortFilteredAudioAndCommentLstToPlaylist(
                targetPlaylist: targetPlaylist,
              );

            String selectedPlaylistAudioSortFilterParmsName =
                playlistListVMlistenTrue
                    .getSelectedPlaylistAudioSortFilterParmsName(
                        audioLearnAppViewType:
                            AudioLearnAppViewType.playlistDownloadView,
                        translatedAppliedSortFilterParmsName:
                            AppLocalizations.of(context)!
                                .sortFilterParametersAppliedName);

              warningMessageVMlistenFalse.confirmMovedUnmovedAudioNumber(
                sourcePlaylistTitle: playlist.title,
                sourcePlaylistType: playlist.playlistType,
                targetPlaylistTitle: targetPlaylist.title,
                targetPlaylistType: targetPlaylist.playlistType,
                appliedSortFilterParmsName:
                    selectedPlaylistAudioSortFilterParmsName,
                movedAudioNumber: movedUnmovedAudioNumberLst[0],
                unmovedAudioNumber: movedUnmovedAudioNumberLst[1],
              );
            });
            break;
          case FilteredAudioAction.copyFilteredAudio:
          // Your copyFilteredAudio logic here
          case FilteredAudioAction.deleteFilteredAudio:
            // Content of the list:
            //  [
            //    numberOfDeletedAudio,
            //    numberOfDeletedCommentedAudio,
            //    deletedAudioFileSizeBytes,
            //    deletedAudioDurationTenthSec,
            //  ]
            List<int> deletedAudioNumberLst =
                playlistListVMlistenTrue.getFilteredAudioQuantities();

            int numberOfDeletedCommentedAudio = deletedAudioNumberLst[1];
            String selectedPlaylistAudioSortFilterParmsName =
                playlistListVMlistenTrue
                    .getSelectedPlaylistAudioSortFilterParmsName(
                        audioLearnAppViewType:
                            AudioLearnAppViewType.playlistDownloadView,
                        translatedAppliedSortFilterParmsName:
                            AppLocalizations.of(context)!
                                .sortFilterParametersAppliedName);

            if (selectedPlaylistAudioSortFilterParmsName.isEmpty) {
              selectedPlaylistAudioSortFilterParmsName =
                  AppLocalizations.of(context)!.sortFilterParametersDefaultName;
            }

            if (numberOfDeletedCommentedAudio == 0) {
              showDialog<void>(
                context: context,
                barrierDismissible:
                    false, // This line prevents the dialog from closing when
                //            tapping outside the dialog
                builder: (BuildContext context) {
                  return ConfirmActionDialog(
                    actionFunction: deleteFilteredAudio,
                    actionFunctionArgs: [
                      playlistListVMlistenTrue,
                    ],
                    dialogTitleOne: AppLocalizations.of(context)!
                        .deleteFilteredAudioConfirmationTitle(
                      selectedPlaylistAudioSortFilterParmsName,
                      playlistListVMlistenTrue.getSelectedPlaylists()[0].title,
                    ),
                    dialogContent: AppLocalizations.of(context)!
                        .deleteFilteredAudioConfirmation(
                      deletedAudioNumberLst[0], // total audio number
                      UiUtil.formatLargeByteAmount(
                        context: context,
                        bytes: deletedAudioNumberLst[2],
                      ), // total audio file size
                      DateTimeUtil.formatSecondsToHHMMSS(
                        seconds: deletedAudioNumberLst[3] ~/ 10,
                      ), // total audio duration
                    ),
                  );
                },
              );
            } else {
              final List<HelpItem> filteredCommentedAudioDeletionHelpItemsLst =
                  [
                HelpItem(
                  helpTitle: AppLocalizations.of(context)!
                      .commentedAudioDeletionHelpTitle,
                  helpContent: AppLocalizations.of(context)!
                      .commentedAudioDeletionHelpContent,
                  displayHelpItemNumber: false,
                ),
                HelpItem(
                  helpTitle: AppLocalizations.of(context)!
                      .commentedAudioDeletionSolutionHelpTitle,
                  helpContent: AppLocalizations.of(context)!
                      .commentedAudioDeletionSolutionHelpContent,
                  displayHelpItemNumber: true,
                ),
                HelpItem(
                  helpTitle: AppLocalizations.of(context)!
                      .commentedAudioDeletionOpenSFDialogHelpTitle,
                  helpContent: AppLocalizations.of(context)!
                      .commentedAudioDeletionOpenSFDialogHelpContent,
                  displayHelpItemNumber: true,
                ),
                HelpItem(
                  helpTitle: AppLocalizations.of(context)!
                      .commentedAudioDeletionCreateSFParmHelpTitle,
                  helpContent: AppLocalizations.of(context)!
                      .commentedAudioDeletionCreateSFParmHelpContent,
                  displayHelpItemNumber: true,
                ),
                HelpItem(
                  helpTitle: AppLocalizations.of(context)!
                      .commentedAudioDeletionSelectSFParmHelpTitle,
                  helpContent: AppLocalizations.of(context)!
                      .commentedAudioDeletionSelectSFParmHelpContent,
                  displayHelpItemNumber: true,
                ),
                HelpItem(
                  helpTitle: AppLocalizations.of(context)!
                      .commentedAudioDeletionApplyingNewSFParmHelpTitle,
                  helpContent: AppLocalizations.of(context)!
                      .commentedAudioDeletionApplyingNewSFParmHelpContent,
                  displayHelpItemNumber: true,
                ),
              ];

              showDialog<void>(
                context: context,
                barrierDismissible:
                    false, // This line prevents the dialog from closing when
                //            tapping outside the dialog
                builder: (BuildContext context) {
                  return ConfirmActionDialog(
                    actionFunction: deleteFilteredAudio,
                    actionFunctionArgs: [
                      playlistListVMlistenTrue,
                    ],
                    dialogTitleOne: AppLocalizations.of(context)!
                        .deleteFilteredCommentedAudioWarningTitleOne,
                    dialogTitleTwo: AppLocalizations.of(context)!
                        .deleteFilteredCommentedAudioWarningTitleTwo(
                      selectedPlaylistAudioSortFilterParmsName,
                      playlistListVMlistenTrue.getSelectedPlaylists()[0].title,
                    ),
                    dialogContent: AppLocalizations.of(context)!
                        .deleteFilteredCommentedAudioWarning(
                      deletedAudioNumberLst[0], // total audio number
                      deletedAudioNumberLst[1], // total commented audio number
                      UiUtil.formatLargeByteAmount(
                        context: context,
                        bytes: deletedAudioNumberLst[2],
                      ), // total audio file size
                      DateTimeUtil.formatSecondsToHHMMSS(
                        seconds: deletedAudioNumberLst[3] ~/ 10,
                      ), // total audio duration
                    ),
                    helpItemsLst: filteredCommentedAudioDeletionHelpItemsLst,
                  );
                },
              );
            }
            break;
          default:
            break;
        }
      }
    });
  }

  /// Method called when the user clicks on the 'Confirm' button after having
  /// selected a text file containing video URLs whose audio are to be downloaded
  /// to the playlist.
  Future<void> downloadAudioFromVideoUrlsContainedInTextFileToPlaylist(
    AudioDownloadVM audioDownloadVM,
    WarningMessageVM warningMessageVM,
    Playlist targetPlaylist,
    List<String> videoUrls,
  ) async {
    int existingAudioFilesNotRedownloadedCount =
        await audioDownloadVM.downloadAudioFromVideoUrlsToPlaylist(
      targetPlaylist: targetPlaylist,
      videoUrls: videoUrls,
    );

    if (existingAudioFilesNotRedownloadedCount > 0) {
      warningMessageVM.setNotRedownloadAudioFilesInPlaylistDirectory(
          targetPlaylistTitle: playlist.title,
          existingAudioNumber: existingAudioFilesNotRedownloadedCount);
    }
  }

  /// Public method passed as parameter to the ActionConfirmDialog
  /// which, in this case, asks the user to confirm the deletion of
  /// filtered audio from the playlist. This method is called when the
  /// user clicks on the 'Confirm' button.
  void deleteFilteredAudio(
    PlaylistListVM playlistListVM,
  ) {
    playlistListVM.deleteSortFilteredAudioLst();
  }

  /// Public method passed as parameter to the ActionConfirmDialog
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

  Future<String> _filePickerSelectVideoUrlsTextFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      allowMultiple: false,
      initialDirectory: await DirUtil.getApplicationPath(),
    );

    if (result != null) {
      return result.files.single.path!;
    }

    return '';
  }
}
