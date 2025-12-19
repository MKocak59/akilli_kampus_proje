import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/report_model.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _announceTitleController = TextEditingController();
  final TextEditingController _announceBodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 2 Sekmeli yapı için kontrolcü (Bildirim Yönetimi - Duyuru)
    _tabController = TabController(length: 2, vsync: this);
  }

  /// 🚦 Durum Güncelleme Fonksiyonu
  void _showStatusDialog(ReportModel report) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Durumu Güncelle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _statusButton(report, "Açık", Colors.red),
              _statusButton(report, "İnceleniyor", Colors.orange),
              _statusButton(report, "Çözüldü", Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _statusButton(ReportModel report, String status, Color color) {
    return ListTile(
      leading: Icon(Icons.circle, color: color),
      title: Text(status),
      onTap: () async {
        Navigator.pop(context); // Dialog'u kapat

        try {
          // 1. Durumu Güncelle
          await _firestore.collection('reports').doc(report.id).update({'status': status});

          DocumentSnapshot freshDoc = await _firestore.collection('reports').doc(report.id).get();
          List<dynamic> freshFollowers = freshDoc.get('followers') ?? [];

          // 2. Eğer takipçi varsa bildirim gönder
          if (freshFollowers.isNotEmpty) {
            WriteBatch batch = _firestore.batch();

            for (var userId in freshFollowers) {
              DocumentReference notifRef = _firestore.collection('user_notifications').doc();
              batch.set(notifRef, {
                'userId': userId,
                'title': 'Bildirim Güncellemesi',
                'message': '"${report.title}" bildiriminin durumu "$status" olarak güncellendi.',
                'isRead': false,
                'createdAt': FieldValue.serverTimestamp(),
                'reportId': report.id,
              });
            }
            await batch.commit();
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Durum güncellendi. (${freshFollowers.length} kişiye bildirim gitti)")),
            );
          }

        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: $e")),
          );
        }
      },
    );
  }

  /// 📢 Duyuru Yayınlama Fonksiyonu
  Future<void> _sendAnnouncement() async {
    if (_announceTitleController.text.isEmpty || _announceBodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen başlık ve mesaj girin.")));
      return;
    }

    try {
      await _firestore.collection('announcements').add({
        'title': _announceTitleController.text.trim(),
        'message': _announceBodyController.text.trim(),
        'createdAt': DateTime.now(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
      });

      _announceTitleController.clear();
      _announceBodyController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("📢 Duyuru tüm kullanıcılara yayınlandı!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yönetici Paneli"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: "Bildirim Yönetimi"),
            Tab(icon: Icon(Icons.campaign), text: "Acil Duyuru"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// 1. SEKME: BİLDİRİM LİSTESİ VE YÖNETİMİ
          _buildReportManagementTab(),

          /// 2. SEKME: DUYURU YAYINLAMA
          _buildAnnouncementTab(),
        ],
      ),
    );
  }

  // --- 1. SEKME TASARIMI ---
  Widget _buildReportManagementTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('reports').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Bildirim yok."));

        final reports = snapshot.data!.docs.map((doc) {
          return ReportModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: report.status == "Çözüldü" ? Colors.green.shade100 : Colors.red.shade100,
                  child: Icon(
                    report.status == "Çözüldü" ? Icons.check : Icons.priority_high,
                    color: report.status == "Çözüldü" ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${report.type} • ${report.status}"),
                    Text(
                      report.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  onPressed: () => _showStatusDialog(report),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- 2. SEKME TASARIMI ---
  Widget _buildAnnouncementTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Icon(Icons.notification_important, size: 80, color: Colors.orange),
          const SizedBox(height: 20),
          const Text(
            "Acil Durum / Genel Duyuru",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Buradan yapacağınız duyurular tüm kullanıcılara gösterilecektir.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _announceTitleController,
            decoration: const InputDecoration(
              labelText: "Duyuru Başlığı",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _announceBodyController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Duyuru Mesajı",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.message),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendAnnouncement,
              icon: const Icon(Icons.send),
              label: const Text("HERKESE YAYINLA"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}