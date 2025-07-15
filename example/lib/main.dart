import 'package:flutter/material.dart';
import 'package:behavior_tracker_sdk/behavior_tracker_sdk.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp()); // ✅ FIXED
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [NavigationTracker()],
      home: const ConsentScreen(),
    );
  }
}

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Start with Consent'),
          onPressed: () async {
            if (await ConsentManager.requestConsent(context)) {
              SensorTracker().start();
              GeoTracker().start(); // comment this if not needed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DemoScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});
  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final _controller = TextEditingController();
  bool _isRestricted = false;

  @override
  Widget build(BuildContext context) {
    return TouchTracker(
      child: Scaffold(
        appBar: AppBar(title: const Text('Behavior Tracker Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              KeystrokeTracker(
                controller: _controller,
                builder: (ctrl) => TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(labelText: 'Type here'),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                child: const Text('Export Collected Data'),
                onPressed: _isRestricted
                    ? null
                    : () {
                        final data = DataCollector().exportJson();
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Collected Events'),
                            content: SingleChildScrollView(child: Text(data)),
                          ),
                        );
                      },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Check Anomaly Detection'),
                onPressed: () async {
                  try {
                    print("📦 Exporting behavior data...");
                    final jsonString = DataCollector().exportJson();
                    print("📄 Raw JSON: $jsonString");

                    final decoded = jsonDecode(jsonString);

                    // Handle if it's a List
                    Map<String, dynamic> data;
                    if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
                      data = Map<String, dynamic>.from(decoded.first);
                    } else if (decoded is Map<String, dynamic>) {
                      data = decoded;
                    } else {
                      throw Exception("Invalid data format received from exportJson()");
                    }

                    final api = ApiClient(baseUrl: "http://192.168.29.254:8000");
                    print("🚀 Sending request to backend...");

                    final severity = await api.sendBehaviorData(data);
                    print("✅ Backend responded with severity: $severity");

                    if (severity == "high") {
                      // Trigger re-authentication
                      Navigator.pushReplacementNamed(context, "/login");
                    } else if (severity == "medium") {
                      // Restrict access to critical features
                      setState(() {
                        _isRestricted = true;
                      });
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Access Restricted"),
                          content: const Text("Critical features have been disabled due to medium severity."),
                        ),
                      );
                    } else {
                      // Low severity - just notify the user
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Notification"),
                          content: const Text("Normal activity detected."),
                        ),
                      );
                    }
                  } catch (e, stackTrace) {
                    print("❌ Error during anomaly detection: $e");
                    print("📛 Stack Trace:\n$stackTrace");

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Error"),
                        content: Text("An error occurred: $e"),
                      ),
                    );
                  }
                },
              ),


            ],
          ),
        ),
      ),
    );
  }
}
