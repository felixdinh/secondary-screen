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
  final List<Display>? availableDisplays; 

  const DualScreenState({
    this.status = DualScreenServiceState.initial,
    this.currentSecondaryDisplay,
    this.currentRoute,
    this.currentData,
    this.isLoading = false,
    this.error,
    this.availableDisplays,
  });

  DualScreenState copyWith({
    DualScreenServiceState? status,
    Display? currentSecondaryDisplay,
    String? currentRoute,
    String? currentData,
    bool? isLoading,
    String? error,
    List<Display>? availableDisplays,
  }) {
    return DualScreenState(
      status: status ?? this.status,
      currentSecondaryDisplay: currentSecondaryDisplay ?? this.currentSecondaryDisplay,
      currentRoute: currentRoute ?? this.currentRoute,
      currentData: currentData ?? this.currentData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      availableDisplays: availableDisplays ?? this.availableDisplays,
    );
  }

  int? get defaultSecondaryDisplayId => currentSecondaryDisplay?.displayId;
}