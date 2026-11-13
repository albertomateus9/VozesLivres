import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';

/// Utilitário gratuito de criação e cálculo de limites de marcadores para OpenStreetMap.
class MarkerService {
  LatLngBounds? bounds(List<Marker> markers) {
    if (markers.isEmpty) return null;
    return createBounds(markers.map((m) => m.point).toList());
  }

  LatLngBounds createBounds(List<LatLng> positions) {
    final southwestLat = positions
        .map((p) => p.latitude)
        .reduce((value, element) => value < element ? value : element);
    final southwestLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value < element ? value : element);
    final northeastLat = positions
        .map((p) => p.latitude)
        .reduce((value, element) => value > element ? value : element);
    final northeastLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value > element ? value : element);

    // Garante área mínima visível quando todos os pontos coincidem
    final latPadding = (northeastLat - southwestLat).abs() < 0.002 ? 0.006 : 0.0;
    final lonPadding = (northeastLon - southwestLon).abs() < 0.002 ? 0.006 : 0.0;

    return LatLngBounds(
      LatLng(southwestLat - latPadding, southwestLon - lonPadding),
      LatLng(northeastLat + latPadding, northeastLon + lonPadding),
    );
  }

  Marker createMarkerFromPlace(
    Place place, {
    bool isCurrentLocation = false,
    void Function(Place)? onTap,
  }) {
    final point = LatLng(
      place.geometry.location.lat,
      place.geometry.location.lng,
    );
    final title = place.name ?? 'Local Seguro';

    return Marker(
      point: point,
      width: 44,
      height: 44,
      child: Tooltip(
        message: title,
        child: GestureDetector(
          onTap: () => onTap?.call(place),
          child: Container(
            decoration: BoxDecoration(
              color: isCurrentLocation
                  ? const Color(0xFF0066CC)
                  : const Color(0xFFD32F2F),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isCurrentLocation
                  ? Icons.my_location_rounded
                  : Icons.shield_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
