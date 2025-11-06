import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/partner_stay.dart';
import '../models/poi.dart';
import '../repositories/partner_stay_repository.dart';
import '../repositories/poi_repository.dart';
import 'repositories.dart';

final poisProvider = FutureProvider<List<Poi>>((ref) async {
  final repository = ref.watch(poiRepositoryProvider);
  return repository.fetchPois();
});

final partnerStaysProvider = FutureProvider<List<PartnerStay>>((ref) async {
  final repository = ref.watch(partnerStayRepositoryProvider);
  return repository.fetchPartnerStays();
});
