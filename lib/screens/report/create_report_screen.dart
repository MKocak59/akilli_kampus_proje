import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // 📍 BU EKLENDİ
import '../../models/report_model.dart';
import 'location_selection_screen.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedType = "Güvenlik";
  bool loading = false;

  // Seçilen Konum Verileri
  double? selectedLat;
  double? selectedLng;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Haritadan Seçme Fonksiyonu
  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationSelectionScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedLat = result.latitude;
        selectedLng = result.longitude;
      });
    }
  }

  // 📍 Mevcut Konumu Alma Fonksiyonu
  Future<void> _getCurrentLocation() async {
    setState(() => loading = true);

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMessage("Konum servisi kapalı.");
      setState(() => loading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMessage("Konum izni reddedildi.");
        setState(() => loading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showMessage("Konum izni kalıcı olarak engelli.");
      setState(() => loading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        selectedLat = position.latitude;
        selectedLng = position.longitude;
        loading = false;
      });
      _showMessage("📍 Mevcut konum alındı!");
    } catch (e) {
      _showMessage("Hata: $e");
      setState(() => loading = false);
    }
  }

  Future<void> createReport() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final user = _auth.currentUser;

    if (title.isEmpty || description.isEmpty) {
      _showMessage("Lütfen başlık ve açıklama girin.");
      return;
    }

    if (selectedLat == null || selectedLng == null) {
      _showMessage("Lütfen bir konum belirleyin.");
      return;
    }

    if (user == null) {
      _showMessage("Oturum hatası.");
      return;
    }

    setState(() => loading = true);

    final report = ReportModel(
      id: "",
      title: title,
      description: description,
      type: selectedType,
      status: "Açık",
      latitude: selectedLat!,
      longitude: selectedLng!,
      createdAt: DateTime.now(),
      createdBy: user.uid,
      createdByEmail: user.email ?? "",
      followers: [],
    );

    try {
      await _firestore.collection("reports").add(report.toMap());
      _showMessage("✅ Bildirim başarıyla gönderildi!");
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showMessage("Hata: $e");
    }

    if (mounted) setState(() => loading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Bildirim Oluştur")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. TÜR SEÇİMİ
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: "Güvenlik", child: Text("Güvenlik")),
                  DropdownMenuItem(value: "Sağlık", child: Text("Sağlık")),
                ],
                onChanged: (val) => setState(() => selectedType = val!),
                decoration: const InputDecoration(
                  labelText: "Bildirim Türü",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),

              // 2. BAŞLIK
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Başlık",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),

              // 3. AÇIKLAMA
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Açıklama",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 24),

              // 4. KONUM SEÇİM ALANI (YENİ KISIM BURASI)
              const Text(
                "Konum Bilgisi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  // SOL BUTON: MEVCUT KONUM
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text("Mevcut Konum", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade900,
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // SAĞ BUTON: HARİTADAN SEÇ
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickLocation,
                      icon: const Icon(Icons.map),
                      label: const Text("Haritadan Seç", style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.orange.shade50,
                        foregroundColor: Colors.orange.shade900,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // KONUM BİLGİSİ KUTUSU (GERİ BİLDİRİM)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selectedLat == null
                      ? Colors.grey.shade100
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedLat == null
                        ? Colors.grey.shade300
                        : Colors.green.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedLat == null
                          ? Icons.location_off
                          : Icons.check_circle,
                      color: selectedLat == null ? Colors.grey : Colors.green,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedLat == null
                            ? "Henüz konum seçilmedi."
                            : "Seçilen:\n${selectedLat!.toStringAsFixed(5)}, ${selectedLng!.toStringAsFixed(5)}",
                        style: TextStyle(
                          color: selectedLat == null
                              ? Colors.grey.shade700
                              : Colors.green.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 5. GÖNDER BUTONU
              ElevatedButton(
                onPressed: loading ? null : createReport,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16)),
                child: loading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("BİLDİRİMİ GÖNDER",
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}