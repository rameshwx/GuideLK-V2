import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/system_settings.dart';
import 'sample_data.dart';

final systemSettingsProvider =
    StateNotifierProvider<SystemSettingsController, SystemSettings>(
  (ref) => SystemSettingsController(buildSampleSystemSettings()),
);

class SystemSettingsController extends StateNotifier<SystemSettings> {
  SystemSettingsController(SystemSettings initial) : super(initial);

  void updateTilesUrl(String value) {
    state = state.copyWith(adminTilesUrl: value);
  }

  void updateMediaBaseUrl(String value) {
    state = state.copyWith(mediaBaseUrl: value);
  }

  void updateMaxUploadSize(int value) {
    state = state.copyWith(maxUploadSizeMb: value);
  }

  void updateAllowedExtensions(List<String> extensions) {
    state = state.copyWith(allowedExtensions: extensions);
  }
}
