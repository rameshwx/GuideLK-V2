import 'package:flutter/foundation.dart';

@immutable
class TranslationEntry {
  const TranslationEntry({
    required this.key,
    required this.values,
  });

  final String key;
  final Map<String, String> values;

  TranslationEntry copyWith({Map<String, String>? values}) {
    return TranslationEntry(
      key: key,
      values: values ?? this.values,
    );
  }
}
