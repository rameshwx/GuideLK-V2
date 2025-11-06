import 'package:uuid/uuid.dart';

import '../models/partner_stay.dart';
import '../models/poi.dart';
import '../models/trip.dart';

const _uuid = Uuid();

final samplePois = <Poi>[
  Poi(
    id: 'sigiriya-rock',
    name: 'Sigiriya Rock Fortress',
    category: 'Cultural',
    description:
        'Ancient rock fortress with frescoes and landscaped gardens in the heart of Sri Lanka.',
    latitude: 7.9569,
    longitude: 80.7603,
    phone: '+94 66 228 6000',
    website: 'https://whc.unesco.org/en/list/202/',
    photos: const [
      'https://images.guidelk.app/sigiriya-1.jpg',
      'https://images.guidelk.app/sigiriya-2.jpg',
    ],
  ),
  Poi(
    id: 'galle-fort',
    name: 'Galle Fort',
    category: 'Historic',
    description:
        'Dutch colonial-era fort overlooking the Indian Ocean with quaint streets and boutiques.',
    latitude: 6.0260,
    longitude: 80.2170,
    photos: const ['https://images.guidelk.app/galle-fort.jpg'],
  ),
  Poi(
    id: 'ella-nine-arch',
    name: 'Nine Arch Bridge',
    category: 'Scenic',
    description:
        'Iconic stone bridge surrounded by lush tea fields and misty mountain vistas.',
    latitude: 6.8902,
    longitude: 81.0592,
    photos: const ['https://images.guidelk.app/nine-arch.jpg'],
  ),
];

final samplePartnerStays = <PartnerStay>[
  PartnerStay(
    id: 'colombo-retreat',
    name: 'Colombo Retreat Hotel',
    address: '45 Galle Road, Colombo 03',
    latitude: 6.9105,
    longitude: 79.8497,
    phone: '+94 11 234 5678',
    website: 'https://stay.guidelk.app/colombo-retreat',
    photos: const ['https://images.guidelk.app/colombo-retreat.jpg'],
  ),
  PartnerStay(
    id: 'kandy-lakehouse',
    name: 'Kandy Lakehouse',
    address: '12 Upper Lake Road, Kandy',
    latitude: 7.2936,
    longitude: 80.6413,
    phone: '+94 81 223 4455',
    website: 'https://stay.guidelk.app/kandy-lakehouse',
  ),
];

final sampleTrips = <Trip>[
  Trip(
    id: 'heritage-loop',
    name: 'Cultural Heritage Loop',
    status: TripStatus.active,
    startDate: DateTime.now().add(const Duration(days: 7)),
    endDate: DateTime.now().add(const Duration(days: 12)),
    stops: [
      TripStop(
        id: _uuid.v4(),
        kind: TripStopKind.poi,
        referenceId: 'sigiriya-rock',
        sortOrder: 0,
        dayIndex: 0,
      ),
      TripStop(
        id: _uuid.v4(),
        kind: TripStopKind.poi,
        referenceId: 'galle-fort',
        sortOrder: 1,
        dayIndex: 1,
      ),
      TripStop(
        id: _uuid.v4(),
        kind: TripStopKind.stay,
        referenceId: 'kandy-lakehouse',
        sortOrder: 2,
        dayIndex: 1,
        isBooked: true,
        checkIn: DateTime.now().add(const Duration(days: 8)),
        checkOut: DateTime.now().add(const Duration(days: 10)),
      ),
    ],
  ),
  Trip(
    id: 'southern-charm',
    name: 'Southern Charm Explorer',
    status: TripStatus.draft,
    stops: [
      TripStop(
        id: _uuid.v4(),
        kind: TripStopKind.stay,
        referenceId: 'colombo-retreat',
        sortOrder: 0,
        dayIndex: 0,
      ),
      TripStop(
        id: _uuid.v4(),
        kind: TripStopKind.poi,
        referenceId: 'galle-fort',
        sortOrder: 1,
        dayIndex: 1,
      ),
    ],
  ),
];
