import 'dart:convert';

class DataCollector {
  static final DataCollector _instance = DataCollector._internal();
  factory DataCollector() => _instance;
  DataCollector._internal();

  final List<Map<String, dynamic>> _events = [];
  String? _userId;

  void setUserId(String userId) {
    _userId = userId;
  }

  void recordEvent(String type, Map<String, dynamic> data) {
    final event = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,
      ...data,
    };
    if (_userId != null) {
      event['userId'] = _userId;
    }
    _events.add(event);
  }

  List<Map<String, dynamic>> get events => List.unmodifiable(_events);

  void clear() => _events.clear();

  String exportJson() => jsonEncode(_events);
}
