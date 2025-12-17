import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/report_model.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  // Tür'e göre ikon seçimi
  IconData _getTypeIcon(String type) {
    if (type == "Sağlık") return Icons.health_and_safety;
    return Icons.security;
  }

  // Tür'e göre renk seçimi
  Color _getTypeColor(String type) {
    if (type == "Sağlık") return Colors.redAccent;
    return Colors.blueAccent;
  }

  // Tarih formatlayıcı (Basit yöntem)
  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // Harita için başlangıç konumu (Bildirimin konumu)
    final LatLng reportLocation = LatLng(report.latitude, report.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bildirim Detayı"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 1. ÜST BİLGİ KARTI (TÜR VE DURUM)
            Container(
              color: _getTypeColor(report.type).withOpacity(0.1),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getTypeColor(report.type).withOpacity(0.2),
                    child: Icon(
                      _getTypeIcon(report.type),
                      color: _getTypeColor(report.type),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.type.toUpperCase(),
                          style: TextStyle(
                            color: _getTypeColor(report.type),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.status,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tarih Bilgisi
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(report.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            /// 2. BAŞLIK VE AÇIKLAMA
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Konu",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Açıklama",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(thickness: 8, color: Colors.black12),

            /// 3. KONUM HARİTASI
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text(
                        "Olay Konumu",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Harita Kutusu
                  Container(
                    height: 250, // Haritanın yüksekliği
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: reportLocation,
                          zoom: 15, // Yakınlaştırma seviyesi
                        ),
                        // Harita üzerindeki kontrolleri kapatalım, sadece görüntü olsun
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false, // Sayfayı kaydırırken harita kaymasın diye
                        rotateGesturesEnabled: false,
                        liteModeEnabled: false, // Android'de daha performanslı çalışması için true yapılabilir ama marker görünmeyebilir bazen
                        markers: {
                          Marker(
                            markerId: const MarkerId("report_loc"),
                            position: reportLocation,
                            infoWindow: InfoWindow(title: report.title),
                          ),
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Koordinatlar: ${report.latitude.toStringAsFixed(5)}, ${report.longitude.toStringAsFixed(5)}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}