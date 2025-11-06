import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const sriLankaBounds = LatLngBounds(
  LatLng(5.76, 79.54),
  LatLng(9.98, 82.05),
);

const sriLankaBoundsPadding = 0.1;

LatLngBounds paddedSriLankaBounds(double paddingDegrees) {
  return LatLngBounds(
    LatLng(sriLankaBounds.south - paddingDegrees, sriLankaBounds.west - paddingDegrees),
    LatLng(sriLankaBounds.north + paddingDegrees, sriLankaBounds.east + paddingDegrees),
  );
}

const sriLankaCenter = LatLng(7.873054, 80.771797);
