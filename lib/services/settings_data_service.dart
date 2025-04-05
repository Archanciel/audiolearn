// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';
import '../utils/dir_util.dart';
import 'sort_filter_parameters.dart';

enum SettingType {
  appTheme,
  language,
  playlists,
  dataLocation,
  formatOfDate,
}

enum AppTheme {
  light,
  dark,
}

enum Language {
  english,
  french,
}

enum Playlists {
  orderedTitleLst, // Associated to this kex is the list of playlist titles
  //                  ordered by the user in clicking on up/down icon buttons
  //                  in the playlist download view.
  isMusicQualityByDefault,
  playSpeed,
  arePlaylistsDisplayedInPlaylistDownloadView,
}

enum DataLocation {
  appSettingsPath,
  playlistRootPath,
}

enum FormatOfDate {
  formatOfDate, // dd/MM/yyyy or MM/dd/yyyy or yyyy/MM/dd
}

/// ChatGPT recommanded: Use JSON serialization libraries like
/// json_serializable to simplify the JSON encoding and decoding
/// process. This will also help you avoid writing manual string
/// parsing code.
class SettingsDataService {
  // default settings are set in the constructor, namely default language,
  // default format of date and default theme
  final Map<SettingType, Map<dynamic, dynamic>> _settings = {
    SettingType.appTheme: {SettingType.appTheme: AppTheme.dark},
    SettingType.language: {SettingType.language: Language.english},
    SettingType.playlists: {
      Playlists.orderedTitleLst: [],
      Playlists.isMusicQualityByDefault: false,
      Playlists.playSpeed: kAudioDefaultPlaySpeed,

      // true -> the playlists are displayed in the playlist download
      // view.
      // false -> the playlist list is no longer expanded and so the
      // playlists are not displayed in the playlist download view.
      //
      // This changes when the user clicks on the playlist toggle button.
      Playlists.arePlaylistsDisplayedInPlaylistDownloadView: false,
    },
    SettingType.dataLocation: {
      DataLocation.appSettingsPath: '',
      DataLocation.playlistRootPath: '',
    },
    SettingType.formatOfDate: {
      FormatOfDate.formatOfDate: 'dd/MM/yyyy',
    },
  };

  Map<SettingType, Map<dynamic, dynamic>> get settings => _settings;

  final List<dynamic> _allSettingsKeyLst = [
    ...SettingType.values,
    ...AppTheme.values,
    ...Language.values,
    ...Playlists.values,
    ...DataLocation.values,
    ...FormatOfDate.values,
  ];

  final bool _isTest;
  bool get isTest => _isTest;

  // This map contains the named AudioSortFilterParameters. The
  // AudioSortFilterParameters by default is named 'default'
  final Map<String, AudioSortFilterParameters>
      _namedAudioSortFilterParametersMap = {};
  Map<String, AudioSortFilterParameters>
      get namedAudioSortFilterParametersMap =>
          _namedAudioSortFilterParametersMap;

  // This list contains the search history of AudioSortFilterParameters.
  // An AudioSortFilterParameters is added to the list when the user
  // clicks on the search button in the audio search view. The search
  // button which replaces the save button indicates that the defined
  // AudioSortFilterParameters isn't named. The search history list is
  // limited to a maximum number of elements.
  List<AudioSortFilterParameters> _searchHistoryAudioSortFilterParametersLst =
      [];
  List<AudioSortFilterParameters>
      get searchHistoryAudioSortFilterParametersLst =>
          _searchHistoryAudioSortFilterParametersLst;

  // The shared preferences are used to determine if the application is
  // started for the first time. If so, the json settings file does not
  // exist and the default settings are used. The shared preferences
  // are also used to store the isFirstRun value.
  final SharedPreferences _sharedPreferences;

  SettingsDataService({
    required SharedPreferences sharedPreferences,
    bool isTest = false,
  })  : _isTest = isTest,
        _sharedPreferences = sharedPreferences;

