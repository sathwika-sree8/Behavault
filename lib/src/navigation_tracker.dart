import 'package:flutter/material.dart';

import 'data_collector.dart';

/// Tracks route navigation in the app.
class NavigationTracker extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    DataCollector().recordEvent('navigation', {
      'type': 'push',
      'route': route.settings.name,
    });
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    DataCollector().recordEvent('navigation', {
      'type': 'pop',
      'route': route.settings.name,
    });
    super.didPop(route, previousRoute);
  }
}