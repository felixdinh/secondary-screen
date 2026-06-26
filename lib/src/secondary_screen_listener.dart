import 'package:flutter/widgets.dart';

import 'secondary_screen_service.dart';
import 'secondary_screen_state.dart';

typedef SecondaryScreenStateBuilder = Widget Function(
  BuildContext context,
  SecondaryScreenState state,
  Widget? child,
);

typedef SecondaryScreenStateListener = void Function(
  BuildContext context,
  SecondaryScreenState state,
);

typedef SecondaryScreenListenWhen = bool Function(
  SecondaryScreenState previous,
  SecondaryScreenState current,
);

class SecondaryScreenBuilder extends StatelessWidget {
  final SecondaryScreenService service;
  final SecondaryScreenStateBuilder builder;
  final Widget? child;

  SecondaryScreenBuilder({
    super.key,
    SecondaryScreenService? service,
    required this.builder,
    this.child,
  }) : service = service ?? SecondaryScreenService.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SecondaryScreenState>(
      valueListenable: service,
      builder: builder,
      child: child,
    );
  }
}

class SecondaryScreenListener extends StatefulWidget {
  final SecondaryScreenService service;
  final SecondaryScreenStateListener listener;
  final SecondaryScreenListenWhen? listenWhen;
  final Widget child;

  SecondaryScreenListener({
    super.key,
    SecondaryScreenService? service,
    required this.listener,
    this.listenWhen,
    required this.child,
  }) : service = service ?? SecondaryScreenService.instance;

  @override
  State<SecondaryScreenListener> createState() =>
      _SecondaryScreenListenerState();
}

class _SecondaryScreenListenerState extends State<SecondaryScreenListener> {
  late SecondaryScreenState _previousState;

  @override
  void initState() {
    super.initState();
    _previousState = widget.service.state;
    widget.service.addListener(_handleStateChange);
  }

  @override
  void didUpdateWidget(covariant SecondaryScreenListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service == widget.service) return;

    oldWidget.service.removeListener(_handleStateChange);
    _previousState = widget.service.state;
    widget.service.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    widget.service.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() {
    if (!mounted) return;

    final currentState = widget.service.state;
    final shouldListen =
        widget.listenWhen?.call(_previousState, currentState) ?? true;

    if (shouldListen) {
      widget.listener(context, currentState);
    }

    _previousState = currentState;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
