// lib/utils/path_util.dart
import 'dart:io';

class PathUtil {
  static final RegExp _illegal = RegExp(r'[<>:"/\\|?*\x00-\x1F]');
  static final RegExp _dots = RegExp(r'[. ]+$');

  static String sanitizeFileName(String name) {
    String n = name.replaceAll(_illegal, '-');
    n = n.replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'-{2,}'), '-').trim();
    n = n.replaceAll(_dots, '');
    if (n.isEmpty) n = 'output.mp3';
    if (!n.toLowerCase().endsWith('.mp3')) n = '$n.mp3';
    if (Platform.isWindows && n.length > 180) {
      const ext = '.mp3';
      n = '${n.substring(0, 180 - ext.length)}$ext';
    }
    return n;
  }

  static String fileName(String fullPath) {
    final sep = Platform.pathSeparator;
    return fullPath.split(sep).last;
  }

  /// Safely remove the last extension from a file name.
  static String removeExtension(String fileName) {
    final i = fileName.lastIndexOf('.');
    return i > 0 ? fileName.substring(0, i) : fileName;
  }
}
