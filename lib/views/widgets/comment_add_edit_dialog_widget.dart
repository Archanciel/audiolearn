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
  bool _reducePositionDurationChange = false;

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
        _titleController.text = widget.comment!.title;
        _commentController.text = widget.comment!.content;
        commentVM.currentCommentAudioPosition = Duration(
            milliseconds: widget.comment!.audioPositionInTenthOfSeconds * 100);
      } else {
        commentVM.currentCommentAudioPosition =
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
            // Non-editable Text for Audio File Details
            // Audio Playback Controls
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  globalAudioPlayerVM.currentAudio?.validVideoTitle ?? '',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
                      height: ScreenMixin.CHECKBOX_WIDTH_HEIGHT,
                      child: Checkbox(
                        key: const Key('reducePositionDurationChangeCheckbox'),
                        value: _reducePositionDurationChange,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _reducePositionDurationChange = newValue ?? false;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: IconButton(
                        key: const Key('backwardOneSecondIconButton'),
                        // Rewind 1 second button
                        icon: const Icon(Icons.fast_rewind),
                        onPressed: () async {
                          await modifyCommentPosition(
                            commentVMlistenFalse: commentVMlistenFalse,
                            millisecondsChange:
                                _reducePositionDurationChange ? -100 : -1000,
                          );
                        },
                        iconSize: _reducePositionDurationChange
                            ? kSmallestButtonWidth * 0.8
                            : kSmallestButtonWidth,
                      ),
                    ),
                    Consumer<CommentVM>(
                      builder: (context, commentVM, child) {
                        // Text for the current comment audio position
                        return Text(
                          _reducePositionDurationChange
                          // if the reduce position duration change checkbox
                          // is checked, the audio position is displayed with
                          // a tenth of a second value after the seconds value
                              ? commentVM.currentCommentAudioPosition
                                  .HHmmssZeroHH(
                                      addRemainingOneDigitTenthOfSecond: true)
                              : commentVM.currentCommentAudioPosition
                                  .HHmmssZeroHH(),
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
                          await modifyCommentPosition(
                            commentVMlistenFalse: commentVMlistenFalse,
                            millisecondsChange:
                                _reducePositionDurationChange ? 100 : 1000,
                          );
                        },
                        iconSize: _reducePositionDurationChange
                            ? kSmallestButtonWidth * 0.8
                            : kSmallestButtonWidth,
                      ),
                    ),
                    IconButton(
                      // Play/Pause button
                      key: const Key('playPauseIconButton'),
                      onPressed: () async {
                        globalAudioPlayerVM.isPlaying
                            ? await globalAudioPlayerVM.pause()
                            : await _playFromCommentPosition(
                                commentVMlistenFalse: commentVMlistenFalse,
                              );
                      },
                      icon: Consumer<AudioPlayerVM>(
                        builder: (context, globalAudioPlayerVM, child) {
                          return Icon(globalAudioPlayerVM.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow);
                        },
                      ),
                      iconSize: kUpDownButtonSize - 10,
                      constraints: const BoxConstraints(), // Ensure the button
                      //                         takes minimal space
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
                          .currentCommentAudioPosition.inMilliseconds ~/
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
                          .currentCommentAudioPosition.inMilliseconds ~/
                      100;

              commentVMlistenFalse.modifyComment(
                modifiedComment: commentToModify,
                commentedAudio: globalAudioPlayerVM.currentAudio!,
              );
            }

            _closeDialogAndReOpenCommentListAddDialog(context);
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

  /// Since before opening the CommentAddEditDialogWidget its caller, the
  /// CommentListAddDialogWidget, was closed, this caller dialog must be
  /// re-opened in order to display the updated list of comments.
  void _closeDialogAndReOpenCommentListAddDialog(
    BuildContext context,
  ) {
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
      globalAudioPlayerVM.pause();
    }
  }

  Future<void> _playFromCommentPosition({
    required CommentVM commentVMlistenFalse,
  }) async {
    await globalAudioPlayerVM.modifyAudioPlayerPluginPosition(
      commentVMlistenFalse.currentCommentAudioPosition,
    );

    await globalAudioPlayerVM.playFromCurrentAudioFile(
      rewindAudioPositionBasedOnPauseDuration: false,
    );
  }

  Future<void> modifyCommentPosition({
    required CommentVM commentVMlistenFalse,
    required int millisecondsChange,
  }) async {
    commentVMlistenFalse.currentCommentAudioPosition =
        commentVMlistenFalse.currentCommentAudioPosition +
            Duration(milliseconds: millisecondsChange);

    await globalAudioPlayerVM.modifyAudioPlayerPluginPosition(
      commentVMlistenFalse.currentCommentAudioPosition,
    );

    await globalAudioPlayerVM.playFromCurrentAudioFile(
      rewindAudioPositionBasedOnPauseDuration: false,
    );
  }
}
