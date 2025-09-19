import 'package:audiolearn/viewmodels/audio_download_vm.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/audio.dart';
import '../../models/audio_file.dart';
import '../../models/help_item.dart';
import '../../models/playlist.dart';
import '../../models/sort_filter_parameters.dart';
import '../../viewmodels/audio_player_vm.dart';
import '../../viewmodels/comment_vm.dart';
import '../../viewmodels/text_to_speech_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import '../../services/settings_data_service.dart';
import '../../viewmodels/theme_provider_vm.dart';
import 'confirm_action_dialog.dart';
import 'help_dialog.dart';

class ConvertTextToAudioDialog extends StatefulWidget {
  final Playlist targetPlaylist;
  final FocusNode focusNode;
  final WarningMessageVM warningMessageVMlistenFalse;
  final SettingsDataService settingsDataService;

  const ConvertTextToAudioDialog({
    super.key,
    required this.settingsDataService,
    required this.warningMessageVMlistenFalse,
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
  String _textToConvert = '';

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

    // This avoids that after reopening the text to audio dialog,
    // the previous text is still listenable. It is very important
    // that notify is false, otherwise an exception happens and
    // the dialog does not work correctly.
    textToSpeechVMlistenTrue.updateInputText(
      text: _textToConvert,
      notify: false,
    );

    return Center(
      child: AlertDialog(
        // title:
        //     Text(AppLocalizations.of(context)!.convertTextToAudioDialogTitle),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                AppLocalizations.of(context)!.convertTextToAudioDialogTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                key: const Key('convertTextToAudioDialogTitleKey'),
              ),
            ),
            IconButton(
              icon: IconTheme(
                data: (themeProviderVM.currentTheme == AppTheme.dark
                        ? ScreenMixin.themeDataDark
                        : ScreenMixin.themeDataLight)
                    .iconTheme,
                child: const Icon(
                  Icons.help_outline,
                  size: 40.0,
                ),
              ),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => HelpDialog(
                    helpItemsLst: [
                      HelpItem(
                        helpTitle: AppLocalizations.of(context)!
                            .convertTextToAudioHelpTitle(('{')),
                        helpContent: AppLocalizations.of(context)!
                            .convertTextToAudioHelpContent('{{', '{{{{', '{'),
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
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
                      key: const Key('voiceSelectionTitleKey'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.textToConvert('{'),
                  style: kDialogTitlesStyle,
                  maxLines: 2,
                  key: const Key('textToConvertTitleKey'),
                ),
              ),
            ],
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
                  keyboardType: TextInputType
                      .multiline, // Enable clicking on Enter to create a new line
                  onChanged: (text) {
                    _textToConvert = text;
                    textToSpeechVMlistenTrue.updateInputText(
                      text: text,
                      notify: true,
                    );

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
    final AudioDownloadVM audioDownloadVMlistenFalse =
        Provider.of<AudioDownloadVM>(
      context,
      listen: false,
    );

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
            _buildCreateMP3Button(
              context: context,
              themeProviderVM: themeProviderVM,
              textToSpeechVMlistenTrue: textToSpeechVMlistenTrue,
              audioDownloadVMlistenFalse: audioDownloadVMlistenFalse,
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
                  _stopAllAudio(
                    textToSpeechVMlistenTrue: textToSpeechVMlistenTrue,
                  );
                  final AudioDownloadVM audioDownloadVMlistenFalse =
                      Provider.of<AudioDownloadVM>(
                    context,
                    listen: false,
                  );
                  audioDownloadVMlistenFalse.doNotifyListeners();

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
    _isAnythingPlaying = textToSpeechVMlistenTrue.isSpeaking;

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
                isButtonEnabled:
                    textToSpeechVMlistenTrue.inputText.trim().isNotEmpty,
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
              ? null // This will disable the button and apply disabled styling
              : () {
                  if (_isAnythingPlaying) {
                    _stopAllAudio(
                        textToSpeechVMlistenTrue: textToSpeechVMlistenTrue);
                  } else {
                    textToSpeechVMlistenTrue.speakText(isVoiceMan: _isVoiceMan);
                  }
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
                  style: textToSpeechVMlistenTrue.inputText.trim().isEmpty
                      ? const TextStyle(
                          fontSize: kTextButtonFontSize) // Disabled style
                      : (themeProviderVM.currentTheme == AppTheme.dark)
                          ? kTextButtonStyleDarkMode
                          : kTextButtonStyleLightMode,
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

  Widget _buildCreateMP3Button({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
    required TextToSpeechVM textToSpeechVMlistenTrue,
    required AudioDownloadVM audioDownloadVMlistenFalse,
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
                isButtonEnabled:
                    textToSpeechVMlistenTrue.inputText.trim().isNotEmpty,
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
                    audioDownloadVMlistenFalse: audioDownloadVMlistenFalse,
                    targetPlaylist: widget.targetPlaylist,
                  ),
          child: Text(
            AppLocalizations.of(context)!.createAudioFileButton,
            style: textToSpeechVMlistenTrue.inputText.trim().isEmpty
                ? const TextStyle(
                    fontSize: kTextButtonFontSize) // Disabled style
                : (themeProviderVM.currentTheme == AppTheme.dark)
                    ? kTextButtonStyleDarkMode
                    : kTextButtonStyleLightMode,
          ),
        ),
      ),
    );
  }

  Future<void> _showFileNameDialog({
    required BuildContext context,
    required TextToSpeechVM textToSpeechVMlistenTrue,
    required AudioDownloadVM audioDownloadVMlistenFalse,
    required Playlist targetPlaylist,
  }) async {
    final TextEditingController fileNameController = TextEditingController();

    final fileName = await showDialog<String>(
      context: context,
      barrierDismissible: false, // Prevent close by tapping outside
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.mp3FileName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.enterMp3FileName),
            SizedBox(height: 16),
            TextField(
              key: const Key('mp3FileNameTextFieldKey'),
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
            key: const Key('create_mp3_button_key'),
            onPressed: () {
              final name = fileNameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(name);
              }
            },
            child: Text(AppLocalizations.of(context)!.createMP3),
          ),
          TextButton(
            key: const Key('cancel_mp3_creation_button_key'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
        ],
      ),
    );

    bool cancelTextToAudioCreation = false;

    if (fileName != null && fileName.trim().isNotEmpty) {
      final AudioPlayerVM audioPlayerVMlistenFalse = Provider.of<AudioPlayerVM>(
        context,
        listen: false,
      );

      Audio? existingAudio = targetPlaylist.getAudioByFileNameNoExt(
        audioFileNameNoExt: fileName.replaceFirst('.mp3', ''),
      );

      if (existingAudio != null) {
        await showDialog<dynamic>(
          context: context,
          barrierDismissible:
              false, // This line prevents the dialog from closing when
          //            tapping outside the dialog
          builder: (BuildContext context) {
            return ConfirmActionDialog(
              actionFunction: returnConfirmAction,
              actionFunctionArgs: [],
              dialogTitleOne:
                  AppLocalizations.of(context)!.replaceExistingAudioInPlaylist(
                fileName,
                targetPlaylist.title,
              ),
              dialogTitleOneReducedFontSize: true,
              dialogContent: "",
            );
          },
        ).then((result) {
          if (result == ConfirmAction.cancel) {
            cancelTextToAudioCreation = true;
          }
        });
      }

      if (cancelTextToAudioCreation) {
        return;
      }

      // Pass voice selection to MP3 conversion
      await textToSpeechVMlistenTrue.convertTextToMP3WithFileName(
        audioPlayerVMlistenFalse: audioPlayerVMlistenFalse,
        warningMessageVMlistenFalse: widget.warningMessageVMlistenFalse,
        fileName: fileName,
        mp3FileDirectory: targetPlaylist.downloadPath,
        isVoiceMan: _isVoiceMan,
      );

      AudioFile? currentAudioFile = textToSpeechVMlistenTrue.currentAudioFile;

      if (currentAudioFile != null) {
        if (!context.mounted) return;

        await audioDownloadVMlistenFalse.importConvertedAudioFileInPlaylist(
          commentVMlistenFalse: Provider.of<CommentVM>(
            context,
            listen: false,
          ),
          targetPlaylist: targetPlaylist,
          currentAudioFile: currentAudioFile,
          commentTitle: AppLocalizations.of(context)!.speech,
        );
      }
    }
  }

  ConfirmAction returnConfirmAction() {
    return ConfirmAction.confirm;
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
