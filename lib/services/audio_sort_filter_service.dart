import 'dart:math';

import 'package:audiolearn/models/comment.dart';
import 'package:audiolearn/utils/date_time_util.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';
import '../models/audio.dart';
import '../models/playlist.dart';
import '../utils/dir_util.dart';
import '../viewmodels/date_format_vm.dart';
import 'sort_filter_parameters.dart';

enum SortFilterParmsVersion {
  versionOne,
  versionTwo,
}

class AudioSortFilterService {
  /// Method called by filterAndSortAudioLst(). This method is used
  /// to sort the audio list by the given sorting items contained in
  /// passed selectedSortItemLst. A SortingItem associates a SortingOption
  /// with a boolean indicating if the sorting is ascending or descending.
  ///
  /// Not private in order to be tested.
  List<Audio> sortAudioLstBySortingOptions({
    required List<Audio> audioLst,
    required List<SortingItem> selectedSortItemLst,
  }) {
    // Create a list of SortCriteria's corresponding to the list of
    // selected sorting items coming from the AudioSortFilterDialog
    // or from the PlaylistListVM method which applies sort filter parameters
    // to return the playable audio of a playlist. This method is
    // getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters().
    //
    // The selectedSortItemLst is a list of SortingItem objects. Each
    // SortingItem object contains a SortingOption and a boolean indicating
    // if the sorting is ascending or descending. The SortCriteria object
    // is a static object that is used to sort the audio list. The SortCriteria
    // object contains a selector function that selects the field of the audio
    // object to sort on and a sortOrder parameter that indicates if the sorting
    // is ascending or descending.
    //
    // The SortCriteria in relation to the UI SortingItem is the SortCriteria
    // corresponding to the SortingItem SortingOption.
    List<SortCriteria<Audio>> copiedSortCriteriaLst =
        selectedSortItemLst.map((sortingItem) {
      // it is hyper important to copy the SortCriteria's because
      // the sortCriteriaForSortingOptionMap is a static map and
      // we don't want to modify its objects, as it is done in the
      // next instruction. If we don't copy the SortCriteria's, the
      // next instruction will modify the sortOrder parameter of
      // the objects in the map and the next time we will use the map,
      // those static objects will have been modified.
      SortCriteria<Audio> sortCriteriaCopy = AudioSortFilterParameters
          .sortCriteriaForSortingOptionMap[sortingItem.sortingOption]!
          .copy();

      sortCriteriaCopy.sortOrder =
          sortingItem.isAscending ? sortAscending : sortDescending;

      return sortCriteriaCopy;
    }).toList();

    // Sorting the audio list by applying the SortCriteria of the
    // sortCriteriaLst
    audioLst.sort((a, b) {
      for (SortCriteria<Audio> copiedSortCriteria in copiedSortCriteriaLst) {
        dynamic comparableA = copiedSortCriteria.selectorFunction(a);
        dynamic comparableB = copiedSortCriteria.selectorFunction(b);
        int comparison;

        if (comparableA.runtimeType == comparableB.runtimeType) {
          // sortOrder is 1 for ascending and -1 for descending
          comparison =
              comparableA.compareTo(comparableB) * copiedSortCriteria.sortOrder;
        } else {
          // the possibility that the two comparable objects are not of
          // the same type can happen only when the sorting option is
          // SortingOption.chapterAudioTitle. In this case, the selector
          // function is coded to compare titles containing a chapter
          // number, the case for audio files representing audio book
          // chapters which were imported. If the titles of downloaded
          // audio's are compared and two titles, one containing a chapter
          // number and the other containing no number, are compared, in
          // order to avoid compareTo exception, the title strings are
          // compared instead of the chapter number.
          //
          // Problem example: "EMI  - Un athée voyage au paradis et découvre
          // la vérité - Expérience de mort imminente" and "Expérience de mort
          // imminente (EMI)  - je reviens de l'au-delà (1_2 ) _ RTS"
          comparison = a.validVideoTitle.compareTo(b.validVideoTitle) *
              copiedSortCriteria.sortOrder;
        }

        if (comparison != 0) {
          return comparison;
        }
      }

      return 0;
    });

    return audioLst;
  }

  List<String> _sortAudioFileNamesLstBySortingOptions({
    required List<String> audioFileNamesLst,
    required List<SortingItem> selectedSortItemLst,
  }) {
    // Create a list of SortCriteria's corresponding to the list of
    // selected sorting items coming from the AudioSortFilterDialog
    // or from the PlaylistListVM method which applies sort filter parameters
    // to return the playable audio of a playlist. This method is
    // getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters().
    //
    // The selectedSortItemLst is a list of SortingItem objects. Each
    // SortingItem object contains a SortingOption and a boolean indicating
    // if the sorting is ascending or descending. The SortCriteria object
    // is a static object that is used to sort the audio list. The SortCriteria
    // object contains a selector function that selects the field of the audio
    // object to sort on and a sortOrder parameter that indicates if the sorting
    // is ascending or descending.
    //
    // The SortCriteria in relation to the UI SortingItem is the SortCriteria
    // corresponding to the SortingItem SortingOption.
    List<SortCriteria<String>> sortCriteriaLst = [
      SortCriteria<String>(
        selectorFunction: (String audioFileName) {
          final regex = RegExp(r'(\d+)_\d+');

          String audioFileNameLow = audioFileName.toLowerCase();

          RegExpMatch? firstMatch = regex.firstMatch(audioFileNameLow);

          if (firstMatch != null) {
            int firstMatchInt = int.parse(firstMatch.group(1)!);

            return firstMatchInt;
          }

          return audioFileNameLow;
        },
        sortOrder: sortAscending,
      ),
    ];

    // Sorting the audio file name list by applying the SortCriteria
    // of the sortCriteriaLst
    audioFileNamesLst.sort((a, b) {
      for (SortCriteria<String> sortCriteria in sortCriteriaLst) {
        int comparison = sortCriteria
                .selectorFunction(a)
                .compareTo(sortCriteria.selectorFunction(b)) *
            sortCriteria.sortOrder;
        if (comparison != 0) return comparison;
      }
      return 0;
    });

    return audioFileNamesLst;
  }

  static bool getDefaultSortOptionOrder({
    required SortingOption sortingOption,
  }) {
    return AudioSortFilterParameters
            .sortCriteriaForSortingOptionMap[sortingOption]!.sortOrder ==
        sortAscending;
  }

