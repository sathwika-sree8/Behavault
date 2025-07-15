import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'data_collector.dart';

/// Handles optional geo tracking, only if consent is given.
class GeoTracker {
  static final GeoTracker _instance = GeoTracker._internal();
  factory GeoTracker() => _instance;
  GeoTracker._internal();

  bool _enabled = false;

  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  Future<void> start() async {
    if (_enabled) return;
    if (!await requestPermission()) return;
    _enabled = true;
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      DataCollector().recordEvent('geolocation', {
        'lat': position.latitude,
        'lng': position.longitude,
        'accuracy': position.accuracy,
      });
    });
  }

  void stop() {
    _enabled = false;
    // Geolocator itself does not provide a way to stop individual streams, so just ignore.
  }
}