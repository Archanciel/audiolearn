// ignore_for_file: avoid_print

import 'dart:io';
import 'package:archive/archive.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';

enum CopyOrMoveFileResult {
  copiedOrMoved,
  targetFileAlreadyExists,
  sourceFileNotExist,
  audioNotKeptInSourcePlaylist,
}

class DirUtil {
  static final Logger logger = Logger();

  static List<String> readUrlsFromFile(String filePath) {
    try {
      // Read all lines from the file
      final file = File(filePath);
      List<String> lines = file.readAsLinesSync();

      // Filter out any empty lines
      lines = lines.where((line) => line.trim().isNotEmpty).toList();

      return lines;
    } catch (e) {
      logger.i('Error reading file: $e');
      return [];
    }
  }

  /// Returns the path of the application directory. If the application directory
  /// does not exist, it is created. The returned path depends on the platform.
  static String getApplicationPath({
    bool isTest = false,
  }) {
    String applicationPath = '';

    if (Platform.isWindows) {
      if (isTest) {
        applicationPath = kApplicationPathWindowsTest;
      } else {
        applicationPath = kApplicationPathWindows;
      }
    } else {
      if (isTest) {
        applicationPath = kApplicationPathAndroidTest;
      } else {
        applicationPath = kApplicationPath;
      }
    }

    // On Android or mobile emulator,/ avoids that the application
    // can not be run after it was installed on the smartphone
    Directory dir = Directory(applicationPath);

    if (!dir.existsSync()) {
      try {
        dir.createSync();
      } catch (e) {
        // Handle the exception, e.g., directory not created
        logger.i('Directory could not be created: $e');
      }
    }

    return applicationPath;
  }

  static String getPlaylistDownloadRootPath({
    bool isTest = false,
  }) {
    String playlistDownloadRootPath = '';

    if (Platform.isWindows) {
      if (isTest) {
        playlistDownloadRootPath = kPlaylistDownloadRootPathWindowsTest;
      } else {
        playlistDownloadRootPath = kPlaylistDownloadRootPathWindows;
      }
    } else {
      if (isTest) {
        playlistDownloadRootPath = kPlaylistDownloadRootPathAndroidTest;
      } else {
        playlistDownloadRootPath = kPlaylistDownloadRootPath;
      }
    }

    // On Android or mobile emulator,/ avoids that the application
    // can not be run after it was installed on the smartphone
    Directory dir = Directory(playlistDownloadRootPath);

    if (!dir.existsSync()) {
      try {
        // now create the playlist dir
        dir.createSync();
      } catch (e) {
        // Handle the exception, e.g., directory not created
        logger.i('Directory could not be created: $e');
      }
    }

    return playlistDownloadRootPath;
  }

  /// Returns the path of the application picture directory. If the application
  /// picture directory does not exist, it is created. The returned path depends
  /// on the platform.
  static String getApplicationPicturePath({
    bool isTest = false,
  }) {
    String applicationPicturePath = '';

    if (Platform.isWindows) {
      if (isTest) {
        applicationPicturePath = kApplicationPicturePathWindowsTest;
      } else {
        applicationPicturePath = kApplicationPicturePathWindows;
      }
    } else {
      if (isTest) {
        applicationPicturePath = kApplicationPicturePathAndroidTest;
      } else {
        applicationPicturePath = kApplicationPicturePath;
      }
    }

    // On Android or mobile emulator,/ avoids that the application
    // can not be run after it was installed on the smartphone
    Directory dir = Directory(applicationPicturePath);

    if (!dir.existsSync()) {
      try {
        dir.createSync();
      } catch (e) {
        // Handle the exception, e.g., directory not created
        logger.i('Directory could not be created: $e');
      }
    }

    return applicationPicturePath;
  }

  static String removeAudioDownloadHomePathFromPathFileName({
    required String pathFileName,
  }) {
    String path = getPlaylistDownloadRootPath();
    String pathFileNameWithoutHomePath = pathFileName.replaceFirst(path, '');

    return pathFileNameWithoutHomePath;
  }

