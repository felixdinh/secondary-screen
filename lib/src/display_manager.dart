import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'display.dart';

const String displayCategoryPresentation =
    "android.hardware.display.category.PRESENTATION";

class DisplayManager {
  static const _displayMethodChannelId = "secondary_screen";
  static const _displayEventChannelId = "secondary_screen_events";

  final MethodChannel _displayMethodChannel =
      const MethodChannel(_displayMethodChannelId);
  final EventChannel _displayEventChannel =
      const EventChannel(_displayEventChannelId);

  Future<List<Display>?> getDisplays({String? category}) async {
    final List<dynamic> origins = await jsonDecode((await _displayMethodChannel
            .invokeMethod('listDisplay', category))) ??
        [];
    return origins.map((element) {
      final map = jsonDecode(jsonEncode(element)) as Map<String, dynamic>;
      return displayFromJson(map);
    }).toList();
  }

  Future<String?> getNameByDisplayId(int displayId, {String? category}) async {
    final displays = await getDisplays(category: category) ?? [];
    for (final display in displays) {
      if (display.displayId == displayId) return display.name;
    }
    return null;
  }

  Future<String?> getNameByIndex(int index, {String? category}) async {
    final displays = await getDisplays(category: category) ?? [];
    if (index >= 0 && index < displays.length) return displays[index].name;
    return null;
  }

  Future<bool?> showSecondaryDisplay(
      {required int displayId, required String routerName}) async {
    return _displayMethodChannel.invokeMethod<bool>('showPresentation',
        '{"displayId": $displayId, "routerName": "$routerName"}');
  }

  Future<bool?> hideSecondaryDisplay({required int displayId}) async {
    return _displayMethodChannel.invokeMethod<bool>(
        'hidePresentation', '{"displayId": $displayId}');
  }

  Future<bool?> transferDataToPresentation(dynamic arguments) async {
    return _displayMethodChannel.invokeMethod<bool>(
        'transferDataToPresentation', arguments);
  }

  Stream<int?>? get connectedDisplaysChangedStream =>
      _displayEventChannel.receiveBroadcastStream().cast<int?>();
}
