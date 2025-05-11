import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';
import '../utils/history_item.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_snackbar.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int selectedIndex = 0;
  HistoryService historyService = HistoryService();
  List<HistoryItem> historyItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = selectedIndex == 0
        ? await historyService.getConversionHistory()
        : await historyService.getDownloadHistory();
    setState(() {
      historyItems = items;
    });
  }

  void _toggleHistory(int index) {
    setState(() {
      selectedIndex = index;
    });
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.primary,
              ),
            child: ToggleButtons(
              isSelected: [selectedIndex == 0, selectedIndex == 1],
              onPressed: _toggleHistory,
              selectedColor: AppColors.white,
              color: AppColors.textPrimary,
              fillColor: AppColors.white,
              renderBorder: false,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('Conversions',
                      style: TextStyle(
                        color: selectedIndex == 0 ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('Downloads',
                      style: TextStyle(
                        color: selectedIndex == 1 ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: historyItems.length,
              itemBuilder: (context, index) {
                final historyItem = historyItems[index];
                final formattedDate =
                    '${historyItem.dateTime.year}-${historyItem.dateTime.month.toString().padLeft(2, '0')}-${historyItem.dateTime.day.toString().padLeft(2, '0')} ${historyItem.dateTime.hour.toString().padLeft(2, '0')}:${historyItem.dateTime.minute.toString().padLeft(2, '0')}';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.accentDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            historyItem.fileName,
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 20),

          // Clear history button
          CustomButton(
            text: 'Clear History',
            backgroundColor: AppColors.danger,
            onPressed: () async {
              bool confirm = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Clear All History"),
                    content: Text("Are you sure you want to clear all history? Downloaded files will still be saved on your device."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("Clear"),
                      ),
                    ],
                  );
                },
              );

              if (confirm) {
                await historyService.clearAllHistory();

                setState(() {
                  historyItems.clear();
                });

                CustomSnackbar.show(
                  context,
                  message: "All history cleared!",
                  backgroundColor: AppColors.success,
                  icon: Icons.delete,
                );
              }
            },
          ),

          SizedBox(height:  20),

        ],
      ),
    );
  }
}
