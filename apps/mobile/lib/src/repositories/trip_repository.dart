import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/bootstrap.dart';
import '../models/trip.dart';

class TripRepository {
  TripRepository(this._box);

  final Box _box;
  final _uuid = const Uuid();

  Future<List<Trip>> fetchTrips() async {
    final raw = _box.get(HiveKeys.trips, defaultValue: []) as List<dynamic>;
    return raw
        .map((dynamic item) => Trip.fromMap(item as Map<dynamic, dynamic>))
        .toList();
  }

  Future<void> saveTrips(List<Trip> trips) async {
    await _box.put(
      HiveKeys.trips,
      trips.map((trip) => trip.toMap()).toList(growable: false),
    );
  }

  TripStop createStop({
    required TripStopKind kind,
    required String referenceId,
    required int sortOrder,
    int dayIndex = 0,
  }) {
    return TripStop(
      id: _uuid.v4(),
      kind: kind,
      referenceId: referenceId,
      sortOrder: sortOrder,
      dayIndex: dayIndex,
    );
  }

  Trip createTrip({
    String? name,
    TripStatus status = TripStatus.draft,
    DateTime? startDate,
    DateTime? endDate,
    List<TripStop> stops = const [],
  }) {
    return Trip(
      id: _uuid.v4(),
      name: name ?? 'Custom Trip',
      status: status,
      startDate: startDate,
      endDate: endDate,
      stops: List<TripStop>.from(stops),
    );
  }
}
