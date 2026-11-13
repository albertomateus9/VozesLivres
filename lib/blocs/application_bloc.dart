import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safeherven_app/models/geometry.dart';
import 'package:safeherven_app/models/location.dart';
import 'package:safeherven_app/models/place.dart';
import 'package:safeherven_app/models/place_search.dart';
import 'package:safeherven_app/services/geolocator_service.dart';
import 'package:safeherven_app/services/marker_service.dart';
import 'package:safeherven_app/services/places_service.dart';

class ApplicationBloc with ChangeNotifier {
  final geolocatorService = GeolocatorService();
  final placesService = PlacesService();
  final markerService = MarkerService();

  Position? currentLocation;
  List<PlaceSearch>? searchResults;
  StreamController<Place?> selectedLocation = StreamController<Place?>.broadcast();
  StreamController<LatLngBounds> bounds = StreamController<LatLngBounds>.broadcast();
  Place? selectedLocationStatic;
  Place? tappedMarkerPlace;
  String? placeType;
  List<Marker> markers = <Marker>[];
  bool isSearchingPlaces = false;

  ApplicationBloc() {
    setCurrentLocation();
  }

  void selectMarkerPlace(Place? place) {
    tappedMarkerPlace = place;
    notifyListeners();
  }

  Future<void> setCurrentLocation() async {
    try {
      currentLocation = await geolocatorService.getCurrentLocation();
      selectedLocationStatic = Place(
        geometry: Geometry(
          location: Location(
            lat: currentLocation!.latitude,
            lng: currentLocation!.longitude,
          ),
        ),
        name: "Sua Localização",
        vicinity: "Sua Posição Atual",
      );
    } catch (e) {
      // Fallback caso o GPS esteja desativado no aparelho ou emulador
      currentLocation = Position(
        longitude: -48.490833,
        latitude: -1.455833,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
      selectedLocationStatic = Place(
        geometry: Geometry(
          location: Location(
            lat: currentLocation!.latitude,
            lng: currentLocation!.longitude,
          ),
        ),
        name: "Belém - PA",
        vicinity: "Localização Padrão",
      );
    }

    if (selectedLocationStatic != null) {
      markers = [
        markerService.createMarkerFromPlace(
          selectedLocationStatic!,
          isCurrentLocation: true,
          onTap: selectMarkerPlace,
        ),
      ];
    }
    notifyListeners();
  }

  Future<void> searchPLaces(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      searchResults = null;
      notifyListeners();
      return;
    }
    try {
      searchResults = await placesService.getAutoComplete(searchTerm);
    } catch (e) {
      searchResults = [];
    }
    notifyListeners();
  }

  Future<void> setSelectedLocation(String? placeId) async {
    try {
      final sLocation = await placesService.getPlace(placeId);
      selectedLocation.add(sLocation);
      selectedLocationStatic = sLocation;
      tappedMarkerPlace = sLocation;
      searchResults = null;
      markers = [
        markerService.createMarkerFromPlace(
          sLocation,
          isCurrentLocation: true,
          onTap: selectMarkerPlace,
        ),
      ];
    } catch (e) {
      searchResults = null;
    }
    notifyListeners();
  }

  void clearSelectedLocation() {
    selectedLocationStatic = null;
    searchResults = null;
    placeType = null;
    tappedMarkerPlace = null;
    if (currentLocation != null) {
      final currentPlace = Place(
        geometry: Geometry(
          location: Location(
            lat: currentLocation!.latitude,
            lng: currentLocation!.longitude,
          ),
        ),
        name: "Sua Localização",
        vicinity: "Sua Posição Atual",
      );
      selectedLocationStatic = currentPlace;
      markers = [
        markerService.createMarkerFromPlace(
          currentPlace,
          isCurrentLocation: true,
          onTap: selectMarkerPlace,
        ),
      ];
    } else {
      markers = [];
    }
    notifyListeners();
  }

  Future<void> togglePlaceType(String value, bool selected) async {
    if (selected) {
      placeType = value;
    } else {
      placeType = null;
    }

    tappedMarkerPlace = null;

    if (placeType != null && selectedLocationStatic != null) {
      isSearchingPlaces = true;
      notifyListeners();
      try {
        final places = await placesService.getPlaces(
          selectedLocationStatic!.geometry.location.lat,
          selectedLocationStatic!.geometry.location.lng,
          placeType!,
        );

        final updatedMarkers = <Marker>[];
        for (final place in places) {
          updatedMarkers.add(
            markerService.createMarkerFromPlace(
              place,
              onTap: selectMarkerPlace,
            ),
          );
        }

        updatedMarkers.add(
          markerService.createMarkerFromPlace(
            selectedLocationStatic!,
            isCurrentLocation: true,
            onTap: selectMarkerPlace,
          ),
        );

        markers = updatedMarkers;
        if (places.isNotEmpty) {
          tappedMarkerPlace = places.first;
        }

        final calculatedBounds = markerService.bounds(markers);
        if (calculatedBounds != null) {
          bounds.add(calculatedBounds);
        }
      } catch (e) {
        markers = [];
      } finally {
        isSearchingPlaces = false;
      }
    } else if (selectedLocationStatic != null) {
      markers = [
        markerService.createMarkerFromPlace(
          selectedLocationStatic!,
          isCurrentLocation: true,
          onTap: selectMarkerPlace,
        ),
      ];
    } else {
      markers = [];
    }

    notifyListeners();
  }

  @override
  void dispose() {
    selectedLocation.close();
    bounds.close();
    super.dispose();
  }
}
