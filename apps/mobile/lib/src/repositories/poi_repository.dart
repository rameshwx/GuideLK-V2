import 'package:hive_flutter/hive_flutter.dart';

import '../core/bootstrap.dart';
import '../models/poi.dart';

class PoiRepository {
  PoiRepository(this._box);

  final Box _box;

  Future<List<Poi>> fetchPois() async {
    final raw = _box.get(HiveKeys.pois, defaultValue: []) as List<dynamic>;
    return raw
        .map((dynamic item) => Poi.fromMap(item as Map<dynamic, dynamic>))
        .toList();
  }
}
