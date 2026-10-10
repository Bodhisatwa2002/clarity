import 'package:flutter/painting.dart';

/// What kind of place a pin is. Drives pin colors across the app.
enum PlaceCategory {
  food('Food', Color(0xFFE8590C)),
  cafe('Café', Color(0xFF7A4A1E)),
  stay('Stay', Color(0xFF7048E8)),
  trek('Trek', Color(0xFF2B8A3E)),
  viewpoint('Viewpoint', Color(0xFF1971C2)),
  temple('Temple', Color(0xFFC2255C)),
  beach('Beach', Color(0xFF0B7285)),
  other('Other', Color(0xFF5B6577));

  const PlaceCategory(this.label, this.color);

  final String label;
  final Color color;

  /// Categories offered in filters and pickers (the long tail is hidden).
  static const List<PlaceCategory> pickable = [food, cafe, stay, trek, viewpoint, temple];
}
