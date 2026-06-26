Display displayFromJson(Map<String, dynamic> json) => Display(
    displayId: json['displayId'],
    flag: json['flags'],
    name: json['name'],
    rotation: json['rotation']);

const int defaultDisplay = 0;
const int invalidDisplay = -1;

const int flagSupportsProtectedBuffers = 1 << 0;
const int flagSecure = 1 << 1;
const int flagPrivate = 1 << 2;

const int rotation0 = 0;
const int rotation90 = 1;
const int rotation180 = 2;
const int rotation270 = 3;

class Display {
  int? displayId = defaultDisplay;
  int? flag;
  int? rotation;
  String? name;

  Display(
      {required this.displayId, this.flag, required this.name, this.rotation});
}
