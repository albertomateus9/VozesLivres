import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:safeherven_app/models/geometry.dart';
import 'package:safeherven_app/models/location.dart';
import 'package:safeherven_app/models/place.dart';
import 'package:safeherven_app/models/place_search.dart';

/// Serviço de busca de endereços e pontos de apoio utilizando APIs 100% gratuitas
/// e abertas do OpenStreetMap (Nominatim e Overpass API), sem necessidade de
/// chaves pagas, além de dados locais de fallback para uso offline.
class PlacesService {
  static const Map<String, String> _osmHeaders = {
    'User-Agent': 'VozesLivresApp/1.0 (https://github.com/albertomateus9/VozesLivres)',
    'Accept': 'application/json',
  };

  final Map<String, Place> _cachedOsmPlaces = {};

  final List<PlaceSearch> _mockSuggestions = [
    PlaceSearch(description: "Hospital Central de Apoio", placeId: "mock_hosp_1"),
    PlaceSearch(description: "Delegacia Especializada de Proteção", placeId: "mock_pol_1"),
    PlaceSearch(description: "Centro de Acolhimento e Apoio Social", placeId: "mock_acc_1"),
    PlaceSearch(description: "Posto de Saúde Municipal", placeId: "mock_doc_1"),
    PlaceSearch(description: "Farmácia Comunitária 24h", placeId: "mock_phar_1"),
    PlaceSearch(description: "Belém - PA (Centro)", placeId: "mock_belem"),
    PlaceSearch(description: "São Paulo - SP (Centro)", placeId: "mock_sp"),
  ];

