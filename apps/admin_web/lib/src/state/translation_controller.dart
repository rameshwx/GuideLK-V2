import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/translation_entry.dart';
import 'sample_data.dart';

final translationsProvider = StateNotifierProvider<TranslationController, List<TranslationEntry>>(
  (ref) => TranslationController(buildSampleTranslations()),
);

class TranslationController extends StateNotifier<List<TranslationEntry>> {
  TranslationController(List<TranslationEntry> initial) : super(initial);

  void upsertEntry(TranslationEntry entry) {
    final exists = state.any((element) => element.key == entry.key);
    if (exists) {
      state = [
        for (final item in state)
          if (item.key == entry.key) entry else item,
      ];
    } else {
      state = [...state, entry];
    }
  }
}
