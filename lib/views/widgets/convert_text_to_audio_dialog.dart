import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/audio_file.dart';
import '../../models/playlist.dart';
import '../../services/sort_filter_parameters.dart';
import '../../viewmodels/text_to_speech_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import 'confirm_action_dialog.dart';

enum CalledFrom {
  playlistDownloadView,
  playlistDownloadViewAudioMenu,
  audioPlayerView,
  audioPlayerViewAudioMenu,
}

enum DateTimeType {
  startDownloadDateTime,
  endDownloadDateTime,
  startUploadDateTime,
  endUploadDateTime,
}

class ConvertTextToAudioDialog extends StatefulWidget {
  final Playlist targetPlaylist;
  final FocusNode focusNode;
  final WarningMessageVM warningMessageVM;
  final SettingsDataService settingsDataService;

  const ConvertTextToAudioDialog({
    super.key,
    required this.settingsDataService,
    required this.warningMessageVM,
    required this.targetPlaylist,
    required this.focusNode,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ConvertTextToAudioDialogState createState() =>
      _ConvertTextToAudioDialogState();
}

class _ConvertTextToAudioDialogState extends State<ConvertTextToAudioDialog>
    with ScreenMixin {
  final TextEditingController _textToConvertController =
      TextEditingController();
  late String _textToConvert;

  final _textToConvertFocusNode = FocusNode();

  Color _textToConvertIconColor = kDarkAndLightDisabledIconColor;

  // Voice selection state
  bool _isVoiceMan = true; // Default to masculine voice

  bool _isAnythingPlaying = false;

  @override
  void initState() {
    super.initState();

    // Add this line to request focus on the TextField after the build
    // method has been called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(
        _textToConvertFocusNode,
      );
    });

