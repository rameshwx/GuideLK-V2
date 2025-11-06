import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import '../../models/trip.dart';
import '../../providers/data_providers.dart';
import '../trips/trip_controller.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tripState = ref.watch(tripControllerProvider);
    final staysAsync = ref.watch(partnerStaysProvider);

    return staysAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (stays) {
        final stayMap = {for (final stay in stays) stay.id: stay};
        final activeTrip = tripState.activeTrip;
        if (activeTrip == null) {
          return Center(child: Text(l10n.noActiveTrip));
        }
        final stayStops = activeTrip.stops
            .where((stop) => stop.kind == TripStopKind.stay)
            .toList();
        if (stayStops.isEmpty) {
          return Center(child: Text(l10n.noStayStops));
        }
        final controller = ref.read(tripControllerProvider.notifier);
        final formatter = DateFormat.yMMMd();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stayStops.length,
          itemBuilder: (context, index) {
            final stop = stayStops[index];
            final stay = stayMap[stop.referenceId];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stay?.name ?? l10n.unknownStay,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (stay?.address != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(stay!.address),
                      ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.markAsBooked),
                      value: stop.isBooked,
                      onChanged: (value) => controller.markStayBooked(
                        activeTrip.id,
                        stop.id,
                        value,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _BookingDateTile(
                            label: l10n.checkInLabel,
                            date: stop.checkIn,
                            formatter: formatter,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BookingDateTile(
                            label: l10n.checkOutLabel,
                            date: stop.checkOut,
                            formatter: formatter,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: stop.isBooked
                            ? () async {
                                final range = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 365),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 2),
                                  ),
                                  initialDateRange: stop.checkIn != null
                                      ? DateTimeRange(
                                          start: stop.checkIn!,
                                          end: stop.checkOut ??
                                              stop.checkIn!.add(
                                                const Duration(days: 1),
                                              ),
                                        )
                                      : null,
                                );
                                if (range != null) {
                                  await controller.updateStayDates(
                                    activeTrip.id,
                                    stop.id,
                                    range.start,
                                    range.end,
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(l10n.updateStayDates),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BookingDateTile extends StatelessWidget {
  const _BookingDateTile({
    required this.label,
    required this.date,
    required this.formatter,
  });

  final String label;
  final DateTime? date;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            date != null ? formatter.format(date!) : '—',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