  static Future<void> createDirIfNotExist({
    required String pathStr,
  }) async {
    final Directory directory = Directory(pathStr);
    bool directoryExists = await directory.exists();

    if (!directoryExists) {
      await directory.create(recursive: true);
    }
  }

  static void createDirIfNotExistSync({
    required String pathStr,
  }) async {
    final Directory directory = Directory(pathStr);
    bool directoryExists = directory.existsSync();

    if (!directoryExists) {
      directory.createSync(recursive: true);
    }
  }

  /// Delete the directory {pathStr}, the files it contains and
  /// its subdirectories.
  static void deleteDirAndSubDirsIfExist({
    required String rootPath,
  }) {
    final Directory directory = Directory(rootPath);

    if (directory.existsSync()) {
      try {
        directory.deleteSync(recursive: true);
      } catch (e) {
        logger.i("Error occurred while deleting directory: $e");
      }
    } else {
      logger.i("Directory does not exist.");
    }
  }

  static void deleteDirIfEmpty({
    required String pathStr,
  }) {
    final Directory directory = Directory(pathStr);

    if (directory.existsSync()) {
      try {
        // Check if the directory is empty
        if (directory.listSync().isEmpty) {
          directory.deleteSync();
        } else {
          logger.i("Directory is not empty.");
        }
      } catch (e) {
        logger.i("Error occurred while deleting directory: $e");
      }
    } else {
      logger.i("Directory does not exist.");
    }
  }

  static String getPathFromPathFileName({
    required String pathFileName,
  }) {
    return path.dirname(pathFileName);
  }

  static String getFileNameWithoutMp3Extension({
    required String mp3FileName,
  }) {
    return mp3FileName.substring(0, mp3FileName.length - 4);
  }

  static String getFileNameWithoutJsonExtension({
    required String jsonFileName,
  }) {
    return jsonFileName.substring(0, jsonFileName.length - 5);
  }

  static String getFileNameFromPathFileName({
    required String pathFileName,
  }) {
    return path.basename(pathFileName);
  }

  static void deleteFilesAndSubDirsOfDir({
    required String rootPath,
  }) {
    // Create a Directory object from the path
    final Directory directory = Directory(rootPath);

    // Check if the directory exists
    if (directory.existsSync()) {
      try {
        // List all contents of the directory
        List<FileSystemEntity> entities = directory.listSync(recursive: false);

        for (FileSystemEntity entity in entities) {
          // Check if the entity is a file and delete it
          if (entity is File) {
            entity.deleteSync();
          }
          // Check if the entity is a directory and delete it recursively
          else if (entity is Directory) {
            entity.deleteSync(recursive: true);
          }
        }
      } catch (e) {
        logger.i('Failed to delete subdirectories or files: $e');
      }
    } else {
      logger.i('The directory does not exist.');
    }
  }

  /// Delete all the files in the {rootPath} directory and its
  /// subdirectories. If {deleteSubDirectoriesAsWell} is true,
  /// the subdirectories and sub subdirectories of {rootPath} are
  /// deleted as well. The {rootPath} directory itself is not
  /// deleted.
  static void deleteFilesInDirAndSubDirs({
    required String rootPath,
    bool deleteSubDirectoriesAsWell = true,
  }) {
    final Directory directory = Directory(rootPath);

    // List the contents of the directory and its subdirectories
    final List<FileSystemEntity> contents = directory.listSync(recursive: true);

    // First, delete all the files
    for (FileSystemEntity entity in contents) {
      if (entity is File) {
        entity.deleteSync();
      }
    }

    // Then, delete the directories starting from the innermost ones
    if (deleteSubDirectoriesAsWell) {
      contents.reversed
          .whereType<Directory>()
          .forEach((dir) => dir.deleteSync());
    }
  }

