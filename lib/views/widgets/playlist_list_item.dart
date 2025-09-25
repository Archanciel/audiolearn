import 'dart:io';

import 'package:audiolearn/constants.dart';
import 'package:audiolearn/utils/dir_util.dart';
import 'package:audiolearn/utils/duration_expansion.dart';
import 'package:audiolearn/utils/ui_util.dart';
import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/audio_player_vm.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/audio.dart';
import '../../models/help_item.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../models/sort_filter_parameters.dart';
import '../../utils/date_time_util.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/date_format_vm.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import 'application_snackbar.dart';
import 'confirm_action_dialog.dart';
import 'convert_text_to_audio_dialog.dart';
import 'playlist_comment_list_dialog.dart';
import 'playlist_info_dialog.dart';
import 'audio_set_speed_dialog.dart';
import 'playlist_one_selectable_dialog.dart';
import 'set_value_to_target_dialog.dart';

enum PlaylistPopupMenuAction {
  openYoutubePlaylist,
  copyYoutubePlaylistUrl,
  displayPlaylistInfo,
  displayPlaylistAudioComments,
  importAudioFilesInPlaylist,
  convertTextToAudioInPlaylist, // New action to convert text to audio
  downloadVideoUrlsFromTextFileInPlaylist,
  updatePlaylistPlayableAudios, // useful if playlist audio files were
  //                               deleted from the app dir
  rewindAudioToStart,
  setPlaylistAudioPlaySpeed,
  setPlaylistAudioQuality,
  filteredAudioActions,
  savePlaylistCommentsAndPicturesToZip,
  savePlaylistAudioMp3FilesToZip,
  restorePlaylistAudioMp3FilesFromZip,
  deletePlaylist,
}

enum FilteredAudioAction {
  moveFilteredAudio,
  copyFilteredAudio,
  deleteFilteredAudio,
  deleteFilteredAudioFromPlaylistAsWell,
  redownloadFilteredAudio,
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

