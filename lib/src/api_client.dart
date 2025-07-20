import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = "http://192.168.29.254:8000"});
  // Your laptop IP

  Future<bool> sendBehaviorData(Map<String, dynamic> sessionData) async {
    final uri = Uri.parse('$baseUrl/predict');
    final features = _extractFeatures(sessionData);

    try {
      if (kIsWeb) {
        final response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"features": features}),
        );
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final anomaly = json["anomaly"];
          if (anomaly is bool) return anomaly;
          if (anomaly is String) {
            // Customize this logic as needed
            return anomaly.toLowerCase() == "high";
          }
          return false;
        } else {
          throw Exception('Failed to fetch anomaly score');
        }
      } else {
        // Use IO client for mobile/desktop
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
    } catch (e) {
      throw Exception('Network error: \$e');
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