    /// In this method, the context is available.
    Future.delayed(Duration.zero, () {
      _textToConvertController.text = '';
      _textToConvert = '';
      _textToConvertIconColor = kDarkAndLightDisabledIconColor;
    });
  }

  @override
  void dispose() {
    _textToConvertController.dispose();
    _textToConvertFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );
    final DateFormatVM dateFormatVMlistenFalse = Provider.of<DateFormatVM>(
      context,
      listen: false,
    );
    TextToSpeechVM textToSpeechVMlistenTrue = Provider.of<TextToSpeechVM>(
      context,
      listen: true,
    );

    return Center(
      child: AlertDialog(
        title:
            Text(AppLocalizations.of(context)!.convertTextToAudioDialogTitle),
        actionsPadding:
            // reduces the top vertical space between the buttons
            // and the content
            kDialogActionsPadding,
        content: SizedBox(
          width: double.maxFinite,
          height: 800,
          child: DraggableScrollableSheet(
            initialChildSize: 1,
            minChildSize: 1,
            maxChildSize: 1,
            builder: (
              BuildContext context,
              ScrollController scrollController,
            ) {
              return SingleChildScrollView(
                child: ListBody(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextToConvertFieldAndDeleteButton(
                      context: context,
                      textToSpeechVMlistenTrue: textToSpeechVMlistenTrue,
                    ),
                    const SizedBox(
                      height: kDialogTextFieldVerticalSeparation,
                    ),
                    Text(
                      AppLocalizations.of(context)!.conversionVoiceSelection,
                      style: kDialogTitlesStyle,
                    ),
                    _buildVoiceSelectionCheckboxes(
                      context: context,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          _buildActionButtonsLine(
              context: context,
              themeProviderVM: themeProviderVM,
              dateFormatVMlistenFalse: dateFormatVMlistenFalse,
              textToSpeechVMlistenTrue: textToSpeechVMlistenTrue),
        ],
      ),
    );
  }

  Widget _buildTextToConvertFieldAndDeleteButton({
    required BuildContext context,
    required TextToSpeechVM textToSpeechVMlistenTrue,
  }) {
    return Tooltip(
      message: AppLocalizations.of(context)!.textToConvertTextFieldTooltip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.textToConvert,
            style: kDialogTitlesStyle,
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Flexible(
                child: TextField(
                  key: const Key('textToConvertTextField'),
                  focusNode: _textToConvertFocusNode,
                  style: kDialogTextFieldStyle,
                  maxLines: 18,
                  decoration: getDialogTextFieldInputDecoration(
                    hintText: AppLocalizations.of(context)!
                        .textToConvertTextFieldHint,
                  ),
                  controller: _textToConvertController,
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    _textToConvert = text;
                    textToSpeechVMlistenTrue.updateInputText(text: text);

                    // setting the Delete button color according to the
                    // TextField content ...
                    _textToConvertIconColor = _textToConvert.isNotEmpty
                        ? kDarkAndLightEnabledIconColor
                        : kDarkAndLightDisabledIconColor;

                    setState(() {}); // necessary to update Delete button color
                  },
                ),
              ),
              SizedBox(
                width: kSmallIconButtonWidth,
                child: IconButton(
                  key: const Key('deleteTextToConvertIconButton'),
                  onPressed: () async {
                    _clearTextToConvertField();
                    _textToConvertFocusNode.requestFocus();
                    setState(() {}); // necessary to update Delete button color
                  },
                  padding: const EdgeInsets.all(0),
                  style: ButtonStyle(
                    // Highlight button when pressed
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          horizontal: kSmallButtonInsidePadding, vertical: 0),
                    ),
                    overlayColor:
                        iconButtonTapModification, // Tap feedback color
                  ),
                  icon: Icon(
                    Icons.clear,
                    // since in the Dialog the disabled IconButton color
                    // is not grey, we need to set it manually. Additionally,
                    // the sentence TextField onChanged callback must execute
                    // setState() to update the IconButton color
                    color: _textToConvertIconColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _clearTextToConvertField() {
    _textToConvertController.clear();
    _textToConvert = '';
    _textToConvertIconColor = kDarkAndLightDisabledIconColor;
  }

  /// Create Reset (X), Save or Apply, Delete and Cancel buttons.
  ///
  /// Save button is displayed when the sort filter name is defined.
  /// If the sort filter name is empty, the Apply button is displayed.
  Column _buildActionButtonsLine({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
    required DateFormatVM dateFormatVMlistenFalse,
    required TextToSpeechVM textToSpeechVMlistenTrue,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildListenTextButton(
              context: context,
              themeProviderVM: themeProviderVM,
              textToSpeechVMlistenTrue: textToSpeechVMlistenTrue,
            ),
            _buildCreateAudioFileButton(
              context: context,
              themeProviderVM: themeProviderVM,
              textToSpeechVMlistenTrue: textToSpeechVMlistenTrue,
              selectedPlaylistDownloadPath: widget.targetPlaylist.downloadPath,
            ),
            SizedBox(
              height: kNormalButtonHeight,
              child: TextButton(
                key: const Key('convertTextToAudioCancelButton'),
                style: ButtonStyle(
                  shape: getButtonRoundedShape(
                      currentTheme: themeProviderVM.currentTheme,
                      isButtonEnabled: true,
                      context: context),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                      horizontal: kSmallButtonInsidePadding,
                      vertical: 0,
                    ),
                  ),
                  overlayColor: textButtonTapModification, // Tap feedback color
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.cancelButton,
                  style: (themeProviderVM.currentTheme == AppTheme.dark)
                      ? kTextButtonStyleDarkMode
                      : kTextButtonStyleLightMode,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildListenTextButton({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
    required TextToSpeechVM textToSpeechVMlistenTrue,
  }) {
    // Check if either TTS is speaking OR audio file is playing
    _isAnythingPlaying = textToSpeechVMlistenTrue.isPlaying ||
        textToSpeechVMlistenTrue.isSpeaking;

    return SizedBox(
      // Dynamic width: increase when showing "Stop playing" text
      width: _isAnythingPlaying
          ? kGreaterButtonWidth + 20 // Increased width for "Stop playing"
          : kGreaterButtonWidth + 20, // Original width for "Listen"
      height: kNormalButtonHeight,
      child: Tooltip(
        message: _isAnythingPlaying
            ? AppLocalizations.of(context)!.stopListeningTextButtonTooltip
            : AppLocalizations.of(context)!.listenTextButtonTooltip,
        child: TextButton(
          key: const Key('listen_text_button'),
          style: ButtonStyle(
            shape: getButtonRoundedShape(
                currentTheme: themeProviderVM.currentTheme,
                isButtonEnabled: true,
                context: context),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(
                horizontal: kSmallButtonInsidePadding,
                vertical: 0,
              ),
            ),
            overlayColor: textButtonTapModification, // Tap feedback color
          ),
          onPressed: () {
            (textToSpeechVMlistenTrue.inputText.trim().isEmpty)
                ? null
                : (_isAnythingPlaying)
                    ? _stopAllAudio(
                        textToSpeechVMlistenTrue: textToSpeechVMlistenTrue,
                      )
                    : textToSpeechVMlistenTrue.speakText(
                        isVoiceMan: _isVoiceMan,
                      );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                _isAnythingPlaying ? Icons.stop : Icons.volume_up,
                size: 18,
              ),
              const SizedBox(
                  width: 4), // Add small spacing between icon and text
              Flexible(
                // Add Flexible to prevent text overflow
                child: Text(
                  _isAnythingPlaying
                      ? AppLocalizations.of(context)!.stopListeningTextButton
                      : AppLocalizations.of(context)!.listenTextButton,
                  style: (themeProviderVM.currentTheme == AppTheme.dark)
                      ? kTextButtonStyleDarkMode
                      : kTextButtonStyleLightMode,
                  overflow:
                      TextOverflow.ellipsis, // Handle any remaining overflow
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to stop all audio (both TTS and audio file playback)
  void _stopAllAudio({
    required TextToSpeechVM textToSpeechVMlistenTrue,
  }) {
    // Stop TTS speaking
    textToSpeechVMlistenTrue.stopSpeaking();
  }

  Widget _buildCreateAudioFileButton({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
    required TextToSpeechVM textToSpeechVMlistenTrue,
    required String selectedPlaylistDownloadPath,
  }) {
    return SizedBox(
      // sets the rounded TextButton size improving the distance
      // between the button text and its boarder
      width: kGreaterButtonWidth * 1.4,
      height: kNormalButtonHeight,
      child: Tooltip(
        message: AppLocalizations.of(context)!.createAudioFileButtonTooltip,
        child: TextButton(
          key: const Key('create_audio_file_button'),
          style: ButtonStyle(
            shape: getButtonRoundedShape(
                currentTheme: themeProviderVM.currentTheme,
                isButtonEnabled: true,
                context: context),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(
                horizontal: kSmallButtonInsidePadding,
                vertical: 0,
              ),
            ),
            overlayColor: textButtonTapModification, // Tap feedback color
          ),
          onPressed: textToSpeechVMlistenTrue.inputText.trim().isEmpty
              ? null
              : () => _showFileNameDialog(
                    context: context,
                    textToSpeechVMlistenTrue: textToSpeechVMlistenTrue,
                    targetPlaylist: widget.targetPlaylist,
                  ),
          child: Row(
            mainAxisSize: MainAxisSize
                .min, // Pour s'assurer que le Row n'occupe pas plus d'espace que nécessaire
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.createAudioFileButton,
                style: (themeProviderVM.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode,
              ), // Texte
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFileNameDialog({
    required BuildContext context,
    required TextToSpeechVM textToSpeechVMlistenTrue,
    required Playlist targetPlaylist,
  }) async {
    final TextEditingController fileNameController = TextEditingController();

    final fileName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.mp3FileName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.enterMp3FileName),
            SizedBox(height: 16),
            TextField(
              controller: fileNameController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.myMp3FileName,
                border: OutlineInputBorder(),
                suffixText: '.mp3',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final name = fileNameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(name);
              }
            },
            child: Text(AppLocalizations.of(context)!.createMP3),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
        ],
      ),
    );

    if (fileName != null && fileName.trim().isNotEmpty) {
      try {
        // Pass voice selection to MP3 conversion
        await textToSpeechVMlistenTrue.convertTextToMP3WithFileName(
          fileName: fileName,
          mp3FileDirectory: targetPlaylist.downloadPath,
          isVoiceMan: _isVoiceMan,
        );

        AudioFile? currentAudioFile = textToSpeechVMlistenTrue.currentAudioFile;

        if (currentAudioFile != null) {
          if (!context.mounted) return;

          Provider.of<AudioDownloadVM>(
            context,
            listen: false,
          ).importAudioFilesInPlaylist(
            targetPlaylist: targetPlaylist,
            filePathNameToImportLst: [currentAudioFile.filePath],
            doesImportedFileResultFromTextToSpeech: true,
          );
        } else {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Création annulée'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Row _buildVoiceSelectionCheckboxes({
    required BuildContext context,
  }) {
    return Row(
      children: [
        Text(AppLocalizations.of(context)!.masculineVoice),
        Checkbox(
          key: const Key('masculineVoiceCheckbox'),
          value: _isVoiceMan,
          onChanged: (bool? newValue) {
            if (newValue == true) {
              setState(() {
                _isVoiceMan = true;
              });
            }

            // now clicking on Enter works since the
            // Checkbox is not focused anymore
            _textToConvertFocusNode.requestFocus();
          },
        ),
        Text(AppLocalizations.of(context)!.femineVoice),
        Checkbox(
          key: const Key('femineVoiceCheckbox'),
          value: !_isVoiceMan,
          onChanged: (bool? newValue) {
            if (newValue == true) {
              setState(() {
                _isVoiceMan = false;
              });
            }
            // now clicking on Enter works since the
            // Checkbox is not focused anymore
            _textToConvertFocusNode.requestFocus();
          },
        ),
      ],
    );
  }

  ConfirmAction returnConfirmAction() {
    return ConfirmAction.confirm;
  }
}

class FilterAndSortAudioParameters {
  final List<SortingOption> _sortingOptionLst;
  List<SortingOption> get sortingOptionLst => _sortingOptionLst;

  final String _videoTitleAndDescriptionSearchWords;
  String get videoTitleAndDescriptionSearchWords =>
      _videoTitleAndDescriptionSearchWords;

  bool ignoreCase;
  bool searchInVideoCompactDescription;
  bool asc;

  FilterAndSortAudioParameters({
    required List<SortingOption> sortingOptionLst,
    required String videoTitleAndDescriptionSearchWords,
    required this.ignoreCase,
    required this.searchInVideoCompactDescription,
    required this.asc,
  })  : _videoTitleAndDescriptionSearchWords =
            videoTitleAndDescriptionSearchWords,
        _sortingOptionLst = sortingOptionLst;
}
