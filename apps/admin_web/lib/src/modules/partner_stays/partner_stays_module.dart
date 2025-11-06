import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../models/partner_stay.dart';
import '../../shared/map/map_attribution.dart';
import '../../shared/map/map_config.dart';
import '../../shared/map/tiles.dart';
import '../../shared/widgets/section_header.dart';
import '../../state/partner_stay_controller.dart';

class PartnerStaysModule extends ConsumerStatefulWidget {
  const PartnerStaysModule({super.key});

  @override
  ConsumerState<PartnerStaysModule> createState() => _PartnerStaysModuleState();
}

class _PartnerStaysModuleState extends ConsumerState<PartnerStaysModule> {
  @override
  Widget build(BuildContext context) {
    final stays = ref.watch(partnerStaysProvider);
    final selectedId = ref.watch(selectedPartnerStayIdProvider);
    final selected = stays.firstWhere(
      (stay) => stay.id == selectedId,
      orElse: () => stays.isNotEmpty ? stays.first : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Partner stays',
          subtitle: 'Onboard, curate, and publish accommodation partners.',
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Partner import pipeline coming soon.')),
                );
              },
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Import roster'),
            ),
            FilledButton.icon(
              onPressed: () => _openStayDialog(context),
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('Add stay'),
            ),
          ],
        ),
        ConstrainedBox(
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
                        Text('Published: ${stays.where((s) => s.isPublished).length} of ${stays.length}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stays.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final stay = stays[index];
                            final isSelected = selected?.id == stay.id;
                            return ListTile(
                              selected: isSelected,
                              title: Text(stay.name),
                              subtitle: Text(stay.address),
                              leading: Icon(
                                stay.isPublished
                                    ? Icons.verified_user_outlined
                                    : Icons.visibility_off_outlined,
                                color:
                                    stay.isPublished ? Colors.blue.shade600 : Colors.grey.shade500,
                              ),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit stay',
                                    onPressed: () => _openStayDialog(context, existing: stay),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete stay',
                                    onPressed: () => _confirmDeletion(context, stay),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                              onTap: () {
                                ref.read(selectedPartnerStayIdProvider.notifier).state = stay.id;
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
                child: _PartnerStayMap(
                  stays: stays,
                  selectedId: selected?.id,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openStayDialog(BuildContext context, {PartnerStay? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final addressController = TextEditingController(text: existing?.address ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final websiteController = TextEditingController(text: existing?.website ?? '');
    final latController = TextEditingController(text: existing?.latitude.toString() ?? '');
    final lonController = TextEditingController(text: existing?.longitude.toString() ?? '');
    var published = existing?.isPublished ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'New partner stay' : 'Edit partner stay'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Property name'),
                      validator: (value) => value == null || value.isEmpty ? 'Name required' : null,
                    ),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(labelText: 'Phone'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: websiteController,
                            decoration: const InputDecoration(labelText: 'Website'),
                          ),
                        ),
                      ],
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
                                return 'Latitude required';
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
                                return 'Longitude required';
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
                  final notifier = ref.read(partnerStaysProvider.notifier);
                  final lat = double.parse(latController.text);
                  final lon = double.parse(lonController.text);
                  if (existing == null) {
                    notifier.createStay(
                      name: nameController.text.trim(),
                      address: addressController.text.trim(),
                      phone: phoneController.text.trim(),
                      website: websiteController.text.trim(),
                      latitude: lat,
                      longitude: lon,
                      isPublished: published,
                    );
                  } else {
                    notifier.updateStay(
                      existing.copyWith(
                        name: nameController.text.trim(),
                        address: addressController.text.trim(),
                        phone: phoneController.text.trim(),
                        website: websiteController.text.trim(),
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
        SnackBar(content: Text(existing == null ? 'Stay created' : 'Stay updated')),
      );
    }
  }

  Future<void> _confirmDeletion(BuildContext context, PartnerStay stay) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete stay'),
          content: Text('Delete ${stay.name}? This will remove it from partner listings.'),
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
      ref.read(partnerStaysProvider.notifier).deleteStay(stay.id);
      ref.read(selectedPartnerStayIdProvider.notifier).state = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${stay.name} deleted')),
      );
    }
  }
}

class _PartnerStayMap extends ConsumerWidget {
  const _PartnerStayMap({required this.stays, this.selectedId});

  final List<PartnerStay> stays;
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
            initialZoom: 6.6,
            cameraConstraint: CameraConstraint.contain(bounds: paddedSriLankaBounds(sriLankaBoundsPadding)),
          ),
          children: [
            buildAdminTileLayer(),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                markers: [
                  for (final stay in stays)
                    Marker(
                      point: LatLng(stay.latitude, stay.longitude),
                      width: 48,
                      height: 48,
                      builder: (context) => _StayMarker(
                        stay: stay,
                        selected: stay.id == selectedId,
                        onTap: () =>
                            ref.read(selectedPartnerStayIdProvider.notifier).state = stay.id,
                      ),
                    ),
                ],
                builder: (context, markers) {
                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
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

class _StayMarker extends StatelessWidget {
  const _StayMarker({required this.stay, required this.selected, required this.onTap});

  final PartnerStay stay;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: stay.name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: selected ? 1.2 : 1,
          child: Icon(
            Icons.hotel_outlined,
            color: selected ? Theme.of(context).colorScheme.secondary : Colors.deepPurple,
            size: selected ? 34 : 28,
          ),
        ),
      ),
    );
  }
}
