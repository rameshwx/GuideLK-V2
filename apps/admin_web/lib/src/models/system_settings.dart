import 'package:flutter/foundation.dart';

@immutable
class SystemSettings {
  const SystemSettings({
    required this.adminTilesUrl,
    required this.mediaBaseUrl,
    required this.maxUploadSizeMb,
    required this.allowedExtensions,
  });

  final String adminTilesUrl;
  final String mediaBaseUrl;
  final int maxUploadSizeMb;
  final List<String> allowedExtensions;

  SystemSettings copyWith({
    String? adminTilesUrl,
    String? mediaBaseUrl,
    int? maxUploadSizeMb,
    List<String>? allowedExtensions,
  }) {
    return SystemSettings(
      adminTilesUrl: adminTilesUrl ?? this.adminTilesUrl,
      mediaBaseUrl: mediaBaseUrl ?? this.mediaBaseUrl,
      maxUploadSizeMb: maxUploadSizeMb ?? this.maxUploadSizeMb,
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
    );
  }
}
