import 'package:flutter/foundation.dart';

@immutable
class PartnerStay {
  const PartnerStay({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.website,
    required this.latitude,
    required this.longitude,
    required this.isPublished,
  });

  final int id;
  final String name;
  final String address;
  final String phone;
  final String website;
  final double latitude;
  final double longitude;
  final bool isPublished;

  PartnerStay copyWith({
    String? name,
    String? address,
    String? phone,
    String? website,
    double? latitude,
    double? longitude,
    bool? isPublished,
  }) {
    return PartnerStay(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
