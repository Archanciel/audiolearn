import 'package:audiolearn/utils/duration_expansion.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/playlist.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../services/sort_filter_parameters.dart';
import '../../viewmodels/text_to_speech_vm.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import '../../models/audio.dart';
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
  final Playlist selectedPlaylist;
  final List<Audio> selectedPlaylistAudioLst;
  final String audioSortFilterParametersName;
  final AudioSortFilterParameters audioSortFilterParameters;
  final AudioLearnAppViewType audioLearnAppViewType;
  final FocusNode focusNode;
  final WarningMessageVM warningMessageVM;
  final CalledFrom calledFrom;
  final SettingsDataService settingsDataService;

  const ConvertTextToAudioDialog({
    super.key,
    required this.settingsDataService,
    required this.warningMessageVM,
    required this.selectedPlaylist,
    required this.selectedPlaylistAudioLst,
    required this.audioSortFilterParameters,
    required this.audioLearnAppViewType,
    required this.focusNode,
    required this.calledFrom,
    this.audioSortFilterParametersName = '',
  });

  @override
  // ignore: library_private_types_in_public_api
  _ConvertTextToAudioDialogState createState() =>
      _ConvertTextToAudioDialogState();
}

class _ConvertTextToAudioDialogState extends State<ConvertTextToAudioDialog>
    with ScreenMixin {
  late final List<String> _audioTitleFilterSentencesLst = [];

  late List<SortingItem> _selectedSortingItemLst;

  final TextEditingController _startFileSizeController =
      TextEditingController();
  final TextEditingController _endFileSizeController = TextEditingController();
  final TextEditingController _textToConvertController =
      TextEditingController();
  final TextEditingController _audioTitleSearchSentenceController =
      TextEditingController();
  final TextEditingController _startDownloadDateTimeController =
      TextEditingController();
  final TextEditingController _endDownloadDateTimeController =
      TextEditingController();
  final TextEditingController _startUploadDateTimeController =
      TextEditingController();
  final TextEditingController _endUploadDateTimeController =
      TextEditingController();
  final TextEditingController _startAudioDurationController =
      TextEditingController();
  final TextEditingController _endAudioDurationController =
      TextEditingController();
  late String _textToConvert;

  final _audioTitleSearchSentenceFocusNode = FocusNode();
  final _textToConvertFocusNode = FocusNode();

  Color _textToConvertIconColor = kDarkAndLightDisabledIconColor;

  // Voice selection state
  bool _isVoiceMan = true; // Default to masculine voice

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
      if (widget.audioSortFilterParametersName ==
          AppLocalizations.of(context)!.sortFilterParametersDefaultName) {
        _textToConvertController.text = '';
        _textToConvert = '';
        _textToConvertIconColor = kDarkAndLightDisabledIconColor;
      } else if (widget.audioSortFilterParametersName.isNotEmpty) {
        _textToConvertIconColor = kDarkAndLightEnabledIconColor;
      }
    });

    _textToConvertController.text = widget.audioSortFilterParametersName;

    // Since the _sortFilterSaveAsUniqueNameController is late, it
    // must be set here otherwise saving the sort filter parameters
    // will not work since an error is thrown  due to the fact that
    // the late _sortFilterSaveAsUniqueNameController is not
    // initialized
    _textToConvert = widget.audioSortFilterParametersName;

    _textToConvertController.text = widget.audioSortFilterParametersName;

    AudioSortFilterParameters audioSortDefaultFilterParameters;

    if (widget.audioSortFilterParametersName.isNotEmpty) {
      audioSortDefaultFilterParameters = widget.audioSortFilterParameters;
    } else {
      audioSortDefaultFilterParameters =
          AudioSortFilterParameters.createDefaultAudioSortFilterParameters();
    }

    _selectedSortingItemLst = [];
    _selectedSortingItemLst
        .addAll(audioSortDefaultFilterParameters.selectedSortItemLst);
    _audioTitleFilterSentencesLst
        .addAll(audioSortDefaultFilterParameters.filterSentenceLst);

    double fileSizeStartRangeMB =
        audioSortDefaultFilterParameters.fileSizeStartRangeMB;
    _startFileSizeController.text =
        (fileSizeStartRangeMB > 0.0) ? fileSizeStartRangeMB.toString() : '';

    double fileSizeEndRangeMB =
        audioSortDefaultFilterParameters.fileSizeEndRangeMB;
    _endFileSizeController.text =
        (fileSizeEndRangeMB > 0.0) ? fileSizeEndRangeMB.toString() : '';

    int durationStartRangeSec =
        audioSortDefaultFilterParameters.durationStartRangeSec;
    _startAudioDurationController.text = (durationStartRangeSec > 0)
        ? Duration(seconds: durationStartRangeSec).HHmm()
        : '';

    int durationEndRangeSec =
        audioSortDefaultFilterParameters.durationEndRangeSec;
    _endAudioDurationController.text = (durationEndRangeSec > 0)
        ? Duration(seconds: durationEndRangeSec).HHmm()
        : '';
  }

  @override
  void dispose() {
    _startFileSizeController.dispose();
    _endFileSizeController.dispose();
    _textToConvertController.dispose();
    _audioTitleSearchSentenceController.dispose();
    _startDownloadDateTimeController.dispose();
    _endDownloadDateTimeController.dispose();
    _startUploadDateTimeController.dispose();
    _endUploadDateTimeController.dispose();
    _startAudioDurationController.dispose();
    _endAudioDurationController.dispose();
    _audioTitleSearchSentenceFocusNode.dispose();
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
                    _buildTextToConvertFieldAndDeleteButton(context),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextToConvertFieldAndDeleteButton(
    BuildContext context,
  ) {
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
                  maxLines: 6,
                  decoration: getDialogTextFieldInputDecoration(
                    hintText: AppLocalizations.of(context)!
                        .textToConvertTextFieldHint,
                  ),
                  controller: _textToConvertController,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    _textToConvert = value;
                    // setting the Delete button color according to the
                    // TextField content ...
                    _textToConvertIconColor = _textToConvert.isNotEmpty
                        ? kDarkAndLightEnabledIconColor
                        : kDarkAndLightDisabledIconColor;

                    setState(() {}); // necessary to update Plus button color
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
  Row _buildActionButtonsLine({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
    required DateFormatVM dateFormatVMlistenFalse,
  }) {
    PlaylistListVM playlistListVMlistenFalse = Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );
    TextToSpeechVM textToSpeechVMlistenTrue = Provider.of<TextToSpeechVM>(
      context,
      listen: true,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildListenTextButton(
          context: context,
          themeProviderVM: themeProviderVM,
          textToSpeechVMlistenTrue: textToSpeechVMlistenTrue,
        ),
        _buildCreateAudioFileButton(
          context: context,
          themeProviderVM: themeProviderVM,
        ),
        TextButton(
          key: const Key('cancelSortFilterButton'),
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
      ],
    );
  }

  Widget _buildListenTextButton({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
    required TextToSpeechVM textToSpeechVMlistenTrue,
  }) {
    // Check if either TTS is speaking OR audio file is playing
    bool isAnythingPlaying = textToSpeechVMlistenTrue.isPlaying ||
        textToSpeechVMlistenTrue.isSpeaking;

    return SizedBox(
      // sets the rounded TextButton size improving the distance
      // between the button text and its boarder
      width: kGreaterButtonWidth + 10,
      height: kNormalButtonHeight,
      child: Tooltip(
        message: AppLocalizations.of(context)!.listenTextButtonTooltip,
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
          onPressed: textToSpeechVMlistenTrue.inputText.trim().isEmpty
              ? null
              : isAnythingPlaying
                  ? () => _stopAllAudio(
                        textToSpeechVMlistenTrue: textToSpeechVMlistenTrue,
                      )
                  : () => textToSpeechVMlistenTrue.speakText(
                        isVoiceMan: _isVoiceMan,
                      ),
          child: Row(
            mainAxisSize: MainAxisSize
                .min, // Pour s'assurer que le Row n'occupe pas plus d'espace que nécessaire
            children: <Widget>[
              const Icon(
                Icons.volume_up,
                size: 18,
              ),
              Text(
                AppLocalizations.of(context)!.listenTextButton,
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
  }) {
    return SizedBox(
      // sets the rounded TextButton size improving the distance
      // between the button text and its boarder
      width: kGreaterButtonWidth * 2.25,
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
          onPressed: () async {},
          child: Row(
            mainAxisSize: MainAxisSize
                .min, // Pour s'assurer que le Row n'occupe pas plus d'espace que nécessaire
            children: <Widget>[
              const Icon(
                Icons.audiotrack,
                size: 18,
              ),
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
