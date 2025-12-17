import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/report_model.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  // 🔥 Takip durumu (Başlangıçta false)
  bool isFollowing = false;
  bool isLoading = false; // Butona basınca dönen loading

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
  }

  /// 🔍 Başlangıçta takip edip etmediğini kontrol et
  void _checkIfFollowing() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        // ReportModel içindeki followers listesinde benim ID'm var mı?
        isFollowing = widget.report.followers.contains(user.uid);
      });
    }
  }

  /// 🖱️ Takip Et / Bırak Butonuna Basınca Çalışır
  Future<void> _toggleFollow() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      if (isFollowing) {
        // ❌ Takipten Çık (Listeden sil)
        await _firestore.collection('reports').doc(widget.report.id).update({
          'followers': FieldValue.arrayRemove([user.uid])
        });

        if (mounted) {
          setState(() {
            isFollowing = false;
            // Modeli de güncelleyelim ki ekran tutarlı kalsın
            widget.report.followers.remove(user.uid);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Takipten çıkıldı.")),
          );
        }
      } else {
        // ✅ Takip Et (Listeye ekle)
        await _firestore.collection('reports').doc(widget.report.id).update({
          'followers': FieldValue.arrayUnion([user.uid])
        });

        if (mounted) {
          setState(() {
            isFollowing = true;
            widget.report.followers.add(user.uid);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bildirim takip ediliyor!")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

  // --- Tasarım Kodları (Öncekiyle Aynı) ---

  IconData _getTypeIcon(String type) {
    if (type == "Sağlık") return Icons.health_and_safety;
    return Icons.security;
  }

  Color _getTypeColor(String type) {
    if (type == "Sağlık") return Colors.redAccent;
    return Colors.blueAccent;
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final LatLng reportLocation = LatLng(widget.report.latitude, widget.report.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bildirim Detayı"),
      ),

      // 🔥 YENİ EKLENEN BUTON: TAKİP ET
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : _toggleFollow,
        backgroundColor: isFollowing ? Colors.grey : Colors.deepPurple,
        icon: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Icon(isFollowing ? Icons.bookmark_remove : Icons.bookmark_add),
        label: Text(isFollowing ? "Takipten Çık" : "Takip Et"),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 1. ÜST BİLGİ KARTI
            Container(
              color: _getTypeColor(widget.report.type).withOpacity(0.1),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getTypeColor(widget.report.type).withOpacity(0.2),
                    child: Icon(
                      _getTypeIcon(widget.report.type),
                      color: _getTypeColor(widget.report.type),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.report.type.toUpperCase(),
                          style: TextStyle(
                            color: _getTypeColor(widget.report.type),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.report.status,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(widget.report.createdAt),
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
                  const Text("Konu", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.report.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),

                  const SizedBox(height: 24),

                  const Text("Açıklama", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.report.description, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
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
                      Text("Olay Konumu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(target: reportLocation, zoom: 15),
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        liteModeEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId("report_loc"),
                            position: reportLocation,
                            infoWindow: InfoWindow(title: widget.report.title),
                          ),
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Koordinatlar: ${widget.report.latitude.toStringAsFixed(5)}, ${widget.report.longitude.toStringAsFixed(5)}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),

                  // FAB butonunun altı boş kalsın diye boşluk
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}