  dynamic get({
    required SettingType settingType,
    required dynamic settingSubType,
  }) {
    return _settings[settingType]![settingSubType];
  }

  /// Usage examples:
  ///
  /// initialSettings.set(
  ///     settingType: SettingType.appTheme,
  ///     settingSubType: SettingType.appTheme,
  ///     value: AppTheme.dark);
  ///
  /// initialSettings.set(
  ///     settingType: SettingType.language,
  ///     settingSubType: SettingType.language,
  ///     value: Language.french);
  ///
  /// initialSettings.set(
  ///     settingType: SettingType.playlists,
  ///     settingSubType: Playlists.rootPath,
  ///     value: kDownloadAppTestDirWindows);
  ///
  /// initialSettings.set(
  ///     settingType: SettingType.playlists,
  ///     settingSubType: Playlists.pathLst,
  ///     value: ['\\one', '\\two']);
  ///
  /// initialSettings.set(
  ///     settingType: SettingType.playlists,
  ///     settingSubType: Playlists.isMusicQualityByDefault,
  ///     value: true);
  ///
  /// initialSettings.set(
  ///     settingType: SettingType.playlists,
  ///     settingSubType: Playlists.defaultAudioSort,
  ///     value: AudioSortCriterion.validVideoTitle);
  ///
  /// initialSettings.set(
  ///     settingType: SettingType.playlists,
  ///     settingSubType: Playlists.arePlaylistsDisplayedInPlaylistDownloadView,
  ///     value: true);
  void set({
    required SettingType settingType,
    required dynamic settingSubType,
    required dynamic value,
  }) {
    _settings[settingType]![settingSubType] = value;
  }

  void saveSettings() {
    _saveSettings();
  }

  /// Method called by PlaylistListVM when the user clicks on the up or
  /// down icon button in the playlist download view. The method updates
  /// the playlist order list and saves the settings.
  void updatePlaylistOrderAndSaveSettings({
    required List<String> playlistOrder,
  }) {
    _settings[SettingType.playlists]![Playlists.orderedTitleLst] =
        playlistOrder;

    _saveSettings();
  }

  /// Method called by PlaylistListVM when the user select the left appbar menu
  /// 'Restore Playlists, Comments and Settings from Zip File' in the playlist
  /// download view. The method updates the playlist order list, extract the
  /// _namedAudioSortFilterParametersMap and the
  /// _searchHistoryAudioSortFilterParametersLst from the existing settings file
  /// and add their content to the current settings before and saving them in the
  /// settings file.
  void updatePlaylistOrderAddExistingAudioSortFilterSettingsAndSave({
    required List<String> playlistOrder,
  }) {
    _settings[SettingType.playlists]![Playlists.orderedTitleLst] =
        playlistOrder;

    // Retrieve the current settings file path

    final String applicationPath = DirUtil.getApplicationPath(
      isTest: _isTest,
    );
    final String settingsFilePath =
        "$applicationPath${Platform.pathSeparator}$kSettingsFileName";
    final File settingsFile = File(settingsFilePath);

    // If the settings file exists, extract the audio sort/filter settings.
    if (settingsFile.existsSync()) {
      try {
        final String jsonString = settingsFile.readAsStringSync();
        final Map<String, dynamic> existingSettings = jsonDecode(jsonString);

        // Extract the named audio sort/filter parameters if they exist.
        if (existingSettings.containsKey('namedAudioSortFilterSettings')) {
          final Map<String, dynamic> namedSettingsJson =
              existingSettings['namedAudioSortFilterSettings'];
          namedSettingsJson.forEach((audioKey, audioValue) {
            _namedAudioSortFilterParametersMap[audioKey] =
                AudioSortFilterParameters.fromJson(audioValue);
          });
        }

        // Extract the search history of audio sort/filter parameters if it exists.
        if (existingSettings
            .containsKey('searchHistoryOfAudioSortFilterSettings')) {
          final String searchHistoryJsonString =
              existingSettings['searchHistoryOfAudioSortFilterSettings'];
          final List<dynamic> historyList = jsonDecode(searchHistoryJsonString);
          _searchHistoryAudioSortFilterParametersLst.addAll(historyList
              .map((element) => AudioSortFilterParameters.fromJson(element)));
        }
      } catch (e) {
        print('Error while extracting audio sort/filter settings: $e');
      }
    }

    // Save the updated settings (including the merged audio sort/filter settings)
    _saveSettings();
  }

