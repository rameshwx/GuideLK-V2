class PartnerStay {
  PartnerStay({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    this.photos = const [],
    this.isPublished = true,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final List<String> photos;
  final bool isPublished;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
      'photos': photos,
      'isPublished': isPublished,
    };
  }

  factory PartnerStay.fromMap(Map<dynamic, dynamic> map) {
    return PartnerStay(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      phone: map['phone'] as String?,
      website: map['website'] as String?,
      photos: (map['photos'] as List<dynamic>? ?? [])
          .map((dynamic e) => e as String)
          .toList(),
      isPublished: map['isPublished'] as bool? ?? true,
    );
  }
}
