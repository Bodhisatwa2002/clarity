import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';

/// The illustrated (placeholder) maps from the design. These stand in for
/// Google Maps until the SDK and an API key are wired up.
enum MapArt {
  /// Full home map, 390×648.
  home(390, 648, '''
<path d="M0 410 C 60 380, 90 440, 150 430 S 260 380, 300 420 S 370 470, 390 450 L 390 648 L 0 648 Z" fill="#D4E5F8"/>
<path d="M232 250 c 30 -18 74 -10 82 18 c 8 28 -18 52 -50 52 c -34 0 -58 -44 -32 -70 z" fill="#CFE2F7"/>
<path d="M20 90 c 40 -20 90 -6 96 26 c 6 30 -40 46 -76 40 c -36 -6 -50 -48 -20 -66 z" fill="#DCEEE2"/>
<path d="M300 60 c 34 -10 70 10 70 40 c 0 30 -40 40 -66 30 c -26 -10 -30 -62 -4 -70 z" fill="#DCEEE2"/>
<g fill="none" stroke="#FFFFFF" stroke-linecap="round">
<path d="M-10 230 C 80 210, 150 260, 230 230 S 360 190, 400 210" stroke-width="12"/>
<path d="M150 -10 C 160 90, 120 180, 170 300 S 200 460, 180 660" stroke-width="10"/>
<path d="M0 340 C 90 330, 180 360, 260 340 S 360 300, 400 320" stroke-width="6"/>
<path d="M250 -10 C 240 60, 280 130, 270 200" stroke-width="6"/>
<path d="M60 160 L 120 300 L 70 400" stroke-width="5"/>
<path d="M330 220 L 360 360" stroke-width="5"/>
</g>'''),

  /// Faded backdrop behind the empty-map state, 390×704.
  empty(390, 704, '''
<path d="M0 470 C 60 440, 90 500, 150 490 S 260 440, 300 480 S 370 530, 390 510 L 390 704 L 0 704 Z" fill="#D4E5F8"/>
<path d="M20 120 c 40 -20 90 -6 96 26 c 6 30 -40 46 -76 40 c -36 -6 -50 -48 -20 -66 z" fill="#DCEEE2"/>
<g fill="none" stroke="#FFFFFF" stroke-linecap="round">
<path d="M-10 260 C 80 240, 150 290, 230 260 S 360 220, 400 240" stroke-width="12"/>
<path d="M150 -10 C 160 90, 120 180, 170 330 S 200 500, 180 720" stroke-width="10"/>
<path d="M0 380 C 90 370, 180 400, 260 380 S 360 340, 400 360" stroke-width="6"/>
</g>'''),

  /// "Drop a pin" picker, 350×250.
  pinDrop(
    350,
    250,
    '''
<path d="M0 170 C 70 150, 120 200, 200 180 S 320 140, 350 160 L 350 250 L 0 250 Z" fill="#D4E5F8"/>
<path d="M40 40 c 40 -20 90 -6 96 26 c 6 30 -40 46 -76 40 c -36 -6 -50 -48 -20 -66 z" fill="#DCEEE2"/>
<path d="M-10 110 C 80 90, 150 140, 230 110 S 330 80, 360 100" fill="none" stroke="#FFFFFF" stroke-width="10" stroke-linecap="round"/>
<path d="M240 -10 C 230 60, 270 130, 260 260" fill="none" stroke="#FFFFFF" stroke-width="6" stroke-linecap="round"/>''',
  ),

