import 'dart:convert';
import 'dart:io';

import 'package:audiolearn/models/comment.dart';

import '../models/audio.dart';
import '../models/playlist.dart';
import 'sort_filter_parameters.dart';

typedef FromJsonFunction<T> = T Function(Map<String, dynamic> jsonDataMap);
typedef ToJsonFunction<T> = Map<String, dynamic> Function(T model);

class ClassNotContainedInJsonFileException implements Exception {
  final String _className;
  final String _jsonFilePathName;
  final StackTrace _stackTrace;

  ClassNotContainedInJsonFileException({
    required String className,
    required String jsonFilePathName,
    StackTrace? stackTrace,
  })  : _className = className,
        _jsonFilePathName = jsonFilePathName,
        _stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() {
    return ('Class $_className not stored in $_jsonFilePathName file.\nStack Trace:\n$_stackTrace');
  }
}

class ClassNotSupportedByToJsonDataServiceException implements Exception {
  final String _className;
  final StackTrace _stackTrace;

  ClassNotSupportedByToJsonDataServiceException({
    required String className,
    StackTrace? stackTrace,
  })  : _className = className,
        _stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() {
    return ('Class $_className has no entry in JsonDataService._toJsonFunctionsMap.\nStack Trace:\n$_stackTrace');
  }
}

class ClassNotSupportedByFromJsonDataServiceException implements Exception {
  final String _className;
  final StackTrace _stackTrace;

  ClassNotSupportedByFromJsonDataServiceException({
    required String className,
    StackTrace? stackTrace,
  })  : _className = className,
        _stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() {
    return ('Class $_className has no entry in JsonDataService._fromJsonFunctionsMap.\nStack Trace:\n$_stackTrace');
  }
}

class ProblemInJsonFileException implements Exception {
  final String _jsonPathFileName;

  ProblemInJsonFileException({
    required String jsonPathFileName,
  }) : _jsonPathFileName = jsonPathFileName;

  @override
  String toString() {
    return (_jsonPathFileName);
  }
}

class JsonDataService {
  // typedef FromJsonFunction<T> = T Function(Map<String, dynamic> jsonDataMap);
  static final Map<Type, FromJsonFunction> _fromJsonFunctionsMap = {
    Audio: (jsonDataMap) => Audio.fromJson(jsonDataMap),
    Playlist: (jsonDataMap) => Playlist.fromJson(jsonDataMap),
    SortingItem: (jsonDataMap) => SortingItem.fromJson(jsonDataMap),
    AudioSortFilterParameters: (jsonDataMap) =>
        AudioSortFilterParameters.fromJson(jsonDataMap),
    Comment: (jsonDataMap) => Comment.fromJson(jsonDataMap),
  };

  // typedef ToJsonFunction<T> = Map<String, dynamic> Function(T model);
  static final Map<Type, ToJsonFunction> _toJsonFunctionsMap = {
    Audio: (model) => model.toJson(),
    Playlist: (model) => model.toJson(),
    SortingItem: (sortingItem) => sortingItem.toJson(),
    AudioSortFilterParameters: (audioSortFilterParameters) =>
        audioSortFilterParameters.toJson(),
    Comment: (model) => model.toJson(),
  };

  static void saveToFile({
    required dynamic model,
    required String path,
  }) {
    final String jsonStr = encodeJson(model);
    File(path).writeAsStringSync(jsonStr);
  }

  static dynamic loadFromFile({
    required String jsonPathFileName,
    required Type type,
  }) {
    if (File(jsonPathFileName).existsSync()) {
      final String jsonStr = File(jsonPathFileName).readAsStringSync();

      try {
        return decodeJson(jsonStr, type);
      } on StateError catch (_) {
        throw ProblemInJsonFileException(
          jsonPathFileName: jsonPathFileName,
        );
      } catch (e) {
        throw ClassNotContainedInJsonFileException(
          className: type.toString(),
          jsonFilePathName: jsonPathFileName,
        );
      }
    } else {
      return null;
    }
  }

  static String encodeJson(dynamic data) {
    if (data is List) {
      throw Exception(
          "encodeJson() does not support encoding list's. Use encodeJsonList() instead.");
    } else {
      final type = data.runtimeType;
      final toJsonFunction = _toJsonFunctionsMap[type];
      if (toJsonFunction != null) {
        return jsonEncode(toJsonFunction(data));
      }
    }

    return '';
  }

  static dynamic decodeJson(
    String jsonString,
    Type type,
  ) {
    final fromJsonFunction = _fromJsonFunctionsMap[type];

    if (fromJsonFunction != null) {
      final jsonData = jsonDecode(jsonString);
      if (jsonData is List) {
        throw Exception(
            "decodeJson() does not support decoding list's. Use decodeJsonList() instead.");
      } else {
        return fromJsonFunction(jsonData);
      }
    }

    return null;
  }

  static void saveListToFile({
    required String jsonPathFileName,
    required dynamic data,
  }) {
    String jsonStr = encodeJsonList(data);
    File(jsonPathFileName).writeAsStringSync(jsonStr);
  }

  static List<T> loadListFromFile<T>({
    required String jsonPathFileName,
    required Type type,
  }) {
    if (File(jsonPathFileName).existsSync()) {
      String jsonStr = File(jsonPathFileName).readAsStringSync();

      if (jsonStr.isEmpty) {
        return [];
      }
      
      try {
        return decodeJsonList(jsonStr, type);
      } on StateError {
        throw ClassNotContainedInJsonFileException(
          className: type.toString(),
          jsonFilePathName: jsonPathFileName,
        );
      }
    } else {
      return [];
    }
  }

  static String encodeJsonList(dynamic data) {
    if (data is List) {
      if (data.isNotEmpty) {
        final type = data.first.runtimeType;
        final toJsonFunction = _toJsonFunctionsMap[type];
        if (toJsonFunction != null) {
          return jsonEncode(data.map((e) => toJsonFunction(e)).toList());
        } else {
          throw ClassNotSupportedByToJsonDataServiceException(
            className: type.toString(),
          );
        }
      }
    } else {
      throw Exception(
          "encodeJsonList() only supports encoding list's. Use encodeJson() instead.");
    }

    return '';
  }

  static List<T> decodeJsonList<T>(
    String jsonString,
    Type type,
  ) {
    final fromJsonFunction = _fromJsonFunctionsMap[type];

    if (fromJsonFunction != null) {
      final jsonData = jsonDecode(jsonString);
      if (jsonData is List) {
        if (jsonData.isNotEmpty) {
          final list = jsonData.map((e) => fromJsonFunction(e)).toList();
          return list.cast<T>(); // Cast the list to the desired type
        } else {
          return <T>[]; // Return an empty list of the desired type
        }
      } else {
        throw Exception(
            "decodeJsonList() only supports decoding list's. Use decodeJson() instead.");
      }
    } else {
      throw ClassNotSupportedByFromJsonDataServiceException(
        className: type.toString(),
      );
    }
  }

  /// print jsonStr in formatted way
  static void printJsonString({
    required String methodName,
    required String jsonStr,
  }) {
    String prettyJson =
        const JsonEncoder.withIndent('  ').convert(json.decode(jsonStr));
    // ignore: avoid_print
    print('$methodName:\n$prettyJson');
  }
}
