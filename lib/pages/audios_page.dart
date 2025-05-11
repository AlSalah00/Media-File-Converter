import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mediaconverter/theme/app_colors.dart';
import 'package:mediaconverter/widgets/custom_buttons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../services/convert_service.dart';
import '../services/download_service.dart';
import '../services/history_service.dart';
import '../utils/file_picker.dart';
import '../utils/history_item.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/file_chip_list.dart';
import '../widgets/loader_dialog.dart';
import '../widgets/share_dialog.dart';


class AudiosPage extends StatefulWidget {
  const AudiosPage({super.key});

  @override
  _AudiosPageState createState() => _AudiosPageState();
}

class _AudiosPageState extends State<AudiosPage> {
  String selectedFormat = 'MP3';
  bool isProcessing = true;

  bool fileUploaded = false;
  bool fileConverted = false;
  bool fileDownloaded = false;
  bool isUploading = false;
  bool isConverting = false;
  bool isDownloading = false;

  List<PlatformFile> selectedFiles = [];

  List<File> uploadedFiles = [];
  List<String> convertedUrls = [];
  List<String> successfulDownloads = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.headphones, size: 70, color: AppColors.primary),
              SizedBox(height: 12),
              Text('Convert Audio Formats',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark)),
              SizedBox(height: 20),

              // Dropdown
              CustomDropdown(
                value: selectedFormat,
                items: ['MP3', 'M4A', 'FLAC', 'WMA', 'AAC', 'WEBA'],
                onChanged: (newValue) {
                  setState(() {
                    selectedFormat = newValue!;
                  });
                },
              ),



              SizedBox(height: 16),

              // Upload button
              CustomButton(
                text: "Upload Audio",
                onPressed: (!isUploading) ? () async {
                  // Show real progress dialog
                  LoaderDialog.show(
                    context,
                    message: 'Uploading files...',
                    animation: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.primary,
                      size: 50,
                    ),
                  );

                  // Pick files
                  PickedFilesResult result = await FilePickerHelper.pickFiles(
                    allowedExtensions: ['mp3', 'm4a', 'flac', 'aac', 'weba', 'wma'],
                    maxFileSize: 20 * 1024 * 1024, // 20MB for audios
                  );

                  // Hide the loader
                  LoaderDialog.hide(context);

                  if (!result.isValid) {
                    CustomSnackbar.show(
                      context,
                      message: result.message,
                      backgroundColor: AppColors.danger,
                      icon: Icons.error,
                    );
                  }

                  else {
                    CustomSnackbar.show(
                      context,
                      message: result.message,
                      backgroundColor: AppColors.success,
                      icon: Icons.check_circle,
                    );
                  }

                  // Handle user canceling
                  if (result.platformFiles.isEmpty) return;

                  setState(() {
                    selectedFiles = result.platformFiles; // For displaying in the UI
                    uploadedFiles = result.files; // For conversion
                    fileUploaded = true;
                    fileConverted = false;
                    fileDownloaded = false;
                  });

                  print('Files uploaded: $uploadedFiles');

                } : null,
              ),

              SizedBox(height: 20),

              FileChipList(
                files: selectedFiles,
                onRemove: (file) {
                  setState(() {
                    selectedFiles.remove(file);
                    if (selectedFiles.isEmpty) {
                      fileUploaded = false;
                    }
                  });
                },
              ),

              SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    text: 'Clear',
                    backgroundColor: AppColors.danger,
                    onPressed: (fileUploaded && !fileDownloaded && !fileConverted && !isConverting)
                        ? () {
                      setState(() {
                        selectedFiles = [];
                        fileUploaded = false;
                        fileConverted = false;
                        fileDownloaded = false;
                      });
                    }
                        : null,
                  ),


                  // Convert button
                  CustomButton(
                    text: 'Convert',
                    onPressed: (fileUploaded && !fileDownloaded && !fileConverted && !isConverting)
                        ? () async {
                      setState(() {
                        isConverting = true;
                      });

                      LoaderDialog.show(
                        context,
                        message: 'Converting...',
                        animation: LoadingAnimationWidget.staggeredDotsWave(
                          color: AppColors.primary,
                          size: 50,
                        ),
                      );

                      convertedUrls = [];

                      final convertService = ConvertService();
                      final historyService = HistoryService();
                      List<ConvertResult> conversionResults = [];

                      for (File file in uploadedFiles) {
                        final result = await convertService.convertFile(file, selectedFormat.toLowerCase());

                        // Check conversion success
                        if (result.isSuccess && result.fileUrl != null) {
                          convertedUrls.add(result.fileUrl!);
                          conversionResults.add(result);

                        } else {
                          // Log the error message
                          conversionResults.add(result);
                        }
                      }

                      LoaderDialog.hide(context);

                      for (var result in conversionResults) {
                        if (result.isSuccess) {
                          CustomSnackbar.show(
                            context,
                            message: result.message,
                            backgroundColor: AppColors.success,
                            icon: Icons.check_circle,
                          );

                          await historyService.addConversionHistory(HistoryItem(
                            fileName: result.fileName,
                            filePath: result.fileUrl!,
                            dateTime: DateTime.now(),
                          ));

                        }
                        else {
                          CustomSnackbar.show(
                            context,
                            message: result.message,
                            backgroundColor: AppColors.danger,
                            icon: Icons.error,
                          );
                        }
                      }

                      setState(() {
                        isConverting = false;
                        fileUploaded = false;
                        selectedFiles = [];
                        fileConverted = convertedUrls.isNotEmpty;
                      });

                      if (!convertedUrls.isNotEmpty) {
                        CustomSnackbar.show(
                          context,
                          message: 'Conversion failed',
                          backgroundColor: AppColors.danger,
                          icon: Icons.error,
                        );
                      }
                    }
                        : null,
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Download button
              CustomButton(
                text: 'Download File(s)',
                onPressed: (fileConverted && !fileDownloaded && !isDownloading)
                    ? () async {
                  setState(() {
                    isDownloading = true;
                  });

                  LoaderDialog.show(
                    context,
                    message: 'Downloading...',
                    animation: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.primary,
                      size: 50,
                    ),
                  );

                  successfulDownloads = [];

                  final downloadService = DownloadService();
                  final historyService = HistoryService();
                  List<DownloadResult> downloadResults = await downloadService.batchDownload(convertedUrls);

                  LoaderDialog.hide(context);

                  for (var result in downloadResults) {
                    CustomSnackbar.show(
                      context,
                      message: result.message,
                      backgroundColor: result.isSuccess ? AppColors.success : AppColors.danger,
                      icon: result.isSuccess ? Icons.check_circle : Icons.error,
                    );

                    if (result.isSuccess) {
                      await historyService.addDownloadHistory(HistoryItem(
                        fileName: result.fileName,
                        filePath: result.filePath,
                        dateTime: DateTime.now(),
                      ));

                      successfulDownloads.add(result.filePath);

                    }
                  }

                  setState(() {
                    isDownloading = false;
                    fileDownloaded = successfulDownloads.isNotEmpty;
                  });

                  if (successfulDownloads.isNotEmpty) {
                    ShareDialog.showShareDialog(context, successfulDownloads);
                  }
                }
                    : null,
              ),

              SizedBox(height: 40),

              Text('Note: You can only upload up to 5 files at once.',
                  style: TextStyle(fontSize: 15, color: AppColors.textPrimaryDark)),

              Text('Total files size allowed: 20MB.',
                  style: TextStyle(fontSize: 15, color: AppColors.textPrimaryDark)),
            ],
          ),
        ),
      ),
    );
  }
}
