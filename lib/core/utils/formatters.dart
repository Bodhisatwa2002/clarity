/// Small display helpers shared by screens.
abstract final class Fmt {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  /// "Aug 2026".
  static String monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  /// "9 Aug 2026".
  static String dayMonthYear(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// "2h ago" for the last day, otherwise "Aug 2026".
  static String relative(DateTime d, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return monthYear(d);
  }

  /// Short age for feed cards and notifications: "10m", "2h", "Yesterday",
  /// "3d", then "Aug 2026".
  static String ago(DateTime d, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inHours < 48) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return monthYear(d);
  }

  /// One decimal, the way ratings are shown everywhere ("4.5").
  static String rating(double r) => r.toStringAsFixed(1);

  /// "1 place" / "7 places".
  static String count(int n, String singular, [String? plural]) =>
      '$n ${n == 1 ? singular : (plural ?? '${singular}s')}';

  /// "98765 43210" from raw digits.
  static String phone(String digits) => digits.length > 5 ? '${digits.substring(0, 5)} ${digits.substring(5)}' : digits;

  /// "BC" from "Bodhi Chakraborty".
  static String initials(String name) =>
      name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();
}
