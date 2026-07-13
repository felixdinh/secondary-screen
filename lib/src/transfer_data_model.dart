/// Event payload transferred from the primary app to the secondary display.
class TransferDataModel {
  /// Event name used by the secondary display to route the payload.
  final String eventName;

  /// Event data sent with [eventName].
  final Map<String, dynamic> data;

  /// Creates a transfer payload.
  TransferDataModel({
    required this.eventName,
    required this.data,
  });

  /// Creates a transfer payload from JSON using `event_name` and `data` keys.
  factory TransferDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransferDataModel(
      eventName: json['event_name'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  /// Converts this payload to JSON using `event_name` and `data` keys.
  Map<String, dynamic> toJson() {
    return {
      'event_name': eventName,
      'data': data,
    };
  }
}
