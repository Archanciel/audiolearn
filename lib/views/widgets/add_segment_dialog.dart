// lib/views/widgets/add_segment_dialog.dart
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/audio_segment.dart';
import '../../utils/time_format_util.dart';
import '../../utils/time_text_input_formatter.dart';

class AddSegmentDialog extends StatefulWidget {
  final double maxDuration;
  final AudioSegment? existingSegment;

  const AddSegmentDialog({
    super.key,
    required this.maxDuration,
    this.existingSegment,
  });

  @override
  State<AddSegmentDialog> createState() => _AddSegmentDialogState();
}

class _AddSegmentDialogState extends State<AddSegmentDialog> {
  late final TextEditingController _startPositionController;
  late final TextEditingController _endPositionController;
  late final TextEditingController _silenceDurationController;
  late final TextEditingController _fadeInDurationController; // NEW
  late final TextEditingController _soundReductionPositionController;
  late final TextEditingController _soundReductionDurationController;

  @override
  void initState() {
    super.initState();
    _startPositionController = TextEditingController(
      text: TimeFormatUtil.formatSeconds(
        widget.existingSegment?.startPosition ?? 0,
      ),
    );
    _endPositionController = TextEditingController(
      text: TimeFormatUtil.formatSeconds(
        widget.existingSegment?.endPosition ?? 0,
      ),
    );
    _silenceDurationController = TextEditingController(
      text: TimeFormatUtil.formatSeconds(
        widget.existingSegment?.silenceDuration ?? 0,
      ),
    );
    _fadeInDurationController = TextEditingController(
      text: TimeFormatUtil.formatSeconds(
        widget.existingSegment?.fadeInDuration ?? 0,
      ),
    );
    _soundReductionPositionController = TextEditingController(
      text: TimeFormatUtil.formatSeconds(
        widget.existingSegment?.soundReductionPosition ?? 0,
      ),
    );
    _soundReductionDurationController = TextEditingController(
      text: TimeFormatUtil.formatSeconds(
        widget.existingSegment?.soundReductionDuration ?? 0,
      ),
    );
  }

  @override
  void dispose() {
    _startPositionController.dispose();
    _endPositionController.dispose();
    _silenceDurationController.dispose();
    _fadeInDurationController.dispose();
    _soundReductionPositionController.dispose();
    _soundReductionDurationController.dispose();
    super.dispose();
  }

