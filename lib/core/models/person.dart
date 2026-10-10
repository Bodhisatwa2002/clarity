import 'dart:ui';

/// Anyone on (or invitable to) Clarity: you, friends, contacts.
class Person {
  const Person({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarBg,
    required this.avatarFg,
    this.username,
    this.city,
    this.placesCount = 0,
    this.citiesCount = 0,
    this.tasteMatch,
    this.lastPlace,
    this.note,
  });

  final String id;
  final String name;
  final String initials;
  final Color avatarBg;
  final Color avatarFg;
  final String? username;
  final String? city;
  final int placesCount;
  final int citiesCount;

  /// 0–100, how often your ratings agree.
  final int? tasteMatch;
  final String? lastPlace;

  /// Why you might know them: "In your contacts", "3 mutual friends".
  final String? note;

  String get firstName => name.split(' ').first;
  String get handle => username == null ? '' : '@$username';
}