  // Save settings to a JSON file. This method is not private because
  // it is used in unit tests.
  void saveSettingsToFile({
    required String jsonPathFileName,
  }) {
    final File file = File(jsonPathFileName);
    final Map<String, dynamic> convertedSettings = _settings.map((key, value) {
      return MapEntry(
        key.toString(),
        value.map((subKey, subValue) =>
            MapEntry(subKey.toString(), subValue.toString())),
      );
    });
    final Map<String, dynamic> namedAudioSortFilterSettingsJson =
        _namedAudioSortFilterParametersMap
            .map((key, value) => MapEntry(key, value.toJson()));

    convertedSettings['namedAudioSortFilterSettings'] =
        namedAudioSortFilterSettingsJson;

    final String searchHistoryAudioSortFilterParametersLstJsonString =
        jsonEncode(_searchHistoryAudioSortFilterParametersLst
            .map((audioSortFilterParameters) =>
                audioSortFilterParameters.toJson())
            .toList());

    convertedSettings['searchHistoryOfAudioSortFilterSettings'] =
        searchHistoryAudioSortFilterParametersLstJsonString;

    final String jsonString = jsonEncode(convertedSettings);

    file.writeAsStringSync(jsonString);
  }

  /// Load settings from a JSON file
  Future<void> loadSettingsFromFile({
    required String settingsJsonPathFileName,
  }) async {
    final File file = File(settingsJsonPathFileName);
    final bool settingsJsonFileExist = file.existsSync();

    // This test enables to avoid that the supportedLocales.dart unit
    // tests fail due to the fact that flutter_test.exe remains active
    // and blocks the possibility for DirUtil to delete the test data
    // once a unit test is completed.
    if (!_isTest) {
      await _checkFirstRun(
        settingsJsonFile: file,
        settingsJsonFileExist: settingsJsonFileExist,
      );
    }

    try {
      if (settingsJsonFileExist) {
        // if settings json file not exist, then the default Settings values
        // set in the Settings constructor are used ...
        final String jsonString = file.readAsStringSync();
        final Map<String, dynamic> decodedSettings = jsonDecode(jsonString);
        decodedSettings.forEach((key, value) {
          if (key == 'namedAudioSortFilterSettings') {
            Map<String, dynamic> audioSortFilterSettingsJson = value;
            audioSortFilterSettingsJson.forEach((audioKey, audioValue) {
              _namedAudioSortFilterParametersMap[audioKey] =
                  AudioSortFilterParameters.fromJson(audioValue);
            });
          } else if (key == 'searchHistoryOfAudioSortFilterSettings') {
            _searchHistoryAudioSortFilterParametersLst =
                List<AudioSortFilterParameters>.from(jsonDecode(value).map(
                    (audioSortFilterParameters) =>
                        AudioSortFilterParameters.fromJson(
                            audioSortFilterParameters)));
          } else {
            final settingType = _parseEnumValue(SettingType.values, key);
            final subSettings =
                (value as Map<String, dynamic>).map((subKey, subValue) {
              return MapEntry(
                _parseEnumValue(_allSettingsKeyLst, subKey),
                _parseJsonValue(_allSettingsKeyLst, subValue),
              );
            });
            _settings[settingType] = subSettings;
          }
        });
      }
    } on PathAccessException catch (e) {
      // the case when installing the app and running it for the first
      // time. The app will start with the default settings. When the
      // user changes the settings, the settings file will be created
      // and the settings will loaded the next time the app is started.
      print(e.toString());
    }

    if (get(
            settingType: SettingType.dataLocation,
            settingSubType: DataLocation.appSettingsPath)
        .isEmpty) {
      // the case if the application is started for the first time and
      // if the settings were not saved.
      set(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.appSettingsPath,
        value: DirUtil.getApplicationPath(
          isTest: _isTest,
        ),
      );
    }

    if (get(
      settingType: SettingType.dataLocation,
      settingSubType: DataLocation.playlistRootPath,
    ).isEmpty) {
      // the case if the application is started for the first time and
      // if the settings were not saved.
      set(
        settingType: SettingType.dataLocation,
        settingSubType: DataLocation.playlistRootPath,
        value: DirUtil.getPlaylistDownloadRootPath(
          isTest: _isTest,
        ),
      );
    }
  }

