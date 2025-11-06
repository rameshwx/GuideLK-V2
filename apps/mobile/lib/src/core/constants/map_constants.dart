import 'package:latlong2/latlong.dart';

class MapConstants {
  MapConstants._();

  static const LatLng initialCenter = LatLng(7.873054, 80.771797);

  static final LatLngBounds sriLankaBounds = LatLngBounds(
    const LatLng(5.76, 79.54),
    const LatLng(9.98, 82.05),
  );
}
