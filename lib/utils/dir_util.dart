// ignore_for_file: avoid_print

import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';

class DirUtil {
  static List<String> readUrlsFromFile(String filePath) {
    try {
      // Read all lines from the file
      final file = File(filePath);
      List<String> lines = file.readAsLinesSync();

      // Filter out any empty lines
      lines = lines.where((line) => line.trim().isNotEmpty).toList();

      return lines;
    } catch (e) {
      print('Error reading file: $e');
      return [];
    }
  }

  /// Returns the path of the application directory. If the application directory
  /// does not exist, it is created. The path returned depends on the platform.
  static String getApplicationPath({
    bool isTest = false,
  }) {
    if (Platform.isWindows) {
      if (isTest) {
        return kApplicationPathWindowsTest;
      } else {
        return kApplicationPathWindows;
      }
    } else {
      // On Android or mobile emulator
      // avoids that the application can not be run after it was
      // installed on the smartphone
      Directory dir = Directory(kApplicationPath);

      if (!dir.existsSync()) {
        try {
          dir.createSync();
        } catch (e) {
          // Handle the exception, e.g., directory not created
          print('Directory could not be created: $e');
        }
      }

      return kApplicationPath;
    }
  }

  static Future<String> getPlaylistDownloadRootPath({
    bool isTest = false,
  }) async {
    if (Platform.isWindows) {
      if (isTest) {
        return kPlaylistDownloadRootPathWindowsTest;
      } else {
        return kPlaylistDownloadRootPathWindows;
      }
    } else {
      // On Android or mobile emulator
      Directory dir = Directory(kPlaylistDownloadRootPath);

      if (!await dir.exists()) {
        try {
          // now create the playlist dir
          await dir.create();
        } catch (e) {
          // Handle the exception, e.g., directory not created
          print('Directory could not be created: $e');
        }
      }

      return kPlaylistDownloadRootPath;
    }
  }

  static Future<String> removeAudioDownloadHomePathFromPathFileName(
      {required String pathFileName}) async {
    String path = await getPlaylistDownloadRootPath();
    String pathFileNameWithoutHomePath = pathFileName.replaceFirst(path, '');

    return pathFileNameWithoutHomePath;
  }

  static void deleteAppDirOnEmulatorIfExist() {
    final Directory directory = Directory(kApplicationPath);

    // using await directory.exists did delete dir only on second
    // app restart. Uncomprehensible !
    bool directoryExists = directory.existsSync();

    if (directoryExists) {
      DirUtil.deleteFilesInDirAndSubDirs(
        rootPath: kApplicationPath,
      );
    }
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
        print("Error occurred while deleting directory: $e");
      }
    } else {
      print("Directory does not exist.");
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
        print('Failed to delete subdirectories or files: $e');
      }
    } else {
      print('The directory does not exist.');
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
      print("Directory does not exist.");
      return;
    }

    directory.listSync().forEach((file) {
      if (file is File && file.path.endsWith('.mp3')) {
        try {
          file.deleteSync();
        } catch (e) {
          print("Error deleting file: ${file.path}, Error: $e");
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
      print(
          'Source directory does not exist. Please check the source directory path.');
      return;
    }

    if (!targetDirectory.existsSync()) {
      print('Target directory does not exist. Creating...');
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

  static Future<void> copyFileToDirectory({
    required String sourceFilePathName,
    required String targetDirectoryPath,
    String? targetFileName,
  }) async {
    File sourceFile = File(sourceFilePathName);

    if (!await sourceFile.exists()) {
      return;
    }

    String copiedFileName = targetFileName ?? sourceFile.uri.pathSegments.last;
    String targetPathFileName =
        '$targetDirectoryPath${path.separator}$copiedFileName';

    await sourceFile.copy(targetPathFileName);
  }

  static List<String> listPathFileNamesInSubDirs({
    required String rootPath,
    required String fileExtension,
    String? excludeDirName, // Default directory name to exclude
  }) {
    List<String> pathFileNameList = [];

    final Directory dir = Directory(rootPath);
    final RegExp pattern = RegExp(r'\.' + RegExp.escape(fileExtension) + r'$');
    RegExp? excludePattern;

    if (excludeDirName != null) {
      excludePattern = RegExp(RegExp.escape(excludeDirName) + r'[/\\]');
    }

    for (FileSystemEntity entity
        in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is File && pattern.hasMatch(entity.path)) {
        // Check if the file's path does not contain the excluded directory name
        if (excludePattern == null || !excludePattern.hasMatch(entity.path)) {
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
  /// Returns true if the file has been moved, false otherwise
  /// which happens if the moved file already exist in the
  /// target directory.
  static bool moveFileToDirectoryIfNotExistSync({
    required String sourceFilePathName,
    required String targetDirectoryPath,
    String? targetFileName,
  }) {
    File sourceFile = File(sourceFilePathName);
    String copiedFileName = targetFileName ?? sourceFile.uri.pathSegments.last;
    String targetPathFileName =
        '$targetDirectoryPath${path.separator}$copiedFileName';

    // If the source file does not exist or the target file already exist,
    // move is not performed and false is returned.
    if (!sourceFile.existsSync() || File(targetPathFileName).existsSync()) {
      return false;
    }

    sourceFile.renameSync(targetPathFileName);

    return true;
  }

  /// If [targetFileName] is not provided, the copied file will
  /// have the same name than the source file name.
  ///
  /// Returns true if the file has been copied, false
  /// otherwise in case the copied file already exists in
  /// the target dir and {overwriteFileIfExist} is false.
  static bool copyFileToDirectorySync({
    required String sourceFilePathName,
    required String targetDirectoryPath,
    String? targetFileName,
    bool overwriteFileIfExist = false,
  }) {
    File sourceFile = File(sourceFilePathName);
    String copiedFileName = targetFileName ?? sourceFile.uri.pathSegments.last;
    String targetPathFileName =
        '$targetDirectoryPath${path.separator}$copiedFileName';

    // If the source file does not exist or the target file already exist and
    // overwriteFileIfExist is not true, copy is not performed and false is
    // returned.
    if (!sourceFile.existsSync() ||
        (!overwriteFileIfExist && File(targetPathFileName).existsSync())) {
      return false;
    }

    sourceFile.copySync(targetPathFileName);

    return true;
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
      print('Directory does not exist');
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
