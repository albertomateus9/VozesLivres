import 'package:safeherven_app/models/geometry.dart';

class Place {
  final Geometry geometry;
  final String? name;
  final String? vicinity;

  Place({required this.geometry, required this.name, required this.vicinity});

  factory Place.fromJson(Map<String, dynamic> parsedJson) {
    return Place(
      geometry: Geometry.fromJson((parsedJson['geometry'] ?? {'location': {'lat': 0.0, 'lng': 0.0}})),
      name: parsedJson['name'] ?? parsedJson['formatted_address'] ?? 'Local Próximo',
      vicinity: parsedJson['vicinity'] ?? parsedJson['formatted_address'] ?? ''
    );
  }
}