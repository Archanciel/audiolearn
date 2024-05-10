// dart file located in lib\views

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../models/audio.dart';
import '../../../models/playlist.dart';
import '../../../utils/ui_util.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../../viewmodels/playlist_list_vm.dart';
import '../../utils/duration_expansion.dart';
import '../../constants.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import 'audio_info_dialog_widget.dart';
import 'playlist_one_selectable_dialog_widget.dart';
import 'audio_file_rename_dialog_widget.dart';

enum AudioPopupMenuAction {
  openYoutubeVideo,
  copyYoutubeVideoUrl,
  displayAudioInfo,
  renameAudioFile,
  moveAudioToPlaylist,
  copyAudioToPlaylist,
  deleteAudio,
  deleteAudioFromPlaylistAswell,
}

/// This widget is used in the PlaylistDownloadView ListView which
/// display the playable audios of the selected playlist.
/// AudioListItemWidget displays the audio item content as well
/// as the audio item left menu and the audio item right play or
/// pause button.
class AudioListItemWidget extends StatelessWidget with ScreenMixin {
  final Audio audio;

  final WarningMessageVM warningMessageVM;

  // this instance variable stores the function defined in
  // _MyHomePageState which causes the PageView widget to drag
  // to another screen according to the passed index.
  final Function(int) onPageChangedFunction;

  AudioListItemWidget({
    super.key,
    required this.audio,
    required this.warningMessageVM,
    required this.onPageChangedFunction,
  });