  /// Method called by the AudioSortFilterDialog when the user clicks
  /// on the 'Save' or 'Apply' button. The method is also called by the
  /// PlaylistVm getSelectedPlaylistPlayableAudiosApplyingSortFilterParameters()
  /// method.
  ///
  /// This method filters and sorts the audio list according to the passed
  /// AudioSortFilterParameters. It is more efficient to filter the audio
  /// list first and then sort it than the contrary !
  List<Audio> filterAndSortAudioLst({
    required Playlist? selectedPlaylist,
    required List<Audio> audioLst,
    required AudioSortFilterParameters audioSortFilterParameters,
  }) {
    List<Audio> audioLstCopy = List<Audio>.from(audioLst);
    List<String> filterSentenceLst =
        audioSortFilterParameters.filterSentenceLst;

    if (filterSentenceLst.isNotEmpty) {
      audioLstCopy = filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions(
        audioLst: audioLstCopy,
        filterSentenceLst: filterSentenceLst,
        sentencesCombination: audioSortFilterParameters.sentencesCombination,
        ignoreCase: audioSortFilterParameters.ignoreCase,
        searchAsWellInVideoCompactDescription:
            audioSortFilterParameters.searchAsWellInVideoCompactDescription,
        searchAsWellInYoutubeChannelName:
            audioSortFilterParameters.searchAsWellInYoutubeChannelName,
      );
    }

    audioLstCopy = filterOnOtherOptions(
      selectedPlaylist: selectedPlaylist,
      audioLst: audioLstCopy,
      audioSortFilterParameters: audioSortFilterParameters,
    );

    return sortAudioLstBySortingOptions(
      audioLst: audioLstCopy,
      selectedSortItemLst: audioSortFilterParameters.selectedSortItemLst,
    );
  }

  /// Method not used !
  List<String> sortAudioFileNamesLst({
    required List<String> audioFileNamesLst,
    required AudioSortFilterParameters audioSortFilterParameters,
  }) {
    List<String> audioFileNamesLstCopy = List<String>.from(audioFileNamesLst);

    return _sortAudioFileNamesLstBySortingOptions(
      audioFileNamesLst: audioFileNamesLstCopy,
      selectedSortItemLst: audioSortFilterParameters.selectedSortItemLst,
    );
  }

  /// Method called by the AudioSortFilterDialog if the user clicks on the 'Save'
  /// button in order to save a sort/filter parameters with a name already used.
  /// This situation happens if the user creates a new sort/filter parameters and
  /// names it with a name already used for an existing sort/filter parameters or
  /// if the user modifies an existing sort/filter parameters and saves it with the
  /// same name.
  ///
  /// This method returns a list of differences between the existing sort/filter
  /// parameters and the new or modified sort/filter parameters. The differences
  /// are returned as a list of translated strings which will be used to inform
  /// the user about the differences between the two sort/filter parameters.
  ///
  /// The advantage of this method is to eventually prevent modifying a sort/filter
  /// parameters used in existing playlists.
  List<String> getListOfDifferencesBetweenSortFilterParameters({
    required DateFormatVM dateFormatVMlistenFalse,
    required AudioSortFilterParameters existingAudioSortFilterParms,
    required AudioSortFilterParameters newOrModifiedaudioSortFilterParms,
    required Map<String, String> sortFilterParmsNameTranslationMap,
  }) {
    List<String> differencesLst = [];

    if (existingAudioSortFilterParms == newOrModifiedaudioSortFilterParms) {
      return []; // No differences
    }

    // Compare selectedSortItemLst, the list containing the audio
    // sorting options, and include the asc or desc order
    if (!listEquals(existingAudioSortFilterParms.selectedSortItemLst,
        newOrModifiedaudioSortFilterParms.selectedSortItemLst)) {
      differencesLst.add(
          sortFilterParmsNameTranslationMap['selectedSortItemLstTitle'] ??
              'selectedSortItemLstTitle'); // add Sort by: title

      // Add specific differences between the lists
      Map<SortFilterParmsVersion, List<SortingItem>> sortDifferencesMap =
          getSortItemsDifferences(
        existingAudioSortFilterParms.selectedSortItemLst,
        newOrModifiedaudioSortFilterParms.selectedSortItemLst,
      );

      if (sortDifferencesMap[SortFilterParmsVersion.versionOne]!.isNotEmpty) {
        _addTranslatedSortFilterParmsNamePlusSortOrder(
          listDiff: sortDifferencesMap,
          listDiffKey: SortFilterParmsVersion.versionOne,
          sortFilterParmsNameTranslationMap: sortFilterParmsNameTranslationMap,
          differencesLst: differencesLst,
        );
      }

      if (sortDifferencesMap[SortFilterParmsVersion.versionTwo]!.isNotEmpty) {
        _addTranslatedSortFilterParmsNamePlusSortOrder(
          listDiff: sortDifferencesMap,
          listDiffKey: SortFilterParmsVersion.versionTwo,
          sortFilterParmsNameTranslationMap: sortFilterParmsNameTranslationMap,
          differencesLst: differencesLst,
        );
      }
    }

    // Compare filterSentenceLst and include specific differences
    if (!listEquals(existingAudioSortFilterParms.filterSentenceLst,
        newOrModifiedaudioSortFilterParms.filterSentenceLst)) {
      differencesLst.add(
          sortFilterParmsNameTranslationMap['filterSentenceLstTitle'] ??
              'filterSentenceLstTitle'); // add Filter words: title

      // Add specific differences between the lists
      Map<SortFilterParmsVersion, List<String>> sentenceDifferencesMap =
          getFilterSentencesDifferences(
        existingAudioSortFilterParms.filterSentenceLst,
        newOrModifiedaudioSortFilterParms.filterSentenceLst,
      );

      if (sentenceDifferencesMap[SortFilterParmsVersion.versionOne]!
          .isNotEmpty) {
        String presentOnlyInFirstTitle =
            sortFilterParmsNameTranslationMap['presentOnlyInFirstTitle'] ??
                'presentOnlyInFirstTitle';
        differencesLst.add(presentOnlyInFirstTitle);
        differencesLst.add(
            sentenceDifferencesMap[SortFilterParmsVersion.versionOne]!
                .join(', '));
      }

      if (sentenceDifferencesMap[SortFilterParmsVersion.versionTwo]!
          .isNotEmpty) {
        String presentOnlyInSecondTitle =
            sortFilterParmsNameTranslationMap['presentOnlyInSecondTitle'] ??
                'presentOnlyInSecondTitle';
        differencesLst.add(presentOnlyInSecondTitle);
        differencesLst.add(
            sentenceDifferencesMap[SortFilterParmsVersion.versionTwo]!
                .join(', '));
      }
    }

    bool wasFilterOptionsTitleAddedToDifferencesLst = false;

    // Compare other fields
    if (existingAudioSortFilterParms.sentencesCombination !=
        newOrModifiedaudioSortFilterParms.sentencesCombination) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionDisplayedStr(
              initialValueStr: existingAudioSortFilterParms.sentencesCombination
                  .toString()
                  .split('.')
                  .last,
              modifiedValueStr: newOrModifiedaudioSortFilterParms
                  .sentencesCombination
                  .toString()
                  .split('.')
                  .last,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'sentencesCombination',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst,
              isValueTranslated: true);
    }
    if (existingAudioSortFilterParms.ignoreCase !=
        newOrModifiedaudioSortFilterParms.ignoreCase) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionCheckboxValueStr(
              initialCheckBoxState: existingAudioSortFilterParms.ignoreCase,
              modifiedCheckBoxState:
                  newOrModifiedaudioSortFilterParms.ignoreCase,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'ignoreCase',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.searchAsWellInYoutubeChannelName !=
        newOrModifiedaudioSortFilterParms.searchAsWellInYoutubeChannelName) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionCheckboxValueStr(
              initialCheckBoxState:
                  existingAudioSortFilterParms.searchAsWellInYoutubeChannelName,
              modifiedCheckBoxState: newOrModifiedaudioSortFilterParms
                  .searchAsWellInYoutubeChannelName,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'searchAsWellInYoutubeChannelName',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.filterMusicQuality !=
        newOrModifiedaudioSortFilterParms.filterMusicQuality) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionCheckboxValueStr(
              initialCheckBoxState:
                  existingAudioSortFilterParms.filterMusicQuality,
              modifiedCheckBoxState:
                  newOrModifiedaudioSortFilterParms.filterMusicQuality,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'filterMusicQuality',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.filterFullyListened !=
        newOrModifiedaudioSortFilterParms.filterFullyListened) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionCheckboxValueStr(
              initialCheckBoxState:
                  existingAudioSortFilterParms.filterFullyListened,
              modifiedCheckBoxState:
                  newOrModifiedaudioSortFilterParms.filterFullyListened,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'filterFullyListened',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.filterPartiallyListened !=
        newOrModifiedaudioSortFilterParms.filterPartiallyListened) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionCheckboxValueStr(
              initialCheckBoxState:
                  existingAudioSortFilterParms.filterPartiallyListened,
              modifiedCheckBoxState:
                  newOrModifiedaudioSortFilterParms.filterPartiallyListened,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'filterPartiallyListened',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.filterNotListened !=
        newOrModifiedaudioSortFilterParms.filterNotListened) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionCheckboxValueStr(
              initialCheckBoxState:
                  existingAudioSortFilterParms.filterNotListened,
              modifiedCheckBoxState:
                  newOrModifiedaudioSortFilterParms.filterNotListened,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'filterNotListened',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.filterCommented !=
        newOrModifiedaudioSortFilterParms.filterCommented) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionCheckboxValueStr(
              initialCheckBoxState:
                  existingAudioSortFilterParms.filterCommented,
              modifiedCheckBoxState:
                  newOrModifiedaudioSortFilterParms.filterCommented,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'filterCommented',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.filterNotCommented !=
        newOrModifiedaudioSortFilterParms.filterNotCommented) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionCheckboxValueStr(
              initialCheckBoxState:
                  existingAudioSortFilterParms.filterNotCommented,
              modifiedCheckBoxState:
                  newOrModifiedaudioSortFilterParms.filterNotCommented,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'filterNotCommented',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }

