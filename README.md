# secondary_screen

A Flutter package for managing dual/secondary screen displays using BLoC state management. Built on top of [`presentation_displays`](https://pub.dev/packages/presentation_displays), it provides a simple service to show routes, transfer data, and auto-reconnect on display changes.

## Features

- Show any named route on a secondary display
- Transfer structured data to the secondary screen in real time
- Auto-reconnect when a display is plugged/unplugged
- Hide the secondary display and optionally clear its data
- `TransferDataModel` for typed event-based data transfer

## Installation

```yaml
dependencies:
  secondary_screen: ^1.0.0
```

## Setup

### Android

Register the secondary entry point in `AndroidManifest.xml`:

```xml
<activity
  android:name="io.flutter.embedding.android.FlutterActivity"
  android:exported="false" />
```

Declare the secondary entry point in your `main.dart`:

```dart
@pragma('vm:entry-point')
void secondaryDisplayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MySecondApp());
}
```

## Usage

### 1. Initialize the service

```dart
// Wrap your app with BlocProvider
BlocProvider(
  create: (_) => DualScreenCubit(),
  child: const MaterialApp(...),
)
```

Call `init` once your widget is ready (e.g. in `initState`):

```dart
context.read<DualScreenCubit>().init(
  autoShow: true,
  defaultRouterName: 'presentation',
);
```

### 2. Show a route on the secondary screen

```dart
await DualScreenCubit.instance.showOnSecondary('presentation');
```

### 3. Transfer data to the secondary screen

Use `TransferDataModel` to send typed events:

```dart
final payload = TransferDataModel(
  eventName: 'add_todo',
  data: {'id': 1, 'taskName': 'Buy milk'},
);

await DualScreenCubit.instance.showOnSecondary(
  'todo_list',
  json: jsonEncode(payload.toJson()),
);
```

### 4. Hide the secondary screen

```dart
await DualScreenCubit.instance.hideOnSecondary(clearData: true);
```

### 5. Reconnect after a disconnect

```dart
await DualScreenCubit.instance.reConnectCurrentRoute();
```

## API

### `DualScreenCubit`

| Method | Description |
|--------|-------------|
| `init({autoShow, defaultRouterName})` | Detect displays and optionally show a route |
| `showOnSecondary(routeName, {json})` | Navigate to a route and optionally send data |
| `hideOnSecondary({clearData})` | Hide the secondary display |
| `updateDataOnSecondary(data)` | Push new data without changing the route |
| `reConnectCurrentRoute()` | Re-show the last active route after reconnect |

### `DualScreenState`

| Field | Type | Description |
|-------|------|-------------|
| `status` | `DualScreenServiceState` | `connected` or `disconnected` |
| `currentSecondaryDisplay` | `Display?` | The active secondary display |
| `availableDisplays` | `List<Display>` | All detected displays |
| `currentRoute` | `String?` | Currently shown route name |
| `currentData` | `String?` | Last transferred JSON data |
| `isLoading` | `bool` | Whether an operation is in progress |
| `error` | `String?` | Last error message, if any |

### `TransferDataModel`

```dart
TransferDataModel(
  eventName: 'my_event',
  data: {'key': 'value'},
)
```

Serializes to/from JSON with `toJson()` / `fromJson()`.

## License

MIT
