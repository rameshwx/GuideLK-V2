import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../repositories/partner_stay_repository.dart';
import '../repositories/poi_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/trip_repository.dart';

final poiRepositoryProvider = Provider<PoiRepository>((ref) {
  final box = Hive.box('poiCache');
  return PoiRepository(box);
});

final partnerStayRepositoryProvider = Provider<PartnerStayRepository>((ref) {
  final box = Hive.box('propertiesCache');
  return PartnerStayRepository(box);
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final box = Hive.box('tripBox');
  return TripRepository(box);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final box = Hive.box('userBox');
  return SettingsRepository(box);
});
