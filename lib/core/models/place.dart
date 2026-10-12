import 'dart:ui';

import 'place_category.dart';

/// A real-world place. Shared by everyone — what a person *thought* of it
/// lives in a [Visit], never here.
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.area,
    required this.address,
    required this.category,
    this.city,
    this.state,
    this.mapPosition,
    this.distance,
  });

  final String id;
  final String name;

  /// Short locality shown in meta lines, e.g. "Melaghar".
  final String area;

  /// Longer address shown on the place screen, e.g. "Melaghar, Tripura".
  final String address;
  final PlaceCategory category;

  /// City for the Cities badge; falls back to [area] when unknown.
  final String? city;

  /// Indian state ("Tripura"), for the States and Seven Sisters badges.
  final String? state;

  /// Where the pin sits on the illustrated home map (390×648 space).
  final Offset? mapPosition;

  /// Distance from the user, for "nearby" lists (dummy until GPS is wired).
  final String? distance;

  Place copyWith({Offset? mapPosition}) => Place(
    id: id,
    name: name,
    area: area,
    address: address,
    category: category,
    city: city,
    state: state,
    mapPosition: mapPosition ?? this.mapPosition,
    distance: distance,
  );
}
