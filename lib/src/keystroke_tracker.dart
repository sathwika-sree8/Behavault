import 'package:flutter/material.dart';
import 'data_collector.dart';

/// Wrap a TextField with this to track typing speed and intervals.
class KeystrokeTracker extends StatefulWidget {
  final TextEditingController controller;
  final Widget Function(TextEditingController) builder;
  const KeystrokeTracker({required this.controller, required this.builder, super.key});

  @override
  State<KeystrokeTracker> createState() => _KeystrokeTrackerState();
}

class _KeystrokeTrackerState extends State<KeystrokeTracker> {
  DateTime? _lastTyped;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final now = DateTime.now();
    if (_lastTyped != null) {
      final interval = now.difference(_lastTyped!).inMilliseconds;
      DataCollector().recordEvent('keystroke', {
        'interval_ms': interval,
        'length': widget.controller.text.length,
      });
    }
    _lastTyped = now;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(widget.controller);
  }
}