  void savePlaylistTitleOrder({
    required String directory,
  }) {
    // Safely retrieve and convert the list to a List<String>
    final List<String> orderedPlaylistTitleLst =
        (_settings[SettingType.playlists]![Playlists.orderedTitleLst]
                as List<dynamic>)
            .map((e) => e.toString())
            .toList();
    final String orderedPlaylistTitlesStr = orderedPlaylistTitleLst.join(', ');

    DirUtil.saveStringToFile(
      pathFileName:
          "$directory${path.separator}$kOrderedPlaylistTitlesFileName",
      content: orderedPlaylistTitlesStr,
    );
  }

  /// Once the playlist root path is changed, before the change, the playlist
  /// title order is saved in the initial playlist root path. If after the
  /// change, the user reset the playlist root path to the initial playlist
  /// root path, then the previously saved playlist title order is restored.
  void restorePlaylistTitleOrderIfExistAndSaveSettings({
    required String directoryContainingPreviouslySavedPlaylistTitleOrder,
  }) {
    String pathFileName =
        "$directoryContainingPreviouslySavedPlaylistTitleOrder${path.separator}$kOrderedPlaylistTitlesFileName";
    final File file = File(pathFileName);

    if (!file.existsSync()) {
      return;
    }

    final String orderedPlaylistTitlesStr = DirUtil.readStringFromFile(
      pathFileName: pathFileName,
    );

    final List<String> orderedPlaylistTitleLst = orderedPlaylistTitlesStr
        .split(', ')
        .where((element) => element.isNotEmpty)
        .toList();

    _settings[SettingType.playlists]![Playlists.orderedTitleLst] =
        orderedPlaylistTitleLst;

    _saveSettings();
  }

  Future<void> _checkFirstRun({
    required File settingsJsonFile,
    required bool settingsJsonFileExist,
  }) async {
    bool isFirstRun = (_sharedPreferences.getBool('isFirstRun') ?? true);

    if (isFirstRun) {
      await _sharedPreferences.setBool('isFirstRun', false);
    }
  }

  void addOrReplaceNamedAudioSortFilterParameters({
    required String audioSortFilterParametersName,
    required AudioSortFilterParameters audioSortFilterParameters,
  }) {
    _namedAudioSortFilterParametersMap[audioSortFilterParametersName] =
        audioSortFilterParameters;

    _saveSettings();
  }

  void addAudioSortFilterParametersToSearchHistory({
    required AudioSortFilterParameters audioSortFilterParameters,
  }) {
    if (_searchHistoryAudioSortFilterParametersLst
        .contains(audioSortFilterParameters)) {
      // existing sort/filter parms in the search history list is not
      // added again
      return;
    }

    if (audioSortFilterParameters ==
        AudioSortFilterParameters.createDefaultAudioSortFilterParameters()) {
      // default sort/filter parms are not added to the search history list
      return;
    }

    // if the search history list is full, remove the last element
    if (_searchHistoryAudioSortFilterParametersLst.length >=
        kMaxAudioSortFilterSettingsSearchHistory) {
      _searchHistoryAudioSortFilterParametersLst
          .removeAt(kMaxAudioSortFilterSettingsSearchHistory - 1);
    }

    _searchHistoryAudioSortFilterParametersLst.add(audioSortFilterParameters);

    _saveSettings();
  }

