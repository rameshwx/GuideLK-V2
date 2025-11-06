import 'package:flutter/foundation.dart';

@immutable
class Poi {
  const Poi({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.isPublished,
  });

  final int id;
  final String name;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final bool isPublished;

  Poi copyWith({
    String? name,
    String? category,
    String? description,
    double? latitude,
    double? longitude,
    bool? isPublished,
  }) {
    return Poi(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
