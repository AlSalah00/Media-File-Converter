import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ConvertResult {
  final bool isSuccess;
  final String message;
  final String fileName;
  final String? fileUrl;

  ConvertResult({
    required this.isSuccess,
    required this.message,
    required this.fileName,
    this.fileUrl,
  });
}

class ConvertService {
  final String apiKey = dotenv.env['CLOUDCONVERT_API_KEY'] ?? '';
  final String baseUrl = 'https://api.cloudconvert.com/v2';

  Future<ConvertResult> convertFile(File file, String outputFormat) async {
    try {
      final fileName = basename(file.path);

      // Step 1: Create job
      final jobResponse = await http.post(
        Uri.parse('$baseUrl/jobs'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tasks': {
            'import-my-file': {
              'operation': 'import/upload'
            },
            'convert-my-file': {
              'operation': 'convert',
              'input': 'import-my-file',
              'output_format': outputFormat
            },
            'export-my-file': {
              'operation': 'export/url',
              'input': 'convert-my-file'
            }
          }
        }),
      );

      if (jobResponse.statusCode != 201) {
        return ConvertResult(
          isSuccess: false,
          message: 'CloudConvert job creation failed: ${jobResponse.statusCode}\n'
              'Response body: ${jobResponse.body}',
          fileName: fileName,
        );
      }

      final jobData = jsonDecode(jobResponse.body);
      final importTask = jobData['data']['tasks']
          .firstWhere((task) => task['name'] == 'import-my-file');

      final uploadUrl = importTask['result']['form']['url'];
      final parameters = importTask['result']['form']['parameters'];

      // Step 2: Upload file
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      parameters.forEach((key, value) {
        request.fields[key] = value;
      });
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      await request.send();

      // Step 3: Poll job status
      final jobId = jobData['data']['id'];
      Map<String, dynamic> jobStatus;

      int retryCount = 0;
      const int maxRetries = 30;
      String status = '';

      do {
        final statusResponse = await http.get(
          Uri.parse('$baseUrl/jobs/$jobId'),
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        );

        final statusData = jsonDecode(statusResponse.body);
        status = statusData['data']['status'];

        if (status == 'error' || status == 'failed' || status == 'canceled') {
          return ConvertResult(
            isSuccess: false,
            message: 'Job failed or was canceled.',
            fileName: fileName,
          );
        }

        await Future.delayed(const Duration(seconds: 2));
        retryCount++;
        jobStatus = jsonDecode(statusResponse.body);
      } while (status != 'finished' && retryCount < maxRetries);

      if (status != 'finished') {
        return ConvertResult(
          isSuccess: false,
          message: 'Timed out waiting for the conversion to finish.',
          fileName: fileName,
        );
      }

      // Step 4: Get export URL
      final exportTask = jobStatus['data']['tasks']
          .firstWhere((task) => task['name'] == 'export-my-file');
      final fileUrl = exportTask['result']['files'][0]['url'];

      return ConvertResult(
        isSuccess: true,
        message: 'Conversion successful.',
        fileName: fileName,
        fileUrl: fileUrl,
      );
    } catch (e) {
      return ConvertResult(
        isSuccess: false,
        message: 'Error converting file: $e',
        fileName: '',
      );
    }
  }
}
