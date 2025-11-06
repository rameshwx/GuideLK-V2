import 'package:hive_flutter/hive_flutter.dart';

import '../core/bootstrap.dart';
import '../models/settings.dart';

class SettingsRepository {
  SettingsRepository(this._userBox);

  final Box _userBox;

  BookingImportSettings readBookingImportSettings() {
    final map = _userBox.get(HiveKeys.bookingImport) as Map<dynamic, dynamic>?;
    final enabledMap = _userBox.get(HiveKeys.featureFlags) as Map<dynamic, dynamic>?;
    final enabled = enabledMap?['bookingImportEnabled'] as bool? ?? false;
    if (map == null) {
      return BookingImportSettings(enabled: enabled);
    }
    return BookingImportSettings.fromMap(map).copyWith(enabled: enabled);
  }

  Future<void> writeBookingImportSettings(BookingImportSettings settings) async {
    await _userBox.put(HiveKeys.featureFlags, {
      'bookingImportEnabled': settings.enabled,
    });
    await _userBox.put(HiveKeys.bookingImport, settings.toMap());
  }
}
