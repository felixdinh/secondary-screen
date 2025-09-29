import 'package:flutter/material.dart';
import 'package:presentation_displays/display.dart';
import 'package:presentation_displays/displays_manager.dart';

enum SecondaryScreenServiceState {
  initial,
  connected,
  disconnected,
}

class SecondaryScreenService {
  static final SecondaryScreenService _instance = SecondaryScreenService._internal();
  factory SecondaryScreenService() => _instance;
  static SecondaryScreenService get instance => _instance;

  SecondaryScreenService._internal();

  final DisplayManager _displayManager = DisplayManager();
  Display? _currentSecondaryDisplay;

  SecondaryScreenServiceState _state = SecondaryScreenServiceState.initial;
  SecondaryScreenServiceState get state => _state;
  int? get defaultSecondaryDisplayId => _currentSecondaryDisplay?.displayId;
  Display? get currentSecondaryDisplay => _currentSecondaryDisplay;
  String? _currentRoute;
  dynamic _currentData;

  Future<void> init({bool autoShow = true, String defaultRouterName = 'presentation'}) async {
    await _handleReConnect();

    if (autoShow && _currentSecondaryDisplay != null) {
      _currentRoute = defaultRouterName;
      showOnSecondary(defaultRouterName);
    }
  }

  Future<bool> showOnSecondary(String routeName, {dynamic data}) async {
    // Ensure we have a default external display selected
    if (_currentSecondaryDisplay == null) {
      await init(autoShow: false, defaultRouterName: routeName);
    }
    if (_currentSecondaryDisplay == null) {
      return false;
    }

    if (data != null) {
      await _displayManager.transferDataToPresentation(data);
      _currentData = data;
    }
    // Refresh current device info in case it was not set
    if (_currentSecondaryDisplay == null) {
      final List<Display?>? displays = await _displayManager.getDisplays();
      if (displays != null && displays.isNotEmpty) {
        _currentSecondaryDisplay = displays.firstWhere((d) => d?.displayId == _currentSecondaryDisplay?.displayId, orElse: () => null);
      }
    }
    return true;
  }

  Future<bool> updateDataOnSecondary(dynamic data) async {
    if (_currentSecondaryDisplay == null) {
      await init(autoShow: false);
    }
    if (_currentSecondaryDisplay == null) {
      return false;
    }
    await _displayManager.transferDataToPresentation(data);
    return true;
  }


  Future<void> _handleReConnect() async {
    _displayManager.connectedDisplaysChangedStream?.listen((displayCount) async {
      if (displayCount == 0) {
        _currentSecondaryDisplay = null;
        _state = SecondaryScreenServiceState.disconnected;
        _displayManager.hideSecondaryDisplay(displayId: _currentSecondaryDisplay!.displayId!);
       return;
      }
      
      debugPrint('connected displays changed: $displayCount');
      final displays = await _displayManager.getDisplays();
      _currentSecondaryDisplay = displays!.first;
      _state = SecondaryScreenServiceState.connected;
      debugPrint('connected default ${_currentSecondaryDisplay?.displayId}:');
      if (_currentRoute != null) {
        showOnSecondary(_currentRoute!, );
      }
    });
  }
}