  void clearAudioSortFilterParametersSearchHistory() {
    _searchHistoryAudioSortFilterParametersLst.clear();

    _saveSettings();
  }

  /// Remove the audio sort/filter parameters from the search history list.
  /// Return true if the audio sort/filter parameters was found and removed,
  /// false otherwise.
  bool clearAudioSortFilterParametersSearchHistoryElement(
    AudioSortFilterParameters audioSortFilterParameters,
  ) {
    bool wasElementRemoved = _searchHistoryAudioSortFilterParametersLst.remove(
      audioSortFilterParameters,
    );

    _saveSettings();

    return wasElementRemoved;
  }

  /// Return the deleted audio sort/filter parameters if it was found and
  /// removed, null otherwise.
  AudioSortFilterParameters? deleteNamedAudioSortFilterParameters({
    required String audioSortFilterParametersName,
  }) {
    AudioSortFilterParameters? removedAudioSortFilterParameters =
        _namedAudioSortFilterParametersMap
            .remove(audioSortFilterParametersName);

    if (removedAudioSortFilterParameters != null) {
      _saveSettings();
    }

    return removedAudioSortFilterParameters;
  }

  void _saveSettings() {
    String applicationPath = DirUtil.getApplicationPath(
      isTest: _isTest,
    );
    saveSettingsToFile(
        jsonPathFileName:
            "$applicationPath${Platform.pathSeparator}$kSettingsFileName");
  }

  T _parseEnumValue<T>(List<T> enumValues, String stringValue) {
    T setting = enumValues[0];

    setting = enumValues.firstWhere((e) => e.toString() == stringValue);

    return setting;
  }

  /// This method is responsible for parsing a JSON value. Since the
  /// JSON value can be a variety of types, this method attempts to
  /// determine the type and parse accordingly.
  ///
  /// - If the JSON value is a list (e.g. "[1, 2, 3]"), the method
  ///   recursively calls itself to parse each element in the list.
  ///
  /// - If the JSON value is a boolean (either "true" or "false"), it
  ///   directly returns Dart's true or false respectively.
  ///
  /// - If the JSON value represents a file path (containing either a
  ///   forward slash '/' or a backslash '\\'), it directly returns the
  ///   value as it's assumed to be a string.
  ///
  /// - For all other cases, it assumes the JSON value represents an
  ///   enumeration value and attempts to parse it using the
  ///   `_parseEnumValue` method.
  ///
  /// The parameter `enumValues` is a list containing all possible enum
  /// values that are valid. `stringValue` is the raw string value from
  /// the JSON data.
  ///
  /// The return type is dynamic because the JSON value could map to
  /// several different Dart types (bool, String, List, or an enumeration
  /// type).
  dynamic _parseJsonValue(List<dynamic> enumValues, String stringValue) {
    if (stringValue.startsWith('[') && stringValue.endsWith(']')) {
      List<String> stringList =
          stringValue.substring(1, stringValue.length - 1).split(', ');
      return stringList
          .map((element) => _parseJsonValue(enumValues, element))
          .toList();
    } else if (stringValue == 'true') {
      // Handle JSON true
      return true;
    } else if (stringValue == 'false') {
      // Handle JSON false
      return false;
    } else if (_isFilePath(stringValue)) {
      // Handle file paths
      return stringValue;
    } else if (int.tryParse(stringValue) != null) {
      return int.parse(stringValue);
    } else if (double.tryParse(stringValue) != null) {
      return double.parse(stringValue);
    } else if (_allSettingsKeyLst
        .map((e) => e.toString())
        .contains(stringValue)) {
      // Handle enums
      return _parseEnumValue(enumValues, stringValue);
    } else {
      // Return the string value if it's not an enum
      return stringValue;
    }
  }

  bool _isFilePath(String value) {
    // A simple check to determine if the value is a file path.
    // You can adjust the condition as needed.
    return value.contains('\\') || value.contains('/storage');
  }
}