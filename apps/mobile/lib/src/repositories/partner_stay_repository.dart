import 'package:hive_flutter/hive_flutter.dart';

import '../core/bootstrap.dart';
import '../models/partner_stay.dart';

class PartnerStayRepository {
  PartnerStayRepository(this._box);

  final Box _box;

  Future<List<PartnerStay>> fetchPartnerStays() async {
    final raw =
        _box.get(HiveKeys.properties, defaultValue: []) as List<dynamic>;
    return raw
        .map((dynamic item) =>
            PartnerStay.fromMap(item as Map<dynamic, dynamic>))
        .toList();
  }
}
