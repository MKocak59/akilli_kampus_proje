import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report_model.dart';

/// ****************************************************
///  REPORT LIST SCREEN (Bildirim Akışı)
/// ****************************************************
/// Bu ekran:
/// - Firestore’daki "reports" koleksiyonunu dinler
/// - Bildirimleri kronolojik listeler
/// - Tür filtresi
/// - Sadece açık olanlar filtresi
/// - Başlık + açıklama araması yapar
/// ****************************************************

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  /// 🔍 Arama metni
  String searchQuery = "";

  /// 🔽 Seçilen bildirim türü
  String selectedType = "Tümü";

  /// ☑️ Sadece açık olanlar
  bool showOnlyOpen = false;

  /// Bildirim türüne göre ikon
  IconData getTypeIcon(String type) {
    switch (type) {
      case "Güvenlik":
        return Icons.security;
      case "Sağlık":
        return Icons.health_and_safety;
      default:
        return Icons.report;
    }
  }

  /// Bildirim durumuna göre renk
  Color getStatusColor(String status) {
    switch (status) {
      case "Açık":
        return Colors.redAccent;
      case "İnceleniyor":
        return Colors.orange;
      case "Çözüldü":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📢 Bildirim Akışı"),
      ),

      body: Column(
        children: [
          /// 🔍 ARAMA KUTUSU
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: "Başlık veya açıklama ara",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          /// 🔽 TÜR FİLTRESİ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: selectedType,
              items: const [
                DropdownMenuItem(value: "Tümü", child: Text("Tümü")),
                DropdownMenuItem(value: "Güvenlik", child: Text("Güvenlik")),
                DropdownMenuItem(value: "Sağlık", child: Text("Sağlık")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Bildirim Türü",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          /// ☑️ SADECE AÇIK OLANLAR
          CheckboxListTile(
            title: const Text("Sadece açık olanlar"),
            value: showOnlyOpen,
            onChanged: (value) {
              setState(() {
                showOnlyOpen = value!;
              });
            },
          ),

          /// 📢 BİLDİRİM LİSTESİ
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("reports")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                /// ⏳ Yükleniyor
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                /// ❌ Hata
                if (snapshot.hasError) {
                  return const Center(child: Text("❌ Bir hata oluştu."));
                }

                /// 📭 Veri yok
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Henüz bildirim yok."));
                }

                /// 🔥 Firestore → Model
                final allReports = snapshot.data!.docs.map((doc) {
                  return ReportModel.fromMap(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  );
                }).toList();

                /// 🔍 FİLTRE + ARAMA
                final filteredReports = allReports.where((report) {
                  final matchesType =
                      selectedType == "Tümü" || report.type == selectedType;

                  final matchesStatus =
                      !showOnlyOpen || report.status == "Açık";

                  final matchesSearch =
                      report.title.toLowerCase().contains(searchQuery) ||
                          report.description.toLowerCase().contains(searchQuery);

                  return matchesType && matchesStatus && matchesSearch;
                }).toList();

                /// 📭 Filtre sonrası boş
                if (filteredReports.isEmpty) {
                  return const Center(
                    child: Text("Filtreye uygun bildirim bulunamadı."),
                  );
                }

                /// 📋 LİSTE
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        /// 🔹 TÜR İKONU
                        leading: Icon(
                          getTypeIcon(report.type),
                          color: Colors.deepPurple,
                        ),

                        /// 🔹 BAŞLIK
                        title: Text(
                          report.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        /// 🔹 AÇIKLAMA + TARİH + DURUM
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(report.description),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  "${report.createdAt.day}.${report.createdAt.month}.${report.createdAt.year}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                    getStatusColor(report.status),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    report.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        trailing:
                        const Icon(Icons.arrow_forward_ios, size: 14),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
