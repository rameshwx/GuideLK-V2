import 'package:intl/intl.dart';

enum TripStatus { draft, active, archived }

enum TripStopKind { poi, stay }

enum TripStopStatus { planned, visited, skipped }

const _sentinel = Object();

class TripStop {
  TripStop({
    required this.id,
    required this.kind,
    required this.referenceId,
    required this.sortOrder,
    this.dayIndex = 0,
    this.status = TripStopStatus.planned,
    this.isBooked = false,
    this.checkIn,
    this.checkOut,
  });

  final String id;
  final TripStopKind kind;
  final String referenceId;
  final int sortOrder;
  final int dayIndex;
  final TripStopStatus status;
  final bool isBooked;
  final DateTime? checkIn;
  final DateTime? checkOut;

  TripStop copyWith({
    TripStopKind? kind,
    String? referenceId,
    int? sortOrder,
    int? dayIndex,
    TripStopStatus? status,
    bool? isBooked,
    Object? checkIn = _sentinel,
    Object? checkOut = _sentinel,
  }) {
    return TripStop(
      id: id,
      kind: kind ?? this.kind,
      referenceId: referenceId ?? this.referenceId,
      sortOrder: sortOrder ?? this.sortOrder,
      dayIndex: dayIndex ?? this.dayIndex,
      status: status ?? this.status,
      isBooked: isBooked ?? this.isBooked,
      checkIn:
          identical(checkIn, _sentinel) ? this.checkIn : checkIn as DateTime?,
      checkOut:
          identical(checkOut, _sentinel) ? this.checkOut : checkOut as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kind': kind.name,
      'referenceId': referenceId,
      'sortOrder': sortOrder,
      'dayIndex': dayIndex,
      'status': status.name,
      'isBooked': isBooked,
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
    };
  }

  factory TripStop.fromMap(Map<dynamic, dynamic> map) {
    return TripStop(
      id: map['id'] as String,
      kind: TripStopKind.values.firstWhere(
        (value) => value.name == map['kind'],
        orElse: () => TripStopKind.poi,
      ),
      referenceId: map['referenceId'] as String,
      sortOrder: map['sortOrder'] as int,
      dayIndex: map['dayIndex'] as int? ?? 0,
      status: TripStopStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => TripStopStatus.planned,
      ),
      isBooked: map['isBooked'] as bool? ?? false,
      checkIn: _parseDate(map['checkIn'] as String?),
      checkOut: _parseDate(map['checkOut'] as String?),
    );
  }
}

class Trip {
  Trip({
    required this.id,
    required this.name,
    required this.status,
    required this.stops,
    this.startDate,
    this.endDate,
  });

  final String id;
  final String name;
  final TripStatus status;
  final List<TripStop> stops;
  final DateTime? startDate;
  final DateTime? endDate;

  Trip copyWith({
    String? name,
    TripStatus? status,
    List<TripStop>? stops,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Trip(
      id: id,
      name: name ?? this.name,
      status: status ?? this.status,
      stops: stops ?? this.stops,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status.name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'stops': stops.map((stop) => stop.toMap()).toList(),
    };
  }

  factory Trip.fromMap(Map<dynamic, dynamic> map) {
    return Trip(
      id: map['id'] as String,
      name: map['name'] as String,
      status: TripStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => TripStatus.draft,
      ),
      startDate: _parseDate(map['startDate'] as String?),
      endDate: _parseDate(map['endDate'] as String?),
      stops: (map['stops'] as List<dynamic>? ?? [])
          .map((dynamic stop) =>
              TripStop.fromMap(stop as Map<dynamic, dynamic>))
          .toList(),
    );
  }

  String get formattedDateRange {
    if (startDate == null && endDate == null) {
      return 'Flexible';
    }
    final buffer = StringBuffer();
    final formatter = DateFormat('d MMM');
    if (startDate != null) {
      buffer.write(formatter.format(startDate!));
    }
    if (endDate != null) {
      buffer
        ..write(' – ')
        ..write(formatter.format(endDate!));
    }
    return buffer.toString();
  }
}

DateTime? _parseDate(String? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value);
}
