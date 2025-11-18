// dart file located in lib\views

import 'package:audiolearn/models/sort_filter_parameters.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:audiolearn/viewmodels/picture_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../../models/audio.dart';
import '../../../utils/ui_util.dart';
import '../../models/comment.dart';
import '../../models/help_item.dart';
import '../../models/playlist.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../../viewmodels/playlist_list_vm.dart';
import '../../utils/duration_expansion.dart';
import '../../constants.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import 'confirm_action_dialog.dart';
import 'audio_info_dialog.dart';
import 'comment_list_add_dialog.dart';
import 'playlist_one_selectable_dialog.dart';
import 'audio_modification_dialog.dart';

/// This widget is used in the PlaylistDownloadView ListView which
/// display the playable audio of the selected playlist.
/// AudioListItemWidget displays the audio item content as well
/// as the audio item left menu and the audio item right play or
/// pause button.
///
/// When the user clicks on the audio item title or subtitle or
/// the play icon button, the screen switches to the AudioPlayerView
/// screen and the passed {onPageChangedFunction} is executed.
class AudioListItem extends StatelessWidget with ScreenMixin {
  final Audio audio;

  final WarningMessageVM warningMessageVM;

  // this instance variable stores the function defined in
  // _MyHomePageState which causes the PageView widget to drag
  // to another screen according to the passed index.
  final Function(int) onPageChangedFunction;

  final bool _isAudioCurrent;
  final Logger _logger = Logger();

  AudioListItem({
    super.key,
    required this.audio,
    required bool isAudioCurrent,
    required this.warningMessageVM,
    required this.onPageChangedFunction,
  }) : _isAudioCurrent = isAudioCurrent;

