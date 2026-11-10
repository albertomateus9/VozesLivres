import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safeherven_app/models/geometry.dart';
import 'package:safeherven_app/models/location.dart';
import 'package:safeherven_app/models/place.dart';
import 'package:safeherven_app/services/geolocator_service.dart';
import 'package:safeherven_app/services/marker_service.dart';
import 'package:safeherven_app/services/places_service.dart';

import '../models/place_search.dart';

class ApplicationBloc with ChangeNotifier {
  final geolocatorService = GeolocatorService();
  final placesService = PlacesService();
  final markerService = MarkerService();


  // Variables
  Position? currentLocation;
  List<PlaceSearch>? searchResults;
  StreamController<Place?> selectedLocation = StreamController<Place?>.broadcast();
  StreamController<LatLngBounds> bounds = StreamController<LatLngBounds>.broadcast();
  Place? selectedLocationStatic;
  String? placeType;
  List<Marker> markers = <Marker>[];

  ApplicationBloc() {
    setCurrentLocation();
  }

  setCurrentLocation() async {
    try {
      currentLocation = await geolocatorService.getCurrentLocation();
      selectedLocationStatic = Place(
          geometry: Geometry(
              location: Location(
                  lat: currentLocation!.latitude,
                  lng: currentLocation!.longitude)
          ),
          name: "Sua Localização",
          vicinity: "Sua Posição Atual"
      );
    } catch (e) {
      // Fallback default coordinates if location is disabled
      currentLocation = Position(
        longitude: -46.633308,
        latitude: -23.550520,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
      selectedLocationStatic = Place(
          geometry: Geometry(
              location: Location(
                  lat: currentLocation!.latitude,
                  lng: currentLocation!.longitude)
          ),
          name: "São Paulo, SP",
          vicinity: "Localização Padrão"
      );
    }
    notifyListeners();
  }

  searchPLaces(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      searchResults = null;
      notifyListeners();
      return;
    }
    try {
      searchResults = await placesService.getAutoComplete(searchTerm) as List<PlaceSearch>;
    } catch (e) {
      searchResults = [];
    }
    notifyListeners();
  }
  
  setSelectedLocation(String? placeId) async {
    try {
      var sLocation = await placesService.getPlace(placeId);
      selectedLocation.add(sLocation);
      selectedLocationStatic = sLocation;
      searchResults = null;
    } catch (e) {
      searchResults = null;
    }
    notifyListeners();
  }

  clearSelectedLocation() {
    selectedLocationStatic = null;
    searchResults = null;
    placeType = null;
    notifyListeners();
  }

  togglePlaceType(String value, bool selected) async {
    if (selected) {
      placeType = value;
    } else {
      placeType = null;
    }

    if (placeType != null && selectedLocationStatic != null) {
      try {
        var places = await placesService.getPlaces(
            selectedLocationStatic!.geometry.location.lat,
            selectedLocationStatic!.geometry.location.lng,
            placeType!,
        );

        markers = [];

        if (places.isNotEmpty) {
          for (var place in places) {
            markers.add(markerService.createMarkerFromPlace(place));
          }
        }

        var locationMarker = markerService.createMarkerFromPlace(selectedLocationStatic!);
        markers.add(locationMarker);

        var _bounds = markerService.bounds(Set<Marker>.of(markers));
        if (_bounds != null) {
          bounds.add(_bounds);
        }
      } catch (e) {
        markers = [];
      }
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