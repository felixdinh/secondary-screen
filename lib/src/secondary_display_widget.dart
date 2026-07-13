import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Callback invoked when the primary app sends data to the secondary display.
typedef ArgumentsCallback = Function(dynamic arguments);

/// Widget that receives payloads sent to a secondary presentation route.
class SecondaryDisplay extends StatefulWidget {
  /// Creates a receiver around [child].
  const SecondaryDisplay(
      {super.key, required this.callback, required this.child});

  /// Handles each payload delivered by the platform channel.
  final ArgumentsCallback callback;

  /// UI rendered on the secondary display.
  final Widget child;

  @override
  State<SecondaryDisplay> createState() => _SecondaryDisplayState();
}

class _SecondaryDisplayState extends State<SecondaryDisplay> {
  static const _presentationChannel = "secondary_screen_engine";
  MethodChannel? _presentationMethodChannel;

  @override
  void initState() {
    super.initState();
    _presentationMethodChannel = const MethodChannel(_presentationChannel);
    _presentationMethodChannel?.setMethodCallHandler((call) async {
      widget.callback(call.arguments);
    });
    _presentationMethodChannel?.invokeMethod<void>('SecondaryDisplayReady');
  }

  @override
  void dispose() {
    _presentationMethodChannel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
