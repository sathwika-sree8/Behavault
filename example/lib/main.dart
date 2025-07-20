import 'package:flutter/material.dart';
import 'package:behavior_tracker_sdk/behavior_tracker_sdk.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:html' as html;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [NavigationTracker()],
      home: const ConsentScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/fundTransfer': (context) => const FundTransferScreen(),
      },
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
              // Set user ID for data collection (example user ID)
              DataCollector().setUserId("user_123");

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
                onPressed: _isRestricted
                    ? null
                    : () async {
                        final data = DataCollector().exportJson();

                        try {
                          if (kIsWeb) {
                            // Trigger file download on web
                            final bytes = utf8.encode(data);
                            final blob = html.Blob([bytes], 'application/json');
                            final url = html.Url.createObjectUrlFromBlob(blob);
                            final anchor = html.document.createElement('a') as html.AnchorElement
                              ..href = url
                              ..download = 'behavior_data.json'
                              ..style.display = 'none';
                            html.document.body!.append(anchor);
                            anchor.click();
                            anchor.remove();
                            html.Url.revokeObjectUrl(url);
                          } else {
                            // Save to local file on mobile/desktop
                            final directory = await getApplicationDocumentsDirectory();
                            final file = File('${directory.path}/behavior_data.json');
                            await file.writeAsString(data);
                          }

                          // Optionally send data to backend
                          final decoded = jsonDecode(data);
                          Map<String, dynamic> sendData;
                          if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
                            sendData = Map<String, dynamic>.from(decoded.first);
                          } else if (decoded is Map<String, dynamic>) {
                            sendData = decoded;
                          } else {
                            throw Exception("Invalid data format received from exportJson()");
                          }

                          final api = ApiClient(baseUrl: "http://192.168.29.254:8000");
                          final anomaly = await api.sendBehaviorData(sendData);

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Data Sent'),
                              content: Text('Behavioral data saved locally and sent to backend. Anomaly detected: \$anomaly'),
                            ),
                          );
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Error'),
                              content: Text('Failed to export or send data: \$e'),
                            ),
                          );
                        }
                      },
                child: const Text('Export Collected Data'),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isRestricted
                    ? null
                    : () {
                        Navigator.pushNamed(context, "/fundTransfer");
                      },
                child: const Text('Fund Transfer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Re-authentication')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Login'),
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/");
          },
        ),
      ),
    );
  }
}

class FundTransferScreen extends StatelessWidget {
  const FundTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fund Transfer')),
      body: Center(
        child: Text('Fund transfer functionality here'),
      ),
    );
  }
}
