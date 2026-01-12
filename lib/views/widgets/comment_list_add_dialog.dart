import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../models/comment.dart';
import '../../utils/duration_expansion.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/date_format_vm.dart';
import '../../viewmodels/picture_vm.dart';
import '../../viewmodels/theme_provider_vm.dart';
import '../screen_mixin.dart';
import 'audio_extractor_dialog.dart';
import 'comment_add_edit_dialog.dart';

/// A global manager class for handling comment dialog overlays throughout the application.
///
/// This utility class manages display, replacement, and dismissal of comment dialogs
/// that are presented as overlays. It ensures only one comment dialog overlay exists
/// at any given time, preventing unintended UI stacking and providing centralized
/// overlay control.
///
/// The class uses static members to maintain a singleton-like pattern, allowing
/// any part of the application to access the same overlay state.
class CommentDialogManager {
  // Stores the currently active overlay entry.
  //
  // This static variable holds a reference to the currently
  // displayed comment dialog overlay. When null, no comment
  // dialog overlay is currently displayed.
  static OverlayEntry? _currentOverlay;

  // **NEW**: Callback to notify when overlay is closed
  static VoidCallback? _onOverlayClosed;

  /// Closes and removes the currently active overlay if one exists.
  ///
  /// This method safely removes any active overlay from the widget tree and
  /// resets the reference to null. If no overlay is currently active,
  /// this method has no effect.
  ///
  /// Usage example:
  /// ```dart
  /// // When needing to dismiss the comment dialog
  /// CommentDialogManager.closeCurrentOverlay();
  /// ```
  static void closeCurrentOverlay() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;

      // **NEW**: Notify that overlay was closed
      if (_onOverlayClosed != null) {
        _onOverlayClosed!();
        _onOverlayClosed = null;
      }
    }
  }

  /// Sets a new overlay as the current active overlay.
  ///
  /// This method first closes any existing overlay using [closeCurrentOverlay],
  /// then assigns the provided [entry] as the new current overlay.
  ///
  /// This ensures that only one comment dialog overlay is displayed at a time,
  /// preventing UI clutter and potential memory leaks.
  ///
  /// Parameters:
  ///   * [entry] - The new OverlayEntry to be set as the current overlay.
  ///   * [onClosed] - **NEW**: Optional callback to be called when overlay is closed.
  ///
  /// Usage example:
  /// ```dart
  /// final overlayEntry = OverlayEntry(
  ///   builder: (context) => CommentDialog(...),
  /// );
  /// CommentDialogManager.setCurrentOverlay(overlayEntry, onClosed: () {
  ///   print('Overlay was closed');
  /// });
  /// overlayState.insert(overlayEntry);
  /// ```
  static void setCurrentOverlay(OverlayEntry entry, {VoidCallback? onClosed}) {
    // Close any previous overlay before opening a new one
    closeCurrentOverlay();
    _currentOverlay = entry;
    _onOverlayClosed = onClosed;
  }

  // Indicates whether there is currently an active overlay.
  //
  // Returns true if there is an active comment dialog overlay,
  // false otherwise.
  //
  // This getter can be used to check if a comment dialog is
  // currently being displayed before attempting to show a
  // new one or to determine which UI behavior to use.
  //
  // Usage example:
  // ```dart
  // if (CommentDialogManager.hasActiveOverlay) {
  //   // Use the overlay-specific closing mechanism
  //   CommentDialogManager.closeCurrentOverlay();
  // } else {
  //   // Use standard dialog navigation
  //   Navigator.of(context).pop();
  // }
  // ```
  static bool get hasActiveOverlay => _currentOverlay != null;
}

class CommentDeleteConfirmActionDialog extends StatelessWidget {
  final Function actionFunction;
  final List<dynamic> actionFunctionArgs;
  final String dialogTitle;
  final String dialogContent;
  final VoidCallback? onCancel; // Nouvelle propriété pour gérer l'annulation

