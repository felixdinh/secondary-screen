import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secondary_screen/secondary_screen.dart';

void main() {
  group('SecondaryScreenService', () {
    late _FakeDisplayManager displayManager;
    late SecondaryScreenService service;

    setUp(() {
      displayManager = _FakeDisplayManager(
        displays: [
          Display(displayId: 0, name: 'primary'),
          Display(displayId: 7, name: 'secondary'),
        ],
      );
      service = SecondaryScreenService.create(displayManager: displayManager);
    });

    tearDown(() async {
      await service.dispose();
      await displayManager.dispose();
    });

    test('init detects secondary display and can auto-show default route',
        () async {
      await service.init(autoShow: true, defaultRouterName: 'presentation');

      expect(service.state.status, SecondaryScreenServiceState.connected);
      expect(service.state.defaultSecondaryDisplayId, 7);
      expect(service.state.currentRoute, 'presentation');
      expect(service.state.isShowing, isTrue);
      expect(displayManager.showCalls, [
        const _ShowCall(displayId: 7, routeName: 'presentation'),
      ]);
    });

    test('showOnSecondary dedupes the active route but still transfers data',
        () async {
      await service.init(autoShow: false);

      final firstPayload = _payload('first');
      final secondPayload = _payload('second');

      expect(
        await service.showOnSecondary('order_display', json: firstPayload),
        isTrue,
      );
      expect(
        await service.showOnSecondary('order_display', json: secondPayload),
        isTrue,
      );

      expect(displayManager.showCalls, [
        const _ShowCall(displayId: 7, routeName: 'order_display'),
      ]);
      expect(displayManager.transferredData, [
        jsonDecode(firstPayload),
        jsonDecode(secondPayload),
      ]);
      expect(service.state.currentData, secondPayload);
    });

    test('hide keeps route and data by default for reconnect', () async {
      final payload = _payload('current');

      await service.init(autoShow: false);
      await service.showOnSecondary('order_display', json: payload);

      expect(await service.hideOnSecondary(), isTrue);

      expect(displayManager.hideCalls, [7]);
      expect(service.state.currentRoute, 'order_display');
      expect(service.state.currentData, payload);
      expect(service.state.isShowing, isFalse);
      expect(service.state.status, SecondaryScreenServiceState.disconnected);
    });

    test('reConnectCurrentRoute restores the last route and payload', () async {
      final payload = _payload('current');

      await service.init(autoShow: false);
      await service.showOnSecondary('order_display', json: payload);
      await service.hideOnSecondary();

      expect(await service.reConnectCurrentRoute(), isTrue);

      expect(displayManager.showCalls, [
        const _ShowCall(displayId: 7, routeName: 'order_display'),
        const _ShowCall(displayId: 7, routeName: 'order_display'),
      ]);
      expect(displayManager.transferredData, [
        jsonDecode(payload),
        jsonDecode(payload),
      ]);
      expect(service.state.isShowing, isTrue);
    });

    test('stateChanges emits state updates', () async {
      final states = <SecondaryScreenState>[];
      final subscription = service.stateChanges.listen(states.add);

      await service.init(autoShow: false);
      await subscription.cancel();

      expect(states, isNotEmpty);
      expect(states.last.status, SecondaryScreenServiceState.connected);
    });
  });

  group('SecondaryScreenController', () {
    late _FakeDisplayManager displayManager;
    late SecondaryScreenService service;
    late SecondaryScreenController controller;

    setUp(() {
      displayManager = _FakeDisplayManager(
        displays: [
          Display(displayId: 0, name: 'primary'),
          Display(displayId: 7, name: 'secondary'),
        ],
      );
      service = SecondaryScreenService.create(displayManager: displayManager);
      controller = SecondaryScreenController(service: service);
    });

    tearDown(() async {
      await service.dispose();
      await displayManager.dispose();
    });

    test('show and send accept TransferDataModel without manual jsonEncode',
        () async {
      final payload = TransferDataModel(
        eventName: 'update_order',
        data: {'total': 42000},
      );

      await controller.init(autoShow: false);
      expect(await controller.show('order_display', data: payload), isTrue);
      expect(await controller.send(payload), isTrue);

      expect(displayManager.showCalls, [
        const _ShowCall(displayId: 7, routeName: 'order_display'),
      ]);
      expect(displayManager.transferredData, [
        payload.toJson(),
        payload.toJson(),
      ]);
    });

    test('showEvent and sendEvent build TransferDataModel internally',
        () async {
      await controller.init(autoShow: false);

      expect(
        await controller.showEvent(
          'order_display',
          eventName: 'update_order',
          data: {'total': 42000},
        ),
        isTrue,
      );
      expect(
        await controller.sendEvent(
          eventName: 'update_order',
          data: {'total': 43000},
        ),
        isTrue,
      );

      expect(displayManager.transferredData, [
        {
          'event_name': 'update_order',
          'data': {'total': 42000},
        },
        {
          'event_name': 'update_order',
          'data': {'total': 43000},
        },
      ]);
    });
  });

  group('SecondaryScreenScope', () {
    late _FakeDisplayManager displayManager;
    late SecondaryScreenService service;
    late SecondaryScreenController controller;

    setUp(() {
      displayManager = _FakeDisplayManager(
        displays: [
          Display(displayId: 0, name: 'primary'),
          Display(displayId: 7, name: 'secondary'),
        ],
      );
      service = SecondaryScreenService.create(displayManager: displayManager);
      controller = SecondaryScreenController(service: service);
    });

    tearDown(() async {
      await service.dispose();
      await displayManager.dispose();
    });

    testWidgets('auto-initializes and exposes the controller from context',
        (tester) async {
      SecondaryScreenController? exposedController;

      await tester.pumpWidget(
        SecondaryScreenScope(
          controller: controller,
          defaultRouteName: 'presentation',
          builder: (context, screen, state, child) {
            exposedController = SecondaryScreenScope.of(context);
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Text(state.currentRoute ?? 'none'),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(exposedController, same(controller));
      expect(find.text('presentation'), findsOneWidget);
      expect(displayManager.showCalls, [
        const _ShowCall(displayId: 7, routeName: 'presentation'),
      ]);
    });
  });
}

String _payload(String value) {
  return jsonEncode({
    'event_name': 'update',
    'data': {'value': value},
  });
}

class _FakeDisplayManager extends DisplayManager {
  _FakeDisplayManager({required this.displays});

  List<Display> displays;
  final List<_ShowCall> showCalls = [];
  final List<int> hideCalls = [];
  final List<dynamic> transferredData = [];
  final StreamController<int?> _displayChangesController =
      StreamController<int?>.broadcast();

  @override
  Future<List<Display>?> getDisplays({String? category}) async {
    return displays;
  }

  @override
  Future<bool?> showSecondaryDisplay({
    required int displayId,
    required String routerName,
  }) async {
    showCalls.add(_ShowCall(displayId: displayId, routeName: routerName));
    return true;
  }

  @override
  Future<bool?> hideSecondaryDisplay({required int displayId}) async {
    hideCalls.add(displayId);
    return true;
  }

  @override
  Future<bool?> transferDataToPresentation(dynamic arguments) async {
    transferredData.add(arguments);
    return true;
  }

  @override
  Stream<int?>? get connectedDisplaysChangedStream =>
      _displayChangesController.stream;

  Future<void> dispose() => _displayChangesController.close();
}

class _ShowCall {
  final int displayId;
  final String routeName;

  const _ShowCall({required this.displayId, required this.routeName});

  @override
  bool operator ==(Object other) {
    return other is _ShowCall &&
        other.displayId == displayId &&
        other.routeName == routeName;
  }

  @override
  int get hashCode => Object.hash(displayId, routeName);

  @override
  String toString() {
    return '_ShowCall(displayId: $displayId, routeName: $routeName)';
  }
}
