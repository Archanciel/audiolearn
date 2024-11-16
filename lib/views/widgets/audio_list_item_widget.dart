// dart file located in lib\views

import 'package:audiolearn/services/sort_filter_parameters.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/audio.dart';
import '../../../utils/ui_util.dart';
import '../../models/comment.dart';
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
class AudioListItemWidget extends StatelessWidget with ScreenMixin {
  final Audio audio;

  final WarningMessageVM warningMessageVM;

  // this instance variable stores the function defined in
  // _MyHomePageState which causes the PageView widget to drag
  // to another screen according to the passed index.
  final Function(int) onPageChangedFunction;

  final bool _isAudioCurrent;

  AudioListItemWidget({
    super.key,
    required this.audio,
    required bool isAudioCurrent,
    required this.warningMessageVM,
    required this.onPageChangedFunction,
  }) : _isAudioCurrent = isAudioCurrent;

  @override
  Widget build(BuildContext context) {
    final AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    final PlaylistListVM playlistVMlistnedFalse = Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );

    final DateFormatVM dateFormatVMlistenTrue = Provider.of<DateFormatVM>(
      context,
      listen: true,
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
            playlistListVMlistenFalse: playlistVMlistnedFalse,
            audio: audio,
          );
        },
      ),
      title: GestureDetector(
        onTap: () async {
          await _dragToAudioPlayerView(
              audioPlayerVMlistenFalse:
                  audioPlayerVMlistenFalse); // dragging to the AudioPlayerView screen
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
                  audioPlayerVMlistenFalse); // dragging to the AudioPlayerView screen
        },
        child: Text(
          key: const Key('audio_item_subtitle'),
          _buildSubTitle(
            context: context,
            playlistVMlistnedFalse: playlistVMlistnedFalse,
            dateFormatVMlistenTrue: dateFormatVMlistenTrue,
          ),
          style: TextStyle(
            color: audioTitleAndSubTitleTextColor,
            backgroundColor: audioTitleAndSubTitleBackgroundColor,
            fontSize: kAudioTitleFontSize,
          ),
        ),
      ),
      trailing: _buildPlayButton(),
    );
  }

  /// This method builds the audio item left menu which is displayed
  /// when the user clicks on the audio item left menu icon.
  void _buildAudioListItemMenu({
    required BuildContext context,
    required PlaylistListVM playlistListVMlistenFalse,
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
          child:
              Text(AppLocalizations.of(context)!.deleteAudioFromPlaylistAswell),
        ),
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
            final AudioPlayerVM audioGlobalPlayerVM =
                Provider.of<AudioPlayerVM>(
              context,
              listen: false,
            );

            await audioGlobalPlayerVM.setCurrentAudio(
              audio: audio,
            );

            showDialog<void>(
              context: context,
              builder: (context) => CommentListAddDialog(
                currentAudio: audio,
              ),
            );
            break;
          case AudioPopupMenuAction.renameAudioFile:
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => AudioModificationDialog(
                audio: audio,
                audioModificationType: AudioModificationType.renameAudioFile,
              ),
            );
            break;
          case AudioPopupMenuAction.modifyAudioTitle:
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => AudioModificationDialog(
                audio: audio,
                audioModificationType: AudioModificationType.modifyAudioTitle,
              ),
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
                usedFor: PlaylistOneSelectableDialogUsedFor.moveAudioToPlaylist,
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
              playlistVMlistnedFalse.moveAudioAndCommentToPlaylist(
                audioLearnAppViewType:
                    AudioLearnAppViewType.playlistDownloadView,
                audio: audio,
                targetPlaylist: targetPlaylist,
                keepAudioInSourcePlaylistDownloadedAudioLst:
                    keepAudioDataInSourcePlaylist,
              );
            });
            break;
          case AudioPopupMenuAction.copyAudioToPlaylist:
            final PlaylistListVM expandablePlaylistVM =
                Provider.of<PlaylistListVM>(
              context,
              listen: false,
            );

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
                return;
              }

              final Playlist? targetPlaylist = resultMap['selectedPlaylist'];

              if (targetPlaylist == null) {
                return;
              }

              expandablePlaylistVM.copyAudioAndCommentToPlaylist(
                audio: audio,
                targetPlaylist: targetPlaylist,
              );
            });
            break;
          case AudioPopupMenuAction.deleteAudio:
            final Audio audioToDelete = audio;
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
              // dialog. Otherwise, _replaceCurrentAudioByNextAudio() will be
              // called before the dialog is closed and the nextAudio variable
              // will remains null.
              await showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmActionDialog(
                    actionFunction: deleteAudio,
                    actionFunctionArgs: [context, audioToDelete],
                    dialogTitle:
                        _createDeleteAudioDialogTitle(context, audioToDelete),
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

            await _replaceCurrentAudioByNextAudio(
              context: context,
              nextAudio: nextAudio,
            );

            Playlist playlist =
                playlistListVMlistenFalse.getSelectedPlaylists()[0];
            List<Audio> audioLst = playlist.playableAudioLst;
            int nextAudioIndex = audioLst.indexOf(nextAudio!);

            // This updates the playlist download view current audio to
            // the next audio in the playlist playable audio list.
            playlistListVMlistenFalse.updateCurrentOrPastPlayableAudio(
              audioCopy: nextAudio!,
              previousAudioIndex: nextAudioIndex,
            );

            break;
          case AudioPopupMenuAction.deleteAudioFromPlaylistAswell:
            final Audio audioToDelete = audio;
            Audio? nextAudio;
            final List<Comment> audioToDeleteCommentLst =
                playlistListVMlistenFalse.getAudioComments(
              audio: audioToDelete,
            );

            if (audioToDeleteCommentLst.isNotEmpty) {
              // If the audio has comments, the ConfirmActionDialog is
              // displayed. Otherwise, the audio is deleted from the
              // playlist download and playable audio list.
              //
              // Await must be applied to showDialog() so that the nextAudio
              // variable is assigned according to the result returned by the
              // dialog. Otherwise, _replaceCurrentAudioByNextAudio() will be
              // called before the dialog is closed and the nextAudio variable
              // will remains null.
              await showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmActionDialog(
                    actionFunction: deleteAudioFromPlaylistAsWell,
                    actionFunctionArgs: [
                      playlistListVMlistenFalse,
                      audioToDelete
                    ],
                    dialogTitle:
                        _createDeleteAudioDialogTitle(context, audioToDelete),
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
              nextAudio =
                  playlistListVMlistenFalse.deleteAudioFromPlaylistAsWell(
                audioLearnAppViewType:
                    AudioLearnAppViewType.playlistDownloadView,
                audio: audioToDelete,
              );
            }

            await _replaceCurrentAudioByNextAudio(
              context: context,
              nextAudio: nextAudio,
            );

            Playlist playlist =
                playlistListVMlistenFalse.getSelectedPlaylists()[0];
            List<Audio> audioLst = playlist.playableAudioLst;
            int nextAudioIndex = audioLst.indexOf(nextAudio!);

            // This updates the playlist download view current audio to
            // the next audio in the playlist playable audio list.
            playlistListVMlistenFalse.updateCurrentOrPastPlayableAudio(
              audioCopy: nextAudio!,
              previousAudioIndex: nextAudioIndex,
            );

            break;
          default:
            break;
        }
      }
    });
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
      audioLearnAppViewType: AudioLearnAppViewType.playlistDownloadView,
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
  /// view.
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

  /// Method called when the user clicks on the audio list item
  /// audio title or subtitle or the play icon button. This switches
  /// to the AudioPlayerView screen and plays the clicked audio.
  Future<void> _dragToAudioPlayerViewAndPlayAudio(
      AudioPlayerVM audioGlobalPlayerVM) async {
    await audioGlobalPlayerVM.setCurrentAudio(
      audio: audio,
    );
    await audioGlobalPlayerVM.goToAudioPlayPosition(
      durationPosition: Duration(seconds: audio.audioPositionSeconds),
      isUndoRedo: true, // necessary to avoid creating an undo
      //                   command which would activate the undo
      //                   icon button
    );
    await audioGlobalPlayerVM.playCurrentAudio();

    // dragging to the AudioPlayerView screen
    onPageChangedFunction(ScreenMixin.AUDIO_PLAYER_VIEW_DRAGGABLE_INDEX);
  }

  /// Method called when the user clicks on the audio list item.
  /// This switches to the AudioPlayerView screen without playing
  /// the clicked audio.
  Future<void> _dragToAudioPlayerView({
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) async {
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
  /// If the applied sorting option is audio last listened date time, the subtitle
  /// displays the audio duration and the last listened date and time.
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

        return '${audioDuration.HHmmss(addRemainingOneDigitTenthOfSecond: true)}. $lastSubtitlePart.';
      case SortingOption.audioRemainingDuration:
        final DateTime? lastListenedDateTime = audio.audioPausedDateTime;
        final String lastSubtitlePart;
        final String audioRemainingHHMMSSDuration =
            DateTimeUtil.formatSecondsToHHMMSS(
          seconds: audio.getAudioRemainingMilliseconds() ~/ 1000,
        );

        if (lastListenedDateTime == null) {
          lastSubtitlePart =
              '${AppLocalizations.of(context)!.remaining} $audioRemainingHHMMSSDuration. ${AppLocalizations.of(context)!.audioStateNotListened}';
        } else {
          lastSubtitlePart =
              '${AppLocalizations.of(context)!.remaining} $audioRemainingHHMMSSDuration. ${AppLocalizations.of(context)!.listenedOn} ${dateFormatVMlistenTrue.formatDate(lastListenedDateTime)} ${AppLocalizations.of(context)!.atPreposition} ${timeFormat.format(lastListenedDateTime)}';
        }

        return '${audioDuration.HHmmss(addRemainingOneDigitTenthOfSecond: true)}. $lastSubtitlePart.';
      case SortingOption.videoUploadDate:
        final DateTime videoUploadDate = audio.videoUploadDate;
        final String lastSubtitlePart;

        lastSubtitlePart =
            '${AppLocalizations.of(context)!.videoUploadDate}: ${dateFormatVMlistenTrue.formatDate(videoUploadDate)}';

        return '${audioDuration.HHmmss(addRemainingOneDigitTenthOfSecond: true)}. $lastSubtitlePart.';
      case SortingOption.audioDownloadDuration:
        String lastSubtitlePart = _createDefaultLastSubTitlePart(
          context: context,
          dateFormatVMlistenTrue: dateFormatVMlistenTrue,
        );

        final Duration audioDownloadDuration = audio.audioDownloadDuration!;
        final String audioDownloadDurationSubtitlePart;

        audioDownloadDurationSubtitlePart =
            '${AppLocalizations.of(context)!.audioDownloadDuration}: ${audioDownloadDuration.HHmmss()}';

        return '${audioDuration.HHmmss(addRemainingOneDigitTenthOfSecond: true)}. $lastSubtitlePart. $audioDownloadDurationSubtitlePart.';
      default:
        String lastSubtitlePart = _createDefaultLastSubTitlePart(
          context: context,
          dateFormatVMlistenTrue: dateFormatVMlistenTrue,
        );

        return '${audioDuration.HHmmss(addRemainingOneDigitTenthOfSecond: true)}. $lastSubtitlePart.';
    }
  }

  String _createDefaultLastSubTitlePart({
    required BuildContext context,
    required DateFormatVM dateFormatVMlistenTrue,
  }) {
    final int audioFileSize = audio.audioFileSize;
    final String audioFileSizeStr;

    audioFileSizeStr = UiUtil.formatLargeByteAmount(
      context: context,
      bytes: audioFileSize,
    );

    final int audioDownloadSpeed = audio.audioDownloadSpeed;
    final String audioDownloadSpeedStr;

    if (audioDownloadSpeed.isInfinite) {
      audioDownloadSpeedStr = 'infinite o/sec';
    } else {
      audioDownloadSpeedStr = '${UiUtil.formatLargeByteAmount(
        context: context,
        bytes: audioDownloadSpeed,
      )}/sec';
    }

    final DateTime audioDownloadDateTime = audio.audioDownloadDateTime;
    final String lastSubtitlePart;

    if (audio.isAudioImported) {
      lastSubtitlePart =
          '$audioFileSizeStr ${AppLocalizations.of(context)!.imported} ${AppLocalizations.of(context)!.on} ${dateFormatVMlistenTrue.formatDate(audioDownloadDateTime)} ${AppLocalizations.of(context)!.atPreposition} ${timeFormat.format(audioDownloadDateTime)}';
    } else {
      lastSubtitlePart =
          '$audioFileSizeStr ${AppLocalizations.of(context)!.atPreposition} $audioDownloadSpeedStr ${AppLocalizations.of(context)!.on} ${dateFormatVMlistenTrue.formatDate(audioDownloadDateTime)} ${AppLocalizations.of(context)!.atPreposition} ${timeFormat.format(audioDownloadDateTime)}';
    }
    return lastSubtitlePart;
  }

  Widget _buildPlayButton() {
    return Consumer<AudioPlayerVM>(
      builder: (context, audioPlayerVM, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayOrPauseInkwellButton(
              context: context,
              audioPlayerVMlistenTrue: audioPlayerVM,
              audio: audio,
            )
          ],
        );
      },
    );
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
  InkWell _buildPlayOrPauseInkwellButton({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVMlistenTrue,
    required Audio audio,
  }) {
    CircleAvatar circleAvatar;

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
      }

      circleAvatar = formatIconBackAndForGroundColor(
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
      circleAvatar = formatIconBackAndForGroundColor(
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
          await _dragToAudioPlayerViewAndPlayAudio(audioPlayerVMlistenTrue);
        } else {
          // if the audio is playing, the displayed icon is
          // the pause icon. Clicking on it will pause the
          // audio without switching to the AudioPlayerView
          // screen.
          await audioPlayerVMlistenTrue.pause();
        }
      },
      child: SizedBox(
        width: 45, // Adjust this width based on the size of your largest icon
        child: Center(child: circleAvatar),
      ),
    );
  }
}
