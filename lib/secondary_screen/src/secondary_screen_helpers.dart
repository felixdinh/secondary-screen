import '../secondary_screen.dart';

class SecondaryScreenHelpers {
  const SecondaryScreenHelpers._();

  static Map<String, dynamic>? stateToJson(SecondaryScreenState state) {
    return {
      'status': state.status.name,
      'currentSecondaryDisplay': displayToJson(state.currentSecondaryDisplay),
    };
  }

  static SecondaryScreenState stateFromJson(Map<String, dynamic> json) {
    final displayJson = json['currentSecondaryDisplay'] as Map<String, dynamic>?;
    return SecondaryScreenState(
      status: SecondaryScreenServiceState.values.byName(json['status']),
      currentSecondaryDisplay: displayJson != null ? displayFromJson(displayJson) : null,
    );
  }

  static Map<String, dynamic>? displayToJson(Display? display) {
    return display != null ? {
      'displayId': display.displayId,
      'flag': display.flag,
      'rotation': display.rotation,
      'name': display.name,
    } : null;
  }

  static Display? displayFromJson(Map<String, dynamic> json) {
    return Display(
      displayId: json['displayId'],
      flag: json['flag'],
      rotation: json['rotation'],
      name: json['name'],
    );
  }
}
