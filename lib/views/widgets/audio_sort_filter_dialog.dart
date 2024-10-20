import 'package:audiolearn/utils/duration_expansion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../utils/button_state_manager.dart';
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

class AudioSortFilterDialog extends StatefulWidget {
  final List<Audio> selectedPlaylistAudioLst;
  final String audioSortFilterParametersName;
  final AudioSortFilterParameters audioSortFilterParameters;
  final AudioSortFilterParameters audioSortPlaylistFilterParameters;
  final AudioLearnAppViewType audioLearnAppViewType;
  final FocusNode focusNode;
  final WarningMessageVM warningMessageVM;
  final CalledFrom calledFrom;

  const AudioSortFilterDialog({
    super.key,
    required this.selectedPlaylistAudioLst,
    this.audioSortFilterParametersName = '',
    required this.audioSortFilterParameters,
    required this.audioSortPlaylistFilterParameters,
    required this.audioLearnAppViewType,
    required this.focusNode,
    required this.warningMessageVM,
    required this.calledFrom,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AudioSortFilterDialogState createState() => _AudioSortFilterDialogState();
}

class _AudioSortFilterDialogState extends State<AudioSortFilterDialog>
    with ScreenMixin {
  late AudioSortFilterParameters _audioSortFilterParameters;
  late InputDecoration _dialogTextFieldDecoration;
  late InputDecoration _dialogDateTextFieldDecoration;

  late final List<String> _audioTitleFilterSentencesLst = [];

  late List<SortingItem> _selectedSortingItemLst;
  late bool _isAnd;
  late bool _isOr;
  late bool _ignoreCase;
  late bool _searchInVideoCompactDescription;
  late bool _searchInYoutubeChannelName;
  late bool _filterMusicQuality;
  late bool _filterFullyListened;
  late bool _filterPartiallyListened;
  late bool _filterNotListened;

  final TextEditingController _startFileSizeController =
      TextEditingController();
  final TextEditingController _endFileSizeController = TextEditingController();
  final TextEditingController _sortFilterSaveAsUniqueNameController =
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
  String _audioTitleSearchSentence = '';
  late String _sortFilterSaveAsUniqueName;
  DateTime? _startDownloadDateTime;
  DateTime? _endDownloadDateTime;
  DateTime? _startUploadDateTime;
  DateTime? _endUploadDateTime;

  final _audioTitleSearchSentenceFocusNode = FocusNode();
  final _sortFilterSaveAsUniqueNameFocusNode = FocusNode();

  Color _audioTitleSearchSentenceAddButtonIconColor =
      kDarkAndLightDisabledIconColor;
  Color _audioSortOptionButtonIconColor = kDarkAndLightDisabledIconColor;
  Color _audioSaveAsNameDeleteIconColor = kDarkAndLightDisabledIconColor;
  Color _historicalAudioSortFilterParamsLeftIconColor =
      kDarkAndLightDisabledIconColor;
  Color _historicalAudioSortFilterParamsRightIconColor =
      kDarkAndLightDisabledIconColor;
  Color _historicalAudioSortFilterParamsDeleteIconColor =
      kDarkAndLightDisabledIconColor;

  int _historicalAudioSortFilterParametersIndex = 0;

  final AudioSortFilterService _audioSortFilterService =
      AudioSortFilterService();

  List<AudioSortFilterParameters> _historicalAudioSortFilterParametersLst = [];

  @override
  void initState() {
    super.initState();

    _audioSortFilterParameters = widget.audioSortFilterParameters;
    _dialogTextFieldDecoration = getDialogTextFieldInputDecoration();
    _dialogDateTextFieldDecoration = getDialogTextFieldInputDecoration(
      labelTxt: 'dd/mm/yyyy',
      labelTxtFontSize: 14.0,
    );

    // Add this line to request focus on the TextField after the build
    // method has been called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // When opening the sort/filter dialog, the focus is set
      // depending from where the dialog was opened.

      switch (widget.calledFrom) {
        case CalledFrom.playlistDownloadView:
          FocusScope.of(context).requestFocus(
            _sortFilterSaveAsUniqueNameFocusNode,
          );
          break;
        case CalledFrom.playlistDownloadViewAudioMenu:
          FocusScope.of(context).requestFocus(
            _audioTitleSearchSentenceFocusNode,
          );
          break;
        case CalledFrom.audioPlayerView:
          FocusScope.of(context).requestFocus(
            _sortFilterSaveAsUniqueNameFocusNode,
          );
          break;
        case CalledFrom.audioPlayerViewAudioMenu:
          FocusScope.of(context).requestFocus(
            _audioTitleSearchSentenceFocusNode,
          );
          break;
        default:
          FocusScope.of(context).requestFocus(
            _sortFilterSaveAsUniqueNameFocusNode,
          );
          break;
      }
    });

    /// In this method, the context is available.
    Future.delayed(Duration.zero, () {
      if (widget.audioSortFilterParametersName ==
          AppLocalizations.of(context)!.sortFilterParametersDefaultName) {
        _sortFilterSaveAsUniqueNameController.text = '';
        _sortFilterSaveAsUniqueName = '';
        _audioSaveAsNameDeleteIconColor = kDarkAndLightDisabledIconColor;
      } else if (widget.audioSortFilterParametersName.isNotEmpty) {
        _audioSaveAsNameDeleteIconColor = kDarkAndLightEnabledIconColor;
      }

      _historicalAudioSortFilterParametersLst = Provider.of<PlaylistListVM>(
        context,
        listen: false,
      ).getSearchHistoryAudioSortFilterParametersLst();

      _initializeHistoricalAudioSortFilterParamsLeftIconColors();
    });

    _sortFilterSaveAsUniqueNameController.text =
        widget.audioSortFilterParametersName;

    // Since the _sortFilterSaveAsUniqueNameController is late, it
    // must be set here otherwise saving the sort filter parameters
    // will not work since an error is thrown  due to the fact that
    // the late _sortFilterSaveAsUniqueNameController is not
    // initialized
    _sortFilterSaveAsUniqueName = widget.audioSortFilterParametersName;

    // Set the initial sort and filter fields
    AudioSortFilterParameters audioSortDefaultFilterParameters =
        widget.audioSortPlaylistFilterParameters;

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
        SentencesCombination.AND);
    _isOr = !_isAnd;
    _filterMusicQuality = audioSortDefaultFilterParameters.filterMusicQuality;
    _filterFullyListened = audioSortDefaultFilterParameters.filterFullyListened;
    _filterPartiallyListened =
        audioSortDefaultFilterParameters.filterPartiallyListened;
    _filterNotListened = audioSortDefaultFilterParameters.filterNotListened;
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
    _sortFilterSaveAsUniqueNameController.dispose();
    _audioTitleSearchSentenceController.dispose();
    _startDownloadDateTimeController.dispose();
    _endDownloadDateTimeController.dispose();
    _startUploadDateTimeController.dispose();
    _endUploadDateTimeController.dispose();
    _startAudioDurationController.dispose();
    _endAudioDurationController.dispose();
    _audioTitleSearchSentenceFocusNode.dispose();
    _sortFilterSaveAsUniqueNameFocusNode.dispose();

