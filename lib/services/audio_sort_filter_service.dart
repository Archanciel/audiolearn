import 'package:audiolearn/models/comment.dart';
import 'package:audiolearn/viewmodels/comment_vm.dart';
import 'package:flutter/foundation.dart';

import '../models/audio.dart';
import 'sort_filter_parameters.dart';

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
        var comparableA = copiedSortCriteria.selectorFunction(a);
        var comparableB = copiedSortCriteria.selectorFunction(b);
        int comparison;

        if (comparableA.runtimeType == comparableB.runtimeType) {
          comparison =
              comparableA.compareTo(comparableB) * copiedSortCriteria.sortOrder;
        } else {
          // the possibility that the two comparable objects are not of
          // the same type can happen only when the sorting option is
          // SortingOption.validVideoTitle. In this case, the selector
          // function is coded to compare titles containing a chapter
          // number, the case for audio files representing audio book
          // chapters which were imported. If the titles of downloaded
          // audio are compared and two titles are compared, one containing
          // a number with the other containing no number, in order to
          // avoid compareZo exception, the title strings are compared.
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

  List<String> getListOfDifferencesBetweenSortFilterParameters({
    required AudioSortFilterParameters audioSortFilterParametersOne,
    required AudioSortFilterParameters audioSortFilterParametersTwo,
    required Map<String, String> sortFilterParmNameTranslationMap,
  }) {
    List<String> differencesLst = [];

    if (audioSortFilterParametersOne == audioSortFilterParametersTwo) {
      return differencesLst; // No differences
    }

    // Compare selectedSortItemLst and include specific differences
    if (!listEquals(audioSortFilterParametersOne.selectedSortItemLst,
        audioSortFilterParametersTwo.selectedSortItemLst)) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['selectedSortItemLst'] ??
              'selectedSortItemLst');

      // Add specific differences between the lists
      Map<String, List<dynamic>> listDiff = listDifferences(
        audioSortFilterParametersOne.selectedSortItemLst,
        audioSortFilterParametersTwo.selectedSortItemLst,
      );

      if (listDiff['onlyInFirst']!.isNotEmpty) {
        List<String> firstListNames = listDiff['onlyInFirst']!.map((item) {
          String sortingOptionName =
              (item as SortingItem).sortingOption.toString().split('.').last;

          return sortFilterParmNameTranslationMap[sortingOptionName] ??
              sortingOptionName;
        }).toList();
        String presentOnlyInFirst =
            sortFilterParmNameTranslationMap['presentOnlyInFirst'] ??
                'presentOnlyInFirst';
        differencesLst.add(presentOnlyInFirst);
        differencesLst.add("${firstListNames.join(', ')}");
      }

      if (listDiff['onlyInSecond']!.isNotEmpty) {
        List<String> secondListNames = listDiff['onlyInSecond']!.map((item) {
          String sortingOptionName =
              (item as SortingItem).sortingOption.toString().split('.').last;

          return sortFilterParmNameTranslationMap[sortingOptionName] ??
              sortingOptionName;
        }).toList();
        String presentOnlyInSecond =
            sortFilterParmNameTranslationMap['presentOnlyInSeond'] ??
                'presentOnlyInSeond';
        differencesLst.add(presentOnlyInSecond);
        differencesLst.add("${secondListNames.join(', ')}");
      }
    }

    // Compare filterSentenceLst and include specific differences
    if (!listEquals(audioSortFilterParametersOne.filterSentenceLst,
        audioSortFilterParametersTwo.filterSentenceLst)) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['filterSentenceLst'] ??
              'filterSentenceLst');

      // Add specific differences between the lists
      Map<String, List<dynamic>> listDiff = listDifferences(
        audioSortFilterParametersOne.filterSentenceLst,
        audioSortFilterParametersTwo.filterSentenceLst,
      );

      if (listDiff['onlyInFirst']!.isNotEmpty) {
        String presentOnlyInFirst =
            sortFilterParmNameTranslationMap['presentOnlyInFirst'] ??
                'presentOnlyInFirst';
        differencesLst.add(presentOnlyInFirst);
        differencesLst
            .add("${listDiff['onlyInFirst']!.join(', ')}");
      }

      if (listDiff['onlyInSecond']!.isNotEmpty) {
        String presentOnlyInSecond =
            sortFilterParmNameTranslationMap['presentOnlyInSeond'] ??
                'presentOnlyInSeond';
        differencesLst.add(presentOnlyInSecond);
        differencesLst.add(
            "${listDiff['onlyInSecond']!.join(', ')}");
      }
    }

    // Compare other fields
    if (audioSortFilterParametersOne.sentencesCombination !=
        audioSortFilterParametersTwo.sentencesCombination) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['sentencesCombination'] ??
              'sentencesCombination');
    }
    if (audioSortFilterParametersOne.ignoreCase !=
        audioSortFilterParametersTwo.ignoreCase) {
      differencesLst
          .add(sortFilterParmNameTranslationMap['ignoreCase'] ?? 'ignoreCase');
    }
    if (audioSortFilterParametersOne.searchAsWellInYoutubeChannelName !=
        audioSortFilterParametersTwo.searchAsWellInYoutubeChannelName) {
      differencesLst.add(sortFilterParmNameTranslationMap[
              'searchAsWellInYoutubeChannelName'] ??
          'searchAsWellInYoutubeChannelName');
    }
    if (audioSortFilterParametersOne.searchAsWellInVideoCompactDescription !=
        audioSortFilterParametersTwo.searchAsWellInVideoCompactDescription) {
      differencesLst.add(sortFilterParmNameTranslationMap[
              'searchAsWellInYoutubeChannelName'] ??
          'searchAsWellInYoutubeChannelName');
    }
    if (audioSortFilterParametersOne.filterMusicQuality !=
        audioSortFilterParametersTwo.filterMusicQuality) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['filterMusicQuality'] ??
              'filterMusicQuality');
    }
    if (audioSortFilterParametersOne.filterFullyListened !=
        audioSortFilterParametersTwo.filterFullyListened) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['filterFullyListened'] ??
              'filterFullyListened');
    }
    if (audioSortFilterParametersOne.filterPartiallyListened !=
        audioSortFilterParametersTwo.filterPartiallyListened) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['filterPartiallyListened'] ??
              'filterPartiallyListened');
    }
    if (audioSortFilterParametersOne.filterNotListened !=
        audioSortFilterParametersTwo.filterNotListened) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['filterNotListened'] ??
              'filterNotListened');
    }
    if (audioSortFilterParametersOne.filterCommented !=
        audioSortFilterParametersTwo.filterCommented) {
      differencesLst.add(sortFilterParmNameTranslationMap['filterCommented'] ??
          'filterCommented');
    }
    if (audioSortFilterParametersOne.filterNotCommented !=
        audioSortFilterParametersTwo.filterNotCommented) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['filterNotCommented'] ??
              'filterNotCommented');
    }
    if (audioSortFilterParametersOne.downloadDateStartRange !=
        audioSortFilterParametersTwo.downloadDateStartRange) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['downloadDateStartRange'] ??
              'downloadDateStartRange');
    }
    if (audioSortFilterParametersOne.downloadDateEndRange !=
        audioSortFilterParametersTwo.downloadDateEndRange) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['downloadDateEndRange'] ??
              'downloadDateEndRange');
    }
    if (audioSortFilterParametersOne.uploadDateStartRange !=
        audioSortFilterParametersTwo.uploadDateStartRange) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['uploadDateStartRange'] ??
              'uploadDateStartRange');
    }
    if (audioSortFilterParametersOne.uploadDateEndRange !=
        audioSortFilterParametersTwo.uploadDateEndRange) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['uploadDateEndRange'] ??
              'uploadDateEndRange');
    }
    if (audioSortFilterParametersOne.fileSizeStartRangeMB !=
        audioSortFilterParametersTwo.fileSizeStartRangeMB) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['fileSizeStartRangeMB'] ??
              'fileSizeStartRangeMB');
    }
    if (audioSortFilterParametersOne.fileSizeEndRangeMB !=
        audioSortFilterParametersTwo.fileSizeEndRangeMB) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['fileSizeEndRangeMB'] ??
              'fileSizeEndRangeMB');
    }
    if (audioSortFilterParametersOne.durationStartRangeSec !=
        audioSortFilterParametersTwo.durationStartRangeSec) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['durationStartRangeSec'] ??
              'durationStartRangeSec');
    }
    if (audioSortFilterParametersOne.durationEndRangeSec !=
        audioSortFilterParametersTwo.durationEndRangeSec) {
      differencesLst.add(
          sortFilterParmNameTranslationMap['durationEndRangeSec'] ??
              'durationEndRangeSec');
    }

    return differencesLst;
  }

  /// Finds the differences between two lists.
  ///
  /// Returns a map with:
  /// - `onlyInFirst`: Elements present only in the first list.
  /// - `onlyInSecond`: Elements present only in the second list.
  Map<String, List<dynamic>> listDifferences(
      List<dynamic> list1, List<dynamic> list2) {
    // Elements only in the first list
    List<dynamic> onlyInFirst =
        list1.where((item) => !list2.contains(item)).toList();

    // Elements only in the second list
    List<dynamic> onlyInSecond =
        list2.where((item) => !list1.contains(item)).toList();

    return {
      'onlyInFirst': onlyInFirst,
      'onlyInSecond': onlyInSecond,
    };
  }

  /// Method called by filterAndSortAudioLst().
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

    if (audioSortFilterParameters.downloadDateStartRange != null &&
        audioSortFilterParameters.downloadDateEndRange != null) {
      filteredAudios = _filterAudioLstByAudioDownloadDateTime(
        audioLst: filteredAudios,
        startDateTime: audioSortFilterParameters.downloadDateStartRange!,
        endDateTime: audioSortFilterParameters.downloadDateEndRange!,
      );
    }

    if (audioSortFilterParameters.uploadDateStartRange != null &&
        audioSortFilterParameters.uploadDateEndRange != null) {
      filteredAudios = _filterAudioLstByAudioVideoUploadDateTime(
        audioLst: filteredAudios,
        startDateTime: audioSortFilterParameters.uploadDateStartRange!,
        endDateTime: audioSortFilterParameters.uploadDateEndRange!,
      );
    }

    if (audioSortFilterParameters.fileSizeStartRangeMB >= 0 &&
        audioSortFilterParameters.fileSizeEndRangeMB != 0) {
      filteredAudios = _filterAudioLstByAudioFileSize(
        audioLst: filteredAudios,
        startFileSizeMB: audioSortFilterParameters.fileSizeStartRangeMB,
        endFileSizeMB: audioSortFilterParameters.fileSizeEndRangeMB,
      );
    }

    if (audioSortFilterParameters.durationStartRangeSec >= 0 &&
        audioSortFilterParameters.durationEndRangeSec != 0) {
      filteredAudios = _filterAudioByAudioDuration(
        audioLst: filteredAudios,
        startDuration:
            Duration(seconds: audioSortFilterParameters.durationStartRangeSec),
        endDuration:
            Duration(seconds: audioSortFilterParameters.durationEndRangeSec),
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

  List<Audio> _filterAudioLstByAudioDownloadDateTime({
    required List<Audio> audioLst,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) {
    return audioLst.where((audio) {
      return (audio.audioDownloadDateTime.isAfter(startDateTime) ||
              audio.audioDownloadDateTime.isAtSameMomentAs(startDateTime)) &&
          (audio.audioDownloadDateTime.isBefore(endDateTime) ||
              audio.audioDownloadDateTime.isAtSameMomentAs(endDateTime));
    }).toList();
  }

  List<Audio> _filterAudioLstByAudioVideoUploadDateTime({
    required List<Audio> audioLst,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) {
    return audioLst.where((audio) {
      return (audio.videoUploadDate.isAfter(startDateTime) ||
              audio.videoUploadDate.isAtSameMomentAs(startDateTime)) &&
          (audio.videoUploadDate.isBefore(endDateTime) ||
              audio.videoUploadDate.isAtSameMomentAs(endDateTime));
    }).toList();
  }

  List<Audio> _filterAudioLstByAudioFileSize({
    required List<Audio> audioLst,
    required double startFileSizeMB,
    required double endFileSizeMB,
  }) {
    return audioLst.where((audio) {
      return (audio.audioFileSize >= startFileSizeMB * 1000000) &&
          (audio.audioFileSize <= endFileSizeMB * 1000000);
    }).toList();
  }

  List<Audio> _filterAudioByAudioDuration({
    required List<Audio> audioLst,
    required Duration startDuration,
    required Duration endDuration,
  }) {
    return audioLst.where((audio) {
      return (audio.audioDuration.inMilliseconds >=
              startDuration.inMilliseconds) &&
          (audio.audioDuration.inMilliseconds <= endDuration.inMilliseconds);
    }).toList();
  }

  static DateTime setDateTimeToEndDay({
    required DateTime date,
  }) {
    // Set the time to the end of the given day (23:59:59)
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}
