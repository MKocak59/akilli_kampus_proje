import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// KONUM SEÇME EKRANI

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation; // Seçilen konum
  bool _isLoading = true;

  // Varsayılan konum (Konum izni yoksa açılacak yer - Örn: İstanbul)
  static const LatLng _defaultLocation = LatLng(41.0082, 28.9784);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // 📍 Kullanıcının anlık konumunu al ve haritayı oraya götür
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    // Konumu al
    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _isLoading = false;
    });

    // Haritayı kullanıcının olduğu yere uçur
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konum İşaretle"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            // Eğer konum seçilmediyse buton pasif olsun
            onPressed: _pickedLocation == null
                ? null
                : () {
              // Seçilen konumu geri gönderiyoruz
              Navigator.of(context).pop(_pickedLocation);
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _defaultLocation,
          zoom: 15,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) => _mapController = controller,

        // Haritaya tıklayınca çalışır
        onTap: (LatLng position) {
          setState(() {
            _pickedLocation = position;
          });
        },

        // İşaretlenen yeri gösterir
        markers: _pickedLocation == null
            ? {}
            : {
          Marker(
            markerId: const MarkerId("selected"),
            position: _pickedLocation!,
          ),
        },
      ),
    );
  }
}