  const CommentDeleteConfirmActionDialog({
    super.key,
    required this.actionFunction,
    required this.actionFunctionArgs,
    required this.dialogTitle,
    required this.dialogContent,
    this.onCancel, // Paramètre optionnel pour gérer l'annulation
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        key: const Key('dialogTitle'),
        dialogTitle,
        textAlign: TextAlign.center,
        maxLines: 2,
      ),
      content: Text(
        key: const Key('dialogContent'),
        dialogContent,
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
  final SettingsDataService settingsDataService;
  final Audio currentAudio;

  const CommentListAddDialog({
    super.key,
    required this.settingsDataService,
    required this.currentAudio,
  });

  @override
  State<CommentListAddDialog> createState() => _CommentListAddDialogState();

  /// Method to display the dialog without darkening the screen when minimized
  /// **ENHANCED**: Now supports auto-refresh when audio changes and callback when closed
  static void showCommentDialog({
    required BuildContext context,
    required SettingsDataService settingsDataservice,
    required Audio currentAudio,
    bool isCalledByAudioListItem = false,
    VoidCallback? onClosed, // **NEW**: Optional callback when dialog is closed
  }) {
    OverlayState? overlayState = Overlay.of(context);

    // Creating the overlay entry
    final overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Gesture detector that ignores taps on the background
            // Now clicking outside will not close the dialog
            Positioned.fill(
              child: GestureDetector(
                // Absorb clicks without any action
                onTap: () {
                  // Do nothing when clicking outside
                },
                // Transparent color to capture events
                // without making the background visible
                child: Container(color: Colors.transparent),
              ),
            ),
            // **NEW**: Auto-refreshing dialog widget
            Center(
              child: Builder(builder: (context) {
                return AutoRefreshCommentDialog(
                  settingsDataService: settingsDataservice,
                  initialAudio: currentAudio,
                  isCalledByAudioListItem: isCalledByAudioListItem,
                );
              }),
            ),
          ],
        ),
      ),
    );

    // Register in our global manager with callback
    CommentDialogManager.setCurrentOverlay(overlayEntry, onClosed: onClosed);

    // Insert into the overlay
    overlayState.insert(overlayEntry);
  }
}

/// **NEW**: Simple state class for CommentListAddDialog that just delegates to the auto-refresh content
class _CommentListAddDialogState extends State<CommentListAddDialog> {
  @override
  Widget build(BuildContext context) {
    // This is just a simple wrapper that displays the current audio content
    // The actual auto-refresh logic is handled in AutoRefreshCommentDialog
    return _CommentListAddDialogContent(
      settingsDataService: widget.settingsDataService,
      currentAudio: widget.currentAudio,
    );
  }
}

/// **NEW**: Auto-refreshing wrapper for CommentListAddDialog
/// This widget listens for audio changes and automatically updates the dialog content
class AutoRefreshCommentDialog extends StatefulWidget {
  final SettingsDataService settingsDataService;
  final Audio initialAudio;
  final bool isCalledByAudioListItem;

  const AutoRefreshCommentDialog({
    super.key,
    required this.settingsDataService,
    required this.initialAudio,
    this.isCalledByAudioListItem = false,
  });

  @override
  State<AutoRefreshCommentDialog> createState() =>
      _AutoRefreshCommentDialogState();
}

class _AutoRefreshCommentDialogState extends State<AutoRefreshCommentDialog> {
  late Audio _currentAudio;
  StreamSubscription? _audioChangeSubscription;

  // **NEW**: Store provider references to avoid accessing them during disposal
  AudioPlayerVM? _audioPlayerVM;
  CommentVM? _commentVM;

  @override
  void initState() {
    super.initState();
    _currentAudio = widget.initialAudio;
    _setupAudioChangeListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // **NEW**: Store provider references safely during didChangeDependencies
    _audioPlayerVM = Provider.of<AudioPlayerVM>(context, listen: false);
    _commentVM = Provider.of<CommentVM>(context, listen: false);
  }

