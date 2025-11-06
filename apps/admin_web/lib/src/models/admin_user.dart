import 'package:flutter/foundation.dart';

@immutable
class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.locale,
    required this.active,
    required this.createdAt,
  });

  final int id;
  final String email;
  final String displayName;
  final String locale;
  final bool active;
  final DateTime createdAt;

  AdminUser copyWith({
    String? email,
    String? displayName,
    String? locale,
    bool? active,
  }) {
    return AdminUser(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      locale: locale ?? this.locale,
      active: active ?? this.active,
      createdAt: createdAt,
    );
  }
}
