import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../models/report_model.dart';
import '../report/report_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Kullanıcı bilgileri
  Map<String, dynamic>? userData;
  bool isLoading = true;

  /// Bildirim Ayarları
  bool notifySecurity = true;
  bool notifyHealth = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// 📥 Firestore'dan Kullanıcı Verisini Çek
  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userData = doc.data();
            notifySecurity = userData?['notifySecurity'] ?? true;
            notifyHealth = userData?['notifyHealth'] ?? true;
          });
        }
      } catch (e) {
        debugPrint("Kullanıcı verisi çekilemedi: $e");
      }
    }
    setState(() => isLoading = false);
  }

  /// 🚪 Çıkış Yap
  Future<void> _signOut() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  /// 💾 Bildirim Ayarını Güncelle
  Future<void> _updateNotificationSetting(String key, bool value) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      if (key == 'notifySecurity') notifySecurity = value;
      if (key == 'notifyHealth') notifyHealth = value;
    });

    await _firestore.collection('users').doc(user.uid).update({key: value});
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            /// 1. SADELEŞTİRİLMİŞ KULLANICI KARTI (Sadece E-posta ve Rol)
            _buildUserInfoCard(user),

            const SizedBox(height: 24),

            /// 🔥 BURASI EKLENECEK: Sadece Admin ise Buton Göster
            if (userData?['role'] == 'admin') ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin');
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text("YÖNETİCİ PANELİNE GİT"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            /// 2. BİLDİRİM AYARLARI
            const Text(
              "Bildirim Ayarları",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Güvenlik Bildirimleri"),
                    secondary: const Icon(Icons.security, color: Colors.blue),
                    value: notifySecurity,
                    onChanged: (val) => _updateNotificationSetting('notifySecurity', val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text("Sağlık Bildirimleri"),
                    secondary: const Icon(Icons.health_and_safety, color: Colors.red),
                    value: notifyHealth,
                    onChanged: (val) => _updateNotificationSetting('notifyHealth', val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 3. TAKİP EDİLENLER LİSTESİ
            const Text(
              "Takip Ettiklerim",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFollowedReportsList(user?.uid),

            const SizedBox(height: 30),

            /// 4. ÇIKIŞ BUTONU
            ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text("Çıkış Yap"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 👤 SADELEŞTİRİLMİŞ KULLANICI KARTI
  Widget _buildUserInfoCard(User? user) {
    // Rol verisini al, yoksa varsayılan olarak 'User' göster
    String role = userData?['role'] ?? "Kullanıcı";

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Profil İkonu
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(Icons.person, size: 32, color: Colors.deepPurple),
            ),
            const SizedBox(width: 16),

            // Sadece E-posta ve Rol Bilgisi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // E-POSTA
                  Text(
                    user?.email ?? "E-posta Yok",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ROL (Renkli Kutucuk İçinde)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: role.toLowerCase() == "admin"
                          ? Colors.red.shade100
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role.toUpperCase(), // USER veya ADMIN yazar
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: role.toLowerCase() == "admin"
                            ? Colors.red.shade900
                            : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Takip Edilenler Listesi (Değişmedi)
  Widget _buildFollowedReportsList(String? uid) {
    if (uid == null) return const Text("Giriş hatası.");

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('reports')
          .where('followers', arrayContains: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.bookmark_border, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                const Flexible(child: Text("Henüz takip ettiğin bir bildirim yok.")),
              ],
            ),
          );
        }

        final reports = snapshot.data!.docs.map((doc) {
          return ReportModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final report = reports[index];
            return Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: report.type == "Güvenlik" ? Colors.blue.shade50 : Colors.red.shade50,
                  child: Icon(
                    report.type == "Güvenlik" ? Icons.security : Icons.health_and_safety,
                    color: report.type == "Güvenlik" ? Colors.blue : Colors.red,
                    size: 20,
                  ),
                ),
                title: Text(report.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  "${report.status} • ${report.createdAt.day}.${report.createdAt.month}.${report.createdAt.year}",
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailScreen(report: report),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}