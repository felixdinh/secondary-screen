import 'display.dart';

/// Connection state of the secondary screen service.
enum SecondaryScreenServiceState {
  /// No display operation has completed yet.
  initial,

  /// A secondary display is connected and available.
  connected,

  /// No secondary display is currently connected.
  disconnected,
}

/// Immutable state emitted by the secondary screen service.
class SecondaryScreenState {
  /// Current service connection status.
  final SecondaryScreenServiceState status;

  /// Selected secondary display used for presentation.
  final Display? currentSecondaryDisplay;

  /// Route currently shown on the secondary display.
  final String? currentRoute;

  /// Last JSON payload sent to the secondary display.
  final String? currentData;

  /// Whether a display operation is in progress.
  final bool isLoading;

  /// Last operation error, if any.
  final String? error;

  /// Displays currently reported by Android.
  final List<Display>? availableDisplays;

  /// Whether a route is currently shown on the secondary display.
  final bool isShowing;

  /// Creates secondary screen state.
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

  /// Returns a copy of this state with the provided fields replaced.
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
      currentRoute:
          currentRoute == _unset ? this.currentRoute : currentRoute as String?,
      currentData:
          currentData == _unset ? this.currentData : currentData as String?,
      isLoading: isLoading ?? this.isLoading,
      error: error == _unset ? this.error : error as String?,
      availableDisplays: availableDisplays == _unset
          ? this.availableDisplays
          : availableDisplays as List<Display>?,
      isShowing: isShowing ?? this.isShowing,
    );
  }

  /// Display ID of the selected secondary display, if available.
  int? get defaultSecondaryDisplayId => currentSecondaryDisplay?.displayId;
}
