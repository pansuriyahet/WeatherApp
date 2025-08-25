import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';  // Add geocoding package

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  // Initial position is Ahmedabad
  LatLng _currentLatLng = const LatLng(23.0225, 72.5714);

  final TextEditingController _searchController = TextEditingController();

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Initial marker for Ahmedabad
    _markers.add(
      Marker(
        markerId: const MarkerId('ahmedabad'),
        position: _currentLatLng,
        infoWindow: const InfoWindow(title: 'Ahmedabad'),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Search and move camera to searched city
  Future<void> _searchAndNavigate() async {
    String city = _searchController.text.trim();
    if (city.isEmpty) return;

    try {
      // Use geocoding package to get location from city name
      List<Location> locations = await locationFromAddress(city);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newLatLng = LatLng(location.latitude, location.longitude);

        // Move camera
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newLatLng, zoom: 13),
          ),
        );

        // Update marker
        setState(() {
          _currentLatLng = newLatLng;
          _markers.clear();
          _markers.add(
            Marker(
              markerId: MarkerId(city.toLowerCase()),
              position: newLatLng,
              infoWindow: InfoWindow(title: city),
            ),
          );
        });
      }
    } catch (e) {
      // Handle errors, like city not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found: $city')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Search'),
      ),
      body: Column(
        children: [
          // Search bar on top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search city',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (value) => _searchAndNavigate(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchAndNavigate,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),

          // Map fills remaining screen
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLatLng,
                zoom: 13,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
