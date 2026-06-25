# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code
flutter analyze

# Run the example app (Android device/emulator required — Android-only package)
cd example && flutter run

# Validate the package before publishing
flutter pub publish --dry-run
```

## Architecture

This is a Flutter **pub.dev package** (`secondary_screen`) that wraps a bundled Android
Presentation plugin with BLoC state management to simplify dual-screen / secondary
display control. It is imported as `package:secondary_screen/secondary_screen.dart`.

### Package structure

The public API is exported from [lib/secondary_screen.dart](lib/secondary_screen.dart),
the barrel file, which re-exports everything under `lib/src/`:

- **[secondary_screen_cubit.dart](lib/src/secondary_screen_cubit.dart)** — `SecondaryScreenCubit`
  (a `Cubit<SecondaryScreenState>`). The main entry point for consumers. It is a **singleton**
  (`SecondaryScreenCubit.instance`) implemented via a factory constructor. All display operations
  (`init`, `showOnSecondary`, `hideOnSecondary`, `updateDataOnSecondary`, `reConnectCurrentRoute`)
  live here. `_handleReConnect()` sets up a listener on `connectedDisplaysChangedStream` that
  auto-reconnects and re-shows the last route when displays are plugged/unplugged.

- **[secondary_screen_state.dart](lib/src/secondary_screen_state.dart)** — `SecondaryScreenState`
  (immutable, `copyWith` with an `_unset` sentinel so `null` can be set explicitly) and the
  `SecondaryScreenServiceState` enum (`initial`, `connected`, `disconnected`). Key fields:
  `currentRoute`, `currentData`, `currentSecondaryDisplay`, `isShowing`, `isLoading`, `error`.
  Getter `defaultSecondaryDisplayId`. This file is a `part of` the cubit file.

- **[transfer_data_model.dart](lib/src/transfer_data_model.dart)** — `TransferDataModel`, a
  JSON-serializable model for typed events (`eventName` + `data` map). JSON keys are snake_case
  (`event_name`, `data`).

- **[secondary_display_widget.dart](lib/src/secondary_display_widget.dart)** — `SecondaryDisplay`,
  the widget used **on the secondary screen** to receive data pushed from the primary side. It
  opens the `secondary_screen_engine` MethodChannel and forwards incoming payloads to its
  `callback`. Each secondary route wraps its UI in this widget.

- **[display_manager.dart](lib/src/display_manager.dart)** — `DisplayManager`, the low-level
  wrapper over the native MethodChannel `secondary_screen` and EventChannel `secondary_screen_events`
  (list displays, show/hide a presentation, transfer data, display-change stream).

- **[display.dart](lib/src/display.dart)** — the `Display` model, `displayFromJson`, and
  flag/rotation constants.

- **[secondary_screen_helpers.dart](lib/src/secondary_screen_helpers.dart)** —
  `SecondaryScreenHelpers`, a static-only utility for serializing `SecondaryScreenState` and
  `Display` to/from JSON maps.

### Native plugin

The Android side lives under
[android/src/main/kotlin/com/felixdinh/secondary_screen/](android/src/main/kotlin/com/felixdinh/secondary_screen/):
`SecondaryScreenPlugin.kt` (channel handler), `PresentationDisplay.kt` (the `Presentation`
subclass hosting a `FlutterView`), and `DisplayJson.kt`. The plugin creates a separate
`FlutterEngine` running the Dart entry point named **`secondaryDisplayMain`** (this name is
hardcoded in `SecondaryScreenPlugin.kt`, so consumers must use it). The three channel IDs
(`secondary_screen`, `secondary_screen_events`, `secondary_screen_engine`) must stay in sync
between Kotlin and the Dart side (`display_manager.dart`, `secondary_display_widget.dart`).

### Key design decisions

- `showOnSecondary(routeName, {json})` only re-navigates the second screen when it isn't already
  showing **or** when `routeName` differs from `state.currentRoute`; otherwise it just transfers
  the data. This makes it safe to call repeatedly.
- `updateDataOnSecondary(data)` takes a raw JSON `String` and only transfers data without changing
  the route (lazily `init(autoShow: false)` if no display is connected yet). `showOnSecondary` takes
  an optional JSON-encoded string and decodes it before calling `transferDataToPresentation`.
- `hideOnSecondary` keeps `currentRoute` so `reConnectCurrentRoute` can restore the last screen.
- Data flow is one-way (primary → secondary). The receiving screen reads `event_name` from the
  payload and dispatches accordingly.
- This package is **Android-only** — it uses the Android Presentation API. No separate
  `FlutterActivity` registration is required; the default `flutterEmbedding` v2 meta-data is enough.
  The `example/` app only targets Android.

### Example app

[example/lib/main.dart](example/lib/main.dart) demonstrates the dual-entry-point pattern required
for secondary displays: `main()` runs the primary app wrapped in
`BlocProvider<SecondaryScreenCubit>`, and `secondaryDisplayMain()` (annotated
`@pragma('vm:entry-point')`) runs a minimal `MaterialApp` using the same `generateRoute` function.
The example is a Point-of-Sale demo — `sales_screen.dart` (primary) drives `order_display_screen.dart`
and `promotion_screen.dart` on the customer-facing second screen; `todo_screen.dart` shows the
event-based transfer pattern.
