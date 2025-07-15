import 'dart:convert';

class DataCollector {
  static final DataCollector _instance = DataCollector._internal();
  factory DataCollector() => _instance;
  DataCollector._internal();

  final List<Map<String, dynamic>> _events = [];

  void recordEvent(String type, Map<String, dynamic> data) {
    _events.add({
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,
      ...data,
    });
  }

  List<Map<String, dynamic>> get events => List.unmodifiable(_events);

  void clear() => _events.clear();

  String exportJson() => jsonEncode(_events);
}