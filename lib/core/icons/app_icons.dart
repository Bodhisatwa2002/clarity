import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The design's hand-drawn 24×24 line icons, kept as raw SVG so they render
/// pixel-identical to the mockups.
enum AppIcon {
  pin('<path d="M12 21.5s-7-6.1-7-11.5a7 7 0 0 1 14 0c0 5.4-7 11.5-7 11.5z"/><circle cx="12" cy="10" r="2.6"/>'),
  search('<circle cx="11" cy="11" r="6.5"/><path d="M16 16l4.5 4.5"/>'),
  bell('<path d="M6 16V11a6 6 0 0 1 12 0v5l1.5 2h-15z"/><path d="M10 20.5a2 2 0 0 0 4 0"/>'),
  map('<path d="M9 4L3 6.5v13L9 17l6 2.5 6-2.5V4l-6 2.5z"/><path d="M9 4v13M15 6.5v13"/>'),
  list('<path d="M8 6h12M8 12h12M8 18h12M4 6h.01M4 12h.01M4 18h.01"/>'),
  feed('<rect x="4" y="3.5" width="16" height="17" rx="2.5"/><path d="M8 8.5h8M8 12.5h8M8 16.5h5"/>'),
  plus('<path d="M12 5v14M5 12h14"/>'),
  friends(
    '<circle cx="9" cy="9" r="3.2"/><path d="M3.5 19a5.5 5.5 0 0 1 11 0"/><circle cx="17" cy="8" r="2.5"/><path d="M16 13.5a4.5 4.5 0 0 1 5 4.5"/>',
  ),
  user('<circle cx="12" cy="8.5" r="3.5"/><path d="M5 20a7 7 0 0 1 14 0"/>'),
  navigate('<path d="M20 4L4 11l7 2 2 7z"/>'),
  star('<path d="M12 3.5l2.6 5.3 5.9.9-4.3 4.1 1 5.8L12 16.9l-5.2 2.7 1-5.8L3.5 9.7l5.9-.9z"/>'),
  back('<path d="M15 5l-7 7 7 7"/>'),
  chevronRight('<path d="M9 6l6 6-6 6"/>'),
  chevronDown('<path d="M6 9l6 6 6-6"/>'),
  close('<path d="M6 6l12 12M18 6L6 18"/>'),
  lock('<rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>'),
  chat(
    '<path d="M4 5h16a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H9l-4 3.5V17H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1z"/><path d="M8 11h.01M12 11h.01M16 11h.01"/>',
  ),
  chatPlain('<path d="M4 5h16a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H9l-4 3.5V17H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1z"/>'),
  chatAlert(
    '<path d="M4 5h16a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H9l-4 3.5V17H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1z"/><path d="M12 8v4M12 14.5h.01"/>',
  ),
  camera('<path d="M4 8h3l2-3h6l2 3h3v11H4z"/><circle cx="12" cy="13" r="3.5"/>'),
  check('<path d="M5 12.5l4.5 4.5L19 7.5"/>'),
  link(
    '<path d="M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1"/><path d="M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1"/>',
  ),
  contacts(
    '<rect x="4" y="3" width="15" height="18" rx="2.5"/><circle cx="11.5" cy="10" r="2.6"/><path d="M7.5 17a4 4 0 0 1 8 0"/><path d="M19 7h1.5M19 11h1.5M19 15h1.5"/>',
  ),
  shield('<path d="M12 3l7 3v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6z"/>'),
  shieldCheck('<path d="M12 3l7 3v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6z"/><path d="M9 12l2 2 4-4"/>'),
  listCheck('<path d="M4 7h10M4 12h7M4 17h10"/><path d="M16 15l2 2 3.5-4"/>'),
  cup(
    '<path d="M4 9h13v5a5 5 0 0 1-5 5H9a5 5 0 0 1-5-5z"/><path d="M17 11h1.5a2.5 2.5 0 0 1 0 5H17"/><path d="M8 3.5v2M12 3.5v2"/>',
  ),
  peak('<path d="M3 19l6.5-11 4 6.5 2.5-3.5L21 19z"/>'),
  crosshair(
    '<circle cx="12" cy="12" r="3.5"/><path d="M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3"/><circle cx="12" cy="12" r="7.5"/>',
  ),
  bookmark('<path d="M6 3.5h12v17l-6-4-6 4z"/>'),
  image(
    '<rect x="3.5" y="5" width="17" height="14" rx="2.5"/><circle cx="9" cy="10" r="1.8"/><path d="M20.5 16l-5-5-8 8"/>',
  ),
  bulb(
    '<path d="M9 18h6M10 21h4"/><path d="M12 3a6 6 0 0 0-3.5 10.9c.6.5 1 1.2 1 2V16h5v-.1c0-.8.4-1.5 1-2A6 6 0 0 0 12 3z"/>',
  ),
  share('<path d="M12 15V3.5M7.5 8L12 3.5 16.5 8"/><path d="M5 12v7.5h14V12"/>'),
  heart('<path d="M12 20s-7.5-4.6-7.5-10.2A4.3 4.3 0 0 1 12 7.4a4.3 4.3 0 0 1 7.5 2.4C19.5 15.4 12 20 12 20z"/>'),
  sparkle(
    '<path d="M12 3l1.8 4.7L18.5 9.5l-4.7 1.8L12 16l-1.8-4.7L5.5 9.5l4.7-1.8z"/><path d="M19 15l.8 2.2L22 18l-2.2.8L19 21l-.8-2.2L16 18l2.2-.8z"/>',
  ),
  whatsapp('<path d="M4 20l1.3-3.9A8 8 0 1 1 8 19z"/>'),
  instagram('<rect x="4" y="4" width="16" height="16" rx="5"/><circle cx="12" cy="12" r="3.6"/>'),
  more(
    '<circle cx="6" cy="12" r="1.8"/><circle cx="12" cy="12" r="1.8"/><circle cx="18" cy="12" r="1.8"/>',
    filled: true,
  ),
  settings(
    '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 0 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 0 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 0 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 0 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/>',
  ),
  wifiOff(
    '<path d="M2.5 8.8a14 14 0 0 1 5-2.8M11 5.5a14 14 0 0 1 10.5 3.3"/><path d="M5.5 12.2a9.5 9.5 0 0 1 3.6-2.1M14.4 10.1a9.5 9.5 0 0 1 4.1 2.1"/><path d="M9 15.5a4.5 4.5 0 0 1 6 0"/><path d="M12 19h.01"/><path d="M3 3l18 18"/>',
  ),
  clock('<circle cx="12" cy="12" r="8"/><path d="M12 8v4l2.5 2"/>'),
  warning('<path d="M12 3.5L2.5 20h19z"/><path d="M12 10v4.5M12 17.2h.01"/>'),
  alertCircle('<circle cx="12" cy="12" r="8.5"/><path d="M12 8v4.5M12 15.7h.01"/>');

