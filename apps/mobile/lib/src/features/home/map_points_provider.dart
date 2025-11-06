import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../models/map_point.dart';
import '../../providers/data_providers.dart';

final mapPointsProvider = FutureProvider<List<MapPoint>>((ref) async {
  final pois = await ref.watch(poisProvider.future);
  final stays = await ref.watch(partnerStaysProvider.future);

  final poiPoints = pois
      .where((poi) => poi.isPublished)
      .map(
        (poi) => MapPoint(
          id: poi.id,
          title: poi.name,
          subtitle: poi.category,
          position: LatLng(poi.latitude, poi.longitude),
          kind: MapPointKind.poi,
          description: poi.description,
          phone: poi.phone,
          website: poi.website,
          photos: poi.photos,
        ),
      );

  final stayPoints = stays
      .where((stay) => stay.isPublished)
      .map(
        (stay) => MapPoint(
          id: stay.id,
          title: stay.name,
          subtitle: stay.address,
          position: LatLng(stay.latitude, stay.longitude),
          kind: MapPointKind.stay,
          phone: stay.phone,
          website: stay.website,
          photos: stay.photos,
        ),
      );

  return [...poiPoints, ...stayPoints];
});
