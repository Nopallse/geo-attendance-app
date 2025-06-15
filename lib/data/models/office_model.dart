import 'package:google_maps_flutter/google_maps_flutter.dart';

class Office {
  final int id;
  final double latitude;
  final double longitude;
  final double radius; // dalam meter
  final String name;

  Office({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.name,
  });

  LatLng get position => LatLng(latitude, longitude);

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['lokasi_id'],
      latitude: json['lat'],
      longitude: json['lng'],
      radius: (json['range'] ?? 0.001) * 100000,
      name: json['ket'] ?? 'Tidak diketahui',
    );
  }
}
