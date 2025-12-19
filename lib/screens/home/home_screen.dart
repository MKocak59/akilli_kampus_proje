import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Rapor detayı importunu kaldırdık çünkü burada artık rapora tıklanmayacak.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Akıllı Kampüs", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Bildirimler Sayfasına Giden Zil Butonu
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),

      // YAN MENÜ (Buradan raporlara gidilebilir)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text("Akıllı Kampüs", style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            _menuButton(context, title: "👤 Profil", route: "/profile"),
            _menuButton(context, title: "🗺️ Harita", route: "/map"),
            _menuButton(context, title: "📋 Bildirim Akışı", route: "/reports"),
            _menuButton(context, title: "📢 Bildirim Oluştur", route: "/report"),
          ],
        ),
      ),

      body: Column(
        children: [
          /// 🔥 1. BÖLÜM: EN SON DUYURU (Banner)
          _buildAnnouncementBanner(),

          /// 2. BÖLÜM: DUYURU GEÇMİŞİ LİSTESİ (Raporlar kalktı, burası geldi)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('announcements') // Artık raporları değil duyuruları çekiyoruz
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Henüz yayınlanmış bir duyuru yok.", style: TextStyle(color: Colors.grey)));
                }

                final announcements = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    var data = announcements[index].data() as Map<String, dynamic>;
                    // Banner'da gösterilen en son duyuruyu listede tekrar göstermeyelim (isteğe bağlı)
                    // if (index == 0) return const SizedBox.shrink();

                    return _buildAnnouncementCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Şikayet Oluştur Butonu (Hızlı erişim için kalabilir veya kaldırabilirsin)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/report');
        },
        label: const Text("Bildirim Oluştur"),
        icon: const Icon(Icons.add_alert),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// 📢 BANNER: En son ve acil duyuru
  Widget _buildAnnouncementBanner() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        String title = data['title'] ?? "Duyuru";
        String message = data['message'] ?? "";

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign, color: Colors.red, size: 32),
                  SizedBox(width: 10),
                  Text(
                    "ÖNEMLİ DUYURU",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.redAccent, height: 20),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 📝 LİSTE KARTI: Geçmiş Duyurular için tasarım
  Widget _buildAnnouncementCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: const Icon(Icons.info_outline, color: Colors.orange),
        ),
        title: Text(
          data['title'] ?? "Başlık Yok",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          data['message'] ?? "",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, {required String title, required String route}) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}