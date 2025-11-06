import 'package:flutter/material.dart';

import 'news/news_module.dart';
import 'partner_stays/partner_stays_module.dart';
import 'pois/pois_module.dart';
import 'system/system_module.dart';
import 'translations/translations_module.dart';
import 'users/users_module.dart';

enum AdminModule {
  users,
  pois,
  stays,
  translations,
  system,
  news,
}

extension AdminModuleMeta on AdminModule {
  String get label {
    switch (this) {
      case AdminModule.users:
        return 'Users';
      case AdminModule.pois:
        return 'Attractions';
      case AdminModule.stays:
        return 'Partner Stays';
      case AdminModule.translations:
        return 'Translations';
      case AdminModule.system:
        return 'System';
      case AdminModule.news:
        return 'News';
    }
  }

  IconData get icon {
    switch (this) {
      case AdminModule.users:
        return Icons.people_outline;
      case AdminModule.pois:
        return Icons.place_outlined;
      case AdminModule.stays:
        return Icons.hotel_class_outlined;
      case AdminModule.translations:
        return Icons.translate_outlined;
      case AdminModule.system:
        return Icons.settings_outlined;
      case AdminModule.news:
        return Icons.campaign_outlined;
    }
  }

  String get pathSegment {
    switch (this) {
      case AdminModule.users:
        return 'users';
      case AdminModule.pois:
        return 'pois';
      case AdminModule.stays:
        return 'stays';
      case AdminModule.translations:
        return 'translations';
      case AdminModule.system:
        return 'system';
      case AdminModule.news:
        return 'news';
    }
  }

  Widget build() {
    switch (this) {
      case AdminModule.users:
        return const UsersModule();
      case AdminModule.pois:
        return const PoisModule();
      case AdminModule.stays:
        return const PartnerStaysModule();
      case AdminModule.translations:
        return const TranslationsModule();
      case AdminModule.system:
        return const SystemModule();
      case AdminModule.news:
        return const NewsModule();
    }
  }
}

