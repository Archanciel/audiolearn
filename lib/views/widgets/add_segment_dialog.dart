// lib/views/widgets/add_segment_dialog.dart
import 'package:flutter/material.dart';
import 'package:googleapis/appengine/v1.dart';
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
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _silenceController;
  late final TextEditingController _fadeInDurationController; // NEW
  late final TextEditingController _soundReductionPositionController;
  late final TextEditingController _soundReductionDurationController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(
      text: TimeFormatUtil.formatSeconds(
        widget.existingSegment?.startPosition ?? 0,
      ),
    );
    _endController = TextEditingController(
      text: TimeFormatUtil.formatSeconds(
        widget.existingSegment?.endPosition ?? 0,
      ),
    );
    _silenceController = TextEditingController(
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
    _titleController = TextEditingController(
      text: (widget.existingSegment?.title ?? ''),
    );
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _silenceController.dispose();
    _fadeInDurationController.dispose();
    _soundReductionPositionController.dispose();
    _soundReductionDurationController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _saveSegment() {
    final start = TimeFormatUtil.parseFlexible(_startController.text);
    final end = TimeFormatUtil.parseFlexible(_endController.text);
    final silence = TimeFormatUtil.parseFlexible(
      _silenceController.text,
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
    final title = _titleController.text.trim();

    if (start < 0 || start >= widget.maxDuration) {
      _showError(
        "${AppLocalizations.of(context)!.startPositionError} ${TimeFormatUtil.formatSeconds(widget.maxDuration)}",
      );
      return;
    }
    if (end <= start || end > widget.maxDuration) {
      _showError(
        "${AppLocalizations.of(context)!.endPositionError} ${TimeFormatUtil.formatSeconds(widget.maxDuration)}",
      );
      return;
    }
    if (silence < 0) {
      _showError(AppLocalizations.of(context)!.negativeSilenceDurationError);
      return;
    }
    if (fadeInDuration < 0) {
      // NEW validation
      _showError(AppLocalizations.of(context)!.fadeInDurationError);
      return;
    }
    final segmentDuration = end - start;
    if (fadeInDuration > segmentDuration) {
      // NEW validation
      _showError(AppLocalizations.of(context)!.fadeInExceedsCommentDurationError);
      return;
    }
    if (soundReductionDuration < 0) {
      _showError(AppLocalizations.of(context)!.negativeSoundDurationError);
      return;
    }
    // Validate sound reduction position
    if (soundReductionPosition > 0 && soundReductionDuration > 0) {
      if (soundReductionPosition < start) {
        _showError(AppLocalizations.of(context)!.negativeSoundPositionError);
        return;
      }
      if (soundReductionPosition >= end) {
        _showError(AppLocalizations.of(context)!.soundPositionBeyondEndError);
        return;
      }
      if (soundReductionPosition + soundReductionDuration > end) {
        _showError(AppLocalizations.of(context)!
            .soundPositionPlusDurationBeyondEndError);
        return;
      }
    }
    if (title.isEmpty) {
      _showError(AppLocalizations.of(context)!.emptyTitleError);
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
        title: title,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.red,
      ),
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
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.modifyAudioTitleLabel,
                border: const OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Text(
              "${AppLocalizations.of(context)!.maxDuration}: ${TimeFormatUtil.formatSeconds(widget.maxDuration)}",
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _startController,
              inputFormatters: [TimeTextInputFormatter()],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.startPositionLabel,
                hintText: '0:00.0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _endController,
              inputFormatters: [TimeTextInputFormatter()],
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.endPositionLabel,
                hintText: '0:00.0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _silenceController,
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
          onPressed: _saveSegment,
          child: Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }
}
