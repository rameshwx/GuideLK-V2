import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/sample_data.dart';

const _userBox = 'userBox';
const _tripBox = 'tripBox';
const _poiBox = 'poiCache';
const _propertiesBox = 'propertiesCache';
const _queuedActionsBox = 'queuedActions';

/// Keys used within the Hive boxes to persist structured data.
class HiveKeys {
  HiveKeys._();

  static const pois = 'pois';
  static const properties = 'properties';
  static const trips = 'trips';
  static const bookingImport = 'bookingImport';
  static const featureFlags = 'featureFlags';
}

/// Firebase configuration expected by the mobile application.
const firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyDew-FIREBASE-API-KEY',
  appId: '1:819709172713:web:659b786487d72622210978',
  messagingSenderId: '819709172713',
  projectId: 'guidelk-d1393',
  authDomain: 'guidelk-d1393.firebaseapp.com',
  storageBucket: 'guidelk-d1393.firebasestorage.app',
  measurementId: 'G-VMES9VG28T',
);

/// Bootstraps Flutter bindings, Firebase, Hive and seeds the local cache with
/// the baseline data required for an offline-first experience.
Future<void> bootstrapApplication() async {
  await Firebase.initializeApp(options: firebaseOptions);
  await Hive.initFlutter();

  await Future.wait([
    Hive.openBox(_userBox),
    Hive.openBox(_tripBox),
    Hive.openBox(_poiBox),
    Hive.openBox(_propertiesBox),
    Hive.openBox(_queuedActionsBox),
  ]);

  await _seedIfEmpty();
}

Future<void> _seedIfEmpty() async {
  final poiBox = Hive.box(_poiBox);
  final propertiesBox = Hive.box(_propertiesBox);
  final tripBox = Hive.box(_tripBox);
  final userBox = Hive.box(_userBox);

  if (!poiBox.containsKey(HiveKeys.pois)) {
    poiBox.put(
      HiveKeys.pois,
      samplePois.map((poi) => poi.toMap()).toList(growable: false),
    );
  }

  if (!propertiesBox.containsKey(HiveKeys.properties)) {
    propertiesBox.put(
      HiveKeys.properties,
      samplePartnerStays
          .map((stay) => stay.toMap())
          .toList(growable: false),
    );
  }

  if (!tripBox.containsKey(HiveKeys.trips)) {
    tripBox.put(
      HiveKeys.trips,
      sampleTrips.map((trip) => trip.toMap()).toList(growable: false),
    );
  }

  if (!userBox.containsKey(HiveKeys.featureFlags)) {
    userBox.put(HiveKeys.featureFlags, {
      'bookingImportEnabled': false,
    });
  }

  if (!userBox.containsKey(HiveKeys.bookingImport)) {
    userBox.put(HiveKeys.bookingImport, const {
      'portabilityUrl': null,
      'scope': 'dma',
    });
  }
}
