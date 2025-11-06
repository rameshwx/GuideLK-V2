import 'package:latlong2/latlong.dart';

enum MapPointKind { poi, stay }

class MapPoint {
  MapPoint({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.position,
    required this.kind,
    this.description,
    this.phone,
    this.website,
    this.photos = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final LatLng position;
  final MapPointKind kind;
  final String? description;
  final String? phone;
  final String? website;
  final List<String> photos;
}
