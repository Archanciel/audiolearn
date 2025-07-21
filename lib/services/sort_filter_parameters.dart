// ignore_for_file: constant_identifier_names, avoid_print

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
///
/// main() contains an example of how to use this class to sort a list of strings.
/// The list is sorted by chapter number or by title. The chapter number is
/// extracted from the string using a regular expression. The sort is done in
/// ascending order.
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
/// as well as an ascending or descending sort order parameter. The class
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
        final regex =
            RegExp(r'(\d+)[_\-/:]\d+|\b(\d+)\s*à\s*\d+', caseSensitive: false);

        String validVideoTitleLow = audio.validVideoTitle.toLowerCase();

        RegExpMatch? match = regex.firstMatch(validVideoTitleLow);

        if (match != null) {
          // Extract the first captured number, either from the first group or second
          int chapterNumber = match.group(1) != null
              ? int.parse(match.group(1)!) // First regex match (1_2, 3-5)
              : int.parse(
                  match.group(2)!); // Second regex match (6 à 10, 11 à 15)

          return chapterNumber;
        }

        return validVideoTitleLow; // Default to title string if no match is found
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

  // If true, only audio with spoken quality are selected.
  final bool filterSpokenQuality;

  // If true, fully listened audio are also selected.
  final bool filterFullyListened;

  // If true, partially listened audio are also selected.
  final bool filterPartiallyListened;

  // If true, not listened audio are also selected.
  final bool filterNotListened;

  // If true, commented audio are also selected.
  final bool filterCommented;

  // If true, not commented audio are also selected.
  final bool filterNotCommented;

  // If true, pictured audio are also selected.
  final bool filterPictured;

  // If true, not pictured audio are also selected.
  final bool filterNotPictured;

  // If true, playable audio are also selected.
  final bool filterPlayable;

  // If true, not playable audio are also selected.
  final bool filterNotPlayable;

  // If true, downloaded audio are also selected.
  final bool filterDownloaded;

  // If true, imported audio are also selected.
  final bool filterImported;

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
    this.filterMusicQuality = true,
    this.filterSpokenQuality = true,
    this.filterFullyListened = true,
    this.filterPartiallyListened = true,
    this.filterNotListened = true,
    this.filterCommented = true,
    this.filterNotCommented = true,
    this.filterPictured = true,
    this.filterNotPictured = true,
    this.filterPlayable = true,
    this.filterNotPlayable = true,
    this.filterDownloaded = true,
    this.filterImported = true,
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
      searchAsWellInYoutubeChannelName:
          json['searchAsWellInYoutubeChannelName'] ?? true,
      searchAsWellInVideoCompactDescription:
          json['searchAsWellInVideoCompactDescription'],
      filterMusicQuality: json['filterMusicQuality'],
      filterSpokenQuality: json['filterSpokenQuality'] ?? true,
      filterFullyListened: json['filterFullyListened'],
      filterPartiallyListened: json['filterPartiallyListened'],
      filterNotListened: json['filterNotListened'],
      filterCommented: json['filterCommented'] ?? true,
      filterNotCommented: json['filterNotCommented'] ?? true,
      filterPictured: json['filterPictured'] ?? true,
      filterNotPictured: json['filterNotPictured'] ?? true,
      filterPlayable: json['filterPlayable'] ?? true,
      filterNotPlayable: json['filterNotPlayable'] ?? true,
      filterDownloaded: json['filterDownloaded'] ?? true,
      filterImported: json['filterImported'] ?? true,
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
      'filterSpokenQuality': filterSpokenQuality,
      'filterFullyListened': filterFullyListened,
      'filterPartiallyListened': filterPartiallyListened,
      'filterNotListened': filterNotListened,
      'filterCommented': filterCommented,
      'filterNotCommented': filterNotCommented,
      'filterPictured': filterPictured,
      'filterNotPictured': filterNotPictured,
      'filterPlayable': filterPlayable,
      'filterNotPlayable': filterNotPlayable,
      'filterDownloaded': filterDownloaded,
      'filterImported': filterImported,
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
        other.filterSpokenQuality == filterSpokenQuality &&
        other.filterFullyListened == filterFullyListened &&
        other.filterPartiallyListened == filterPartiallyListened &&
        other.filterNotListened == filterNotListened &&
        other.filterCommented == filterCommented &&
        other.filterNotCommented == filterNotCommented &&
        other.filterPictured == filterPictured &&
        other.filterNotPictured == filterNotPictured &&
        other.filterPlayable == filterPlayable &&
        other.filterNotPlayable == filterNotPlayable &&
        other.filterDownloaded == filterDownloaded &&
        other.filterImported == filterImported &&
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
      filterSpokenQuality,
      filterFullyListened,
      filterPartiallyListened,
      filterNotListened,
      filterCommented,
      filterNotCommented,
      filterPictured,
      filterNotPictured,
      downloadDateStartRange,
      downloadDateEndRange,
      uploadDateStartRange,
      uploadDateEndRange,
      fileSizeStartRangeMB + durationStartRangeSec, // 20 arguments max !
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
      filterSpokenQuality: filterSpokenQuality,
      filterFullyListened: filterFullyListened,
      filterPartiallyListened: filterPartiallyListened,
      filterNotListened: filterNotListened,
      filterCommented: filterCommented,
      filterNotCommented: filterNotCommented,
      filterPictured: filterPictured,
      filterNotPictured: filterNotPictured,
      filterPlayable: filterPlayable,
      filterNotPlayable: filterNotPlayable,
      filterDownloaded: filterDownloaded,
      filterImported: filterImported,
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

