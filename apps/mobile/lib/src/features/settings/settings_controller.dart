import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/settings.dart';
import '../../providers/repositories.dart';
import '../../repositories/settings_repository.dart';

final bookingSettingsProvider =
    StateNotifierProvider<BookingSettingsController, BookingImportSettings>(
  (ref) {
    final repository = ref.watch(settingsRepositoryProvider);
    return BookingSettingsController(repository);
  },
);

class BookingSettingsController
    extends StateNotifier<BookingImportSettings> {
  BookingSettingsController(this._repository)
      : super(_repository.readBookingImportSettings());

  final SettingsRepository _repository;

  Future<void> update({
    bool? enabled,
    String? portabilityUrl,
    BookingPortabilityScope? scope,
  }) async {
    state = state.copyWith(
      enabled: enabled ?? state.enabled,
      portabilityUrl: portabilityUrl ?? state.portabilityUrl,
      scope: scope ?? state.scope,
    );
    await _repository.writeBookingImportSettings(state);
  }
}
