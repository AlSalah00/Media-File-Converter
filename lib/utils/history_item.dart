class HistoryItem {
  final String fileName;
  final String filePath;
  final DateTime dateTime;

  HistoryItem({
    required this.fileName,
    required this.filePath,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      fileName: map['fileName'],
      filePath: map['filePath'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}