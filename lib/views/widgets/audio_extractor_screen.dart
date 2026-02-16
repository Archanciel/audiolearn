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
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../models/audio.dart';
import '../../models/comment.dart';
import '../../models/multi_audio_comments.dart';
import '../../models/playlist.dart';
import '../../models/audio_with_segments.dart';
import '../../services/json_data_service.dart';
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

  // This list is used to extract multiple audios in one
  // MP3 file
  final List<Audio> multipleAudiosLst;

  const AudioExtractorScreen({
    super.key,
    required this.settingsDataService,
    required this.currentAudio,
    required this.commentVMlistenTrue,
    this.multipleAudiosLst = const [],
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
  bool _extractingMultipleAudios = false;
  String? _loadedCommentsFileName;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _segmentsScrollController = ScrollController();
    _loadedCommentsFileName = null; // ✅ ADD: Always reset on init

    final AudioExtractorVM audioExtractorVM = context.read<AudioExtractorVM>();
    audioExtractorVM.currentAudio = widget.currentAudio;
    audioExtractorVM.commentVMlistenTrue = widget.commentVMlistenTrue;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Clear any previous extraction result and errors
      audioExtractorVM.resetExtractionResult();

      // ✅ CRITICAL: Determine mode and clear opposite mode's state
      if (widget.multipleAudiosLst.isNotEmpty) {
        // Multi-audio mode: clear single-audio segments WITHOUT updating comments
        // (because _commentsLst hasn't been initialized for multi-audio mode)
        _extractingMultipleAudios = true;
        audioExtractorVM.clearSegmentsOnly(); // ← NOUVELLE MÉTHODE
        await _loadMultipleAudios(
          context: context,
          audioExtractorVM: audioExtractorVM,
        );
      } else {
        // Single-audio mode: clear multi-audio state
        audioExtractorVM.clearMultiAudios();
        await _pickMP3File(
          context: context,
          audioExtractorVM: audioExtractorVM,
        );

        await _loadSegmentsFromCommentFile(
          context: context,
          audioExtractorVM: audioExtractorVM,
        );
      }

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
    final AudioExtractorVM audioExtractorVM =
        Provider.of<AudioExtractorVM>(context);

    return Theme(
      data: themeProviderVMlistenFalse.currentTheme == AppTheme.dark
          ? ScreenMixin.themeDataDark
          : ScreenMixin.themeDataLight,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            key: const Key('audioExtractorBackButton'),
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
          title: Text(
            (audioExtractorVM.isMultiAudioMode)
                ? AppLocalizations.of(context)!
                    .audioExtractorMultiAudiosDialogTitle
                : AppLocalizations.of(context)!.audioExtractorDialogTitle,
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
          child: Consumer<ExtractMp3AudioPlayerVM>(
            builder: (context, audioPlayerVM, _) {
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
                          (audioExtractorVM.isMultiAudioMode)
                              ? "${AppLocalizations.of(context)!.audios} (${audioExtractorVM.multiAudios.length})"
                              : "${AppLocalizations.of(context)!.commentsDialogTitle} (${audioExtractorVM.segmentCount})",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    (audioExtractorVM.isMultiAudioMode)
                        ? _buildMultiAudioList(context, audioExtractorVM)
                        : (audioExtractorVM.segments.isEmpty)
                            ? const SizedBox.shrink()
                            : _buildSingleAudioList(context, audioExtractorVM),
                    if (audioExtractorVM.isMultiAudioMode
                        ? audioExtractorVM.multiAudios.isNotEmpty
                        : audioExtractorVM.segments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${AppLocalizations.of(context)!.totalDuration}: ${TimeFormatUtil.formatSeconds(audioExtractorVM.isMultiAudioMode ? audioExtractorVM.totalDurationMultiAudio : audioExtractorVM.totalDuration)}",
                            key: const Key('totalSegmentsDurationTextKey'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (!audioExtractorVM.isMultiAudioMode)
                            TextButton.icon(
                              key: const Key('clearAllSegmentsButton'),
                              onPressed: () => _confirmClearSegments(
                                  context, audioExtractorVM),
                              icon: const Icon(Icons.clear_all, size: 18),
                              label: Text(
                                  AppLocalizations.of(context)!.clearAllButton),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
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
                              // ✅ ADD: Save/Load buttons for multi-audio mode
                              if (_extractingMultipleAudios) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      key: const Key('loadCommentsButton'),
                                      onPressed: () =>
                                          _loadMultiAudioCommentsFile(
                                              context: context),
                                      icon: const Icon(Icons.folder_open,
                                          size: 18),
                                      label: Text(AppLocalizations.of(context)!
                                          .loadCommentsButton),
                                    ),
                                    ElevatedButton.icon(
                                      key: const Key('saveCommentsButton'),
                                      onPressed:
                                          audioExtractorVM.multiAudios.isEmpty
                                              ? null
                                              : () => _saveMultiAudioComments(
                                                    context: context,
                                                    audioExtractorVM:
                                                        audioExtractorVM,
                                                  ),
                                      icon: const Icon(Icons.save, size: 18),
                                      label: Text(AppLocalizations.of(context)!
                                          .saveCommentsButton),
                                    ),
                                  ],
                                ),
                              ],
                              (_extractingMultipleAudios)
                                  ? const SizedBox
                                      .shrink() // multiple audios are extracted in saved/MP3 dir.
                                  //           No playlist option is displayed.
                                  : Row(
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
                                          labelTooltip:
                                              AppLocalizations.of(context)!
                                                  .inDirectoryLabelTooltip,
                                          value: _extractInDirectory,
                                          onChangedFunction: (bool? value) {
                                            setState(() {
                                              _extractInDirectory =
                                                  value ?? false;
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
                                          labelTooltip:
                                              AppLocalizations.of(context)!
                                                  .inPlaylistLabelTooltip,
                                          value: _extractInPlaylist,
                                          onChangedFunction: (bool? value) {
                                            setState(() {
                                              _extractInPlaylist =
                                                  value ?? false;
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

  Future<void> _loadMultipleAudios({
    required BuildContext context,
    required AudioExtractorVM audioExtractorVM,
  }) async {
    try {
      final List<AudioWithSegments> audiosWithSegments = [];

      // ✅ IMPROVED: Better error handling for loading saved comments
      Map<String, List<Comment>>? savedCommentsMap;
      if (_loadedCommentsFileName != null) {
        try {
          final dynamic loaded = JsonDataService.loadFromFile(
            jsonPathFileName: _loadedCommentsFileName!,
            type: MultiAudioComments,
          );

          if (loaded is MultiAudioComments) {
            savedCommentsMap = loaded.audioCommentsMap;
          } else {
            throw Exception('Invalid file format');
          }
        } catch (e) {
          // ✅ ADD: Clear the problematic filename and show error
          _loadedCommentsFileName = null;

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppLocalizations.of(context)!.errorLoadingCommentsFile}: $e',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }

          // Continue with default behavior (load from individual files)
          savedCommentsMap = null;
        }
      }

      for (final Audio audio in widget.multipleAudiosLst) {
        List<Comment> commentsLst;

        // Check if we have saved comments for this audio
        if (savedCommentsMap != null &&
            savedCommentsMap.containsKey(audio.audioFileName)) {
          commentsLst = savedCommentsMap[audio.audioFileName]!;
        } else {
          // Load comments from audio's individual comment file
          commentsLst =
              widget.commentVMlistenTrue.loadAudioComments(audio: audio);
        }

        // Convert comments to segments
        final List<AudioSegment> segments = [];

        for (final Comment comment in commentsLst) {
          // ✅ ADD: Validate comment data
          if (comment.commentStartPositionInTenthOfSeconds < 0 ||
              comment.commentEndPositionInTenthOfSeconds < 0) {
            continue; // Skip invalid comments
          }

          final double start =
              comment.commentStartPositionInTenthOfSeconds / 10.0;
          final double end = comment.commentEndPositionInTenthOfSeconds / 10.0;

          if (start >= 0 && end > start) {
            double silence = comment.silenceDuration;
            if (silence == 0.0) {
              silence = kDefaultSilenceDuration;
            }

            segments.add(
              AudioSegment(
                startPosition: start,
                endPosition: end,
                silenceDuration: silence,
                playSpeed: (comment.wasPlaySpeedModifiedByAddSegmentDialog)
                    ? comment.playSpeed
                    : audio.audioPlaySpeed,
                fadeInDuration: comment.fadeInDuration,
                soundReductionPosition: comment.soundReductionPosition,
                soundReductionDuration: comment.soundReductionDuration,
                commentId: comment.id,
                commentTitle: comment.title,
                deleted: comment.deleted,
              ),
            );
          }
        }

        // If no segments were created, create a default full-audio segment
        if (segments.isEmpty) {
          final double roundedEndPosition = TimeFormatUtil.roundToTenthOfSecond(
              toBeRounded: audio.audioDuration.inMilliseconds / 1000.0);

          segments.add(
            AudioSegment(
              startPosition: 0.0,
              endPosition: roundedEndPosition,
              silenceDuration: 1.0,
              playSpeed: audio.audioPlaySpeed,
              fadeInDuration: 0.0,
              soundReductionPosition: 0.0,
              soundReductionDuration: 0.0,
              commentId:
                  'full_audio_${audio.audioFileName}_${DateTime.now().microsecondsSinceEpoch}',
              commentTitle: audio.validVideoTitle,
              deleted: false,
            ),
          );
        }

        audiosWithSegments.add(
          AudioWithSegments(
            audio: audio,
            segments: segments,
          ),
        );
      }

      audioExtractorVM.setMultiAudios(audiosWithSegments);

      if (!context.mounted) return;

      final int totalSegments = audiosWithSegments.fold(
        0,
        (sum, audioWithSeg) => sum + audioWithSeg.segments.length,
      );

      // ✅ IMPROVED: Different message if loaded from file
      final String message = savedCommentsMap != null
          ? '${AppLocalizations.of(context)!.loadedSavedComments} (${widget.multipleAudiosLst.length} ${AppLocalizations.of(context)!.audiosMin}, $totalSegments ${AppLocalizations.of(context)!.segments})'
          : AppLocalizations.of(context)!.loadedCommentsFromMultipleAudios(
              widget.multipleAudiosLst.length,
              totalSegments,
            );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e, stackTrace) {
      // ✅ ADD: Comprehensive error logging
      _logger.e('Error in _loadMultipleAudios: $e');
      _logger.e('Stack trace: $stackTrace');

      audioExtractorVM.setError('Error loading multiple audios: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading multiple audios: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Add these methods in the _AudioExtractorScreenState class:

  Future<void> _saveMultiAudioComments({
    required BuildContext context,
    required AudioExtractorVM audioExtractorVM,
  }) async {
    // Prompt for filename
    final TextEditingController fileNameController = TextEditingController(
      text: 'multi_audio_comments_${DateTime.now().millisecondsSinceEpoch}',
    );

    final String? fileName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.saveCommentsDialogTitle),
        content: TextField(
          key: const Key('saveCommentsFileNameTextField'),
          controller: fileNameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.fileNameLabel,
            hintText: 'multi_audio_comments',
          ),
          autofocus: true,
        ),
        actions: [
          ElevatedButton(
            key: const Key('saveCommentsButtonInSaveCommentsDialogKey'),
            onPressed: () {
              final name = fileNameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(dialogContext).pop(name);
              }
            },
            child: Text(AppLocalizations.of(context)!.saveButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
        ],
      ),
    );

    if (fileName == null || fileName.isEmpty) return;

    // Convert segments to comments and group by audio
    final Map<String, List<Comment>> audioCommentsMap = {};

    for (final audioWithSegments in audioExtractorVM.multiAudios) {
      final String audioFileName = audioWithSegments.audio.audioFileName;
      final List<Comment> comments = [];

      for (final segment in audioWithSegments.segments) {
        Comment comment = Comment(
          title: segment.commentTitle,
          content: '', // Empty content for generated comments
          commentStartPositionInTenthOfSeconds:
              (segment.startPosition * 10).toInt(),
          commentEndPositionInTenthOfSeconds:
              (segment.endPosition * 10).toInt(),
          silenceDuration: segment.silenceDuration,
          playSpeed: segment.playSpeed,
          fadeInDuration: segment.fadeInDuration,
          soundReductionPosition: segment.soundReductionPosition,
          soundReductionDuration: segment.soundReductionDuration,
          deleted: segment.deleted,
          wasPlaySpeedModifiedByAddSegmentDialog: segment.playSpeed != 1.0,
        );
        comment.setId(segment.commentId); // Preserve original comment ID
        comments.add(
          comment,
        );
      }

      audioCommentsMap[audioFileName] = comments;
    }

    final multiAudioComments = MultiAudioComments(
      audioCommentsMap: audioCommentsMap,
    );

    final String multiCommentsDir =
        '${widget.currentAudio.enclosingPlaylist!.downloadPath}${Platform.pathSeparator}$kCommentDirName';

    // Create directory if it doesn't exist
    final Directory multiCommentsDirObj = Directory(multiCommentsDir);
    if (!multiCommentsDirObj.existsSync()) {
      multiCommentsDirObj.createSync(recursive: true);
    }

    // Use .multi.json extension to avoid confusion with regular comment files
    final String filePath =
        '$multiCommentsDir${Platform.pathSeparator}$fileName.multi.json';

    JsonDataService.saveToFile(
      model: multiAudioComments,
      path: filePath,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppLocalizations.of(context)!.commentsSavedMessage} $filePath',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loadMultiAudioCommentsFile({
    required BuildContext context,
  }) async {
    final String multiCommentsDir =
        '${widget.currentAudio.enclosingPlaylist!.downloadPath}${Platform.pathSeparator}$kCommentDirName';

    final Directory multiCommentsDirObj = Directory(multiCommentsDir);
    if (!multiCommentsDirObj.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noSavedCommentsMessage),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final List<FileSystemEntity> files = multiCommentsDirObj
        .listSync()
        .where((file) => file.path.endsWith('.multi.json'))
        .toList();

    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noSavedCommentsMessage),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show dialog to select file
    final String? selectedFile = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          // Get fresh file list (in case files were deleted)
          final List<FileSystemEntity> currentFiles = multiCommentsDirObj
              .listSync()
              .where((file) => file.path.endsWith('.multi.json'))
              .toList();

          if (currentFiles.isEmpty) {
            // Close dialog if no files left
            Future.microtask(() => Navigator.of(dialogContext).pop());
          }

          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.loadCommentsDialogTitle),
            content: SizedBox(
              width: double.maxFinite,
              child: currentFiles.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)!.noSavedCommentsMessage,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: currentFiles.length,
                      itemBuilder: (context, index) {
                        final file = currentFiles[index];
                        final fileName = PathUtil.fileName(file.path);

                        return ListTile(
                          title: Text(fileName),
                          onTap: () =>
                              Navigator.of(dialogContext).pop(file.path),
                          trailing: IconButton(
                            key: Key('deleteMultiCommentFileButton_$index'),
                            icon: const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              // Show confirmation dialog
                              showDialog(
                                context: dialogContext,
                                builder: (confirmContext) => AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(context)!
                                        .deleteCommentDialogTitle,
                                  ),
                                  content: Text(
                                    'Delete $fileName?',
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        // Delete the file
                                        try {
                                          File(file.path).deleteSync();

                                          // Close confirmation dialog
                                          Navigator.of(confirmContext).pop();

                                          // Show success message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Deleted $fileName',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              backgroundColor: Colors.green,
                                              duration:
                                                  const Duration(seconds: 2),
                                            ),
                                          );

                                          // Refresh the file list
                                          setState(() {});
                                        } catch (e) {
                                          // Show error message
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error deleting file: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                              duration:
                                                  const Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.delete,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(confirmContext).pop(),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .cancelButton,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(AppLocalizations.of(context)!.cancelButton),
              ),
            ],
          );
        },
      ),
    );

    if (selectedFile == null) return;

    setState(() {
      _loadedCommentsFileName = selectedFile;
    });

    // Reload the multi-audio data
    final AudioExtractorVM audioExtractorVM = context.read<AudioExtractorVM>();
    await _loadMultipleAudios(
      context: context,
      audioExtractorVM: audioExtractorVM,
    );
  }

  Widget _buildSingleAudioList(
    BuildContext context,
    AudioExtractorVM audioExtractorVM,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
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
            final AudioSegment segment = audioExtractorVM.segments[index];
            final String displayedIndex = (index + 1).toString();

            return _buildSegmentCard(
              context: context,
              segment: segment,
              displayedIndex: displayedIndex,
              onEdit: () async {
                final AudioSegment? updatedSegment =
                    await showDialog<AudioSegment>(
                  context: context,
                  builder: (_) => AddSegmentDialog(
                    maxDuration: audioExtractorVM.audioFile.duration,
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
              onDelete: () => _confirmDeleteSegment(
                context: context,
                audioExtractorVM: audioExtractorVM,
                segmentToDeleteIndex: index,
              ),
              onDuplicate: () => _duplicateSingleAudioSegment(
                // ✅ ADD
                context: context,
                audioExtractorVM: audioExtractorVM,
                segment: segment,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMultiAudioList(
    BuildContext context,
    AudioExtractorVM audioExtractorVM,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Scrollbar(
        controller: _segmentsScrollController,
        thumbVisibility: true,
        child: ListView.builder(
          controller: _segmentsScrollController,
          primary: false,
          shrinkWrap: true,
          itemCount: audioExtractorVM.multiAudios.length,
          itemBuilder: (context, audioIndex) {
            final AudioWithSegments audioWithSegments =
                audioExtractorVM.multiAudios[audioIndex];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audio header
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade800,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          '${audioIndex + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              audioWithSegments.audio.validVideoTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${audioWithSegments.activeSegmentCount} segment(s) - ${TimeFormatUtil.formatSeconds(audioWithSegments.totalDuration)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Segments for this audio
                ...List.generate(
                  audioWithSegments.segments.length,
                  (segmentIndex) {
                    final segment = audioWithSegments.segments[segmentIndex];
                    final displayedIndex =
                        '${audioIndex + 1}.${segmentIndex + 1}';

                    return _buildSegmentCard(
                      context: context,
                      segment: segment,
                      displayedIndex: displayedIndex,
                      onEdit: () async {
                        final AudioSegment? updatedSegment =
                            await showDialog<AudioSegment>(
                          context: context,
                          builder: (_) => AddSegmentDialog(
                            maxDuration: audioWithSegments
                                    .audio.audioDuration.inMilliseconds /
                                1000.0,
                            existingSegment: segment,
                          ),
                        );

                        if (updatedSegment != null) {
                          audioExtractorVM.updateMultiAudioSegment(
                            audioIndex: audioIndex,
                            segmentIndex: segmentIndex,
                            segment: updatedSegment,
                            commentVMlistenTrue: widget.commentVMlistenTrue,
                          );
                        }
                      },
                      onDelete: () => _confirmDeleteMultiAudioSegment(
                        context: context,
                        audioExtractorVM: audioExtractorVM,
                        audioIndex: audioIndex,
                        segmentIndex: segmentIndex,
                      ),
                      onDuplicate: () => _duplicateMultiAudioSegment(
                        // ✅ ADD
                        context: context,
                        audioExtractorVM: audioExtractorVM,
                        audioIndex: audioIndex,
                        segment: segment,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, thickness: 2),
              ],
            );
          },
        ),
      ),
    );
  }

// 6. Add this helper method to build individual segment cards:

  Widget _buildSegmentCard({
    required BuildContext context,
    required AudioSegment segment,
    required String displayedIndex,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onDuplicate,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // ✅ Custom padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // ✅ Align to top
          children: [
            // Leading icons column (no size constraint!)
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18, // ✅ Full size!
                  child: Text(
                    displayedIndex,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 18),
                CircleAvatar(
                  radius: 18, // ✅ Full size!
                  backgroundColor: const Color.fromARGB(255, 27, 131, 31),
                  child: IconButton(
                    key: Key('duplicateSegmentButtonKey_$displayedIndex'),
                    icon: const Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDuplicate,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12), // Spacing between leading and content

            // Main content (title, positions, etc.)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    segment.commentTitle,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  if (segment.deleted)
                    Tooltip(
                      message: AppLocalizations.of(context)!
                          .commentWasDeletedTooltip,
                      child: Text(
                        key: Key('commentDeletedTextKey_$displayedIndex'),
                        AppLocalizations.of(context)!.commentWasDeleted,
                        maxLines: 2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Tooltip(
                        message: AppLocalizations.of(context)!
                            .commentStartPositionTooltip,
                        child: Text(
                          TimeFormatUtil.formatSeconds(segment.startPosition),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward,
                          size: 15, color: Colors.white70),
                    ],
                  ),
                  Tooltip(
                    message:
                        AppLocalizations.of(context)!.commentEndPositionTooltip,
                    child: Text(
                      TimeFormatUtil.formatSeconds(segment.endPosition),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Tooltip(
                    message: AppLocalizations.of(context)!
                        .extractAudioPlaySpeedTooltip,
                    child: Text(
                      "${AppLocalizations.of(context)!.extractAudioPlaySpeed}: ${segment.playSpeed}",
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
                        AppLocalizations.of(context)!.fadeStartPositionTooltip,
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
                    message: AppLocalizations.of(context)!
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
                    message: AppLocalizations.of(context)!
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
                  const SizedBox(height: 8),
                  // Subtitle (duration)
                  Text(
                    "${AppLocalizations.of(context)!.duration}: ${TimeFormatUtil.formatSeconds(segment.duration)}"
                    "${segment.silenceDuration > 0 ? ' + ${AppLocalizations.of(context)!.silence} ${TimeFormatUtil.formatSeconds(segment.silenceDuration)}' : ''}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            // Trailing action buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  key: Key('editSegmentButtonKey_$displayedIndex'),
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: const Icon(Icons.edit, size: 20),
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  key: Key('deleteSegmentButtonKey_$displayedIndex'),
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// 7. Add method to delete multi-audio segments:

  void _confirmDeleteMultiAudioSegment({
    required BuildContext context,
    required AudioExtractorVM audioExtractorVM,
    required int audioIndex,
    required int segmentIndex,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => Actions(
        // Using Actions to enable clicking on Enter to apply the
        // action of clicking on the 'Delete' button
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              // executing the same code as in the 'Delete'
              // TextButton onPressed callback
              audioExtractorVM.removeMultiAudioSegment(
                audioIndex: audioIndex,
                segmentIndex: segmentIndex,
              );
              Navigator.of(dialogContext).pop();
            },
          ),
        },
        child: Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          },
          child: Focus(
            autofocus: true,
            child: AlertDialog(
              title:
                  Text(AppLocalizations.of(context)!.deleteCommentDialogTitle),
              content:
                  Text(AppLocalizations.of(context)!.deleteCommentExplanation),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    audioExtractorVM.removeMultiAudioSegment(
                      audioIndex: audioIndex,
                      segmentIndex: segmentIndex,
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.delete),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(AppLocalizations.of(context)!.cancelButton),
                ),
              ],
            ),
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
                (Platform.isWindows)
                    ? Text(
                        key: const Key('extractedAudioDurationTextKey'),
                        TimeFormatUtil.formatSeconds(
                          audioExtractorVM.isMultiAudioMode
                              ? audioExtractorVM.totalDurationMultiAudio
                              : audioExtractorVM.totalDuration,
                        ),
                      )
                    : Text(
                        key: const Key('extractedAudioDurationTextKey'),
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
      builder: (dialogContext) => Actions(
        // Using Actions to enable clicking on Enter to apply the
        // action of clicking on the 'Delete' button
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              // executing the same code as in the 'Delete'
              // TextButton onPressed callback
              _applyDelete(
                dialogContext: dialogContext,
                audioExtractorVM: audioExtractorVM,
                segmentToDeleteIndex: segmentToDeleteIndex,
              );
              return null;
            },
          ),
        },
        child: Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          },
          child: Focus(
            autofocus: true,
            child: AlertDialog(
              title:
                  Text(AppLocalizations.of(context)!.deleteCommentDialogTitle),
              content: Text(
                AppLocalizations.of(context)!.deleteCommentExplanation,
              ),
              actions: [
                ElevatedButton(
                  key: const Key('confirmDeleteSegmentButton'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    _applyDelete(
                      dialogContext: dialogContext,
                      audioExtractorVM: audioExtractorVM,
                      segmentToDeleteIndex: segmentToDeleteIndex,
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.delete),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(AppLocalizations.of(context)!.cancelButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _applyDelete({
    required BuildContext dialogContext,
    required AudioExtractorVM audioExtractorVM,
    required int segmentToDeleteIndex,
  }) {
    audioExtractorVM.removeSegment(
      segmentToRemoveIndex: segmentToDeleteIndex,
    );
    Navigator.of(dialogContext).pop();
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
        // Create a default segment spanning the entire audio duration

        // Round to tenth of second to match validation logic
        final double roundedEndPosition = TimeFormatUtil.roundToTenthOfSecond(
            toBeRounded: currentAudio.audioDuration.inMilliseconds / 1000.0);

        AudioSegment(
          startPosition: 0.0,
          endPosition: roundedEndPosition,
          silenceDuration: 1.0,
          playSpeed: currentAudio.audioPlaySpeed,
          fadeInDuration: 0.0,
          soundReductionPosition: 0.0,
          soundReductionDuration: 0.0,
          commentId: 'full_audio_${DateTime.now().microsecondsSinceEpoch}',
          commentTitle: currentAudio.validVideoTitle,
          deleted: false,
        );

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)!.noCommentFoundInAudioMessage} Full audio segment created.",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
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
              playSpeed: (comment.wasPlaySpeedModifiedByAddSegmentDialog)
                  ? comment.playSpeed
                  : currentAudio.audioPlaySpeed,
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
              fontWeight: FontWeight.w700,
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
    // Handle multi-audio mode
    if (audioExtractorVM.isMultiAudioMode) {
      if (audioExtractorVM.multiAudios.isEmpty) {
        audioExtractorVM.setError('No audios loaded');
        return;
      }

      // Release player if needed
      if (audioPlayerVM.isLoaded) {
        await audioPlayerVM.releaseCurrentFile();
        if (Platform.isWindows) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // Generate filename for multi-audio extraction
      final int totalSegments = audioExtractorVM.totalSegmentCountMultiAudio;
      String extractedMp3FileName =
          'multi_${audioExtractorVM.multiAudios.length}_audios_${totalSegments}_segments.mp3';

      if (_extractInMusicQuality) {
        extractedMp3FileName =
            "${AppLocalizations.of(context)!.inMusicQuality}_$extractedMp3FileName";
      }

      extractedMp3FileName = PathUtil.sanitizeFileName(extractedMp3FileName);

      await audioExtractorVM.extractMultiAudioToDirectory(
        context: context,
        settingsDataService: settingsDataService,
        inMusicQuality: _extractInMusicQuality,
        extractedMp3FileName: extractedMp3FileName,
      );

      return;
    }

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

    // NEW - Release on ALL platforms
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
          context: context,
          audioDownloadVMlistenFalse: audioDownloadVMlistenFalse,
          currentAudio: widget.currentAudio,
          targetPlaylist: targetPlaylist!,
          extractedMp3FileName: extractedMp3FileName,
          inMusicQuality: _extractInMusicQuality,
          totalDuration: audioExtractorVM
              .totalDuration, // duration corrected by play speed
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

// Add these methods before the closing brace of _AudioExtractorScreenState

  /// Duplicates a segment in single-audio mode
  void _duplicateSingleAudioSegment({
    required BuildContext context,
    required AudioExtractorVM audioExtractorVM,
    required AudioSegment segment,
  }) {
    // Create duplicate with modified title and new ID
    final AudioSegment duplicatedSegment = AudioSegment(
      startPosition: segment.startPosition,
      endPosition: segment.endPosition,
      silenceDuration: segment.silenceDuration,
      playSpeed: segment.playSpeed,
      fadeInDuration: segment.fadeInDuration,
      soundReductionPosition: segment.soundReductionPosition,
      soundReductionDuration: segment.soundReductionDuration,
      commentId:
          'duplicated_${segment.commentId}_${DateTime.now().microsecondsSinceEpoch}',
      commentTitle:
          '${AppLocalizations.of(context)!.toExtractCommentTitleAddition}-${segment.commentTitle}',
      deleted: false,
    );

    // Add to segments list
    audioExtractorVM.addSegment(duplicatedSegment);

    // Create corresponding comment and add to comments list
    final Comment duplicatedComment = Comment(
      title: duplicatedSegment.commentTitle,
      content: '',
      commentStartPositionInTenthOfSeconds:
          (duplicatedSegment.startPosition * 10).toInt(),
      commentEndPositionInTenthOfSeconds:
          (duplicatedSegment.endPosition * 10).toInt(),
      silenceDuration: duplicatedSegment.silenceDuration,
      playSpeed: duplicatedSegment.playSpeed,
      fadeInDuration: duplicatedSegment.fadeInDuration,
      soundReductionPosition: duplicatedSegment.soundReductionPosition,
      soundReductionDuration: duplicatedSegment.soundReductionDuration,
      deleted: false,
      wasPlaySpeedModifiedByAddSegmentDialog:
          duplicatedSegment.playSpeed != 1.0,
    );
    duplicatedComment.setId(duplicatedSegment.commentId);

    // Add comment to audio
    widget.commentVMlistenTrue.addComment(
      addedComment: duplicatedComment,
      audioToComment: widget.currentAudio,
    );

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.segmentDuplicatedMessage,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Duplicates a segment in multi-audio mode
  void _duplicateMultiAudioSegment({
    required BuildContext context,
    required AudioExtractorVM audioExtractorVM,
    required int audioIndex,
    required AudioSegment segment,
  }) {
    // Create duplicate with modified title and new ID
    final AudioSegment duplicatedSegment = AudioSegment(
      startPosition: segment.startPosition,
      endPosition: segment.endPosition,
      silenceDuration: segment.silenceDuration,
      playSpeed: segment.playSpeed,
      fadeInDuration: segment.fadeInDuration,
      soundReductionPosition: segment.soundReductionPosition,
      soundReductionDuration: segment.soundReductionDuration,
      commentId:
          'duplicated_${segment.commentId}_${DateTime.now().microsecondsSinceEpoch}',
      commentTitle: 'To extract ${segment.commentTitle}',
      deleted: false,
    );

    // Get current audio with segments
    final AudioWithSegments audioWithSegments =
        audioExtractorVM.multiAudios[audioIndex];

    // Create new segments list with duplicate added
    final List<AudioSegment> updatedSegments =
        List<AudioSegment>.from(audioWithSegments.segments)
          ..add(duplicatedSegment);

    // Update the multi-audio
    audioExtractorVM.updateMultiAudioSegments(audioIndex, updatedSegments);

    // Create corresponding comment and add to the audio's comment file
    final Comment duplicatedComment = Comment(
      title: duplicatedSegment.commentTitle,
      content: '',
      commentStartPositionInTenthOfSeconds:
          (duplicatedSegment.startPosition * 10).toInt(),
      commentEndPositionInTenthOfSeconds:
          (duplicatedSegment.endPosition * 10).toInt(),
      silenceDuration: duplicatedSegment.silenceDuration,
      playSpeed: duplicatedSegment.playSpeed,
      fadeInDuration: duplicatedSegment.fadeInDuration,
      soundReductionPosition: duplicatedSegment.soundReductionPosition,
      soundReductionDuration: duplicatedSegment.soundReductionDuration,
      deleted: false,
      wasPlaySpeedModifiedByAddSegmentDialog:
          duplicatedSegment.playSpeed != 1.0,
    );
    duplicatedComment.setId(duplicatedSegment.commentId);

    // Add comment to the specific audio
    widget.commentVMlistenTrue.addComment(
      addedComment: duplicatedComment,
      audioToComment: audioWithSegments.audio,
    );

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.segmentDuplicatedMessage ??
              'Segment duplicated',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
