/// Festival dates for the Festival lights badge. Must match the rows the
/// badges migration inserts into `public.festivals`
/// (supabase/migrations/20261013120000_badges_feed_thanks_festivals.sql).
/// Lunar festivals move every year; a day either side covers regions that
/// celebrate on different days.
abstract final class Festivals {
  static final List<({String id, String name, DateTime starts, DateTime ends})> all = [
    _f('holi_2025', 'Holi', '2025-03-13', '2025-03-15'),
    _f('bihu_2025', 'Rongali Bihu', '2025-04-14', '2025-04-16'),
    _f('durga_puja_2025', 'Durga Puja', '2025-09-28', '2025-10-02'),
    _f('diwali_2025', 'Diwali', '2025-10-19', '2025-10-22'),
    _f('hornbill_2025', 'Hornbill Festival', '2025-12-01', '2025-12-10'),
    _f('christmas_2025', 'Christmas', '2025-12-24', '2025-12-26'),
    _f('holi_2026', 'Holi', '2026-03-03', '2026-03-04'),
    _f('bihu_2026', 'Rongali Bihu', '2026-04-14', '2026-04-16'),
    _f('durga_puja_2026', 'Durga Puja', '2026-10-16', '2026-10-21'),
    _f('diwali_2026', 'Diwali', '2026-11-07', '2026-11-10'),
    _f('hornbill_2026', 'Hornbill Festival', '2026-12-01', '2026-12-10'),
    _f('christmas_2026', 'Christmas', '2026-12-24', '2026-12-26'),
    _f('holi_2027', 'Holi', '2027-03-21', '2027-03-22'),
    _f('bihu_2027', 'Rongali Bihu', '2027-04-14', '2027-04-16'),
    _f('durga_puja_2027', 'Durga Puja', '2027-10-05', '2027-10-10'),
    _f('diwali_2027', 'Diwali', '2027-10-28', '2027-10-30'),
    _f('hornbill_2027', 'Hornbill Festival', '2027-12-01', '2027-12-10'),
    _f('christmas_2027', 'Christmas', '2027-12-24', '2027-12-26'),
  ];

  /// The festival on [date], if any ("Durga Puja").
  static String? on(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    for (final f in all) {
      if (!day.isBefore(f.starts) && !day.isAfter(f.ends)) return f.name;
    }
    return null;
  }

  static ({String id, String name, DateTime starts, DateTime ends}) _f(
    String id,
    String name,
    String from,
    String to,
  ) => (id: id, name: name, starts: DateTime.parse(from), ends: DateTime.parse(to));
}
