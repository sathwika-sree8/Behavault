import 'package:flutter/material.dart';

/// Handles user consent for behavioral data tracking.
class ConsentManager {
  static bool _consentGiven = false;

  /// Show a consent dialog; returns true if user accepts.
  static Future<bool> requestConsent(BuildContext context) async {
    if (_consentGiven) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Consent Required'),
        content: Text('Allow this app to collect behavioral analytics for better experience?'),
        actions: [
          TextButton(
            child: Text('Decline'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text('Allow'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    _consentGiven = result ?? false;
    return _consentGiven;
  }

  static bool get consentGiven => _consentGiven;
  static void reset() => _consentGiven = false;
}