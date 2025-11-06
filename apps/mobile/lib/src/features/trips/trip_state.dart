import 'package:collection/collection.dart';

import '../../models/trip.dart';

class TripState {
  const TripState({
    required this.trips,
    this.isLoading = false,
    this.error,
  });

  const TripState.loading() : this(trips: const [], isLoading: true);

  final List<Trip> trips;
  final bool isLoading;
  final String? error;

  Trip? get activeTrip =>
      trips.firstWhereOrNull((trip) => trip.status == TripStatus.active);

  TripState copyWith({
    List<Trip>? trips,
    bool? isLoading,
    String? error,
  }) {
    return TripState(
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
