import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/partner_stay.dart';
import '../../models/poi.dart';
import '../../models/trip.dart';
import '../../providers/data_providers.dart';
import 'trip_controller.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tripState = ref.watch(tripControllerProvider);
    final poisAsync = ref.watch(poisProvider);
    final staysAsync = ref.watch(partnerStaysProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTripDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.createTripCta),
      ),
      body: tripState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : poisAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(error.toString())),
              data: (pois) => staysAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text(error.toString())),
                data: (stays) => _TripList(
                  trips: tripState.trips,
                  pois: {for (final poi in pois) poi.id: poi},
                  stays: {for (final stay in stays) stay.id: stay},
                ),
              ),
            ),
    );
  }

  Future<void> _showCreateTripDialog(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.newTripDialogTitle),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.tripNameLabel),
                  validator: (value) =>
                      value == null || value.isEmpty ? l10n.requiredField : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 2),
                            ),
                          );
                          if (picked != null) {
                            startDate = picked.start;
                            endDate = picked.end;
                          }
                        },
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(l10n.pickDatesCta),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancelCta),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(l10n.createCta),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await ref.read(tripControllerProvider.notifier).createTrip(
            name: nameController.text,
            startDate: startDate,
            endDate: endDate,
            setActive: true,
          );
    }
  }
}

class _TripList extends ConsumerWidget {
  const _TripList({
    required this.trips,
    required this.pois,
    required this.stays,
  });

  final List<Trip> trips;
  final Map<String, Poi> pois;
  final Map<String, PartnerStay> stays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(tripControllerProvider.notifier);
    final l10n = context.l10n;

    if (trips.isEmpty) {
      return Center(child: Text(l10n.noTripsYet));
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trip.formattedDateRange,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(label: Text(_statusLabel(trip.status, l10n))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (trip.status != TripStatus.active)
                        OutlinedButton.icon(
                          onPressed: () => controller.setActiveTrip(trip.id),
                          icon: const Icon(Icons.flag_outlined),
                          label: Text(l10n.setActiveCta),
                        ),
                      if (trip.status != TripStatus.archived)
                        OutlinedButton.icon(
                          onPressed: () => controller.archiveTrip(trip.id),
                          icon: const Icon(Icons.archive_outlined),
                          label: Text(l10n.archiveCta),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => controller.deleteTrip(trip.id),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.deleteCta),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (trip.stops.isEmpty)
                    Text(l10n.noStopsMessage)
                  else
                    ReorderableListView.builder(
                      key: ValueKey('stops-${trip.id}'),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: trip.stops.length,
                      onReorder: (oldIndex, newIndex) =>
                          controller.reorderStops(trip.id, oldIndex, newIndex),
                      itemBuilder: (context, stopIndex) {
                        final stop = trip.stops[stopIndex];
                        final title = stop.kind == TripStopKind.poi
                            ? pois[stop.referenceId]?.name ?? l10n.unknownPoi
                            : stays[stop.referenceId]?.name ?? l10n.unknownStay;
                        final subtitle = stop.kind == TripStopKind.poi
                            ? pois[stop.referenceId]?.category ?? ''
                            : stays[stop.referenceId]?.address ?? '';
                        return ListTile(
                          key: ValueKey(stop.id),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: Icon(
                            stop.kind == TripStopKind.poi
                                ? Icons.location_on_outlined
                                : Icons.hotel_outlined,
                          ),
                          title: Text(title),
                          subtitle: Text(subtitle),
                          trailing: DropdownButton<TripStopStatus>(
                            value: stop.status,
                            onChanged: (value) {
                              if (value != null) {
                                controller.updateStopStatus(
                                  trip.id,
                                  stop.id,
                                  value,
                                );
                              }
                            },
                            items: TripStopStatus.values
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(_stopStatusLabel(status, l10n)),
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(TripStatus status, AppLocalizations l10n) {
    switch (status) {
      case TripStatus.draft:
        return l10n.tripStatusDraft;
      case TripStatus.active:
        return l10n.tripStatusActive;
      case TripStatus.archived:
        return l10n.tripStatusArchived;
    }
  }

  String _stopStatusLabel(TripStopStatus status, AppLocalizations l10n) {
    switch (status) {
      case TripStopStatus.planned:
        return l10n.stopStatusPlanned;
      case TripStopStatus.visited:
        return l10n.stopStatusVisited;
      case TripStopStatus.skipped:
        return l10n.stopStatusSkipped;
    }
  }
}
