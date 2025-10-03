import 'package:presentation_displays/display.dart';
import 'package:secondary_screen/dual_screen_service/src/dual_screen_service.dart';

class DualScreenHelpers {
  const DualScreenHelpers._();


  static Map<String,dynamic>? stateToJson(DualScreenState state) {
    return {
      'status': state.status.name,
      'currentSecondaryDisplay': displayToJson(state.currentSecondaryDisplay),
    };
  }

  static DualScreenState stateFromJson(Map<String,dynamic> json) {
    return DualScreenState(
      status: DualScreenServiceState.values.byName(json['status']),
      currentSecondaryDisplay: displayFromJson(json['currentSecondaryDisplay']),
    );
  }
  
  static Map<String,dynamic>? displayToJson(Display? display) {
    return display != null ? {
      'displayId': display.displayId,
      'flag': display.flag,
      'rotation': display.rotation,
      'name': display.name,
    } : null;
  }

  static Display? displayFromJson(Map<String,dynamic> json) {
    return Display(
      displayId: json['displayId'],
      flag: json['flag'],
      rotation: json['rotation'],
      name: json['name'],
    );
  }
}