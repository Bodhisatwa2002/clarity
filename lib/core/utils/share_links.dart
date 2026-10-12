/// Every public link the app shows or copies, built in one place so they all
/// follow the same pattern:
///
///   clarity.in/bodhi                    your map
///   clarity.in/bodhi/neermahal          a place on your map
///   clarity.in/bodhi/list/goa-trip-2027 a list you share
///
/// Shown without the scheme; [https] adds it when the link is copied.
abstract final class ShareLinks {
  static const host = 'clarity.in';

  static String map(String username) => '$host/$username';

  static String place(String username, String placeName) => '$host/$username/${slug(placeName)}';

  static String list(String username, String listTitle) => '$host/$username/list/${slug(listTitle)}';

  static String https(String link) => 'https://$link';

  /// "Goa trip 2027" → "goa-trip-2027".
  static String slug(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
}
