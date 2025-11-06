import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../models/poi.dart';
import '../../shared/map/map_attribution.dart';
import '../../shared/map/map_config.dart';
import '../../shared/map/tiles.dart';
import '../../shared/widgets/section_header.dart';
import '../../state/poi_controller.dart';

class PoisModule extends ConsumerStatefulWidget {
  const PoisModule({super.key});

  @override
  ConsumerState<PoisModule> createState() => _PoisModuleState();
}

class _PoisModuleState extends ConsumerState<PoisModule> {
  @override
  Widget build(BuildContext context) {
    final pois = ref.watch(poiProvider);
    final selectedId = ref.watch(selectedPoiIdProvider);

    final selectedPoi = pois.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => pois.isNotEmpty ? pois.first : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Attractions',
          subtitle: 'Create, localise, and publish curated points of interest.',
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bulk import coming soon — upload CSV or GeoJSON.'),
                  ),
                );
              },
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Bulk import'),
            ),
            FilledButton.icon(
              onPressed: () => _openPoiDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add attraction'),
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 520),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Manage ${pois.length} attractions',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: pois.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final poi = pois[index];
                                final isSelected = selectedPoi?.id == poi.id;
                                return ListTile(
                                  selected: isSelected,
                                  title: Text(poi.name),
                                  subtitle: Text('${poi.category} • ${poi.latitude.toStringAsFixed(3)}, '
                                      '${poi.longitude.toStringAsFixed(3)}'),
                                  trailing: Wrap(
                                    spacing: 8,
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit attraction',
                                        onPressed: () => _openPoiDialog(context, existing: poi),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete attraction',
                                        onPressed: () => _confirmDeletion(context, poi),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                  leading: Icon(
                                    poi.isPublished ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: poi.isPublished
                                        ? Colors.green.shade600
                                        : Colors.grey.shade500,
                                  ),
                                  onTap: () {
                                    ref.read(selectedPoiIdProvider.notifier).state = poi.id;
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _PoiMap(
                      pois: pois,
                      selectedId: selectedPoi?.id,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _openPoiDialog(BuildContext context, {Poi? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final categoryController = TextEditingController(text: existing?.category ?? '');
    final descriptionController = TextEditingController(text: existing?.description ?? '');
    final latController = TextEditingController(text: existing?.latitude.toString() ?? '');
    final lonController = TextEditingController(text: existing?.longitude.toString() ?? '');
    var published = existing?.isPublished ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'New attraction' : 'Edit attraction'),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                    ),
                    TextFormField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: latController,
                            decoration: const InputDecoration(labelText: 'Latitude'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final parsed = double.tryParse(value ?? '');
                              if (parsed == null) {
                                return 'Enter a latitude';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: lonController,
                            decoration: const InputDecoration(labelText: 'Longitude'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final parsed = double.tryParse(value ?? '');
                              if (parsed == null) {
                                return 'Enter a longitude';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile.adaptive(
                      value: published,
                      onChanged: (value) {
                        setState(() {
                          published = value;
                        });
                      },
                      title: const Text('Published'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final notifier = ref.read(poiProvider.notifier);
                  final lat = double.parse(latController.text);
                  final lon = double.parse(lonController.text);
                  if (existing == null) {
                    notifier.createPoi(
                      name: nameController.text.trim(),
                      category: categoryController.text.trim(),
                      description: descriptionController.text.trim(),
                      latitude: lat,
                      longitude: lon,
                      isPublished: published,
                    );
                  } else {
                    notifier.updatePoi(
                      existing.copyWith(
                        name: nameController.text.trim(),
                        category: categoryController.text.trim(),
                        description: descriptionController.text.trim(),
                        latitude: lat,
                        longitude: lon,
                        isPublished: published,
                      ),
                    );
                  }
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(existing == null ? 'Attraction created' : 'Attraction updated')),
      );
    }
  }

  Future<void> _confirmDeletion(BuildContext context, Poi poi) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete attraction'),
          content: Text('Are you sure you want to delete ${poi.name}? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      ref.read(poiProvider.notifier).deletePoi(poi.id);
      ref.read(selectedPoiIdProvider.notifier).state = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${poi.name} deleted')),
      );
    }
  }
}

class _PoiMap extends ConsumerWidget {
  const _PoiMap({required this.pois, this.selectedId});

  final List<Poi> pois;
  final int? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 520,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: sriLankaCenter,
            initialZoom: 6.8,
            cameraConstraint: CameraConstraint.contain(bounds: paddedSriLankaBounds(sriLankaBoundsPadding)),
          ),
          children: [
            buildAdminTileLayer(),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                markers: [
                  for (final poi in pois)
                    Marker(
                      point: LatLng(poi.latitude, poi.longitude),
                      width: 48,
                      height: 48,
                      builder: (context) => _PoiMarker(
                        poi: poi,
                        selected: poi.id == selectedId,
                        onTap: () =>
                            ref.read(selectedPoiIdProvider.notifier).state = poi.id,
                      ),
                    ),
                ],
                builder: (context, markers) {
                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text('${markers.length}', style: const TextStyle(color: Colors.white)),
                  );
                },
              ),
            ),
            const MapAttribution(),
          ],
        ),
      ),
    );
  }
}

class _PoiMarker extends StatelessWidget {
  const _PoiMarker({required this.poi, required this.selected, required this.onTap});

  final Poi poi;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: poi.name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: selected ? 1.2 : 1,
          child: Icon(
            Icons.place,
            color: selected ? Theme.of(context).colorScheme.primary : Colors.redAccent,
            size: selected ? 36 : 30,
          ),
        ),
      ),
    );
  }
}
