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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/audio.dart';
import '../../models/comment.dart';
import '../../models/playlist.dart';
import '../../viewmodels/audio_download_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../../views/screen_mixin.dart';
import '../../constants.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import 'help_dialog.dart';
import 'playlist_one_selectable_dialog.dart';

class AudioExtractorScreen extends StatefulWidget {
  final SettingsDataService settingsDataService;
  final Audio currentAudio;
  final CommentVM commentVMlistenTrue;

  const AudioExtractorScreen({
    super.key,
    required this.settingsDataService,
    required this.currentAudio,
    required this.commentVMlistenTrue,
  });

  @override
  State<AudioExtractorScreen> createState() => _AudioExtractorScreenState();
}

class _AudioExtractorScreenState extends State<AudioExtractorScreen>
    with ScreenMixin {
  late final List<HelpItem> _helpItemsLst;
  late final ScrollController _segmentsScrollController;
  bool _extractInMusicQuality = false;
  bool _extractInDirectory = true;
  bool _extractInPlaylist = false;

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
          helpTitle: AppLocalizations.of(context)!.playlistRestorationHelpTitle,
          helpContent: AppLocalizations.of(context)!
              .restorePlaylistAndCommentsFromZipTooltip,
          displayHelpItemNumber: false,
        ),
        HelpItem(
          helpTitle:
              AppLocalizations.of(context)!.playlistRestorationFirstHelpTitle,
          helpContent:
              AppLocalizations.of(context)!.playlistRestorationFirstHelpContent,
          displayHelpItemNumber: true,
        ),
        HelpItem(
          helpTitle:
              AppLocalizations.of(context)!.playlistRestorationSecondHelpTitle,
          helpContent: '',
          displayHelpItemNumber: false,
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
            textAlign: TextAlign.center, // Centered multi lines text
            maxLines: 2,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: IconTheme(
                data: (themeProviderVMlistenFalse.currentTheme == AppTheme.dark
                        ? ScreenMixin.themeDataDark
                        : ScreenMixin.themeDataLight)
                    .iconTheme,
                child: const Icon(
                  Icons.help_outline,
                  size: 39.0, // 40 is too big for french version
                ),
              ),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => HelpDialog(
                    helpItemsLst: _helpItemsLst,
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer2<AudioExtractorVM, ExtractMp3AudioPlayerVM>(
            builder: (context, audioExtractorVM, audioPlayerVM, _) {
              String extractionResultMessage =
                  audioExtractorVM.extractionResult.message;
              if (extractionResultMessage.contains('Extracted MP3 saved to')) {
                extractionResultMessage = extractionResultMessage.replaceFirst(
                  'Extracted MP3 saved to',
                  AppLocalizations.of(context)!.extractedMp3Saved,
                );
              }
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
                                  final AudioSegment segment =
                                      audioExtractorVM.segments[index];
                                  final String displayedIndex =
                                      (index + 1).toString();
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        child: Text(displayedIndex),
                                      ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            segment.commentTitle,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w700, // bold
                                              fontSize: 15,
                                            ),
                                          ),
                                          (segment.deleted)
                                              ? Tooltip(
                                                  message: AppLocalizations.of(
                                                          context)!
                                                      .commentWasDeletedTooltip,
                                                  child: Text(
                                                    key: Key(
                                                        'commentDeletedTextKey_$displayedIndex'),
                                                    AppLocalizations.of(
                                                            context)!
                                                        .commentWasDeleted,
                                                    maxLines: 2,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight
                                                          .w700, // bold
                                                      fontSize: 14,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                          Row(
                                            children: [
                                              Tooltip(
                                                message: AppLocalizations.of(
                                                        context)!
                                                    .commentStartPositionTooltip,
                                                child: Text(
                                                  TimeFormatUtil.formatSeconds(
                                                      segment.startPosition),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    color: Colors.white70,
                                                  ),
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
                                          Tooltip(
                                            message:
                                                AppLocalizations.of(context)!
                                                    .commentEndPositionTooltip,
                                            child: Text(
                                              TimeFormatUtil.formatSeconds(
                                                  segment.endPosition),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Tooltip(
                                            message:
                                                AppLocalizations.of(context)!
                                                    .fadeStartPositionTooltip,
                                            child: Text(
                                              "${AppLocalizations.of(context)!.fadeStartPosition}: ${TimeFormatUtil.formatSeconds(segment.fadeInDuration)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Tooltip(
                                            message: AppLocalizations.of(
                                                    context)!
                                                .soundReductionPositionTooltip,
                                            child: Text(
                                              "${AppLocalizations.of(context)!.soundReductionPosition}: ${TimeFormatUtil.formatSeconds(segment.soundReductionPosition)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Tooltip(
                                            message: AppLocalizations.of(
                                                    context)!
                                                .soundReductionDurationTooltip,
                                            child: Text(
                                              "${AppLocalizations.of(context)!.soundReductionDuration}: ${TimeFormatUtil.formatSeconds(segment.soundReductionDuration)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        "${AppLocalizations.of(context)!.duration}: ${TimeFormatUtil.formatSeconds(segment.duration)}"
                                        "${segment.silenceDuration > 0 ? ' + ${AppLocalizations.of(context)!.silence} ${TimeFormatUtil.formatSeconds(segment.silenceDuration)}' : ''}",
                                        style: const TextStyle(
                                            fontSize: 12), // ← Smaller font
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            key: Key(
                                                'editSegmentButtonKey_$displayedIndex'),
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              // After pressing 'Edit' icon button, show
                                              // the AddSegmentDialog to edit the segment
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
                                                  existingSegment: segment,
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
                                            key: Key(
                                                'deleteSegmentButtonKey_$displayedIndex'),
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _confirmDeleteSegment(
                                              context: context,
                                              audioExtractorVM:
                                                  audioExtractorVM,
                                              segmentToDeleteIndex: index,
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
                            key: const Key('totalSegmentsDurationTextKey'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            key: const Key('clearAllSegmentsButton'),
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
                    (audioExtractorVM
                            .existNotDeletedSegmentWithEndPositionGreaterThanAudioDuration())
                        ? Text(
                            key: const Key('deleteInvalidCommentsMessageKey'),
                            AppLocalizations.of(context)!
                                .deleteInvalidCommentsMessage(
                                    TimeFormatUtil.formatSeconds(widget
                                            .currentAudio
                                            .audioDuration
                                            .inMilliseconds /
                                        1000.0)),
                            maxLines: 4,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.w700, // bold
                            ),
                          )
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    key: const Key('extractMp3Button'),
                                    onPressed: audioExtractorVM
                                            .extractionResult.isProcessing
                                        ? null
                                        : () => _extractMP3(
                                              context: context,
                                              settingsDataService:
                                                  widget.settingsDataService,
                                            ),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .extractMp3Button,
                                    ),
                                  ),
                                  createCheckboxRowFunction(
                                    // displaying music quality checkbox
                                    checkBoxWidgetKey:
                                        const Key('musicalQualityCheckBox'),
                                    context: context,
                                    label: AppLocalizations.of(context)!
                                        .inMusicQualityLabel,
                                    value: _extractInMusicQuality,
                                    onChangedFunction: (bool? value) {
                                      setState(() {
                                        _extractInMusicQuality = value ?? false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  createCheckboxRowFunction(
                                    // displaying music quality checkbox
                                    checkBoxWidgetKey:
                                        const Key('onDirectoryCheckBox'),
                                    context: context,
                                    label: AppLocalizations.of(context)!
                                        .inDirectoryLabel,
                                    labelTooltip: AppLocalizations.of(context)!
                                        .inDirectoryLabelTooltip,
                                    value: _extractInDirectory,
                                    onChangedFunction: (bool? value) {
                                      setState(() {
                                        _extractInDirectory = value ?? false;
                                        _extractInPlaylist =
                                            !_extractInDirectory;
                                      });

                                      if (!_extractInDirectory) {
                                        // Clear the directory not selected error
                                        audioExtractorVM.setError('');
                                      }
                                    },
                                  ),
                                  createCheckboxRowFunction(
                                    // displaying music quality checkbox
                                    checkBoxWidgetKey:
                                        const Key('inPlaylistCheckBox'),
                                    context: context,
                                    label: AppLocalizations.of(context)!
                                        .inPlaylistLabel,
                                    labelTooltip: AppLocalizations.of(context)!
                                        .inPlaylistLabelTooltip,
                                    value: _extractInPlaylist,
                                    onChangedFunction: (bool? value) {
                                      setState(() {
                                        _extractInPlaylist = value ?? false;
                                        _extractInDirectory =
                                            !_extractInPlaylist;
                                      });

                                      // Clear the directory not selected error
                                      audioExtractorVM.setError('');
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                    if (audioExtractorVM.extractionResult.isProcessing)
                      const Center(child: CircularProgressIndicator()),
                    if (audioExtractorVM.extractionResult.hasMessage)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          extractionResultMessage,
                          style: TextStyle(
                            color: audioExtractorVM.extractionResult.isError
                                ? Colors.red
                                : audioExtractorVM.extractionResult.isSuccess
                                    ? Colors.green[700]
                                    : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700, // bold
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
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: IconButton(
                key: const Key('playPauseButton'),
                iconSize: 80,
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
                style: ButtonStyle(
                  // Highlight button when pressed
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                        horizontal: kSmallButtonInsidePadding, vertical: 0),
                  ),
                  overlayColor: iconButtonTapModification, // Tap feedback color
                ),
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
            maxLines: 2,
          ),
        ],
        if (audioPlayerVM.hasError)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              audioPlayerVM.errorMessage.replaceFirst('File does not exist',
                  AppLocalizations.of(context)!.fileNotExistError),
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
      ],
    );
  }

  void _confirmDeleteSegment({
    required BuildContext context,
    required AudioExtractorVM audioExtractorVM,
    required int segmentToDeleteIndex,
  }) {
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
            key: const Key('confirmDeleteSegmentButton'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              audioExtractorVM.removeSegment(
                segmentToRemoveIndex: segmentToDeleteIndex,
              );
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
    AudioExtractorVM audioExtractorVM,
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
            key: const Key('confirmClearAllSegmentsButton'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              audioExtractorVM.clearAllSegments();
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.clearAllButton),
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
    final String path = widget.currentAudio.filePathName;

    final double duration = await AudioExtractorService.getAudioDuration(
      filePath: path,
    );

    audioExtractorVM.setAudioFile(
      path: path,
      name: widget.currentAudio.audioFileName,
      duration: duration,
    );
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
        // Useful if in the audio extractor dialog the red 'Clear all'
        // button was pressed
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.noCommentFoundInAudioMessage,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700, // bold
              ),
            ),
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
            audioExtractorVM.audioFile.duration > 0) {
          double silence = comment.silenceDuration;

          if (silence == 0.0) {
            (i < commentsLst.length - 1) ? kDefaultSilenceDuration : 0.0;
          }

          audioExtractorVM.addSegment(
            AudioSegment(
              startPosition: start,
              endPosition: end,
              silenceDuration: silence,
              fadeInDuration: comment.fadeInDuration,
              soundReductionPosition: comment.soundReductionPosition,
              soundReductionDuration: comment.soundReductionDuration,
              commentId: comment.id,
              commentTitle: comment.title,
              deleted: comment.deleted,
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
            "${AppLocalizations.of(context)!.loadedComments(added)}${skipped > 0 ? ' ${AppLocalizations.of(context)!.skippedComments(skipped)}' : ''}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700, // bold
            ),
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

  Future<void> _extractMP3({
    required BuildContext context,
    required SettingsDataService settingsDataService,
  }) async {
    final AudioExtractorVM audioExtractorVM = context.read<AudioExtractorVM>();
    final ExtractMp3AudioPlayerVM audioPlayerVM =
        context.read<ExtractMp3AudioPlayerVM>();

    if (audioExtractorVM.multiInputs.isEmpty) {
      if (audioExtractorVM.audioFile.path == null) {
        audioExtractorVM.setError('Please select an MP3 file first');

        return;
      }

      if (audioExtractorVM.segments.isEmpty) {
        // Useful if in the audio extractor dialog the red 'Clear all'
        // button was pressed
        audioExtractorVM.setError(
            AppLocalizations.of(context)!.addAtLeastOneCommentMessage);

        return;
      }
    }

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

    if (_extractInDirectory) {
      int extractedSegmentsNumber = audioExtractorVM.segmentsNotDeletedNumber();

      if (audioExtractorVM.multiInputs.isNotEmpty) {
        final totalSegs = audioExtractorVM.multiInputs.fold<int>(
          0,
          (n, i) => n + i.segments.length,
        );
        extractedMp3FileName = '${base}_multi_${totalSegs}_comments.mp3';
      } else if (extractedSegmentsNumber == 1) {
        extractedMp3FileName =
            '$base from ${TimeFormatUtil.formatSeconds(audioExtractorVM.segments[0].startPosition)} '
            'to ${TimeFormatUtil.formatSeconds(audioExtractorVM.segments[0].endPosition)}.mp3';
      } else {
        extractedMp3FileName =
            '${base}_${extractedSegmentsNumber}_comments.mp3';
      }

      if (_extractInMusicQuality) {
        // AppLocalizations.of(context)!.inMusicQuality is only added
        // when the extracted music quality MP3 is placed in a directory
        // and not when it is added to a playlist
        extractedMp3FileName =
            "${AppLocalizations.of(context)!.inMusicQuality}_$extractedMp3FileName";
      }
    } else {
      // Extracting to playlist. The file name is simpler here without
      // music quality addition to the file name and without comments
      // number because the file is stored in the playlist directory.
      extractedMp3FileName = '$base.mp3';
    }

    extractedMp3FileName = PathUtil.sanitizeFileName(
      extractedMp3FileName,
    );

    Playlist? targetPlaylist;

    if (!_extractInDirectory) {
      // Showing the dialog enabling to select the playlist where to add
      // the audio containing the extracted MP3 as well as the corresponding
      // comments
      showDialog<dynamic>(
        context: context,
        builder: (context) => PlaylistOneSelectableDialog(
          usedFor: PlaylistOneSelectableDialogUsedFor
              .fromCommentsExtractedMp3AddedToPlaylist,
          warningMessageVM: Provider.of<WarningMessageVM>(
            context,
            listen: false,
          ),
          excludedPlaylist: widget.currentAudio.enclosingPlaylist!,
        ),
      ).then((resultMap) async {
        if (resultMap is String && resultMap == 'cancel') {
          return;
        }

        targetPlaylist = resultMap['selectedPlaylist'];

        if (targetPlaylist == null) {
          return;
        }

        AudioDownloadVM audioDownloadVMlistenFalse =
            Provider.of<AudioDownloadVM>(
          context,
          listen: false,
        );

        bool wasExtractedAudioAddedToTargetPlaylist =
            await audioExtractorVM.extractMP3ToPlaylist(
          audioDownloadVMlistenFalse: audioDownloadVMlistenFalse,
          currentAudio: widget.currentAudio,
          targetPlaylist: targetPlaylist!,
          extractedMp3FileName: extractedMp3FileName,
          inMusicQuality: _extractInMusicQuality,
          totalDuration: audioExtractorVM.totalDuration,
        );

        if (!wasExtractedAudioAddedToTargetPlaylist) {
          audioExtractorVM.setError(
              // This error is cleared when user set 'In playlist' checkbox
              AppLocalizations.of(context)!
                  .extractedAudioNotAddedToPlaylistMessage(
                      targetPlaylist!.title));
        }
      });
    }

    if (_extractInDirectory) {
      await audioExtractorVM.extractMP3ToDirectory(
        settingsDataService: settingsDataService,
        inMusicQuality: _extractInMusicQuality,
        extractedMp3FileName: extractedMp3FileName,
      );
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
