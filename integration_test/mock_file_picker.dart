// Custom Mock FilePicker
import 'package:file_picker/file_picker.dart';

class MockFilePicker extends FilePicker {
  String _pathToSelectStr = '';

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async {
    return _pathToSelectStr;
  }

  void setPathToSelect({
    required String pathToSelectStr,
  }) {
    _pathToSelectStr = pathToSelectStr;
  }
}
