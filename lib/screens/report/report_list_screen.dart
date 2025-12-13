import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report_model.dart';

///  REPORT LIST SCREEN (Bildirim Akışı)
/// Bu ekran Firestore'daki "reports" koleksiyonunu
/// gerçek zamanlı olarak dinler ve listeler.
///
/// - StreamBuilder kullanır
/// - Yeni bildirim eklenince otomatik güncellenir
/// - Yükleniyor / boş / hata durumları ele alınır


class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📢 Bildirim Akışı"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        /// Firestore'daki reports koleksiyonunu dinliyoruz
        stream: FirebaseFirestore.instance
            .collection("reports")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          /// 1️⃣ Yükleniyor durumu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// 2️⃣ Hata durumu
          if (snapshot.hasError) {
            return const Center(
              child: Text("❌ Bir hata oluştu."),
            );
          }

          /// 3️⃣ Veri yoksa
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Henüz bildirim yok."),
            );
          }

          /// 4️⃣ Veriler geldiyse
          final reports = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final doc = reports[index];
              final report = ReportModel.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    report.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(report.description),
                      const SizedBox(height: 6),
                      Text(
                        "Tür: ${report.type} • Durum: ${report.status}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
