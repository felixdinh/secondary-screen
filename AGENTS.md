# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

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
```

## Architecture

This is a Flutter **pub.dev package** (`secondary_screen`) that wraps the `presentation_displays` plugin with BLoC state management to simplify dual-screen/secondary display control.

### Package structure

The public API is exported from [lib/dual_screen_service/dual_screen_service.dart](lib/dual_screen_service/dual_screen_service.dart), which re-exports three files:

- **[dual_screen_service.dart](lib/dual_screen_service/src/dual_screen_service.dart)** — `DualScreenCubit` (a `Cubit<DualScreenState>`). This is the main entry point for consumers. It is a **singleton** (`DualScreenCubit.instance`) implemented via a factory constructor. All display operations (`showOnSecondary`, `hideOnSecondary`, `updateDataOnSecondary`, `reConnectCurrentRoute`) live here. `_handleReConnect()` sets up a stream listener on `connectedDisplaysChangedStream` that auto-reconnects when displays are plugged/unplugged.

- **[dual_screen_state.dart](lib/dual_screen_service/src/dual_screen_state.dart)** — `DualScreenState` (immutable, `copyWith` pattern) and `DualScreenServiceState` enum (`initial`, `connected`, `disconnected`). This file is a `part of` the cubit file.

- **[transfer_data_model.dart](lib/dual_screen_service/src/transfer_data_model.dart)** — `TransferDataModel`, a simple JSON-serializable model for passing typed events (`eventName` + `data` map) to the secondary display. JSON keys are snake_case (`event_name`, `data`).

- **[dual_screen_helpers.dart](lib/dual_screen_service/src/dual_screen_helpers.dart)** — `DualScreenHelpers`, a static-only utility class for serializing `DualScreenState` and `Display` to/from JSON maps.

### Key design decisions

- `showOnSecondary` skips calling `_displayManager.showSecondaryDisplay` if the route hasn't changed (deduplication guard on `state.currentRoute`). To force a re-show, callers must set `currentRoute` to null first (as `init` does).
- `updateDataOnSecondary` takes a raw `String` (not a `TransferDataModel`), while `showOnSecondary` takes a JSON-encoded string and decodes it internally before calling `transferDataToPresentation`.
- This package is **Android-only** — it relies on `presentation_displays`, which uses the Android Presentation API. The `example/` app only targets Android.

### Example app

[example/lib/main.dart](example/lib/main.dart) demonstrates the dual-entry-point pattern required for secondary displays: `main()` runs the primary app wrapped in `BlocProvider<DualScreenCubit>`, and `secondaryDisplayMain()` (annotated `@pragma('vm:entry-point')`) runs a minimal `MaterialApp` using the same `generateRoute` function. The secondary app must be registered as a separate `FlutterActivity` in `AndroidManifest.xml`.
