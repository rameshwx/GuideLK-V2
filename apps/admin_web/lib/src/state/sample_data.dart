import 'package:intl/intl.dart';

import '../models/admin_user.dart';
import '../models/feature_flag.dart';
import '../models/partner_stay.dart';
import '../models/poi.dart';
import '../models/system_settings.dart';
import '../models/translation_entry.dart';

final _lorem = 'Curated by the GuideLK editorial team to highlight the best of Sri Lanka.';

List<AdminUser> buildSampleUsers() {
  final now = DateTime.now();
  return List.generate(8, (index) {
    final created = now.subtract(Duration(days: 14 + index * 11));
    return AdminUser(
      id: index + 1,
      email: 'user${index + 1}@example.com',
      displayName: 'GuideLK User ${index + 1}',
      locale: index % 2 == 0 ? 'en' : 'ta',
      active: index % 5 != 0,
      createdAt: created,
    );
  });
}

List<Poi> buildSamplePois() {
  return const [
    Poi(
      id: 1,
      name: 'Sigiriya Rock Fortress',
      category: 'UNESCO Heritage',
      description: _lorem,
      latitude: 7.9570,
      longitude: 80.7603,
      isPublished: true,
    ),
    Poi(
      id: 2,
      name: 'Nine Arches Bridge',
      category: 'Railway',
      description: _lorem,
      latitude: 6.8761,
      longitude: 81.0592,
      isPublished: true,
    ),
    Poi(
      id: 3,
      name: 'Galle Fort',
      category: 'History',
      description: _lorem,
      latitude: 6.0260,
      longitude: 80.2170,
      isPublished: false,
    ),
  ];
}

List<PartnerStay> buildSamplePartnerStays() {
  return const [
    PartnerStay(
      id: 1,
      name: 'Kandy Heritage Villas',
      address: '15 Temple Road, Kandy',
      phone: '+94 81 222 1000',
      website: 'https://kandyheritage.lk',
      latitude: 7.2906,
      longitude: 80.6337,
      isPublished: true,
    ),
    PartnerStay(
      id: 2,
      name: 'Ella Hideout',
      address: 'Ella Gap Road, Ella',
      phone: '+94 57 222 3355',
      website: 'https://ellahideout.lk',
      latitude: 6.8667,
      longitude: 81.0460,
      isPublished: true,
    ),
    PartnerStay(
      id: 3,
      name: 'Colombo Seaview Suites',
      address: '43 Marine Drive, Colombo',
      phone: '+94 11 433 9870',
      website: 'https://seaviewsuites.lk',
      latitude: 6.9051,
      longitude: 79.8568,
      isPublished: false,
    ),
  ];
}

List<TranslationEntry> buildSampleTranslations() {
  final keys = {
    'home.title': {
      'en': 'Plan your Sri Lanka adventure',
      'ta': 'இலங்கை சாகசத்தைக் திட்டமிடுங்கள்',
      'zh': '规划斯里兰卡之旅',
      'ru': 'Планируйте путешествие по Шри-Ланке',
      'hi': 'अपनी श्रीलंका यात्रा की योजना बनाएं',
      'pl': 'Zaplanuj podróż po Sri Lance',
    },
    'trips.empty': {
      'en': 'Create your first route to begin',
      'ta': 'தொடங்க உங்கள் முதல் பாதையை உருவாக்கவும்',
      'zh': '创建第一条行程以开始',
      'ru': 'Создайте свой первый маршрут, чтобы начать',
      'hi': 'शुरू करने के लिए अपना पहला मार्ग बनाएं',
      'pl': 'Utwórz swoją pierwszą trasę, aby rozpocząć',
    },
    'settings.booking.import': {
      'en': 'Booking.com import',
      'ta': 'Booking.com இறக்குமதி',
      'zh': 'Booking.com 导入',
      'ru': 'Импорт Booking.com',
      'hi': 'Booking.com आयात',
      'pl': 'Import Booking.com',
    },
  };

  return keys.entries
      .map(
        (entry) => TranslationEntry(
          key: entry.key,
          values: Map<String, String>.from(entry.value),
        ),
      )
      .toList();
}

List<FeatureFlag> buildSampleFeatureFlags() {
  return const [
    FeatureFlag(
      key: 'booking_import',
      label: 'Booking.com import (DMA)',
      description: 'Allow users to import reservations via Booking.com data portability.',
      enabled: false,
    ),
    FeatureFlag(
      key: 'news_module',
      label: 'News feed',
      description: 'Enable curated alerts in the mobile experience.',
      enabled: false,
    ),
    FeatureFlag(
      key: 'offline_sync',
      label: 'Automatic offline sync',
      description: 'Silently refresh content in the background when online.',
      enabled: true,
    ),
  ];
}

SystemSettings buildSampleSystemSettings() {
  return const SystemSettings(
    adminTilesUrl:
        'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=YOUR_KEY',
    mediaBaseUrl: 'https://www.nodecmb.com/guidelkv2/media/',
    maxUploadSizeMb: 12,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
  );
}

String formatDate(DateTime date) {
  final formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}
