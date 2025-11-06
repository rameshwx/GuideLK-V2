import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/poi.dart';
import 'sample_data.dart';

final poiProvider =
    StateNotifierProvider<PoiController, List<Poi>>((ref) => PoiController(buildSamplePois()));

final selectedPoiIdProvider = StateProvider<int?>((ref) => null);

class PoiController extends StateNotifier<List<Poi>> {
  PoiController(List<Poi> initial) : super(initial) {
    if (initial.isNotEmpty) {
      _nextId = initial.map((e) => e.id).reduce(max) + 1;
    }
  }

  int _nextId = 1;

  void createPoi({
    required String name,
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    bool isPublished = false,
  }) {
    final poi = Poi(
      id: _nextId++,
      name: name,
      category: category,
      description: description,
      latitude: latitude,
      longitude: longitude,
      isPublished: isPublished,
    );
    state = [...state, poi];
  }

  void updatePoi(Poi updated) {
    state = [
      for (final poi in state)
        if (poi.id == updated.id) updated else poi,
    ];
  }

  void deletePoi(int id) {
    state = [for (final poi in state) if (poi.id != id) poi];
  }
}