    if (existingAudioSortFilterParms.filterPictured !=
        newOrModifiedaudioSortFilterParms.filterPictured) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionCheckboxValueStr(
              initialCheckBoxState: existingAudioSortFilterParms.filterPictured,
              modifiedCheckBoxState:
                  newOrModifiedaudioSortFilterParms.filterPictured,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'filterPictured',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.filterNotPictured !=
        newOrModifiedaudioSortFilterParms.filterNotPictured) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionCheckboxValueStr(
              initialCheckBoxState:
                  existingAudioSortFilterParms.filterNotPictured,
              modifiedCheckBoxState:
                  newOrModifiedaudioSortFilterParms.filterNotPictured,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'filterNotPictured',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }

    if (existingAudioSortFilterParms.downloadDateStartRange !=
        newOrModifiedaudioSortFilterParms.downloadDateStartRange) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionDateValueStr(
              dateFormatVMlistenFalse: dateFormatVMlistenFalse,
              initialDateTimeValue:
                  existingAudioSortFilterParms.downloadDateStartRange,
              modifiedDateTimeValue:
                  newOrModifiedaudioSortFilterParms.downloadDateStartRange,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'downloadDateStartRange',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.downloadDateEndRange !=
        newOrModifiedaudioSortFilterParms.downloadDateEndRange) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionDateValueStr(
              dateFormatVMlistenFalse: dateFormatVMlistenFalse,
              initialDateTimeValue:
                  existingAudioSortFilterParms.downloadDateEndRange,
              modifiedDateTimeValue:
                  newOrModifiedaudioSortFilterParms.downloadDateEndRange,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'downloadDateEndRange',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.uploadDateStartRange !=
        newOrModifiedaudioSortFilterParms.uploadDateStartRange) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionDateValueStr(
              dateFormatVMlistenFalse: dateFormatVMlistenFalse,
              initialDateTimeValue:
                  existingAudioSortFilterParms.uploadDateStartRange,
              modifiedDateTimeValue:
                  newOrModifiedaudioSortFilterParms.uploadDateStartRange,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'uploadDateStartRange',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.uploadDateEndRange !=
        newOrModifiedaudioSortFilterParms.uploadDateEndRange) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionDateValueStr(
              dateFormatVMlistenFalse: dateFormatVMlistenFalse,
              initialDateTimeValue:
                  existingAudioSortFilterParms.uploadDateEndRange,
              modifiedDateTimeValue:
                  newOrModifiedaudioSortFilterParms.uploadDateEndRange,
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'uploadDateEndRange',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst);
    }
    if (existingAudioSortFilterParms.fileSizeStartRangeMB !=
        newOrModifiedaudioSortFilterParms.fileSizeStartRangeMB) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionDisplayedStr(
              initialValueStr:
                  existingAudioSortFilterParms.fileSizeStartRangeMB.toString(),
              modifiedValueStr: newOrModifiedaudioSortFilterParms
                  .fileSizeStartRangeMB
                  .toString(),
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'fileSizeStartRangeMB',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst,
              areInitialStartAndEndValueEqualToZero:
                  existingAudioSortFilterParms.fileSizeStartRangeMB == 0 &&
                      existingAudioSortFilterParms.fileSizeEndRangeMB == 0);
    }
    if (existingAudioSortFilterParms.fileSizeEndRangeMB !=
        newOrModifiedaudioSortFilterParms.fileSizeEndRangeMB) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionDisplayedStr(
              initialValueStr:
                  existingAudioSortFilterParms.fileSizeEndRangeMB.toString(),
              modifiedValueStr: newOrModifiedaudioSortFilterParms
                  .fileSizeEndRangeMB
                  .toString(),
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'fileSizeEndRangeMB',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst,
              areInitialStartAndEndValueEqualToZero:
                  existingAudioSortFilterParms.fileSizeStartRangeMB == 0 &&
                      existingAudioSortFilterParms.fileSizeEndRangeMB == 0);
    }
    if (existingAudioSortFilterParms.durationStartRangeSec !=
        newOrModifiedaudioSortFilterParms.durationStartRangeSec) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionDisplayedStr(
              initialValueStr: DateTimeUtil.formatSecondsToHHMM(
                seconds: existingAudioSortFilterParms.durationStartRangeSec,
              ),
              modifiedValueStr: DateTimeUtil.formatSecondsToHHMM(
                seconds:
                    newOrModifiedaudioSortFilterParms.durationStartRangeSec,
              ),
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'durationStartRangeSec',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst,
              areInitialStartAndEndValueEqualToZero:
                  existingAudioSortFilterParms.durationStartRangeSec == 0 &&
                      existingAudioSortFilterParms.durationEndRangeSec == 0);
    }
    if (existingAudioSortFilterParms.durationEndRangeSec !=
        newOrModifiedaudioSortFilterParms.durationEndRangeSec) {
      wasFilterOptionsTitleAddedToDifferencesLst =
          _addToDifferencesLstOtherOptionDisplayedStr(
              initialValueStr: DateTimeUtil.formatSecondsToHHMM(
                seconds: existingAudioSortFilterParms.durationEndRangeSec,
              ),
              modifiedValueStr: DateTimeUtil.formatSecondsToHHMM(
                seconds: newOrModifiedaudioSortFilterParms.durationEndRangeSec,
              ),
              sortFilterParmsNameTranslationMap:
                  sortFilterParmsNameTranslationMap,
              optionNameTranslationKey: 'durationEndRangeSec',
              differencesLst: differencesLst,
              wasFilterOptionsTitleAddedToDifferencesLst:
                  wasFilterOptionsTitleAddedToDifferencesLst,
              areInitialStartAndEndValueEqualToZero:
                  existingAudioSortFilterParms.durationStartRangeSec == 0 &&
                      existingAudioSortFilterParms.durationEndRangeSec == 0);
    }

    return differencesLst;
  }

  bool _addToDifferencesLstOtherOptionDisplayedStr({
    required String initialValueStr,
    required String modifiedValueStr,
    required Map<String, String> sortFilterParmsNameTranslationMap,
    required String optionNameTranslationKey,
    required List<String> differencesLst,
    required bool wasFilterOptionsTitleAddedToDifferencesLst,
    bool isValueTranslated = false,
    bool areInitialStartAndEndValueEqualToZero = false,
  }) {
    if (!wasFilterOptionsTitleAddedToDifferencesLst) {
      differencesLst.add(
          sortFilterParmsNameTranslationMap['filterOptionLstTitle'] ??
              'filterOptionLstTitle'); // add Filter options: title
      wasFilterOptionsTitleAddedToDifferencesLst = true;
    }

    String translatedOptionName =
        sortFilterParmsNameTranslationMap[optionNameTranslationKey]!;

    if (!areInitialStartAndEndValueEqualToZero) {
      String valueInInitialVersionTitle =
          sortFilterParmsNameTranslationMap['valueInInitialVersionTitle'] ??
              'valueInInitialVersionTitle';
      differencesLst.add(valueInInitialVersionTitle);

      String valueInInitialVersion =
          '$translatedOptionName: ${(isValueTranslated) ? sortFilterParmsNameTranslationMap[initialValueStr] : initialValueStr}';
      differencesLst.add(valueInInitialVersion);
    }

    String valueInModifiedVersionTitle =
        sortFilterParmsNameTranslationMap['valueInModifiedVersionTitle'] ??
            'valueInModifiedVersionTitle';
    differencesLst.add(valueInModifiedVersionTitle);

    String valueInModifiedVersion =
        '$translatedOptionName: ${(isValueTranslated) ? sortFilterParmsNameTranslationMap[modifiedValueStr] : modifiedValueStr}';
    differencesLst.add(valueInModifiedVersion);

    return wasFilterOptionsTitleAddedToDifferencesLst;
  }

  bool _addToDifferencesLstOtherOptionCheckboxValueStr({
    required bool initialCheckBoxState,
    required bool modifiedCheckBoxState,
    required Map<String, String> sortFilterParmsNameTranslationMap,
    required String optionNameTranslationKey,
    required List<String> differencesLst,
    required bool wasFilterOptionsTitleAddedToDifferencesLst,
  }) {
    if (!wasFilterOptionsTitleAddedToDifferencesLst) {
      differencesLst.add(
          sortFilterParmsNameTranslationMap['filterOptionLstTitle'] ??
              'filterOptionLstTitle'); // add Filter options: title
      wasFilterOptionsTitleAddedToDifferencesLst = true;
    }

    String valueInInitialVersionTitle =
        sortFilterParmsNameTranslationMap['valueInInitialVersionTitle'] ??
            'valueInInitialVersionTitle';
    differencesLst.add(valueInInitialVersionTitle);

    String initialCheckBoxStateStr =
        initialCheckBoxState ? 'checked' : 'unchecked';
    String translatedOptionName =
        sortFilterParmsNameTranslationMap[optionNameTranslationKey]!;
    String valueInInitialVersion =
        '$translatedOptionName: ${sortFilterParmsNameTranslationMap[initialCheckBoxStateStr]}';
    differencesLst.add(valueInInitialVersion);

    String valueInModifiedVersionTitle =
        sortFilterParmsNameTranslationMap['valueInModifiedVersionTitle'] ??
            'valueInModifiedVersionTitle';
    differencesLst.add(valueInModifiedVersionTitle);

    String modifiedCheckBoxStateStr =
        modifiedCheckBoxState ? 'checked' : 'unchecked';
    String valueInModifiedVersion =
        '$translatedOptionName: ${sortFilterParmsNameTranslationMap[modifiedCheckBoxStateStr]}';
    differencesLst.add(valueInModifiedVersion);

    return wasFilterOptionsTitleAddedToDifferencesLst;
  }

  bool _addToDifferencesLstOtherOptionDateValueStr({
    required DateFormatVM dateFormatVMlistenFalse,
    required DateTime? initialDateTimeValue,
    required DateTime? modifiedDateTimeValue,
    required Map<String, String> sortFilterParmsNameTranslationMap,
    required String optionNameTranslationKey,
    required List<String> differencesLst,
    required bool wasFilterOptionsTitleAddedToDifferencesLst,
  }) {
    if (!wasFilterOptionsTitleAddedToDifferencesLst) {
      differencesLst.add(
          sortFilterParmsNameTranslationMap['filterOptionLstTitle'] ??
              'filterOptionLstTitle'); // add Filter options: title
      wasFilterOptionsTitleAddedToDifferencesLst = true;
    }

    String translatedOptionName =
        sortFilterParmsNameTranslationMap[optionNameTranslationKey]!;

    if (initialDateTimeValue != null) {
      String valueInInitialVersionTitle =
          sortFilterParmsNameTranslationMap['valueInInitialVersionTitle'] ??
              'valueInInitialVersionTitle';
      differencesLst.add(valueInInitialVersionTitle);

      String valueInInitialVersion =
          '$translatedOptionName: ${dateFormatVMlistenFalse.formatDate(initialDateTimeValue)}';
      differencesLst.add(valueInInitialVersion);
    }

    String valueInModifiedVersionTitle =
        sortFilterParmsNameTranslationMap['valueInModifiedVersionTitle'] ??
            'valueInModifiedVersionTitle';
    differencesLst.add(valueInModifiedVersionTitle);

    String valueInModifiedVersion;

    if (modifiedDateTimeValue != null) {
      valueInModifiedVersion =
          '$translatedOptionName: ${dateFormatVMlistenFalse.formatDate(modifiedDateTimeValue)}';
    } else {
      valueInModifiedVersion =
          '$translatedOptionName: ${sortFilterParmsNameTranslationMap['emptyDate']}';
    }

    differencesLst.add(valueInModifiedVersion);

    return wasFilterOptionsTitleAddedToDifferencesLst;
  }

  void _addTranslatedSortFilterParmsNamePlusSortOrder({
    required Map<SortFilterParmsVersion, List<SortingItem>> listDiff,
    required SortFilterParmsVersion listDiffKey,
    required Map<String, String> sortFilterParmsNameTranslationMap,
    required List<String> differencesLst,
  }) {
    List<String> namePlusOrderLst = listDiff[listDiffKey]!.map((item) {
      String sortingOptionName =
          (item).sortingOption.toString().split('.').last;
      String ascOrDesc = (item).isAscending
          ? sortFilterParmsNameTranslationMap['ascending'] ?? 'asc'
          : sortFilterParmsNameTranslationMap['descending'] ?? 'desc';
      String translatedSortFilterName =
          sortFilterParmsNameTranslationMap[sortingOptionName] ??
              sortingOptionName;
      return '$translatedSortFilterName $ascOrDesc';
    }).toList();

    String presentOnlyInVersionTitle;

    if (listDiffKey == SortFilterParmsVersion.versionOne) {
      presentOnlyInVersionTitle =
          sortFilterParmsNameTranslationMap['presentOnlyInFirstTitle'] ??
              'presentOnlyInFirstTitle';
    } else {
      presentOnlyInVersionTitle =
          sortFilterParmsNameTranslationMap['presentOnlyInSecondTitle'] ??
              'presentOnlyInSecondTitle';
    }

    differencesLst.add(presentOnlyInVersionTitle);
    differencesLst.add(namePlusOrderLst.join(', '));
  }

  /// Finds the differences between two lists of SortingItem's.
  ///
  /// Returns a map with:
  /// - `onlyInFirst`: SortingItem's with specific values present only in the
  ///    first list.
  /// - `onlyInSecond`: SortingItem's with specific values present only in the
  ///    second list.
  Map<SortFilterParmsVersion, List<SortingItem>> getSortItemsDifferences(
      List<SortingItem> list1, List<SortingItem> list2) {
    // SortingItem's only in the first list
    List<SortingItem> onlyInFirst =
        list1.where((item) => !list2.contains(item)).toList();

    // SortingItem's only in the second list
    List<SortingItem> onlyInSecond =
        list2.where((item) => !list1.contains(item)).toList();

    return {
      SortFilterParmsVersion.versionOne: onlyInFirst,
      SortFilterParmsVersion.versionTwo: onlyInSecond,
    };
  }

  /// Finds the differences between two lists of audio filtering sentences (String's).
  ///
  /// Returns a map with:
  /// - `onlyInFirst`: filtering sentences present only in the first list.
  /// - `onlyInSecond`: filtering sentences present only in the second list.
  Map<SortFilterParmsVersion, List<String>> getFilterSentencesDifferences(
      List<String> list1, List<String> list2) {
    // filtering sentences only in the first list
    List<String> onlyInFirst =
        list1.where((item) => !list2.contains(item)).toList();

    // filtering sentences only in the second list
    List<String> onlyInSecond =
        list2.where((item) => !list1.contains(item)).toList();

    return {
      SortFilterParmsVersion.versionOne: onlyInFirst,
      SortFilterParmsVersion.versionTwo: onlyInSecond,
    };
  }

  /// Method called by filterAndSortAudioLst(). The video title is
  ///
  /// This method filters the audio list by the given filter sentences applied
  /// on the video title and/or the Youtube channel name and/or the video
  /// description if required.
  ///
  /// Not private in order to be unit tested.
  List<Audio> filterOnVideoTitleAndDescriptionAndYoutubeChannelOptions({
    required List<Audio> audioLst,
    required List<String> filterSentenceLst,
    required SentencesCombination sentencesCombination,
    required bool ignoreCase,
    required bool searchAsWellInVideoCompactDescription,
    required bool searchAsWellInYoutubeChannelName,
  }) {
    List<Audio> filteredAudios = [];

    for (Audio audio in audioLst) {
      bool isAudioFiltered = false;
      for (String filterSentence in filterSentenceLst) {
        if (searchAsWellInYoutubeChannelName &&
            searchAsWellInVideoCompactDescription) {
          // here, the 'Include Youtube channel' and 'Include description'
          // checkboxes are checked, so we need to search in the valid video
          // title as well as in the Youtube channel name as well as in the
          // compact video description.
          String? filterSentenceInLowerCase;
          if (ignoreCase) {
            // computing the filter sentence in lower case makes
            // sense when we are analysing the two fields in order
            // to avoid computing twice the same thing
            filterSentenceInLowerCase = filterSentence.toLowerCase();
            if (audio.validVideoTitle
                    .toLowerCase()
                    .contains(filterSentenceInLowerCase) ||
                audio.youtubeVideoChannel
                    .toLowerCase()
                    .contains(filterSentenceInLowerCase) ||
                audio.compactVideoDescription
                    .toLowerCase()
                    .contains(filterSentenceInLowerCase)) {
              isAudioFiltered = true;
            } else {
              isAudioFiltered = false;
            }
          } else {
            if (audio.validVideoTitle.contains(filterSentence) ||
                audio.youtubeVideoChannel.contains(filterSentence) ||
                audio.compactVideoDescription.contains(filterSentence)) {
              isAudioFiltered = true;
            } else {
              isAudioFiltered = false;
            }
          }

          if (isAudioFiltered &&
              sentencesCombination == SentencesCombination.or) {
            // not necessary to test the other filter sentences since
            // equality was found and 'OR' is sufficient ..
            break;
          } else if (!isAudioFiltered &&
              sentencesCombination == SentencesCombination.and) {
            // not necessary to test the other filter sentences since
            // inequality was found and 'AND' is necessary ..
            break;
          }
        } else if (searchAsWellInYoutubeChannelName &&
            !searchAsWellInVideoCompactDescription) {
          // here, the 'Include Youtube channel' checkbox is checked,
          // but the 'Include description' is not checked, so we need to
          // search in the as well as in the Youtube channel but not in
          // the compact video description.
          String? filterSentenceInLowerCase;
          if (ignoreCase) {
            // computing the filter sentence in lower case makes
            // sense when we are analysing the two fields in order
            // to avoid computing twice the same thing
            filterSentenceInLowerCase = filterSentence.toLowerCase();
            if (audio.validVideoTitle
                    .toLowerCase()
                    .contains(filterSentenceInLowerCase) ||
                audio.youtubeVideoChannel
                    .toLowerCase()
                    .contains(filterSentenceInLowerCase)) {
              isAudioFiltered = true;
            } else {
              isAudioFiltered = false;
            }
          } else {
            if (audio.validVideoTitle.contains(filterSentence) ||
                audio.youtubeVideoChannel.contains(filterSentence)) {
              isAudioFiltered = true;
            } else {
              isAudioFiltered = false;
            }
          }

          if (isAudioFiltered &&
              sentencesCombination == SentencesCombination.or) {
            // not necessary to test the other filter sentences since
            // equality was found and 'OR' is sufficient ..
            break;
          } else if (!isAudioFiltered &&
              sentencesCombination == SentencesCombination.and) {
            // not necessary to test the other filter sentences since
            // inequality was found and 'AND' is necessary ..
            break;
          }
        } else if (!searchAsWellInYoutubeChannelName &&
            searchAsWellInVideoCompactDescription) {
          // here, the 'Include Youtube channel' checkbox is not checked
          // but the 'Include description'checkbox is checked, so we need
          // to search in the valid video title as well as in the compact
          // video description, but not in the Youtube channel name.
          String? filterSentenceInLowerCase;
          if (ignoreCase) {
            // computing the filter sentence in lower case makes
            // sense when we are analysing the two fields in order
            // to avoid computing twice the same thing
            filterSentenceInLowerCase = filterSentence.toLowerCase();
            if (audio.validVideoTitle
                    .toLowerCase()
                    .contains(filterSentenceInLowerCase) ||
                audio.compactVideoDescription
                    .toLowerCase()
                    .contains(filterSentenceInLowerCase)) {
              isAudioFiltered = true;
            } else {
              isAudioFiltered = false;
            }
          } else {
            if (audio.validVideoTitle.contains(filterSentence) ||
                audio.compactVideoDescription.contains(filterSentence)) {
              isAudioFiltered = true;
            } else {
              isAudioFiltered = false;
            }
          }

          if (isAudioFiltered &&
              sentencesCombination == SentencesCombination.or) {
            // not necessary to test the other filter sentences since
            // equality was found and 'OR' is sufficient ..
            break;
          } else if (!isAudioFiltered &&
              sentencesCombination == SentencesCombination.and) {
            // not necessary to test the other filter sentences since
            // inequality was found and 'AND' is necessary ..
            break;
          }
        } else {
          // we need to search in the valid video title only
          if (ignoreCase) {
            if (audio.validVideoTitle
                .toLowerCase()
                .contains(filterSentence.toLowerCase())) {
              isAudioFiltered = true;
            } else {
              isAudioFiltered = false;
            }
          } else {
            if (audio.validVideoTitle.contains(filterSentence)) {
              isAudioFiltered = true;
            } else {
              isAudioFiltered = false;
            }
          }

          if (isAudioFiltered &&
              sentencesCombination == SentencesCombination.or) {
            // not necessary to test the other filter sentences since
            // equality was found and 'OR' is sufficient ..
            break;
          } else if (!isAudioFiltered &&
              sentencesCombination == SentencesCombination.and) {
            // not necessary to test the other filter sentences since
            // inequality was found and 'AND' is necessary ..
            break;
          }
        }
      } // end of for loop on filterSentenceLst

      if (isAudioFiltered) {
        // one of the filter sentences was found in the audio
        filteredAudios.add(audio);
      }
    }

    return filteredAudios;
  }

  /// Method called by filterAndSortAudioLst().
  ///
  /// This method filters the passed audio list by the other filter
  /// options set by the user in the sort and filter dialog, i.e.
  ///
  /// Audio music quality,
  /// Fully listened,
  /// Partially listened,
  /// Not listened,
  /// Commented,
  /// Not commented,
  /// Start download date,
  /// End download date,
  /// Start upload date,
  /// End upload date,
  /// File size range,
  /// Audio duration range.
  ///
  /// Not private in order to be unit tested.
  List<Audio> filterOnOtherOptions({
    required Playlist? selectedPlaylist,
    required List<Audio> audioLst,
    required AudioSortFilterParameters audioSortFilterParameters,
  }) {
    List<Audio> filteredAudios = audioLst;

    // If the 'Audio music quality' checkbox is set to true, the
    // returned audio list contains only music quality audio.
    // Otherwise, the returned audio list contains both music and
    // speech quality audio.
    if (audioSortFilterParameters.filterMusicQuality) {
      filteredAudios = audioLst.where((audio) {
        return audio.isAudioMusicQuality;
      }).toList();
    }

    // If the 'Fully listened' checkbox was set to false (by
    // default it is set to true), the returned audio list
    // does not contain audio that were fully listened.
    if (!audioSortFilterParameters.filterFullyListened) {
      filteredAudios = filteredAudios.where((audio) {
        return !audio.wasFullyListened();
      }).toList();
    }

    // If the 'Partially listened' checkbox was set to false (by
    // default it is set to true), the returned audio list
    // does not contain audio that are partially listened.
    if (!audioSortFilterParameters.filterPartiallyListened) {
      filteredAudios = filteredAudios.where((audio) {
        return !audio.isPartiallyListened();
      }).toList();
    }

    // If the 'Not listened' checkbox was set to false (by
    // default it is set to true), the returned audio list
    // does not contain audio that are not fully or partially
    // listened.
    if (!audioSortFilterParameters.filterNotListened) {
      filteredAudios = filteredAudios.where((audio) {
        return audio.wasFullyListened() || audio.isPartiallyListened();
      }).toList();
    }

    if (filteredAudios.isEmpty) {
      return filteredAudios;
    }

    CommentVM commentVM = CommentVM();
    Map<String, List<Comment>> commentsMap = commentVM.getPlaylistAudioComments(
      playlist: filteredAudios.first.enclosingPlaylist!,
    );

    // If the 'Commented' checkbox was set to false (by
    // default it is set to true), the returned audio list
    // does not contain audio that have been commented.
    if (!audioSortFilterParameters.filterCommented) {
      filteredAudios = _filterAudioLstByRemovingCommentedAudio(
        audioLst: filteredAudios,
        commentsMap: commentsMap,
      );
    }

    // If the 'Not commented' checkbox was set to false (by
    // default it is set to true), the returned audio list
    // does not contain audio that have not been commented.
    if (!audioSortFilterParameters.filterNotCommented) {
      filteredAudios = _filterAudioLstByRemovingUnCommentedAudio(
        audioLst: filteredAudios,
        commentsMap: commentsMap,
      );
    }

    if (selectedPlaylist == null) {
      return filteredAudios;
    }

    List<String> playlistPictureFileNamesLst = DirUtil.listFileNamesInDir(
      directoryPath:
          "${selectedPlaylist.downloadPath}${path.separator}$kPictureDirName",
      fileExtension: 'jpg',
    );

    // If the 'Pictured' checkbox was set to false (by
    // default it is set to true), the returned audio list
    // does not contain audio to which a picture was added.
    if (!audioSortFilterParameters.filterPictured) {
      filteredAudios = _filterAudioLstByRemovingPicturedAudio(
        audioLst: filteredAudios,
        playlistPictureFileNamedLst: playlistPictureFileNamesLst,
      );
    }

    // If the 'Not pictured' checkbox was set to false (by
    // default it is set to true), the returned audio list
    // does not contain audio that to which no picture was
    // added.
    if (!audioSortFilterParameters.filterNotPictured) {
      filteredAudios = _filterAudioLstByRemovingUnPicturedAudio(
        audioLst: filteredAudios,
        playlistPictureFileNamedLst: playlistPictureFileNamesLst,
      );
    }

    if (audioSortFilterParameters.downloadDateStartRange != null ||
        audioSortFilterParameters.downloadDateEndRange != null) {
      filteredAudios = _filterAudioLstByAudioDownloadDateTime(
        audioLst: filteredAudios,
        startDateTime: audioSortFilterParameters.downloadDateStartRange,
        endDateTime: audioSortFilterParameters.downloadDateEndRange,
      );
    }

    if (audioSortFilterParameters.uploadDateStartRange != null ||
        audioSortFilterParameters.uploadDateEndRange != null) {
      filteredAudios = _filterAudioLstByAudioVideoUploadDateTime(
        audioLst: filteredAudios,
        startDateTime: audioSortFilterParameters.uploadDateStartRange,
        endDateTime: audioSortFilterParameters.uploadDateEndRange,
      );
    }

    if (audioSortFilterParameters.fileSizeStartRangeMB != 0 ||
        audioSortFilterParameters.fileSizeEndRangeMB != 0) {
      filteredAudios = _filterAudioLstByAudioFileSize(
        audioLst: filteredAudios,
        startFileSizeMB: audioSortFilterParameters.fileSizeStartRangeMB,
        endFileSizeMB: audioSortFilterParameters.fileSizeEndRangeMB,
      );
    }

    if (audioSortFilterParameters.durationStartRangeSec != 0 ||
        audioSortFilterParameters.durationEndRangeSec != 0) {
      filteredAudios = _filterAudioLstByAudioDuration(
        audioLst: filteredAudios,
        startRangeSeconds: audioSortFilterParameters.durationStartRangeSec,
        endRangeSeconds: audioSortFilterParameters.durationEndRangeSec,
      );
    }

    return filteredAudios;
  }

  List<Audio> _filterAudioLstByRemovingCommentedAudio({
    required List<Audio> audioLst,
    required Map<String, List<Comment>> commentsMap,
  }) {
    return audioLst.where((audio) {
      return commentsMap[audio.audioFileName.replaceFirst('.mp3', '')] == null;
    }).toList();
  }

  List<Audio> _filterAudioLstByRemovingUnCommentedAudio({
    required List<Audio> audioLst,
    required Map<String, List<Comment>> commentsMap,
  }) {
    return audioLst.where((audio) {
      return commentsMap[audio.audioFileName.replaceFirst('.mp3', '')] != null;
    }).toList();
  }

  List<Audio> _filterAudioLstByRemovingPicturedAudio({
    required List<Audio> audioLst,
    required List<String> playlistPictureFileNamedLst,
  }) {
    return audioLst.where((audio) {
      // Returns only audio for which no picture was added, i.e. the
      // playlistPictureFileNamedLst does not contain the audio
      // file name with the '.jpg' extension.
      return !playlistPictureFileNamedLst
          .contains(audio.audioFileName.replaceFirst('.mp3', '.jpg'));
    }).toList();
  }

  List<Audio> _filterAudioLstByRemovingUnPicturedAudio({
    required List<Audio> audioLst,
    required List<String> playlistPictureFileNamedLst,
  }) {
    // Returns only audio for which a picture was added, i.e. the
    // playlistPictureFileNamedLst does contain the audio
    // file name with the '.jpg' extension.
    return audioLst.where((audio) {
      return playlistPictureFileNamedLst
          .contains(audio.audioFileName.replaceFirst('.mp3', '.jpg'));
    }).toList();
  }

  List<Audio> _filterAudioLstByAudioDownloadDateTime({
    required List<Audio> audioLst,
    required DateTime? startDateTime,
    required DateTime? endDateTime,
  }) {
    if (endDateTime != null) {
      endDateTime = DateTimeUtil.setDateTimeToEndDay(date: endDateTime);
    }

    if (startDateTime != null) {
      if (endDateTime != null) {
        if (startDateTime.isAfter(endDateTime)) {
          return [];
        }

        return audioLst.where((audio) {
          return (audio.audioDownloadDateTime.isAfter(startDateTime) ||
                  audio.audioDownloadDateTime
                      .isAtSameMomentAs(startDateTime)) &&
              (audio.audioDownloadDateTime.isBefore(endDateTime!) ||
                  audio.audioDownloadDateTime.isAtSameMomentAs(endDateTime));
        }).toList();
      } else {
        // endDateTime is null
        return audioLst.where((audio) {
          return (audio.audioDownloadDateTime.isAfter(startDateTime) ||
              audio.audioDownloadDateTime.isAtSameMomentAs(startDateTime));
        }).toList();
      }
    } else {
      // startDateTime is null
      if (endDateTime != null) {
        return audioLst.where((audio) {
          return (audio.audioDownloadDateTime.isBefore(endDateTime!) ||
              audio.audioDownloadDateTime.isAtSameMomentAs(endDateTime));
        }).toList();
      } else {
        // startDateTime and endDateTime are null
        return audioLst;
      }
    }
  }

  List<Audio> _filterAudioLstByAudioVideoUploadDateTime({
    required List<Audio> audioLst,
    required DateTime? startDateTime,
    required DateTime? endDateTime,
  }) {
    if (endDateTime != null) {
      endDateTime = DateTimeUtil.setDateTimeToEndDay(date: endDateTime);
    }

    if (startDateTime != null) {
      if (endDateTime != null) {
        if (startDateTime.isAfter(endDateTime)) {
          return [];
        }

        return audioLst.where((audio) {
          return (audio.videoUploadDate.isAfter(startDateTime) ||
                  audio.videoUploadDate.isAtSameMomentAs(startDateTime)) &&
              (audio.videoUploadDate.isBefore(endDateTime!) ||
                  audio.videoUploadDate.isAtSameMomentAs(endDateTime));
        }).toList();
      } else {
        // endDateTime is null
        return audioLst.where((audio) {
          return (audio.videoUploadDate.isAfter(startDateTime) ||
              audio.videoUploadDate.isAtSameMomentAs(startDateTime));
        }).toList();
      }
    } else {
      // startDateTime is null
      if (endDateTime != null) {
        return audioLst.where((audio) {
          return (audio.videoUploadDate.isBefore(endDateTime!) ||
              audio.videoUploadDate.isAtSameMomentAs(endDateTime));
        }).toList();
      } else {
        // startDateTime and endDateTime are null
        return audioLst;
      }
    }
  }

  List<Audio> _filterAudioLstByAudioFileSize({
    required List<Audio> audioLst,
    required double startFileSizeMB,
    required double endFileSizeMB,
  }) {
    if (startFileSizeMB != 0) {
      if (endFileSizeMB != 0) {
        if (startFileSizeMB > endFileSizeMB) {
          return [];
        }
        return audioLst.where((audio) {
          return (audio.audioFileSize >= startFileSizeMB * 1000000) &&
              (audio.audioFileSize <
                  (_addSmallIncrement(endFileSizeMB)) * 1000000);
        }).toList();
      } else {
        // endFileSizeMB == 0
        return audioLst.where((audio) {
          return audio.audioFileSize >= startFileSizeMB * 1000000;
        }).toList();
      }
    } else {
      // startFileSizeMB == 0
      if (endFileSizeMB != 0) {
        return audioLst.where((audio) {
          return audio.audioFileSize <
              (_addSmallIncrement(endFileSizeMB)) * 1000000;
        }).toList();
      } else {
        // startFileSizeMB and endFileSizeMB are 0
        return audioLst;
      }
    }
  }

  /// Adds a small increment to the value in order to include for example those
  /// file size of 2373715 bytes and 2370022 bytes in the filter result if the
  /// start and end filter file size were set to the same value of 2.37 MB. Without
  /// converting the end value to 2.38 MB, the file sizes of 2373715 and 2370022
  /// bytes would not be included in the filter result.
  double _addSmallIncrement(double value) {
    // Determine the precision (number of decimals) in the value
    String valueStr = value.toString();
    int decimalPlaces = 0;

    if (valueStr.contains('.')) {
      decimalPlaces =
          valueStr.split('.')[1].length; // Length of the fraction part
    }

    // Calculate the increment dynamically based on decimal places
    double increment = 1 / (10 * pow(10, decimalPlaces - 1));

    // Add the increment and return the result
    return value + increment;
  }

  List<Audio> _filterAudioLstByAudioDuration({
    required List<Audio> audioLst,
    required int startRangeSeconds,
    required int endRangeSeconds,
  }) {
    if (startRangeSeconds != 0) {
      if (endRangeSeconds != 0) {
        if (startRangeSeconds > endRangeSeconds) {
          return [];
        }
        return audioLst.where((audio) {
          return (audio.audioDuration.inSeconds >= startRangeSeconds) &&
              (audio.audioDuration.inSeconds <= endRangeSeconds);
        }).toList();
      } else {
        // endRangeSeconds == 0
        return audioLst.where((audio) {
          return audio.audioDuration.inSeconds >= startRangeSeconds;
        }).toList();
      }
    } else {
      // startRangeSeconds == 0
      if (endRangeSeconds != 0) {
        return audioLst.where((audio) {
          return audio.audioDuration.inSeconds <= endRangeSeconds;
        }).toList();
      } else {
        // startRangeSeconds and endRangeSeconds are 0
        return audioLst;
      }
    }
  }
}
