part of 'secondary_screen_service.dart';

enum SecondaryScreenServiceState {
  initial,
  connected,
  disconnected,
}

class SecondaryScreenState {
  final SecondaryScreenServiceState status;
  final Display? currentSecondaryDisplay;
  final String? currentRoute;
  final String? currentData;
  final bool isLoading;
  final String? error;
  final List<Display>? availableDisplays;
  final bool isShowing;

  const SecondaryScreenState({
    this.status = SecondaryScreenServiceState.initial,
    this.currentSecondaryDisplay,
    this.currentRoute,
    this.currentData,
    this.isLoading = false,
    this.error,
    this.availableDisplays,
    this.isShowing = false,
  });

  // Sentinel so copyWith can distinguish "not passed" from "explicitly null"
  static const _unset = Object();

  SecondaryScreenState copyWith({
    SecondaryScreenServiceState? status,
    Object? currentSecondaryDisplay = _unset,
    Object? currentRoute = _unset,
    Object? currentData = _unset,
    bool? isLoading,
    Object? error = _unset,
    Object? availableDisplays = _unset,
    bool? isShowing,
  }) {
    return SecondaryScreenState(
      status: status ?? this.status,
      currentSecondaryDisplay: currentSecondaryDisplay == _unset
          ? this.currentSecondaryDisplay
          : currentSecondaryDisplay as Display?,
      currentRoute: currentRoute == _unset
          ? this.currentRoute
          : currentRoute as String?,
      currentData: currentData == _unset
          ? this.currentData
          : currentData as String?,
      isLoading: isLoading ?? this.isLoading,
      error: error == _unset ? this.error : error as String?,
      availableDisplays: availableDisplays == _unset
          ? this.availableDisplays
          : availableDisplays as List<Display>?,
      isShowing: isShowing ?? this.isShowing,
    );
  }

  int? get defaultSecondaryDisplayId => currentSecondaryDisplay?.displayId;
}
