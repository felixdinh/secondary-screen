class TransferDataModel {
  final String eventName;
  final Map<String, dynamic> data;

  TransferDataModel({
    required this.eventName,
    required this.data,
  });

  factory TransferDataModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TransferDataModel(
      eventName: json['event_name'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_name': eventName,
      'data': data,
    };
  }
}