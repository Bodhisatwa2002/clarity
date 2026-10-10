import 'package:flutter/widgets.dart';

import '../../../core/models/person.dart';
import '../../../core/theme/app_theme.dart';
import 'dashed_border.dart';
import 'pressable.dart';

/// A colored circle with someone's initials — the app's avatar until real
/// profile photos exist.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.initials,
    required this.background,
    required this.foreground,
    this.size = 46,
    this.fontSize,
    this.ring,
    this.onTap,
  });

  /// Convenience for a [Person]'s colors and initials.
  InitialsAvatar.person(Person person, {Key? key, double size = 46, double? fontSize, Color? ring, VoidCallback? onTap})
    : this(
        key: key,
        initials: person.initials,
        background: person.avatarBg,
        foreground: person.avatarFg,
        size: size,
        fontSize: fontSize,
        ring: ring,
        onTap: onTap,
      );

  final String initials;
  final Color background;
  final Color foreground;
  final double size;
  final double? fontSize;

  /// Optional 2pt outline (used in overlapping avatar stacks).
  final Color? ring;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        border: ring == null ? null : Border.all(color: ring!, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppText.sans(fontSize ?? (size * 0.32).roundToDouble(), weight: FontWeight.w800, color: foreground),
      ),
    );
    return onTap == null ? avatar : Pressable(onTap: onTap, child: avatar);
  }
}

/// A dashed, empty avatar for contacts who aren't on Clarity yet.
class GhostAvatar extends StatelessWidget {
  const GhostAvatar({super.key, required this.label, this.size = 46, this.color = AppColors.chipBorder});

  final String label;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: color,
      shape: BoxShape.circle,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            label,
            style: AppText.sans(15, weight: FontWeight.w800, color: AppColors.slate),
          ),
        ),
      ),
    );
  }
}

/// Overlapping avatars ("BC PK RS AD").
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.people,
    this.size = 38,
    this.overlap = 10,
    this.ring = AppColors.avatarRing,
  });

  final List<Person> people;
  final double size;
  final double overlap;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: people.isEmpty ? 0 : size + (people.length - 1) * (size - overlap),
      child: Stack(
        children: [
          for (var i = 0; i < people.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: InitialsAvatar.person(people[i], size: size, fontSize: 12, ring: ring),
            ),
        ],
      ),
    );
  }
}
