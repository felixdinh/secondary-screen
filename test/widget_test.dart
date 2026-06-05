import 'package:flutter_test/flutter_test.dart';
import 'package:secondary_screen/dual_screen_service/dual_screen_service.dart';

void main() {
  group('TransferDataModel', () {
    test('toJson serializes correctly', () {
      final model = TransferDataModel(
        eventName: 'add_todo',
        data: {'id': 1, 'taskName': 'Test task'},
      );

      final json = model.toJson();

      expect(json['event_name'], 'add_todo');
      expect(json['data'], {'id': 1, 'taskName': 'Test task'});
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'event_name': 'update_todo',
        'data': {'id': 2, 'taskName': 'Another task', 'isCompleted': true},
      };

      final model = TransferDataModel.fromJson(json);

      expect(model.eventName, 'update_todo');
      expect(model.data['id'], 2);
      expect(model.data['isCompleted'], true);
    });
  });

  group('DualScreenState', () {
    test('initial state has correct defaults', () {
      const state = DualScreenState();

      expect(state.status, DualScreenServiceState.initial);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.currentRoute, isNull);
      expect(state.currentSecondaryDisplay, isNull);
    });

    test('copyWith updates only specified fields', () {
      const state = DualScreenState();

      final updated = state.copyWith(
        isLoading: true,
        status: DualScreenServiceState.connected,
      );

      expect(updated.isLoading, true);
      expect(updated.status, DualScreenServiceState.connected);
      expect(updated.error, isNull);
      expect(updated.currentRoute, isNull);
    });

    test('defaultSecondaryDisplayId returns null when no display', () {
      const state = DualScreenState();
      expect(state.defaultSecondaryDisplayId, isNull);
    });
  });
}
