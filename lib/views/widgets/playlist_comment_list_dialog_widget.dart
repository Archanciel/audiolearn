import 'package:audiolearn/models/audio.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/utils/duration_expansion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/comment.dart';
import '../../models/playlist.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';
import 'confirm_action_dialog_widget.dart';
import 'comment_add_edit_dialog_widget.dart';

/// This widget displays a dialog with the list of positionned
/// comment of the audio contained in the playlist.
///
/// When a comment is clicked, this opens a dialog to edit the
/// comment.
class PlaylistCommentListDialogWidget extends StatefulWidget {
  final Playlist currentPlaylist;

  const PlaylistCommentListDialogWidget({
    super.key,
    required this.currentPlaylist,
  });

  @override
  State<PlaylistCommentListDialogWidget> createState() =>
      _PlaylistCommentListDialogWidgetState();
}

class _PlaylistCommentListDialogWidgetState
    extends State<PlaylistCommentListDialogWidget> with ScreenMixin {
  final FocusNode _focusNodeDialog = FocusNode();
  Comment? _playingComment;
  final ScrollController _scrollController = ScrollController();
  late int _currentCommentIndex;
  final double _itemHeight = 70.0;

  @override
  void dispose() {
    _focusNodeDialog.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(context);

    // Retrieve the screen width using MediaQuery
    double maxDropdownWidth =
        computeMaxDialogListItemWidth(context) - kSmallIconButtonWidth;

    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      _focusNodeDialog,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Ok'
            // TextButton onPressed callback
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            Flexible(
              child: Text(
                AppLocalizations.of(context)!.playlistCommentsDialogTitle,
                maxLines: 2,
                softWrap: true,
              ),
            ),
          ],
        ),
        actionsPadding: kDialogActionsPadding,
        content: Consumer<CommentVM>(
          builder: (context, commentVM, child) {
            Map<String, List<Comment>> playlistAudiosCommentsMap =
                commentVM.getAllPlaylistComments(
              playlist: widget.currentPlaylist,
            );

            // Obtaining the list of audio file name playlistAudiosCommentsMap
            // keys and sorting them. Since the audio file names are formatted
            // as YYMMDD-HHMMSS-audio name YYMMDD, YYMMDD-HHMMSS being the
            // audio download date time and YYMMDD being the video upload date,
            // sorting the audio file names sorts them by the audio download
            // date time. So, the list starts with the first downloaded audio
            // and ends with the last downloaded audio.
            List<String> audioFileNamesLst =
                playlistAudiosCommentsMap.keys.toList();
            audioFileNamesLst.sort((a, b) => a.compareTo(b));

            return SingleChildScrollView(
              controller: _scrollController,
              child: ListBody(
                children: _buildPlaylistAudiosCommentsList(
                  commentVM: commentVM,
                  playlistAudiosCommentsMap: playlistAudiosCommentsMap,
                  audioFileNamesLst: audioFileNamesLst,
                  maxDropdownWidth: maxDropdownWidth,
                  isDarkTheme: themeProviderVM.currentTheme == AppTheme.dark,
                ),
              ),
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('closeDialogTextButton'),
            child: Text(
              AppLocalizations.of(context)!.closeTextButton,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlaylistAudiosCommentsList({
    required CommentVM commentVM,
    required Map<String, List<Comment>> playlistAudiosCommentsMap,
    required List<String> audioFileNamesLst,
    required double maxDropdownWidth,
    required bool isDarkTheme,
  }) {
    AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );
    String currentAudioFileName = widget.currentPlaylist
        .getCurrentOrLastlyPlayedAudioContainedInPlayableAudioLst()!
        .audioFileName;
    currentAudioFileName = currentAudioFileName.substring(
      0,
      currentAudioFileName.length - 4,
    );

    List<Widget> widgets = [];
    Color? audioTitleTextColor;
    Color? audioTitleBackgroundColor;
    int currentCommentIndex = 0;

    for (String audioFileName in audioFileNamesLst) {
      if (audioFileName == currentAudioFileName) {
        audioTitleTextColor = Colors.white;
        audioTitleBackgroundColor = Colors.blue;
      } else {
        audioTitleTextColor = (isDarkTheme)
            ? kSliderThumbColorInDarkMode
            : kSliderThumbColorInLightMode;
        audioTitleBackgroundColor = null;
      }
      // Display the audio file name
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            DateTimeUtil.removeDateTimeElementsFromFileName(
              audioFileName,
            ),
            style: TextStyle(
              color: audioTitleTextColor,
              backgroundColor: audioTitleBackgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );

      // Adding the comments number correspomding to the audioFileName
      List<Comment> audioCommentsLst =
          playlistAudiosCommentsMap[audioFileName]!;
      currentCommentIndex += audioCommentsLst.length;

      if (audioFileName == currentAudioFileName) {
        _currentCommentIndex = currentCommentIndex;
      }

      for (Comment comment in audioCommentsLst) {
        widgets.add(
          GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: _buildCommentTitlePlusIconsAndCommentDatesAndPosition(
                    audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                    audioFileNameNoExt: audioFileName,
                    commentVM: commentVM,
                    maxDropdownWidth: maxDropdownWidth,
                    comment: comment,
                  ),
                ),
                if (comment.content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    // comment content Text
                    child: Text(
                      key: const Key('commentTextKey'),
                      comment.content,
                    ),
                  ),
              ],
            ),
            onTap: () async {
              if (audioPlayerVMlistenFalse.isPlaying &&
                  _playingComment != comment) {
                // if the user clicks on a comment while another
                // comment is playing, the playing comment is paused.
                // Otherwise, the edited comment keeps playing.
                await audioPlayerVMlistenFalse.pause();
              }

              await _closeDialogAndOpenCommentAddEditDialog(
                context: context,
                audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                audioFileNameNoExt: audioFileName,
                comment: comment,
              );
            },
          ),
        );
      }
    }

    _scrollToCurrentAudioItem();

    return widgets;
  }

  Widget _buildCommentTitlePlusIconsAndCommentDatesAndPosition({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required String audioFileNameNoExt,
    required CommentVM commentVM,
    required double maxDropdownWidth,
    required Comment comment,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                width: maxDropdownWidth,
                // comment title Text
                child: Text(
                  key: const Key('commentTitleKey'),
                  comment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: kSmallestButtonWidth,
                  child: IconButton(
                    // Play/Pause icon button
                    key: const Key('playPauseIconButton'),
                    onPressed: () async {
                      // this logic enables that when we
                      // click on the play button of a comment,
                      // if an other comment is playing, it is
                      // paused
                      (_playingComment != null &&
                              _playingComment == comment &&
                              audioPlayerVMlistenFalse.isPlaying)
                          ? await audioPlayerVMlistenFalse
                              .pause() // clicked on currently playing comment pause button
                          : await _playFromCommentPosition(
                              // clicked on other comment play button
                              audioPlayerVM: audioPlayerVMlistenFalse,
                              audioFileNameNoExt: audioFileNameNoExt,
                              comment: comment,
                            );
                    },
                    icon: Consumer<AudioPlayerVM>(
                      builder: (context, audioPlayerVMlistenTrue, child) {
                        // The code below ensures that the audio player is
                        // paused when the current comment end audio position
                        // is reached.
                        if (_playingComment != null &&
                            _playingComment == comment &&
                            audioPlayerVMlistenTrue.currentAudioPosition >=
                                Duration(
                                    milliseconds: comment
                                            .commentEndPositionInTenthOfSeconds *
                                        100)) {
                          audioPlayerVMlistenTrue.pause().then((_) {});
                        }

                        // this logic avoids that when the
                        // user clicks on the play button of a
                        // comment, the play button of the
                        // other comment are updated to 'pause'
                        return Icon((_playingComment != null &&
                                _playingComment == comment &&
                                audioPlayerVMlistenTrue.isPlaying)
                            ? Icons.pause
                            : Icons.play_arrow);
                      },
                    ),
                    iconSize: kSmallestButtonWidth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(), // Ensure the button
                    //                                      takes minimal space
                  ),
                ),
                SizedBox(
                  width: kSmallestButtonWidth,
                  child: IconButton(
                    // delete comment icon button
                    key: const Key('deleteCommentIconButton'),
                    onPressed: () async {
                      await _confirmDeleteComment(
                        audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                        audioFileNameNoExt: audioFileNameNoExt,
                        commentVM: commentVM,
                        comment: comment,
                      );
                    },
                    icon: const Icon(
                      Icons.clear,
                    ),
                    iconSize: kSmallestButtonWidth - 5,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(), // Ensure the button
                    //                                      takes minimal space
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Tooltip(
                  message:
                      AppLocalizations.of(context)!.commentCreationDateTooltip,
                  child: Text(
                    // comment creation date Text
                    key: const Key('creationDateTimeKey'),
                    style: const TextStyle(fontSize: 13),
                    frenchDateFormat.format(comment.creationDateTime),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                (comment.lastUpdateDateTime.day != comment.creationDateTime.day)
                    ? Tooltip(
                        message: AppLocalizations.of(context)!
                            .commentUpdateDateTooltip,
                        child: Text(
                          // comment update date Text
                          key: const Key('lastUpdateDateTimeKey'),
                          style: const TextStyle(fontSize: 13),
                          frenchDateFormat.format(comment.lastUpdateDateTime),
                        ),
                      )
                    : Container(),
              ],
            ),
            Row(
              children: [
                Tooltip(
                  message:
                      AppLocalizations.of(context)!.commentStartPositionTooltip,
                  child: Text(
                    // comment position Text
                    key: const Key('commentPositionKey'),
                    style: const TextStyle(fontSize: 13),
                    Duration(
                            milliseconds:
                                comment.commentStartPositionInTenthOfSeconds *
                                    100)
                        .HHmmssZeroHH(),
                  ),
                ),
                const SizedBox(width: 11),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// In order to avoid keyboard opening and closing continuously after
  /// opening the CommentAddEditDialogWidget, the current dialog must be
  /// closed before opening the CommentAddEditDialogWidget.
  Future<void> _closeDialogAndOpenCommentAddEditDialog({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required String audioFileNameNoExt,
    Comment? comment,
  }) async {
    Navigator.of(context).pop(); // closes the current dialog

    await audioPlayerVMlistenFalse.setCurrentAudio(
        audio: widget.currentPlaylist.getAudioByFileNameNoExt(
      audioFileNameNoExt: audioFileNameNoExt,
    )!);

    showDialog<void>(
      context: context,
      barrierDismissible:
          false, // This line prevents the dialog from closing when
      //        tapping outside the dialog
      // instanciating CommentAddEditDialogWidget without
      // passing a comment opens it in 'add' mode
      builder: (context) => CommentAddEditDialogWidget(
        callerDialog: CallerDialog.playlistCommentListAddDialog,
        comment: comment,
      ),
    );
  }

  Future<void> _confirmDeleteComment({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required String audioFileNameNoExt,
    required CommentVM commentVM,
    required Comment comment,
  }) async {
    Audio currentAudio = widget.currentPlaylist.getAudioByFileNameNoExt(
      audioFileNameNoExt: audioFileNameNoExt,
    )!;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmActionDialogWidget(
          actionFunction: commentVM.deleteCommentFunction,
          actionFunctionArgs: [
            comment.id,
            currentAudio,
          ],
          dialogTitle: AppLocalizations.of(context)!.deleteCommentConfirnTitle,
          dialogContent: AppLocalizations.of(context)!
              .deleteCommentConfirnBody(comment.title),
        );
      },
    );

    if (audioPlayerVMlistenFalse.isPlaying) {
      await audioPlayerVMlistenFalse.pause();
    }
  }

  Future<void> _playFromCommentPosition({
    required AudioPlayerVM audioPlayerVM,
    required Comment comment,
    required String audioFileNameNoExt,
  }) async {
    _playingComment = comment;

    await audioPlayerVM.setCurrentAudio(
      audio: widget.currentPlaylist.getAudioByFileNameNoExt(
        audioFileNameNoExt: audioFileNameNoExt,
      )!,
    );

    if (!audioPlayerVM.isPlaying) {
      // This fixes a problem when a playing comment was paused and
      // then the user clicked on the play button of an other comment.
      // In such a situation, the user had to click twice or three
      // times on the other comment play button to play it if the other
      // comment was positioned before the previously played comment.
      // If the other comment was positioned after the previously played
      // comment, then the user had to click only once on the play button
      // of the other comment to play it.
      await audioPlayerVM.playCurrentAudio(
        rewindAudioPositionBasedOnPauseDuration: false,
        isCommentPlaying: true,
      );
    }

    await audioPlayerVM.modifyAudioPlayerPluginPosition(
      Duration(
          milliseconds: comment.commentStartPositionInTenthOfSeconds * 100),
    );

    await audioPlayerVM.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      isCommentPlaying: true,
    );
  }

  void _scrollToCurrentAudioItem() {
    if (_currentCommentIndex <= 4) {
      // this avoids scrolling down when the currenz audio is
      // in the top part of the audio list. Without that, the
      // list is unusefully scrolled down and the user has to scroll
      // up to see top audios
      return;
    }

    double multiplier = _currentCommentIndex.toDouble();

    if (_currentCommentIndex > 300) {
      multiplier *= 1.23;
    } else if (_currentCommentIndex > 200) {
      multiplier *= 1.21;
    } else if (_currentCommentIndex > 120) {
      multiplier *= 1.2;
    }

    double offset = multiplier * _itemHeight;

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
      _scrollController.animateTo(
        offset,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    } else {
      // The scroll controller isn't attached to any scroll views.
      // Schedule a callback to try again after the next frame.
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToCurrentAudioItem());
    }
  }
}