  /// **NEW**: Sets up listener for automatic audio changes
  void _setupAudioChangeListener() {
    // Use a post-frame callback to ensure providers are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final AudioPlayerVM audioPlayerVM = Provider.of<AudioPlayerVM>(
          context,
          listen: false,
        );
        audioPlayerVM.setCurrentAudio(audio: _currentAudio);
        final CommentVM commentVM = Provider.of<CommentVM>(
          context,
          listen: false,
        );

        // Store references for later cleanup
        _audioPlayerVM = audioPlayerVM;
        _commentVM = commentVM;

        // Listen for audio changes from AudioPlayerVM
        audioPlayerVM.currentAudioChangedNotifier.addListener(_onAudioChanged);

        // Also listen for refresh notifications from CommentVM
        commentVM.commentDialogRefreshNotifier.addListener(_onRefreshRequested);
      }
    });
  }

  void _onAudioChanged() {
    // **NEW**: Check if widget is still mounted and we have valid references
    if (!mounted || _audioPlayerVM == null) return;

    final Audio? newAudio = _audioPlayerVM!.currentAudioChangedNotifier.value;
    if (newAudio != null && newAudio != _currentAudio && mounted) {
      setState(() {
        _currentAudio = newAudio;
      });
    }
  }

  void _onRefreshRequested() {
    // **NEW**: Check if widget is still mounted and we have valid references
    if (!mounted || _commentVM == null) return;

    final Audio? newAudio = _commentVM!.commentDialogRefreshNotifier.value;
    if (newAudio != null && newAudio != _currentAudio && mounted) {
      setState(() {
        _currentAudio = newAudio;
      });
    }
  }

  @override
  void dispose() {
    // **NEW**: Use stored references instead of Provider.of() during disposal
    // Clean up listeners using stored references
    if (_audioPlayerVM != null) {
      _audioPlayerVM!.currentAudioChangedNotifier
          .removeListener(_onAudioChanged);
    }

    if (_commentVM != null) {
      _commentVM!.commentDialogRefreshNotifier
          .removeListener(_onRefreshRequested);
    }

    _audioChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build the actual dialog content with the current audio
    return _CommentListAddDialogContent(
      settingsDataService: widget.settingsDataService,
      currentAudio: _currentAudio,
      isCalledByAudioListItem: widget.isCalledByAudioListItem,
    );
  }
}

/// **NEW**: Extracted dialog content as a separate widget for better organization
class _CommentListAddDialogContent extends StatefulWidget {
  final SettingsDataService settingsDataService;
  final Audio currentAudio;

  // If true, avoids the presence of the minimize comment list add
  // dialog icon if the comment list add dialog is opened from the
  // audio list item 'Audio Comments' menu
  final bool isCalledByAudioListItem;

  const _CommentListAddDialogContent({
    required this.settingsDataService,
    required this.currentAudio,
    this.isCalledByAudioListItem = false,
  });

  @override
  State<_CommentListAddDialogContent> createState() =>
      _CommentListAddDialogContentState();
}