  /// Delete all the files in the {rootPath} directory and its
  /// subdirectories. If {deleteSubDirectoriesAsWell} is true,
  /// the subdirectories and sub subdirectories of {rootPath} are
  /// deleted as well. The {rootPath} directory itself is not
  /// deleted.
  static void deleteFilesInDirAndSubDirsWithRetry({
    required String rootPath,
    bool deleteSubDirectoriesAsWell = true,
    int maxRetries = 5,
    Duration retryDelay = const Duration(milliseconds: 500),
  }) {
    final Directory directory = Directory(rootPath);

    if (!directory.existsSync()) {
      return; // Directory doesn't exist, nothing to delete
    }

    // List the contents of the directory and its subdirectories
    final List<FileSystemEntity> contents = directory.listSync(recursive: true);

    // First, delete all the files with retry logic
    for (FileSystemEntity entity in contents) {
      if (entity is File) {
        _deleteFileWithRetry(
          entity,
          maxRetries: maxRetries,
          retryDelay: retryDelay,
        );
      }
    }

    // Then, delete the directories starting from the innermost ones
    if (deleteSubDirectoriesAsWell) {
      final List<Directory> directories =
          contents.reversed.whereType<Directory>().toList();

      for (Directory dir in directories) {
        _deleteDirectoryWithRetry(
          dir,
          maxRetries: maxRetries,
          retryDelay: retryDelay,
        );
      }
    }
  }

