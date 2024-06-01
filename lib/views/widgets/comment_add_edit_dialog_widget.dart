import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/comment.dart';
import '../../services/settings_data_service.dart';
import '../../utils/date_time_util.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../views/screen_mixin.dart';
import '../../utils/duration_expansion.dart';
import 'comment_list_add_dialog_widget.dart';
import 'set_value_to_target_dialog_widget.dart';

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
  bool _commentStartPositionChangedInTenthOfSeconds = false;
  bool _commentEndPositionChangedInTenthOfSeconds = false;
  bool _playButtonWasClicked = true;
  bool _commentEndPositionIsModified = false;

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
        commentVM.currentCommentStartPosition = Duration(
            milliseconds:
                widget.comment!.commentStartPositionInTenthOfSeconds * 100);
        Duration commentEndPosition = Duration(
            milliseconds:
                widget.comment!.commentEndPositionInTenthOfSeconds * 100);
        commentVM.currentCommentEndPosition = commentEndPosition;
      } else {
        // here, we are creating a comment
        commentVM.currentCommentStartPosition =
            globalAudioPlayerVM.currentAudioPosition;
        commentVM.currentCommentEndPosition =
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
                        _buildCommentStartPositionRow(
                            context, commentVMlistenFalse),
                        _buildCommentEndPositionRow(
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

                              // Modify the end audio position if the end
                              // audio position is before or equal to the
                              // current audio position.
                              //
                              // In the situation when a new comment is
                              // created, it is useful to set the end audio
                              // position as the current audio play position
                              // when the user clicks on the pause button after
                              // having left the application play the audio
                              // till the comment end position.
                              if (commentVMlistenFalse
                                      .currentCommentEndPosition <=
                                  commentVMlistenFalse
                                      .currentCommentStartPosition) {
                                commentVMlistenFalse.currentCommentEndPosition =
                                    globalAudioPlayerVM.currentAudioPosition;
                              }
                            } else {
                              _playButtonWasClicked = true;
                              _commentEndPositionIsModified = false;

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
                              if (!_commentEndPositionIsModified) {
                                if (commentVMlistenFalse
                                        .currentCommentEndPosition >
                                    commentVMlistenFalse
                                        .currentCommentStartPosition) {
                                  // situation in which the current comment end
                                  // audio position was set
                                  if (audioPlayerVMlistenTrue
                                          .currentAudioPosition >=
                                      commentVMlistenFalse
                                          .currentCommentEndPosition) {
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
                                      audioPlayerVMlistenTrue.pause().then((_) {
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
                                        .currentCommentEndPosition >
                                    commentVMlistenFalse
                                        .currentCommentStartPosition) {
                                  // situation in which the current comment end
                                  // audio position was set
                                  if (audioPlayerVMlistenTrue
                                          .currentAudioPosition >=
                                      commentVMlistenFalse
                                          .currentCommentEndPosition) {
                                    // here, the audio player reached the
                                    // current comment end audio position
                                    audioPlayerVMlistenTrue
                                        .pause()
                                        .then((value) => null);
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
                _buildAudioPlayerViewAudioPositionRow(
                  context: context,
                  commentVMlistenFalse: commentVMlistenFalse,
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
                  commentStartPositionInTenthOfSeconds: (commentVMlistenFalse
                              .currentCommentStartPosition.inMilliseconds /
                          100)
                      .round(),
                  commentEndPositionInTenthOfSeconds: (commentVMlistenFalse
                              .currentCommentEndPosition.inMilliseconds /
                          100)
                      .round(),
                ),
                audioToComment: globalAudioPlayerVM.currentAudio!,
              );
            } else {
              Comment commentToModify = widget.comment!;

              commentToModify.title = _titleController.text;
              commentToModify.content = _commentController.text;
              commentToModify.commentStartPositionInTenthOfSeconds =
                  (commentVMlistenFalse
                              .currentCommentStartPosition.inMilliseconds /
                          100)
                      .round();
              commentToModify.commentEndPositionInTenthOfSeconds =
                  (commentVMlistenFalse
                              .currentCommentEndPosition.inMilliseconds /
                          100)
                      .round();

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

  Row _buildCommentStartPositionRow(
    BuildContext context,
    CommentVM commentVMlistenFalse,
  ) {
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
              key: const Key('commentStartTenthOfSecondsCheckbox'),
              value: _commentStartPositionChangedInTenthOfSeconds,
              onChanged: (bool? newValue) {
                setState(() {
                  _commentStartPositionChangedInTenthOfSeconds =
                      newValue ?? false;
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            key: const Key('backwardCommentStartIconButton'),
            // Rewind 1 second button
            icon: const Icon(Icons.fast_rewind),
            onPressed: () async {
              await _modifyCommentStartPosition(
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _commentStartPositionChangedInTenthOfSeconds ? -100 : -1000,
              );
            },
            iconSize: _commentStartPositionChangedInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
        Consumer<CommentVM>(
          builder: (context, commentVM, child) {
            // Text for the current comment audio position
            return Text(
              key: const Key('commentStartPositionText'),
              _commentStartPositionChangedInTenthOfSeconds
                  // if the modify position duration change in tenth
                  // of seconds checkbox is checked, the audio
                  // position is displayed with a tenth of a second
                  // value after the seconds value
                  ? commentVM.currentCommentStartPosition
                      .HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true)
                  : commentVM.currentCommentStartPosition.HHmmssZeroHH(),
            );
          },
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            // Forward 1 second button
            key: const Key('forwardCommentStartIconButton'),
            icon: const Icon(Icons.fast_forward),
            onPressed: () async {
              await _modifyCommentStartPosition(
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _commentStartPositionChangedInTenthOfSeconds ? 100 : 1000,
              );
            },
            iconSize: _commentStartPositionChangedInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
      ],
    );
  }

  Row _buildCommentEndPositionRow(
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
              key: const Key('commentEndTenthOfSecondsCheckbox'),
              value: _commentEndPositionChangedInTenthOfSeconds,
              onChanged: (bool? newValue) {
                setState(() {
                  _commentEndPositionChangedInTenthOfSeconds =
                      newValue ?? false;
                });
              },
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            key: const Key('backwardCommentEndIconButton'),
            // Rewind 1 second button
            icon: const Icon(Icons.fast_rewind),
            onPressed: () async {
              _commentEndPositionIsModified = true;
              await _modifyCommentEndPosition(
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _commentEndPositionChangedInTenthOfSeconds ? -100 : -1000,
              );
            },
            iconSize: _commentEndPositionChangedInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
        Consumer<CommentVM>(
          builder: (context, commentVM, child) {
            // Text for the current comment end audio position
            return Text(
              key: const Key('commentEndPositionText'),
              _commentEndPositionChangedInTenthOfSeconds
                  // if the modify position duration change in tenth
                  // of seconds checkbox is checked, the audio
                  // position is displayed with a tenth of a second
                  // value after the seconds value
                  ? commentVM.currentCommentEndPosition
                      .HHmmssZeroHH(addRemainingOneDigitTenthOfSecond: true)
                  : commentVM.currentCommentEndPosition.HHmmssZeroHH(),
            );
          },
        ),
        SizedBox(
          width: 50,
          child: IconButton(
            // Forward 1 second button
            key: const Key('forwardCommentEndIconButton'),
            icon: const Icon(Icons.fast_forward),
            onPressed: () async {
              _commentEndPositionIsModified = true;
              await _modifyCommentEndPosition(
                commentVMlistenFalse: commentVMlistenFalse,
                millisecondsChange:
                    _commentEndPositionChangedInTenthOfSeconds ? 100 : 1000,
              );
            },
            iconSize: _commentEndPositionChangedInTenthOfSeconds
                ? kSmallestButtonWidth * 0.8
                : kSmallestButtonWidth,
          ),
        ),
      ],
    );
  }

  /// The row contains the text button which opens a dialog to set the
  /// current audio position as the comment start or end position.
  Row _buildAudioPlayerViewAudioPositionRow({
    required BuildContext context,
    required CommentVM commentVMlistenFalse,
  }) {
    ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Consumer<AudioPlayerVM>(
          builder: (context, audioPlayerVM, child) {
            String currentAudioPositionStr =
                audioPlayerVM.currentAudioPosition.HHmmssZeroHH();
            return Tooltip(
              message: AppLocalizations.of(context)!
                  .updateCommentStartEndPositionTooltip,
              child: TextButton(
                key: const Key('selectCommentPositionTextButton'),
                style: ButtonStyle(
                  shape: getButtonRoundedShape(
                    currentTheme: themeProviderVM.currentTheme,
                    isButtonEnabled: true,
                    context: context,
                  ),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                        horizontal: kSmallButtonInsidePadding, vertical: 0),
                  ),
                  overlayColor: textButtonTapModification, // Tap feedback color
                ),
                onPressed: () {
                  showDialog<List<String>>(
                    context: context,
                    builder: (BuildContext context) {
                      return SetValueToTargetDialogWidget(
                        dialogTitle:
                            AppLocalizations.of(context)!.setCommentPosition,
                        dialogCommentStr: AppLocalizations.of(context)!
                            .commentPositionExplanation,
                        passedValueFieldLabel:
                            AppLocalizations.of(context)!.commentPosition,
                        passedValueStr: currentAudioPositionStr,
                        targetNamesLst: [
                          AppLocalizations.of(context)!.commentStartPosition,
                          AppLocalizations.of(context)!.commentEndPosition,
                        ],
                      );
                    },
                  ).then((resultStringLst) {
                    if (resultStringLst == null) {
                      // the case if the Cancel button was pressed
                      return;
                    }

                    String positionStr = resultStringLst[0];
                    String checkboxIndexStr = resultStringLst[1];
                    Duration positionDuration = Duration(
                        milliseconds: DateTimeUtil.convertToTenthsOfSeconds(
                                timeString: positionStr) *
                            100);

                    if (checkboxIndexStr == '0') {
                      // the case if the Comment Start Position checkbox was
                      // checked
                      commentVMlistenFalse.currentCommentStartPosition =
                          positionDuration;
                    } else {
                      // the case if the Comment End Position checkbox was
                      // checked
                      commentVMlistenFalse.currentCommentEndPosition =
                          positionDuration;
                    }
                  });
                },
                child: Text(
                  currentAudioPositionStr,
                  textAlign: TextAlign.center,
                  style: (themeProviderVM.currentTheme == AppTheme.dark)
                      ? kTextButtonStyleDarkMode
                      : kTextButtonStyleLightMode,
                ),
              ),
            );
          },
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
    Navigator.of(context).pop(); // close the current dialog

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
      commentVMlistenFalse.currentCommentStartPosition,
    );

    await globalAudioPlayerVM.playFromCurrentAudioFile(
      rewindAudioPositionBasedOnPauseDuration: false,
    );
  }

  Future<void> _modifyCommentStartPosition({
    required CommentVM commentVMlistenFalse,
    required int millisecondsChange,
  }) async {
    commentVMlistenFalse.currentCommentStartPosition =
        commentVMlistenFalse.currentCommentStartPosition +
            Duration(milliseconds: millisecondsChange);

    await globalAudioPlayerVM.modifyAudioPlayerPluginPosition(
      commentVMlistenFalse.currentCommentStartPosition,
    );

    await globalAudioPlayerVM.playFromCurrentAudioFile(
      rewindAudioPositionBasedOnPauseDuration: false,
    );
  }

  Future<void> _modifyCommentEndPosition({
    required CommentVM commentVMlistenFalse,
    required int millisecondsChange,
  }) async {
    commentVMlistenFalse.currentCommentEndPosition =
        commentVMlistenFalse.currentCommentEndPosition +
            Duration(milliseconds: millisecondsChange);

    await globalAudioPlayerVM.modifyAudioPlayerPluginPosition(
        commentVMlistenFalse.currentCommentEndPosition -
            const Duration(milliseconds: 4000));

    await globalAudioPlayerVM.playFromCurrentAudioFile(
      rewindAudioPositionBasedOnPauseDuration: false,
    );
  }
}
