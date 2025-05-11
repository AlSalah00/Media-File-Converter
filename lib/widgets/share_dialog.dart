import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareDialog {
  static void showShareDialog(
      BuildContext context,
      List<String> filePaths,
      ) {
    final fileNames = filePaths.map((path) => path.split('/').last).join(', ');

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Files Downloaded'),
            content: Text('Would you like to share these files?\n$fileNames'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _shareFiles(filePaths);
                },
                child: const Text('Share'),
              ),
            ],
          );
        },
      );
    }
  }

  static void _shareFiles(List<String> filePaths) {
    try {
      final xFiles = filePaths.map((path) => XFile(path)).toList();
      Share.shareXFiles(xFiles, text: 'Check out these files!');
    } catch (e) {
      print('Error sharing files: $e');
    }
  }
}
