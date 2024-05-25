import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/comment.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../views/screen_mixin.dart';
import '../../utils/duration_expansion.dart';
import 'comment_list_add_dialog_widget.dart';

/// This widget displays a dialog to add or edit a comment.
/// The edit mode is activated when a comment is passed to the
/// widget constructor. Else, the widget is in add mode.
class CommentAddEditDialogWidget extends StatefulWidget {
  final Comment? comment;
  final bool isAddMode;

  const CommentAddEditDialogWidget({
    super.key,
    this.comment,
  }) : isAddMode = comment == null;

  @override
  State<CommentAddEditDialogWidget> createState() =>
      _CommentAddEditDialogWidgetState();
}

class _CommentAddEditDialogWidgetState extends State<CommentAddEditDialogWidget>
    with ScreenMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNodeCommentTitle = FocusNode();
  bool _modifyPositionDurationChangeInTenthOfSeconds = false;
  bool _modifyCommentEndPositionDurationChangeInTenthOfSeconds = false;
  bool _playButtonWasClicked = true;
  bool _forwardingCommentEndPositionSituation = false;
  bool _backwardingCommentEndPositionSituation = false;

  @override
  void initState() {
    super.initState();

    // Important to set the current comment audio position after the
    // build method has been executed since the commentVM notifies
    // listeners when the currentCommentAudioPosition is set.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CommentVM commentVM = Provider.of<CommentVM>(
        context,
        listen: false,
      );

      if (widget.comment != null) {
        // here, we are editing a comment
        _titleController.text = widget.comment!.title;
        _commentController.text = widget.comment!.content;
        commentVM.currentCommentStartAudioPosition = Duration(
            milliseconds: widget.comment!.audioPositionInTenthOfSeconds * 100);
        Duration commentEndPosition = Duration(
            milliseconds:
                widget.comment!.commentEndAudioPositionInTenthOfSeconds * 100);
        if (commentEndPosition < globalAudioPlayerVM.currentAudioPosition) {
          commentVM.currentCommentEndAudioPosition =
              globalAudioPlayerVM.currentAudioPosition;
        } else {
          // the user has positioned the play audio view audio position after
          // the current comment end audio position in order to increase the
          // comment end audio position
          commentVM.currentCommentEndAudioPosition = commentEndPosition;
        }
      } else {
        // here, we are creating a comment
        commentVM.currentCommentStartAudioPosition =
            globalAudioPlayerVM.currentAudioPosition;
        commentVM.currentCommentEndAudioPosition =
            globalAudioPlayerVM.currentAudioPosition;
      }
    });
  }

  @override
  void dispose() {
    _focusNodeCommentTitle.dispose();
    _titleController.dispose();
    _commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(
      _focusNodeCommentTitle,
    );

    CommentVM commentVMlistenFalse = Provider.of<CommentVM>(
      context,
      listen: false,
    );

    // Since it is necessary that Enter can be used in comment text field
    // to add a new line, using KeyListener and FocusNode must be avoided.
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.commentDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField for Title
            SizedBox(
              height: kDialogTextFieldHeight,
              child: TextField(
                key: const Key('commentTitleTextField'),
                controller: _titleController,
                style: kDialogTextFieldBoldStyle,
                decoration: getDialogTextFieldInputDecoration(
                  hintText: AppLocalizations.of(context)!.commentTitle,
                ),
                focusNode: _focusNodeCommentTitle,
              ),
            ),
            const SizedBox(height: 10),
            // Multiline TextField for Comments
            TextField(
              key: const Key('commentContentTextField'),
              controller: _commentController,
              style: kDialogTextFieldStyle,
              minLines: 2,
              maxLines: 3,
              decoration: getDialogTextFieldInputDecoration(
                hintText: AppLocalizations.of(context)!.commentText,
              ),
            ),
            const SizedBox(height: 30),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Commented audio title
                Text(
                  globalAudioPlayerVM.currentAudio?.validVideoTitle ?? '',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        _buildModifyCommentStartPosition(
                            context, commentVMlistenFalse),
                        _buildModifyCommentEndPosition(
                            context, commentVMlistenFalse),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          // Play/Pause button
                          key: const Key('playPauseIconButton'),
                          onPressed: () async {
                            if (globalAudioPlayerVM.isPlaying) {
                              await globalAudioPlayerVM.pause();

                              // modify the end audio position if the end
                              // audio position is before or equal to the
                              // current audio position
                              if (commentVMlistenFalse
                                      .currentCommentEndAudioPosition <=
                                  commentVMlistenFalse
                                      .currentCommentStartAudioPosition) {
                                commentVMlistenFalse
                                        .currentCommentEndAudioPosition =
                                    globalAudioPlayerVM.currentAudioPosition;
                              }
                            } else {
                              _playButtonWasClicked = true;
                              _forwardingCommentEndPositionSituation = false;
                              _backwardingCommentEndPositionSituation = false;

                              await _playFromCommentPosition(
                                  commentVMlistenFalse: commentVMlistenFalse);
                            }
                          },
                          icon: Consumer<AudioPlayerVM>(
                            // Setting the icon as Consumer of AudioPlayerVM
                            // enables the icon to change according to the
                            // audio player VM state.
                            //
                            // Additionally, the code below ensures that the
                            // audio player is paused when the current comment
                            // end audio position is reached.
                            builder: (context, audioPlayerVMlistenTrue, child) {
                              if (!_forwardingCommentEndPositionSituation ||
                                  !_backwardingCommentEndPositionSituation) {
                                if (commentVMlistenFalse
                                        .currentCommentEndAudioPosition >
                                    commentVMlistenFalse
                                        .currentCommentStartAudioPosition) {
                                  // situation in which the current comment end
                                  // audio position was set
                                  if (audioPlayerVMlistenTrue
                                          .currentAudioPosition >=
                                      commentVMlistenFalse
                                          .currentCommentEndAudioPosition) {
                                    // here, the audio player reached the
                                    // current comment end audio position
                                    if (_playButtonWasClicked) {
                                      // if the audio player was stopped after
                                      // reaching the current comment end audio,
                                      // the user must be able to play the audio
                                      // again from the current comment audio
                                      // start position
                                      _playButtonWasClicked = false;
                                    } else {
                                      audioPlayerVMlistenTrue
                                          .pause()
                                          .then((_) {
                                        // enables the user to play the audio again
                                        // from the current comment audio start
                                        // position
                                        _playButtonWasClicked = true;
                                      });
                                    }
                                  }
                                }
                              } else {
                                if (commentVMlistenFalse
                                        .currentCommentEndAudioPosition >
                                    commentVMlistenFalse
                                        .currentCommentStartAudioPosition) {
                                  // situation in which the current comment end
                                  // audio position was set
                                  if (audioPlayerVMlistenTrue
                                          .currentAudioPosition >=
                                      commentVMlistenFalse
                                          .currentCommentEndAudioPosition) {
                                    // here, the audio player reached the
                                    // current comment end audio position
                                    audioPlayerVMlistenTrue.pause().then((value) => null);
                                  }
                                }
                              }

                              return Icon(audioPlayerVMlistenTrue.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow);
                            },
                          ),
                          iconSize: kUpDownButtonSize - 10,
                          constraints:
                              const BoxConstraints(), // Ensure the button
                          //                         takes minimal space
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('addOrUpdateCommentTextButton'),
          child: Text(
            widget.isAddMode
                ? AppLocalizations.of(context)!.add
                : AppLocalizations.of(context)!.update,
          ),
          onPressed: () async {
            if (widget.isAddMode) {
              commentVMlistenFalse.addComment(
                comment: Comment(
                  title: _titleController.text,
                  content: _commentController.text,
                  audioPositionInTenthOfSeconds: commentVMlistenFalse
                          .currentCommentStartAudioPosition.inMilliseconds ~/
                      100,
                  commentEndAudioPositionInTenthOfSeconds: commentVMlistenFalse
                          .currentCommentEndAudioPosition.inMilliseconds ~/
                      100,
                ),
                audioToComment: globalAudioPlayerVM.currentAudio!,
              );
            } else {
              Comment commentToModify = widget.comment!;

              commentToModify.title = _titleController.text;
              commentToModify.content = _commentController.text;
              commentToModify.audioPositionInTenthOfSeconds =
                  commentVMlistenFalse
                          .currentCommentStartAudioPosition.inMilliseconds ~/
                      100;
              commentToModify.commentEndAudioPositionInTenthOfSeconds =
                  commentVMlistenFalse
                          .currentCommentEndAudioPosition.inMilliseconds ~/
                      100;

              commentVMlistenFalse.modifyComment(
                modifiedComment: commentToModify,
                commentedAudio: globalAudioPlayerVM.currentAudio!,
              );
            }

            await _closeDialogAndReOpenCommentListAddDialog(context);
          },
        ),
        TextButton(
          key: const Key('cancelTextButton'),
          child: Text(AppLocalizations.of(context)!.cancelButton),
          onPressed: () async =>
              _closeDialogAndReOpenCommentListAddDialog(context),
        ),
      ],
    );
  }

  Row _buildModifyCommentStartPosition(
      BuildContext context, CommentVM commentVMlistenFalse) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
          height: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
          child: Tooltip(
            message:
                AppLocalizations.of(context)!.tenthOfSecondsCheckboxTooltip,
            child: Checkbox(
              key: const Key('modifyPositionDurationChangeInTenthOfSeconds'),
              value: _modifyPositionDurationChangeInTenthOfSeconds,
              onChanged: (bool? newValue) {
                setState(() {
                  _modifyPositionDurationChangeInTenthOfSeconds =
                      newValue ?? false;
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            key: const Key('backwardOneSecondIconButton'),
            // Rewind 1 second button
            icon: const Icon(Icons.fast_rewind),
            onPressed: () async {
              await _modifyCommentStartPosition(
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _modifyPositionDurationChangeInTenthOfSeconds
                        ? -100
                        : -1000,
              );
            },
            iconSize: _modifyPositionDurationChangeInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
        Consumer<CommentVM>(
          builder: (context, commentVM, child) {
            // Text for the current comment audio position
            return Text(
              _modifyPositionDurationChangeInTenthOfSeconds
                  // if the modify position duration change in tenth
                  // of seconds checkbox is checked, the audio
                  // position is displayed with a tenth of a second
                  // value after the seconds value
                  ? commentVM.currentCommentStartAudioPosition
                      .HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true)
                  : commentVM.currentCommentStartAudioPosition.HHmmssZeroHH(),
            );
          },
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            // Forward 1 second button
            key: const Key('forwardOneSecondIconButton'),
            icon: const Icon(Icons.fast_forward),
            onPressed: () async {
              await _modifyCommentStartPosition(
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _modifyPositionDurationChangeInTenthOfSeconds ? 100 : 1000,
              );
            },
            iconSize: _modifyPositionDurationChangeInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
      ],
    );
  }

  Row _buildModifyCommentEndPosition(
      BuildContext context, CommentVM commentVMlistenFalse) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
          height: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
          child: Tooltip(
            message:
                AppLocalizations.of(context)!.tenthOfSecondsCheckboxTooltip,
            child: Checkbox(
              key: const Key(
                  'modifyCommentEndPositionDurationChangeInTenthOfSeconds'),
              value: _modifyCommentEndPositionDurationChangeInTenthOfSeconds,
              onChanged: (bool? newValue) {
                setState(() {
                  _modifyCommentEndPositionDurationChangeInTenthOfSeconds =
                      newValue ?? false;
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            key: const Key('backwardCommentEndOneSecondIconButton'),
            // Rewind 1 second button
            icon: const Icon(Icons.fast_rewind),
            onPressed: () async {
              _backwardingCommentEndPositionSituation = true;
              _forwardingCommentEndPositionSituation = false;
              await _modifyCommentEndPosition(
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _modifyCommentEndPositionDurationChangeInTenthOfSeconds
                        ? -100
                        : -1000,
              );
            },
            iconSize: _modifyCommentEndPositionDurationChangeInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
        Consumer<CommentVM>(
          builder: (context, commentVM, child) {
            // Text for the current comment end audio position
            return Text(
              _modifyCommentEndPositionDurationChangeInTenthOfSeconds
                  // if the modify position duration change in tenth
                  // of seconds checkbox is checked, the audio
                  // position is displayed with a tenth of a second
                  // value after the seconds value
                  ? commentVM.currentCommentEndAudioPosition
                      .HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true)
                  : commentVM.currentCommentEndAudioPosition.HHmmssZeroHH(),
            );
          },
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            // Forward 1 second button
            key: const Key('forwardCommentEndOneSecondIconButton'),
            icon: const Icon(Icons.fast_forward),
            onPressed: () async {
              _forwardingCommentEndPositionSituation = true;
              _backwardingCommentEndPositionSituation = false;
              await _modifyCommentEndPosition(
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _modifyCommentEndPositionDurationChangeInTenthOfSeconds
                        ? 100
                        : 1000,
              );
            },
            iconSize: _modifyCommentEndPositionDurationChangeInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
      ],
    );
  }

  /// Since before opening the CommentAddEditDialogWidget its caller, the
  /// CommentListAddDialogWidget, was closed, this caller dialog must be
  /// re-opened in order to display the updated list of comments.
  Future<void> _closeDialogAndReOpenCommentListAddDialog(
    BuildContext context,
  ) async {
    // Closing first the current CommentAddEditDialogWidget dialog (... pop())
    // and then opening the CommentListAddDialogWidget dialog before pausing
    // the audio without using await on pause method avoids that if the audio
    // is playing when we close the CommentAddEditDialogWidget, the
    // CommentAddEditDialogWidget is re-opened !
    Navigator.of(context).pop();

    showDialog<void>(
      context: context,
      // passing the current audio to the dialog instead
      // of initializing a private _currentAudio variable
      // in the dialog avoid integr test problems
      builder: (context) => CommentListAddDialogWidget(
        currentAudio: globalAudioPlayerVM.currentAudio!,
      ),
    );

    if (globalAudioPlayerVM.isPlaying) {
      await globalAudioPlayerVM.pause();
    }
  }

  Future<void> _playFromCommentPosition({
    required CommentVM commentVMlistenFalse,
  }) async {
    await globalAudioPlayerVM.modifyAudioPlayerPluginPosition(
      commentVMlistenFalse.currentCommentStartAudioPosition,
    );

    await globalAudioPlayerVM.playFromCurrentAudioFile(
      rewindAudioPositionBasedOnPauseDuration: false,
    );
  }

  Future<void> _modifyCommentStartPosition({
    required CommentVM commentVMlistenFalse,
    required int millisecondsChange,
  }) async {
    commentVMlistenFalse.currentCommentStartAudioPosition =
        commentVMlistenFalse.currentCommentStartAudioPosition +
            Duration(milliseconds: millisecondsChange);

    await globalAudioPlayerVM.modifyAudioPlayerPluginPosition(
      commentVMlistenFalse.currentCommentStartAudioPosition,
    );

    await globalAudioPlayerVM.playFromCurrentAudioFile(
      rewindAudioPositionBasedOnPauseDuration: false,
    );
  }

  Future<void> _modifyCommentEndPosition({
    required CommentVM commentVMlistenFalse,
    required int millisecondsChange,
  }) async {
    commentVMlistenFalse.currentCommentEndAudioPosition =
        commentVMlistenFalse.currentCommentEndAudioPosition +
            Duration(milliseconds: millisecondsChange);

      await globalAudioPlayerVM.modifyAudioPlayerPluginPosition(
        commentVMlistenFalse.currentCommentEndAudioPosition -
            const Duration(milliseconds: 200));

    await globalAudioPlayerVM.playFromCurrentAudioFile(
      rewindAudioPositionBasedOnPauseDuration: false,
    );
  }
}
