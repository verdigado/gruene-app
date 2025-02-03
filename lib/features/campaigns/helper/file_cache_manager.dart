import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileManager {
  static const String storeDirName = 'wk-campaign-file-store';

  Future<String> storeFile(String filename, Uint8List data) async {
    var fullFileName = await _getFullFileName(filename);
    File file = await File(fullFileName).create(recursive: true);
    await file.writeAsBytes(data);
    return fullFileName;
  }

  Future<String> _getStore() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, storeDirName);
  }

  Future<String> _getFullFileName(String filename) async {
    return p.join(await _getStore(), p.basename(filename));
  }

  void deleteFile(String filename) async {
    var fullFileName = await _getFullFileName(filename);
    var file = File(fullFileName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Uint8List> retrieveFileData(String filename) async {
    var fullFileName = await _getFullFileName(filename);
    var file = File(fullFileName);
    return file.readAsBytes();
  }

  Future<void> clearAllFiles() async {
    var dir = Directory(await _getStore());
    if (!(await dir.exists())) return;
    var allFiles = await dir.list().toList();
    for (var file in allFiles) {
      var stat = await file.stat();
      // delete all files older than 30 days, assuming these are outdated
      if (stat.modified.add(Duration(days: 30)).millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch) {
        file.delete();
      }
    }
  }
}
