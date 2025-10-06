import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presentation_displays/display.dart';
import 'package:presentation_displays/displays_manager.dart';
import 'package:secondary_screen/dual_screen_service/src/transfer_data_model.dart';

part 'dual_screen_state.dart';

class DualScreenCubit extends Cubit<DualScreenState> {
  final DisplayManager _displayManager = DisplayManager();

  static DualScreenCubit get instance => _instance;
  static final DualScreenCubit _instance = DualScreenCubit._internal();
  factory DualScreenCubit() => _instance;

  DualScreenCubit._internal() : super(const DualScreenState());

  Future<void> init({bool autoShow = true, String defaultRouterName = 'presentation'}) async {
    debugPrint('💁init:\n defaultRouterName: $defaultRouterName\n autoShow: $autoShow');

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final displays = await _displayManager.getDisplays();
      final defaultSecondaryDisplay = (displays?.length ?? 0) > 1 ? displays?.elementAtOrNull(1) : null;
      if (displays != null && displays.isNotEmpty) {
        emit(state.copyWith(currentSecondaryDisplay: defaultSecondaryDisplay));
      }
      if (autoShow && defaultSecondaryDisplay != null) {
        // Reset currentRoute trước khi show để đảm bảo showSecondaryDisplay được gọi
        emit(state.copyWith(currentRoute: null));
        await showOnSecondary(defaultRouterName);
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    } finally {
      emit(state.copyWith(isLoading: false));
    }

    _handleReConnect();
  }

  Future<bool> showOnSecondary(String routeName,{String? json}) async {
    debugPrint('🔄 showOnSecondary: $routeName, currentRoute: ${state.currentRoute}');
    emit(state.copyWith(isLoading: true, error: null));
    try {
      if (state.currentSecondaryDisplay?.displayId == null) {
        emit(state.copyWith(
            isLoading: false, error: 'No secondary display available'));
        return false;
      }
      if (state.currentRoute != routeName) {
        debugPrint('📱 Calling showSecondaryDisplay for route: $routeName');
        await _displayManager.showSecondaryDisplay(
            displayId: state.currentSecondaryDisplay!.displayId!,
            routerName: routeName);
      } else {
        debugPrint('⏭️ Skipping showSecondaryDisplay - same route: $routeName');
      }

      if (json != null) {
        debugPrint('📤 Transferring data: $json');
        await _displayManager.transferDataToPresentation(json);
        debugPrint('✅ Data transferred successfully');
      }
      emit(state.copyWith(
          isLoading: false, currentRoute: routeName, currentData: json));

      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> hideOnSecondary({bool clearData = false}) async {
    debugPrint('hideOnSecondary');
    debugPrint(
        'state.currentSecondaryDisplay: ${state.currentSecondaryDisplay?.displayId}');
    emit(state.copyWith(isLoading: true, error: null));
    try {
      if (state.currentSecondaryDisplay?.displayId == null) {
        emit(state.copyWith(
            isLoading: false, error: 'No secondary display available'));
        return false;
      }
      await _displayManager.hideSecondaryDisplay(
          displayId: state.currentSecondaryDisplay!.displayId!);
      if (clearData) {
        emit(state.copyWith(currentData: null, currentRoute: null));
      }
      emit(state.copyWith(isLoading: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
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

      await _displayManager.transferDataToPresentation(data);
      emit(state.copyWith(currentData: data, isLoading: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  Future<void> _handleReConnect() async {
    _displayManager.connectedDisplaysChangedStream?.listen((displayCount) async {
      debugPrint('connected displays changed: $displayCount');
      if (displayCount == 0) {
        emit(state.copyWith(
          currentSecondaryDisplay: null,
          status: DualScreenServiceState.disconnected,
        ));
        if (state.currentSecondaryDisplay != null) {
          _displayManager.hideSecondaryDisplay(displayId: state.currentSecondaryDisplay!.displayId!);
        }
        return;
      }
      debugPrint('connected displays changed: $displayCount');
      final displays = await _displayManager.getDisplays();
      final newDisplay = displays!.first;
      emit(state.copyWith(
        currentSecondaryDisplay: newDisplay,
        status: DualScreenServiceState.connected,
      ));
      debugPrint('connected default ${newDisplay.displayId}:');
      if (state.currentRoute != null) {
        showOnSecondary(state.currentRoute!);
      }
    });
  }

}
