import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'secondary_screen_service.dart';
import 'secondary_screen_state.dart';
import 'transfer_data_model.dart';

class SecondaryScreenController
    implements ValueListenable<SecondaryScreenState> {
  final SecondaryScreenService service;

  static SecondaryScreenController get instance => _instance;
  static final SecondaryScreenController _instance =
      SecondaryScreenController._();

  factory SecondaryScreenController({SecondaryScreenService? service}) {
    if (service == null ||
        identical(service, SecondaryScreenService.instance)) {
      return _instance;
    }
    return SecondaryScreenController._(service: service);
  }

  SecondaryScreenController._({SecondaryScreenService? service})
      : service = service ?? SecondaryScreenService.instance;

  SecondaryScreenState get state => service.state;

  @override
  SecondaryScreenState get value => service.value;

  ValueListenable<SecondaryScreenState> get listenable => service.listenable;

  Stream<SecondaryScreenState> get stateChanges => service.stateChanges;

  bool get isConnected => state.status == SecondaryScreenServiceState.connected;

  bool get isShowing => state.isShowing;

  int? get displayId => state.defaultSecondaryDisplayId;

  String? get currentRoute => state.currentRoute;

  String? get currentData => state.currentData;

  @override
  void addListener(VoidCallback listener) {
    service.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    service.removeListener(listener);
  }

  Future<void> init({
    bool autoShow = true,
    String defaultRouteName = 'presentation',
  }) {
    return service.init(
      autoShow: autoShow,
      defaultRouterName: defaultRouteName,
    );
  }

  Future<bool> show(String routeName, {Object? data}) {
    return service.showOnSecondary(
      routeName,
      json: data == null ? null : _encodeData(data),
    );
  }

  Future<bool> send(Object data) {
    return service.updateDataOnSecondary(_encodeData(data));
  }

  Future<bool> hide({bool clearData = false}) {
    return service.hideOnSecondary(clearData: clearData);
  }

  Future<bool> reconnect() {
    return service.reConnectCurrentRoute();
  }

  Future<bool> showEvent(
    String routeName, {
    required String eventName,
    required Map<String, dynamic> data,
  }) {
    return show(
      routeName,
      data: TransferDataModel(eventName: eventName, data: data),
    );
  }

  Future<bool> sendEvent({
    required String eventName,
    required Map<String, dynamic> data,
  }) {
    return send(TransferDataModel(eventName: eventName, data: data));
  }

  String _encodeData(Object data) {
    if (data is String) {
      _validateJsonObject(data);
      return data;
    }
    if (data is TransferDataModel) {
      return jsonEncode(data.toJson());
    }
    if (data is Map<String, dynamic>) {
      return jsonEncode(data);
    }
    if (data is Map) {
      return jsonEncode(Map<String, dynamic>.from(data));
    }

    throw ArgumentError.value(
      data,
      'data',
      'Expected a JSON object string, Map, or TransferDataModel.',
    );
  }

  void _validateJsonObject(String data) {
    final decoded = jsonDecode(data);
    if (decoded is! Map) {
      throw const FormatException(
        'Secondary display data must be a JSON object.',
      );
    }
  }
}