  Future<List<PlaceSearch>> getAutoComplete(String search) async {
    final trimmed = search.trim();
    if (trimmed.isEmpty) return [];

    try {
      final url = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': trimmed,
          'format': 'jsonv2',
          'limit': '6',
          'accept-language': 'pt-BR',
        },
      );
      final response = await http
          .get(url, headers: _osmHeaders)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> items = convert.jsonDecode(response.body) as List<dynamic>;
        if (items.isNotEmpty) {
          final results = <PlaceSearch>[];
          for (final item in items) {
            final map = item as Map<String, dynamic>;
            final id = 'osm_${map['place_id']}';
            final displayName = (map['display_name'] ?? '').toString();
            final lat = double.tryParse((map['lat'] ?? '').toString()) ?? -23.550520;
            final lon = double.tryParse((map['lon'] ?? '').toString()) ?? -46.633308;
            final shortName = (map['name'] != null && map['name'].toString().isNotEmpty)
                ? map['name'].toString()
                : displayName.split(',').first.trim();

            _cachedOsmPlaces[id] = Place(
              geometry: Geometry(location: Location(lat: lat, lng: lon)),
              name: shortName,
              vicinity: displayName,
            );
            results.add(PlaceSearch(description: displayName, placeId: id));
          }
          return results;
        }
      }
    } catch (_) {
      // Fallback para sugestões locais em caso de modo offline
    }

    final query = trimmed.toLowerCase();
    final filtered = _mockSuggestions
        .where((p) => p.description.toString().toLowerCase().contains(query))
        .toList();
    return filtered.isNotEmpty ? filtered : _mockSuggestions;
  }

  Future<Place> getPlace(String? placeId) async {
    if (placeId != null && _cachedOsmPlaces.containsKey(placeId)) {
      return _cachedOsmPlaces[placeId]!;
    }
    return _getMockPlaceById(placeId);
  }

  Future<List<Place>> getPlaces(double lat, double lng, String placeType) async {
    // 1. Busca primária rápida e gratuita via OpenStreetMap Nominatim (viewbox ~6km)
    final nomQuery = _nominatimQueryForType(placeType);
    try {
      const delta = 0.055;
      final viewbox = '${lng - delta},${lat + delta},${lng + delta},${lat - delta}';
      final nomUrl = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': nomQuery,
          'format': 'jsonv2',
          'limit': '12',
          'viewbox': viewbox,
          'bounded': '1',
          'accept-language': 'pt-BR',
        },
      );
      final nomResponse = await http
          .get(nomUrl, headers: _osmHeaders)
          .timeout(const Duration(seconds: 6));

      if (nomResponse.statusCode == 200) {
        final List<dynamic> items = convert.jsonDecode(nomResponse.body) as List<dynamic>;
        if (items.isNotEmpty) {
          return items.map((raw) {
            final item = raw as Map<String, dynamic>;
            final itemLat = double.tryParse((item['lat'] ?? '').toString()) ?? lat;
            final itemLng = double.tryParse((item['lon'] ?? '').toString()) ?? lng;
            final displayName = (item['display_name'] ?? '').toString();
            final rawName = item['name']?.toString();
            final name = (rawName != null && rawName.isNotEmpty)
                ? rawName
                : (displayName.isNotEmpty
                    ? displayName.split(',').first.trim()
                    : _defaultLabelForType(placeType));
            final parts = displayName.split(',').map((s) => s.trim()).toList();
            final vicinity = parts.length > 1
                ? parts.skip(1).take(3).join(', ')
                : 'OpenStreetMap';

            return Place(
              geometry: Geometry(location: Location(lat: itemLat, lng: itemLng)),
              name: name,
              vicinity: vicinity,
            );
          }).toList();
        }
      }
    } catch (_) {
      // Segue para Overpass API / fallback offline
    }

    // 2. Fallback gratuito via Overpass API
    final overpassFilter = _overpassFilterForType(placeType, lat, lng);
    if (overpassFilter != null) {
      try {
        final query = '[out:json][timeout:6];($overpassFilter);out center 15;';
        final url = Uri.parse('https://overpass-api.de/api/interpreter');
        final response = await http
            .post(
              url,
              headers: {
                'User-Agent': _osmHeaders['User-Agent']!,
                'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: {'data': query},
            )
            .timeout(const Duration(seconds: 7));

        if (response.statusCode == 200) {
          final decoded = convert.jsonDecode(response.body) as Map<String, dynamic>;
          final elements = (decoded['elements'] as List<dynamic>?) ?? [];
          final places = <Place>[];

          for (final raw in elements) {
            final elem = raw as Map<String, dynamic>;
            final center = elem['center'] as Map<String, dynamic>?;
            final elemLat = (elem['lat'] as num?)?.toDouble() ??
                (center?['lat'] as num?)?.toDouble();
            final elemLng = (elem['lon'] as num?)?.toDouble() ??
                (center?['lon'] as num?)?.toDouble();
            if (elemLat == null || elemLng == null) continue;

            final tags = (elem['tags'] as Map<String, dynamic>?) ?? {};
            final name = (tags['name'] ?? _defaultLabelForType(placeType)).toString();
            final street = tags['addr:street']?.toString();
            final number = tags['addr:housenumber']?.toString();
            final suburb = tags['addr:suburb']?.toString();
            final addressParts = [
              if (street != null && street.isNotEmpty)
                number != null && number.isNotEmpty ? '$street, $number' : street,
              if (suburb != null && suburb.isNotEmpty) suburb,
            ];
            final vicinity = addressParts.isNotEmpty
                ? addressParts.join(' - ')
                : 'OpenStreetMap ($placeType)';

            places.add(
              Place(
                geometry: Geometry(location: Location(lat: elemLat, lng: elemLng)),
                name: name,
                vicinity: vicinity,
              ),
            );
          }

          if (places.isNotEmpty) {
            return places;
          }
        }
      } catch (_) {
        // Fallback para pontos locais seguros se estiver offline
      }
    }

    return _getMockPlacesByType(lat, lng, placeType);
  }

  String _nominatimQueryForType(String placeType) {
    switch (placeType) {
      case 'hospital':
        return 'hospital';
      case 'police':
        return 'delegacia policia';
      case 'church':
        return 'igreja';
      case 'mosque':
        return 'mesquita';
      case 'pharmacy':
        return 'farmacia';
      case 'travel_agency':
        return 'agencia de viagens';
      case 'lawyer':
        return 'advogado defensoria';
      case 'atm':
        return 'banco 24h caixa eletronico';
      case 'bank':
        return 'banco';
      case 'doctor':
        return 'posto de saude clinica';
      case 'university':
        return 'universidade escola';
      default:
        return placeType;
    }
  }

  String? _overpassFilterForType(String placeType, double lat, double lng) {
    switch (placeType) {
      case 'hospital':
        return 'nwr["amenity"="hospital"](around:5000,$lat,$lng);';
      case 'police':
        return 'nwr["amenity"="police"](around:5000,$lat,$lng);';
      case 'church':
        return 'nwr["amenity"="place_of_worship"](around:4000,$lat,$lng);';
      case 'mosque':
        return 'nwr["amenity"="place_of_worship"]["religion"="muslim"](around:8000,$lat,$lng);';
      case 'pharmacy':
        return 'nwr["amenity"="pharmacy"](around:4000,$lat,$lng);';
      case 'travel_agency':
        return 'nwr["shop"="travel_agency"](around:6000,$lat,$lng);';
      case 'lawyer':
        return 'nwr["office"="lawyer"](around:6000,$lat,$lng);';
      case 'atm':
        return 'nwr["amenity"="atm"](around:4000,$lat,$lng);';
      case 'bank':
        return 'nwr["amenity"="bank"](around:4000,$lat,$lng);';
      case 'doctor':
        return 'nwr["amenity"~"clinic|doctors|hospital"](around:5000,$lat,$lng);';
      case 'university':
        return 'nwr["amenity"~"university|college|school"](around:5000,$lat,$lng);';
      default:
        return null;
    }
  }

  String _defaultLabelForType(String placeType) {
    switch (placeType) {
      case 'hospital':
        return 'Hospital / Pronto Atendimento';
      case 'police':
        return 'Delegacia de Polícia';
      case 'pharmacy':
        return 'Farmácia';
      case 'doctor':
        return 'Posto de Saúde / Clínica';
      case 'lawyer':
        return 'Assistência Jurídica';
      case 'university':
        return 'Instituição de Ensino';
      case 'bank':
        return 'Agência Bancária';
      case 'atm':
        return 'Caixa Eletrônico 24h';
      case 'church':
      case 'mosque':
        return 'Espaço Comunitário / Templo';
      default:
        return 'Local Seguro';
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
          name: "Delegacia Especializada de Proteção",
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
            vicinity: "Referência offline - Av. Saúde, 250",
          ),
          Place(
            geometry: Geometry(location: Location(lat: lat - 0.002, lng: lng + 0.004)),
            name: "Posto de Saúde da Família",
            vicinity: "Referência offline - Rua do Acolhimento, 12",
          ),
        ];
      case 'police':
        return [
          Place(
            geometry: Geometry(location: Location(lat: lat + 0.004, lng: lng - 0.003)),
            name: "Delegacia de Proteção e Apoio",
            vicinity: "Referência offline - Av. Proteção, 190",
          ),
        ];
      case 'pharmacy':
        return [
          Place(
            geometry: Geometry(location: Location(lat: lat - 0.001, lng: lng - 0.002)),
            name: "Farmácia Popular 24 Horas",
            vicinity: "Referência offline - Rua Comercial, 88",
          ),
        ];
      default:
        return [
          Place(
            geometry: Geometry(location: Location(lat: lat + 0.002, lng: lng + 0.002)),
            name: "${_defaultLabelForType(placeType)} (Próximo)",
            vicinity: "Ponto de apoio comunitário próximo",
          ),
        ];
    }
  }
}
