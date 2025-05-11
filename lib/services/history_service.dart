import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/history_item.dart';

class HistoryService {
  static const String _conversionKey = 'conversion_history';
  static const String _downloadKey = 'download_history';

  Future<void> addConversionHistory(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getConversionHistory();

    // Remove the oldest entry if exceeding the limit
    const maxEntries = 50;
    if (history.length >= maxEntries) {
      history.removeAt(0);
    }

    history.add(item);
    prefs.setStringList(_conversionKey, history.map((item) => jsonEncode(item.toMap())).toList());
  }

  Future<void> addDownloadHistory(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getDownloadHistory();

    const maxEntries = 50;
    if (history.length >= maxEntries) {
      history.removeAt(0);
    }

    history.add(item);
    prefs.setStringList(_downloadKey, history.map((item) => jsonEncode(item.toMap())).toList());
  }

  Future<List<HistoryItem>> getConversionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_conversionKey) ?? [];
    return history.map((item) => HistoryItem.fromMap(jsonDecode(item))).toList();
  }

  Future<List<HistoryItem>> getDownloadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_downloadKey) ?? [];
    return history.map((item) => HistoryItem.fromMap(jsonDecode(item))).toList();
  }

  Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conversionKey);
    await prefs.remove(_downloadKey);
  }

}
