# secondary_screen

[![pub package](https://img.shields.io/pub/v/secondary_screen.svg)](https://pub.dev/packages/secondary_screen)
[![pub points](https://img.shields.io/pub/points/secondary_screen)](https://pub.dev/packages/secondary_screen/score)
[![platform](https://img.shields.io/badge/platform-android-success.svg)](https://pub.dev/packages/secondary_screen)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Drive a **dual / secondary screen** from Flutter with BLoC state management — show named routes on the second display, push live data to it, and auto-reconnect when a display is plugged or unplugged. Ideal for **Point of Sale (POS)** setups where the customer sees a live order summary or promotions.

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
- **Single entry point** — a singleton `SecondaryScreenCubit` any layer can call.
- **Low-level access** — `DisplayManager` to enumerate displays directly when you need it.

## 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  secondary_screen: ^2.0.0
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

**Initialize** — wrap your app with a `BlocProvider` and call `init` (e.g. in `initState`):

```dart
BlocProvider(
  create: (_) => SecondaryScreenCubit(),
  child: const MaterialApp(onGenerateRoute: generateRoute, initialRoute: 'sales'),
)

context.read<SecondaryScreenCubit>().init(
  autoShow: true,
  defaultRouterName: 'presentation',
);
```

`SecondaryScreenCubit` is a singleton — reach it anywhere via `SecondaryScreenCubit.instance`.

**Show a route & push data** — build the payload with `TransferDataModel`; the `eventName` tells the receiver what to do:

```dart
final payload = TransferDataModel(
  eventName: 'update_order',
  data: {'items': [...], 'total': 42000},
);

// Navigate the second screen and send the first payload:
await SecondaryScreenCubit.instance.showOnSecondary(
  'order_display',
  json: jsonEncode(payload.toJson()),
);

// Later, refresh data without re-navigating:
await SecondaryScreenCubit.instance.updateDataOnSecondary(jsonEncode(payload.toJson()));
```

> `showOnSecondary` only re-navigates when the screen isn't already showing or the route changes — otherwise it just transfers data, so it's safe to call repeatedly.

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
await SecondaryScreenCubit.instance.hideOnSecondary(clearData: true);
await SecondaryScreenCubit.instance.reConnectCurrentRoute(); // restores the last route
```

> 💡 For a full, runnable Point-of-Sale demo (sales, order display, promotion carousel, and an event-based todo screen), see the [`example/`](example/) directory.

## 📖 API reference

### `SecondaryScreenCubit`

A singleton `Cubit<SecondaryScreenState>`.

| Method                                       | Returns        | Description                                                       |
| -------------------------------------------- | -------------- | ---------------------------------------------------------------- |
| `init({autoShow = true, defaultRouterName})` | `Future<void>` | Detect displays, connect, optionally show `defaultRouterName`     |
| `showOnSecondary(routeName, {json})`         | `Future<bool>` | Navigate to a route (deduped) and optionally send a JSON payload  |
| `updateDataOnSecondary(data)`                | `Future<bool>` | Push a new JSON payload without changing the route                |
| `hideOnSecondary({clearData = false})`       | `Future<bool>` | Hide the secondary display; keeps the last route for reconnecting |
| `reConnectCurrentRoute()`                    | `Future`       | Re-show the last active route after a reconnect                   |

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