  @override
  Widget build(BuildContext context) {
    final PlaylistListVM playlistListVMlistendFalse =
        Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );
    final AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );
    final DateFormatVM dateFormatVMlistenTrue = Provider.of<DateFormatVM>(
      context,
      listen: true,
    );
    final PictureVM pictureVMlistenFalse = Provider.of<PictureVM>(
      context,
      listen: false,
    );

    Color? audioTitleAndSubTitleTextColor;
    Color? audioTitleAndSubTitleBackgroundColor;

    if (_isAudioCurrent) {
      List<Color?> audioTitleForeAndBackgroundColors =
          UiUtil.generateCurrentAudioStateColors();

      audioTitleAndSubTitleTextColor = audioTitleForeAndBackgroundColors[0];
      audioTitleAndSubTitleBackgroundColor =
          audioTitleForeAndBackgroundColors[1];
    }

    return ListTile(
      // generating the audio item left (leading) menu ...
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          _buildAudioListItemMenu(
            context: context,
            playlistListVMlistenFalse: playlistListVMlistendFalse,
            audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
            pictureVMlistenFalse: pictureVMlistenFalse,
            audio: audio,
          );
        },
      ),
      title: GestureDetector(
        onTap: () async {
          await _dragToAudioPlayerView(
              audioPlayerVMlistenFalse:
                  audioPlayerVMlistenFalse); // dragging to the AudioPlayerView
          //                                    screen after typing on audio title
        },
        child: Text(audio.validVideoTitle,
            style: TextStyle(
              color: audioTitleAndSubTitleTextColor,
              backgroundColor: audioTitleAndSubTitleBackgroundColor,
              fontSize: kAudioTitleFontSize,
            )),
      ),
      subtitle: GestureDetector(
        onTap: () async {
          await _dragToAudioPlayerView(
              audioPlayerVMlistenFalse:
                  audioPlayerVMlistenFalse); // dragging to the AudioPlayerView
          //                                    screen after typing on sub-title
        },
        child: Text(
          key: const Key('audio_item_subtitle'),
          _buildSubTitle(
            context: context,
            playlistVMlistnedFalse: playlistListVMlistendFalse,
            dateFormatVMlistenTrue: dateFormatVMlistenTrue,
          ),
          style: TextStyle(
            color: audioTitleAndSubTitleTextColor,
            backgroundColor: audioTitleAndSubTitleBackgroundColor,
            fontSize: kAudioTitleFontSize,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlayOrPauseInkwellButton(
            context: context,
            audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
            audio: audio,
          )
        ],
      ),
    );
  }

  /// This method builds the audio item left menu which is displayed
  /// when the user clicks on the audio item left menu icon.
  void _buildAudioListItemMenu({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenFalse,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required PictureVM pictureVMlistenFalse,
    required Audio audio,
  }) {
    final RenderBox listTileBox = context.findRenderObject() as RenderBox;
    final Offset listTilePosition = listTileBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        listTilePosition.dx - listTilePosition.dx,
        listTilePosition.dy,
        0,
        0,
      ),
      items: [
        if (audio.audioType == AudioType.downloaded) ...[
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_menu_open_youtube_video'),
            value: AudioPopupMenuAction.openYoutubeVideo,
            child: Text(AppLocalizations.of(context)!.openYoutubeVideo),
          )
        ],
        if (audio.audioType == AudioType.downloaded) ...[
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_copy_youtube_video_url'),
            value: AudioPopupMenuAction.copyYoutubeVideoUrl,
            child: Text(AppLocalizations.of(context)!.copyYoutubeVideoUrl),
          )
        ],
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
        if (pictureVMlistenFalse.getLastAddedAudioPictureFile(
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
          child:
              Text(AppLocalizations.of(context)!.deleteAudioFromPlaylistAswell),
        ),
        if (audio.audioType == AudioType.downloaded) ...[
          PopupMenuItem<AudioPopupMenuAction>(
            key: const Key('popup_menu_redownload_delete_audio'),
            value: AudioPopupMenuAction.redownloadDeletedAudio,
            child: Text(AppLocalizations.of(context)!.redownloadDeletedAudio),
          )
        ],
      ],
      elevation: 8,
    ).then((value) async {
      if (value != null) {
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
              builder: (BuildContext context) => AudioInfoDialog(
                audio: audio,
              ),
            );
            break;
          case AudioPopupMenuAction.audioComment:
            showDialog<void>(
              context: context,
              builder: (context) => CommentListAddDialog(
                currentAudio: audio,
              ),
            );
            break;
          case AudioPopupMenuAction.modifyAudioTitle:
            List<HelpItem> audioTitleModificationHelpItemsLst = [
              HelpItem(
                helpTitle: AppLocalizations.of(context)!
                    .audioTitleModificationHelpTitle,
                helpContent: AppLocalizations.of(context)!
                    .audioTitleModificationHelpContent,
                displayHelpItemNumber: false,
              ),
            ];
            await showDialog<String?>(
              context: context,
              barrierDismissible:
                  false, // This line prevents the dialog from closing when
              //            tapping outside the dialog
              builder: (BuildContext context) {
                return AudioModificationDialog(
                  audio: audio,
                  audioModificationType: AudioModificationType.modifyAudioTitle,
                  helpItemsLst: audioTitleModificationHelpItemsLst,
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
                audioModificationType: AudioModificationType.renameAudioFile,
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
            break;
          case AudioPopupMenuAction.removeAudioPicture:
            pictureVMlistenFalse.removeLastAddedAudioPicture(
              audio: audio,
            );
            break;
          case AudioPopupMenuAction.moveAudioToPlaylist:
            final PlaylistListVM playlistVMlistnedFalse =
                Provider.of<PlaylistListVM>(
              context,
              listen: false,
            );

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
              bool keepAudioDataInSourcePlaylist =
                  resultMap['keepAudioDataInSourcePlaylist'];
              playlistVMlistnedFalse.moveAudioAndCommentAndPictureToPlaylist(
                  audioLearnAppViewType:
                      AudioLearnAppViewType.playlistDownloadView,
                  audio: audio,
                  targetPlaylist: targetPlaylist,
                  keepAudioInSourcePlaylistDownloadedAudioLst:
                      keepAudioDataInSourcePlaylist,
                  audioPlayerVMlistenFalse: audioPlayerVMlistenFalse);
            });
            break;
          case AudioPopupMenuAction.copyAudioToPlaylist:
            final PlaylistListVM playlistVMlistenFalse =
                Provider.of<PlaylistListVM>(
              context,
              listen: false,
            );

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
                return;
              }

              final Playlist? targetPlaylist = resultMap['selectedPlaylist'];

              if (targetPlaylist == null) {
                return;
              }

              playlistVMlistenFalse.copyAudioAndCommentAndPictureToPlaylist(
                audio: audio,
                targetPlaylist: targetPlaylist,
              );
            });
            break;
          case AudioPopupMenuAction.deleteAudio:
            final Audio audioToDelete = audio;

            if (!audioToDelete.isPaused) {
              audioPlayerVMlistenFalse.pause();
            }

            Audio? nextAudio;

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
              // dialog. Otherwise, UiUtil.replaceCurrentAudioByNextAudio() will be
              // called before the dialog is closed and the nextAudio variable
              // will remains null.
              await showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmActionDialog(
                    actionFunction: UiUtil.deleteAudio,
                    actionFunctionArgs: [
                      context,
                      audioToDelete,
                      AudioLearnAppViewType.playlistDownloadView,
                    ],
                    dialogTitleOne:
                        UiUtil.createDeleteCommentedAudioDialogTitle(
                      context: context,
                      audioToDelete: audioToDelete,
                    ),
                    dialogContent: AppLocalizations.of(context)!
                        .confirmCommentedAudioDeletionComment(
                            audioToDeleteCommentLst.length),
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
                    AudioLearnAppViewType.playlistDownloadView,
                audio: audioToDelete,
              );
            }

            await UiUtil.replaceCurrentAudioByNextAudio(
              context: context,
              nextAudio: nextAudio,
            );

            // This method only calls the PlaylistListVM notifyListeners()
            // method so that the playlist download view current audio is
            // updated to the next audio in the playlist playable audio list.
            playlistListVMlistenFalse.updateCurrentAudio();
            break;
          case AudioPopupMenuAction.deleteAudioFromPlaylistAswell:
            await UiUtil.handleDeleteAudioFromPlaylistAsWell(
              context: context,
              playlistListVMlistenFalse: playlistListVMlistenFalse,
              audioToDelete: audio,
              audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
              warningMessageVM: warningMessageVM,
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
                warningMessageVM.redownloadAudioConfirmation(
                  targetPlaylistTitle: audio.enclosingPlaylist!.title,
                  redownloadAudioTitle: audio.validVideoTitle,
                  redownloadAudioNumber: redownloadAudioNumber,
                );
              } // else -1 is returned, since no confirmation warning
              //   is displayed, the no internet or
              //   downloadAudioYoutubeError warning thrown by
              //   AudioDownloadVM.notifyDownloadError() can be displayed.
            });
        }
      }
    });
  }

  /// Method called when the user clicks on the audio list item play icon button.
  /// This switches to the AudioPlayerView screen and plays the clicked audio.
  Future<void> _dragToAudioPlayerViewAndPlayAudio({
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) async {
    Audio? audioPlayerVMcurrentAudio = audioPlayerVMlistenFalse.currentAudio;

    if (audioPlayerVMcurrentAudio != null &&
        !audioPlayerVMcurrentAudio.isPaused && // is playing
        audioPlayerVMcurrentAudio != audio) {
      // If clicking on another audio item play button, the audio player
      // VM current audio is paused if it is playing. If it is not paused,
      // the position of the clicked audio will be set to zero by the
      // audioPlayer onPositionChanged listener.
      await audioPlayerVMlistenFalse.pause();
    }

    await audioPlayerVMlistenFalse.setCurrentAudio(
      audio: audio,
    );
    await audioPlayerVMlistenFalse.goToAudioPlayPosition(
      durationPosition: Duration(seconds: audio.audioPositionSeconds),
      isUndoRedo: true, // necessary to avoid creating an undo
      //                   command which would activate the undo
      //                   icon button
    );
    await audioPlayerVMlistenFalse.playCurrentAudio();

    // dragging to the AudioPlayerView screen
    onPageChangedFunction(ScreenMixin.AUDIO_PLAYER_VIEW_DRAGGABLE_INDEX);
  }

  /// Method called when the user clicks on the audio list item audio title or
  /// subtitle. This switches to the AudioPlayerView screen without playing the
  /// clicked audio.
  Future<void> _dragToAudioPlayerView({
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) async {
    Audio? audioPlayerVMcurrentAudio = audioPlayerVMlistenFalse.currentAudio;

    if (audioPlayerVMcurrentAudio != null &&
        !audioPlayerVMcurrentAudio.isPaused && // is playing
        audioPlayerVMcurrentAudio != audio) {
      // If clicking on another audio item, the audio player VM current
      // audio is paused if it is playing. If it is not paused, the
      // position of the clicked audio will be set to zero by the
      // audioPlayer onPositionChanged listener.
      await audioPlayerVMlistenFalse.pause();
    }

    await audioPlayerVMlistenFalse.setCurrentAudio(
      audio: audio,
    );

    await audioPlayerVMlistenFalse.goToAudioPlayPosition(
      durationPosition: Duration(
        seconds: audio.audioPositionSeconds,
      ),
      isUndoRedo: true, // necessary to avoid creating an undo
      //                   command which would activate the undo
      //                   icon button
    );

    // dragging to the AudioPlayerView screen
    onPageChangedFunction(ScreenMixin.AUDIO_PLAYER_VIEW_DRAGGABLE_INDEX);
  }

  /// The method builds the audio item subtitle displayed in the audio
  /// list item. The subtitle is built according to the applied sorting option.
  /// The subtitle displays the audio duration and the last listened date
  /// and time if the applied sorting option is last listened date time.
  ///
  /// If the applied sorting option is audio remaining duration, the subtitle
  /// displays the audio duration, the remaining audio duration and the last
  /// listened date and time if the audio is paused.
  ///
  /// If the applied sorting option is video upload date or if the audio are filtered
  /// according to a video start/end upload date, the subtitle displays the audio
  /// duration and the video upload date.
  ///
  /// If the applied sorting option is default, the subtitle displays
  /// the audio duration, the audio file size, the audio download speed and
  /// the audio download date and time.
  String _buildSubTitle({
    required BuildContext context,
    required PlaylistListVM playlistVMlistnedFalse,
    required DateFormatVM dateFormatVMlistenTrue,
  }) {
    Duration? audioDuration = audio.audioDuration;

    SortingOption appliedSortingOption =
        playlistVMlistnedFalse.getAppliedSortingOption();

    switch (appliedSortingOption) {
      case SortingOption.lastListenedDateTime:
        final DateTime? lastListenedDateTime = audio.audioPausedDateTime;
        final String lastSubtitlePart;

        if (lastListenedDateTime == null) {
          lastSubtitlePart =
              AppLocalizations.of(context)!.audioStateNotListened;
        } else {
          lastSubtitlePart =
              '${AppLocalizations.of(context)!.listenedOn} ${dateFormatVMlistenTrue.formatDate(lastListenedDateTime)} ${AppLocalizations.of(context)!.atPreposition} ${timeFormat.format(lastListenedDateTime)}';
        }

        return '${audioDuration.HHmmss(addRemainingOneDigitTenthOfSecond: true)} $lastSubtitlePart';
      case SortingOption.lastCommentDateTime:
        CommentVM commentVM = CommentVM();
        String lastSubtitlePart;

        // Load comments for this audio
        List<Comment> comments = commentVM.loadAudioComments(audio: audio);

        if (comments.isEmpty) {
          lastSubtitlePart = AppLocalizations.of(context)!.audioStateNoComment;
        } else {
          // Find the most recent comment modification date
          DateTime mostRecentCommentDate = comments
              .map((comment) => comment.lastUpdateDateTime)
              .reduce((a, b) => a.isAfter(b) ? a : b);

          lastSubtitlePart =
              '${AppLocalizations.of(context)!.commentedOn} ${dateFormatVMlistenTrue.formatDate(mostRecentCommentDate)} ${AppLocalizations.of(context)!.atPreposition} ${timeFormat.format(mostRecentCommentDate)}';
        }
        return '${audioDuration.HHmmss(addRemainingOneDigitTenthOfSecond: true)} $lastSubtitlePart';
      case SortingOption.audioRemainingDuration:
        final DateTime? lastListenedDateTime = audio.audioPausedDateTime;
        final String lastSubtitlePart;
        final String audioRemainingHHMMSSDuration =
            DateTimeUtil.formatSecondsToHHMMSS(
          seconds: audio.getAudioRemainingMilliseconds() ~/ 1000,
        );

        if (lastListenedDateTime == null) {
          lastSubtitlePart =
              '${AppLocalizations.of(context)!.remaining} $audioRemainingHHMMSSDuration ${AppLocalizations.of(context)!.audioStateNotListened}';
        } else {
          lastSubtitlePart =
              '${AppLocalizations.of(context)!.remaining} $audioRemainingHHMMSSDuration ${AppLocalizations.of(context)!.listenedOn} ${dateFormatVMlistenTrue.formatDate(lastListenedDateTime)} ${AppLocalizations.of(context)!.atPreposition} ${timeFormat.format(lastListenedDateTime)}';
        }

        return '${audioDuration.HHmmss(addRemainingOneDigitTenthOfSecond: true)} $lastSubtitlePart';
      case SortingOption.videoUploadDate:
        // This video upload date value is only used if the audio type is
        // AudioType.imported or AudioType.converted.
        DateTime videoUploadDate = DateTime(0, 1, 1);
        final String lastSubtitlePart;

        if (audio.audioType == AudioType.downloaded) {
          videoUploadDate = audio.videoUploadDate;
        }

        String formatedDate =
            dateFormatVMlistenTrue.formatDate(videoUploadDate);

        if (formatedDate.contains('0000')) {
          formatedDate = formatedDate.replaceAll('01', '00');
        }

        lastSubtitlePart =
            '${AppLocalizations.of(context)!.videoUploadDate}: $formatedDate';

        return '${audioDuration.HHmmss(addRemainingOneDigitTenthOfSecond: true)} $lastSubtitlePart';
      case SortingOption.audioDownloadDuration:
        String lastSubtitlePart = _createDefaultLastSubTitlePart(
          context: context,
          dateFormatVMlistenTrue: dateFormatVMlistenTrue,
        );

        final Duration audioDownloadDuration = audio.audioDownloadDuration!;
        final String audioDownloadDurationSubtitlePart;

        audioDownloadDurationSubtitlePart =
            '${AppLocalizations.of(context)!.audioDownloadDuration}: ${audioDownloadDuration.HHmmss()}';

        return '${audioDuration.HHmmss(addRemainingOneDigitTenthOfSecond: true)} $lastSubtitlePart $audioDownloadDurationSubtitlePart';
      default:
        String lastSubtitlePart = _createDefaultLastSubTitlePart(
          context: context,
          dateFormatVMlistenTrue: dateFormatVMlistenTrue,
        );

        return '${audioDuration.HHmmss(addRemainingOneDigitTenthOfSecond: true)} $lastSubtitlePart';
    }
  }

  String _createDefaultLastSubTitlePart({
    required BuildContext context,
    required DateFormatVM dateFormatVMlistenTrue,
  }) {
    final int audioFileSize = audio.audioFileSize;
    final String audioFileSizeStr;

    audioFileSizeStr = UiUtil.formatLargeSizeToKbOrMb(
      context: context,
      sizeInBytes: audioFileSize,
    );

    final int audioDownloadSpeed = audio.audioDownloadSpeed;
    final String audioDownloadSpeedStr;

    if (audioDownloadSpeed.isInfinite) {
      audioDownloadSpeedStr = 'infinite o/sec';
    } else {
      audioDownloadSpeedStr = '${UiUtil.formatLargeSizeToKbOrMb(
        context: context,
        sizeInBytes: audioDownloadSpeed,
      )}/sec';
    }

    final DateTime audioDownloadDateTime = audio.audioDownloadDateTime;
    String lastSubtitlePart = '';

    if (audio.audioType == AudioType.imported) {
      lastSubtitlePart =
          '$audioFileSizeStr ${AppLocalizations.of(context)!.imported} ${AppLocalizations.of(context)!.on} ${dateFormatVMlistenTrue.formatDate(audioDownloadDateTime)} ${AppLocalizations.of(context)!.atPreposition} ${timeFormat.format(audioDownloadDateTime)}';
    } else if (audio.audioType == AudioType.downloaded) {
      lastSubtitlePart =
          '$audioFileSizeStr ${AppLocalizations.of(context)!.atPreposition} $audioDownloadSpeedStr ${AppLocalizations.of(context)!.on} ${dateFormatVMlistenTrue.formatDate(audioDownloadDateTime)} ${AppLocalizations.of(context)!.atPreposition} ${timeFormat.format(audioDownloadDateTime)}';
    } else if (audio.audioType == AudioType.textToSpeech) {
      lastSubtitlePart =
          '$audioFileSizeStr ${AppLocalizations.of(context)!.textToSpeech} ${AppLocalizations.of(context)!.on} ${dateFormatVMlistenTrue.formatDate(audioDownloadDateTime)} ${AppLocalizations.of(context)!.atPreposition} ${timeFormat.format(audioDownloadDateTime)}';
    }

    return lastSubtitlePart;
  }

  /// This method build the audio play or pause button displayed
  /// at right position of the playlist audio ListTile.
  ///
  /// According to the audio state - is it playing or paused, and
  /// if not playing, is it paused at a certain position or is
  /// its position zero, the icon type and icon color are different.
  /// The current application theme is also integrated.
  ///
  /// Using InkWell instead of IconButton enables to use CircleAvatar
  /// as a button. IconButton doesn't allow to use CircleAvatar as a
  /// button. CircleAvatar is used to display the bookmark icon which
  /// can be highlighted or not and disabled or not and be enclosed in
  /// a colored circle.
  Widget _buildPlayOrPauseInkwellButton({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required Audio audio,
  }) {
    CircleAvatar circleAvatar;

    return ValueListenableBuilder<String?>(
      // currentAudioTitleNotifier is necessary to correctly handle
      // the case when the current audio reach its end position and
      // the next playable audio starts playing. Without it, the ended
      // audio play/pause button remains as a pause button and the
      // next audio play/pause button remains as a play button.
      //
      // If the current ending audio is the last playable audio, the
      // play/pause button is correctly set as play button. In both
      // cases, when the audio is at end, the play button is set with
      // the right color.
      valueListenable: audioPlayerVMlistenFalse.currentAudioTitleNotifier,
      builder: (context, currentAudioTitle, child) {
        return ValueListenableBuilder<bool>(
          valueListenable:
              audioPlayerVMlistenFalse.currentAudioPlayPauseNotifier,
          builder: (context, mustPlayPauseButtonBeSetToPaused, child) {
            if (audio.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd) {
              Icon playOrPauseIcon;

              if (audio.isPaused) {
                // if the audio is paused, the displayed icon is
                // the play icon. Clicking on it will play the audio
                // from the current position and will switch to the
                // AudioPlayerView screen.
                playOrPauseIcon = const Icon(Icons.play_arrow);
              } else {
                // if the audio is playing, the displayed icon is
                // the pause icon. Clicking on it will pause the
                // audio without switching to the AudioPlayerView
                // screen.
                playOrPauseIcon = const Icon(Icons.pause);
                _logger.i(
                    "${audio.validVideoTitle} is playing at ${audio.audioPositionSeconds} seconds.");
              }

              circleAvatar = formatIconBackAndForgroundColor(
                context: context,
                iconToFormat: playOrPauseIcon,
                isIconHighlighted: true, // since audio is playing or paused
                //                          at a certain position the icon
                //                          is highlighted
              );
            } else {
              // the audio is not playing or paused at a certain position
              // (i.e. its position is zero or its position is at the end
              // of the audio file)
              circleAvatar = formatIconBackAndForgroundColor(
                  context: context,
                  iconToFormat: const Icon(Icons.play_arrow),
                  isIconHighlighted: false, // since audio is at start or end
                  //                           position, the icon is not
                  //                           highlighted
                  isIconColorStronger: audio.audioPositionSeconds != 0);
            }

            // Return the icon wrapped inside a SizedBox to ensure
            // horizontal alignment
            return InkWell(
              key: const Key('play_pause_audio_item_inkwell'),
              onTap: () async {
                if (audio.isPaused) {
                  // if the audio is paused, the displayed icon is
                  // the play icon. Clicking on it will play the audio
                  // from the current position and will switch to the
                  // AudioPlayerView screen.
                  await _dragToAudioPlayerViewAndPlayAudio(
                    audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                  );
                } else {
                  // if the audio is playing, the displayed icon is
                  // the pause icon. Clicking on it will pause the
                  // audio without switching to the AudioPlayerView
                  // screen.
                  await audioPlayerVMlistenFalse.pause();
                }
              },
              child: SizedBox(
                width:
                    45, // Adjust this width based on the size of your largest icon
                child: Center(child: circleAvatar),
              ),
            );
          },
        );
      },
    );
  }
}