  /// A friend's mini map with category dots, 358×180.
  friend(358, 180, '''
<path d="M0 130 C 70 110, 120 160, 200 140 S 320 100, 358 120 L 358 180 L 0 180 Z" fill="#D4E5F8"/>
<path d="M260 30 c 30 -12 70 0 70 30 c 0 26 -40 34 -64 24 c -24 -10 -30 -46 -6 -54 z" fill="#DCEEE2"/>
<path d="M-10 80 C 80 60, 150 110, 230 80 S 330 50, 368 70" fill="none" stroke="#FFFFFF" stroke-width="9" stroke-linecap="round"/>
<path d="M120 -10 C 130 60, 100 110, 140 190" fill="none" stroke="#FFFFFF" stroke-width="6" stroke-linecap="round"/>
<g stroke="#FFFFFF" stroke-width="2">
<circle cx="60" cy="50" r="8" fill="#E8590C"/><circle cx="96" cy="96" r="8" fill="#2B8A3E"/><circle cx="170" cy="56" r="8" fill="#1971C2"/>
<circle cx="210" cy="112" r="8" fill="#2B8A3E"/><circle cx="286" cy="60" r="8" fill="#2B8A3E"/><circle cx="312" cy="128" r="8" fill="#7048E8"/>
<circle cx="240" cy="36" r="8" fill="#E8590C"/><circle cx="34" cy="120" r="8" fill="#C2255C"/>
</g>'''),

  /// The tiny map inside a share card, 164×92.
  shareCard(164, 92, '''
<path d="M-5 50 C 40 36, 80 70, 120 52 S 160 40, 170 46" fill="none" stroke="#DCE6F3" stroke-width="7" stroke-linecap="round"/>
<g stroke="#FFFFFF" stroke-width="1.5">
<circle cx="30" cy="30" r="6" fill="#E8590C"/><circle cx="62" cy="62" r="6" fill="#2B8A3E"/><circle cx="100" cy="28" r="6" fill="#1971C2"/><circle cx="134" cy="66" r="6" fill="#7048E8"/>
</g>''');

  const MapArt(this.width, this.height, this.body);

  final double width;
  final double height;
  final String body;

  Size get size => Size(width, height);

  String get svg =>
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $width $height" '
      'width="$width" height="$height">$body</svg>';
}

/// Paints a [MapArt] at its native size.
class MapArtView extends StatelessWidget {
  const MapArtView(this.art, {super.key});

  final MapArt art;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(art.svg, width: art.width, height: art.height, fit: BoxFit.fill);
  }
}

/// A teardrop map pin in a category color. [selected] draws the larger,
/// highlighted version.
class MapPinMarker extends StatelessWidget {
  const MapPinMarker({super.key, required this.color, this.selected = false});

  final Color color;
  final bool selected;

  static const Size idleSize = Size(30, 36);
  static const Size selectedSize = Size(52, 60);

  @override
  Widget build(BuildContext context) {
    final c = svgColor(color);
    final svg = selected
        ? '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 60"><path d="M26 58s-20-17-20-33a20 20 0 0 1 40 0c0 16-20 33-20 33z" fill="$c" stroke="#FFFFFF" stroke-width="3"/><circle cx="26" cy="25" r="7" fill="#FFFFFF"/></svg>'
        : '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 36"><path d="M15 34.5s-12-10-12-19.5a12 12 0 0 1 24 0c0 9.5-12 19.5-12 19.5z" fill="$c" stroke="#FFFFFF" stroke-width="2.2"/><circle cx="15" cy="15" r="4" fill="#FFFFFF"/></svg>';
    final size = selected ? selectedSize : idleSize;
    return SvgPicture.string(svg, width: size.width, height: size.height);
  }
}

/// The dashed outline pin from the empty-map illustration.
class GhostPin extends StatelessWidget {
  const GhostPin({super.key, this.width = 44, this.height = 52});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 52 60"><path d="M26 58s-20-17-20-33a20 20 0 0 1 40 0c0 16-20 33-20 33z" fill="none" stroke="#2A66CF" stroke-width="2.5" stroke-dasharray="5 5"/><circle cx="26" cy="25" r="6" fill="#2A66CF"/></svg>',
      width: width,
      height: height,
    );
  }
}

/// "You are here" — a blue dot in a soft halo.
class YouAreHereDot extends StatelessWidget {
  const YouAreHereDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'You are here',
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.blue.withValues(alpha: 0.16)),
        alignment: Alignment.center,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.blue,
            border: Border.all(color: AppColors.white, width: 3),
            boxShadow: [
              BoxShadow(color: AppColors.shadow.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
        ),
      ),
    );
  }
}
