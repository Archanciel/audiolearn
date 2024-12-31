// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

import '../models/audio.dart';
import '../utils/date_time_parser.dart';

// This enum is used to specify how to sort the audio list.
// It is used in the AudioSortFilterDialog.
enum SortingOption {
  audioDownloadDate,
  videoUploadDate,
  validAudioTitle,
  chapterAudioTitle,
  audioEnclosingPlaylistTitle,
  audioDuration,
  audioRemainingDuration,
  lastListenedDateTime,
  audioFileSize,
  audioDownloadSpeed,
  audioDownloadDuration,
}

// This enum is used to specify how to combine the filter sentences
// specified by the user in the AudioSortFilterDialog.
enum SentencesCombination {
  and, // all sentences must be found
  or, // at least one sentence must be found
}

// Constants used to specify the sort order. The plus or minus constant is
// used multiply the value returned by compareTo applyed in
// AudioSortFilterService.sortAudioLstBySortingOptions() as shown
// below:
//
//      sortCriteria.selectorFunction(a)
//                .compareTo(sortCriteria.selectorFunction(b)).
//
// Since the compareTo value is a positive or negative integer, the
// multiplication by the sort order constant will sort the list in
// ascending or descending order.
const int sortAscending = 1;
const int sortDescending = -1;

/// The instances of this class contain the sort function and the sort order
/// for a specific sorting option. The sort function is used to extract the
/// value to sort on from T instance, currently only Audio instance.
class SortCriteria<T> {
  final Comparable Function(T) selectorFunction;
  int sortOrder;

  SortCriteria({
    required this.selectorFunction,
    required this.sortOrder,
  });

  SortCriteria<T> copy() {
    return SortCriteria<T>(
      selectorFunction: this.selectorFunction,
      sortOrder: this.sortOrder,
    );
  }
}

/// This class represent a 'Sort by:' list item added by the user in
/// the AudioSortFilterDialog. It associates a SortingOption
/// with a boolean indicating if the sorting is ascending or descending.
class SortingItem {
  final SortingOption sortingOption; // is an enum
  bool isAscending;

  SortingItem({
    required this.sortingOption,
    required this.isAscending,
  });

