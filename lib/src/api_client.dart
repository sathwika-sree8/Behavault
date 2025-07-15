import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = "http://127.0.0.1:8000"});
  // Your laptop IP

  Future<bool> sendBehaviorData(Map<String, dynamic> sessionData) async {
    final uri = Uri.parse('$baseUrl/predict');
    final features = _extractFeatures(sessionData);

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"features": features}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["anomaly"] ?? false;
    } else {
      throw Exception('Failed to fetch anomaly score');
    }
  }

  List<double> _extractFeatures(Map<String, dynamic> data) {
    List<dynamic>? keystrokes = data["keystrokes"];
    List<dynamic>? motion = data["motion"];
    List<dynamic>? touches = data["touches"];
    List<dynamic>? navigation = data["navigation"];

    return [
      (keystrokes != null) ? keystrokes.length.toDouble() : 0.0,
      (motion != null) ? motion.length.toDouble() : 0.0,
      (touches != null) ? touches.length.toDouble() : 0.0,
      (data["location"] == null) ? 0.0 : 1.0,
      (navigation != null) ? navigation.length.toDouble() : 0.0,
    ];
  }
}
