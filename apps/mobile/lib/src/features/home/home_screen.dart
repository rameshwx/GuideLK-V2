import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

import '../../l10n/l10n.dart';

final sriLankaBounds = LatLngBounds(
  const LatLng(5.76, 79.54),
  const LatLng(9.98, 82.05),
);

const initialCenter = LatLng(7.873054, 80.771797);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<MbTilesTileProvider>? _providerFuture;

  @override
  void initState() {
    super.initState();
    _providerFuture = _loadMbtilesProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.homeTitle)),
      body: FutureBuilder<MbTilesTileProvider>(
        future: _providerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Text(context.l10n.loadingMap));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Failed to load offline tiles. Ensure sri_lanka.mbtiles is bundled.',
                textAlign: TextAlign.center,
              ),
            );
          }
          final provider = snapshot.requireData;
          return FlutterMap(
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 7,
              cameraConstraint: CameraConstraint.contain(bounds: sriLankaBounds),
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                tileProvider: provider,
                userAgentPackageName: 'com.guidelk.mobile',
                maxZoom: 14,
                minZoom: 6,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        context.l10n.mapAttribution,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<MbTilesTileProvider> _loadMbtilesProvider() async {
  const mbtilesAssetPath = 'assets/tiles/sri_lanka.mbtiles';
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final destination = File('${documentsDirectory.path}/sri_lanka.mbtiles');

  if (!await destination.exists()) {
    final data = await rootBundle.load(mbtilesAssetPath);
    final bytes = data.buffer.asUint8List();
    await destination.writeAsBytes(bytes, flush: true);
  }
  return MbTilesTileProvider.fromSource(destination.path);
}
