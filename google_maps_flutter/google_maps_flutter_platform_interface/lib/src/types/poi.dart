// google_maps_flutter/google_maps_flutter_platform_interface/lib/src/types/poi.dart
import 'package:meta/meta.dart';
import 'location.dart';

@immutable
class PointOfInterest {
  const PointOfInterest({
    required this.placeId,
    required this.name,
    required this.location,
  });

  final String placeId;
  final String name;
  final LatLng location;

  factory PointOfInterest.fromMap(Map<dynamic, dynamic> json) {
    final pos = json['position'] as Map<dynamic, dynamic>? ?? const {};
    final lat = (pos['latitude'] as num?)?.toDouble() ?? 0.0;
    final lng = (pos['longitude'] as num?)?.toDouble() ?? 0.0;
    return PointOfInterest(
      placeId: (json['placeId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      location: LatLng(lat, lng),
    );
  }

  Map<String, dynamic> toJson() => {
        'placeId': placeId,
        'name': name,
        'position': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      };
}