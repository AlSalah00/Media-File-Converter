import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart';

class ShareService {
  void shareFile(String filePath) {
    try {
      final fileName = basename(filePath);
      Share.shareXFiles(
        [XFile(filePath)],
        text: 'Check this out: $fileName',
      );
    } catch (e) {
      print('❌ Error sharing file: $e');
    }
  }

  void shareMultipleFiles(List<String> filePaths) {
    try {
      final xFiles = filePaths.map((path) => XFile(path)).toList();
      Share.shareXFiles(xFiles, text: 'Check these out!');
    } catch (e) {
      print('❌ Error sharing files: $e');
    }
  }
}