  factory SortingItem.fromJson(Map<String, dynamic> json) {
    return SortingItem(
      sortingOption: SortingOption.values.firstWhere(
          (e) => e.toString().split('.').last == json['sortingOption']),
      isAscending: json['isAscending'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sortingOption': sortingOption.toString().split('.').last,
      'isAscending': isAscending,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is SortingItem &&
        other.sortingOption == sortingOption &&
        other.isAscending == isAscending;
  }

  @override
  int get hashCode => Object.hash(sortingOption, isAscending);

  SortingItem copy() {
    return SortingItem(
      sortingOption: sortingOption,
      isAscending: isAscending,
    );
  }
}

/// This class contains a Map of SortCriteria keyed by SortingOption. The
/// SortCriteria contains the function used to compute the audio sort order
/// as well as an ascending or descending sort order modification.The class
/// also contains the default SortingItem definition and a method to create
/// a default AudioSortFilterParameters instance.
class AudioSortFilterParameters {
  static Map<SortingOption, SortCriteria<Audio>>
      sortCriteriaForSortingOptionMap = {
    SortingOption.audioDownloadDate: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.audioDownloadDateTime;
      },
      sortOrder: sortDescending,
    ),
    SortingOption.videoUploadDate: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return DateTimeParser.truncateDateTimeToDateOnly(audio.videoUploadDate);
      },
      sortOrder: sortDescending,
    ),
    SortingOption.validAudioTitle: SortCriteria<Audio>(

      selectorFunction: (Audio audio) {
      //   final regex = RegExp(r'(\d+)_\d+');

        String validVideoTitleLow = audio.validVideoTitle.toLowerCase();

        // RegExpMatch? firstMatch = regex.firstMatch(validVideoTitleLow);

        // if (firstMatch != null) {
        //   int firstMatchInt = int.parse(firstMatch.group(1)!);

        //   return firstMatchInt;
        // }
        return validVideoTitleLow;
      },
      sortOrder: sortAscending,
    ),
    SortingOption.chapterAudioTitle: SortCriteria<Audio>(

      selectorFunction: (Audio audio) {
        final regex = RegExp(r'(\d+)_\d+');

        String validVideoTitleLow = audio.validVideoTitle.toLowerCase();

        RegExpMatch? firstMatch = regex.firstMatch(validVideoTitleLow);

        if (firstMatch != null) {
          int firstMatchInt = int.parse(firstMatch.group(1)!);

          return firstMatchInt;
        }
        return validVideoTitleLow;
      },
      sortOrder: sortAscending,
    ),
    SortingOption.audioEnclosingPlaylistTitle: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.enclosingPlaylist!.title;
      },
      sortOrder: sortAscending,
    ),
    SortingOption.audioDuration: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.audioDuration.inMilliseconds;
      },
      sortOrder: sortAscending,
    ),
    SortingOption.audioRemainingDuration: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.getAudioRemainingMilliseconds();
      },
      sortOrder: sortAscending,
    ),
    SortingOption.lastListenedDateTime: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        // Since audio.audioPausedDateTime is nullable, we return a default
        // date if it is null. This default date is in the past. So, if the
        // audio.audioPausedDateTime is null, the audio will be positioned at
        // the end of the descendly sorted list.
        return audio.audioPausedDateTime ?? DateTime(2000);
      },
      sortOrder: sortDescending,
    ),
    SortingOption.audioFileSize: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.audioFileSize;
      },
      sortOrder: sortDescending,
    ),
    SortingOption.audioDownloadSpeed: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.audioDownloadSpeed;
      },
      sortOrder: sortDescending,
    ),
    SortingOption.audioDownloadDuration: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.audioDownloadDuration!.inMilliseconds;
      },
      sortOrder: sortDescending,
    ),
  };

  // This list contains the SortingItem's selected by the user in the
  // AudioSortFilterDialog. A SortingItem associates a SortingOption
  // with a boolean indicating if the sorting is ascending or descending.
  final List<SortingItem> selectedSortItemLst;

  // This list contains the filter word(s) or sentence(s) specified by the
  // user in the Video title (and description) filter field of the
  // AudioSortFilterDialog.
  final List<String> filterSentenceLst;

  // This enum is used to specify how to combine the filter sentences: 'and'
  // or 'or'.
  final SentencesCombination sentencesCombination;

  // If true, the search is case insensitive.
  final bool ignoreCase;

  // If true, the search is also done in the Youtube channel name.
  final bool searchAsWellInYoutubeChannelName;

  // If true, the search is also done in the video compact description.
  final bool searchAsWellInVideoCompactDescription;

  // If true, only audio with music quality are selected.
  final bool filterMusicQuality;

  // If true, fully listened audio are also selected.
  final bool filterFullyListened;

  // If true, partially listened audio are also selected.
  final bool filterPartiallyListened;

  // If true, not listened audio are also selected.
  final bool filterNotListened;

  // If true, not commented audio are also selected.
  final bool filterCommented;

  // If true, not commented audio are also selected.
  final bool filterNotCommented;

  // The start and end range for the download date filter.
  final DateTime? downloadDateStartRange;
  final DateTime? downloadDateEndRange;

  // The start and end range for the upload date filter.
  final DateTime? uploadDateStartRange;
  final DateTime? uploadDateEndRange;

  // The start and end range for the file size filter.
  final double fileSizeStartRangeMB;
  final double fileSizeEndRangeMB;

  // The start and end range for the duration filter.
  final int durationStartRangeSec;
  final int durationEndRangeSec;

  AudioSortFilterParameters({
    required this.selectedSortItemLst,
    this.filterSentenceLst = const [],
    required this.sentencesCombination,
    this.ignoreCase = true,
    this.searchAsWellInYoutubeChannelName = true,
    this.searchAsWellInVideoCompactDescription = true,
    this.filterMusicQuality = false,
    this.filterFullyListened = true,
    this.filterPartiallyListened = true,
    this.filterNotListened = true,
    this.filterCommented = true,
    this.filterNotCommented = true,
    this.downloadDateStartRange,
    this.downloadDateEndRange,
    this.uploadDateStartRange,
    this.uploadDateEndRange,
    this.fileSizeStartRangeMB = 0,
    this.fileSizeEndRangeMB = 0,
    this.durationStartRangeSec = 0,
    this.durationEndRangeSec = 0,
  });

  factory AudioSortFilterParameters.fromJson(Map<String, dynamic> json) {
    return AudioSortFilterParameters(
      selectedSortItemLst: (json['selectedSortItemLst'] as List)
          .map((e) => SortingItem.fromJson(e))
          .toList(),
      filterSentenceLst:
          (json['filterSentenceLst'] as List).cast<String>(),
      sentencesCombination:
          SentencesCombination.values[json['sentencesCombination']],
      ignoreCase: json['ignoreCase'],
      searchAsWellInYoutubeChannelName:
          json['searchAsWellInYoutubeChannelName'] ?? true,
      searchAsWellInVideoCompactDescription:
          json['searchAsWellInVideoCompactDescription'],
      filterMusicQuality: json['filterMusicQuality'],
      filterFullyListened: json['filterFullyListened'],
      filterPartiallyListened: json['filterPartiallyListened'],
      filterNotListened: json['filterNotListened'],
      filterCommented: json['filterCommented'] ?? true,
      filterNotCommented: json['filterNotCommented'] ?? true,
      downloadDateStartRange: json['downloadDateStartRange'] == null
          ? null
          : DateTime.parse(json['downloadDateStartRange']),
      downloadDateEndRange: json['downloadDateEndRange'] == null
          ? null
          : DateTime.parse(json['downloadDateEndRange']),
      uploadDateStartRange: json['uploadDateStartRange'] == null
          ? null
          : DateTime.parse(json['uploadDateStartRange']),
      uploadDateEndRange: json['uploadDateEndRange'] == null
          ? null
          : DateTime.parse(json['uploadDateEndRange']),
      fileSizeStartRangeMB: json['fileSizeStartRangeMB'] ?? 0.0,
      fileSizeEndRangeMB: json['fileSizeEndRangeMB'] ?? 0.0,
      durationStartRangeSec: json['durationStartRangeSec'],
      durationEndRangeSec: json['durationEndRangeSec'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedSortItemLst': selectedSortItemLst,
      'filterSentenceLst': filterSentenceLst,
      'sentencesCombination': sentencesCombination.index,
      'ignoreCase': ignoreCase,
      'searchAsWellInYoutubeChannelName': searchAsWellInYoutubeChannelName,
      'searchAsWellInVideoCompactDescription':
          searchAsWellInVideoCompactDescription,
      'filterMusicQuality': filterMusicQuality,
      'filterFullyListened': filterFullyListened,
      'filterPartiallyListened': filterPartiallyListened,
      'filterNotListened': filterNotListened,
      'filterCommented': filterCommented,
      'filterNotCommented': filterNotCommented,
      'downloadDateStartRange': downloadDateStartRange?.toIso8601String(),
      'downloadDateEndRange': downloadDateEndRange?.toIso8601String(),
      'uploadDateStartRange': uploadDateStartRange?.toIso8601String(),
      'uploadDateEndRange': uploadDateEndRange?.toIso8601String(),
      'fileSizeStartRangeMB': fileSizeStartRangeMB,
      'fileSizeEndRangeMB': fileSizeEndRangeMB,
      'durationStartRangeSec': durationStartRangeSec,
      'durationEndRangeSec': durationEndRangeSec,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AudioSortFilterParameters &&
        listEquals(other.selectedSortItemLst, selectedSortItemLst) &&
        listEquals(other.filterSentenceLst, filterSentenceLst) &&
        other.sentencesCombination == sentencesCombination &&
        other.ignoreCase == ignoreCase &&
        other.searchAsWellInYoutubeChannelName ==
            searchAsWellInYoutubeChannelName &&
        other.searchAsWellInVideoCompactDescription ==
            searchAsWellInVideoCompactDescription &&
        other.filterMusicQuality == filterMusicQuality &&
        other.filterFullyListened == filterFullyListened &&
        other.filterPartiallyListened == filterPartiallyListened &&
        other.filterNotListened == filterNotListened &&
        other.filterCommented == filterCommented &&
        other.filterNotCommented == filterNotCommented &&
        other.downloadDateStartRange == downloadDateStartRange &&
        other.downloadDateEndRange == downloadDateEndRange &&
        other.uploadDateStartRange == uploadDateStartRange &&
        other.uploadDateEndRange == uploadDateEndRange &&
        other.fileSizeStartRangeMB == fileSizeStartRangeMB &&
        other.fileSizeEndRangeMB == fileSizeEndRangeMB &&
        other.durationStartRangeSec == durationStartRangeSec &&
        other.durationEndRangeSec == durationEndRangeSec;
  }

  @override
  int get hashCode {
    return Object.hash(
      selectedSortItemLst,
      filterSentenceLst,
      sentencesCombination,
      ignoreCase,
      searchAsWellInYoutubeChannelName,
      searchAsWellInVideoCompactDescription,
      filterMusicQuality,
      filterFullyListened,
      filterPartiallyListened,
      filterNotListened,
      filterCommented,
      filterNotCommented,
      downloadDateStartRange,
      downloadDateEndRange,
      uploadDateStartRange,
      uploadDateEndRange,
      fileSizeStartRangeMB,
      fileSizeEndRangeMB,
      durationStartRangeSec,
      durationEndRangeSec,
    );
  }

  AudioSortFilterParameters copy() {
    return AudioSortFilterParameters(
      selectedSortItemLst: List<SortingItem>.from(
          selectedSortItemLst.map((item) => item.copy())),
      filterSentenceLst: List<String>.from(filterSentenceLst),
      sentencesCombination: sentencesCombination,
      ignoreCase: ignoreCase,
      searchAsWellInYoutubeChannelName: searchAsWellInYoutubeChannelName,
      searchAsWellInVideoCompactDescription:
          searchAsWellInVideoCompactDescription,
      filterMusicQuality: filterMusicQuality,
      filterFullyListened: filterFullyListened,
      filterPartiallyListened: filterPartiallyListened,
      filterNotListened: filterNotListened,
      filterCommented: filterCommented,
      filterNotCommented: filterNotCommented,
      downloadDateStartRange: downloadDateStartRange,
      downloadDateEndRange: downloadDateEndRange,
      uploadDateStartRange: uploadDateStartRange,
      uploadDateEndRange: uploadDateEndRange,
      fileSizeStartRangeMB: fileSizeStartRangeMB,
      fileSizeEndRangeMB: fileSizeEndRangeMB,
      durationStartRangeSec: durationStartRangeSec,
      durationEndRangeSec: durationEndRangeSec,
    );
  }

  /// The default SortingItem is the one that is selected by default in the
  /// AudioSortFilterDialog
  static SortingItem getDefaultSortingItem() {
    return SortingItem(
      sortingOption: SortingOption.audioDownloadDate,
      isAscending:
          sortCriteriaForSortingOptionMap[SortingOption.audioDownloadDate]!
                  .sortOrder ==
              sortAscending,
    );
  }

  /// In the PlaylistDownloadView or in theAudioPlayableListDialog,
  /// the audio are by default sorted by the audio download date in descending
  /// order.
  static AudioSortFilterParameters createDefaultAudioSortFilterParameters() {
    return AudioSortFilterParameters(
      selectedSortItemLst: [AudioSortFilterParameters.getDefaultSortingItem()],
      filterSentenceLst: [],
      sentencesCombination: SentencesCombination.and,
    );
  }
}
