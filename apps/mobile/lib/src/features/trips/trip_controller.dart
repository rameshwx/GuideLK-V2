import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/trip.dart';
import '../../providers/repositories.dart';
import '../../repositories/trip_repository.dart';
import 'trip_state.dart';

final tripControllerProvider =
    StateNotifierProvider<TripController, TripState>((ref) {
  return TripController(ref)..loadTrips();
});

class TripController extends StateNotifier<TripState> {
  TripController(this._ref) : super(const TripState.loading());

  final Ref _ref;
  bool _initialised = false;

  TripRepository get _repository => _ref.read(tripRepositoryProvider);

  Future<void> loadTrips() async {
    if (_initialised) {
      return;
    }
    _initialised = true;
    await refresh();
  }

  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final trips = await _repository.fetchTrips();
      state = TripState(trips: trips);
    } catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> setActiveTrip(String tripId) async {
    final trips = state.trips.map((trip) {
      if (trip.id == tripId) {
        return trip.copyWith(status: TripStatus.active);
      }
      if (trip.status == TripStatus.active) {
        return trip.copyWith(status: TripStatus.draft);
      }
      return trip;
    }).toList();
    await _persist(trips);
  }

  Future<void> archiveTrip(String tripId) async {
    final trips = state.trips.map((trip) {
      if (trip.id == tripId) {
        return trip.copyWith(status: TripStatus.archived);
      }
      return trip;
    }).toList();
    await _persist(trips);
  }

  Future<void> addStopToActiveTrip({
    required TripStopKind kind,
    required String referenceId,
  }) async {
    final trips = [...state.trips];
    var activeTrip = trips.firstWhereOrNull(
      (trip) => trip.status == TripStatus.active,
    );
    if (activeTrip == null) {
      activeTrip = _repository.createTrip(
        name: 'New Trip',
        status: TripStatus.active,
      );
      trips.add(activeTrip);
    }

    final sortOrder = activeTrip.stops.length;
    final stop = _repository.createStop(
      kind: kind,
      referenceId: referenceId,
      sortOrder: sortOrder,
      dayIndex: activeTrip.stops.isEmpty
          ? 0
          : activeTrip.stops.last.dayIndex + (kind == TripStopKind.stay ? 0 : 1),
    );

    final updatedStops = [...activeTrip.stops, stop];
    final updatedTrip = activeTrip.copyWith(stops: updatedStops);
    final index = trips.indexWhere((trip) => trip.id == activeTrip!.id);
    trips[index] = updatedTrip;

    await _persist(trips);
  }

  Future<void> updateStopStatus(
    String tripId,
    String stopId,
    TripStopStatus status,
  ) async {
    final trips = state.trips.map((trip) {
      if (trip.id != tripId) return trip;
      final updatedStops = trip.stops.map((stop) {
        if (stop.id != stopId) return stop;
        return stop.copyWith(status: status);
      }).toList();
      return trip.copyWith(stops: updatedStops);
    }).toList();
    await _persist(trips);
  }

  Future<void> reorderStops(String tripId, int oldIndex, int newIndex) async {
    final trips = state.trips.map((trip) {
      if (trip.id != tripId) return trip;
      final stops = [...trip.stops];
      final item = stops.removeAt(oldIndex);
      stops.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
      final reindexed = <TripStop>[];
      for (var i = 0; i < stops.length; i++) {
        reindexed.add(stops[i].copyWith(sortOrder: i));
      }
      return trip.copyWith(stops: reindexed);
    }).toList();
    await _persist(trips);
  }

  Future<void> markStayBooked(
    String tripId,
    String stopId,
    bool isBooked,
  ) async {
    final trips = state.trips.map((trip) {
      if (trip.id != tripId) return trip;
      final updatedStops = trip.stops.map((stop) {
        if (stop.id != stopId) return stop;
        return stop.copyWith(
          isBooked: isBooked,
          checkIn: isBooked ? (stop.checkIn ?? DateTime.now()) : null,
          checkOut: isBooked ? (stop.checkOut ?? DateTime.now()) : null,
        );
      }).toList();
      return trip.copyWith(stops: updatedStops);
    }).toList();
    await _persist(trips);
  }

  Future<void> updateStayDates(
    String tripId,
    String stopId,
    DateTime? checkIn,
    DateTime? checkOut,
  ) async {
    final trips = state.trips.map((trip) {
      if (trip.id != tripId) return trip;
      final updatedStops = trip.stops.map((stop) {
        if (stop.id != stopId) return stop;
        return stop.copyWith(checkIn: checkIn, checkOut: checkOut);
      }).toList();
      return trip.copyWith(stops: updatedStops);
    }).toList();
    await _persist(trips);
  }

  Future<void> createTrip({
    required String name,
    DateTime? startDate,
    DateTime? endDate,
    bool setActive = false,
  }) async {
    final trips = [...state.trips];
    final newTrip = _repository.createTrip(
      name: name,
      status: setActive ? TripStatus.active : TripStatus.draft,
      startDate: startDate,
      endDate: endDate,
    );

    final updatedTrips = trips.map((trip) {
      if (!setActive || trip.status != TripStatus.active) {
        return trip;
      }
      return trip.copyWith(status: TripStatus.draft);
    }).toList();

    updatedTrips.add(newTrip);
    await _persist(updatedTrips);
  }

  Future<void> deleteTrip(String tripId) async {
    final trips = state.trips.where((trip) => trip.id != tripId).toList();
    await _persist(trips);
  }

  Future<void> _persist(List<Trip> trips) async {
    state = state.copyWith(trips: trips);
    await _repository.saveTrips(trips);
  }
}