    super.dispose();
  }

  void _resetSortFilterOptions() {
    _selectedSortingItemLst.clear();
    _selectedSortingItemLst
        .add(AudioSortFilterParameters.getDefaultSortingItem());
    _sortFilterSaveAsUniqueNameController.clear();
    _audioTitleSearchSentenceController.clear();
    _audioTitleFilterSentencesLst.clear();
    _ignoreCase = true;
    _searchInYoutubeChannelName = true;
    _searchInVideoCompactDescription = true;
    _isAnd = true;
    _isOr = false;
    _filterMusicQuality = false;
    _filterFullyListened = true;
    _filterPartiallyListened = true;
    _filterNotListened = true;
    _startDownloadDateTimeController.clear();
    _endDownloadDateTimeController.clear();
    _startUploadDateTimeController.clear();
    _endUploadDateTimeController.clear();
    _startAudioDurationController.clear();
    _endAudioDurationController.clear();
    _startFileSizeController.clear();
    _endFileSizeController.clear();
    _audioSortOptionButtonIconColor = kDarkAndLightDisabledIconColor;

    _initializeHistoricalAudioSortFilterParamsLeftIconColors();
  }

  // Method called when the user clicks on the Filter option left or
  // right sort and filter history parameters buttons
  void _setSortFilterOptions(
    AudioSortFilterParameters audioSortFilterParameters,
  ) {
    _selectedSortingItemLst.clear();
    _selectedSortingItemLst
        .addAll(audioSortFilterParameters.selectedSortItemLst);
    _sortFilterSaveAsUniqueNameController.clear();
    _audioTitleSearchSentenceController.clear();
    _audioTitleFilterSentencesLst.clear();
    _audioTitleFilterSentencesLst
        .addAll(audioSortFilterParameters.filterSentenceLst);
    _ignoreCase = audioSortFilterParameters.ignoreCase;
    _searchInYoutubeChannelName =
        audioSortFilterParameters.searchAsWellInYoutubeChannelName;
    _searchInVideoCompactDescription =
        audioSortFilterParameters.searchAsWellInVideoCompactDescription;
    _isAnd = (audioSortFilterParameters.sentencesCombination ==
        SentencesCombination.AND);
    _isOr = !_isAnd;
    _filterMusicQuality = audioSortFilterParameters.filterMusicQuality;
    _filterFullyListened = audioSortFilterParameters.filterFullyListened;
    _filterPartiallyListened =
        audioSortFilterParameters.filterPartiallyListened;
    _filterNotListened = audioSortFilterParameters.filterNotListened;
    _startDownloadDateTimeController.clear();
    _endDownloadDateTimeController.clear();
    _startUploadDateTimeController.clear();
    _endUploadDateTimeController.clear();
    _startAudioDurationController.clear();
    _endAudioDurationController.clear();
    _startFileSizeController.clear();
    _endFileSizeController.clear();

    if (_selectedSortingItemLst.length > 1) {
      _audioSortOptionButtonIconColor = kDarkAndLightEnabledIconColor;
    } else {
      _audioSortOptionButtonIconColor = kDarkAndLightDisabledIconColor;
    }

    _audioSortFilterParameters = audioSortFilterParameters;
  }

  void _initializeHistoricalAudioSortFilterParamsLeftIconColors() {
    _historicalAudioSortFilterParametersIndex =
        _historicalAudioSortFilterParametersLst.length;
    int maxValue = _historicalAudioSortFilterParametersLst.length;

    ButtonStateManager buttonStateManager = ButtonStateManager(
      minValue: 0,
      maxValue: maxValue.toDouble(),
    );

    _manageButtonsState(buttonStateManager);
    setState(() {});
  }

  String _sortingOptionToString(
    SortingOption option,
    BuildContext context,
  ) {
    switch (option) {
      case SortingOption.audioDownloadDate:
        return AppLocalizations.of(context)!.audioDownloadDate;
      case SortingOption.videoUploadDate:
        return AppLocalizations.of(context)!.videoUploadDate;
      case SortingOption.validAudioTitle:
        return AppLocalizations.of(context)!.audioTitleLabel;
      case SortingOption.audioEnclosingPlaylistTitle:
        return AppLocalizations.of(context)!.audioEnclosingPlaylistTitle;
      case SortingOption.audioDuration:
        return AppLocalizations.of(context)!.audioDuration;
      case SortingOption.audioRemainingDuration:
        return AppLocalizations.of(context)!.audioRemainingDuration;
      case SortingOption.lastListenedDateTime:
        return AppLocalizations.of(context)!.lastListenedDateTime;
      case SortingOption.audioFileSize:
        return AppLocalizations.of(context)!.audioFileSize;
      case SortingOption.audioDownloadSpeed:
        return AppLocalizations.of(context)!.audioDownloadSpeed;
      case SortingOption.audioDownloadDuration:
        return AppLocalizations.of(context)!.audioDownloadDuration;
      default:
        throw ArgumentError('Invalid sorting option');
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final DateTime now = DateTime.now();
    final ThemeProviderVM themeProviderVM = Provider.of<ThemeProviderVM>(
      context,
      listen: false,
    );
    return Center(
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.sortFilterDialogTitle),
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
                    _buildSaveAsFields(context),
                    const SizedBox(
                      height: kDialogTextFieldVerticalSeparation,
                    ),
                    Text(
                      AppLocalizations.of(context)!.sortBy,
                      style: kDialogTitlesStyle,
                    ),
                    _buildSortingChoiceList(context),
                    _buildSelectedSortingOptionsList(),
                    const SizedBox(
                      height: kDialogTextFieldVerticalSeparation,
                    ),
                    _buildFilterOptionTitleSearchHistoryButtons(context),
                    const SizedBox(
                      height: 14,
                    ),
                    _buildAudioFilterSentence(),
                    _buildAudioFilterSentencesLst(context),
                    Row(
                      children: <Widget>[
                        Tooltip(
                          message:
                              AppLocalizations.of(context)!.andSentencesTooltip,
                          child: Text(AppLocalizations.of(context)!.and),
                        ),
                        Checkbox(
                          key: const Key('andCheckbox'),
                          fillColor: WidgetStateColor.resolveWith(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.disabled)) {
                                return kDarkAndLightDisabledIconColor;
                              }
                              return kDarkAndLightEnabledIconColor;
                            },
                          ),
                          value: _isAnd,
                          onChanged: (_audioTitleFilterSentencesLst.length > 1)
                              ? _toggleCheckboxAnd
                              : null,
                        ),
                        Tooltip(
                          message:
                              AppLocalizations.of(context)!.orSentencesTooltip,
                          child: Text(AppLocalizations.of(context)!.or),
                        ),
                        Checkbox(
                          key: const Key('orCheckbox'),
                          fillColor: WidgetStateColor.resolveWith(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.disabled)) {
                                return kDarkAndLightDisabledIconColor;
                              }
                              return kDarkAndLightEnabledIconColor;
                            },
                          ),
                          value: _isOr,
                          onChanged: (_audioTitleFilterSentencesLst.length > 1)
                              ? _toggleCheckboxOr
                              : null,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(AppLocalizations.of(context)!.ignoreCase),
                        Checkbox(
                          key: const Key('ignoreCaseCheckbox'),
                          fillColor: WidgetStateColor.resolveWith(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.disabled)) {
                                return kDarkAndLightDisabledIconColor;
                              }
                              return kDarkAndLightEnabledIconColor;
                            },
                          ),
                          value: _ignoreCase,
                          onChanged: (_audioTitleFilterSentencesLst.isNotEmpty)
                              ? (bool? newValue) {
                                  setState(() {
                                    _modifyIgnoreCaseCheckBox(
                                      newValue,
                                    );
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                    Tooltip(
                      message: AppLocalizations.of(context)!
                          .searchInYoutubeChannelNameTooltip,
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!
                              .searchInYoutubeChannelName),
                          Checkbox(
                            key: const Key('searchInYoutubeChannelName'),
                            fillColor: WidgetStateColor.resolveWith(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return kDarkAndLightDisabledIconColor;
                                }
                                return kDarkAndLightEnabledIconColor;
                              },
                            ),
                            value: _searchInYoutubeChannelName,
                            onChanged:
                                (_audioTitleFilterSentencesLst.isNotEmpty)
                                    ? (bool? newValue) {
                                        setState(() {
                                          _modifySearchInYoutubeChannelNameCheckbox(
                                            newValue,
                                          );
                                        });
                                      }
                                    : null,
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: AppLocalizations.of(context)!
                          .searchInVideoCompactDescriptionTooltip,
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!
                              .searchInVideoCompactDescription),
                          Checkbox(
                            key: const Key('searchInVideoCompactDescription'),
                            fillColor: WidgetStateColor.resolveWith(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return kDarkAndLightDisabledIconColor;
                                }
                                return kDarkAndLightEnabledIconColor;
                              },
                            ),
                            value: _searchInVideoCompactDescription,
                            onChanged:
                                (_audioTitleFilterSentencesLst.isNotEmpty)
                                    ? (bool? newValue) {
                                        setState(() {
                                          _modifySearchInVideoCompactDescriptionCheckbox(
                                            newValue,
                                          );
                                        });
                                      }
                                    : null,
                          ),
                        ],
                      ),
                    ),
                    _buildAudioStateCheckboxes(context),
                    _buildAudioDateFields(context, now),
                    const SizedBox(
                      height: kDialogTextFieldVerticalSeparation,
                    ),
                    _buildAudioFileSizeFields(context),
                    const SizedBox(
                      height: kDialogTextFieldVerticalSeparation,
                    ),
                    _buildAudioDurationFields(context),
                    const SizedBox(
                      height: kDialogTextFieldVerticalSeparation,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          _buildActionButtonsLine(
            context,
            themeProviderVM,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveAsFields(
    BuildContext context,
  ) {
    return Tooltip(
      message: AppLocalizations.of(context)!.sortFilterSaveAsTextFieldTooltip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.saveAs,
            style: kDialogTitlesStyle,
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  key: const Key('sortFilterSaveAsUniqueNameTextField'),
                  focusNode: _sortFilterSaveAsUniqueNameFocusNode,
                  style: kDialogTextFieldStyle,
                  decoration: _dialogTextFieldDecoration,
                  controller: _sortFilterSaveAsUniqueNameController,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    _sortFilterSaveAsUniqueName = value;
                    // setting the Delete button color according to the
                    // TextField content ...
                    _audioSaveAsNameDeleteIconColor =
                        _sortFilterSaveAsUniqueName.isNotEmpty
                            ? kDarkAndLightEnabledIconColor
                            : kDarkAndLightDisabledIconColor;

                    setState(() {}); // necessary to update Plus button color
                  },
                ),
              ),
              SizedBox(
                width: kSmallIconButtonWidth,
                child: IconButton(
                  key: const Key('deleteSaveAsNameIconButton'),
                  onPressed: () async {
                    _sortFilterSaveAsUniqueNameController.text = '';
                    _sortFilterSaveAsUniqueName = '';
                    _audioSaveAsNameDeleteIconColor =
                        kDarkAndLightDisabledIconColor;
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
                    color: _audioSaveAsNameDeleteIconColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Create Reset (X), Save or Apply, Delete and Cancel buttons.
  ///
  /// Save button is displayed when the sort filter name is defined.
  /// If the sort filter name is empty, the Apply button is displayed.
  Row _buildActionButtonsLine(
    BuildContext context,
    ThemeProviderVM themeProviderVM,
  ) {
    PlaylistListVM playlistListVM = Provider.of<PlaylistListVM>(
      context,
      listen: false,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Tooltip(
          message: AppLocalizations.of(context)!.resetSortFilterOptionsTooltip,
          child: IconButton(
            key: const Key('resetSortFilterOptionsIconButton'),
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _resetSortFilterOptions();
              });

              // now clicking on Enter works since the
              // Checkbox is not focused anymore
              _audioTitleSearchSentenceFocusNode.requestFocus();
            },
          ),
        ),
        _buildSaveOrApplyButton(
          playlistListVM: playlistListVM,
          themeProviderVM: themeProviderVM,
        ),
        Tooltip(
          message: (_sortFilterSaveAsUniqueName.isNotEmpty)
              ? AppLocalizations.of(context)!.deleteSortFilterOptionsTooltip
              : '',
          child: TextButton(
            key: const Key('deleteSortFilterTextButton'),
            onPressed: () {
              _audioSortFilterParameters =
                  _generateAudioSortFilterParametersFromDialogFields();

              if (_audioSortFilterParameters ==
                  AudioSortFilterParameters
                      .createDefaultAudioSortFilterParameters()) {
                // here, the user clicks on the Delete button without
                // having modified the sort/filter parameters. In this case,
                // the Default sort/filter parameters are not deleted.
                widget.warningMessageVM.noSortFilterParameterWasModified();

                // does not close the sort and filter dialog
                return;
              } else if (_sortFilterSaveAsUniqueName.isEmpty) {
                // here, the user deletes an historical sort/filter parameter
                if (!playlistListVM
                    .clearAudioSortFilterSettingsSearchHistoryElement(
                        _audioSortFilterParameters)) {
                  // here, the sort/filter parameter to delete was not present
                  // in the historical sort/filter parameters list
                  widget.warningMessageVM
                      .deletedHistoricalSortFilterParameterNotExist();

                  // does not close the sort and filter dialog
                  return;
                } else {
                  // here, the sort/filter parameter was present in the
                  // historical sort/filter parameters list and was deleted
                  ButtonStateManager buttonStateManager = ButtonStateManager(
                    minValue: 0,
                    maxValue: _historicalAudioSortFilterParametersLst.length
                            .toDouble() -
                        1.0,
                  );

                  _manageButtonsState(buttonStateManager);
                  widget.warningMessageVM
                      .historicalSortFilterParameterWasDeleted();

                  // does not close the sort and filter dialog
                  return;
                }
              } else {
                // here, the user deletes a saved with name sort/filter
                // parameter
                playlistListVM.deleteAudioSortFilterParameters(
                  audioSortFilterParametersName: _sortFilterSaveAsUniqueName,
                );

                // removing the deleted sort/filter parameters from the
                // sort/filter dialog
                setState(() {
                  _resetSortFilterOptions();
                });
              }

              Navigator.of(context).pop(['delete']);
            },
            child: Text(
              AppLocalizations.of(context)!.deleteShort,
              style: (themeProviderVM.currentTheme == AppTheme.dark)
                  ? kTextButtonStyleDarkMode
                  : kTextButtonStyleLightMode,
            ),
          ),
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

  /// Save button is displayed when the sort filter name is defined.
  /// If the sort filter name is empty, the Apply button is displayed.
  Widget _buildSaveOrApplyButton({
    required PlaylistListVM playlistListVM,
    required ThemeProviderVM themeProviderVM,
  }) {
    if (_sortFilterSaveAsUniqueName.isEmpty) {
      // In this situation, the user applies a sort/filter (mainly
      // a filter only) parameters without saving them. In this case,
      // the defined sort/filter parameters are added to the search
      // history list which is saved in the settings file.
      return Tooltip(
        message: AppLocalizations.of(context)!.applySortFilterOptionsTooltip,
        child: TextButton(
          key: const Key('applySortFilterOptionsTextButton'),
          onPressed: () {
            List<dynamic> filterSortAudioAndParmLst = _filterAndSortAudioLst(
                sortFilterParametersSaveAsUniqueName:
                    AppLocalizations.of(context)!
                        .sortFilterParametersAppliedName);

            if (filterSortAudioAndParmLst[1] ==
                AudioSortFilterParameters
                    .createDefaultAudioSortFilterParameters()) {
              widget.warningMessageVM.noSortFilterParameterWasModified();
              // does not close the sort and filter dialog
              return;
            }

            playlistListVM.addSearchHistoryAudioSortFilterParameters(
              audioSortFilterParameters: filterSortAudioAndParmLst[1],
            );

            _historicalAudioSortFilterParametersIndex++;

            Navigator.of(context).pop(filterSortAudioAndParmLst);
          },
          child: Text(
            AppLocalizations.of(context)!.applyButton,
            style: (themeProviderVM.currentTheme == AppTheme.dark)
                ? kTextButtonStyleDarkMode
                : kTextButtonStyleLightMode,
          ),
        ),
      );
    } else {
      // In this situation, the user saves the named sort/filter
      // parameters. In this case, the named sort/filter parameters are
      // added to the sort/filter list which is saved in the settings file.
      return Tooltip(
        message: AppLocalizations.of(context)!.saveSortFilterOptionsTooltip,
        child: TextButton(
          key: const Key('saveSortFilterOptionsTextButton'),
          onPressed: () {
            List<dynamic> filterSortAudioAndParmLst = _filterAndSortAudioLst(
              sortFilterParametersSaveAsUniqueName: _sortFilterSaveAsUniqueName,
            );
            playlistListVM.saveAudioSortFilterParameters(
              audioSortFilterParametersName: _sortFilterSaveAsUniqueName,
              audioSortFilterParameters: filterSortAudioAndParmLst[1],
            );

            Navigator.of(context).pop(filterSortAudioAndParmLst);
          },
          child: Text(
            AppLocalizations.of(context)!.saveButton,
            style: (themeProviderVM.currentTheme == AppTheme.dark)
                ? kTextButtonStyleDarkMode
                : kTextButtonStyleLightMode,
          ),
        ),
      );
    }
  }

  Column _buildAudioDurationFields(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.audioDurationRange),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLabelTextField(
              key: const Key('startAudioDurationTextField'),
              context: context,
              controller: _startAudioDurationController,
              label: AppLocalizations.of(context)!.start,
              labelSize: 43.0,
            ),
            const SizedBox(width: 10),
            _buildLabelTextField(
              key: const Key('endAudioDurationTextField'),
              context: context,
              controller: _endAudioDurationController,
              label: AppLocalizations.of(context)!.end,
              labelSize: 30.0,
            ),
          ],
        ),
      ],
    );
  }

  Column _buildAudioFileSizeFields(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.fileSizeRange),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLabelTextField(
              key: const Key('startFileSizeTextField'),
              context: context,
              controller: _startFileSizeController,
              label: AppLocalizations.of(context)!.start,
              labelSize: 43.0,
            ),
            const SizedBox(width: 10),
            _buildLabelTextField(
              key: const Key('endFileSizeTextField'),
              context: context,
              controller: _endFileSizeController,
              label: AppLocalizations.of(context)!.end,
              labelSize: 30.0,
            ),
          ],
        ),
      ],
    );
  }

  Row _buildLabelTextField({
    required Key key,
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required double labelSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: labelSize,
          child: Text(
            label,
            style: kDialogLabelStyle,
          ),
        ),
        SizedBox(
          width: 70,
          child: TextField(
            key: key,
            style: kDialogTextFieldStyle,
            decoration: _dialogTextFieldDecoration,
            controller: controller,
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioDateFields(
    BuildContext context,
    DateTime now,
  ) {
    return Column(
      children: [
        _buildLabelDateIconTextField(
          dateIconButtondKey: const Key('startDownloadDateIconButton'),
          textFieldKey: const Key('startDownloadDateTextField'),
          context: context,
          dateTimeType: DateTimeType.startDownloadDateTime,
          controller: _startDownloadDateTimeController,
          dateTime: _startDownloadDateTime,
          label: AppLocalizations.of(context)!.startDownloadDate,
        ),
        _buildLabelDateIconTextField(
          dateIconButtondKey: const Key('endDownloadDateIconButton'),
          textFieldKey: const Key('endDownloadDateTextField'),
          context: context,
          dateTimeType: DateTimeType.endDownloadDateTime,
          controller: _endDownloadDateTimeController,
          dateTime: _endDownloadDateTime,
          label: AppLocalizations.of(context)!.endDownloadDate,
        ),
        _buildLabelDateIconTextField(
          dateIconButtondKey: const Key('startUploadDateIconButton'),
          textFieldKey: const Key('startUploadDateTextField'),
          context: context,
          dateTimeType: DateTimeType.startUploadDateTime,
          controller: _startUploadDateTimeController,
          dateTime: _startUploadDateTime,
          label: AppLocalizations.of(context)!.startUploadDate,
        ),
        _buildLabelDateIconTextField(
          dateIconButtondKey: const Key('endUploadDateIconButton'),
          textFieldKey: const Key('endUploadDateTextField'),
          context: context,
          dateTimeType: DateTimeType.endUploadDateTime,
          controller: _endUploadDateTimeController,
          dateTime: _endUploadDateTime,
          label: AppLocalizations.of(context)!.endUploadDate,
        ),
      ],
    );
  }

  Row _buildLabelDateIconTextField({
    required Key dateIconButtondKey,
    required Key textFieldKey,
    required BuildContext context,
    required DateTimeType dateTimeType,
    required TextEditingController controller,
    required DateTime? dateTime,
    required String label,
  }) {
    // Initialize the TextField with the current date
    if (dateTime != null) {
      controller.text = frenchDateFormat.format(dateTime);
    }

    // Add listener to handle manual input
    controller.addListener(() {
      try {
        final parsedDate = DateFormat('dd/MM/yyyy').parse(controller.text);
        _setDateTime(
          dateTimeType: dateTimeType,
          dateTime: parsedDate,
        );
      } catch (e) {
        // If parsing fails, you can decide to show an error message or leave it
      }
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 84,
          child: Text(label),
        ),
        IconButton(
          key: dateIconButtondKey,
          style: ButtonStyle(
            // Highlight button when pressed
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(
                  horizontal: kSmallButtonInsidePadding, vertical: 0),
            ),
            overlayColor: iconButtonTapModification, // Tap feedback color
          ),
          icon: const Icon(Icons.calendar_month_rounded),
          onPressed: () async {
            // Parse the date from the TextField if it's valid, otherwise use the original date
            DateTime initialDate;
            try {
              initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
            } catch (e) {
              initialDate = dateTime ?? DateTime.now();
            }

            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              locale: const Locale(
                'en',
                'GB',
              ), // Set locale to use DD/MM/YYYY format
            );

            // Add this check
            _setDateTime(
              dateTimeType: dateTimeType,
              dateTime: pickedDate,
            );

            if (pickedDate != null) {
              controller.text = frenchDateFormat.format(pickedDate);
            }
          },
        ),
        SizedBox(
          width: 100,
          child: TextField(
            key: textFieldKey,
            style: kDialogTextFieldStyle,
            decoration: _dialogDateTextFieldDecoration,
            controller: controller,
            keyboardType: TextInputType
                .datetime, // Updated to datetime for better keyboard options
          ),
        ),
      ],
    );
  }

  void _setDateTime({
    required DateTimeType dateTimeType,
    DateTime? dateTime,
  }) {
    if (dateTime == null) {
      return;
    }

    switch (dateTimeType) {
      case DateTimeType.startDownloadDateTime:
        _startDownloadDateTime = dateTime;
        break;
      case DateTimeType.endDownloadDateTime:
        _endDownloadDateTime = AudioSortFilterService.setDateTimeToEndDay(
          date: dateTime,
        );
        break;
      case DateTimeType.startUploadDateTime:
        _startUploadDateTime = dateTime;
        break;
      case DateTimeType.endUploadDateTime:
        _endUploadDateTime = AudioSortFilterService.setDateTimeToEndDay(
          date: dateTime,
        );
        break;
    }
  }

  Widget _buildAudioStateCheckboxes(
    BuildContext context,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)!.audioMusicQuality),
            Checkbox(
              key: const Key('filterMusicQualityCheckbox'),
              value: _filterMusicQuality,
              onChanged: (bool? newValue) {
                setState(() {
                  _filterMusicQuality = newValue!;
                });

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context)!.fullyListened),
            Checkbox(
              key: const Key('filterFullyListenedCheckbox'),
              value: _filterFullyListened,
              onChanged: (bool? newValue) {
                setState(() {
                  _filterFullyListened = newValue!;
                });

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context)!.partiallyListened),
            Checkbox(
              key: const Key('filterPartiallyListenedCheckbox'),
              value: _filterPartiallyListened,
              onChanged: (bool? newValue) {
                setState(() {
                  _filterPartiallyListened = newValue!;
                });

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
          ],
        ),
        Row(
          children: [
            Text(AppLocalizations.of(context)!.notListened),
            Checkbox(
              key: const Key('filterNotListenedCheckbox'),
              value: _filterNotListened,
              onChanged: (bool? newValue) {
                setState(() {
                  _filterNotListened = newValue!;
                });

                // now clicking on Enter works since the
                // Checkbox is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
          ],
        ),
      ],
    );
  }

  void _modifySearchInYoutubeChannelNameCheckbox(bool? newValue) {
    _searchInYoutubeChannelName = newValue!;

    // now clicking on Enter works since the
    // Checkbox is not focused anymore
    _audioTitleSearchSentenceFocusNode.requestFocus();
  }

  void _modifySearchInVideoCompactDescriptionCheckbox(bool? newValue) {
    _searchInVideoCompactDescription = newValue!;

    // now clicking on Enter works since the
    // Checkbox is not focused anymore
    _audioTitleSearchSentenceFocusNode.requestFocus();
  }

  void _modifyIgnoreCaseCheckBox(bool? newValue) {
    _ignoreCase = newValue!;

    // now clicking on Enter works since the
    // Checkbox is not focused anymore
    _audioTitleSearchSentenceFocusNode.requestFocus();
  }

  SizedBox _buildAudioFilterSentencesLst(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
        itemCount: _audioTitleFilterSentencesLst.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_audioTitleFilterSentencesLst[index]),
            trailing: IconButton(
              key: const Key('removeSentenceIconButton'),
              style: ButtonStyle(
                // Highlight button when pressed
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(
                      horizontal: kSmallButtonInsidePadding, vertical: 0),
                ),
                overlayColor: iconButtonTapModification, // Tap feedback color
              ),
              icon: const Icon(Icons.clear),
              onPressed: () {
                _audioTitleFilterSentencesLst[index].isNotEmpty
                    ? setState(() {
                        _audioTitleFilterSentencesLst.removeAt(index);
                      })
                    : null; // required in order to be able to test if the
                //             IconButton is disabled or not

                // now clicking on Enter works since the
                // IconButton is not focused anymore
                _audioTitleSearchSentenceFocusNode.requestFocus();
              },
            ),
          );
        },
      ),
    );
  }

  Row _buildFilterOptionTitleSearchHistoryButtons(
    BuildContext context,
  ) {
    ButtonStateManager buttonStateManager = ButtonStateManager(
      minValue: 0,
      maxValue: _historicalAudioSortFilterParametersLst.length.toDouble() - 1.0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.filterOptions,
          style: kDialogTitlesStyle,
        ),
        SizedBox(
          width: kSmallestButtonWidth,
          child: IconButton(
            key: const Key('search_history_arrow_left_button'),
            onPressed: _historicalAudioSortFilterParametersIndex > 0
                ? () => tapSearchHistoryLeftArrowIconButton(buttonStateManager)
                : null, // required in order to be able to test if the
            //             IconButton is disabled or not
            padding: const EdgeInsets.all(0),
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: Icon(
              Icons.arrow_left,
              size: kUpDownButtonSize,
              color: _historicalAudioSortFilterParamsLeftIconColor,
            ),
          ),
        ),
        SizedBox(
          width: kSmallestButtonWidth,
          child: IconButton(
            key: const Key('search_history_arrow_right_button'),
            onPressed: _historicalAudioSortFilterParametersIndex <
                    _historicalAudioSortFilterParametersLst.length - 1
                ? () => tapSearchHistoryRightArrowIconButton(buttonStateManager)
                : null, // required in order to be able to test if the
            //             IconButton is disabled or not
            padding: const EdgeInsets.all(0),
            style: ButtonStyle(
              // Highlight button when pressed
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(
                    horizontal: kSmallButtonInsidePadding, vertical: 0),
              ),
              overlayColor: iconButtonTapModification, // Tap feedback color
            ),
            icon: Icon(
              Icons.arrow_right,
              size: kUpDownButtonSize,
              color: _historicalAudioSortFilterParamsRightIconColor,
            ),
          ),
        ),
        SizedBox(
          width: kSmallestButtonWidth,
          child: Tooltip(
            message: AppLocalizations.of(context)!
                .clearSortFilterAudiosParmsHistoryMenu,
            child: IconButton(
              key: const Key('search_history_delete_all_button'),
              onPressed: _historicalAudioSortFilterParametersLst.isNotEmpty
                  ? () =>
                      _tapSearchHistoryDeleteAllIconButton(buttonStateManager)
                  : null, // required in order to be able to test if the
              //             IconButton is disabled or not
              padding: const EdgeInsets.all(0),
              style: ButtonStyle(
                // Highlight button when pressed
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(
                      horizontal: kSmallButtonInsidePadding, vertical: 0),
                ),
                overlayColor: iconButtonTapModification, // Tap feedback color
              ),
              icon: Icon(
                Icons.delete,
                size: kUpDownButtonSize / 2,
                color: _historicalAudioSortFilterParamsDeleteIconColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void tapSearchHistoryLeftArrowIconButton(
      ButtonStateManager buttonStateManager) {
    if (_historicalAudioSortFilterParametersIndex > 0) {
      // at dialog opening, _historicalAudioSortFilterParametersIndex
      // was initialized to the list length - 1
      AudioSortFilterParameters audioSortFilterParameters =
          _historicalAudioSortFilterParametersLst[
              _historicalAudioSortFilterParametersIndex - 1];

      _setSortFilterOptions(audioSortFilterParameters);
    }

    _historicalAudioSortFilterParametersIndex--;

    _manageButtonsState(buttonStateManager);
    _historicalAudioSortFilterParametersIndex;
    setState(() {});
  }

  void tapSearchHistoryRightArrowIconButton(
    ButtonStateManager buttonStateManager,
  ) {
    if (_historicalAudioSortFilterParametersIndex <
        _historicalAudioSortFilterParametersLst.length - 1) {
      AudioSortFilterParameters audioSortFilterParameters =
          _historicalAudioSortFilterParametersLst[
              _historicalAudioSortFilterParametersIndex + 1];

      _setSortFilterOptions(audioSortFilterParameters);
    }

    _historicalAudioSortFilterParametersIndex++;

    _manageButtonsState(buttonStateManager);
    setState(() {});
  }

  void _tapSearchHistoryDeleteAllIconButton(
    ButtonStateManager buttonStateManager,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmActionDialog(
          actionFunction: _clearAudioSortFilterSettingsSearchHistory,
          actionFunctionArgs: [
            Provider.of<PlaylistListVM>(context, listen: false),
            buttonStateManager,
          ],
          dialogTitle: AppLocalizations.of(context)!
              .clearSortFilterAudiosParmsHistoryMenu,
          dialogContent: AppLocalizations.of(context)!
              .allHistoricalSortFilterParametersDeleteConfirmation,
        );
      },
    );
  }

  void _clearAudioSortFilterSettingsSearchHistory(
    PlaylistListVM playlistListVM,
    ButtonStateManager buttonStateManager,
  ) {
    playlistListVM.clearAudioSortFilterSettingsSearchHistory();
    _historicalAudioSortFilterParametersLst.clear();
    _historicalAudioSortFilterParametersIndex =
        0; // fixes a bug found during integration testing
    _manageButtonsState(buttonStateManager);
    setState(() {});
  }

  void _manageButtonsState(
    ButtonStateManager buttonStateManager,
  ) {
    List<bool> historicalAudioSortFilterButtonsState =
        buttonStateManager.getTwoButtonsState(
      _historicalAudioSortFilterParametersIndex.toDouble(),
    );

    if (historicalAudioSortFilterButtonsState[0]) {
      _historicalAudioSortFilterParamsLeftIconColor =
          kDarkAndLightEnabledIconColor;
    } else {
      _historicalAudioSortFilterParamsLeftIconColor =
          kDarkAndLightDisabledIconColor;
    }
    if (historicalAudioSortFilterButtonsState[1]) {
      _historicalAudioSortFilterParamsRightIconColor =
          kDarkAndLightEnabledIconColor;
    } else {
      _historicalAudioSortFilterParamsRightIconColor =
          kDarkAndLightDisabledIconColor;
    }

    if (_historicalAudioSortFilterParametersLst.isNotEmpty) {
      _historicalAudioSortFilterParamsDeleteIconColor =
          kDarkAndLightEnabledIconColor;
    } else {
      _historicalAudioSortFilterParamsDeleteIconColor =
          kDarkAndLightDisabledIconColor;
    }
  }

  // This method defines the TextField used to add a word or sentence
  // applied to filter the audio based on their title or description.
  Widget _buildAudioFilterSentence() {
    return Tooltip(
      message: AppLocalizations.of(context)!
          .audioTitleSearchSentenceTextFieldTooltip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.videoTitleOrDescription,
          ),
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            height: kDialogTextFieldHeight,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    key: const Key('audioTitleSearchSentenceTextField'),
                    focusNode: _audioTitleSearchSentenceFocusNode,
                    style: kDialogTextFieldStyle,
                    decoration: _dialogTextFieldDecoration,
                    controller: _audioTitleSearchSentenceController,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      _audioTitleSearchSentence = value.trim();
                      // setting the Add button color according to the
                      // TextField content ...
                      _audioTitleSearchSentenceAddButtonIconColor =
                          _audioTitleSearchSentence.isNotEmpty
                              ? kDarkAndLightEnabledIconColor
                              : kDarkAndLightDisabledIconColor;

                      setState(() {}); // necessary to update Add button color
                    },
                  ),
                ),
                SizedBox(
                  width: kSmallIconButtonWidth,
                  child: IconButton(
                    key: const Key('addSentenceIconButton'),
                    onPressed: _audioTitleSearchSentence != ''
                        ? () async => setState(() {
                              _addSentenceToFilterSentencesLst();
                            })
                        : null,
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
                      Icons.add,
                      // since in the Dialog the disabled IconButton color
                      // is not grey, we need to set it manually. Additionally,
                      // the sentence TextField onChanged callback must execute
                      // setState() to update the IconButton color
                      color: _audioTitleSearchSentenceAddButtonIconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addSentenceToFilterSentencesLst() {
    if (!_audioTitleFilterSentencesLst.contains(_audioTitleSearchSentence)) {
      _audioTitleFilterSentencesLst.add(_audioTitleSearchSentence);
      _audioTitleSearchSentence = '';
      _audioTitleSearchSentenceController.clear();

      // reset the Plus button color to disabled color
      // since the TextField is now empty
      _audioTitleSearchSentenceAddButtonIconColor =
          kDarkAndLightDisabledIconColor;
    }

    // now clicking on Enter works since the
    // IconButton is not focused anymore
    _audioTitleSearchSentenceFocusNode.requestFocus();
  }

  /// The method builds the list of sorting options
  /// choosen by the user.
  SizedBox _buildSelectedSortingOptionsList() {
    return SizedBox(
      // Required to solve the error RenderBox was
      // not laid out: RenderPhysicalShape#ee087
      // relayoutBoundary=up2 'package:flutter/src/
      // rendering/box.dart':
      width: double.maxFinite,
      child: ListView.builder(
        key: const Key('selectedSortingOptionsListView'),
        // controller: _scrollController,
        itemCount: _selectedSortingItemLst.length,
        shrinkWrap: true,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          return ListTile(
            title: Text(
              _sortingOptionToString(
                _selectedSortingItemLst[index].sortingOption,
                context,
              ),
              style: const TextStyle(fontSize: kDropdownMenuItemFontSize),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: kSmallIconButtonWidth,
                  child: Tooltip(
                    message: AppLocalizations.of(context)!
                        .clickToSetAscendingOrDescendingTooltip,
                    child: IconButton(
                      key: const Key('sort_ascending_or_descending_button'),
                      onPressed: () {
                        setState(() {
                          bool isAscending =
                              _selectedSortingItemLst[index].isAscending;
                          _selectedSortingItemLst[index].isAscending =
                              !isAscending; // Toggle the sorting state
                        });
                      },
                      style: ButtonStyle(
                        // Highlight button when pressed
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.symmetric(
                              horizontal: kSmallButtonInsidePadding,
                              vertical: 0),
                        ),
                        overlayColor:
                            iconButtonTapModification, // Tap feedback color
                      ),
                      icon: Icon(
                        _selectedSortingItemLst[index].isAscending
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down, // Conditional icon
                        size: kUpDownButtonSize,
                        color: kDarkAndLightEnabledIconColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: kSmallIconButtonWidth,
                  child: IconButton(
                    key: const Key('removeSortingOptionIconButton'),
                    onPressed: _selectedSortingItemLst.length != 1
                        ? () => setState(() {
                              if (_selectedSortingItemLst.length > 1) {
                                _selectedSortingItemLst.removeAt(index);
                              }

                              if (_selectedSortingItemLst.length > 1) {
                                _audioSortOptionButtonIconColor =
                                    kDarkAndLightEnabledIconColor;
                              } else {
                                _audioSortOptionButtonIconColor =
                                    kDarkAndLightDisabledIconColor;
                              }
                            })
                        : null,
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
                      color: _audioSortOptionButtonIconColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortingChoiceList(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      child: DropdownButton<SortingOption>(
        key: const Key('sortingOptionDropdownButton'),
        value: SortingOption.audioDownloadDate,
        onChanged: (SortingOption? newValue) {
          // situation when the user selects a sorting option
          setState(() {
            if (!_selectedSortingItemLst
                .any((sortingItem) => sortingItem.sortingOption == newValue)) {
              _selectedSortingItemLst.add(SortingItem(
                sortingOption: newValue!,
                isAscending: AudioSortFilterService.getDefaultSortOptionOrder(
                  sortingOption: newValue,
                ),
              ));
              // since _selectedSortingItemLst must contain at least one
              // element, now the _selectedSortingItemLst has more than
              // one element, the delete IconButton color is set to the
              // enabled color
              _audioSortOptionButtonIconColor = kDarkAndLightEnabledIconColor;
            }
          });
        },
        items: _buildListOfSortingOptionDropdownMenuItems(context),
      ),
    );
  }

  /// The returned list of DropdownMenuItem<SortingOption> is based on the
  /// app view type. Most sorting options are excluded for the Audio Player
  /// View.
  ///
  /// This code first filters out the SortingOption values that should not
  /// be included when widget.audioLearnAppViewType is AudioLearnAppViewType.
  /// audioPlayerView using .where(), and then maps over the filtered list
  /// to create DropdownMenuItem<SortingOption> widgets. This approach
  /// ensures that you only include the relevant options in your
  /// DropdownButton.
  List<DropdownMenuItem<SortingOption>>
      _buildListOfSortingOptionDropdownMenuItems(
    BuildContext context,
  ) {
    return SortingOption.values.where((SortingOption value) {
      // Exclude certain options based on the app view type
      return (widget.audioLearnAppViewType ==
              AudioLearnAppViewType.playlistDownloadView)
          ?
          // SortingOption excluded when the sort/filter dialog
          // is opened in the playlist download view.
          //
          // Excluding the audio enclosing playlist title option
          // since currently the audio of only one playlist are
          // displayed in the playlist download view. So, sorting
          // by playlist title is not relevant.
          !(value == SortingOption.audioEnclosingPlaylistTitle)
          :
          // SortingOption's excluded when the sort/filter dialog
          // is opened in the audio play view
          //
          // Excluding the audio enclosing playlist title option
          // since currently the audio of only one playlist are
          // displayed in the playlist download view. So, sorting
          // by playlist title is not relevant.
          !(value == SortingOption.audioEnclosingPlaylistTitle ||
              value == SortingOption.audioDownloadSpeed ||
              value == SortingOption.audioDownloadDuration ||
              value == SortingOption.audioFileSize);
    }).map<DropdownMenuItem<SortingOption>>((SortingOption value) {
      return DropdownMenuItem<SortingOption>(
        value: value,
        child: SizedBox(
          child: Text(
            _sortingOptionToString(value, context),
            style: const TextStyle(fontSize: kDropdownMenuItemFontSize),
            maxLines: 2,
          ),
        ),
      );
    }).toList();
  }

  void _toggleCheckboxAnd(bool? value) {
    setState(() {
      _isAnd = !_isAnd;
      // When checkbox 1 is checked, ensure checkbox 2 is unchecked
      if (_isAnd) _isOr = false;
    });
  }

  void _toggleCheckboxOr(bool? value) {
    setState(() {
      _isOr = !_isOr;
      // When checkbox 2 is checked, ensure checkbox 1 is unchecked
      if (_isOr) _isAnd = false;
    });
  }

  /// Method called when the user clicks on the 'Save' or 'Apply'
  /// button.
  ///
  /// The method filters and sorts the audio list based on the selected
  /// sorting and filtering options. The method returns a list of three
  /// elements:
  /// 1/ the filtered and sorted selected playlist audio list
  /// 2/ the audio sort filter parameters (AudioSortFilterParameters)
  /// 3/ the sort filter parameters save as unique name
  List<dynamic> _filterAndSortAudioLst({
    required String sortFilterParametersSaveAsUniqueName,
  }) {
    _audioSortFilterParameters =
        _generateAudioSortFilterParametersFromDialogFields();

    List<Audio> filteredAndSortedAudioLst =
        _audioSortFilterService.filterAndSortAudioLst(
      audioLst: widget.selectedPlaylistAudioLst,
      audioSortFilterParameters: _audioSortFilterParameters,
    );

    return [
      filteredAndSortedAudioLst,
      _audioSortFilterParameters,
      sortFilterParametersSaveAsUniqueName,
    ];
  }

  AudioSortFilterParameters
      _generateAudioSortFilterParametersFromDialogFields() {
    String startFileSizeTxt = _startFileSizeController.text;
    String endFileSizeTxt = _endFileSizeController.text;
    String startAudioDurationTxt = _startAudioDurationController.text;
    String endAudioDurationTxt = _endAudioDurationController.text;

    double fileSizeEndRangeMB = AudioSortFilterService.increaseByMinimumUnit(
      endValueTxt: endFileSizeTxt,
    );

    return AudioSortFilterParameters(
      selectedSortItemLst: _selectedSortingItemLst,
      filterSentenceLst: _audioTitleFilterSentencesLst,
      sentencesCombination:
          (_isAnd) ? SentencesCombination.AND : SentencesCombination.OR,
      ignoreCase: _ignoreCase,
      searchAsWellInYoutubeChannelName: _searchInYoutubeChannelName,
      searchAsWellInVideoCompactDescription: _searchInVideoCompactDescription,
      filterMusicQuality: _filterMusicQuality,
      filterFullyListened: _filterFullyListened,
      filterPartiallyListened: _filterPartiallyListened,
      filterNotListened: _filterNotListened,
      downloadDateStartRange: _startDownloadDateTime,
      downloadDateEndRange: _endDownloadDateTime,
      uploadDateStartRange: _startUploadDateTime,
      uploadDateEndRange: _endUploadDateTime,
      fileSizeStartRangeMB: double.tryParse(startFileSizeTxt) ?? 0.0,
      fileSizeEndRangeMB: fileSizeEndRangeMB,
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
  get sortingOptionLst => _sortingOptionLst;

  final String _videoTitleAndDescriptionSearchWords;
  get videoTitleAndDescriptionSearchWords =>
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
