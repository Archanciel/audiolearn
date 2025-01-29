// Custom Mock FilePicker
import 'package:file_picker/file_picker.dart';

class MockFilePicker extends FilePicker {
  String _pathToSelectStr = '';
  List<PlatformFile> _selectedFiles = [];

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

  @override
  Future<FilePickerResult?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    bool withData = false,
    bool allowCompression = true,
    int compressionQuality = 100, // New parameter
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
    dynamic Function(FilePickerStatus)? onFileLoading, // New parameter
    bool readSequential = false, // New parameter
    bool withReadStream = false, // New parameter
  }) async {
    if (_selectedFiles.isEmpty) {
      return null;
    }
    return FilePickerResult(_selectedFiles);
  }

  void setSelectedFiles(List<PlatformFile> files) {
    _selectedFiles = files;
  }
}
