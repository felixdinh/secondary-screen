import 'package:flutter/widgets.dart';

import 'secondary_screen_controller.dart';
import 'secondary_screen_listener.dart';
import 'secondary_screen_state.dart';

typedef SecondaryScreenScopeBuilder = Widget Function(
  BuildContext context,
  SecondaryScreenController screen,
  SecondaryScreenState state,
  Widget? child,
);

typedef SecondaryScreenErrorListener = void Function(
  BuildContext context,
  String error,
  SecondaryScreenState state,
);

class SecondaryScreenScope extends StatefulWidget {
  final SecondaryScreenController? controller;
  final bool autoInit;
  final bool autoShow;
  final String defaultRouteName;
  final SecondaryScreenScopeBuilder? builder;
  final SecondaryScreenStateListener? onStateChanged;
  final SecondaryScreenErrorListener? onError;
  final SecondaryScreenListenWhen? listenWhen;
  final Widget? child;

  const SecondaryScreenScope({
    super.key,
    this.controller,
    this.autoInit = true,
    this.autoShow = true,
    this.defaultRouteName = 'presentation',
    this.builder,
    this.onStateChanged,
    this.onError,
    this.listenWhen,
    this.child,
  }) : assert(
          builder != null || child != null,
          'Provide either builder or child.',
        );

  static SecondaryScreenController of(
    BuildContext context, {
    bool listen = false,
  }) {
    final inherited = listen
        ? context
            .dependOnInheritedWidgetOfExactType<_SecondaryScreenInherited>()
        : context.getInheritedWidgetOfExactType<_SecondaryScreenInherited>();
    return inherited?.controller ?? SecondaryScreenController.instance;
  }

  static SecondaryScreenController? maybeOf(
    BuildContext context, {
    bool listen = false,
  }) {
    final inherited = listen
        ? context
            .dependOnInheritedWidgetOfExactType<_SecondaryScreenInherited>()
        : context.getInheritedWidgetOfExactType<_SecondaryScreenInherited>();
    return inherited?.controller;
  }

  static SecondaryScreenState stateOf(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_SecondaryScreenInherited>();
    return inherited?.state ?? SecondaryScreenController.instance.state;
  }

  @override
  State<SecondaryScreenScope> createState() => _SecondaryScreenScopeState();
}

class _SecondaryScreenScopeState extends State<SecondaryScreenScope> {
  late SecondaryScreenController _controller;
  late SecondaryScreenState _previousState;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SecondaryScreenController.instance;
    _previousState = _controller.state;
    _controller.addListener(_handleStateChange);
    _initIfNeeded();
  }

  @override
  void didUpdateWidget(covariant SecondaryScreenScope oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextController =
        widget.controller ?? SecondaryScreenController.instance;
    var controllerChanged = false;
    if (_controller != nextController) {
      _controller.removeListener(_handleStateChange);
      _controller = nextController;
      _previousState = _controller.state;
      _controller.addListener(_handleStateChange);
      controllerChanged = true;
    }

    final initOptionsChanged = oldWidget.autoInit != widget.autoInit ||
        oldWidget.autoShow != widget.autoShow ||
        oldWidget.defaultRouteName != widget.defaultRouteName;
    if (controllerChanged || initOptionsChanged) {
      _initIfNeeded();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChange);
    super.dispose();
  }

  void _initIfNeeded() {
    if (!widget.autoInit) return;

    _controller.init(
      autoShow: widget.autoShow,
      defaultRouteName: widget.defaultRouteName,
    );
  }

  void _handleStateChange() {
    if (!mounted) return;

    final currentState = _controller.state;
    final shouldListen =
        widget.listenWhen?.call(_previousState, currentState) ?? true;

    if (shouldListen) {
      widget.onStateChanged?.call(context, currentState);
    }

    final error = currentState.error;
    if (error != null && error != _previousState.error) {
      widget.onError?.call(context, error, currentState);
    }

    _previousState = currentState;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SecondaryScreenState>(
      valueListenable: _controller,
      child: widget.child,
      builder: (context, state, child) {
        return _SecondaryScreenInherited(
          controller: _controller,
          state: state,
          child: Builder(
            builder: (context) {
              return widget.builder?.call(
                    context,
                    _controller,
                    state,
                    child,
                  ) ??
                  child!;
            },
          ),
        );
      },
    );
  }
}

class _SecondaryScreenInherited extends InheritedWidget {
  final SecondaryScreenController controller;
  final SecondaryScreenState state;

  const _SecondaryScreenInherited({
    required this.controller,
    required this.state,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _SecondaryScreenInherited oldWidget) {
    return controller != oldWidget.controller || state != oldWidget.state;
  }
}