  /// Helper method to delete a file with retry logic
  static void _deleteFileWithRetry(File file,
      {required int maxRetries, required Duration retryDelay}) {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        file.deleteSync();
        return; // Success
      } catch (e) {
        if (attempt == maxRetries - 1) {
          // Last attempt failed, log and rethrow
          print(
              'Failed to delete file ${file.path} after $maxRetries attempts: $e');
          rethrow;
        }

        // Wait before retrying with exponential backoff
        sleep(
            Duration(milliseconds: retryDelay.inMilliseconds * (attempt + 1)));
      }
    }
  }

  /// Helper method to delete a directory with retry logic
  static void _deleteDirectoryWithRetry(Directory directory,
      {required int maxRetries, required Duration retryDelay}) {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        directory.deleteSync();
        return; // Success
      } catch (e) {
        if (attempt == maxRetries - 1) {
          // Last attempt failed, log and rethrow
          print(
              'Failed to delete directory ${directory.path} after $maxRetries attempts: $e');
          rethrow;
        }

        // Wait before retrying with exponential backoff
        sleep(
            Duration(milliseconds: retryDelay.inMilliseconds * (attempt + 1)));
      }
    }
  }

  static void deleteFileIfExist({
    required String pathFileName,
  }) {
    final File file = File(pathFileName);

    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  static void deleteMp3FilesInDir(String filePath) {
    final directory = Directory(filePath);

    if (!directory.existsSync()) {
      logger.i("Directory does not exist.");
      return;
    }

    directory.listSync().forEach((file) {
      if (file is File && file.path.endsWith('.mp3')) {
        try {
          file.deleteSync();
        } catch (e) {
          logger.i("Error deleting file: ${file.path}, Error: $e");
        }
      }
    });
  }

  static void replaceFileContent({
    required String sourcePathFileName,
    required String targetPathFileName,
  }) {
    final String sourceFileContent =
        File(sourcePathFileName).readAsStringSync();
    final File file = File(targetPathFileName);

    if (file.existsSync()) {
      file.writeAsStringSync(sourceFileContent);
    }
  }

  /// This function copies all files and directories from a given
  /// source directory and its sub-directories to a target directory.
  ///
  /// It first checks if the source and target directories exist,
  /// and creates the target directory if it does not exist. It then
  /// iterates through all the contents of the source directory and
  /// its sub-directories, creating any directories that do not exist
  /// in the target directory and copying any files to the
  /// corresponding paths in the target directory.
  static void copyFilesFromDirAndSubDirsToDirectory({
    required String sourceRootPath,
    required String destinationRootPath,
  }) {
    final Directory sourceDirectory = Directory(sourceRootPath);
    final Directory targetDirectory = Directory(destinationRootPath);

    if (!sourceDirectory.existsSync()) {
      logger.i(
          'Source directory does not exist. Please check the source directory path.');
      return;
    }

    if (!targetDirectory.existsSync()) {
      logger.i(
          'Target directory $destinationRootPath does not exist. Creating...');
      targetDirectory.createSync(recursive: true);
    }

    final List<FileSystemEntity> contents =
        sourceDirectory.listSync(recursive: true);

    for (FileSystemEntity entity in contents) {
      String relativePath = path.relative(entity.path, from: sourceRootPath);
      String newPath = path.join(destinationRootPath, relativePath);

      if (entity is Directory) {
        Directory(newPath).createSync(recursive: true);
      } else if (entity is File) {
        entity.copySync(newPath);
      }
    }
  }

  /// Copies a file to a target directory if the file does not already exist in the
  /// target directory. True is returned if the file was copied, false otherwise.
  static bool copyFileToDirectoryIfNotExistSync({
    required String sourceFilePathName,
    required String targetDirectoryPath,
    String? targetFileName,
  }) {
    File sourceFile = File(sourceFilePathName);

    if (!sourceFile.existsSync()) {
      return false;
    }

    String copiedFileName = targetFileName ?? sourceFile.uri.pathSegments.last;
    String targetPathFileName =
        '$targetDirectoryPath${path.separator}$copiedFileName';

    // If the target file already exists, do not copy it again
    if (File(targetPathFileName).existsSync()) {
      return false;
    }

    // Create the target directory if it does not exist
    Directory targetDirectory = Directory(targetDirectoryPath);

    if (!targetDirectory.existsSync()) {
      targetDirectory.createSync(recursive: true);
    }

    sourceFile.copySync(targetPathFileName);

    return true;
  }

  static List<String> getPlaylistPathFileNamesLst({
    required String baseDir,
  }) {
    final playlistsDir = Directory(baseDir);
    final List<String> jsonPathFileNamesLst = [];

    // Check if the directory exists
    if (!playlistsDir.existsSync()) {
      logger.i('Error: Directory $baseDir does not exist.');
      return jsonPathFileNamesLst;
    }

    // Get all subdirectories in the playlists directory
    for (final entity in playlistsDir.listSync()) {
      if (entity is Directory) {
        // For each subdirectory, look for JSON files
        for (final file in entity.listSync()) {
          if (file is File &&
              file.path.endsWith('.json') &&
              !file.path.endsWith('settings.json')) {
            jsonPathFileNamesLst.add(file.path);
          }
        }
      }
    }

    return jsonPathFileNamesLst;
  }

  static List<String> listPathFileNamesInSubDirs({
    required String rootPath,
    required String fileExtension,
    List<String>? excludeDirNamesLst, // List of directory names to exclude
  }) {
    List<String> pathFileNameList = [];

    final Directory dir = Directory(rootPath);
    final RegExp pattern = RegExp(r'\.' + RegExp.escape(fileExtension) + r'$');
    List<RegExp>? excludePatterns;

    if (excludeDirNamesLst != null && excludeDirNamesLst.isNotEmpty) {
      excludePatterns = excludeDirNamesLst
          .map((dirName) => RegExp(RegExp.escape(dirName) + r'[/\\]'))
          .toList();
    }

    for (FileSystemEntity entity
        in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is File && pattern.hasMatch(entity.path)) {
        bool shouldExclude = false;

        // Check if the file's path contains any of the excluded directory names
        if (excludePatterns != null) {
          shouldExclude =
              excludePatterns.any((pattern) => pattern.hasMatch(entity.path));
        }

        if (!shouldExclude) {
          // Check if the file is not directly in the root path
          String relativePath = entity.path
              .replaceFirst(RegExp(RegExp.escape(rootPath) + r'[/\\]?'), '');
          if (relativePath.contains(Platform.pathSeparator)) {
            pathFileNameList.add(entity.path);
          }
        }
      }
    }

    return pathFileNameList;
  }

  /// List all the file names in a directory with a given extension.
  ///
  /// If the directory does not exist, an empty list is returned.
  static List<String> listFileNamesInDir({
    required String directoryPath,
    required String fileExtension,
  }) {
    List<String> fileNameList = [];

    final dir = Directory(directoryPath);

    if (!dir.existsSync()) {
      return fileNameList;
    }

    final pattern = RegExp(r'\.' + RegExp.escape(fileExtension) + r'$');

    for (FileSystemEntity entity
        in dir.listSync(recursive: false, followLinks: false)) {
      if (entity is File && pattern.hasMatch(entity.path)) {
        fileNameList.add(entity.path.split(Platform.pathSeparator).last);
      }
    }

    return fileNameList;
  }

  /// Lists all the file path names in a directory with a given extension.
  ///
  /// If the directory does not exist, an empty list is returned.
  static List<String> listPathFileNamesInDir({
    required String directoryPath,
    required String fileExtension,
  }) {
    List<String> fileNameList = [];

    final dir = Directory(directoryPath);

    // Check if the directory exists
    if (!dir.existsSync()) {
      return fileNameList;
    }

    // Create a pattern to match files with the given extension
    final pattern = RegExp(r'\.' + RegExp.escape(fileExtension) + r'$');

    // Iterate through the directory's contents
    for (FileSystemEntity entity
        in dir.listSync(recursive: false, followLinks: false)) {
      // Check if the entity is a file and matches the pattern
      if (entity is File && pattern.hasMatch(entity.path)) {
        fileNameList.add(entity.path);
      }
    }

    return fileNameList;
  }

  /// If [targetFileName] is not provided, the moved file will
  /// have the same name than the source file name.
  ///
  /// Returns CopyOrMoveFileResult.copiedOrMoved if the file has
  /// been moved, targetFileAlreadyExists or sourceFileNotExist
  /// otherwise, which happens if the moved file already exist in
  /// the target directory or if the file does not exist in the
  /// source directory.
  static CopyOrMoveFileResult moveFileToDirectoryIfNotExistSync({
    required String sourceFilePathName,
    required String targetDirectoryPath,
    String? targetFileName,
  }) {
    File sourceFile = File(sourceFilePathName);
    String copiedFileName = targetFileName ?? sourceFile.uri.pathSegments.last;
    String targetPathFileName =
        '$targetDirectoryPath${path.separator}$copiedFileName';

    // Create the target directory if it does not exist
    Directory targetDirectory = Directory(targetDirectoryPath);

    if (!targetDirectory.existsSync()) {
      targetDirectory.createSync(recursive: true);
    }

    // If the source file does not exist or the target file already exist and
    // move is not performed and a CopyOrMoveFileResult is returned.

    if (!sourceFile.existsSync()) {
      return CopyOrMoveFileResult.sourceFileNotExist;
    }

    if (File(targetPathFileName).existsSync()) {
      return CopyOrMoveFileResult.targetFileAlreadyExists;
    }

    sourceFile.renameSync(targetPathFileName);

    return CopyOrMoveFileResult.copiedOrMoved;
  }

  /// If [targetFileName] is not provided, the copied file will
  /// have the same name than the source file name.
  ///
  /// Returns CopyOrMoveFileResult.copiedOrMoved if the file has
  /// been copied, targetFileAlreadyExists or sourceFileNotExist
  /// otherwise, which happens if the moved file already exist in
  /// the target directory or if the file does not exist in the
  /// source directory.
  static CopyOrMoveFileResult copyFileToDirectorySync({
    required String sourceFilePathName,
    required String targetDirectoryPath,
    String? targetFileName,
    bool overwriteFileIfExist = false,
  }) {
    File sourceFile = File(sourceFilePathName);
    String copiedFileName = targetFileName ?? sourceFile.uri.pathSegments.last;
    String targetPathFileName =
        '$targetDirectoryPath${path.separator}$copiedFileName';

    // Create the target directory if it does not exist
    Directory targetDirectory = Directory(targetDirectoryPath);

    if (!targetDirectory.existsSync()) {
      targetDirectory.createSync(recursive: true);
    }

    // If the source file does not exist or the target file already exist and
    // overwriteFileIfExist is not true, copy is not performed and a
    // CopyOrMoveFileResult is returned.

    if (!sourceFile.existsSync()) {
      return CopyOrMoveFileResult.sourceFileNotExist;
    }

    if (!overwriteFileIfExist && File(targetPathFileName).existsSync()) {
      return CopyOrMoveFileResult.targetFileAlreadyExists;
    }

    sourceFile.copySync(targetPathFileName);

    return CopyOrMoveFileResult.copiedOrMoved;
  }

  /// Return false in case the file to rename does not exist or if a file named
  /// as newFileName already exists. In those cases, no file is renamed.
  static bool renameFile({
    required String fileToRenameFilePathName,
    required String newFileName,
  }) {
    File sourceFile = File(fileToRenameFilePathName);

    if (!sourceFile.existsSync()) {
      return false;
    }

    // Get the directory of the source file
    String dirPath = path.dirname(fileToRenameFilePathName);

    // Create the new file path with the new file name
    String newFilePathName = path.join(dirPath, newFileName);

    // Check if a file with the new name already exists
    if (File(newFilePathName).existsSync()) {
      return false;
    }

    // Rename the file
    sourceFile.renameSync(newFilePathName);

    return true;
  }

  static void replacePlaylistRootPathInSettingsJsonFiles({
    required String directoryPath,
    required String oldRootPath,
    required String newRootPath,
  }) {
    Directory directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      logger.i('Directory does not exist');
      return;
    }

    if (newRootPath.contains('\\')) {
      newRootPath = newRootPath.replaceAll('\\', '\\\\');
    }

    // List all files and directories within the current directory
    List<FileSystemEntity> entities = directory.listSync(recursive: true);
    for (FileSystemEntity entity in entities) {
      if (entity is File && entity.path.endsWith('settings.json')) {
        replaceInFile(entity, oldRootPath, newRootPath);
      }
    }
  }

  static void replaceInFile(
    File file,
    String oldRootPath,
    String newRootPath,
  ) {
    String content = file.readAsStringSync();

    if (content.contains(oldRootPath)) {
      final newContent = content.replaceAll(oldRootPath, newRootPath);
      file.writeAsStringSync(newContent);
    }
  }

  /// Function to save a string to a text file
  static void saveStringToFile({
    required String pathFileName,
    required String content,
  }) {
    File file = File(pathFileName);

    // Write the content to the file
    file.writeAsStringSync(content);
  }

  /// Function to read a string from a text file
  static String readStringFromFile({
    required String pathFileName,
  }) {
    File file = File(pathFileName);

    // Read the content of the file
    return file.readAsStringSync();
  }

  static Future<List<String>> listPathFileNamesInZip({
    required String zipFilePathName,
  }) async {
    // Open the zip file
    File zipFile = File(zipFilePathName);
    List<int> bytes = await zipFile.readAsBytes();

    // Decode the zip file
    Archive archive = ZipDecoder().decodeBytes(bytes);

    // List to store the full paths of files
    List<String> filePaths = [];

    // Loop through the archive files and get their full paths (name includes directories)
    for (ArchiveFile file in archive) {
      if (!file.isFile) continue; // Skip directories
      filePaths
          .add(file.name); // File name includes the full path inside the zip
    }

    return filePaths;
  }
}
