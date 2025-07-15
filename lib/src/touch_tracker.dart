import 'package:flutter/material.dart';

import 'data_collector.dart';

/// Widget to track touches, pressure, swipe speed, gesture angle.
class TouchTracker extends StatelessWidget {
  final Widget child;

  const TouchTracker({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        DataCollector().recordEvent('touch_down', {
          'x': e.position.dx,
          'y': e.position.dy,
          'pressure': e.pressure,
        });
      },
      onPointerUp: (e) {
        DataCollector().recordEvent('touch_up', {
          'x': e.position.dx,
          'y': e.position.dy,
          'pressure': e.pressure,
        });
      },
      child: _GestureTracker(child: child),
    );
  }
}

/// Tracks swipes and gestures
class _GestureTracker extends StatefulWidget {
  final Widget child;
  const _GestureTracker({required this.child});

  @override
  State<_GestureTracker> createState() => _GestureTrackerState();
}

class _GestureTrackerState extends State<_GestureTracker> {
  Offset? _start;
  DateTime? _startTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) {
        _start = d.localPosition;
        _startTime = DateTime.now();
      },
      onPanEnd: (d) {
        if (_start != null && _startTime != null) {
          final duration = DateTime.now().difference(_startTime!);
          final velocity = d.velocity.pixelsPerSecond;
          final angle = velocity.direction;
          DataCollector().recordEvent('swipe', {
            'start_x': _start!.dx,
            'start_y': _start!.dy,
            'duration_ms': duration.inMilliseconds,
            'velocity_x': velocity.dx,
            'velocity_y': velocity.dy,
            'angle': angle,
          });
        }
        _start = null;
        _startTime = null;
      },
      child: widget.child,
    );
  }
}