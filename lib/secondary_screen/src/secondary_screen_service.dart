
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../secondary_screen.dart';

part 'secondary_screen_state.dart';

class SecondaryScreenCubit extends Cubit<SecondaryScreenState> {
  final DisplayManager _displayManager = DisplayManager();

  static SecondaryScreenCubit get instance => _instance;
  static final SecondaryScreenCubit _instance = SecondaryScreenCubit._internal();
  factory SecondaryScreenCubit() => _instance;

  SecondaryScreenCubit._internal() : super(const SecondaryScreenState());

  Future<void> init({bool autoShow = true, String defaultRouterName = 'presentation'}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final displays = await _displayManager.getDisplays();
      final defaultSecondaryDisplay = (displays?.length ?? 0) > 1 ? displays?.elementAtOrNull(1) : null;
      if (displays != null && displays.isNotEmpty) {
        emit(state.copyWith(
          currentSecondaryDisplay: defaultSecondaryDisplay,
          availableDisplays: displays,
          status: SecondaryScreenServiceState.connected
        ));
      }
      if (autoShow && defaultSecondaryDisplay != null) {
        emit(state.copyWith(currentRoute: null, isShowing: false));
        await showOnSecondary(defaultRouterName);
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    } finally {
      emit(state.copyWith(isLoading: false));
    }

    _handleReConnect();
  }

  Future<bool> showOnSecondary(String routeName, {String? json}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      if (state.currentSecondaryDisplay?.displayId == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'No secondary display available',
        ));
        return false;
      }

      // Re-show when not currently showing OR when switching to a different route
      if (!state.isShowing || state.currentRoute != routeName) {
        await _displayManager.showSecondaryDisplay(
          displayId: state.currentSecondaryDisplay!.displayId!,
          routerName: routeName,
        );
      }

      if (json != null) {
        final Map<String, dynamic> dataMap = jsonDecode(json);
        await _displayManager.transferDataToPresentation(dataMap);
      }
      emit(state.copyWith(
        isLoading: false,
        currentRoute: routeName,
        currentData: json,
        isShowing: true,
        status: SecondaryScreenServiceState.connected,
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> hideOnSecondary({bool clearData = false}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      if (state.currentSecondaryDisplay?.displayId == null) {
        emit(state.copyWith(isLoading: false, error: 'No secondary display available'));
        return false;
      }
      await _displayManager.hideSecondaryDisplay(displayId: state.currentSecondaryDisplay!.displayId!);

      emit(state.copyWith(
        isLoading: false,
        // Keep currentRoute so reConnectCurrentRoute can restore the last screen
        currentData: clearData ? null : state.currentData,
        isShowing: false,
        status: SecondaryScreenServiceState.disconnected,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  Future reConnectCurrentRoute() async {
    if (state.currentRoute != null) {
      await showOnSecondary(state.currentRoute!);
    }
    return false;
  }

  Future<bool> updateDataOnSecondary(String data) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      if (state.currentSecondaryDisplay == null) {
        await init(autoShow: false);
      }
      if (state.currentSecondaryDisplay == null) {
        emit(state.copyWith(
            isLoading: false, error: 'No secondary display available'));
        return false;
      }

      final Map<String, dynamic> dataMap = jsonDecode(data);
      await _displayManager.transferDataToPresentation(dataMap);
      emit(state.copyWith(currentData: data, isLoading: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  Future<void> _handleReConnect() async {
    _displayManager.connectedDisplaysChangedStream?.listen((displayCount) async {
      if (displayCount == 0) {
        // Hide before clearing the display reference
        if (state.currentSecondaryDisplay != null) {
          await _displayManager.hideSecondaryDisplay(
              displayId: state.currentSecondaryDisplay!.displayId!);
        }
        emit(state.copyWith(
          currentSecondaryDisplay: null,
          isShowing: false,
          status: SecondaryScreenServiceState.disconnected,
        ));
        return;
      }
      final displays = await _displayManager.getDisplays();
      final newDisplay = displays!.elementAtOrNull(1) ?? displays.first;
      emit(state.copyWith(
        availableDisplays: displays,
        currentSecondaryDisplay: newDisplay,
        status: SecondaryScreenServiceState.connected,
      ));
      if (state.currentRoute != null) {
        showOnSecondary(state.currentRoute!);
      }
    });
  }
}
