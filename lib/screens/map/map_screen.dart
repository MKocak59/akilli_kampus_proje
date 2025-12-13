import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report_model.dart';


///Harita Ekranı
///Bu ekran:
///Kampüs içindeki bildirmleri harita üzerinde gösterir
///Bildirim türüne göre farklı pinler kullanır
///Pin tıklanınca bilgi penceresi açar
///
///Kullanılanlar:
///Google Maps
///Reports Koleksiyonu
///ReportModel


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  ///Google Map controller
  GoogleMapController? mapController;

  ///Haritadaki marker'lar
  final Set<Marker> _markers = {};

  ///Başlangıç konumu
  static const LatLng _initialPosition = LatLng(
    41.015137, // örnek: İstanbul
    28.979530,
  );

  @override
  void initState() {
    super.initState();
    _loadReportsFromFirestore();
  }

  ///Firestore’dan bildirimleri çekip haritaya pin ekler
  Future<void> _loadReportsFromFirestore() async {
    final snapshot =
    await FirebaseFirestore.instance.collection("reports").get();

    final markers = <Marker>{};

    for (var doc in snapshot.docs) {
      final report = ReportModel.fromMap(
        doc.id,
        doc.data(),
      );

      ///Marker oluşturma
      markers.add(
        Marker(
          markerId: MarkerId(report.id),
          position: LatLng(report.latitude, report.longitude),
          infoWindow: InfoWindow(
            title: report.title,
            snippet: report.type,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            report.type == "Güvenlik"
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🗺️ Harita"),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _initialPosition,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}