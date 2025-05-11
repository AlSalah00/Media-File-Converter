import 'dart:io';
import 'package:file_picker/file_picker.dart';

class PickedFilesResult {
  final List<PlatformFile> platformFiles;
  final List<File> files;
  final bool isValid;
  final String message;

  PickedFilesResult({
    required this.platformFiles,
    required this.files,
    required this.isValid,
    this.message = '',
  });
}

class FilePickerHelper {
  static Future<PickedFilesResult> pickFiles({
    required List<String> allowedExtensions,
    bool allowMultiple = true,
    int maxFiles = 5,
    int maxFileSize = 50 * 1024 * 1024, // default is 50MB
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );

    if (result != null) {
      List<PlatformFile> selected = result.files;

      // Limit the number of files
      if (selected.length > maxFiles) {
        selected = selected.sublist(0, maxFiles);
      }

      // Filter out files exceeding max size
      selected = selected.where((file) {
        if (file.size > maxFileSize) {
          return false;
        }
        return true;
      }).toList();

      if (selected.isEmpty) {
        return PickedFilesResult(
          platformFiles: [],
          files: [],
          isValid: false,
          message: 'No valid files selected. Some files exceed the size limit.',
        );
      }

      // Convert to List<File>
      List<File> files = selected
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();

      return PickedFilesResult(
        platformFiles:  selected,
        files: files,
        isValid: true,
        message: 'Files uploaded successfully.',
      );
    } else {
      return PickedFilesResult(
        platformFiles: [],
        files: [],
        isValid: false,
        message: 'File selection was canceled.',
      );
    }
  }
}
