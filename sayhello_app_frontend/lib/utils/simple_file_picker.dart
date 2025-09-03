import 'package:file_picker/file_picker.dart';

class SimpleFilePicker {
  static Future<Map<String, dynamic>?> pickFile() async {
    try {
      print('Starting simple file picker...');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print('File selected: ${file.name}, size: ${file.size} bytes');

        return {
          'name': file.name,
          'bytes': file.bytes,
          'size': file.size,
          'extension': file.extension,
          'path': file.path,
        };
      }

      print('No file selected');
      return null;
    } catch (e) {
      print('Simple file picker error: $e');
      return null;
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
