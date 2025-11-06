import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/map_constants.dart';
import '../../l10n/l10n.dart';
import '../../models/map_point.dart';
import '../../models/trip.dart';
import '../trips/trip_controller.dart';
import 'map_points_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<MbTilesTileProvider>? _providerFuture;

  @override
  void initState() {
    super.initState();
    _providerFuture = _loadMbtilesProvider();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tripState = ref.watch(tripControllerProvider);
    final pointsAsync = ref.watch(mapPointsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          if (tripState.activeTrip != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  l10n.activeTripLabel(tripState.activeTrip!.name),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
        ],
      ),
      body: FutureBuilder<MbTilesTileProvider>(
        future: _providerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Text(l10n.loadingMap));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text(l10n.mapLoadFailure));
          }
          final provider = snapshot.requireData;
          return pointsAsync.when(
            data: (points) => _MapView(
              provider: provider,
              points: points,
              onTapMarker: _showPointDetails,
            ),
            error: (error, _) => Center(child: Text(error.toString())),
            loading: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  void _showPointDetails(MapPoint point) {
    final l10n = context.l10n;
    final tripController = ref.read(tripControllerProvider.notifier);
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      point.kind == MapPointKind.poi
                          ? Icons.location_on_outlined
                          : Icons.hotel_outlined,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        point.title,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                if (point.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(point.subtitle, style: theme.textTheme.bodyMedium),
                ],
                if (point.description != null) ...[
                  const SizedBox(height: 12),
                  Text(point.description!),
                ],
                if (point.website != null || point.phone != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (point.website != null)
                        Chip(
                          avatar: const Icon(Icons.public),
                          label: Text(point.website!),
                        ),
                      if (point.phone != null)
                        Chip(
                          avatar: const Icon(Icons.phone),
                          label: Text(point.phone!),
                        ),
                    ],
                  ),
                ],
                if (point.photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final photo = point.photos[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Image.network(
                              photo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return ColoredBox(
                                  color: theme.colorScheme.surfaceVariant,
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: point.photos.length,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await tripController.addStopToActiveTrip(
                        kind: point.kind == MapPointKind.poi
                            ? TripStopKind.poi
                            : TripStopKind.stay,
                        referenceId: point.id,
                      );
                      if (mounted) {
                        Navigator.of(context).pop();
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.addedToTrip(point.title))),
                        );
                      }
                    },
                    icon: const Icon(Icons.playlist_add),
                    label: Text(l10n.addToTrip),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView({
    required this.provider,
    required this.points,
    required this.onTapMarker,
  });

  final MbTilesTileProvider provider;
  final List<MapPoint> points;
  final ValueChanged<MapPoint> onTapMarker;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: MapConstants.initialCenter,
        initialZoom: 7,
        cameraConstraint:
            CameraConstraint.contain(bounds: MapConstants.sriLankaBounds),
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          tileProvider: provider,
          userAgentPackageName: 'com.guidelk.mobile',
          maxZoom: 14,
          minZoom: 6,
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            markers: [
              for (final point in points)
                Marker(
                  point: point.position,
                  width: 40,
                  height: 40,
                  builder: (context) => _MarkerChip(
                    point: point,
                    onTap: () => onTapMarker(point),
                  ),
                ),
            ],
            builder: (context, cluster) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  cluster.count.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
  }
}

class _MarkerChip extends StatelessWidget {
  const _MarkerChip({required this.point, required this.onTap});

  final MapPoint point;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = point.kind == MapPointKind.poi
        ? colorScheme.primary
        : colorScheme.secondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(
          point.kind == MapPointKind.poi
              ? Icons.location_on
              : Icons.hotel,
          color: Colors.white,
          size: 20,
        ),
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
