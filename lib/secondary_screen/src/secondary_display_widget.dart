import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ArgumentsCallback = Function(dynamic arguments);

class SecondaryDisplay extends StatefulWidget {
  const SecondaryDisplay(
      {super.key, required this.callback, required this.child});

  final ArgumentsCallback callback;
  final Widget child;

  @override
  State<SecondaryDisplay> createState() => _SecondaryDisplayState();
}

class _SecondaryDisplayState extends State<SecondaryDisplay> {
  static const _presentationChannel = "presentation_displays_plugin_engine";
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
