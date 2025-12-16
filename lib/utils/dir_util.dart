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
          logger.i(
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
          logger.i(
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

  static void deleteMp3FilesInDir({
    required String filePath,
  }) {
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
          'Source directory $sourceRootPath does not exist. Please check the source directory path.');
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

  /// Returns the number of files in [directoryPath] whose file names end with
  /// [fileExtension]. The [fileExtension] must be provided without a leading dot,
  /// e.g. "mp3", "jpg", "json".
  ///
  /// If the directory does not exist, the method returns 0.
  ///
  /// The method checks only regular files (not directories).
  static int countFilesInDir({
    required String directoryPath,
    required String fileExtension,
  }) {
    final dir = Directory(directoryPath);

    if (!dir.existsSync()) {
      return 0;
    }

    // Normalize extension to lowercase for case-insensitive matching.
    final normalizedExt = fileExtension.toLowerCase();

    int count = 0;
    for (final entity in dir.listSync(followLinks: false)) {
      if (entity is File) {
        final name = entity.path.toLowerCase();
        if (name.endsWith('.$normalizedExt')) {
          count++;
        }
      }
    }

    return count;
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

  /// Returns '':
  /// - the directory to rename does not exist; or
  /// - a directory with the new name already exists.
  ///
  /// Otherwise renames the directory and returns the
  /// renamed directory path.
  static String renameDirectory({
    required String directoryToRenamePath,
    required String newDirectoryName,
  }) {
    final existingDir = Directory(directoryToRenamePath);

    // Check if the directory to rename exists
    if (!existingDir.existsSync()) {
      return '';
    }

    final String parent = existingDir.parent.path;
    final String newPath = path.join(parent, newDirectoryName);

    // Check if destination already exists
    final newDir = Directory(newPath);
    if (newDir.existsSync()) {
      return '';
    }

    try {
      existingDir.renameSync(newPath);
      return newPath;
    } catch (e) {
      logger.e('Error renaming directory: $e');
      return '';
    }
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

  /// Sets the creation time of a file in Windows.
  /// Returns true if successful, false otherwise.
  static Future<bool> setFileCreationTime({
    required String filePathName,
    required DateTime creationTime,
  }) async {
    if (!File(filePathName).existsSync()) {
      logger.i('Error: File does not exist: $filePathName');
      return false;
    }

    try {
      // Escape the path for PowerShell
      String escapedPath = _escapePowerShellPath(filePathName);
      String timeStr = _formatDateTimeForPowerShell(creationTime);

      final result = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          '\$file = Get-Item -LiteralPath "$escapedPath"; '
              '\$file.CreationTime = [DateTime]::Parse("$timeStr"); '
              'Write-Host "Success"'
        ],
      );

      if (result.exitCode == 0 &&
          result.stdout.toString().contains('Success')) {
        // Verify the change was applied
        DateTime? actualTime = getFileCreationDate(filePathName);
        if (actualTime != null) {
          // Allow 1 second difference due to precision
          return actualTime.difference(creationTime).inSeconds.abs() <= 1;
        }
      }

      if (result.exitCode != 0) {
        logger.i('PowerShell error: ${result.stderr}');
      }

      return false;
    } catch (e) {
      logger.i('Error setting file creation time: $e');
      return false;
    }
  }

  /// Sets the modification time of a file in Windows.
  /// Returns true if successful, false otherwise.
  static Future<bool> setFileModificationTime({
    required String filePathName,
    required DateTime modificationTime,
  }) async {
    if (!File(filePathName).existsSync()) {
      logger.i('Error: File does not exist: $filePathName');
      return false;
    }

    try {
      String escapedPath = _escapePowerShellPath(filePathName);
      String timeStr = _formatDateTimeForPowerShell(modificationTime);

      final result = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          '\$file = Get-Item -LiteralPath "$escapedPath"; '
              '\$file.LastWriteTime = [DateTime]::Parse("$timeStr"); '
              'Write-Host "Success"'
        ],
      );

      if (result.exitCode == 0 &&
          result.stdout.toString().contains('Success')) {
        // Verify the change was applied
        DateTime? actualTime = getFileModificationDate(filePathName);
        if (actualTime != null) {
          return actualTime.difference(modificationTime).inSeconds.abs() <= 1;
        }
      }

      if (result.exitCode != 0) {
        logger.i('PowerShell error: ${result.stderr}');
      }

      return false;
    } catch (e) {
      logger.i('Error setting file modification time: $e');
      return false;
    }
  }

  /// Sets the access time of a file in Windows.
  /// Returns true if successful, false otherwise.
  static Future<bool> setFileAccessTime({
    required String filePathName,
    required DateTime accessTime,
  }) async {
    if (!File(filePathName).existsSync()) {
      logger.i('Error: File does not exist: $filePathName');
      return false;
    }

    try {
      String escapedPath = _escapePowerShellPath(filePathName);
      String timeStr = _formatDateTimeForPowerShell(accessTime);

      final result = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          '\$file = Get-Item -LiteralPath "$escapedPath"; '
              '\$file.LastAccessTime = [DateTime]::Parse("$timeStr"); '
              'Write-Host "Success"'
        ],
      );

      return result.exitCode == 0 &&
          result.stdout.toString().contains('Success');
    } catch (e) {
      logger.i('Error setting file access time: $e');
      return false;
    }
  }

  /// Sets all file times (creation, modification, and optionally access time) at once.
  /// This is more efficient than calling individual methods.
  /// Returns true if all operations succeeded, false otherwise.
  static Future<bool> setAllFileTimes({
    required String filePathName,
    required DateTime creationTime,
    required DateTime modificationTime,
    DateTime? accessTime,
  }) async {
    if (!File(filePathName).existsSync()) {
      logger.i('Error: File does not exist: $filePathName');
      return false;
    }

    try {
      String escapedPath = _escapePowerShellPath(filePathName);
      String creationTimeStr = _formatDateTimeForPowerShell(creationTime);
      String modTimeStr = _formatDateTimeForPowerShell(modificationTime);
      String accessTimeStr = accessTime != null
          ? _formatDateTimeForPowerShell(accessTime)
          : modTimeStr;

      final command = '''
        \$file = Get-Item -LiteralPath "$escapedPath"
        \$file.CreationTime = [DateTime]::Parse("$creationTimeStr")
        \$file.LastWriteTime = [DateTime]::Parse("$modTimeStr")
        \$file.LastAccessTime = [DateTime]::Parse("$accessTimeStr")
        Write-Host "Success"
      ''';

      final result = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          command,
        ],
      );

      if (result.exitCode == 0 &&
          result.stdout.toString().contains('Success')) {
        // Verify the changes were applied
        DateTime? actualCreation = getFileCreationDate(filePathName);
        DateTime? actualModification = getFileModificationDate(filePathName);

        if (actualCreation != null && actualModification != null) {
          bool creationOk =
              actualCreation.difference(creationTime).inSeconds.abs() <= 1;
          bool modificationOk =
              actualModification.difference(modificationTime).inSeconds.abs() <=
                  1;

          if (!creationOk) {
            logger.i(
                'Warning: Creation time verification failed. Expected: $creationTime, Got: $actualCreation');
          }
          if (!modificationOk) {
            logger.i(
                'Warning: Modification time verification failed. Expected: $modificationTime, Got: $actualModification');
          }

          return creationOk && modificationOk;
        }
      }

      if (result.exitCode != 0) {
        logger.i('PowerShell error: ${result.stderr}');
      }

      return false;
    } catch (e) {
      logger.i('Error setting file times: $e');
      return false;
    }
  }

  /// Gets the creation date of a file.
  /// Returns null if the file doesn't exist or an error occurs.
  static DateTime? getFileCreationDate(String filePathName) {
    try {
      File file = File(filePathName);

      if (!file.existsSync()) {
        return null;
      }

      return file.statSync().changed;
    } catch (e) {
      logger.i('Error getting file creation date: $e');
      return null;
    }
  }

  /// Gets the modification date of a file.
  /// Returns null if the file doesn't exist or an error occurs.
  static DateTime? getFileModificationDate(String filePathName) {
    try {
      File file = File(filePathName);

      if (!file.existsSync()) {
        return null;
      }

      return file.statSync().modified;
    } catch (e) {
      logger.i('Error getting file modification date: $e');
      return null;
    }
  }

  /// Gets the access date of a file.
  /// Returns null if the file doesn't exist or an error occurs.
  static DateTime? getFileAccessDate(String filePathName) {
    try {
      File file = File(filePathName);

      if (!file.existsSync()) {
        return null;
      }

      return file.statSync().accessed;
    } catch (e) {
      logger.i('Error getting file access date: $e');
      return null;
    }
  }

  /// Formats a DateTime for PowerShell in ISO 8601 format.
  /// This format is unambiguous and works across all locales.
  static String _formatDateTimeForPowerShell(DateTime dateTime) {
    // Use ISO 8601 format which PowerShell can parse reliably
    return dateTime.toIso8601String();
  }

  /// Escapes a file path for use in PowerShell commands.
  /// Handles backslashes and special characters properly.
  static String _escapePowerShellPath(String path) {
    // Replace single backslashes with double backslashes for PowerShell
    // and escape any single quotes
    return path.replaceAll("'", "''");
  }

  /// Prints all date information for a file (useful for debugging).
  static void printFileDates(String filePathName) {
    if (!File(filePathName).existsSync()) {
      logger.i('File does not exist: $filePathName');
      return;
    }

    logger.i('\n=== File Date Information ===');
    logger.i('File: $filePathName');
    logger.i('Creation Time:     ${getFileCreationDate(filePathName)}');
    logger.i('Modification Time: ${getFileModificationDate(filePathName)}');
    logger.i('Access Time:       ${getFileAccessDate(filePathName)}');
    logger.i('=============================\n');
  }
}
