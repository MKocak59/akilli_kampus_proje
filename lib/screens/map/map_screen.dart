import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report_model.dart';
import '../report/report_detail_screen.dart';


///  HARİTA EKRANI (MapScreen)

/// Bu ekran:
/// Kampüs içindeki bildirmleri harita üzerinde gösterir
/// Bildirim türüne göre farklı renk pinler kullanır
/// Pin tıklanınca alt bilgi kartı açar
/// Kartta başlık, tür, tarih ve "Detayı Gör" butonu bulunur

/// Kullanılanlar:
/// Google Maps
/// Firestore
/// ReportModel


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Google Map controller
  GoogleMapController? mapController;

  /// Haritadaki marker'lar
  final Set<Marker> _markers = {};

  /// Seçilen bildirim (pine tıklanınca atanır)
  ReportModel? selectedReport;

  /// Başlangıç konumu
  static const LatLng _initialPosition = LatLng(
    41.015137,
    28.979530,
  );

  @override
  void initState() {
    super.initState();
    _loadReportsFromFirestore();
  }


  /// Firestore’dan bildirimleri çekip haritaya marker ekler

  Future<void> _loadReportsFromFirestore() async {
    final snapshot =
    await FirebaseFirestore.instance.collection("reports").get();

    final Set<Marker> loadedMarkers = {};

    for (var doc in snapshot.docs) {
      final report = ReportModel.fromMap(
        doc.id,
        doc.data(),
      );

      loadedMarkers.add(
        Marker(
          markerId: MarkerId(report.id),
          position: LatLng(report.latitude, report.longitude),

          /// Pine tıklanınca alttaki bilgi kartını açar
          onTap: () {
            setState(() {
              selectedReport = report;
            });
          },

          icon: BitmapDescriptor.defaultMarkerWithHue(
            report.type == "Güvenlik"
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(loadedMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🗺 Harita"),
      ),

      /// Stack kullanıyoruz → Harita + Alt bilgi kartı
      body: Stack(
        children: [
          /// GOOGLE MAP
          GoogleMap(
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

            /// Haritaya tıklanınca kart kapansın
            onTap: (_) {
              setState(() {
                selectedReport = null;
              });
            },
          ),

          /// ALT BİLGİ KARTI
          if (selectedReport != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildInfoCard(context),
            ),
        ],
      ),
    );
  }


  ///  Pine tıklanınca açılan bilgi kartı

  Widget _buildInfoCard(BuildContext context) {
    // Seçili raporun null olmadığından emin olalım
    final report = selectedReport!;

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// BAŞLIK
            Text(
              report.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            /// TÜR
            Text("Tür: ${report.type}"),

            const SizedBox(height: 6),

            /// TARİH
            Text(
              "Oluşturulma: ${report.createdAt.day}.${report.createdAt
                  .month}.${report.createdAt.year}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 12),

            /// DETAY BUTONU
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                // 🔥 GÜNCELLENEN KISIM BURASI 🔥
                onPressed: () {
                  // Detay sayfasına git ve seçilen raporu yanına al
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailScreen(report: report),
                    ),
                  );
                },
                child: const Text("Detayı Gör"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}