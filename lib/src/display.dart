/// Creates a [Display] from a platform display JSON map.
Display displayFromJson(Map<String, dynamic> json) => Display(
    displayId: json['displayId'],
    flag: json['flags'],
    name: json['name'],
    rotation: json['rotation']);

/// Android's default built-in display ID.
const int defaultDisplay = 0;

/// Display ID used by Android when no valid display is available.
const int invalidDisplay = -1;

/// Display flag indicating protected buffers are supported.
const int flagSupportsProtectedBuffers = 1 << 0;

/// Display flag indicating the display is secure.
const int flagSecure = 1 << 1;

/// Display flag indicating the display is private.
const int flagPrivate = 1 << 2;

/// Display rotation value for 0 degrees.
const int rotation0 = 0;

/// Display rotation value for 90 degrees.
const int rotation90 = 1;

/// Display rotation value for 180 degrees.
const int rotation180 = 2;

/// Display rotation value for 270 degrees.
const int rotation270 = 3;

/// Describes an Android display returned by the platform display manager.
class Display {
  /// Unique Android display ID.
  int? displayId = defaultDisplay;

  /// Android display flags.
  int? flag;

  /// Current display rotation.
  int? rotation;

  /// Human-readable display name.
  String? name;

  /// Creates a display descriptor.
  Display(
      {required this.displayId, this.flag, required this.name, this.rotation});
}
