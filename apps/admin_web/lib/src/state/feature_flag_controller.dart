import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/feature_flag.dart';
import 'sample_data.dart';

final featureFlagsProvider = StateNotifierProvider<FeatureFlagController, List<FeatureFlag>>(
  (ref) => FeatureFlagController(buildSampleFeatureFlags()),
);

class FeatureFlagController extends StateNotifier<List<FeatureFlag>> {
  FeatureFlagController(List<FeatureFlag> initial) : super(initial);

  void toggle(FeatureFlag flag) {
    state = [
      for (final item in state)
        if (item.key == flag.key) item.copyWith(enabled: !item.enabled) else item,
    ];
  }
}
