import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:safeherven_app/blocs/application_bloc.dart';
import 'package:safeherven_app/models/place.dart';
import 'package:safeherven_app/shared/appbar.dart';
import 'package:safeherven_app/shared/bottom.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final MapController _mapController = MapController();
  late StreamSubscription<Place?> locationSubscription;
  late StreamSubscription<LatLngBounds> boundsSubscription;
  final _locationController = TextEditingController();

  Future<void> _checkStatus() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await [Permission.location].request();
    }
    if (await Permission.location.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    _checkStatus();
    final applicationBloc = Provider.of<ApplicationBloc>(context, listen: false);

    locationSubscription = applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null && place.name != null) {
        _locationController.text = place.name!;
        _goToPlace(place);
      } else {
        _locationController.text = "";
      }
    });

    boundsSubscription = applicationBloc.bounds.stream.listen((bounds) {
      if (!mounted) return;
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(42.0),
          maxZoom: 15.5,
        ),
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    boundsSubscription.cancel();
    locationSubscription.cancel();
    _locationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    final tappedPlace = applicationBloc.tappedMarkerPlace;

    return Scaffold(
      appBar: const SafeHervenAppBar("Locais Seguros", isHome: false),
      bottomNavigationBar: const MenuBottom(currentIndex: 1),
      body: (applicationBloc.currentLocation == null)
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0B2545)),
            )
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _locationController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: "Buscar por localização ou cidade...",
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0066CC)),
                      suffixIcon: _locationController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _locationController.clear();
                                applicationBloc.clearSelectedLocation();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
                      ),
                    ),
                    onChanged: (value) => applicationBloc.searchPLaces(value),
                    onTap: () => applicationBloc.clearSelectedLocation(),
                  ),
                ),
                Stack(
                  children: [
                    SizedBox(
                      height: 320,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            applicationBloc.currentLocation!.latitude,
                            applicationBloc.currentLocation!.longitude,
                          ),
                          initialZoom: 13.5,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'org.safeherven.app',
                          ),
                          MarkerLayer(
                            markers: applicationBloc.markers,
                          ),
                          const RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (applicationBloc.isSearchingPlaces)
                      const Positioned(
                        top: 12,
                        right: 12,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0B2545),
                            ),
                          ),
                        ),
                      ),
                    if (applicationBloc.searchResults != null &&
                        applicationBloc.searchResults!.isNotEmpty)
                      Container(
                        height: 320,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B2545).withValues(alpha: .90),
                        ),
                      ),
                    if (applicationBloc.searchResults != null &&
                        applicationBloc.searchResults!.isNotEmpty)
                      SizedBox(
                        height: 320,
                        child: ListView.builder(
                          itemCount: applicationBloc.searchResults?.length ?? 0,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.location_on, color: Colors.white),
                              title: Text(
                                applicationBloc.searchResults![index].description.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              onTap: () {
                                applicationBloc.setSelectedLocation(
                                  applicationBloc.searchResults![index].placeId?.toString(),
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
                if (tappedPlace != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Card(
                      color: const Color(0xFFEEF6FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF0066CC), width: 1),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF0B2545),
                          child: Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                        ),
                        title: Text(
                          tappedPlace.name ?? 'Local Seguro',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B2545),
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          tappedPlace.vicinity ?? 'OpenStreetMap',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => applicationBloc.selectMarkerPlace(null),
                        ),
                      ),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text(
                    'Encontrar Local Seguro Mais Próximo',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B2545),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      _buildChip('Hospital', 'hospital', applicationBloc),
                      _buildChip('Delegacia de Polícia', 'police', applicationBloc),
                      _buildChip('Igreja', 'church', applicationBloc),
                      _buildChip('Mesquita', 'mosque', applicationBloc),
                      _buildChip('Farmácia', 'pharmacy', applicationBloc),
                      _buildChip('Agência de Viagens', 'travel_agency', applicationBloc),
                      _buildChip('Assistência Jurídica', 'lawyer', applicationBloc),
                      _buildChip('Caixa Eletrônico', 'atm', applicationBloc),
                      _buildChip('Banco', 'bank', applicationBloc),
                      _buildChip('Médico / Posto de Saúde', 'doctor', applicationBloc),
                      _buildChip('Universidade', 'university', applicationBloc),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildChip(String label, String type, ApplicationBloc bloc) {
    final bool isSelected = bloc.placeType == type;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF0B2545),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF0B2545),
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0B2545) : const Color(0xFFCBD5E1),
        ),
      ),
      onSelected: (val) => bloc.togglePlaceType(type, val),
    );
  }

  void _goToPlace(Place place) {
    _mapController.move(
      LatLng(place.geometry.location.lat, place.geometry.location.lng),
      14.5,
    );
  }
}
