import 'dart:ui';

/// Where pins sit on the illustrated home map (390×648 space) until the real
/// Google map replaces it. Pins take these spots in order, newest visit first.
abstract final class MapSlots {
  static const List<Offset> all = [
    Offset(104, 194),
    Offset(280, 268),
    Offset(214, 150),
    Offset(64, 300),
    Offset(290, 350),
    Offset(200, 348),
    Offset(330, 128),
    Offset(176, 96),
    Offset(250, 206),
    Offset(36, 238),
    Offset(352, 300),
    Offset(130, 340),
    Offset(356, 200),
    Offset(60, 120),
  ];

  static Offset at(int index) => all[index % all.length];
}
