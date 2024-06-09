import '../models/audio.dart';
import 'sort_filter_parameters.dart';

class AudioSortFilterService {
  /// Method called by filterAndSortAudioLst(). This method is used
  /// to sort the audio list by the given sorting option.
  ///
  /// Not private in order to be tested.
  List<Audio> sortAudioLstBySortingOptions({
    required List<Audio> audioLst,
    required List<SortingItem> selectedSortItemLst,
  }) {
    // Create a list of SortCriteria corresponding to the list of
    // selected sorting options coming from the UI.
    List<SortCriteria<Audio>> copiedSortCriteriaLst =
        selectedSortItemLst.map((sortingItem) {
      // it is hyper important to copy the SortCriteria because
      // the sortCriteriaForSortingOptionMap is a static map and
      // we don't want to modify its objects, as it is done in the
      // next instruction. If we don't copy the SortCriteria, the
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
      for (SortCriteria<Audio> sortCriteria in copiedSortCriteriaLst) {
        int comparison = sortCriteria
                .selectorFunction(a)
                .compareTo(sortCriteria.selectorFunction(b)) *
            sortCriteria.sortOrder;
        if (comparison != 0) return comparison;
      }
      return 0;
    });

    return audioLst;
  }

  static bool getDefaultSortOptionOrder({
    required SortingOption sortingOption,
  }) {
    return AudioSortFilterParameters
            .sortCriteriaForSortingOptionMap[sortingOption]!.sortOrder ==
        sortAscending;
  }

  List<Audio> filterAndSortAudioLst({
    required List<Audio> audioLst,
    required AudioSortFilterParameters audioSortFilterParameters,
  }) {
    List<Audio> audioLstCopy = List<Audio>.from(audioLst);
    List<String> filterSentenceLst =
        audioSortFilterParameters.filterSentenceLst;

    if (filterSentenceLst.isNotEmpty) {
      audioLstCopy = filterOnVideoTitleAndDescriptionOptions(
        audioLst: audioLstCopy,
        filterSentenceLst: filterSentenceLst,
        sentencesCombination: audioSortFilterParameters.sentencesCombination,
        ignoreCase: audioSortFilterParameters.ignoreCase,
        searchAsWellInVideoCompactDescription:
            audioSortFilterParameters.searchAsWellInVideoCompactDescription,
      );
    }

    audioLstCopy = _filterOnOtherOptions(
      audioLst: audioLstCopy,
      audioSortFilterParameters: audioSortFilterParameters,
    );

    return sortAudioLstBySortingOptions(
      audioLst: audioLstCopy,
      selectedSortItemLst: audioSortFilterParameters.selectedSortItemLst,
    );
  }

  /// Method called by filterAndSortAudioLst().
  ///
  /// This method filters the audio list by the given filter
  /// sentences applied on the video title and the video
  /// description if required.
  ///
  /// Not private in order to be tested
  List<Audio> filterOnVideoTitleAndDescriptionOptions({
    required List<Audio> audioLst,
    required List<String> filterSentenceLst,
    required SentencesCombination sentencesCombination,
    required bool ignoreCase,
    required bool searchAsWellInVideoCompactDescription,
  }) {
    List<Audio> filteredAudios = [];

    for (Audio audio in audioLst) {
      bool isAudioFiltered = false;
      for (String filterSentence in filterSentenceLst) {
        if (searchAsWellInVideoCompactDescription) {
          // we need to search in the valid video title as well as in the
          // compact video description
          String? filterSentenceInLowerCase;
          if (ignoreCase) {
            // computing the filter sentence in lower case makes
            // sense when we are analysing the two fields in order
            // to avoid computing twice the same thing
            filterSentenceInLowerCase = filterSentence.toLowerCase();
          }
          if (ignoreCase
              ? audio.validVideoTitle
                      .toLowerCase()
                      .contains(filterSentenceInLowerCase!) ||
                  audio.compactVideoDescription
                      .toLowerCase()
                      .contains(filterSentenceInLowerCase)
              : audio.validVideoTitle.contains(filterSentence) ||
                  audio.compactVideoDescription.contains(filterSentence)) {
            isAudioFiltered = true;
            if (sentencesCombination == SentencesCombination.OR) {
              break;
            }
          } else {
            if (sentencesCombination == SentencesCombination.AND) {
              isAudioFiltered = false;
              break;
            }
          }
        } else {
          // we need to search in the valid video title only
          if (ignoreCase
              ? audio.validVideoTitle
                  .toLowerCase()
                  .contains(filterSentence.toLowerCase())
              : audio.validVideoTitle.contains(filterSentence)) {
            isAudioFiltered = true;
            if (sentencesCombination == SentencesCombination.OR) {
              break;
            }
          } else {
            if (sentencesCombination == SentencesCombination.AND) {
              isAudioFiltered = false;
              break;
            }
          }
        }
      }
      if (isAudioFiltered) {
        filteredAudios.add(audio);
      }
    }

    return filteredAudios;
  }

  /// Method called by filterAndSortAudioLst().
  ///
  /// This method filters the passed audio list by the other filter
  /// options set by the user in the sort and filter dialog.
  List<Audio> _filterOnOtherOptions({
    required List<Audio> audioLst,
    required AudioSortFilterParameters audioSortFilterParameters,
  }) {
    List<Audio> filteredAudios = audioLst;

    // If the 'Audio music quality' checkbox is set to true, the
    // returned audio list contains only music quality audios.
    // Otherwise, the returned audio list contains both music and
    // speech quality audios.
    if (audioSortFilterParameters.filterMusicQuality) {
      filteredAudios = audioLst.where((audio) {
        return audio.isAudioMusicQuality;
      }).toList();
    }

    // If the 'Fully listened' checkbox was set to false (by
    // default it is set to true), the returned audio list
    // does not contain audios that were fully listened.
    if (!audioSortFilterParameters.filterFullyListened) {
      filteredAudios = filteredAudios.where((audio) {
        return !audio.wasFullyListened();
      }).toList();
    }

    // If the 'Partially listened' checkbox was set to false (by
    // default it is set to true), the returned audio list
    // does not contain audios that are partially listened.
    if (!audioSortFilterParameters.filterPartiallyListened) {
      filteredAudios = filteredAudios.where((audio) {
        return !audio.isPartiallyListened();
      }).toList();
    }

    // If the 'Not listened' checkbox was set to false (by
    // default it is set to true), the returned audio list
    // does not contain audios that are not fully or partially
    // listened.
    if (!audioSortFilterParameters.filterNotListened) {
      filteredAudios = filteredAudios.where((audio) {
        return audio.wasFullyListened() || audio.isPartiallyListened();
      }).toList();
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

    if (audioSortFilterParameters.fileSizeStartRangeMB != 0 &&
        audioSortFilterParameters.fileSizeEndRangeMB != 0) {
      filteredAudios = _filterAudioLstByAudioFileSize(
        audioLst: filteredAudios,
        startFileSizeMB: audioSortFilterParameters.fileSizeStartRangeMB,
        endFileSizeMB: audioSortFilterParameters.fileSizeEndRangeMB,
      );
    }

    if (audioSortFilterParameters.durationStartRangeSec != 0 &&
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
      return (audio.audioDownloadDuration!.inMilliseconds >=
              startDuration.inMilliseconds) &&
          (audio.audioDownloadDuration!.inMilliseconds <=
              endDuration.inMilliseconds);
    }).toList();
  }
}
