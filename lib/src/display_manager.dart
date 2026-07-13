import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'display.dart';

/// Android display category used to list presentation-capable displays.
const String displayCategoryPresentation =
    "android.hardware.display.category.PRESENTATION";

/// Low-level bridge to Android display and presentation APIs.
class DisplayManager {
  /// Creates a display manager that talks to the platform plugin channels.
  DisplayManager();

  static const _displayMethodChannelId = "secondary_screen";
  static const _displayEventChannelId = "secondary_screen_events";

  final MethodChannel _displayMethodChannel =
      const MethodChannel(_displayMethodChannelId);
  final EventChannel _displayEventChannel =
      const EventChannel(_displayEventChannelId);

  /// Returns all Android displays, optionally filtered by [category].
  Future<List<Display>?> getDisplays({String? category}) async {
    final List<dynamic> origins = await jsonDecode((await _displayMethodChannel
            .invokeMethod('listDisplay', category))) ??
        [];
    return origins.map((element) {
      final map = jsonDecode(jsonEncode(element)) as Map<String, dynamic>;
      return displayFromJson(map);
    }).toList();
  }

  /// Returns the display name for [displayId], or `null` when it is not found.
  Future<String?> getNameByDisplayId(int displayId, {String? category}) async {
    final displays = await getDisplays(category: category) ?? [];
    for (final display in displays) {
      if (display.displayId == displayId) return display.name;
    }
    return null;
  }

  /// Returns the display name at [index], or `null` when out of range.
  Future<String?> getNameByIndex(int index, {String? category}) async {
    final displays = await getDisplays(category: category) ?? [];
    if (index >= 0 && index < displays.length) return displays[index].name;
    return null;
  }

  /// Shows [routerName] on the Android presentation display with [displayId].
  Future<bool?> showSecondaryDisplay(
      {required int displayId, required String routerName}) async {
    return _displayMethodChannel.invokeMethod<bool>('showPresentation',
        '{"displayId": $displayId, "routerName": "$routerName"}');
  }

  /// Hides the Android presentation display with [displayId].
  Future<bool?> hideSecondaryDisplay({required int displayId}) async {
    return _displayMethodChannel.invokeMethod<bool>(
        'hidePresentation', '{"displayId": $displayId}');
  }

  /// Sends [arguments] to the active presentation engine.
  Future<bool?> transferDataToPresentation(dynamic arguments) async {
    return _displayMethodChannel.invokeMethod<bool>(
        'transferDataToPresentation', arguments);
  }

  /// Emits the connected display count whenever Android display topology changes.
  Stream<int?>? get connectedDisplaysChangedStream =>
      _displayEventChannel.receiveBroadcastStream().cast<int?>();
}
