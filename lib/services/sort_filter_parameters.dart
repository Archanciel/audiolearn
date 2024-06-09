// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

import '../models/audio.dart';
import '../utils/date_time_parser.dart';

/// This enum is used to specify how to sort the audio list.
/// It is used in the sort and filter audio dialog.
enum SortingOption {
  audioDownloadDate,
  videoUploadDate,
  validAudioTitle,
  audioEnclosingPlaylistTitle,
  audioDuration,
  audioRemainingDuration,
  audioFileSize,
  audioMusicQuality,
  audioDownloadSpeed,
  audioDownloadDuration,
  videoUrl, // useful to detect audio duplicates
}

/// This enum is used to specify how to combine the filter sentences
/// specified by the user in the sort and filter audio dialog.
enum SentencesCombination {
  AND, // all sentences must be found
  OR, // at least one sentence must be found
}

const int sortAscending = 1;
const int sortDescending = -1;

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
/// the sort and filter audio dialog. It associates a SortingOption
/// with a boolean indicating if the sorting is ascending or descending.
class SortingItem {
  final SortingOption sortingOption;
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
    if (identical(this, other)) return true;
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

class AudioSortFilterParameters {
  static Map<SortingOption, SortCriteria<Audio>>
      sortCriteriaForSortingOptionMap = {
    SortingOption.audioDownloadDate: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return DateTimeParser.truncateDateTimeToDateOnly(
            audio.audioDownloadDateTime);
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
        return audio.validVideoTitle.toLowerCase();
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
        return audio.audioDuration!.inMilliseconds;
      },
      sortOrder: sortAscending,
    ),
    SortingOption.audioRemainingDuration: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.audioDuration!.inMilliseconds -
            audio.audioPositionSeconds * 1000;
      },
      sortOrder: sortAscending,
    ),
    SortingOption.audioFileSize: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.audioFileSize;
      },
      sortOrder: sortDescending,
    ),
    SortingOption.audioMusicQuality: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.isAudioMusicQuality ? 1 : 0;
      },
      sortOrder: sortAscending,
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
    SortingOption.videoUrl: SortCriteria<Audio>(
      selectorFunction: (Audio audio) {
        return audio.videoUrl;
      },
      sortOrder: sortAscending,
    ),
  };

  static SortingItem getDefaultSortingItem() {
    return SortingItem(
      sortingOption: SortingOption.audioDownloadDate,
      isAscending:
          sortCriteriaForSortingOptionMap[SortingOption.audioDownloadDate]!
                  .sortOrder ==
              sortAscending,
    );
  }

  static AudioSortFilterParameters createDefaultAudioSortFilterParameters() {
    return AudioSortFilterParameters(
      selectedSortItemLst: [AudioSortFilterParameters.getDefaultSortingItem()],
      filterSentenceLst: [],
      sentencesCombination: SentencesCombination.AND,
    );
  }

  final List<SortingItem> selectedSortItemLst;
  final List<String> filterSentenceLst;
  final SentencesCombination sentencesCombination;
  final bool ignoreCase;
  final bool searchAsWellInVideoCompactDescription;
  final bool filterMusicQuality;
  final bool filterFullyListened;
  final bool filterPartiallyListened;
  final bool filterNotListened;

  final DateTime? downloadDateStartRange;
  final DateTime? downloadDateEndRange;
  final DateTime? uploadDateStartRange;
  final DateTime? uploadDateEndRange;
  final double fileSizeStartRangeMB;
  final double fileSizeEndRangeMB;
  final int durationStartRangeSec;
  final int durationEndRangeSec;

  AudioSortFilterParameters({
    required this.selectedSortItemLst,
    this.filterSentenceLst = const [],
    required this.sentencesCombination,
    this.ignoreCase = true, //                  when opening the sort and filter
    this.searchAsWellInVideoCompactDescription = true, // dialog, corresponding
    this.filterMusicQuality = false, //         checkbox's are not checked
    this.filterFullyListened = true,
    this.filterPartiallyListened = true,
    this.filterNotListened = true,
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
      filterSentenceLst: (json['filterSentenceLst'] as List).cast<String>(),
      sentencesCombination:
          SentencesCombination.values[json['sentencesCombination']],
      ignoreCase: json['ignoreCase'],
      searchAsWellInVideoCompactDescription:
          json['searchAsWellInVideoCompactDescription'],
      filterMusicQuality: json['filterMusicQuality'],
      filterFullyListened: json['filterFullyListened'],
      filterPartiallyListened: json['filterPartiallyListened'],
      filterNotListened: json['filterNotListened'],
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
      fileSizeStartRangeMB: json['fileSizeStartRangeMB'] ?? 0,
      fileSizeEndRangeMB: json['fileSizeEndRangeMB'] ?? 0,
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
      'searchAsWellInVideoCompactDescription':
          searchAsWellInVideoCompactDescription,
      'filterMusicQuality': filterMusicQuality,
      'filterFullyListened': filterFullyListened,
      'filterPartiallyListened': filterPartiallyListened,
      'filterNotListened': filterNotListened,
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
        other.searchAsWellInVideoCompactDescription ==
            searchAsWellInVideoCompactDescription &&
        other.filterMusicQuality == filterMusicQuality &&
        other.filterFullyListened == filterFullyListened &&
        other.filterPartiallyListened == filterPartiallyListened &&
        other.filterNotListened == filterNotListened &&
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
      searchAsWellInVideoCompactDescription,
      filterMusicQuality,
      filterFullyListened,
      filterPartiallyListened,
      filterNotListened,
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
      searchAsWellInVideoCompactDescription:
          searchAsWellInVideoCompactDescription,
      filterMusicQuality: filterMusicQuality,
      filterFullyListened: filterFullyListened,
      filterPartiallyListened: filterPartiallyListened,
      filterNotListened: filterNotListened,
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
}
