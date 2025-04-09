import 'package:google_maps_flutter/google_maps_flutter.dart';

class Office {
  final int id;
  final String name;
  final LatLng position;
  final double radius;

  Office({
    required this.id,
    required this.name,
    required this.position,
    required this.radius,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id'],
      name: json['name'],
      position: LatLng(
        double.parse(json['latitude'].toString()),
        double.parse(json['longitude'].toString()),
      ),
      radius: double.parse(json['radius'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'radius': radius,
    };
  }
}