// https://chat.openai.com/share/4e661b29-3cd0-41eb-9a66-2fbb0cdb7a7f

void main() {
  const int ascending = 1;
  // const int descending = -1;

  List<String> titles = [
    "La foi contre la peur (1_2 - Joyce Meyer -  Avoir des relations saines",
    "La foi contre la peur (2_2 - Joyce Meyer -  Avoir des relations saines",
    "Il est temps d'être sérieux avec Dieu ! (2_2 - Joyce Meyer - Grandir avec Dieu",
    "Il est temps d'être sérieux avec Dieu ! (1_2 - Joyce Meyer - Grandir avec Dieu",
    "Laisser Dieu au contrôle - Joyce Meyer - Grandir avec Dieu",
    "VOICI COMMENT ÊTRE GUIDÉ PAR LE SAINT ESPRIT _ JOYCE MEYER",
    "Communiquer avec Dieu (1_2 - Joyce Meyer - Grandir avec Dieu",
    "Communiquer avec Dieu (2_2 - Joyce Meyer - Grandir avec Dieu",
  ];

  List<String> audioChapters = [
    "Audio Et l'Univers disparaitra 1_37 - Avant - propos de l'éditeur américain.mp3",
    "Audio Et l'Univers disparaitra 2_37 - Note et remerciements de l'auteur.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 3_37 - Partie 1 chapitre 1.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 4_37 - chapitre 2-1.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 5_37 - chapitre 2 - 2.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 6_37 - chapitre 2 - 3.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 7_37 - chapitre 2 - 4.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 8_37 - chapitre 2 - 5.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 9_37 - chapitre 2 - 6.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 10_37 - chapitre 3 - 1.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 11_37 - chapitre 3 - 2.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 12_37 - chapitre 3 - 3.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 13_37 - chapitre 4 - 1.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 14_37 - chapitre 4 - 2.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 15_37 - chapitre 4 - 3.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 16_37 - Chapitre 5 - 1.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 17_37 - chapitre 5 - 2.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 18_37 - chapitre 5 - 3.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 19_37 - chapitre 5 - 4.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 20_37 - chapitre 5 - 5.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 21_37 - Partie 2 chapitre 6 - 1.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 22_37 - chapitre 6 - 2.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 23_37 - chapitre 7 - 1.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 24_37 - chapitre 7 - 2.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 25_37 - chapitre 7 - 3.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 26_37 - chapitre 8.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 27_37 - chapitre 9 - 1.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 28_37 - chapitre 9 - 2.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 29_37 - chapitre 10.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 30_37 - chapitre 11 - 1.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 31_37 - chapitre 11 - 2.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 32_37 - chapitre 12.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 33_37 - chapitre 13.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 34_37 - chapitre 14.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 35_37 - chapitre 15.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 36_37 - chapitre 16.mp3",
    "Audio Et l'Univers disparaitra de Gary Renard 37_37 - chapitre 17.mp3",
  ];

  print('\nTitles list');

  for (String title in titles) {
    print(title);
  }

  SortCriteria<String> chapterSortCriteria = SortCriteria<String>(
    selectorFunction: (String str) {
      final regex = RegExp(r'(\d+)_\d+');

      String strLow = str.toLowerCase();

      RegExpMatch? firstMatch = regex.firstMatch(strLow);

      if (firstMatch != null) {
        int firstMatchInt = int.parse(firstMatch.group(1)!);

        return firstMatchInt;
      }
      return strLow;
    },
    sortOrder: ascending,
  );

  List<dynamic> sortedChapters = sortChaptersByChapterCriteria(
    titles: titles,
    sortCriteria: chapterSortCriteria,
  );

  print('\nList sorted by chapter criteria ascending. BAD SORT !');

  for (String chapter in sortedChapters) {
    print(chapter);
  }

  SortCriteria<String> titleSortCriteria = SortCriteria<String>(
    selectorFunction: (String str) {
      return str.toLowerCase();
    },
    sortOrder: ascending,
  );

  List<dynamic> sortedTitles = sortTitlesByTitleCriteria(
    titles: titles,
    sortCriteria: titleSortCriteria,
  );

  print('\nList sorted by title criteria ascending. GOOD SORT !');

  for (String title in sortedTitles) {
    print(title);
  }

  print('\nTitles list');

  for (String title in audioChapters) {
    print(title);
  }

  sortedChapters = sortChaptersByChapterCriteria(
    titles: audioChapters,
    sortCriteria: chapterSortCriteria,
  );

  print('\nList sorted by chapter criteria ascending. GOOD SORT !');

  for (String chapter in sortedChapters) {
    print(chapter);
  }

  sortedTitles = sortTitlesByTitleCriteria(
    titles: audioChapters,
    sortCriteria: titleSortCriteria,
  );

  print('\nList sorted by title criteria ascending. BAD SORT !');

  for (String title in sortedTitles) {
    print(title);
  }
}

List<String> sortChaptersByChapterCriteria({
  required List<String> titles,
  required SortCriteria<String> sortCriteria,
}) {
  List<String> titlesLstCopy = List<String>.from(titles);

  titlesLstCopy.sort((a, b) {
    dynamic comparableA = sortCriteria.selectorFunction(a);
    dynamic comparableB = sortCriteria.selectorFunction(b);
    int comparison;

    if (comparableA.runtimeType == comparableB.runtimeType) {
      // sortOrder is 1 for ascending and -1 for descending
      comparison = comparableA.compareTo(comparableB) * sortCriteria.sortOrder;
    } else {
      comparison = a.compareTo(b) * sortCriteria.sortOrder;
    }

    if (comparison != 0) {
      return comparison;
    }

    return 0;
  });

  return titlesLstCopy;
}

List<String> sortTitlesByTitleCriteria({
  required List<String> titles,
  required SortCriteria<String> sortCriteria,
}) {
  List<String> titlesLstCopy = List<String>.from(titles);

  titlesLstCopy.sort((a, b) {
    int comparison = a.compareTo(b) * sortCriteria.sortOrder;

    if (comparison != 0) {
      return comparison;
    }

    return 0;
  });

  return titlesLstCopy;
}
