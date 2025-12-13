import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report_model.dart';

///  CREATE REPORT SCREEN (Yeni Bildirim Oluşturma)
/// Bu ekran kullanıcıların:
/// - Sağlık / Güvenlik bildirimi oluşturmasını
/// - Başlık ve açıklama girmesini
/// - Firestore’a kayıt atmasını sağlar
///
/// Kullanılanlar:
/// - FirebaseAuth → kullanıcı bilgisi
/// - Cloud Firestore → veri kaydı
/// - ReportModel → veri modeli


class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  /// Form controller'ları
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  /// Bildirim türü (default: güvenlik)
  String selectedType = "Güvenlik";

  bool loading = false;

  /// Firebase servisleri
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔥 Bildirim oluşturma fonksiyonu
  Future<void> createReport() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final user = _auth.currentUser;

    if (title.isEmpty || description.isEmpty) {
      _showMessage("Lütfen tüm alanları doldurun.");
      return;
    }

    if (user == null) {
      _showMessage("Kullanıcı oturumu bulunamadı.");
      return;
    }

    setState(() => loading = true);

    /// ReportModel oluştur
    final report = ReportModel(
      id: "", // Firestore otomatik verecek
      title: title,
      description: description,
      type: selectedType,
      status:"Açık",
      latitude: 0.0,   // Şimdilik sabit
      longitude: 0.0,  // Şimdilik sabit
      createdAt: DateTime.now(),
      createdBy: user.uid,
      createdByEmail: user.email ?? "",
      followers: [],

    );

    try {
      await _firestore
          .collection("reports")
          .add(report.toMap());

      _showMessage("✅ Bildirim başarıyla oluşturuldu!");

      await Future.delayed(const Duration(milliseconds: 800));

      Navigator.pop(context);
    } catch (e) {
      _showMessage("❌ Hata oluştu: $e");
    }

    setState(() => loading = false);
  }

  /// Snackbar mesaj fonksiyonu
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Bildirim Oluştur"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              /// Bildirim türü seçimi
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: "Güvenlik", child: Text("Güvenlik")),
                  DropdownMenuItem(value: "Sağlık", child: Text("Sağlık")),
                ],
                onChanged: (value) {
                  setState(() => selectedType = value!);
                },
                decoration: const InputDecoration(
                  labelText: "Bildirim Türü",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              /// Başlık
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Başlık",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              /// Açıklama
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Açıklama",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              /// Gönder butonu
              ElevatedButton(
                onPressed: loading ? null : createReport,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                  "Bildirimi Gönder",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
