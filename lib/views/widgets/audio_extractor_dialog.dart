import 'dart:io';

import 'package:audiolearn/models/audio_segment.dart';
import 'package:audiolearn/models/help_item.dart';
import 'package:audiolearn/services/audio_extractor_service.dart';
import 'package:audiolearn/utils/path_util.dart';
import 'package:audiolearn/utils/time_format_util.dart';
import 'package:audiolearn/viewmodels/audio_extractor_vm.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:audiolearn/viewmodels/extract_mp3_audio_player_vm.dart';
import 'package:audiolearn/views/widgets/add_segment_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/audio.dart';
import '../../models/comment.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';

class AudioExtractorDialog extends StatefulWidget {
  final SettingsDataService settingsDataService = SettingsDataService();
  final Audio currentAudio;
  final CommentVM commentVMlistenTrue;

  AudioExtractorDialog({
    super.key,
    required this.currentAudio,
    required this.commentVMlistenTrue,
  });

  @override
  State<AudioExtractorDialog> createState() => _AudioExtractorDialogState();
}

class _AudioExtractorDialogState extends State<AudioExtractorDialog>
    with ScreenMixin {
  late final List<HelpItem> _helpItemsLst;
  late final ScrollController _segmentsScrollController;
  bool _extractInMusicQuality = false;

  @override
  void initState() {
    super.initState();
    _segmentsScrollController = ScrollController();
    final AudioExtractorVM audioExtractorVM = context.read<AudioExtractorVM>();
    audioExtractorVM.currentAudio = widget.currentAudio;
    audioExtractorVM.commentVMlistenTrue = widget.commentVMlistenTrue;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _pickMP3File(
        context: context,
        audioExtractorVM: audioExtractorVM,
      );

      await _loadSegmentsFromCommentFile(
        context: context,
        audioExtractorVM: audioExtractorVM,
      );
      _helpItemsLst = [
        HelpItem(
          helpTitle: AppLocalizations.of(context)!.defaultApplicationHelpTitle,
          helpContent:
              AppLocalizations.of(context)!.defaultApplicationHelpContent,
        ),
        HelpItem(
          helpTitle:
              AppLocalizations.of(context)!.modifyingExistingPlaylistsHelpTitle,
          helpContent: AppLocalizations.of(context)!
              .modifyingExistingPlaylistsHelpContent,
        ),
        HelpItem(
          helpTitle:
              AppLocalizations.of(context)!.alreadyDownloadedAudiosHelpTitle,
          helpContent:
              AppLocalizations.of(context)!.alreadyDownloadedAudiosHelpContent,
        ),
        HelpItem(
          helpTitle:
              AppLocalizations.of(context)!.excludingFutureDownloadsHelpTitle,
          helpContent:
              AppLocalizations.of(context)!.excludingFutureDownloadsHelpContent,
        ),
      ];
    });
  }

  @override
  void dispose() {
    _segmentsScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProviderVM themeProviderVMlistenFalse =
        Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    ); // by default, listen is true

    return Theme(
      data: themeProviderVMlistenFalse.currentTheme == AppTheme.dark
          ? ScreenMixin.themeDataDark
          : ScreenMixin.themeDataLight,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.audioExtractorDialogTitle,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSettingsDialog(context: context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer2<AudioExtractorVM, ExtractMp3AudioPlayerVM>(
            builder: (context, audioExtractorVM, audioPlayerVM, _) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.commentsDialogTitle} (${audioExtractorVM.segmentCount})",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    (audioExtractorVM.segments.isEmpty)
                        ? const SizedBox.shrink() // ← Renders nothing
                        : Container(
                            constraints: const BoxConstraints(
                              maxHeight: 400,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Scrollbar(
                              controller: _segmentsScrollController,
                              thumbVisibility: true,
                              child: ListView.builder(
                                controller: _segmentsScrollController,
                                primary: false,
                                shrinkWrap: true,
                                itemCount: audioExtractorVM.segments.length,
                                itemBuilder: (context, index) {
                                  final s = audioExtractorVM.segments[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        child: Text('${index + 1}'),
                                      ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.title,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                TimeFormatUtil.formatSeconds(
                                                    s.startPosition),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              const Icon(
                                                Icons
                                                    .arrow_forward, // or Icons.arrow_right_alt
                                                size: 15, // ← Control size
                                                color: Colors.white70,
                                              ),
                                            ],
                                          ),
                                          Text(
                                            TimeFormatUtil.formatSeconds(
                                                s.endPosition),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${AppLocalizations.of(context)!.soundReductionPosition}: ${TimeFormatUtil.formatSeconds(s.soundReductionPosition)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${AppLocalizations.of(context)!.soundReductionDuration}: ${TimeFormatUtil.formatSeconds(s.soundReductionDuration)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        "${AppLocalizations.of(context)!.duration}: ${TimeFormatUtil.formatSeconds(s.duration)}"
                                        "${s.silenceDuration > 0 ? ' + ${AppLocalizations.of(context)!.silence} ${TimeFormatUtil.formatSeconds(s.silenceDuration)}' : ''}",
                                        style: const TextStyle(
                                            fontSize: 12), // ← Smaller font
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              // After pressing 'Edit' icon button
                                              final AudioSegment?
                                                  updatedSegment =
                                                  await showDialog<
                                                      AudioSegment>(
                                                context: context,
                                                builder: (
                                                  _,
                                                ) =>
                                                    AddSegmentDialog(
                                                  maxDuration: audioExtractorVM
                                                      .audioFile.duration,
                                                  existingSegment: s,
                                                ),
                                              );

                                              if (updatedSegment != null) {
                                                audioExtractorVM.updateSegment(
                                                  index: index,
                                                  segment: updatedSegment,
                                                );
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _confirmDeleteSegment(
                                              context,
                                              audioExtractorVM,
                                              index,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                    if (audioExtractorVM.segments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${AppLocalizations.of(context)!.totalDuration}: ${TimeFormatUtil.formatSeconds(audioExtractorVM.totalDuration)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _confirmClearSegments(
                              context,
                              audioExtractorVM,
                            ),
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: Text(
                                AppLocalizations.of(context)!.clearAllButton),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed:
                              audioExtractorVM.extractionResult.isProcessing
                                  ? null
                                  : () => _extractMP3(context: context),
                          child: Text(
                            AppLocalizations.of(context)!.extractMp3Button,
                          ),
                        ),
                        createCheckboxRowFunction(
                          // displaying music quality checkbox
                          checkBoxWidgetKey:
                              const Key('playlistQualityConfirmDialogCheckBox'),
                          context: context,
                          label:
                              AppLocalizations.of(context)!.inMusicQualityLabel,
                          value: _extractInMusicQuality,
                          onChangedFunction: (bool? value) {
                            setState(() {
                              _extractInMusicQuality = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (audioExtractorVM.extractionResult.isProcessing)
                      const Center(child: CircularProgressIndicator()),
                    if (audioExtractorVM.extractionResult.hasMessage)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          audioExtractorVM.extractionResult.message,
                          style: TextStyle(
                            color: audioExtractorVM.extractionResult.isError
                                ? Colors.red
                                : audioExtractorVM.extractionResult.isSuccess
                                    ? Colors.green[700]
                                    : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (audioExtractorVM.extractionResult.isSuccess &&
                        audioExtractorVM.extractionResult.outputPath !=
                            null) ...[
                      const SizedBox(height: 8),
                      _buildAudioPlayerControls(
                        context: context,
                        audioExtractorVM: audioExtractorVM,
                        audioPlayerVM: audioPlayerVM,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAudioPlayerControls({
    required BuildContext context,
    required AudioExtractorVM audioExtractorVM,
    required ExtractMp3AudioPlayerVM audioPlayerVM,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: audioPlayerVM.hasError
                  ? () => audioPlayerVM.tryRepairPlayer()
                  : audioPlayerVM.isLoaded
                      ? () => audioPlayerVM.togglePlay()
                      : () => _playExtractedFile(
                            context,
                            audioExtractorVM.extractionResult.outputPath!,
                          ),
              icon: Icon(
                audioPlayerVM.hasError
                    ? Icons.refresh
                    : audioPlayerVM.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
              ),
              label: Text(
                audioPlayerVM.hasError
                    ? 'Retry'
                    : audioPlayerVM.isPlaying
                        ? 'Pause'
                        : 'Play',
              ),
            ),
          ],
        ),
        if (audioPlayerVM.isLoaded && !audioPlayerVM.hasError) ...[
          const SizedBox(height: 8),
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 4,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
            ),
            child: Slider(
              value: audioPlayerVM.progressPercent.clamp(0.0, 1.0),
              onChanged: (value) => audioPlayerVM.seekByPercentage(
                percentage: value,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TimeFormatUtil.formatDuration(
                    audioPlayerVM.position,
                  ),
                ),
                Text(
                  TimeFormatUtil.formatDuration(
                    audioPlayerVM.duration,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${AppLocalizations.of(context)!.audioStatePlaying}: ${PathUtil.fileName(audioExtractorVM.extractionResult.outputPath!)}",
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (audioPlayerVM.hasError)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              audioPlayerVM.errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  void _confirmDeleteSegment(
    BuildContext context,
    AudioExtractorVM vm,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCommentDialogTitle),
        content: Text(
          AppLocalizations.of(context)!.deleteCommentExplanation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              vm.removeSegment(index);
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _confirmClearSegments(
    BuildContext context,
    AudioExtractorVM vm,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.clearAllCommentDialogTitle),
        content: Text(
          AppLocalizations.of(context)!.clearAllCommentExplanation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              vm.clearSegments();
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.clearAllButton),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('MP3 Extractor $kApplicationVersion'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
  // ────────────────────────────────────────────────────────────────────────────
  // File picking helpers
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _pickMP3File({
    required BuildContext context,
    required AudioExtractorVM audioExtractorVM,
  }) async {
    try {
      final String path = widget.currentAudio.filePathName;

      final double duration = await AudioExtractorService.getAudioDuration(
        filePath: path,
      );

      audioExtractorVM.setAudioFile(
        path: path,
        name: widget.currentAudio.audioFileName,
        duration: duration,
      );
    } catch (e) {
      audioExtractorVM.setError('Error selecting file: $e');
    }
  }

  Future<void> _loadSegmentsFromCommentFile({
    required BuildContext context,
    required AudioExtractorVM audioExtractorVM,
  }) async {
    try {
      Audio currentAudio = widget.currentAudio;
      final List<Comment> commentsLst =
          widget.commentVMlistenTrue.loadAudioComments(
        audio: currentAudio,
      );

      _extractInMusicQuality = currentAudio.isAudioMusicQuality;
      audioExtractorVM.commentsLst = commentsLst;

      if (commentsLst.isEmpty) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.noCommentFoundInAudioMessage),
            backgroundColor: Colors.orange,
          ),
        );

        return;
      }

      int added = 0;
      int skipped = 0;

      for (int i = 0; i < commentsLst.length; i++) {
        final Comment comment = commentsLst[i];
        final double start =
            comment.commentStartPositionInTenthOfSeconds / 10.0;
        final double end = comment.commentEndPositionInTenthOfSeconds / 10.0;

        if (start >= 0 &&
            end > start &&
            audioExtractorVM.audioFile.duration > 0 &&
            end <= audioExtractorVM.audioFile.duration) {

          double silence = comment.silenceDuration;

          if (silence == 0.0) {
            (i < commentsLst.length - 1) ? kDefaultSilenceDuration : 0.0;
          }

          audioExtractorVM.addSegment(
            AudioSegment(
              startPosition: start,
              endPosition: end,
              silenceDuration: silence,
              soundReductionPosition: comment.soundReductionPosition,
              soundReductionDuration: comment.soundReductionDuration,
              title: comment.title,
            ),
          );
          added++;
        } else {
          skipped++;
        }
      }

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Loaded $added segment(s)${skipped > 0 ? ' ($skipped skipped)' : ''}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      audioExtractorVM.setError('Error loading comment file: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading comment file: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _extractMP3({required BuildContext context}) async {
    final AudioExtractorVM audioExtractorVM = context.read<AudioExtractorVM>();
    final ExtractMp3AudioPlayerVM audioPlayerVM =
        context.read<ExtractMp3AudioPlayerVM>();

    if (audioExtractorVM.multiInputs.isEmpty) {
      if (audioExtractorVM.audioFile.path == null) {
        audioExtractorVM.setError('Please select an MP3 file first');

        return;
      }

      if (audioExtractorVM.segments.isEmpty) {
        audioExtractorVM.setError(
            AppLocalizations.of(context)!.addAtLeastOneCommentMessage);

        return;
      }
    }

    try {
      // ✅ NEW - Release on ALL platforms
      if (audioPlayerVM.isLoaded) {
        if (Platform.isWindows) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preparing extraction...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        await audioPlayerVM.releaseCurrentFile();

        if (Platform.isWindows) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      final String base = PathUtil.removeExtension(
        audioExtractorVM.audioFile.name ?? 'extract',
      );

      String extractedMp3FileName;

      if (audioExtractorVM.multiInputs.isNotEmpty) {
        final totalSegs = audioExtractorVM.multiInputs.fold<int>(
          0,
          (n, i) => n + i.segments.length,
        );
        extractedMp3FileName = '${base}_multi_${totalSegs}_comments.mp3';
      } else if (audioExtractorVM.segments.length == 1) {
        extractedMp3FileName =
            '$base from ${TimeFormatUtil.formatSeconds(audioExtractorVM.segments[0].startPosition)} '
            'to ${TimeFormatUtil.formatSeconds(audioExtractorVM.segments[0].endPosition)}.mp3';
      } else {
        extractedMp3FileName =
            '${base}_${audioExtractorVM.segments.length}_comments.mp3';
      }

      if (_extractInMusicQuality) {
        extractedMp3FileName =
            "${AppLocalizations.of(context)!.inMusicQuality}_$extractedMp3FileName";
      }

      extractedMp3FileName = PathUtil.sanitizeFileName(
        extractedMp3FileName,
      );

      final String? extractedMp3DestinationDir =
          await FilePicker.platform.getDirectoryPath();
      if (extractedMp3DestinationDir == null) {
        audioExtractorVM.setError(
            AppLocalizations.of(context)!.saveLocationSelectionCanceledMessage);

        return;
      }

      final String outputPath =
          '$extractedMp3DestinationDir${Platform.pathSeparator}$extractedMp3FileName';

      if (audioExtractorVM.multiInputs.isNotEmpty) {
        await audioExtractorVM.extractMP3Multi(outputPath);
      } else {
        await audioExtractorVM.extractMP3(
          inMusicQuality: _extractInMusicQuality,
          outputPath: outputPath,
        );
      }
    } catch (e) {
      audioExtractorVM.setError('Error selecting save location: $e');
    }
  }

  Future<void> _playExtractedFile(
    BuildContext context,
    String filePath,
  ) async {
    final audioPlayerVM = context.read<ExtractMp3AudioPlayerVM>();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    try {
      await audioPlayerVM.loadFile(filePath: filePath);
      if (!audioPlayerVM.hasError) {
        await audioPlayerVM.togglePlay();
      } else {
        if (!context.mounted) return;
        _showErrorSnackBar(context, audioPlayerVM.errorMessage);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar(context, 'Error playing file: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Repair',
          textColor: Colors.white,
          onPressed: () async {
            final audioPlayerVM = Provider.of<ExtractMp3AudioPlayerVM>(
              context,
              listen: false,
            );
            await audioPlayerVM.tryRepairPlayer();
          },
        ),
      ),
    );
  }
}