  @override
  Widget build(BuildContext context) {
    final AudioPlayerVM audioGlobalPlayerVM =
        Provider.of<AudioPlayerVM>(context, listen: false);

    return ListTile(
      // generating the audio item left (leading) menu ...
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          final RenderBox listTileBox = context.findRenderObject() as RenderBox;
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
                key: const Key('popup_menu_rename_audio_file'),
                value: AudioPopupMenuAction.renameAudioFile,
                child: Text(AppLocalizations.of(context)!.renameAudioFile),
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
                child: Text(AppLocalizations.of(context)!
                    .deleteAudioFromPlaylistAswell),
              ),
            ],
            elevation: 8,
          ).then((value) {
            if (value != null) {
              switch (value) {
                case AudioPopupMenuAction.openYoutubeVideo:
                  openUrlInExternalApp(url: audio.videoUrl);
                  break;
                case AudioPopupMenuAction.copyYoutubeVideoUrl:
                  Clipboard.setData(ClipboardData(text: audio.videoUrl));
                  break;
                case AudioPopupMenuAction.displayAudioInfo:
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AudioInfoDialogWidget(
                        audio: audio,
                      );
                    },
                  );
                  break;
                case AudioPopupMenuAction.renameAudioFile:
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AudioFileRenameDialogWidget(
                        audio: audio,
                      );
                    },
                  );
                  break;
                case AudioPopupMenuAction.moveAudioToPlaylist:
                  PlaylistListVM expandablePlaylistVM =
                      getAndInitializeExpandablePlaylistListVM(context);

                  showDialog<dynamic>(
                    context: context,
                    builder: (context) => PlaylistOneSelectableDialogWidget(
                      usedFor: PlaylistOneSelectableDialogUsedFor
                          .moveAudioToPlaylist,
                      warningMessageVM: warningMessageVM,
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

                    bool keepAudioDataInSourcePlaylist =
                        resultMap['keepAudioDataInSourcePlaylist'];

                    expandablePlaylistVM.moveAudioToPlaylist(
                      audio: audio,
                      targetPlaylist: targetPlaylist,
                      keepAudioInSourcePlaylistDownloadedAudioLst:
                          keepAudioDataInSourcePlaylist,
                    );
                  });
                  break;
                case AudioPopupMenuAction.copyAudioToPlaylist:
                  PlaylistListVM expandablePlaylistVM =
                      getAndInitializeExpandablePlaylistListVM(context);

                  showDialog<dynamic>(
                    context: context,
                    builder: (context) => PlaylistOneSelectableDialogWidget(
                      usedFor: PlaylistOneSelectableDialogUsedFor
                          .copyAudioToPlaylist,
                      warningMessageVM: warningMessageVM,
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
                  Provider.of<PlaylistListVM>(
                    context,
                    listen: false,
                  ).deleteAudioMp3(audio: audio);
                  break;
                case AudioPopupMenuAction.deleteAudioFromPlaylistAswell:
                  Provider.of<PlaylistListVM>(
                    context,
                    listen: false,
                  ).deleteAudioFromPlaylistAswell(audio: audio);
                  break;
                default:
                  break;
              }
            }
          });
        },
      ),
      title: GestureDetector(
        onTap: () async {
          await dragToAudioPlayerView(
              audioGlobalPlayerVM); // dragging to the AudioPlayerView screen
        },
        child: Text(audio.validVideoTitle,
            style: const TextStyle(fontSize: kAudioTitleFontSize)),
      ),
      subtitle: GestureDetector(
        onTap: () async {
          await dragToAudioPlayerView(
              audioGlobalPlayerVM); // dragging to the AudioPlayerView screen
        },
        child: Text(
          _buildSubTitle(context),
          style: const TextStyle(fontSize: kAudioTitleFontSize),
        ),
      ),
      trailing: _buildPlayButton(),
    );
  }

  /// Method called when the user clicks on the audio list item
  /// play icon button. This switches to the AudioPlayerView screen
  /// and plays the clicked audio.
  Future<void> _dragToAudioPlayerViewAndPlayAudio(
      AudioPlayerVM audioGlobalPlayerVM) async {
    await audioGlobalPlayerVM.setCurrentAudio(audio);
    await audioGlobalPlayerVM.goToAudioPlayPosition(
      durationPosition: Duration(seconds: audio.audioPositionSeconds),
      isUndoRedo: true, // necessary to avoid creating an undo
      //                   command which would activate the undo
      //                   icon button
    );
    await audioGlobalPlayerVM.playFromCurrentAudioFile();

    // dragging to the AudioPlayerView screen
    onPageChangedFunction(ScreenMixin.AUDIO_PLAYER_VIEW_DRAGGABLE_INDEX);
  }

  /// Method called when the user clicks on the audio list item.
  /// This switches to the AudioPlayerView screen without playing
  /// the clicked audio.
  Future<void> dragToAudioPlayerView(AudioPlayerVM audioGlobalPlayerVM) async {
    await audioGlobalPlayerVM.setCurrentAudio(audio);
    await audioGlobalPlayerVM.goToAudioPlayPosition(
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

  PlaylistListVM getAndInitializeExpandablePlaylistListVM(
      BuildContext context) {
    PlaylistListVM expandablePlaylistVM =
        Provider.of<PlaylistListVM>(context, listen: false);

    // Resetting the selected playlist to null,
    // otherwise, if the user selects a playlist, click
    // on Confirm button and then opens the dialog again and
    // clicks on the Cancel button, the previously selected
    // playlist used as target playlist is still selected
    // expandablePlaylistVM.setUniqueSelectedPlaylist(
    //   selectedPlaylist: null,
    // );

    return expandablePlaylistVM;
  }

  String _buildSubTitle(BuildContext context) {
    String subTitle;

    Duration? audioDuration = audio.audioDuration;
    int audioFileSize = audio.audioFileSize;
    String audioFileSizeStr;

    audioFileSizeStr = UiUtil.formatLargeIntValue(
      context: context,
      value: audioFileSize,
    );

    int audioDownloadSpeed = audio.audioDownloadSpeed;
    String audioDownloadSpeedStr;

    if (audioDownloadSpeed.isInfinite) {
      audioDownloadSpeedStr = 'infinite o/sec';
    } else {
      audioDownloadSpeedStr = '${UiUtil.formatLargeIntValue(
        context: context,
        value: audioDownloadSpeed,
      )}/sec';
    }

    subTitle =
        '${audioDuration!.HHmmss()}. $audioFileSizeStr ${AppLocalizations.of(context)!.atPreposition} $audioDownloadSpeedStr ${AppLocalizations.of(context)!.on} ${frenchDateTimeFormat.format(audio.audioDownloadDateTime)}';
    return subTitle;
  }

  Widget _buildPlayButton() {
    return Consumer<AudioPlayerVM>(
      builder: (context, audioGlobalPlayerVM, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayOrPauseIcon(context, audioGlobalPlayerVM, audio)
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
  InkWell _buildPlayOrPauseIcon(
    BuildContext context,
    AudioPlayerVM audioGlobalPlayerVM,
    Audio audio,
  ) {
    Widget iconContent; // This will hold the content of the play button

    if (audio.isPlayingOrPausedWithPositionBetweenAudioStartAndEnd) {
      // if (audio.audioPositionSeconds > 0 &&
      //     audio.audioPositionSeconds < audio.audioDuration!.inSeconds) {
      // the audio is paused on a non-zero position and non end
      // position, i.e. if it was played and paused ...
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

      iconContent = CircleAvatar(
        backgroundColor:
            kDarkAndLightEnabledIconColor, // background color of the circle
        radius: 10,
        child: Icon(
          playOrPauseIcon.icon,
          color: Colors.white, // icon color
          size: 18, // icon size
        ),
      );
    } else {
      // the audio is neither playing nor paused. It is at position
      // zero, i.e. if it was not played ... or at the end position,
      // i.e. if it was played until the end and stopped.
      Color backgroundColor;

      if (Theme.of(context).brightness == Brightness.dark) {
        backgroundColor = Colors.black;
      } else {
        backgroundColor = Colors.white;
      }

      iconContent = CircleAvatar(
        backgroundColor: backgroundColor, // background color of the circle
        radius: 12, // you can adjust the size
        child: const Icon(
          Icons.play_arrow,
          color: kDarkAndLightEnabledIconColor, // icon color
          size: 24, // icon size
        ),
      );
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
          await _dragToAudioPlayerViewAndPlayAudio(audioGlobalPlayerVM);
        } else {
          // if the audio is playing, the displayed icon is
          // the pause icon. Clicking on it will pause the
          // audio without switching to the AudioPlayerView
          // screen.
          await audioGlobalPlayerVM.pause();
        }
      },
      child: SizedBox(
        width: 45, // Adjust this width based on the size of your largest icon
        child: Center(child: iconContent),
      ),
    );
  }
}