class _CommentListAddDialogContentState
    extends State<_CommentListAddDialogContent> with ScreenMixin {
  final FocusNode _focusNodeDialog = FocusNode();
  Comment? _playingComment;

  // Variables to manage the scrolling of the dialog
  final ScrollController _scrollController = ScrollController();
  int _audioCommentsLinesNumber = 0;

  bool _isMinimized = false;

  // Add a listener for position changes
  ValueNotifier<Duration>? _positionNotifier;

  @override
  void initState() {
    super.initState();
    // Set up position monitoring when the widget is created
    _setupPositionMonitoring();
  }

  @override
  void didUpdateWidget(_CommentListAddDialogContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // **NEW**: Reset playing comment when audio changes
    if (oldWidget.currentAudio != widget.currentAudio) {
      _playingComment = null;
      _setupPositionMonitoring(); // Re-setup monitoring for new audio
    }
  }

  void _setupPositionMonitoring() {
    final audioPlayerVM = Provider.of<AudioPlayerVM>(context, listen: false);

    // Store a reference to the position notifier
    _positionNotifier = audioPlayerVM.currentAudioPositionNotifier;

    // Add a listener that will be called whenever the position changes
    _positionNotifier?.addListener(_checkCommentEndPosition);
  }

  void _checkCommentEndPosition() {
    // Skip if no comment is playing
    if (_playingComment == null) return;

    final audioPlayerVM = Provider.of<AudioPlayerVM>(context, listen: false);
    final currentAudio = widget.currentAudio;
    final currentAudioPosition = _positionNotifier?.value;

    // Only proceed if we have valid position data
    if (currentAudioPosition == null) return;

    // This is the same code from your ValueListenableBuilder
    // When the current comment end position is reached, schedule a pause
    if (_playingComment != null &&
        audioPlayerVM.isPlaying &&
        (currentAudioPosition >=
                Duration(
                  milliseconds:
                      _playingComment!.commentEndPositionInTenthOfSeconds * 100,
                ) ||
            // The 'or' test below is necessary to enable
            // the pause of a comment whose end position
            // is the same as the audio end position. For
            // a reason I don't know, without this
            // condition, playing such a comment on the
            // Android smartphone does not call the
            // audioPlayerVMlistenFalse.pause() method!
            currentAudioPosition >=
                currentAudio.audioDuration -
                    const Duration(milliseconds: 1400))) {
      // You cannot await here, but you can trigger an
      // action which will not block the widget tree rendering.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        audioPlayerVM.pause();
      });
    }
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    if (_positionNotifier != null) {
      _positionNotifier!.removeListener(_checkCommentEndPosition);
      _positionNotifier = null;
    }

    _focusNodeDialog.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVM =
        Provider.of<ThemeProviderVM>(context);
    final AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
      context,
      listen: false,
    );
    final CommentVM commentVMlistenTrue = Provider.of<CommentVM>(
      context,
      listen: true,
    );
    final PictureVM pictureVMlistenFalse = Provider.of<PictureVM>(
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
      return Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.transparent),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 275),
              child: FloatingActionButton(
                key: const Key('maximizeCommentListAddDialogKey'),
                mini: true,
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.01),
                child: const Icon(Icons.expand_less, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isMinimized = false;
                  });
                },
              ),
            ),
          ),
        ],
      );
    }

    final List<Comment> loadedAudioComments =
        commentVMlistenTrue.loadAudioComments(
      audio: currentAudio,
    );

    return KeyboardListener(
      // Using FocusNode to enable clicking on Enter to close
      // the dialog
      focusNode: _focusNodeDialog,
      onKeyEvent: (event) async {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            await _whenClosingStopAudioIfPlaying(
              audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
              commentVMlistenTrue: commentVMlistenTrue,
              currentAudio: currentAudio,
            );

            // Check if we're using an overlay or a standard dialog
            if (CommentDialogManager.hasActiveOverlay) {
              // Use the global manager to close the dialog
              CommentDialogManager.closeCurrentOverlay();
            } else {
              // Otherwise, use standard navigation
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The FittedBox will scale the text to fit the available space
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.commentsDialogTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center, // Centered multi lines text
                  maxLines: 2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            (pictureVMlistenFalse.getLastAddedAudioPictureFile(
                          audio: currentAudio,
                        ) !=
                        null &&
                    CommentDialogManager.hasActiveOverlay &&
                    !widget.isCalledByAudioListItem)
                // Showing the minimize icon happens only if the comment list
                // add dialog was opened in the audio player view by the
                // CommentDialogManager.
                ? IconButton(
                    key: const Key('minimizeCommentListAddDialogKey'),
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
                : const SizedBox(width: 0),
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
            key: const Key('audioCommentsListKey'),
            children: _buildAudioCommentsLst(
              themeProviderVM: themeProviderVM,
              audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
              commentVMlistenTrue: commentVMlistenTrue,
              commentsLst: loadedAudioComments,
              currentAudio: currentAudio,
              isDarkTheme: isDarkTheme,
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              (loadedAudioComments.isNotEmpty)
                  ? TextButton(
                      key: const Key('extractCommentsToMp3TextButton'),
                      child: Tooltip(
                        message: AppLocalizations.of(context)!
                            .extractCommentsToMp3TextButtonTooltip,
                        child: Text(
                          AppLocalizations.of(context)!
                              .extractCommentsToMp3TextButton,
                          style: (isDarkTheme)
                              ? kTextButtonStyleDarkMode
                              : kTextButtonStyleLightMode,
                        ),
                      ),
                      onPressed: () async {
                        showDialog<void>(
                          context: context,
                          barrierDismissible:
                              false, // This line prevents the dialog from
                          // closing when tapping outside the dialog
                          builder: (BuildContext context) {
                            return AudioExtractorDialog(
                              settingsDataService: widget.settingsDataService,
                              currentAudio: currentAudio,
                              commentVMlistenTrue: commentVMlistenTrue,
                            );
                          },
                        );

                        if (CommentDialogManager.hasActiveOverlay) {
                          // Close the dialog if an overlay is active
                          CommentDialogManager.closeCurrentOverlay();
                        } else {
                          // Otherwise, close the normal dialog
                          Navigator.of(context).pop();
                        }
                      },
                    )
                  : const SizedBox(width: 0),
              TextButton(
                key: const Key('closeDialogTextButton'),
                child: Text(
                  AppLocalizations.of(context)!.closeTextButton,
                  style: (isDarkTheme)
                      ? kTextButtonStyleDarkMode
                      : kTextButtonStyleLightMode,
                ),
                onPressed: () async {
                  await _whenClosingStopAudioIfPlaying(
                    audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                    commentVMlistenTrue: commentVMlistenTrue,
                    currentAudio: currentAudio,
                  );

                  if (CommentDialogManager.hasActiveOverlay) {
                    // Close the dialog if an overlay is active
                    CommentDialogManager.closeCurrentOverlay();
                  } else {
                    // Otherwise, close the normal dialog
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Method called when clicking on dialog close button or on enter (on Windows).
  Future<void> _whenClosingStopAudioIfPlaying({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required CommentVM commentVMlistenTrue,
    required Audio currentAudio,
  }) async {
    // Calling setCurrentAudio() when closing the comment
    // list dialog is necessary, otherwise, on Android,
    // clicking on position buttons or audio slider will
    // not work after a comment was played.

    // Since playing a comment changes the audio player
    // position, avoiding to clear the undo/redo lists
    // enables the user to undo the audio position change.
    //
    // Checking if _playingComment is not null avoids to
    // stop playing the audio in case the user opened the
    // comment list dialog and then closed it without having
    // played a comment.
    if (_playingComment != null && audioPlayerVMlistenFalse.isPlaying) {
      await audioPlayerVMlistenFalse.pause();
    }

    await audioPlayerVMlistenFalse.setCurrentAudio(
      audio: currentAudio,
    );

    // Useful in order to redisplay the second line play/pause
    // icon in the audio player view containing a picture when
    // the comment list dialog is closed.
    commentVMlistenTrue.wasCommentDialogOpened = false;
  }

  List<Widget> _buildAudioCommentsLst({
    required ThemeProviderVM themeProviderVM,
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required CommentVM commentVMlistenTrue,
    required List<Comment> commentsLst,
    required Audio currentAudio,
    required bool isDarkTheme,
  }) {
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
                  commentVMlistenTrue: commentVMlistenTrue,
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
              // if the user clicks on a comment title while another
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
    required CommentVM commentVMlistenTrue,
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
                    // Use a simpler ValueListenableBuilder just for the icon state
                    icon: ValueListenableBuilder<Duration>(
                      valueListenable:
                          audioPlayerVMlistenFalse.currentAudioPositionNotifier,
                      builder: (context, currentAudioPosition, child) {
                        if (_playingComment != null &&
                            _playingComment == comment &&
                            audioPlayerVMlistenFalse.currentAudio!
                                .isPlayingOrPausedWithPositionBetweenAudioStartAndEnd &&
                            (currentAudioPosition >=
                                    Duration(
                                        milliseconds: comment
                                                .commentEndPositionInTenthOfSeconds *
                                            100) ||
                                // This 'or' addition is necessary to enable
                                // replaying a comment whose end position
                                // is the same as the audio end position. For
                                // a reason I don't know, without this
                                // condition, re-playing such a comment on the
                                // Android smartphone does not work !
                                currentAudioPosition >=
                                    currentAudio.audioDuration -
                                        const Duration(milliseconds: 1400))) {
                          // You cannot await here, but you can trigger an
                          // action which will not block the widget tree
                          // rendering.
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            await audioPlayerVMlistenFalse.pause();
                          });
                        }

                        // This logic avoids that when the user clicks on
                        // the play button of a comment, the play button
                        // of the other comment is updated to 'pause'.
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
                        audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
                        commentVMlistenTrue: commentVMlistenTrue,
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
                (comment.lastUpdateDateTime != comment.creationDateTime)
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
        settingsDataService: widget.settingsDataService,
        callerDialog: CallerDialog.commentListAddDialog,
        commentableAudio: currentAudio,
        comment: comment,
      ),
    );
  }

  Future<void> _confirmDeleteComment({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required CommentVM commentVMlistenTrue,
    required Audio currentAudio,
    required Comment comment,
  }) async {
    // Use overlay to display confirmation dialog
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry? confirmOverlayEntry;

    // Completer to wait for user response
    Completer<bool> confirmCompleter = Completer<bool>();

    confirmOverlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54, // Darkens the background
        child: Center(
          child: CommentDeleteConfirmActionDialog(
            actionFunction: (id, audio) async {
              // Delete the comment
              commentVMlistenTrue.deleteCommentFunction(id, audio);

              // Close the confirmation dialog
              confirmOverlayEntry?.remove();

              // Complete with true (action confirmed)
              confirmCompleter.complete(true);
            },
            actionFunctionArgs: [
              comment.id,
              currentAudio,
            ],
            dialogTitle:
                AppLocalizations.of(context)!.deleteCommentConfirnTitle,
            dialogContent: AppLocalizations.of(context)!
                .deleteCommentConfirnBody(comment.title),
            onCancel: () {
              // Close the confirmation dialog
              confirmOverlayEntry?.remove();

              // Complete with false (action canceled)
              confirmCompleter.complete(false);
            },
          ),
        ),
      ),
    );

    // Insert the confirmation dialog into the overlay
    overlayState.insert(confirmOverlayEntry);

    // Wait for user response
    bool confirmed = await confirmCompleter.future;

    // If the action is confirmed, pause playback
    if (confirmed && audioPlayerVMlistenFalse.isPlaying) {
      await audioPlayerVMlistenFalse.pause();
    }
  }

  Future<void> _playFromCommentPosition({
    required AudioPlayerVM audioPlayerVMlistenFalse,
    required Audio currentAudio,
    required Comment comment,
  }) async {
    _playingComment = comment;

    await audioPlayerVMlistenFalse.modifyAudioPlayerPosition(
      durationPosition: Duration(
          milliseconds: comment.commentStartPositionInTenthOfSeconds * 100),
      isUndoCommandToAdd: true,
    );

    if (audioPlayerVMlistenFalse.currentAudio != currentAudio) {
      // Adding the test fixes the problem of playing audio comments
      // from the comment list add dialog.
      await audioPlayerVMlistenFalse.setCurrentAudio(
        audio: currentAudio,
      );
    }

    await audioPlayerVMlistenFalse.playCurrentAudio(
      rewindAudioPositionBasedOnPauseDuration: false,
      commentEndPositionInTenthOfSeconds:
          comment.commentEndPositionInTenthOfSeconds,
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
