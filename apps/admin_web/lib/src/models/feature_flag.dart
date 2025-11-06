import 'package:flutter/foundation.dart';

@immutable
class FeatureFlag {
  const FeatureFlag({
    required this.key,
    required this.label,
    required this.description,
    required this.enabled,
  });

  final String key;
  final String label;
  final String description;
  final bool enabled;

  FeatureFlag copyWith({bool? enabled}) {
    return FeatureFlag(
      key: key,
      label: label,
      description: description,
      enabled: enabled ?? this.enabled,
    );
  }
}
