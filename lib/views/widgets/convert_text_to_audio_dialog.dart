import 'package:audiolearn/utils/duration_expansion.dart';
import 'package:audiolearn/viewmodels/date_format_vm.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../models/playlist.dart';
import '../../utils/date_time_parser.dart';
import '../../viewmodels/playlist_list_vm.dart';
import '../../services/sort_filter_parameters.dart';
import '../../viewmodels/warning_message_vm.dart';
import '../screen_mixin.dart';
import '../../models/audio.dart';
import '../../services/audio_sort_filter_service.dart';
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
  late AudioSortFilterParameters _audioSortFilterParameters;

  late final List<String> _audioTitleFilterSentencesLst = [];

  late List<SortingItem> _selectedSortingItemLst;
  late bool _isAnd;
  late bool _ignoreCase;
  late bool _searchInVideoCompactDescription;
  late bool _searchInYoutubeChannelName;
  late bool _masculineVoice;
  late bool _femineVoice;
  late bool _filterFullyListened;
  late bool _filterPartiallyListened;
  late bool _filterNotListened;
  late bool _filterCommented;
  late bool _filterNotCommented;
  late bool _filterPictured;
  late bool _filterNotPictured;
  late bool _filterPlayable;
  late bool _filterNotPlayable;
  late bool _filterDownloaded;
  late bool _filterImported;

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
  DateTime? _startDownloadDateTime;
  DateTime? _endDownloadDateTime;
  DateTime? _startUploadDateTime;
  DateTime? _endUploadDateTime;

  final _audioTitleSearchSentenceFocusNode = FocusNode();
  final _textToConvertFocusNode = FocusNode();

  Color _textToConvertIconColor = kDarkAndLightDisabledIconColor;

  late AudioSortFilterService _audioSortFilterService;

  static const int _maxDisplayableStringLength = 34;

  @override
  void initState() {
    super.initState();

    _audioSortFilterService = AudioSortFilterService(
      settingsDataService: widget.settingsDataService,
    );
    _audioSortFilterParameters = widget.audioSortFilterParameters;

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
    _ignoreCase = audioSortDefaultFilterParameters.ignoreCase;
    _searchInYoutubeChannelName =
        audioSortDefaultFilterParameters.searchAsWellInYoutubeChannelName;
    _searchInVideoCompactDescription =
        _audioSortFilterParameters.searchAsWellInVideoCompactDescription;
    _isAnd = (audioSortDefaultFilterParameters.sentencesCombination ==
        SentencesCombination.and);
    _masculineVoice = true;
    _femineVoice = false;
    _filterFullyListened = audioSortDefaultFilterParameters.filterFullyListened;
    _filterPartiallyListened =
        audioSortDefaultFilterParameters.filterPartiallyListened;
    _filterNotListened = audioSortDefaultFilterParameters.filterNotListened;
    _filterCommented = audioSortDefaultFilterParameters.filterCommented;
    _filterNotCommented = audioSortDefaultFilterParameters.filterNotCommented;
    _filterPictured = audioSortDefaultFilterParameters.filterPictured;
    _filterNotPictured = audioSortDefaultFilterParameters.filterNotPictured;
    _filterPlayable = audioSortDefaultFilterParameters.filterPlayable;
    _filterNotPlayable = audioSortDefaultFilterParameters.filterNotPlayable;
    _filterDownloaded = audioSortDefaultFilterParameters.filterDownloaded;
    _filterImported = audioSortDefaultFilterParameters.filterImported;
    _startDownloadDateTime =
        audioSortDefaultFilterParameters.downloadDateStartRange;
    _endDownloadDateTime =
        audioSortDefaultFilterParameters.downloadDateEndRange;
    _startUploadDateTime =
        audioSortDefaultFilterParameters.uploadDateStartRange;
    _endUploadDateTime = audioSortDefaultFilterParameters.uploadDateEndRange;

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

  void _resetSortFilterOptions() {
    _selectedSortingItemLst.clear();
    _selectedSortingItemLst
        .add(AudioSortFilterParameters.getDefaultSortingItem());
    _clearTextToConvertField();
    _audioTitleSearchSentenceController.clear();
    _audioTitleFilterSentencesLst.clear();
    _ignoreCase = true;
    _searchInYoutubeChannelName = true;
    _searchInVideoCompactDescription = true;
    _masculineVoice = false;
    _filterFullyListened = true;
    _filterPartiallyListened = true;
    _filterNotListened = true;
    _filterCommented = true;
    _filterNotCommented = true;
    _filterPictured = true;
    _filterNotPictured = true;
    _filterPlayable = true;
    _filterNotPlayable = true;
    _filterDownloaded = true;
    _filterImported = true;
    _startDownloadDateTimeController.clear();
    _endDownloadDateTimeController.clear();
    _startUploadDateTimeController.clear();
    _endUploadDateTimeController.clear();
    _startAudioDurationController.clear();
    _endAudioDurationController.clear();
    _startFileSizeController.clear();
    _endFileSizeController.clear();
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildListenTextButton(
          context: context,
          themeProviderVM: themeProviderVM,
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

  AudioSortFilterParameters? executeAudioSortFilterParmsDeletion(
    PlaylistListVM playlistListVM,
  ) {
    AudioSortFilterParameters? deletedSFparms =
        playlistListVM.deleteAudioSortFilterParameters(
      audioSortFilterParametersName: _textToConvert,
    );

    // removing the deleted sort/filter parameters from the
    // sort/filter dialog
    setState(() {
      _resetSortFilterOptions();
    });

    return deletedSFparms;
  }

  Widget _buildListenTextButton({
    required BuildContext context,
    required ThemeProviderVM themeProviderVM,
  }) {
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
          onPressed: () async {
          },
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
          onPressed: () async {
          },
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
          value: _masculineVoice,
          onChanged: (bool? newValue) {
            setState(() {
              _masculineVoice = newValue!;
            });

            if (!_masculineVoice) {
              // If the music quality checkbox is unchecked, the spoken
              // quality checkbox must be checked since it makes no sense
              // to have both unchecked
              _femineVoice = true;
            } else {
              // If the masculine voice checkbox is checked, the spoken
              // quality checkbox must be unchecked since it makes no sense
              // to have both checked
              _femineVoice = false;
            }

            // now clicking on Enter works since the
            // Checkbox is not focused anymore
            _textToConvertFocusNode.requestFocus();
          },
        ),
        Text(AppLocalizations.of(context)!.femineVoice),
        Checkbox(
          key: const Key('femineVoiceCheckbox'),
          value: _femineVoice,
          onChanged: (bool? newValue) {
            setState(() {
              _femineVoice = newValue!;
            });

            if (_femineVoice) {
              // If the spoken quality checkbox is unchecked, the music
              // quality checkbox must be checked since it makes no sense
              // to have both unchecked
              _masculineVoice = false;
            } else {
              // If the spoken quality checkbox is checked, the music
              // quality checkbox must be unchecked since it makes no sense
              // to have both checked
              _masculineVoice = true;
            }

            // now clicking on Enter works since the
            // Checkbox is not focused anymore
            _textToConvertFocusNode.requestFocus();
          },
        ),
      ],
    );
  }

  /// Method called when the user clicks on the 'Save' or 'Apply' button.
  ///
  /// The method tests if the Save as Sort/Filter parms name already exist. If
  /// it does, a confirm action dialog is displayed to the user listing the
  /// differences between the existing and the new sort/filter parameters. The
  /// user is asked to confirm the save operation or to cancel it.
  ///
  /// The method filters and sorts the audio list based on the selected
  /// sorting and filtering options. The method returns a list of three
  /// elements:
  ///   1/ the filtered and sorted selected playlist audio list
  ///   2/ the audio sort filter parameters (AudioSortFilterParameters)
  ///   3/ the sort filter parameters save as unique name
  Future<List> _filterAndSortAudioLst({
    required PlaylistListVM playlistListVMlistenFalse,
    required DateFormatVM dateFormatVMlistenFalse,
    required String sortFilterParametersSaveAsUniqueName,
  }) async {
    _audioSortFilterParameters =
        _generateAudioSortFilterParametersFromDialogFields();

    bool cancelSaveSortFilterParms = false;

    if (playlistListVMlistenFalse.doesAudioSortFilterParmsNameAlreadyExist(
        audioSortFilterParmrsName: _textToConvert)) {
      // Obtaining the existing sort/filter parameters in order to
      // compare them with the new or modified ones.
      AudioSortFilterParameters existingAudioSortFilterParameters =
          playlistListVMlistenFalse.getAudioSortFilterParameters(
        audioSortFilterParametersName: _textToConvert,
      );

      // Getting the list of differences between the existing and the new
      // or modified sort/filter parameters
      List<String> listOfDifferencesBetweenSortFilterParameters =
          _audioSortFilterService
              .getListOfDifferencesBetweenSortFilterParameters(
        dateFormatVMlistenFalse: dateFormatVMlistenFalse,
        existingAudioSortFilterParms: existingAudioSortFilterParameters,
        newOrModifiedaudioSortFilterParms: _audioSortFilterParameters,
        sortFilterParmsNameTranslationMap:
            _createSortFilterParmNameTranslationMap(),
      );

      if (listOfDifferencesBetweenSortFilterParameters.isNotEmpty) {
        // If there are differences between the existing and the new or
        // modified sort/filter parameters, a confirm action dialog which
        // contains the sort/filter parameters modifications is displayed
        // to the user.
        String formattedModifiedSortFilterParmsStr =
            _formatModifiedSortFilterParmsStr(
          sortFilterParmsVersionDifferenceLst:
              listOfDifferencesBetweenSortFilterParameters,
        );

        await showDialog<dynamic>(
          context: context,
          barrierDismissible:
              false, // This line prevents the dialog from closing when
          //            tapping outside the dialog
          builder: (BuildContext context) {
            return ConfirmActionDialog(
              actionFunction: returnConfirmAction,
              actionFunctionArgs: [],
              dialogTitleOne: AppLocalizations.of(context)!
                  .updatingSortFilterParmsWarningTitle(
                _textToConvert,
              ),
              dialogTitleOneReducedFontSize: true,
              dialogContent: formattedModifiedSortFilterParmsStr,
            );
          },
        ).then((result) {
          if (result == ConfirmAction.cancel) {
            cancelSaveSortFilterParms = true;
          }
        });
      }
    }

    if (cancelSaveSortFilterParms) {
      // The case if the user was saving a sort/filter parameters
      // with the same name as an existing one and, after having
      // read the confirm action dialog warning, cancelled the save
      // operation. In this situation, the sort/filter parameters
      // are not saved and the audio sort filter dialog is not closed.
      return [];
    } else {
      List<Audio> filteredAndSortedAudioLst =
          _audioSortFilterService.filterAndSortAudioLst(
        selectedPlaylist: widget.selectedPlaylist,
        audioLst: widget.selectedPlaylistAudioLst,
        audioSortFilterParameters: _audioSortFilterParameters,
      );

      return [
        filteredAndSortedAudioLst,
        _audioSortFilterParameters,
        sortFilterParametersSaveAsUniqueName,
      ];
    }
  }

  ConfirmAction returnConfirmAction() {
    return ConfirmAction.confirm;
  }

  /// This method creates a map of keyed by the sort filter parameters names and
  /// valued by the sort filter parameters names translated in the current language.
  ///
  /// This must be done that way since the AppLocalizations class is only available
  /// in the interface classes.
  Map<String, String> _createSortFilterParmNameTranslationMap() {
    Map<String, String> translationMap = {
      'selectedSortItemLstTitle':
          "${AppLocalizations.of(context)!.sortBy}$kStartAtZeroPosition",

      // Adding a ':' at the end of the string will cause it to be
      // formatted in _formatModifiedSortFilterParmsStr() as an aligned
      // title in the confirm action dialog
      'presentOnlyInFirstTitle':
          "${AppLocalizations.of(context)!.presentOnlyInFirstTitle}:",

      // Adding a ':' at the end of the string will cause it to be
      // formatted in _formatModifiedSortFilterParmsStr() as an aligned
      // title in the confirm action dialog
      'presentOnlyInSecondTitle':
          "${AppLocalizations.of(context)!.presentOnlyInSecondTitle}:",

      'audioDownloadDate': AppLocalizations.of(context)!.audioDownloadDate,
      'videoUploadDate': AppLocalizations.of(context)!.videoUploadDate,
      'validAudioTitle': AppLocalizations.of(context)!.audioTitleLabel,
      'chapterAudioTitle': AppLocalizations.of(context)!.chapterAudioTitleLabel,
      'audioEnclosingPlaylistTitle':
          AppLocalizations.of(context)!.audioEnclosingPlaylistTitle,
      'audioDuration': AppLocalizations.of(context)!.audioDuration,
      'audioRemainingDuration':
          AppLocalizations.of(context)!.audioRemainingDuration,
      'lastListenedDateTime':
          AppLocalizations.of(context)!.lastListenedDateTime,
      'audioFileSize': AppLocalizations.of(context)!.audioFileSize,
      'audioDownloadSpeed': AppLocalizations.of(context)!.audioDownloadSpeed,
      'audioDownloadDuration':
          AppLocalizations.of(context)!.audioDownloadDuration,
      "ascending": AppLocalizations.of(context)!.ascendingShort,
      "descending": AppLocalizations.of(context)!.descendingShort,
      'filterSentenceLstTitle':
          "${AppLocalizations.of(context)!.filterSentences}$kStartAtZeroPosition",
      'filterOptionLstTitle':
          "${AppLocalizations.of(context)!.filterOptions}$kStartAtZeroPosition",
      'valueInInitialVersionTitle':
          "${AppLocalizations.of(context)!.valueInInitialVersionTitle}:",
      'valueInModifiedVersionTitle':
          "${AppLocalizations.of(context)!.valueInModifiedVersionTitle}:",
      'sentencesCombination':
          "${AppLocalizations.of(context)!.and} / ${AppLocalizations.of(context)!.or}",
      'and': AppLocalizations.of(context)!.and,
      'or': AppLocalizations.of(context)!.or,
      'ignoreCase': AppLocalizations.of(context)!.ignoreCase,
      'checked': AppLocalizations.of(context)!.checked,
      'unchecked': AppLocalizations.of(context)!.unchecked,
      'searchAsWellInYoutubeChannelName':
          AppLocalizations.of(context)!.searchInYoutubeChannelName,
      'searchAsWellInVideoCompactDescription':
          AppLocalizations.of(context)!.searchInVideoCompactDescription,
      'filterMusicQuality': AppLocalizations.of(context)!.audioMusicQuality,
      'filterSpokenQuality': AppLocalizations.of(context)!.audioSpokenQuality,
      'filterFullyListened': AppLocalizations.of(context)!.fullyListened,
      'filterPartiallyListened':
          AppLocalizations.of(context)!.partiallyListened,
      'filterNotListened': AppLocalizations.of(context)!.notListened,
      'filterCommented': AppLocalizations.of(context)!.commented,
      'filterNotCommented': AppLocalizations.of(context)!.notCommented,
      'filterPictured': AppLocalizations.of(context)!.pictured,
      'filterNotPictured': AppLocalizations.of(context)!.notPictured,
      'filterPlayable': AppLocalizations.of(context)!.playable,
      'filterNotPlayable': AppLocalizations.of(context)!.notPlayable,
      'filterDownloaded': AppLocalizations.of(context)!.downloadedCheckbox,
      'filterImported': AppLocalizations.of(context)!.importedCheckbox,
      'downloadDateStartRange': AppLocalizations.of(context)!.startDownloadDate,
      'downloadDateEndRange': AppLocalizations.of(context)!.endDownloadDate,
      'uploadDateStartRange': AppLocalizations.of(context)!.startUploadDate,
      'uploadDateEndRange': AppLocalizations.of(context)!.endUploadDate,
      'emptyDate': AppLocalizations.of(context)!.emptyDate,
      'fileSizeStartRangeMB':
          "${AppLocalizations.of(context)!.fileSizeRange} ${AppLocalizations.of(context)!.start}",
      'fileSizeEndRangeMB':
          "${AppLocalizations.of(context)!.fileSizeRange} ${AppLocalizations.of(context)!.end}",
      'durationStartRangeSec':
          "${AppLocalizations.of(context)!.audioDurationRange} ${AppLocalizations.of(context)!.start}",
      'durationEndRangeSec':
          "${AppLocalizations.of(context)!.audioDurationRange} ${AppLocalizations.of(context)!.end}",
    };

    return translationMap;
  }

  String _formatModifiedSortFilterParmsStr({
    required List<String> sortFilterParmsVersionDifferenceLst,
  }) {
    StringBuffer formattedString = StringBuffer();

    // number of ' ' to add before displaying the element
    int leftSpaceNumber = 0;

    for (int i = 0; i < sortFilterParmsVersionDifferenceLst.length; i++) {
      String element = sortFilterParmsVersionDifferenceLst[i];

      if (element.contains(kStartAtZeroPosition)) {
        // A new option list is started and its name is displayed at
        // position 0. Two options list exist:
        //   1/ the sort option list
        //   2/ the filter option list
        leftSpaceNumber = 0;
        element = element.replaceAll(kStartAtZeroPosition, '');
      }

      String leftSpace = ' ' * leftSpaceNumber;

      if (element.contains(', ')) {
        element = _formatCommaSeparatedValues(
          input: element,
          firstIndentSpaces: leftSpaceNumber - 2,
          subsequentIndentSpaces: leftSpaceNumber + 1,
          leftSpace: leftSpace,
        );
      } else {
        if (element.length >= _maxDisplayableStringLength) {
          element = _replacePenultimateSpaceWithNewline(
            strToModify: element,
            spaceStr: '$leftSpace ',
          );
        }
      }

      formattedString.write('$leftSpace$element');

      // Add a comma and newline if the element does not end with ':' and
      // is not the last element
      if (!element.endsWith(':') &&
          i < sortFilterParmsVersionDifferenceLst.length - 1) {
        formattedString.write('\n');
        leftSpaceNumber--;
      } else if (i < sortFilterParmsVersionDifferenceLst.length - 1) {
        // element ends with ':' and is not the last element
        leftSpace = ' ' * leftSpaceNumber++;
        formattedString
            .write('\n$leftSpace'); // Add only newline if it ends with ':'
      }
    }

    return formattedString.toString();
  }

  String _replacePenultimateSpaceWithNewline({
    required String strToModify,
    required String spaceStr,
  }) {
    // Find the last space index
    int lastSpaceIndex = strToModify.lastIndexOf(' ');

    // If there's no space or only one space, return the string as is
    if (lastSpaceIndex == -1) {
      return strToModify;
    }

    // Find the penultimate space index
    int penultimateSpaceIndex =
        strToModify.substring(0, lastSpaceIndex).lastIndexOf(' ');

    if (penultimateSpaceIndex == -1) {
      return strToModify; // No penultimate space found
    }

    // Reconstruct the string
    return '${strToModify.substring(0, penultimateSpaceIndex)}\n$spaceStr${strToModify.substring(penultimateSpaceIndex + 1)}';
  }

  String _formatCommaSeparatedValues({
    required String input,
    required int firstIndentSpaces,
    required int subsequentIndentSpaces,
    required String leftSpace,
  }) {
    // Define the spaces for indentation
    String firstIndent = (firstIndentSpaces > 0) ? ' ' * firstIndentSpaces : '';
    String subsequentIndent =
        (subsequentIndentSpaces > 0) ? ' ' * subsequentIndentSpaces : '';

    // Split the input string by the commas, preserving the delimiters
    RegExp regExp = RegExp(r"(.*?,)");
    Iterable<Match> matches = regExp.allMatches(input);

    StringBuffer buffer = StringBuffer();
    bool isFirst = true;

    int lastMatchEnd =
        0; // Tracks the end of the last match for appending remaining text

    for (Match match in matches) {
      String substring = match.group(
          0)!; // Get the matched substring, e.g., "Date téléch audio asc,"

      if (substring.length >= _maxDisplayableStringLength) {
        substring = _replacePenultimateSpaceWithNewline(
          strToModify: substring,
          spaceStr: '$leftSpace ',
        );
      }

      // Apply the appropriate indentation
      if (isFirst) {
        buffer.write('$firstIndent${substring.trim()}');
        isFirst = false;
      } else {
        buffer.write('\n$subsequentIndent${substring.trim()}');
      }

      // Update the position of the last match
      lastMatchEnd = match.end;
    }

    // Append any remaining part of the string (after the last comma)
    if (lastMatchEnd <= input.length) {
      buffer
          .write('\n$subsequentIndent${input.substring(lastMatchEnd).trim()}');
    }

    return buffer.toString();
  }

  AudioSortFilterParameters
      _generateAudioSortFilterParametersFromDialogFields() {
    String startFileSizeTxt = _startFileSizeController.text;
    String endFileSizeTxt = _endFileSizeController.text;
    String startAudioDurationTxt = _startAudioDurationController.text;
    String endAudioDurationTxt = _endAudioDurationController.text;

    return AudioSortFilterParameters(
      selectedSortItemLst: _selectedSortingItemLst,
      filterSentenceLst: _audioTitleFilterSentencesLst,
      sentencesCombination:
          (_isAnd) ? SentencesCombination.and : SentencesCombination.or,
      ignoreCase: _ignoreCase,
      searchAsWellInYoutubeChannelName: _searchInYoutubeChannelName,
      searchAsWellInVideoCompactDescription: _searchInVideoCompactDescription,
      filterMusicQuality: _masculineVoice,
      filterSpokenQuality: _femineVoice,
      filterFullyListened: _filterFullyListened,
      filterPartiallyListened: _filterPartiallyListened,
      filterNotListened: _filterNotListened,
      filterCommented: _filterCommented,
      filterNotCommented: _filterNotCommented,
      filterPictured: _filterPictured,
      filterNotPictured: _filterNotPictured,
      filterPlayable: _filterPlayable,
      filterDownloaded: _filterDownloaded,
      filterImported: _filterImported,
      filterNotPlayable: _filterNotPlayable,
      downloadDateStartRange: _startDownloadDateTime,
      downloadDateEndRange: _endDownloadDateTime,
      uploadDateStartRange: _startUploadDateTime,
      uploadDateEndRange: _endUploadDateTime,
      fileSizeStartRangeMB: double.tryParse(startFileSizeTxt) ?? 0.0,
      fileSizeEndRangeMB: double.tryParse(endFileSizeTxt) ?? 0.0,
      durationStartRangeSec:
          DateTimeParser.parseHHMMDuration(startAudioDurationTxt)?.inSeconds ??
              0,
      durationEndRangeSec:
          DateTimeParser.parseHHMMDuration(endAudioDurationTxt)?.inSeconds ?? 0,
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
