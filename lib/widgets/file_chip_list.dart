import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mediaconverter/theme/app_colors.dart';

class FileChipList extends StatefulWidget {
  final List<PlatformFile> files;
  final void Function(PlatformFile file) onRemove;

  const FileChipList({
    super.key,
    required this.files,
    required this.onRemove,
  });

  @override
  State<FileChipList> createState() => _FileChipListState();
}

class _FileChipListState extends State<FileChipList> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 100), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 2500),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = [];

    for (int i = 0; i < widget.files.length; i++) {
      final file = widget.files[i];
      chips.add(
        Chip(
          label: Text(file.name),
          backgroundColor: AppColors.accentDark,
          labelStyle: TextStyle(color: AppColors.textPrimary),
          deleteIcon: Icon(Icons.close, color: AppColors.textPrimary),
          onDeleted: () => widget.onRemove(file),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips
              .map((chip) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: chip,
          ))
              .toList(),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant FileChipList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.files.length > oldWidget.files.length) {
      _scrollToEnd(); // Auto-scroll when new files are added
    }
  }


}
