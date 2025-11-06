# GuideLK Mobile App

Flutter application targeting Android and iOS that provides the Sri Lanka offline-first trip
planner. The project is configured for Riverpod state management, Hive offline storage, and
flutter_map based mapping with offline MBTiles tiles.

## Getting started

1. Install Flutter 3.19 or newer.
2. Run `flutter pub get`.
3. Place a licensed `sri_lanka.mbtiles` file under `assets/tiles/`.
4. Configure Firebase by adding `google-services.json` and `GoogleService-Info.plist` files for the
   `guidelk-d1393` project.
5. Run the application with `flutter run`.

The map camera is constrained to Sri Lanka by default. Attribution for OpenStreetMap and
OpenMapTiles is displayed in the lower-right corner.
