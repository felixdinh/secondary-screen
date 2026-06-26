import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'display.dart';
import 'display_manager.dart';
import 'secondary_screen_state.dart';

class SecondaryScreenService implements ValueListenable<SecondaryScreenState> {
  final DisplayManager _displayManager;
  final ValueNotifier<SecondaryScreenState> _stateNotifier;
  final StreamController<SecondaryScreenState> _stateController =
      StreamController<SecondaryScreenState>.broadcast(sync: true);

  StreamSubscription<int?>? _displayChangesSubscription;
  bool _isDisposed = false;

  static SecondaryScreenService get instance => _instance;
  static final SecondaryScreenService _instance = SecondaryScreenService._();

  factory SecondaryScreenService() => _instance;

  SecondaryScreenService._({DisplayManager? displayManager})
      : _displayManager = displayManager ?? DisplayManager(),
        _stateNotifier = ValueNotifier<SecondaryScreenState>(
          const SecondaryScreenState(),
        );

  @visibleForTesting
  SecondaryScreenService.create({DisplayManager? displayManager})
      : this._(displayManager: displayManager);

  SecondaryScreenState get state => _stateNotifier.value;

  @override
  SecondaryScreenState get value => state;

  ValueListenable<SecondaryScreenState> get listenable => this;

  Stream<SecondaryScreenState> get stateChanges => _stateController.stream;

  @override
  void addListener(VoidCallback listener) {
    _stateNotifier.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _stateNotifier.removeListener(listener);
  }

  Future<void> init({
    bool autoShow = true,
    String defaultRouterName = 'presentation',
  }) async {
    _emit(state.copyWith(isLoading: true, error: null));

    try {
      final displays = await _displayManager.getDisplays() ?? <Display>[];
      final defaultSecondaryDisplay = _defaultSecondaryDisplay(displays);

      _emit(state.copyWith(
        currentSecondaryDisplay: defaultSecondaryDisplay,
        availableDisplays: displays,
        status: defaultSecondaryDisplay == null
            ? SecondaryScreenServiceState.disconnected
            : SecondaryScreenServiceState.connected,
      ));

      if (autoShow && defaultSecondaryDisplay != null) {
        _emit(state.copyWith(currentRoute: null, isShowing: false));
        await showOnSecondary(defaultRouterName);
      }
    } catch (e) {
      _emit(state.copyWith(error: e.toString(), isLoading: false));
    } finally {
      _emit(state.copyWith(isLoading: false));
    }

    _ensureReconnectHandler();
  }

  Future<bool> showOnSecondary(String routeName, {String? json}) async {
    _emit(state.copyWith(isLoading: true, error: null));

    try {
      final displayId = state.currentSecondaryDisplay?.displayId;
      if (displayId == null) {
        _emit(state.copyWith(
          isLoading: false,
          error: 'No secondary display available',
        ));
        return false;
      }

      if (!state.isShowing || state.currentRoute != routeName) {
        await _displayManager.showSecondaryDisplay(
          displayId: displayId,
          routerName: routeName,
        );
      }

      if (json != null) {
        await _displayManager.transferDataToPresentation(_decodePayload(json));
      }

      _emit(state.copyWith(
        isLoading: false,
        currentRoute: routeName,
        currentData: json,
        isShowing: true,
        status: SecondaryScreenServiceState.connected,
      ));

      return true;
    } catch (e) {
      _emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> hideOnSecondary({bool clearData = false}) async {
    _emit(state.copyWith(isLoading: true, error: null));

    try {
      final displayId = state.currentSecondaryDisplay?.displayId;
      if (displayId == null) {
        _emit(state.copyWith(
          isLoading: false,
          error: 'No secondary display available',
        ));
        return false;
      }

      await _displayManager.hideSecondaryDisplay(displayId: displayId);

      _emit(state.copyWith(
        isLoading: false,
        currentData: clearData ? null : state.currentData,
        isShowing: false,
        status: SecondaryScreenServiceState.disconnected,
      ));
      return true;
    } catch (e) {
      _emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> reConnectCurrentRoute() async {
    final currentRoute = state.currentRoute;
    if (currentRoute == null) return false;

    return showOnSecondary(currentRoute, json: state.currentData);
  }

  Future<bool> updateDataOnSecondary(String data) async {
    _emit(state.copyWith(isLoading: true, error: null));

    try {
      if (state.currentSecondaryDisplay == null) {
        await init(autoShow: false);
      }

      if (state.currentSecondaryDisplay == null) {
        _emit(state.copyWith(
          isLoading: false,
          error: 'No secondary display available',
        ));
        return false;
      }

      await _displayManager.transferDataToPresentation(_decodePayload(data));
      _emit(state.copyWith(currentData: data, isLoading: false));
      return true;
    } catch (e) {
      _emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _displayChangesSubscription?.cancel();
    await _stateController.close();
    _stateNotifier.dispose();
  }

  void _ensureReconnectHandler() {
    if (_displayChangesSubscription != null) return;

    _displayChangesSubscription =
        _displayManager.connectedDisplaysChangedStream?.listen(
      _handleDisplaysChanged,
      onError: (Object error) {
        _emit(state.copyWith(error: error.toString()));
      },
    );
  }

  Future<void> _handleDisplaysChanged(int? displayCount) async {
    if (displayCount == 0) {
      final displayId = state.currentSecondaryDisplay?.displayId;
      if (displayId != null) {
        await _displayManager.hideSecondaryDisplay(displayId: displayId);
      }
      _emit(state.copyWith(
        currentSecondaryDisplay: null,
        isShowing: false,
        status: SecondaryScreenServiceState.disconnected,
      ));
      return;
    }

    final displays = await _displayManager.getDisplays() ?? <Display>[];
    final newDisplay = _defaultSecondaryDisplay(displays);

    _emit(state.copyWith(
      availableDisplays: displays,
      currentSecondaryDisplay: newDisplay,
      isShowing: newDisplay == null ? false : state.isShowing,
      status: newDisplay == null
          ? SecondaryScreenServiceState.disconnected
          : SecondaryScreenServiceState.connected,
    ));

    if (newDisplay != null && state.currentRoute != null) {
      await reConnectCurrentRoute();
    }
  }

  void _emit(SecondaryScreenState nextState) {
    if (_isDisposed) return;
    _stateNotifier.value = nextState;
    if (!_stateController.isClosed) {
      _stateController.add(nextState);
    }
  }

  Display? _defaultSecondaryDisplay(List<Display> displays) {
    return displays.length > 1 ? displays[1] : null;
  }

  Map<String, dynamic> _decodePayload(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is! Map) {
      throw const FormatException(
          'Secondary display payload must be a JSON object');
    }
    return Map<String, dynamic>.from(decoded);
  }
}
