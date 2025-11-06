import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/partner_stay.dart';
import 'sample_data.dart';

final partnerStaysProvider = StateNotifierProvider<PartnerStayController, List<PartnerStay>>(
  (ref) => PartnerStayController(buildSamplePartnerStays()),
);

final selectedPartnerStayIdProvider = StateProvider<int?>((ref) => null);

class PartnerStayController extends StateNotifier<List<PartnerStay>> {
  PartnerStayController(List<PartnerStay> initial) : super(initial) {
    if (initial.isNotEmpty) {
      _nextId = initial.map((e) => e.id).reduce(max) + 1;
    }
  }

  int _nextId = 1;

  void createStay({
    required String name,
    required String address,
    required String phone,
    required String website,
    required double latitude,
    required double longitude,
    bool isPublished = false,
  }) {
    final stay = PartnerStay(
      id: _nextId++,
      name: name,
      address: address,
      phone: phone,
      website: website,
      latitude: latitude,
      longitude: longitude,
      isPublished: isPublished,
    );
    state = [...state, stay];
  }

  void updateStay(PartnerStay updated) {
    state = [
      for (final stay in state)
        if (stay.id == updated.id) updated else stay,
    ];
  }

  void deleteStay(int id) {
    state = [for (final stay in state) if (stay.id != id) stay];
  }
}
