import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../models/comment.dart';
import '../../services/settings_data_service.dart';
import '../../utils/date_time_util.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../../views/screen_mixin.dart';
import '../../utils/duration_expansion.dart';
import 'comment_list_add_dialog.dart';
import 'set_value_to_target_dialog.dart';

enum CallerDialog {
  commentListAddDialog,
  playlistCommentListAddDialog,
}

/// This widget displays a dialog to add or edit a comment.
/// The edit mode is activated when a comment is passed to the
/// widget constructor. Else, the widget is in add mode.
class CommentAddEditDialog extends StatefulWidget {
  final CallerDialog callerDialog;
  final Comment? comment;
  final bool isAddMode;
  final Audio commentableAudio;

  const CommentAddEditDialog({
    super.key,
    required this.callerDialog,
    required this.commentableAudio,
    this.comment,
  }) : isAddMode = comment == null;

  @override
  State<CommentAddEditDialog> createState() => _CommentAddEditDialogState();
}

class _CommentAddEditDialogState extends State<CommentAddEditDialog>
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
      AudioPlayerVM audioPlayerVM = Provider.of<AudioPlayerVM>(
        context,
        listen: false,
      );
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
            audioPlayerVM.currentAudioPosition;
        commentVM.currentCommentEndPosition =
            audioPlayerVM.currentAudioPosition;
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
    AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
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
                  key: const Key('commentedAudioTitleText'),
                  widget.commentableAudio.validVideoTitle,
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        _buildCommentStartPositionRow(
                          context: context,
                          audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                          commentVMlistenFalse: commentVMlistenFalse,
                        ),
                        _buildCommentEndPositionRow(
                          context: context,
                          audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                          commentVMlistenFalse: commentVMlistenFalse,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          // Play/Pause button
                          key: const Key('playPauseIconButton'),
                          onPressed: () async {
                            if (audioPlayerVMlistenFalse.isPlaying) {
                              await audioPlayerVMlistenFalse.pause();

                              // Modify the end audio position if the end audio position is before or equal to the current audio position.
                              if (commentVMlistenFalse
                                      .currentCommentEndPosition <=
                                  commentVMlistenFalse
                                      .currentCommentStartPosition) {
                                commentVMlistenFalse.currentCommentEndPosition =
                                    audioPlayerVMlistenFalse
                                        .currentAudioPosition;
                              }
                            } else {
                              // The audio is not playing.
                              _playButtonWasClicked = true;
                              _commentEndPositionIsModified = false;

                              await _playFromCommentStartPosition(
                                audioPlayerVM: audioPlayerVMlistenFalse,
                                commentVMlistenFalse: commentVMlistenFalse,
                              );
                            }
                          },
                          style: ButtonStyle(
                            // Highlight button when pressed.
                            padding:
                                WidgetStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.symmetric(
                                horizontal: kSmallButtonInsidePadding,
                                vertical: 0,
                              ),
                            ),
                            overlayColor:
                                iconButtonTapModification, // Tap feedback color.
                          ),
                          icon: ValueListenableBuilder<bool>(
                            valueListenable: audioPlayerVMlistenFalse
                                .currentAudioPlayPauseNotifier,
                            builder: (context, isPlaying, child) {
                              // Evaluate and adjust play/pause state based on the current audio position.
                              if (!_commentEndPositionIsModified) {
                                if (commentVMlistenFalse
                                        .currentCommentEndPosition >
                                    commentVMlistenFalse
                                        .currentCommentStartPosition) {
                                  if (audioPlayerVMlistenFalse
                                          .currentAudioPosition >=
                                      commentVMlistenFalse
                                          .currentCommentEndPosition) {
                                    if (_playButtonWasClicked) {
                                      // Allow playback to be restarted from the comment's start position.
                                      _playButtonWasClicked = false;
                                    } else {
                                      // Pause the audio and update the flag.
                                      audioPlayerVMlistenFalse
                                          .pause()
                                          .then((_) {
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
                                  if (audioPlayerVMlistenFalse
                                          .currentAudioPosition >=
                                      commentVMlistenFalse
                                          .currentCommentEndPosition) {
                                    // You cannot await here, but you can
                                    // trigger an action which will not
                                    // block the widget tree rendering.
                                    //
                                    // Pause the audio when the current
                                    // comment end position is reached.
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      audioPlayerVMlistenFalse.pause();
                                    });
                                  }
                                }
                              }

                              return Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow);
                            },
                          ),
                          iconSize: kUpDownButtonSize - 10,
                          constraints:
                              const BoxConstraints(), // Ensures the button takes minimal space.
                        ),
                      ],
                    ),
                  ],
                ),
                _buildSetAudioPositionTextButton(
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
                audioToComment: widget.commentableAudio,
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
                commentedAudio: widget.commentableAudio,
              );
            }

            await _closeDialogAndReOpenCommentListAddDialog(
              context: context,
              audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
            );
          },
        ),
        TextButton(
          key: const Key('cancelTextButton'),
          child: Text(AppLocalizations.of(context)!.cancelButton),
          onPressed: () async =>
              await _closeDialogAndReOpenCommentListAddDialog(
            context: context,
            audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
          ),
        ),
      ],
    );
  }

  Row _buildCommentStartPositionRow({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required CommentVM commentVMlistenFalse,
  }) {
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
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(Icons.fast_rewind),
            onPressed: () async {
              await _modifyCommentStartPosition(
                audioPlayerVM: audioPlayerVMlistenFalse,
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
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(Icons.fast_forward),
            onPressed: () async {
              await _modifyCommentStartPosition(
                audioPlayerVM: audioPlayerVMlistenFalse,
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

  Row _buildCommentEndPositionRow({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required CommentVM commentVMlistenFalse,
  }) {
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
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(Icons.fast_rewind),
            onPressed: () async {
              _commentEndPositionIsModified = true;
              await _modifyCommentEndPosition(
                audioPlayerVM: audioPlayerVMlistenFalse,
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
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(Icons.fast_forward),
            onPressed: () async {
              _commentEndPositionIsModified = true;
              await _modifyCommentEndPosition(
                audioPlayerVM: audioPlayerVMlistenFalse,
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

  /// The returned row contains the text button which opens a dialog
  /// to set the current audio position as the comment start or end
  /// position.
  Row _buildSetAudioPositionTextButton({
    required BuildContext context,
    required CommentVM commentVMlistenFalse,
  }) {
    final ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );
    // Retrieve AudioPlayerVM without listening so that we can use its other values.
    final AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<Duration>(
          valueListenable:
              audioPlayerVMlistenFalse.currentAudioPositionNotifier,
          builder: (context, currentAudioPosition, child) {
            // When the current comment end position is reached,
            // schedule a pause.
            if (currentAudioPosition >=
                    commentVMlistenFalse.currentCommentEndPosition ||
                // The 'or' test below is necessary to enable the
                // pause of a comment whose end position is the same
                // as the audio end position. For a reason I don't
                // know, without this condition, playing such a
                // comment on the Android smartphone does not call
                // the audioPlayerVMlistenFalse.pause() method !
                currentAudioPosition >=
                    widget.commentableAudio.audioDuration -
                        const Duration(milliseconds: 1400)) {
              // You cannot await here, but you can trigger an
              // action which will not block the widget tree
              // rendering.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                audioPlayerVMlistenFalse.pause();
              });
            }

            // Format the current audio position using your custom extension function.
            String currentAudioPositionStr = currentAudioPosition.HHmmssZeroHH(
                addRemainingOneDigitTenthOfSecond: true);
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
                      horizontal: kSmallButtonInsidePadding,
                      vertical: 0,
                    ),
                  ),
                  overlayColor: textButtonTapModification, // Tap feedback color
                ),
                onPressed: () {
                  showDialog<List<String>>(
                    barrierDismissible:
                        false, // Prevents the dialog from closing when tapping outside.
                    context: context,
                    builder: (BuildContext context) {
                      return SetValueToTargetDialog(
                        dialogTitle:
                            AppLocalizations.of(context)!.setCommentPosition,
                        dialogCommentStr: AppLocalizations.of(context)!
                            .commentPositionExplanation,
                        passedValueFieldLabel:
                            AppLocalizations.of(context)!.commentPosition,
                        passedValueFieldTooltip: AppLocalizations.of(context)!
                            .commentPositionTooltip,
                        passedValueStr: currentAudioPositionStr,
                        targetNamesLst: [
                          AppLocalizations.of(context)!.commentStartPosition,
                          AppLocalizations.of(context)!.commentEndPosition,
                        ],
                        validationFunction: validateEnteredValueFunction,
                        validationFunctionArgs: [
                          // This duration string is used if the user empties the position field.
                          '0:00.0',
                          // Uses the total duration from audioPlayerVM.
                          audioPlayerVMlistenFalse.currentAudioTotalDuration
                              .HHmmssZeroHH(
                            addRemainingOneDigitTenthOfSecond: true,
                          ),
                        ],
                      );
                    },
                  ).then((resultStringLst) {
                    if (resultStringLst == null) {
                      // The case if the Cancel button was pressed.
                      return;
                    }

                    String positionStr = resultStringLst[0];
                    String checkboxIndexStr = resultStringLst[1];
                    Duration positionDuration = Duration(
                      milliseconds: DateTimeUtil.convertToTenthsOfSeconds(
                            timeString: positionStr,
                          ) *
                          100,
                    );

                    if (checkboxIndexStr == '0') {
                      // The case when the Comment Start Position checkbox is checked.
                      commentVMlistenFalse.currentCommentStartPosition =
                          positionDuration;
                    } else {
                      // The case when the Comment End Position checkbox is checked.
                      commentVMlistenFalse.currentCommentEndPosition =
                          positionDuration;
                    }

                    // Updating the display format according to the provided position.
                    int pointPosition = positionStr.indexOf('.');
                    if (pointPosition != -1) {
                      // If the position contains a tenth of a second (e.g., 00:00:00.0).
                      if (positionStr.substring(pointPosition + 1) != '0') {
                        if (checkboxIndexStr == '0') {
                          _commentStartPositionChangedInTenthOfSeconds = true;
                        } else if (checkboxIndexStr == '1') {
                          _commentEndPositionChangedInTenthOfSeconds = true;
                        }
                      }
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

  /// This function validates the entered time value in the
  /// SetValuesToTargetDialog. In order to do this, it is passed
  /// as parameter to the dialog constructor.
  ///
  /// In SetValuesToTargetDialog._createResultList(), the entered
  /// time value is validated by calling this function this way:
  ///    bool isValid = Function.apply(
  ///                       widget.validationFunction,
  ///                       widget.validationFunctionArgs,
  ///                   );
  InvalidValueState validateEnteredValueFunction(
    String minDurationStr,
    String maxDurationStr,
    String enteredTimeStr,
  ) {
    int minDurationInTenthsOfSeconds =
        DateTimeUtil.convertToTenthsOfSeconds(timeString: minDurationStr);
    int maxDurationInTenthsOfSeconds =
        DateTimeUtil.convertToTenthsOfSeconds(timeString: maxDurationStr);
    int enteredTimeInTenthsOfSeconds =
        DateTimeUtil.convertToTenthsOfSeconds(timeString: enteredTimeStr);

    if (enteredTimeInTenthsOfSeconds > maxDurationInTenthsOfSeconds) {
      return InvalidValueState.tooBig;
    } else if (enteredTimeInTenthsOfSeconds < minDurationInTenthsOfSeconds) {
      return InvalidValueState.tooSmall;
    } else {
      // the case if the entered value is valid
      return InvalidValueState.none;
    }
  }

  /// Since before opening the CommentAddEditDialog its caller, the
  /// CommentListAddDialog or the PlaylistCommentListAddDialog,
  /// was closed, the caller dialog must be re-opened in order to display
  /// the updated list of comments.
  Future<void> _closeDialogAndReOpenCommentListAddDialog({
    required BuildContext context,
    required AudioPlayerVM audioPlayerVMlistenFalse,
  }) async {
    // Closing first the current CommentAddEditDialog dialog (... pop())
    // and then opening the CommentListAddDialog dialog before pausing
    // the audio without using await on pause method avoids that if the audio
    // is playing when we close the CommentAddEditDialog, the
    // CommentAddEditDialog is re-opened !
    Navigator.of(context).pop(); // close the current dialog

    // Using this method enables to minimize the comment list
    // add dialog.
    CommentListAddDialog.showCommentDialog(
      context: context,
      currentAudio: widget.commentableAudio,
    );

    if (audioPlayerVMlistenFalse.isPlaying) {
      await audioPlayerVMlistenFalse.pause();
    }
  }

  Future<void> _playFromCommentStartPosition({
    required AudioPlayerVM audioPlayerVM,
    required CommentVM commentVMlistenFalse,
  }) async {
    await audioPlayerVM.modifyAudioPlayerPosition(
      durationPosition: commentVMlistenFalse.currentCommentStartPosition,
      isUndoCommandToAdd: true,
    );

    await audioPlayerVM.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      isCommentPlaying: true,
    );
  }

  Future<void> _modifyCommentStartPosition({
    required AudioPlayerVM audioPlayerVM,
    required CommentVM commentVMlistenFalse,
    required int millisecondsChange,
  }) async {
    Duration modifiedCommentStartPosition =
        commentVMlistenFalse.currentCommentStartPosition +
            Duration(milliseconds: millisecondsChange);

    Duration audioDuration = widget.commentableAudio.audioDuration;

    if (modifiedCommentStartPosition < const Duration(milliseconds: 0)) {
      modifiedCommentStartPosition = const Duration(milliseconds: 0);
    } else if (modifiedCommentStartPosition > audioDuration - const Duration(milliseconds: 2000)) {
      modifiedCommentStartPosition = audioDuration  -
            const Duration(milliseconds: 2000); // will play comment starting
        //                                         2 sec before audio end position.
        //                                         This will avoid a problem caused
        //                                         by playing a comment whose position
        //                                         is almost at the audio end position.
    }

    commentVMlistenFalse.currentCommentStartPosition =
        modifiedCommentStartPosition;

    await audioPlayerVM.modifyAudioPlayerPosition(
      durationPosition: modifiedCommentStartPosition,
      isUndoCommandToAdd: true,
    );

    await audioPlayerVM.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      isCommentPlaying: true,
    );
  }

  Future<void> _modifyCommentEndPosition({
    required AudioPlayerVM audioPlayerVM,
    required CommentVM commentVMlistenFalse,
    required int millisecondsChange,
  }) async {
    Duration modifiedCommentEndPosition =
        commentVMlistenFalse.currentCommentEndPosition +
            Duration(milliseconds: millisecondsChange);

    Duration audioDuration = widget.commentableAudio.audioDuration;

    if (modifiedCommentEndPosition > audioDuration) {
      modifiedCommentEndPosition = audioDuration;
    } else if (modifiedCommentEndPosition < const Duration(milliseconds: 0)) {
      modifiedCommentEndPosition = const Duration(milliseconds: 0);
    }

    commentVMlistenFalse.currentCommentEndPosition = modifiedCommentEndPosition;

    await audioPlayerVM.modifyAudioPlayerPosition(
        durationPosition: modifiedCommentEndPosition -
            const Duration(milliseconds: 4000), // will play comment starting
        //                                      4 sec before new end position
        isUndoCommandToAdd: true);

    await audioPlayerVM.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      isCommentPlaying: true,
    );
  }
}