  const AppIcon(this.body, {this.filled = false});

  /// Inner SVG markup in a 24×24 view box.
  final String body;

  /// Whether the icon is drawn with fill instead of stroke by default.
  final bool filled;
}

/// Renders an [AppIcon] in the given color.
///
/// Line icons use [color] as the stroke; pass [fill] to also fill the shape
/// (e.g. a liked heart or a bookmarked place).
class AppIconView extends StatelessWidget {
  const AppIconView(
    this.icon, {
    super.key,
    this.size = 20,
    this.color = const Color(0xFF111111),
    this.strokeWidth = 2,
    this.fill,
  });

  final AppIcon icon;
  final double size;
  final Color color;
  final double strokeWidth;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final String fillAttr;
    final String strokeAttr;
    if (icon.filled) {
      fillAttr = svgColor(color);
      strokeAttr = 'none';
    } else {
      fillAttr = fill == null ? 'none' : svgColor(fill!);
      strokeAttr = svgColor(color);
    }
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
        'fill="$fillAttr" stroke="$strokeAttr" stroke-width="$strokeWidth" '
        'stroke-linecap="round" stroke-linejoin="round">${icon.body}</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

/// A solid star (for ratings), sized like the design's inline stars.
class StarIcon extends StatelessWidget {
  const StarIcon({super.key, this.size = 14, this.color = const Color(0xFF111111)});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
        'fill="${svgColor(color)}">${AppIcon.star.body}</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

/// `#RRGGBB` (plus `fill-opacity` is not needed: callers pass opaque colors,
/// or an `rgba()` string for translucent ones).
String svgColor(Color c) {
  final a = c.a;
  final r = (c.r * 255).round();
  final g = (c.g * 255).round();
  final b = (c.b * 255).round();
  if (a < 1) return 'rgba($r,$g,$b,${a.toStringAsFixed(3)})';
  String hex(int v) => v.toRadixString(16).padLeft(2, '0');
  return '#${hex(r)}${hex(g)}${hex(b)}';
}
