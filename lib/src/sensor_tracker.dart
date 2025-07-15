import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

import 'data_collector.dart';

/// Tracks gyroscope and accelerometer.
class SensorTracker {
  static final SensorTracker _instance = SensorTracker._internal();
  factory SensorTracker() => _instance;
  SensorTracker._internal();

  StreamSubscription? _gyroSub, _accelSub;

  void start() {
    _gyroSub ??= gyroscopeEvents.listen((event) {
      DataCollector().recordEvent('gyroscope', {
        'x': event.x,
        'y': event.y,
        'z': event.z,
      });
    });

    _accelSub ??= accelerometerEvents.listen((event) {
      DataCollector().recordEvent('accelerometer', {
        'x': event.x,
        'y': event.y,
        'z': event.z,
      });
    });
  }

  void stop() {
    _gyroSub?.cancel();
    _gyroSub = null;
    _accelSub?.cancel();
    _accelSub = null;
  }
}