  void _saveSegment() {
    final start = TimeFormatUtil.parseFlexible(_startPositionController.text);
    final end = TimeFormatUtil.parseFlexible(_endPositionController.text);
    final silence = TimeFormatUtil.parseFlexible(
      _silenceDurationController.text,
    );
    final fadeInDuration = TimeFormatUtil.parseFlexible(
      // NEW
      _fadeInDurationController.text,
    );
    final soundReductionPosition = TimeFormatUtil.parseFlexible(
      _soundReductionPositionController.text,
    );
    final soundReductionDuration = TimeFormatUtil.parseFlexible(
      _soundReductionDurationController.text,
    );
    final commentId = widget.existingSegment?.commentId ?? '';
    final commentTitle = widget.existingSegment?.commentTitle ?? '';

    if (start < 0 || start > widget.maxDuration - 0.1) {
      _showError(
        "${AppLocalizations.of(context)!.startPositionError(TimeFormatUtil.formatSeconds(widget.maxDuration - 0.1))}.",
      );
      return;
    }
    if (end <= start || end > widget.maxDuration) {
      _showError(
        "${AppLocalizations.of(context)!.endPositionError} ${TimeFormatUtil.formatSeconds(widget.maxDuration)}.",
      );
      return;
    }
    if (silence < 0) {
      _showError(
          "${AppLocalizations.of(context)!.negativeSilenceDurationError}.");
      return;
    }
    if (fadeInDuration < 0) {
      // NEW validation
      _showError("${AppLocalizations.of(context)!.fadeInDurationError}.");
      return;
    }
    final segmentDuration = end - start;
    if (fadeInDuration > segmentDuration) {
      // NEW validation
      _showError(
          "${AppLocalizations.of(context)!.fadeInExceedsCommentDurationError}.");
      return;
    }
    if (soundReductionDuration < 0) {
      _showError(
          "${AppLocalizations.of(context)!.negativeSoundDurationError}.");
      return;
    }
    // Validate sound reduction position
    if (soundReductionPosition > 0 && soundReductionDuration > 0) {
      if (soundReductionPosition < start) {
        _showError(
            "${AppLocalizations.of(context)!.negativeSoundPositionError}.");
        return;
      }
      if (soundReductionPosition >= end) {
        _showError(
            "${AppLocalizations.of(context)!.soundPositionBeyondEndError}.");
        return;
      }
      if (soundReductionPosition + soundReductionDuration > end) {
        _showError(
            "${AppLocalizations.of(context)!.soundPositionPlusDurationBeyondEndError}.");
        return;
      }
    }
    if (commentTitle.isEmpty) {
      _showError("${AppLocalizations.of(context)!.emptyTitleError}.");
      return;
    }

    Navigator.of(context).pop(
      AudioSegment(
        startPosition: start,
        endPosition: end,
        silenceDuration: silence,
        fadeInDuration: fadeInDuration,
        soundReductionPosition: soundReductionPosition,
        soundReductionDuration: soundReductionDuration,
        commentId: commentId,
        commentTitle: commentTitle,

        // When saving the edited segment, deleted must be set to false
        deleted: false,
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 32),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.errorTitle,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingSegment != null
            ? AppLocalizations.of(context)!.editCommentDialogTitle
            : AppLocalizations.of(context)!.addCommentDialogTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingSegment!.commentTitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700, // bold
                fontSize: 15,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            (widget.existingSegment!.deleted)
                ? Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Tooltip(
                      message: AppLocalizations.of(context)!
                          .commentWasDeletedTooltip,
                      child: Text(
                        AppLocalizations.of(context)!.commentWasDeleted,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700, // bold
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            Text(
              // Displays the total audio duration
              "${AppLocalizations.of(context)!.maxDuration}: ${TimeFormatUtil.formatSeconds(widget.maxDuration)}",
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('startPositionTextField'),
              controller: _startPositionController,
              inputFormatters: [TimeTextInputFormatter()],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.startPositionLabel,
                hintText: '0:00.0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('endPositionTextField'),
              controller: _endPositionController,
              inputFormatters: [TimeTextInputFormatter()],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.endPositionLabel,
                hintText: '0:00.0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('silenceDurationTextField'),
              controller: _silenceDurationController,
              inputFormatters: [TimeTextInputFormatter()],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.silenceDurationLabel,
                hintText: '0:00.0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.volumeFadeInOptional,
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('fadeInDurationTextField'),
              controller: _fadeInDurationController,
              inputFormatters: [TimeTextInputFormatter()],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.fadeInDurationLabel,
                hintText: '0:00.0',
                border: OutlineInputBorder(),
                helperText:
                    AppLocalizations.of(context)!.fadeInDurationHelperText,
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.volumeFadeOutOptional,
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('soundReductionPositionTextField'),
              controller: _soundReductionPositionController,
              inputFormatters: [TimeTextInputFormatter()],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.fadeStartPositionLabel,
                hintText:
                    AppLocalizations.of(context)!.fadeStartPositionHintText,
                border: OutlineInputBorder(),
                helperText:
                    AppLocalizations.of(context)!.fadeStartPositionHelperText,
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('soundReductionDurationTextField'),
              controller: _soundReductionDurationController,
              inputFormatters: [TimeTextInputFormatter()],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.fadeDurationLabel,
                hintText: "0:00.0",
                border: OutlineInputBorder(),
                helperText:
                    AppLocalizations.of(context)!.fadeDurationHelperText,
                helperMaxLines: 2,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        ElevatedButton(
          key: Key('saveEditedSegmentButton'),
          onPressed: _saveSegment,
          child: Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }
}
