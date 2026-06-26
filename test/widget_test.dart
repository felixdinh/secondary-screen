import 'package:flutter_test/flutter_test.dart';
import 'package:secondary_screen/secondary_screen.dart';

void main() {
  group('TransferDataModel', () {
    test('toJson serializes correctly', () {
      final model = TransferDataModel(
        eventName: 'update_order',
        data: {
          'items': [
            {'name': 'Coffee', 'quantity': 1, 'subtotal': 25000},
          ],
          'total': 25000,
        },
      );

      final json = model.toJson();

      expect(json['event_name'], 'update_order');
      expect(json['data'], {
        'items': [
          {'name': 'Coffee', 'quantity': 1, 'subtotal': 25000},
        ],
        'total': 25000,
      });
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'event_name': 'update_order',
        'data': {
          'items': [
            {'name': 'Tea', 'quantity': 2, 'subtotal': 40000},
          ],
          'total': 40000,
        },
      };

      final model = TransferDataModel.fromJson(json);

      expect(model.eventName, 'update_order');
      expect(model.data['total'], 40000);
      expect(model.data['items'], [
        {'name': 'Tea', 'quantity': 2, 'subtotal': 40000},
      ]);
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
