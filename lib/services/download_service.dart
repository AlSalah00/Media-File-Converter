import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';


class DownloadResult {
  final bool isSuccess;
  final String message;
  final String fileName;
  final String filePath;

  DownloadResult({
    required this.isSuccess,
    required this.message,
    required this.fileName,
    required this.filePath,
  });
}

class DownloadService {
  final Dio _dio = Dio();

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();
        return photos.isGranted && videos.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else {
      return true;
    }
  }

  Future<DownloadResult> downloadFile(String url, String fileName) async {
    try {
      final permissionGranted = await requestStoragePermission();
      if (!permissionGranted) {
        return DownloadResult(
          isSuccess: false,
          message: 'Storage permission denied',
          fileName: fileName,
          filePath: '',
        );
      }

      final dir = Directory("/storage/emulated/0/Download/");
      if (dir == null) {
        return DownloadResult(
          isSuccess: false,
          message: 'Could not get external storage directory',
          fileName: fileName,
          filePath: '',
        );
      }

      final savePath = '${dir.path}/$fileName';
      await _dio.download(url, savePath);

      return DownloadResult(
        isSuccess: true,
        message: 'File downloaded to: Your Downloads Folder',
        fileName: fileName,
        filePath: savePath,
      );
    } catch (e) {
      return DownloadResult(
        isSuccess: false,
        message: 'Download error: $e',
        fileName: fileName,
        filePath: '',
      );
    }
  }


  Future<List<DownloadResult>> batchDownload(List<String> urls) async {
    List<DownloadResult> results = [];

    for (String url in urls) {
      final fileName = url.split('/').last.split('?').first;
      final result = await downloadFile(url, fileName);

      if (result.isSuccess) {
        print(result.message);
      } else {
        print(result.message);
      }

      results.add(result);
    }

    print('Batch download completed. Total files downloaded: ${results.where((r) => r.isSuccess).length}'); // For debug
    return results;
  }
}