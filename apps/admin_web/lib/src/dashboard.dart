import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const sriLankaBounds = LatLngBounds(
  LatLng(5.76, 79.54),
  LatLng(9.98, 82.05),
);

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final tilesUrl = const String.fromEnvironment(
      'ADMIN_TILES_URL',
      defaultValue:
          'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=YOUR_KEY',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('GuideLK Admin'),
        centerTitle: false,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _ModuleCard(title: 'Users', description: 'Search, deactivate or reactivate users'),
                _ModuleCard(title: 'Attractions', description: 'Manage POIs and categories'),
                _ModuleCard(title: 'Partner stays', description: 'Onboard and curate partner properties'),
                _ModuleCard(title: 'Translations', description: 'Manage localized strings'),
                _ModuleCard(title: 'System', description: 'Feature flags and configuration'),
                _ModuleCard(title: 'News (stub)', description: 'Placeholder module for alerts feed'),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(7.873054, 80.771797),
                initialZoom: 6.5,
                cameraConstraint: CameraConstraint.contain(bounds: sriLankaBounds),
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate: tilesUrl,
                  userAgentPackageName: 'com.guidelk.admin',
                  tileProvider: NetworkTileProvider(),
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
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          '© OpenStreetMap contributors · Tiles by provider',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
