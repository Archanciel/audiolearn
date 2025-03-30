import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../models/comment.dart';
import '../../utils/duration_expansion.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/date_format_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';
import 'confirm_action_dialog.dart';
import 'comment_add_edit_dialog.dart';

// Gestionnaire global pour l'overlay des commentaires
class CommentDialogManager {
  static OverlayEntry? _currentOverlay;

  static void closeCurrentOverlay() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }

  static void setCurrentOverlay(OverlayEntry entry) {
    // Ferme tout overlay précédent avant d'en ouvrir un nouveau
    closeCurrentOverlay();
    _currentOverlay = entry;
  }

  static bool get hasActiveOverlay => _currentOverlay != null;
}

class CommentDeleteConfirmActionDialog extends StatelessWidget {
  final Function actionFunction;
  final List<dynamic> actionFunctionArgs;
  final String dialogTitleOne;
  final String dialogContent;
  final VoidCallback? onCancel; // Nouvelle propriété pour gérer l'annulation

  const CommentDeleteConfirmActionDialog({
    Key? key,
    required this.actionFunction,
    required this.actionFunctionArgs,
    required this.dialogTitleOne,
    required this.dialogContent,
    this.onCancel, // Paramètre optionnel pour gérer l'annulation
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(dialogTitleOne),
      content: Text(dialogContent),
      actions: <Widget>[
        TextButton(
          key: const Key('confirmButton'),
          child: Text(
            AppLocalizations.of(context)!.confirmButton,
            style: (isDarkTheme)
                ? kTextButtonStyleDarkMode
                : kTextButtonStyleLightMode,
          ),
          onPressed: () async {
            // Exécuter la fonction d'action avec les arguments
            if (actionFunctionArgs.isNotEmpty) {
              await Function.apply(actionFunction, actionFunctionArgs);
            } else {
              await actionFunction();
            }

            // Si nous n'utilisons pas le callback onCancel, fermer avec Navigator
            if (onCancel == null) {
              Navigator.of(context).pop();
            }
            // Sinon, l'overlay sera fermé par la fonction actionFunction modifiée
          },
        ),
        TextButton(
          key: const Key('cancelButtonKey'),
          child: Text(
            AppLocalizations.of(context)!.cancelButton,
            style: (isDarkTheme)
                ? kTextButtonStyleDarkMode
                : kTextButtonStyleLightMode,
          ),
          onPressed: () {
            // Si onCancel existe, l'appeler, sinon utiliser Navigator.pop
            if (onCancel != null) {
              onCancel!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

/// This widget displays a dialog with the list of positionned
/// comment added to the current audio.
///
/// When a comment is clicked, this opens a dialog to edit the
/// comment.
///
/// Additionally, a button 'plus' is displayed to add a new
/// positionned comment.
class CommentListAddDialog extends StatefulWidget {
  final Audio currentAudio;

  const CommentListAddDialog({
    super.key,
    required this.currentAudio,
  });

  @override
  State<CommentListAddDialog> createState() => _CommentListAddDialogState();

  /// Méthode pour afficher le dialogue sans l'overlay sombre quand minimisé
  static void showCommentDialog({
    required BuildContext context,
    required Audio currentAudio,
  }) {
    OverlayState? overlayState = Overlay.of(context);

    // Création de l'overlay entry
    final overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Gestionnaire de gestes qui ignore les taps sur l'arrière-plan.
            // Now clicking outside it does not close the dialog.
            Positioned.fill(
              child: GestureDetector(
                // Absorber les clics sans aucune action
                onTap: () {
                  // Ne rien faire quand on clique à l'extérieur
                  // C'est cette modification qui empêche la fermeture
                },
                // Couleur transparente pour capturer les événements
                // sans rendre l'arrière-plan visible
                child: Container(color: Colors.transparent),
              ),
            ),
            // Le widget du dialogue lui-même
            Center(
              child: CommentListAddDialog(
                currentAudio: currentAudio,
              ),
            ),
          ],
        ),
      ),
    );

    // Enregistrement dans notre gestionnaire global
    CommentDialogManager.setCurrentOverlay(overlayEntry);

    // Insertion dans l'overlay
    overlayState.insert(overlayEntry);
  }
}

class _CommentListAddDialogState extends State<CommentListAddDialog>
    with ScreenMixin {
  final FocusNode _focusNodeDialog = FocusNode();
  Comment? _playingComment;

  // Variables to manage the scrolling of the dialog
  final ScrollController _scrollController = ScrollController();
  int _audioCommentsLinesNumber = 0;

  bool _isMinimized = false;

  @override
  void dispose() {
    _focusNodeDialog.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context); // by default, listen is true
    final AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );
    final CommentVM commentVMlistenFalse = Provider.of<CommentVM>(
      context,
      listen: false,
    );
    final bool isDarkTheme = themeProviderVM.currentTheme == AppTheme.dark;
    final Audio currentAudio = widget.currentAudio;

    // Required so that clicking on Enter closes the dialog
    FocusScope.of(context).requestFocus(
      _focusNodeDialog,
    );

    if (_isMinimized) {
      // Retourner un widget positionné qui ne contient que le bouton d'expansion
      return Positioned(
        bottom: 20,
        right: 20,
        child: FloatingActionButton(
          mini: true,
          backgroundColor:
              Theme.of(context).dialogBackgroundColor.withOpacity(0.7),
          child: const Icon(Icons.expand_less),
          onPressed: () {
            setState(() {
              _isMinimized = false;
            });
          },
        ),
      );
    }

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            // executing the same code as in the 'Close'
            // TextButton onPressed callback
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            Text(AppLocalizations.of(context)!.commentsDialogTitle),
            const SizedBox(width: 15),
            (CommentDialogManager.hasActiveOverlay)
                // Showing the minimize icon happens only if the comment list
                // add dialog is was opened in the audio player view by the
                // CommentDialogManager.
                ? IconButton(
                    icon: const Icon(
                      Icons.expand_more,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _isMinimized = true;
                      });
                    },
                  )
                : const Spacer(),
            Tooltip(
              message:
                  AppLocalizations.of(context)!.addPositionedCommentTooltip,
              child: IconButton(
                // add comment icon button
                key: const Key('addPositionedCommentIconButtonKey'),
                style: ButtonStyle(
                  // Highlight button when pressed
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                        horizontal: kSmallButtonInsidePadding, vertical: 0),
                  ),
                  overlayColor: iconButtonTapModification, // Tap feedback color
                ),
                icon: IconTheme(
                  data: (isDarkTheme
                          ? ScreenMixin.themeDataDark
                          : ScreenMixin.themeDataLight)
                      .iconTheme,
                  child: const Icon(
                    Icons.add_circle_outline,
                    size: 40.0,
                  ),
                ),
                onPressed: () {
                  _closeDialogAndOpenCommentAddEditDialog(
                    context: context,
                    currentAudio: currentAudio,
                  );
                },
              ),
            ),
          ],
        ),
        actionsPadding: kDialogActionsPadding,
        content: SingleChildScrollView(
          controller: _scrollController,
          child: ListBody(
            children: _buildAudioCommentsLst(
              themeProviderVM: themeProviderVM,
              audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
              commentVMlistenFalse: commentVMlistenFalse,
              currentAudio: currentAudio,
              isDarkTheme: isDarkTheme,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('closeDialogTextButton'),
            child: Text(
              AppLocalizations.of(context)!.closeTextButton,
              style: (isDarkTheme)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
            onPressed: () async {
              // Calling setCurrentAudio() when closing the comment
              // list dialog is necessary, otherwise, on Android,
              // clicking on position buttons or audio slider will
              // not work after a comment was played.

              // Since playing a comment changes the audio player
              // position, avoiding to clear the undo/redo lists
              // enables the user to undo the audio position change.
              if (audioPlayerVMlistenFalse.isPlaying) {
                await audioPlayerVMlistenFalse.pause();
              }

              await audioPlayerVMlistenFalse.setCurrentAudio(
                audio: currentAudio,
              );

              if (CommentDialogManager.hasActiveOverlay) {
                // Fermer le dialogue si un overlay est actif
                CommentDialogManager.closeCurrentOverlay();
              } else {
                // Sinon, fermer le dialogue normal
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAudioCommentsLst({
    required ThemeProviderVM themeProviderVM,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required CommentVM commentVMlistenFalse,
    required Audio currentAudio,
    required bool isDarkTheme,
  }) {
    List<Comment> commentsLst = commentVMlistenFalse.loadAudioComments(
      audio: currentAudio,
    );

    const TextStyle commentTitleTextStyle = TextStyle(
      fontSize: kAudioTitleFontSize,
      fontWeight: FontWeight.bold,
    );

    const TextStyle commentContentTextStyle = TextStyle(
      fontSize: kAudioTitleFontSize,
    );

    // List of widgets corresponding to the audio comments
    List<Widget> widgetsLst = [];

    for (Comment comment in commentsLst) {
      // Adding the calculated lines number occupied by the comment
      // title
      _audioCommentsLinesNumber +=
          (1 + // 2 dates + position line after the comment title
              computeTextLineNumber(
                context: context,
                textStyle: commentTitleTextStyle,
                text: comment.title,
              ));

      // Adding the calculated lines number occupied by the comment
      // content
      _audioCommentsLinesNumber += computeTextLineNumber(
        context: context,
        textStyle: commentContentTextStyle,
        text: comment.content,
      );

      widgetsLst.add(
        GestureDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: _buildCommentTitlePlusIconsAndCommentDatesAndPosition(
                  themeProviderVM: themeProviderVM,
                  audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                  dateFormatVMlistenFalse: Provider.of<DateFormatVM>(
                    context,
                    listen: false,
                  ),
                  commentVMlistenFalse: commentVMlistenFalse,
                  currentAudio: currentAudio,
                  comment: comment,
                  commentTitleTextStyle: commentTitleTextStyle,
                  isDarkTheme: isDarkTheme,
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

            _closeDialogAndOpenCommentAddEditDialog(
              context: context,
              currentAudio: currentAudio,
              comment: comment,
            );
          },
        ),
      );
    }

    _scrollToCurrentAudioItem();

    return widgetsLst;
  }

  Widget _buildCommentTitlePlusIconsAndCommentDatesAndPosition({
    required ThemeProviderVM themeProviderVM,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required DateFormatVM dateFormatVMlistenFalse,
    required CommentVM commentVMlistenFalse,
    required Audio currentAudio,
    required Comment comment,
    required TextStyle commentTitleTextStyle,
    required bool isDarkTheme,
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
                // comment title Text
                child: Text(
                  key: const Key('commentTitleKey'),
                  comment.title,
                  style: commentTitleTextStyle,
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
                              audioPlayerVMlistenFalse:
                                  audioPlayerVMlistenFalse,
                              comment: comment,
                            );
                    },
                    style: ButtonStyle(
                      // Highlight button when pressed
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: kSmallButtonInsidePadding, vertical: 0),
                      ),
                      overlayColor:
                          iconButtonTapModification, // Tap feedback color
                    ),
                    icon: ValueListenableBuilder<Duration>(
                      valueListenable:
                          audioPlayerVMlistenFalse.currentAudioPositionNotifier,
                      builder: (context, currentAudioPosition, child) {
                        // When the current comment end position is
                        // reached, schedule a pause.
                        if (_playingComment != null &&
                            _playingComment == comment &&
                            (currentAudioPosition >=
                                    Duration(
                                      milliseconds: comment
                                              .commentEndPositionInTenthOfSeconds *
                                          100,
                                    ) ||
                                // The 'or' test below is necessary to enable
                                // the pause of a comment whose end position
                                // is the same as the audio end position. For
                                // a reason I don't know, without this
                                // condition, playing such a comment on the
                                // Android smartphone does not call the
                                // audioPlayerVMlistenFalse.pause() method !
                                currentAudioPosition >=
                                    currentAudio.audioDuration -
                                        const Duration(milliseconds: 1400))) {
                          // You cannot await here, but you can trigger an
                          // action which will not block the widget tree
                          // rendering.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            audioPlayerVMlistenFalse.pause();
                          });
                        }

                        return ValueListenableBuilder<bool>(
                          valueListenable: audioPlayerVMlistenFalse
                              .currentAudioPlayPauseNotifier,
                          builder: (context, isPlaying, child) {
                            return IconTheme(
                              data: (isDarkTheme
                                      ? ScreenMixin.themeDataDark
                                      : ScreenMixin.themeDataLight)
                                  .iconTheme,
                              child: Icon(
                                // Display pause if this comment is playing and the audio is playing;
                                // otherwise, display the play_arrow icon.
                                (_playingComment != null &&
                                        _playingComment == comment &&
                                        isPlaying)
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            );
                          },
                        );
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
                        audioPlayerVM: audioPlayerVMlistenFalse,
                        commentVMlistenFalse: commentVMlistenFalse,
                        currentAudio: currentAudio,
                        comment: comment,
                      );
                    },
                    style: ButtonStyle(
                      // Highlight button when pressed
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: kSmallButtonInsidePadding, vertical: 0),
                      ),
                      overlayColor:
                          iconButtonTapModification, // Tap feedback color
                    ),
                    icon: IconTheme(
                      // IconTheme usage is required otherwise when
                      // the CommentListAddDialog is opened from the
                      // AudioPlayerScreen left appbar menu, the icon
                      // color is not the one defined in the theme and
                      // so is different from the icon color set when
                      // opening the CommentListAddDialog from the
                      // AudioPlayerScreen inkwell button or the playlist
                      // Audio Comments menu item.
                      data: (isDarkTheme
                              ? ScreenMixin.themeDataDark
                              : ScreenMixin.themeDataLight)
                          .iconTheme,
                      child: const Icon(
                        Icons.clear,
                      ),
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
                    // comment creation date Text. This date is
                    // displayed with 2 chars for the year in order
                    // reduce the used space. This is useful on a
                    // smartphone screen where space is limited.
                    key: const Key('creation_date_key'),
                    style: const TextStyle(fontSize: 13),
                    dateFormatVMlistenFalse
                        .formatDateYy(comment.creationDateTime),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                (comment.lastUpdateDateTime.day != comment.creationDateTime.day)
                    ? Tooltip(
                        message: AppLocalizations.of(context)!
                            .commentUpdateDateTooltip,
                        child: Text(
                          // comment update date Text. This date is
                          // displayed with 2 chars for the year in order
                          // reduce the used space. This is useful on a
                          // smartphone screen where space is limited.
                          key: const Key('last_update_date_key'),
                          style: const TextStyle(fontSize: 13),
                          dateFormatVMlistenFalse
                              .formatDateYy(comment.lastUpdateDateTime),
                        ),
                      )
                    : Container(),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Row(
              children: [
                Tooltip(
                  message:
                      AppLocalizations.of(context)!.commentStartPositionTooltip,
                  child: Text(
                    // comment start position Text
                    key: const Key('commentStartPositionKey'),
                    style: const TextStyle(fontSize: 13),
                    Duration(
                            milliseconds:
                                comment.commentStartPositionInTenthOfSeconds *
                                    100)
                        .HHmmssZeroHH(),
                  ),
                ),
                const SizedBox(width: 5),
                Tooltip(
                  message:
                      AppLocalizations.of(context)!.commentEndPositionTooltip,
                  child: Text(
                    // comment position Text
                    key: const Key('commentEndPositionKey'),
                    style: const TextStyle(fontSize: 13),
                    Duration(
                            milliseconds:
                                comment.commentEndPositionInTenthOfSeconds *
                                    100)
                        .HHmmssZeroHH(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// In order to avoid keyboard opening and closing continuously after
  /// opening the CommentAddEditDialog, the current dialog must be
  /// closed before opening the CommentAddEditDialog.
  void _closeDialogAndOpenCommentAddEditDialog({
    required BuildContext context,
    required Audio currentAudio,
    Comment? comment,
  }) {
    if (CommentDialogManager.hasActiveOverlay) {
      // Fermer le dialogue si un overlay est actif
      CommentDialogManager.closeCurrentOverlay();
    } else {
      // Sinon, fermer le dialogue normal
      Navigator.of(context).pop();
    }

    showDialog<void>(
      context: context,
      barrierDismissible:
          false, // This line prevents the dialog from closing when
      //            tapping outside the dialog.

      // Instanciating CommentAddEditDialog without passing a comment
      // opens it in 'add' mode
      builder: (context) => CommentAddEditDialog(
        callerDialog: CallerDialog.commentListAddDialog,
        commentableAudio: currentAudio,
        comment: comment,
      ),
    );
  }

  Future<void> _confirmDeleteComment({
    required AudioPlayerVM audioPlayerVM,
    required CommentVM commentVMlistenFalse,
    required Audio currentAudio,
    required Comment comment,
  }) async {
    // Utiliser l'overlay pour afficher le dialogue de confirmation
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry? confirmOverlayEntry;

    // Completer pour attendre la réponse de l'utilisateur
    Completer<bool> confirmCompleter = Completer<bool>();

    confirmOverlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54, // Assombrit l'arrière-plan
        child: Center(
          child: CommentDeleteConfirmActionDialog(
            actionFunction: (id, audio) async {
              // Supprimer le commentaire
              commentVMlistenFalse.deleteCommentFunction(id, audio);

              // Fermer le dialogue de confirmation
              confirmOverlayEntry?.remove();

              // Compléter avec true (action confirmée)
              confirmCompleter.complete(true);
            },
            actionFunctionArgs: [
              comment.id,
              currentAudio,
            ],
            dialogTitleOne:
                AppLocalizations.of(context)!.deleteCommentConfirnTitle,
            dialogContent: AppLocalizations.of(context)!
                .deleteCommentConfirnBody(comment.title),
            onCancel: () {
              // Fermer le dialogue de confirmation
              confirmOverlayEntry?.remove();

              // Compléter avec false (action annulée)
              confirmCompleter.complete(false);
            },
          ),
        ),
      ),
    );

    // Insérer le dialogue de confirmation dans l'overlay
    overlayState.insert(confirmOverlayEntry);

    // Attendre la réponse de l'utilisateur
    bool confirmed = await confirmCompleter.future;

    // Si l'action est confirmée, mettre en pause la lecture
    if (confirmed && audioPlayerVM.isPlaying) {
      await audioPlayerVM.pause();
    }
  }

  Future<void> _playFromCommentPosition({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required Comment comment,
  }) async {
    _playingComment = comment;

    // if (!audioPlayerVMlistenFalse.isPlaying) {
    // This fixes a problem when a playing comment was paused and
    // then the user clicked on the play button of an other comment.
    // In such a situation, the user had to click twice or three
    // times on the other comment play button to play it if the other
    // comment was positioned before the previously played comment.
    // If the other comment was positioned after the previously played
    // comment, then the user had to click only once on the play button
    // of the other comment to play it.
    //   await audioPlayerVMlistenFalse.playCurrentAudio(
    //     rewindAudioPositionBasedOnPauseDuration: false,
    //     isCommentPlaying: true,
    //   );
    // }
    //
    // What fixed the problem is adding
    // _currentAudioPosition = durationPosition; in
    // AudioPlayerVM.modifyAudioPlayerPosition() method.

    await audioPlayerVMlistenFalse.modifyAudioPlayerPosition(
      durationPosition: Duration(
          milliseconds: comment.commentStartPositionInTenthOfSeconds * 100),
      isUndoCommandToAdd: true,
    );

    await audioPlayerVMlistenFalse.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      isCommentPlaying: true,
    );
  }

  void _scrollToCurrentAudioItem() {
    double offset = _audioCommentsLinesNumber * 135.0;

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
      _scrollController.animateTo(
        offset,
        duration: kScrollDuration,
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
