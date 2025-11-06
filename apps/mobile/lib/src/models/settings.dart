enum BookingPortabilityScope { dma, dmaContinuous }

class BookingImportSettings {
  const BookingImportSettings({
    required this.enabled,
    this.portabilityUrl,
    this.scope = BookingPortabilityScope.dma,
  });

  final bool enabled;
  final String? portabilityUrl;
  final BookingPortabilityScope scope;

  BookingImportSettings copyWith({
    bool? enabled,
    String? portabilityUrl,
    BookingPortabilityScope? scope,
  }) {
    return BookingImportSettings(
      enabled: enabled ?? this.enabled,
      portabilityUrl: portabilityUrl ?? this.portabilityUrl,
      scope: scope ?? this.scope,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'portabilityUrl': portabilityUrl,
      'scope': scope.name,
    };
  }

  factory BookingImportSettings.fromMap(Map<dynamic, dynamic> map) {
    return BookingImportSettings(
      enabled: map['enabled'] as bool? ?? false,
      portabilityUrl: map['portabilityUrl'] as String?,
      scope: BookingPortabilityScope.values.firstWhere(
        (scope) => scope.name == map['scope'],
        orElse: () => BookingPortabilityScope.dma,
      ),
    );
  }
}