    final AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    final PlaylistListVM playlistListVMlistenFalse =
        Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );

    return ListTile(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          _buildPlaylistItemMenu(
            context: context,
            playlistListVMlistenFalse: playlistListVMlistenFalse,
            audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
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
            playlistListVMlistenFalse.togglePlaylistsList();

            // If another playlist is selected in the audio
            // player view while the current audio is playing,
            // then the current audio is paused.
            if (audioPlayerVMlistenFalse.isPlaying) {
              await audioPlayerVMlistenFalse.pause();
            }
          }

          playlistListVMlistenFalse.setPlaylistSelection(
            playlistSelectedOrUnselected: playlist,
            isPlaylistSelected: value!,
          );

          await audioPlayerVMlistenFalse.setCurrentAudioFromSelectedPlaylist();
        },
      ),
    );
  }

  void _buildPlaylistItemMenu({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenFalse,
    required AudioPlayerVM audioPlayerVMlistenFalse,
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
          key: const Key('popup_menu_convert_text_to_audio_in_playlist'),
          value: PlaylistPopupMenuAction.convertTextToAudioInPlaylist,
          child: Tooltip(
            message:
                AppLocalizations.of(context)!.playlistConvertTextToAudioMenuTooltip,
            child: Text(AppLocalizations.of(context)!.playlistConvertTextToAudioMenu),
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
          key: const Key('popup_menu_set_audio_quality'),
          value: PlaylistPopupMenuAction.setPlaylistAudioQuality,
          child: Tooltip(
            message:
                AppLocalizations.of(context)!.setPlaylistAudioQualityTooltip,
            child: Text(AppLocalizations.of(context)!.setPlaylistAudioQuality),
          ),
        ),
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_filtered_audio_actions'),
          value: PlaylistPopupMenuAction.filteredAudioActions,
          child: Text(AppLocalizations.of(context)!.filteredAudioActions),
        ),
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_save_playlist_comments_pictures_to_zip'),
          value: PlaylistPopupMenuAction.savePlaylistCommentsAndPicturesToZip,
          child: Tooltip(
            message: AppLocalizations.of(context)!
                .saveUniquePlaylistCommentsAndPicturesToZipTooltip,
            child: Text(AppLocalizations.of(context)!
                .saveUniquePlaylistCommentsAndPicturesToZipMenu),
          ),
        ),
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_save_playlist_audio_mp3_files_to_zip'),
          value: PlaylistPopupMenuAction.savePlaylistAudioMp3FilesToZip,
          child: Tooltip(
            message: AppLocalizations.of(context)!
                .savePlaylistAudioMp3FilesToZipTooltip,
            child: Text(AppLocalizations.of(context)!
                .savePlaylistAudioMp3FilesToZipMenu),
          ),
        ),
        PopupMenuItem<PlaylistPopupMenuAction>(
          key: const Key('popup_menu_restore_playlist_audio_mp3_files_from_zip'),
          value: PlaylistPopupMenuAction.restorePlaylistAudioMp3FilesFromZip,
          child: Tooltip(
            message: AppLocalizations.of(context)!
                .restorePlaylistAudioMp3FilesFromZipTooltip,
            child: Text(AppLocalizations.of(context)!
                .restorePlaylistAudioMp3FilesFromZipMenu),
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
                  playlistJsonFileSize: playlistListVMlistenFalse
                      .getPlaylistJsonFileSize(playlist: playlist),
                );
              },
            );
            break;
          case PlaylistPopupMenuAction.displayPlaylistAudioComments:
            if (playlistListVMlistenFalse.getSelectedPlaylists().isEmpty ||
                playlistListVMlistenFalse.getSelectedPlaylists()[0] !=
                    playlist) {
              // the case if the user opens the playlist audio
              // comment dialog on a playlist which is not currently
              // selected
              playlistListVMlistenFalse.setPlaylistSelection(
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
              barrierDismissible:
                  false, // This line prevents the dialog from closing when
              //            tapping outside the dialog
              builder: (context) => PlaylistCommentListDialog(
                currentPlaylist: playlist,
              ),
            );
            break;
          case PlaylistPopupMenuAction.importAudioFilesInPlaylist:
            List<String> selectedFilePathNameLst =
                await _filePickerSelectAudioFiles();

            AudioDownloadVM audioDownloadVMlistenFalse =
                Provider.of<AudioDownloadVM>(
              context,
              listen: false,
            );

            await audioDownloadVMlistenFalse.importAudioFilesInPlaylist(
              targetPlaylist: playlist,
              filePathNameToImportLst: selectedFilePathNameLst,
            );
            break;
          case PlaylistPopupMenuAction.convertTextToAudioInPlaylist:
              // Using FocusNode to enable clicking on Enter to close
              // the dialog
              final FocusNode focusNode = FocusNode();
              showDialog<List<dynamic>>(
                context: context,
                barrierDismissible: false, // This line prevents the dialog from
                // closing when tapping outside the dialog
                builder: (BuildContext context) {
                  return ConvertTextToAudioDialog(
                    settingsDataService: settingsDataService,
                    warningMessageVMlistenFalse: warningMessageVMlistenFalse,
                    targetPlaylist: playlist,
                    focusNode: focusNode,
                  );
                },
              ).then((filterSortAudioAndParmLst) {
                if (filterSortAudioAndParmLst != null) {
                  // user clicked on Save or Apply button on sort and filter
                  // dialog opened by the popup menu button item
                  List<Audio> returnedAudioList = filterSortAudioAndParmLst[0];
                  AudioSortFilterParameters audioSortFilterParameters =
                      filterSortAudioAndParmLst[1];
                  String audioSortFilterParametersName =
                      filterSortAudioAndParmLst[2];
                  playlistListVMlistenFalse
                      .setSortFilterForSelectedPlaylistPlayableAudiosAndParms(
                    audioLearnAppViewType:
                        AudioLearnAppViewType.playlistDownloadView,
                    sortFilteredSelectedPlaylistPlayableAudio:
                        returnedAudioList,
                    audioSortFilterParms: audioSortFilterParameters,
                    audioSortFilterParmsName: audioSortFilterParametersName,
                    translatedAppliedSortFilterParmsName:
                        AppLocalizations.of(context)!
                            .sortFilterParametersAppliedName,
                  );
                  // _wasSortFilterAudioSettingsApplied = true;
                }
              });
              focusNode.requestFocus();
              break;
          case PlaylistPopupMenuAction.downloadVideoUrlsFromTextFileInPlaylist:
            String selectedFilePathName =
                await _filePickerSelectVideoUrlsTextFile();

            List<String> videoUrls =
                DirUtil.readUrlsFromFile(selectedFilePathName);

            AudioDownloadVM audioDownloadVMlistenFalse =
                Provider.of<AudioDownloadVM>(
              context,
              listen: false,
            );

            showDialog<List<String>>(
              barrierDismissible:
                  false, // Prevents the dialog from closing when tapping outside.
              context: context,
              builder: (BuildContext context) {
                return SetValueToTargetDialog(
                  dialogTitle: AppLocalizations.of(context)!
                      .downloadAudioFromVideoUrlsInPlaylistTitle(
                          playlist.title),
                  dialogCommentStr: AppLocalizations.of(context)!
                      .downloadAudioFromVideoUrlsInPlaylist(
                    videoUrls.length.toString(),
                  ),
                  checkboxLabelLst: [
                    AppLocalizations.of(context)!.playlistQualityAudio,
                    AppLocalizations.of(context)!.playlistQualityMusic,
                  ],
                  validationFunctionArgs: [],
                  checkboxIndexSetToTrue:
                      (playlist.playlistQuality == PlaylistQuality.voice)
                          ? 0
                          : 1, // 0 for audio, 1 for music
                );
              },
            ).then((resultStringLst) async {
              if (resultStringLst == null) {
                // The case if the Cancel button was pressed.
                return;
              }

              PlaylistQuality downloadAudioQuality = (resultStringLst[0] == '0')
                  ? PlaylistQuality.voice
                  : PlaylistQuality.music;

              await downloadAudioFromVideoUrlsContainedInTextFileToPlaylist(
                audioDownloadVMlistenFalse: audioDownloadVMlistenFalse,
                warningMessageVM: warningMessageVMlistenFalse,
                targetPlaylist: playlist,
                videoUrls: videoUrls,
                downloadAudioAtMusicQuality:
                    downloadAudioQuality == PlaylistQuality.music,
              );
            });
            break;
          case PlaylistPopupMenuAction.updatePlaylistPlayableAudios:
            int removedPlayableAudioNumber =
                playlistListVMlistenFalse.updatePlayableAudioLst(
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
                playlistListVMlistenFalse.rewindPlayableAudioToStart(
              audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
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

                playlistListVMlistenFalse
                    .updateIndividualPlaylistAndOrAlreadyDownloadedAudioPlaySpeed(
                  audioPlaySpeed: value[0] as double,
                  playlist: playlist,
                  applyAudioPlaySpeedToPlayableAudios: value[2] as bool,
                );
              }
            });
            break;
          case PlaylistPopupMenuAction.setPlaylistAudioQuality:
            showDialog<List<String>>(
              barrierDismissible:
                  false, // Prevents the dialog from closing when tapping outside.
              context: context,
              builder: (BuildContext context) {
                return SetValueToTargetDialog(
                  dialogTitle: AppLocalizations.of(context)!
                      .setPlaylistAudioQualityDialogTitle,
                  dialogCommentStr:
                      AppLocalizations.of(context)!.selectAudioQuality,
                  checkboxLabelLst: [
                    AppLocalizations.of(context)!.playlistQualityAudio,
                    AppLocalizations.of(context)!.playlistQualityMusic,
                  ],
                  validationFunctionArgs: [],
                  checkboxIndexSetToTrue:
                      (playlist.playlistQuality == PlaylistQuality.voice)
                          ? 0
                          : 1, // 0 for audio, 1 for music
                );
              },
            ).then((resultStringLst) {
              if (resultStringLst == null) {
                // The case if the Cancel button was pressed.
                return;
              }

              if (resultStringLst[0] == '0') {
                // The case when the audio quality is set to audio.
                playlistListVMlistenFalse.setPlaylistAudioQuality(
                  playlist: playlist,
                  playlistQuality: PlaylistQuality.voice,
                );
              } else if (resultStringLst[0] == '1') {
                // The case when the audio quality is set to music.
                playlistListVMlistenFalse.setPlaylistAudioQuality(
                  playlist: playlist,
                  playlistQuality: PlaylistQuality.music,
                );
              }
            });
            break;
          case PlaylistPopupMenuAction.filteredAudioActions:
            // Show the submenu for filtered audio actions
            _showFilteredAudioActionsMenu(
              context: context,
              playlistListVMlistenFalse: playlistListVMlistenFalse,
              warningMessageVMlistenFalse: warningMessageVMlistenFalse,
            );
            break;
          case PlaylistPopupMenuAction.savePlaylistCommentsAndPicturesToZip:
            await UiUtil.saveUniquePlaylistCommentsAndPicturesToZip(
              context: context,
              playlist: playlist,
            );
            break;
          case PlaylistPopupMenuAction.savePlaylistAudioMp3FilesToZip:
            String? targetSaveDirectoryPath;

            if (Platform.isAndroid) {
              // On Android, use the predefined path - no file picker needed
              Directory? externalDir = await getExternalStorageDirectory();
              if (externalDir != null) {
                Directory mp3Dir =
                    Directory('${externalDir.path}/downloads/AudioLearn');
                if (!await mp3Dir.exists()) {
                  await mp3Dir.create(recursive: true);
                }
                targetSaveDirectoryPath = mp3Dir.path;
              } else {
                // Handle error case
                final WarningMessageVM warningMessageVMlistenFalse =
                    Provider.of<WarningMessageVM>(
                  context,
                  listen: false,
                );
                warningMessageVMlistenFalse.setError(
                  errorType: ErrorType.androidStorageAccessError,
                );
                return;
              }
            } else {
              // On other platforms, use the file picker
              targetSaveDirectoryPath =
                  await UiUtil.filePickerSelectTargetDir();

              if (targetSaveDirectoryPath == null) {
                return;
              }
            }

            final PlaylistListVM playlistListVMlistenFalse =
                Provider.of<PlaylistListVM>(
              context,
              listen: false,
            );
            final DateFormatVM dateFormatVMlistenFalse =
                Provider.of<DateFormatVM>(
              context,
              listen: false,
            );

            final List<HelpItem> savePlaylistMp3HelpItemsLst = [
              HelpItem(
                helpTitle: AppLocalizations.of(context)!
                    .uniquePlaylistMp3SaveHelpTitle,
                helpContent: AppLocalizations.of(context)!
                    .uniquePlaylistMp3SaveHelpContent(
                  dateFormatVMlistenFalse
                      .formatDate(DateTime(2025, 7, 27)), // Example date,
                  dateFormatVMlistenFalse
                      .formatDate(DateTime(2025, 6, 20)), // Example date,
                  dateFormatVMlistenFalse
                      .formatDate(DateTime(2025, 6, 15)), // Example date,
                ),
                displayHelpItemNumber: false,
              ),
            ];

            showDialog<List<String>>(
              barrierDismissible:
                  false, // Prevents the dialog from closing when tapping outside.
              context: context,
              builder: (BuildContext context) {
                return SetValueToTargetDialog(
                  dialogTitle: AppLocalizations.of(context)!
                      .setAudioDownloadFromDateTimeTitle,
                  dialogCommentStr: AppLocalizations.of(context)!
                      .audioDownloadFromDateTimeUniquePlaylistExplanation,
                  passedValueFieldLabel: AppLocalizations.of(context)!
                      .audioDownloadFromDateTimeLabel(
                          dateFormatVMlistenFalse.selectedDateFormat),
                  passedValueFieldTooltip: AppLocalizations.of(context)!
                      .audioDownloadFromDateTimeUniquePlaylistTooltip,
                  passedValueStr: playlistListVMlistenFalse
                      .getOldestAudioDownloadDateFormattedStr(
                    listOfPlaylists: [playlist], // only one playlist
                  ),
                  checkboxLabelLst: [],
                  validationFunctionArgs: [],
                  isCursorAtStart: true,
                  helpItemsLst: savePlaylistMp3HelpItemsLst,
                );
              },
            ).then((resultStringLst) async {
              if (resultStringLst == null) {
                // The case if the Cancel button was pressed.
                return;
              }

              String oldestAudioDownloadDateFormattedStr = resultStringLst[0];

              List<dynamic> resultsLst =
                  await UiUtil.obtainAudioMp3SavingToZipDuration(
                playlistListVMlistenFalse: playlistListVMlistenFalse,
                dateFormatVMlistenFalse: dateFormatVMlistenFalse,
                warningMessageVMlistenFalse: warningMessageVMlistenFalse,
                playlistsLst: [playlist], // only one playlist
                oldestAudioDownloadDateFormattedStr:
                    oldestAudioDownloadDateFormattedStr,
              );

              if (resultsLst[0] == null) {
                // The case if the date format is invalid.
                return;
              }

              DateTime parseDateTimeOrDateStrUsinAppDateFormat =
                  resultsLst[0]! as DateTime;
              Duration audioMp3SavingToZipDuration = resultsLst[1] as Duration;

              showDialog<void>(
                context: context,
                barrierDismissible:
                    false, // This line prevents the dialog from closing when
                //            tapping outside the dialog
                builder: (BuildContext context) {
                  return ConfirmActionDialog(
                    actionFunction: () async {
                      await playlistListVMlistenFalse
                          .savePlaylistsAudioMp3FilesToZip(
                        listOfPlaylists: [playlist],
                        targetDir: targetSaveDirectoryPath!,
                        fromAudioDownloadDateTime:
                            parseDateTimeOrDateStrUsinAppDateFormat,
                        zipFileSizeLimitInMb: settingsDataService.get(
                          settingType: SettingType.playlists,
                          settingSubType:
                              Playlists.maxSavableAudioMp3FileSizeInMb,
                        ) ??
                            kMp3ZipFileSizeLimitInMb,
                        uniquePlaylistIsSaved: true,
                      );
                      // Handle any post-execution logic here
                    },
                    actionFunctionArgs: [],
                    dialogTitleOne:
                        AppLocalizations.of(context)!.savingAudioToZipTimeTitle,
                    dialogContent:
                        AppLocalizations.of(context)!.savingAudioToZipTime(
                      audioMp3SavingToZipDuration.HHmmss(),
                    ),
                  );
                },
              );
            });
            break;
          case PlaylistPopupMenuAction.restorePlaylistAudioMp3FilesFromZip:
            final List<HelpItem> restorePlaylistsHelpItemsLst = [
              HelpItem(
                helpTitle: AppLocalizations.of(context)!
                    .uniquePlaylistMp3RestorationHelpTitle,
                helpContent: AppLocalizations.of(context)!
                    .uniquePlaylistMp3RestorationHelpContent,
                displayHelpItemNumber: false,
              ),
            ];

            showDialog<List<String>>(
              barrierDismissible:
                  false, // Prevents the dialog from closing when tapping outside.
              context: context,
              builder: (BuildContext context) {
                return SetValueToTargetDialog(
                  dialogTitle: AppLocalizations.of(context)!
                      .audioMp3UniquePlaylistRestorationDialogTitle,
                  dialogCommentStr: AppLocalizations.of(context)!
                      .audioMp3UniquePlaylistRestorationExplanation,
                  checkboxLabelLst: [],
                  validationFunctionArgs: [],
                  canAllCheckBoxBeUnchecked: true,
                  helpItemsLst: restorePlaylistsHelpItemsLst,
                );
              },
            ).then((resultStringLst) async {
              if (resultStringLst == null) {
                // The case if the Cancel button was pressed.
                return;
              }

              await UiUtil.restorePlaylistsAudioMp3FilesFromZip(
                context: context,
                playlistsLst: [playlist], // only one playlist
                warningMessageVMlistenFalse: warningMessageVMlistenFalse,
                uniquePlaylistIsRestored: true,
              );
            });
            break;
          case PlaylistPopupMenuAction.deletePlaylist:
            showDialog<void>(
              context: context,
              barrierDismissible:
                  false, // This line prevents the dialog from closing when
              //            tapping outside the dialog
              builder: (BuildContext context) {
                CommentVM commentVMlistenFalse =
                    Provider.of<CommentVM>(context, listen: false);
                return ConfirmActionDialog(
                  actionFunction: deletePlaylist,
                  actionFunctionArgs: [
                    playlistListVMlistenFalse,
                    playlist,
                  ],
                  dialogTitleOne: _createDeletePlaylistDialogTitle(context),
                  dialogContent:
                      AppLocalizations.of(context)!.deletePlaylistDialogComment(
                    playlist.downloadedAudioLst.length,
                    commentVMlistenFalse.getPlaylistAudioCommentNumber(
                      playlist: playlist,
                    ),
                    playlistListVMlistenFalse.getPlaylistAudioPictureNumber(
                      playlist: playlist,
                    ),
                  ),
                );
              },
            );
            break;
        }
      }
    });
  }

  void _showFilteredAudioActionsMenu({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenFalse,
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
          key: const Key('popup_menu_move_filtered_audio'),
          value: FilteredAudioAction.moveFilteredAudio,
          child: Text(AppLocalizations.of(context)?.moveFilteredAudio ??
              'Move Filtered Audio'),
        ),
        PopupMenuItem<FilteredAudioAction>(
          key: const Key('popup_menu_copy_filtered_audio'),
          value: FilteredAudioAction.copyFilteredAudio,
          child: Text(AppLocalizations.of(context)?.copyFilteredAudio ??
              'Copy Filtered Audio'),
        ),
        PopupMenuItem<FilteredAudioAction>(
          key: const Key('popup_menu_delete_filtered_audio'),
          value: FilteredAudioAction.deleteFilteredAudio,
          child: Text(AppLocalizations.of(context)!.deleteFilteredAudio),
        ),
        PopupMenuItem<FilteredAudioAction>(
          key: const Key(
              'popup_menu_delete_filtered_audio_from_playlist_as_well'),
          value: FilteredAudioAction.deleteFilteredAudioFromPlaylistAsWell,
          child: Text(AppLocalizations.of(context)!
              .deleteFilteredAudioFromPlaylistAsWell),
        ),
        PopupMenuItem<FilteredAudioAction>(
          key: const Key('popup_menu_redownload_filtered_audio'),
          value: FilteredAudioAction.redownloadFilteredAudio,
          child: Tooltip(
            message:
                AppLocalizations.of(context)!.redownloadFilteredAudioTooltip,
            child: Text(AppLocalizations.of(context)!.redownloadFilteredAudio),
          ),
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

              String selectedPlaylistAudioSortFilterParmsName =
                  playlistListVMlistenFalse
                      .getSelectedPlaylistAudioSortFilterParmsNameForView(
                          audioLearnAppViewType:
                              AudioLearnAppViewType.playlistDownloadView,
                          translatedAppliedSortFilterParmsName:
                              AppLocalizations.of(context)!
                                  .sortFilterParametersAppliedName);

              if (selectedPlaylistAudioSortFilterParmsName.isEmpty ||
                  selectedPlaylistAudioSortFilterParmsName ==
                      AppLocalizations.of(context)!
                          .sortFilterParametersDefaultName) {
                // The case if no sort filter parameters were applied.
                // Then, no audio are moved to the target playlist.
                _displayNotApplyingDefaultSFparmsToMoveWarning(
                  context: context,
                  sourcePlaylist: playlist,
                  targetPlaylist: targetPlaylist,
                  warningMessageVMlistenFalse: warningMessageVMlistenFalse,
                );

                return;
              }

              // Content of the list:
              //  [
              //    movedAudioNumber,
              //    movedCommentedAudioNumber,
              //    unmovedAudioNumber,
              //  ]
              List<int> movedUnmovedAudioNumberLst = playlistListVMlistenFalse
                  .moveSortFilteredAudioAndCommentAndPictureLstToPlaylist(
                targetPlaylist: targetPlaylist,
              );

              warningMessageVMlistenFalse.confirmMovedUnmovedAudioNumber(
                sourcePlaylistTitle: playlist.title,
                sourcePlaylistType: playlist.playlistType,
                targetPlaylistTitle: targetPlaylist.title,
                targetPlaylistType: targetPlaylist.playlistType,
                appliedSortFilterParmsName:
                    selectedPlaylistAudioSortFilterParmsName,
                movedAudioNumber: movedUnmovedAudioNumberLst[0],
                movedCommentedAudioNumber: movedUnmovedAudioNumberLst[1],
                unmovedAudioNumber: movedUnmovedAudioNumberLst[2],
              );
            });
            break;
          case FilteredAudioAction.copyFilteredAudio:
            showDialog<dynamic>(
              context: context,
              builder: (context) => PlaylistOneSelectableDialog(
                usedFor: PlaylistOneSelectableDialogUsedFor
                    .copyMultipleAudioToPlaylist,
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

              String selectedPlaylistAudioSortFilterParmsName =
                  playlistListVMlistenFalse
                      .getSelectedPlaylistAudioSortFilterParmsNameForView(
                          audioLearnAppViewType:
                              AudioLearnAppViewType.playlistDownloadView,
                          translatedAppliedSortFilterParmsName:
                              AppLocalizations.of(context)!
                                  .sortFilterParametersAppliedName);

              if (selectedPlaylistAudioSortFilterParmsName.isEmpty ||
                  selectedPlaylistAudioSortFilterParmsName ==
                      AppLocalizations.of(context)!
                          .sortFilterParametersDefaultName) {
                // The case if no sort filter parameters were applied.
                // Then, no audio are copied to the target playlist.
                _displayNotApplyingDefaultSFparmsToCopyWarning(
                  context: context,
                  sourcePlaylist: playlist,
                  targetPlaylist: targetPlaylist,
                  warningMessageVMlistenFalse: warningMessageVMlistenFalse,
                );

                return;
              }

              // Content of the list:
              //  [
              //    copiedAudioNumber,
              //    copiedCommentedAudioNumber,
              //    notCopiedAudioNumber,
              //  ]
              List<int> copiedNotCopiedAudioNumberLst =
                  playlistListVMlistenFalse
                      .copySortFilteredAudioAndCommentAndPictureLstToPlaylist(
                targetPlaylist: targetPlaylist,
              );

              warningMessageVMlistenFalse.confirmCopiedNotCopiedAudioNumber(
                sourcePlaylistTitle: playlist.title,
                sourcePlaylistType: playlist.playlistType,
                targetPlaylistTitle: targetPlaylist.title,
                targetPlaylistType: targetPlaylist.playlistType,
                appliedSortFilterParmsName:
                    selectedPlaylistAudioSortFilterParmsName,
                copiedAudioNumber: copiedNotCopiedAudioNumberLst[0],
                copiedCommentedAudioNumber: copiedNotCopiedAudioNumberLst[1],
                notCopiedAudioNumber: copiedNotCopiedAudioNumberLst[2],
              );
            });
            break;
          case FilteredAudioAction.deleteFilteredAudio:
            // Content of the list:
            //  [
            //    numberOfDeletedAudio,
            //    numberOfDeletedCommentedAudio,
            //    deletedAudioFileSizeBytes,
            //    deletedAudioDurationTenthSec,
            //  ]
            List<int> deletedAudioNumberLst =
                playlistListVMlistenFalse.getFilteredAudioQuantities();

            int numberOfDeletedCommentedAudio = deletedAudioNumberLst[1];
            String selectedPlaylistAudioSortFilterParmsName =
                playlistListVMlistenFalse
                    .getSelectedPlaylistAudioSortFilterParmsNameForView(
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
                    actionFunction: deleteFilteredAudioAndCommentAndPictureLst,
                    actionFunctionArgs: [
                      playlistListVMlistenFalse,
                    ],
                    dialogTitleOne: AppLocalizations.of(context)!
                        .deleteFilteredAudioConfirmationTitle(
                      selectedPlaylistAudioSortFilterParmsName,
                      playlistListVMlistenFalse.getSelectedPlaylists()[0].title,
                    ),
                    dialogContent: AppLocalizations.of(context)!
                        .deleteFilteredAudioConfirmation(
                      deletedAudioNumberLst[0], // total audio number
                      UiUtil.formatLargeSizeToKbOrMb(
                        context: context,
                        sizeInBytes: deletedAudioNumberLst[2],
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

              // Here, the deleted commented audio number is greater than 0
              showDialog<void>(
                context: context,
                barrierDismissible:
                    false, // This line prevents the dialog from closing when
                //            tapping outside the dialog
                builder: (BuildContext context) {
                  return ConfirmActionDialog(
                    actionFunction: deleteFilteredAudioAndCommentAndPictureLst,
                    actionFunctionArgs: [
                      playlistListVMlistenFalse,
                    ],
                    dialogTitleOne: AppLocalizations.of(context)!
                        .deleteFilteredCommentedAudioWarningTitleOne,
                    dialogTitleTwo: AppLocalizations.of(context)!
                        .deleteFilteredCommentedAudioWarningTitleTwo(
                      selectedPlaylistAudioSortFilterParmsName,
                      playlistListVMlistenFalse.getSelectedPlaylists()[0].title,
                    ),
                    dialogContent: AppLocalizations.of(context)!
                        .deleteFilteredCommentedAudioWarning(
                      deletedAudioNumberLst[0], // total audio number
                      deletedAudioNumberLst[1], // total commented audio number
                      UiUtil.formatLargeSizeToKbOrMb(
                        context: context,
                        sizeInBytes: deletedAudioNumberLst[2],
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
          case FilteredAudioAction.deleteFilteredAudioFromPlaylistAsWell:
            // Content of the list:
            //  [
            //    numberOfDeletedAudio,
            //    numberOfDeletedCommentedAudio,
            //    deletedAudioFileSizeBytes,
            //    deletedAudioDurationTenthSec,
            //  ]
            List<int> deletedAudioNumberLst =
                playlistListVMlistenFalse.getFilteredAudioQuantities();
            String selectedPlaylistAudioSortFilterParmsName =
                playlistListVMlistenFalse
                    .getSelectedPlaylistAudioSortFilterParmsNameForView(
                        audioLearnAppViewType:
                            AudioLearnAppViewType.playlistDownloadView,
                        translatedAppliedSortFilterParmsName:
                            AppLocalizations.of(context)!
                                .sortFilterParametersAppliedName);

            if (selectedPlaylistAudioSortFilterParmsName.isEmpty) {
              selectedPlaylistAudioSortFilterParmsName =
                  AppLocalizations.of(context)!.sortFilterParametersDefaultName;
            }

            showDialog<void>(
              context: context,
              barrierDismissible:
                  false, // This line prevents the dialog from closing when
              //            tapping outside the dialog
              builder: (BuildContext context) {
                return ConfirmActionDialog(
                  actionFunction: deleteFilteredAudioLstFromPlaylistAsWell,
                  actionFunctionArgs: [
                    playlistListVMlistenFalse,
                  ],
                  dialogTitleOne: AppLocalizations.of(context)!
                      .deleteFilteredAudioFromPlaylistAsWellConfirmationTitle(
                    selectedPlaylistAudioSortFilterParmsName,
                    playlistListVMlistenFalse.getSelectedPlaylists()[0].title,
                  ),
                  dialogContent: AppLocalizations.of(context)!
                      .deleteFilteredAudioConfirmation(
                    deletedAudioNumberLst[0], // total audio number
                    UiUtil.formatLargeSizeToKbOrMb(
                      context: context,
                      sizeInBytes: deletedAudioNumberLst[2],
                    ), // total audio file size
                    DateTimeUtil.formatSecondsToHHMMSS(
                      seconds: deletedAudioNumberLst[3] ~/ 10,
                    ), // total audio duration
                  ),
                );
              },
            );
            break;
          case FilteredAudioAction.redownloadFilteredAudio:
            // You cannot await here, but you can trigger an
            // action which will not block the widget tree
            // rendering.
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              AudioPlayerVM audioPlayerVMlistenFalse =
                  Provider.of<AudioPlayerVM>(
                context,
                listen: false,
              );
              List<int> redownloadAudioNumberLst =
                  await playlistListVMlistenFalse
                      .redownloadSortFilteredAudioLst(
                audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
              );

              if (redownloadAudioNumberLst.isNotEmpty) {
                warningMessageVMlistenFalse.redownloadAudioNumberConfirmation(
                  targetPlaylistTitle: playlist.title,
                  redownloadAudioNumberAudioNumber: redownloadAudioNumberLst[0],
                  notRedownloadAudioNumberAudioNumber:
                      redownloadAudioNumberLst[1],
                );
              } // else, since no confirmation warning is displayed,
              //   the no internet warning thrown by AudioDownloadVM.
              //   notifyDownloadError() can be displayed..
            });

            break;
        }
      }
    });
  }

  void _displayNotApplyingDefaultSFparmsToMoveWarning({
    required BuildContext context,
    required Playlist sourcePlaylist,
    required Playlist targetPlaylist,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    warningMessageVMlistenFalse.displayNotApplyingDefaultSFparmsToMoveWarning(
      sourcePlaylistTitle: playlist.title,
      sourcePlaylistType: playlist.playlistType,
      targetPlaylistTitle: targetPlaylist.title,
      targetPlaylistType: targetPlaylist.playlistType,
      appliedSortFilterParmsName:
          AppLocalizations.of(context)!.sortFilterParametersDefaultName,
    );
  }

  void _displayNotApplyingDefaultSFparmsToCopyWarning({
    required BuildContext context,
    required Playlist sourcePlaylist,
    required Playlist targetPlaylist,
    required WarningMessageVM warningMessageVMlistenFalse,
  }) {
    warningMessageVMlistenFalse.displayNotApplyingDefaultSFparmsToCopyWarning(
      sourcePlaylistTitle: playlist.title,
      sourcePlaylistType: playlist.playlistType,
      targetPlaylistTitle: targetPlaylist.title,
      targetPlaylistType: targetPlaylist.playlistType,
      appliedSortFilterParmsName:
          AppLocalizations.of(context)!.sortFilterParametersDefaultName,
    );
  }

  /// Method called when the user clicks on the 'Confirm' button after having
  /// selected a text file containing video URLs whose audio are to be downloaded
  /// to the playlist.
  Future<void> downloadAudioFromVideoUrlsContainedInTextFileToPlaylist({
    required AudioDownloadVM audioDownloadVMlistenFalse,
    required WarningMessageVM warningMessageVM,
    required Playlist targetPlaylist,
    required List<String> videoUrls,
    required bool downloadAudioAtMusicQuality,
  }) async {
    int existingAudioFilesNotRedownloadedCount =
        await audioDownloadVMlistenFalse.downloadAudioFromVideoUrlsToPlaylist(
      targetPlaylist: targetPlaylist,
      videoUrlsLst: videoUrls,
      downloadAtMusicQuality: downloadAudioAtMusicQuality,
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
  void deleteFilteredAudioAndCommentAndPictureLst(
    PlaylistListVM playlistListVM,
  ) {
    playlistListVM.deleteSortFilteredAudioLstAndTheirCommentsAndPicture();
  }

  /// Public method passed as parameter to the ActionConfirmDialog
  /// which, in this case, asks the user to confirm the deletion of
  /// filtered audio from the playlist as well. This method is called
  /// when the user clicks on the 'Confirm' button.
  void deleteFilteredAudioLstFromPlaylistAsWell(
    PlaylistListVM playlistListVM,
  ) {
    playlistListVM.deleteSortFilteredAudioLstFromPlaylistAsWell();
  }

  /// Public method passed as parameter to the ActionConfirmDialog
  /// which, in this case, asks the user to confirm the deletion of a
  /// playlist. This method is called when the user clicks on the
  /// 'Confirm' button.
  void deletePlaylist(
    PlaylistListVM playlistListVMlistenFalse,
    Playlist playlistToDelete,
  ) {
    playlistListVMlistenFalse.deletePlaylist(
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
      initialDirectory: DirUtil.getApplicationPath(),
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
      initialDirectory: DirUtil.getApplicationPath(),
    );

    if (result != null) {
      return result.files.single.path!;
    }

    return '';
  }
}
