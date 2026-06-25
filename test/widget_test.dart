import 'package:flutter_test/flutter_test.dart';
import 'package:secondary_screen/secondary_screen.dart';

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

  group('SecondaryScreenState', () {
    test('initial state has correct defaults', () {
      const state = SecondaryScreenState();

      expect(state.status, SecondaryScreenServiceState.initial);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.currentRoute, isNull);
      expect(state.currentSecondaryDisplay, isNull);
    });

    test('copyWith updates only specified fields', () {
      const state = SecondaryScreenState();

      final updated = state.copyWith(
        isLoading: true,
        status: SecondaryScreenServiceState.connected,
      );

      expect(updated.isLoading, true);
      expect(updated.status, SecondaryScreenServiceState.connected);
      expect(updated.error, isNull);
      expect(updated.currentRoute, isNull);
    });

    test('defaultSecondaryDisplayId returns null when no display', () {
      const state = SecondaryScreenState();
      expect(state.defaultSecondaryDisplayId, isNull);
    });
  });
}
