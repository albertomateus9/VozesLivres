import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:safeherven_app/models/geometry.dart';
import 'package:safeherven_app/models/location.dart';
import 'package:safeherven_app/models/place.dart';
import 'dart:convert' as convert;

import 'package:safeherven_app/models/place_search.dart';

class PlacesService {
  final key = 'YOUR-API-KEY';

  final List<PlaceSearch> _mockSuggestions = [
    PlaceSearch(description: "Hospital Central de Apoio", placeId: "mock_hosp_1"),
    PlaceSearch(description: "Delegacia Especializada de Proteção à Mulher", placeId: "mock_pol_1"),
    PlaceSearch(description: "Centro de Acolhimento e Apoio Social", placeId: "mock_acc_1"),
    PlaceSearch(description: "Posto de Saúde Municipal", placeId: "mock_doc_1"),
    PlaceSearch(description: "Farmácia Comunitária 24h", placeId: "mock_phar_1"),
    PlaceSearch(description: "Belém - PA (Centro)", placeId: "mock_belem"),
    PlaceSearch(description: "São Paulo - SP (Centro)", placeId: "mock_sp"),
  ];

  Future<Iterable> getAutoComplete(String search) async {
    if (key == 'YOUR-API-KEY') {
      final query = search.toLowerCase();
      final filtered = _mockSuggestions.where((p) => p.description.toString().toLowerCase().contains(query)).toList();
      return filtered.isNotEmpty ? filtered : _mockSuggestions;
    }
    try {
      var url = Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=%28cities%29&key=$key');
      var response = await http.get(url);
      var json = convert.jsonDecode(response.body);
      var jsonResults = json['predictions'] as List;
      return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
    } catch (e) {
      return _mockSuggestions;
    }
  }

  Future<Place> getPlace(String? placeId) async {
    if (key == 'YOUR-API-KEY' || placeId?.startsWith('mock_') == true) {
      return _getMockPlaceById(placeId);
    }
    try {
      var url = Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?key=$key&place_id=$placeId');
      var response = await http.get(url);
      var json = convert.jsonDecode(response.body);
      var jsonResult = json['result'] as Map<String, dynamic>;
      return Place.fromJson(jsonResult);
    } catch (e) {
      return _getMockPlaceById(placeId);
    }
  }

  Future<List<Place>> getPlaces(double lat, double lng, String placeType) async {
    if (key == 'YOUR-API-KEY') {
      return _getMockPlacesByType(lat, lng, placeType);
    }
    try {
      var url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/textsearch/json?'
              'type=$placeType&location=$lat,$lng&rankby=distance&key=$key'
      );
      var response = await http.get(url);
      var json = convert.jsonDecode(response.body);
      var jsonResults = json['results'] as List;
      return jsonResults.map((place) => Place.fromJson(place)).toList();
    } catch (e) {
      return _getMockPlacesByType(lat, lng, placeType);
    }
  }

  Place _getMockPlaceById(String? id) {
    switch (id) {
      case 'mock_hosp_1':
        return Place(
          geometry: Geometry(location: Location(lat: -23.551520, lng: -46.634308)),
          name: "Hospital Central de Apoio",
          vicinity: "Av. Principal, 100 - Centro",
        );
      case 'mock_pol_1':
        return Place(
          geometry: Geometry(location: Location(lat: -23.549520, lng: -46.632308)),
          name: "Delegacia Especializada de Proteção à Mulher",
          vicinity: "Rua das Flores, 50 - Centro",
        );
      case 'mock_belem':
        return Place(
          geometry: Geometry(location: Location(lat: -1.455833, lng: -48.490833)),
          name: "Belém - PA",
          vicinity: "Belém, Pará",
        );
      default:
        return Place(
          geometry: Geometry(location: Location(lat: -23.550520, lng: -46.633308)),
          name: "Local de Apoio Selecionado",
          vicinity: "Endereço Seguro Próximo",
        );
    }
  }

  List<Place> _getMockPlacesByType(double lat, double lng, String placeType) {
    switch (placeType) {
      case 'hospital':
      case 'doctor':
        return [
          Place(
            geometry: Geometry(location: Location(lat: lat + 0.003, lng: lng + 0.002)),
            name: "Hospital de Urgência e Acolhimento",
            vicinity: "Av. Saúde, 250",
          ),
          Place(
            geometry: Geometry(location: Location(lat: lat - 0.002, lng: lng + 0.004)),
            name: "Posto de Saúde da Família",
            vicinity: "Rua do Acolhimento, 12",
          ),
        ];
      case 'police':
        return [
          Place(
            geometry: Geometry(location: Location(lat: lat + 0.004, lng: lng - 0.003)),
            name: "Delegacia de Defesa da Mulher",
            vicinity: "Av. Proteção, 190",
          ),
        ];
      case 'pharmacy':
        return [
          Place(
            geometry: Geometry(location: Location(lat: lat - 0.001, lng: lng - 0.002)),
            name: "Farmácia Popular 24 Horas",
            vicinity: "Rua Comercial, 88",
          ),
        ];
      default:
        return [
          Place(
            geometry: Geometry(location: Location(lat: lat + 0.002, lng: lng + 0.002)),
            name: "Ponto de Apoio Comunitário ($placeType)",
            vicinity: "Endereço Seguro Próximo",
          ),
        ];
    }
  }
}
