import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerHelper {
  static Future<Map<String, dynamic>?> pickFile({
    required String type,
    bool withData = true,
  }) async {
    try {
      // First check if we're on a supported platform
      if (kIsWeb) {
        // Web platform
        return await _pickFileWeb(type: type, withData: withData);
      } else {
        // Mobile/Desktop platform
        return await _pickFileMobile(type: type, withData: withData);
      }
    } catch (e) {
      print('FilePickerHelper error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _pickFileWeb({
    required String type,
    bool withData = true,
  }) async {
    try {
      FilePickerResult? result;

      if (type == 'image') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: withData,
        );
      } else {
        List<String> allowedExtensions = [];
        switch (type) {
          case 'pdf':
            allowedExtensions = ['pdf'];
            break;
          case 'doc':
            allowedExtensions = ['doc', 'docx'];
            break;
          default:
            allowedExtensions = ['pdf', 'doc', 'docx'];
        }

        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: allowedExtensions,
          allowMultiple: false,
          withData: withData,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        return {
          'name': file.name,
          'bytes': file.bytes,
          'size': file.size,
          'extension': file.extension,
          'path': file.path,
        };
      }
      return null;
    } catch (e) {
      print('Web file picker error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> _pickFileMobile({
    required String type,
    bool withData = true,
  }) async {
    try {
      // For images, try ImagePicker first as it's more reliable
      if (type == 'image') {
        try {
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
          );

          if (image != null) {
            final bytes = withData ? await image.readAsBytes() : null;
            final size = await image.length();

            return {
              'name': image.name,
              'bytes': bytes,
              'size': size,
              'extension': image.name.split('.').last,
              'path': image.path,
            };
          }
        } catch (imagePickerError) {
          print(
            'ImagePicker failed, falling back to FilePicker: $imagePickerError',
          );
          // Fall through to FilePicker
        }
      }

      // Use FilePicker as primary or fallback
      FilePickerResult? result;

      try {
        // Try with specific file types first
        if (type == 'image') {
          result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
            withData: withData,
          );
        } else {
          List<String> allowedExtensions = [];
          switch (type) {
            case 'pdf':
              allowedExtensions = ['pdf'];
              break;
            case 'doc':
              allowedExtensions = ['doc', 'docx'];
              break;
            default:
              allowedExtensions = ['pdf', 'doc', 'docx'];
          }

          result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: allowedExtensions,
            allowMultiple: false,
            withData: withData,
          );
        }
      } catch (specificError) {
        print('Specific file type picker failed: $specificError');

        // Fallback to any file type
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
          withData: withData,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        return {
          'name': file.name,
          'bytes': file.bytes,
          'size': file.size,
          'extension': file.extension,
          'path': file.path,
        };
      }
      return null;
    } catch (e) {
      print('Mobile file picker error: $e');
      rethrow;
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static bool validateFileType(String fileName, String expectedType) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (expectedType.toLowerCase()) {
      case 'pdf':
        return extension == 'pdf';
      case 'doc':
        return ['doc', 'docx'].contains(extension);
      case 'image':
        return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
      default:
        return true;
    }
  }
}
