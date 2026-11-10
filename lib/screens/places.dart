import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:safeherven_app/blocs/application_bloc.dart';
import 'package:safeherven_app/shared/bottom.dart';
import 'package:safeherven_app/shared/appbar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/place.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({Key? key}) : super(key: key);

  @override
  _PlacesScreenState createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  late StreamSubscription locationSubscription;
  late StreamSubscription boundsSubscription;
  final _locationController = TextEditingController();

  _checkStatus() async {
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

    boundsSubscription = applicationBloc.bounds.stream.listen((bounds) async {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
    });

    super.initState();
  }

  @override
  void dispose() {
    boundsSubscription.cancel();
    locationSubscription.cancel();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
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
                      child: GoogleMap(
                        markers: Set<Marker>.of(applicationBloc.markers),
                        onMapCreated: (GoogleMapController controller) {
                          if (!_mapController.isCompleted) {
                            _mapController.complete(controller);
                          }
                        },
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            applicationBloc.currentLocation!.latitude,
                            applicationBloc.currentLocation!.longitude,
                          ),
                          zoom: 12.0,
                        ),
                      ),
                    ),
                    if (applicationBloc.searchResults != null &&
                        applicationBloc.searchResults!.isNotEmpty)
                      Container(
                        height: 320,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B2545).withOpacity(.85),
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
                              leading: const Icon(Icons.location_on, color: Color(0xFF0066CC)),
                              title: Text(
                                applicationBloc.searchResults![index].description,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              onTap: () {
                                applicationBloc.setSelectedLocation(
                                  applicationBloc.searchResults![index].placeId,
                                );
                              },
                            );
                          },
                        ),
                      )
                  ],
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

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(place.geometry.location.lat, place.geometry.location.lng),
          zoom: 14,
        ),
      ),
    );
  }
}

