import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

const _defaultTilesUrl =
    'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=YOUR_KEY';

String adminTilesUrl() {
  return const String.fromEnvironment('ADMIN_TILES_URL', defaultValue: _defaultTilesUrl);
}

TileLayer buildAdminTileLayer() {
  return TileLayer(
    urlTemplate: adminTilesUrl(),
    userAgentPackageName: 'com.guidelk.admin',
    tileProvider: NetworkTileProvider(),
    errorTileCallback: (tile, error, stackTrace) {
      debugPrint('Tile error for $tile: $error');
    },
  );
}
