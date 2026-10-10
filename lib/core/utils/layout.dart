import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The mockups are drawn on a 390×844 iPhone where content starts 60pt from
/// the top (status bar included). These helpers translate design offsets to
/// the real device's safe area.
abstract final class Layout {
  static const double designTop = 60;

  /// Where header content starts on this device.
  static double top(BuildContext context) => math.max(MediaQuery.paddingOf(context).top + 13, 40);

  /// A design y-offset (measured from the top of the 844pt frame) adjusted
  /// for this device's status bar.
  static double y(BuildContext context, double designY) => designY - designTop + top(context);

  /// Bottom padding for scrolling content that sits under the floating nav.
  static const double navClearance = 120;
}
