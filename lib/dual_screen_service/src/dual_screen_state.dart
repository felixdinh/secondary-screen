part of 'dual_screen_service.dart';

enum DualScreenServiceState {
  initial,
  connected,
  disconnected,
}

class DualScreenState {
  final DualScreenServiceState status;
  final Display? currentSecondaryDisplay;
  final String? currentRoute;
  final String? currentData;
  final bool isLoading;
  final String? error;

  const DualScreenState({
    this.status = DualScreenServiceState.initial,
    this.currentSecondaryDisplay,
    this.currentRoute,
    this.currentData,
    this.isLoading = false,
    this.error,
  });

  DualScreenState copyWith({
    DualScreenServiceState? status,
    Display? currentSecondaryDisplay,
    String? currentRoute,
    String? currentData,
    bool? isLoading,
    String? error,
  }) {
    return DualScreenState(
      status: status ?? this.status,
      currentSecondaryDisplay: currentSecondaryDisplay ?? this.currentSecondaryDisplay,
      currentRoute: currentRoute ?? this.currentRoute,
      currentData: currentData ?? this.currentData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  int? get defaultSecondaryDisplayId => currentSecondaryDisplay?.displayId;
}