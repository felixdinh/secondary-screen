import 'display.dart';
import 'secondary_screen_state.dart';

/// Serialization helpers for secondary screen state and display values.
class SecondaryScreenHelpers {
  const SecondaryScreenHelpers._();

  /// Converts [state] to a JSON map that can be persisted.
  static Map<String, dynamic>? stateToJson(SecondaryScreenState state) {
    return {
      'status': state.status.name,
      'currentSecondaryDisplay': displayToJson(state.currentSecondaryDisplay),
    };
  }

  /// Restores [SecondaryScreenState] from a JSON map.
  static SecondaryScreenState stateFromJson(Map<String, dynamic> json) {
    final displayJson =
        json['currentSecondaryDisplay'] as Map<String, dynamic>?;
    return SecondaryScreenState(
      status: SecondaryScreenServiceState.values.byName(json['status']),
      currentSecondaryDisplay:
          displayJson != null ? displayFromJson(displayJson) : null,
    );
  }

  /// Converts [display] to a JSON map.
  static Map<String, dynamic>? displayToJson(Display? display) {
    return display != null
        ? {
            'displayId': display.displayId,
            'flag': display.flag,
            'rotation': display.rotation,
            'name': display.name,
          }
        : null;
  }

  /// Restores a [Display] from a JSON map.
  static Display? displayFromJson(Map<String, dynamic> json) {
    return Display(
      displayId: json['displayId'],
      flag: json['flag'],
      rotation: json['rotation'],
      name: json['name'],
    );
  }
}
