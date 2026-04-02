import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transfer_file_model.dart';

class FileService {
  static Future<List<TransferFileModel>> pickFiles({FileType type = FileType.any}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: type,
    );

    if (result != null) {
      return result.files.map((file) {
        return TransferFileModel(
          name: file.name,
          path: file.path!,
          size: file.size,
          extension: file.extension ?? '',
          type: _getFileType(file.extension ?? ''),
        );
      }).toList();
    } else {
      return [];
    }
  }

  static String _getFileType(String extension) {
    extension = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav', 'm4a', 'aac'].contains(extension)) {
      return 'audio';
    } else if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extension)) {
      return 'document';
    } else if (['apk'].contains(extension)) {
      return 'apk';
    } else {
      return 'file';
    }
  }

  static Future<String> getSaveDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download/OfflineShare');
    } else {
      directory = await getApplicationDocumentsDirectory();
      directory = Directory('${directory.path}/OfflineShare');
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }
}
