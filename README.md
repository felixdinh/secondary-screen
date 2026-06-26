# secondary_screen

[![pub package](https://img.shields.io/pub/v/secondary_screen.svg)](https://pub.dev/packages/secondary_screen)
[![pub points](https://img.shields.io/pub/points/secondary_screen)](https://pub.dev/packages/secondary_screen/score)
[![platform](https://img.shields.io/badge/platform-android-success.svg)](https://pub.dev/packages/secondary_screen)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Drive a **dual / secondary screen** from Flutter with a state-manager-agnostic service API — show named routes on the second display, push live data to it, and auto-reconnect when a display is plugged or unplugged. Ideal for **Point of Sale (POS)** setups where the customer sees a live order summary or promotions.

![POS demo](https://raw.githubusercontent.com/felixdinh/secondary-screen/master/doc/images/demo.gif)

*The cashier's primary screen (left) drives the customer-facing secondary display (right) in real time.*

<img src="https://raw.githubusercontent.com/felixdinh/secondary-screen/master/doc/images/customer-display.jpg" alt="Customer-facing secondary display on a Zonerich POS terminal" width="480" />

*Running on a real Zonerich dual-screen POS terminal — the customer-facing display.*

> **Platform:** Android only. Built on the Android [Presentation API](https://developer.android.com/reference/android/app/Presentation) via [`presentation_displays`](https://pub.dev/packages/presentation_displays).

## 🚀 Features

- **Route control** — show any named route on the secondary display.
- **Live data transfer** — push structured, event-based payloads (`TransferDataModel`) to the second screen in real time.
- **Receive widget** — `SecondaryDisplay` delivers incoming data to your secondary UI.
- **Auto-reconnect** — restores the last route when a display is plugged/unplugged.
- **One wrapper setup** — `SecondaryScreenScope` initializes the service and exposes a controller from context.
- **Convenience controller** — call `show`, `send`, `showEvent`, `sendEvent`, `hide`, and `reconnect` without manual JSON encoding.
- **State-manager agnostic** — use the singleton `SecondaryScreenService`, its `ValueListenable`, or bridge the service into Provider, Riverpod, BLoC, GetX, or your own state layer.
- **UI listener widgets** — `SecondaryScreenBuilder` and `SecondaryScreenListener` rebuild or react to service state without requiring BLoC.
- **Low-level access** — `DisplayManager` to enumerate displays directly when you need it.

## 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  secondary_screen: ^2.1.0
```

Then import it:

```dart
import 'package:secondary_screen/secondary_screen.dart';
```

## ⚙️ Setup (Android)

A secondary display runs in its **own Flutter entry point and engine**. No extra `<activity>` registration is required — the default `flutterEmbedding` v2 meta-data Flutter generates is enough.

**1. Declare the secondary entry point** in your `main.dart`. It **must** be annotated with `@pragma('vm:entry-point')` so it survives tree-shaking:

```dart
@pragma('vm:entry-point')
void secondaryDisplayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MySecondApp());
}

class MySecondApp extends StatelessWidget {
  const MySecondApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      onGenerateRoute: generateRoute, // same route table as the primary app
      initialRoute: 'presentation',
    );
  }
}
```

**2. Share one `onGenerateRoute`** between both entry points so route names line up:

```dart
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
    case 'sales':
      return MaterialPageRoute(builder: (_) => const SalesScreen());
    case 'presentation':
      return MaterialPageRoute(builder: (_) => const PromotionScreen());
    case 'order_display':
      return MaterialPageRoute(builder: (_) => const OrderDisplayScreen());
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(body: Center(child: Text('No route'))),
      );
  }
}
```

## 🛠️ Usage

**Wrap your primary app** — `SecondaryScreenScope` initializes the service, optionally shows your default secondary route, and exposes a controller to every descendant:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SecondaryScreenScope(
      autoShow: true,
      defaultRouteName: 'presentation',
      child: MaterialApp(
        onGenerateRoute: generateRoute,
        initialRoute: 'sales',
      ),
    );
  }
}
```

**Use the controller anywhere below the wrapper** — no `jsonEncode` needed:

```dart
final screen = SecondaryScreenScope.of(context);

await screen.showEvent(
  'order_display',
  eventName: 'update_order',
  data: {'items': items, 'total': 42000},
);

await screen.sendEvent(
  eventName: 'update_order',
  data: {'items': updatedItems, 'total': 50000},
);
```

For custom payload models, pass `TransferDataModel` or a JSON object `Map` directly:

```dart
final payload = TransferDataModel(
  eventName: 'update_order',
  data: {'items': items, 'total': 42000},
);

await screen.show('order_display', data: payload);
await screen.send(payload);
```

**Read state from the same wrapper**:

```dart
SecondaryScreenScope(
  builder: (context, screen, state, child) {
    final isConnected = state.status == SecondaryScreenServiceState.connected;
    return Column(
      children: [
        Text(isConnected ? 'Connected' : 'Disconnected'),
        Expanded(child: child!),
      ],
    );
  },
  child: const SalesScreen(),
)
```

Use `onError` or `onStateChanged` when the wrapper should handle side effects for you:

```dart
SecondaryScreenScope(
  onError: (context, error, state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  },
  child: const MyPrimaryScreen(),
)
```

You can still use the lower-level singleton service when you do not want a widget wrapper:

```dart
await SecondaryScreenService.instance.init(
  autoShow: true,
  defaultRouterName: 'presentation',
);
await SecondaryScreenService.instance.showOnSecondary(
  'order_display',
  json: jsonEncode({
    'event_name': 'update_order',
    'data': {'items': items, 'total': 42000},
  }),
);
```

**Listen from Flutter UI** — use `SecondaryScreenBuilder` for a focused rebuild when you do not need the full scope wrapper:

```dart
SecondaryScreenBuilder(
  builder: (context, state, child) {
    final isConnected = state.status == SecondaryScreenServiceState.connected;
    return Text(isConnected ? 'Connected' : 'Disconnected');
  },
)
```

Use `SecondaryScreenListener` for focused side effects:

```dart
SecondaryScreenListener(
  listenWhen: (previous, current) => previous.error != current.error,
  listener: (context, state) {
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
      );
    }
  },
  child: const MyPrimaryScreen(),
)
```

**Receive data on the secondary screen** — wrap the route's UI in `SecondaryDisplay` and handle payloads in its `callback`:

```dart
SecondaryDisplay(
  callback: (args) {
    if (args is! Map) return;
    final map = Map<String, dynamic>.from(args);
    if (map['event_name'] == 'update_order') {
      final data = Map<String, dynamic>.from(map['data']);
      // ...update your UI from data...
    }
  },
  child: yourCustomerFacingUi,
)
```

**Hide & reconnect:**

```dart
final screen = SecondaryScreenScope.of(context);
await screen.hide(clearData: true);
await screen.reconnect(); // restores the last route
```

> `show` only re-navigates when the screen isn't already showing or the route changes — otherwise it just transfers data, so it's safe to call repeatedly.

> 💡 For a full, runnable Point-of-Sale demo, see the [`example/`](example/) directory: `SalesScreen` runs on the primary display, while `PromotionScreen` and `OrderDisplayScreen` run on the secondary display.

## 📖 API reference

### `SecondaryScreenScope`

One-widget primary-side setup. It can auto-initialize the secondary display, auto-show a default route, provide state to a builder, and expose `SecondaryScreenController` through `SecondaryScreenScope.of(context)`.

| Option             | Type                              | Description                                           |
| ------------------ | --------------------------------- | ----------------------------------------------------- |
| `autoInit`         | `bool`                            | Calls `init` automatically when the widget mounts     |
| `autoShow`         | `bool`                            | Shows `defaultRouteName` after a display is detected  |
| `defaultRouteName` | `String`                          | Initial secondary route, defaults to `presentation`   |
| `builder`          | `SecondaryScreenScopeBuilder?`    | Rebuild from controller + current state               |
| `onStateChanged`   | `SecondaryScreenStateListener?`   | Side effect for state changes                         |
| `onError`          | `SecondaryScreenErrorListener?`   | Side effect for new error messages                    |
| `listenWhen`       | `SecondaryScreenListenWhen?`      | Filters `onStateChanged` calls                        |

### `SecondaryScreenController`

High-level controller exposed by `SecondaryScreenScope.of(context)` and `SecondaryScreenController.instance`.

| Method                                 | Returns        | Description                                            |
| -------------------------------------- | -------------- | ------------------------------------------------------ |
| `init({autoShow, defaultRouteName})`   | `Future<void>` | Detect displays and optionally show a default route    |
| `show(routeName, {data})`              | `Future<bool>` | Navigate and optionally send `String`, `Map`, or `TransferDataModel` |
| `send(data)`                           | `Future<bool>` | Send `String`, `Map`, or `TransferDataModel` without route changes |
| `showEvent(routeName, {eventName, data})` | `Future<bool>` | Build and send `TransferDataModel` while navigating |
| `sendEvent({eventName, data})`         | `Future<bool>` | Build and send `TransferDataModel` without navigation  |
| `hide({clearData = false})`            | `Future<bool>` | Hide the secondary display                             |
| `reconnect()`                          | `Future<bool>` | Restore the last route                                 |

### `SecondaryScreenService`

A lower-level singleton service that implements `ValueListenable<SecondaryScreenState>` and exposes a broadcast `stateChanges` stream. Use it directly when you want to bridge into another state-management library.

| Method                                       | Returns        | Description                                                       |
| -------------------------------------------- | -------------- | ---------------------------------------------------------------- |
| `init({autoShow = true, defaultRouterName})` | `Future<void>` | Detect displays, connect, optionally show `defaultRouterName`     |
| `showOnSecondary(routeName, {json})`         | `Future<bool>` | Navigate to a route (deduped) and optionally send a JSON payload  |
| `updateDataOnSecondary(data)`                | `Future<bool>` | Push a new JSON payload without changing the route                |
| `hideOnSecondary({clearData = false})`       | `Future<bool>` | Hide the secondary display; keeps the last route for reconnecting |
| `reConnectCurrentRoute()`                    | `Future<bool>` | Re-show the last active route after a reconnect                   |

| State access     | Type                                   | Description                                  |
| ---------------- | -------------------------------------- | -------------------------------------------- |
| `state`          | `SecondaryScreenState`                 | Current immutable state snapshot             |
| `listenable`     | `ValueListenable<SecondaryScreenState>` | Rebuild Flutter UI with `ValueListenableBuilder` |
| `stateChanges`   | `Stream<SecondaryScreenState>`         | Bridge state updates into another state layer |

### `SecondaryScreenBuilder`

`SecondaryScreenBuilder({service, builder, child})` — rebuilds when `SecondaryScreenService` emits a new state. The `service` argument is optional and defaults to `SecondaryScreenService.instance`.

### `SecondaryScreenListener`

`SecondaryScreenListener({service, listenWhen, listener, child})` — runs side effects when service state changes. Use `listenWhen` to filter transitions, such as only reacting when `error` changes.

### `SecondaryScreenState`

| Field                     | Type                          | Description                            |
| ------------------------- | ----------------------------- | -------------------------------------- |
| `status`                  | `SecondaryScreenServiceState` | `initial`, `connected`, `disconnected` |
| `currentSecondaryDisplay` | `Display?`                    | The active secondary display           |
| `availableDisplays`       | `List<Display>?`              | All detected displays                  |
| `currentRoute`            | `String?`                     | Currently shown route name             |
| `currentData`             | `String?`                     | Last transferred JSON payload          |
| `isShowing`               | `bool`                        | Whether a route is currently shown     |
| `isLoading`               | `bool`                        | Whether an operation is in progress    |
| `error`                   | `String?`                     | Last error message, if any             |

Getter: `defaultSecondaryDisplayId` → `currentSecondaryDisplay?.displayId`.

### `TransferDataModel`

`TransferDataModel(eventName, data)` — serializes to/from JSON with snake_case keys (`event_name`, `data`) via `toJson()` / `fromJson()`.

### `SecondaryDisplay`

`SecondaryDisplay({callback, child})` — widget placed on the secondary screen; `callback(dynamic args)` receives each decoded payload.

### `DisplayManager`

Low-level platform access: `getDisplays()`, `getNameByDisplayId()`, `getNameByIndex()`, `showSecondaryDisplay()`, `hideSecondaryDisplay()`, `transferDataToPresentation()`, and the `connectedDisplaysChangedStream` (`Stream<int?>` of the connected-display count).

## 🤝 Contributions & Issues

Contributions are welcome!

- Found a bug or have a feature request? Please [open an issue](https://github.com/felixdinh/secondary-screen/issues).
- Want to contribute code? Feel free to submit a [Pull Request](https://github.com/felixdinh/secondary-screen/pulls).

## 📄 License

Released under the MIT License. See [LICENSE](LICENSE) for details.
