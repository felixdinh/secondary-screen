# Changelog

## 2.0.0

> **Breaking:** the import path changed. Update imports to
> `import 'package:secondary_screen/secondary_screen.dart';`.

- Flatten the library layout to `lib/secondary_screen.dart` + `lib/src/`, so the
  package is imported as `package:secondary_screen/secondary_screen.dart`
  (previously the redundant `package:secondary_screen/secondary_screen/secondary_screen.dart`)
- Rename the internal source file `secondary_screen_service.dart` →
  `secondary_screen_cubit.dart` to match the `SecondaryScreenCubit` class
  (public class names are unchanged)
- Rename the native MethodChannel/EventChannel IDs from `presentation_displays_plugin*`
  to `secondary_screen*` (Dart and Android kept in sync)
- Rename the Android plugin package `com.example.secondary_screen` →
  `com.felixdinh.secondary_screen`

## 1.0.1

- Improve README with full usage guide, API reference, and setup instructions
- Widen `flutter_bloc` constraint to `>=8.1.3 <10.0.0` to support the latest stable (9.x)

## 1.0.0+1

- Initial release
- `SecondaryScreenCubit` for managing secondary display state with BLoC
- Support for showing, hiding, and transferring data to secondary screens
- Auto-reconnect on display change
- `TransferDataModel` for structured data transfer between screens
