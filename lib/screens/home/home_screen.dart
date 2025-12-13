import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:akilli_kampus_proje/services/auth_service.dart';

///  HOME SCREEN (Ana Sayfa)
/// Kullanıcı giriş yaptıktan sonra yönlendirilen ekrandır.
/// Bu ekranda
/// - Kullanıcının email adresi gösterilir.
/// - Menü butonları bulunur.
/// - Bildirim akışı / harita / bildirim oluşturma / profil gibi ekranlara geçilir.
/// - Sağ üstte çıkış var

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// Firebase üzerinden o anda giriş yapan kullanıcıyı alıyoruz
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Akıllı Kampüs"),
        actions: [
          /// ÇIKIŞ İKONU
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 📌 Hoş geldin yazısı — satır kaymasını önledik
            Text(
              "Hoş geldin, ${user?.email ?? 'Kullanıcı'}",
              maxLines: 1, // ✔ Tek satır ile sınırla
              overflow: TextOverflow.ellipsis, // ✔ Taşınca ... ile göster
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            /// ANA MENÜ BUTONLARI
            _menuButton(
              context,
              title: "📢 Bildirim Akışı",
              route: "/reports",
            ),

            _menuButton(
              context,
              title: "🗺️ Harita",
              route: "/map",
            ),

            _menuButton(
              context,
              title: "➕ Yeni Bildirim Oluştur",
              route: "/report",
            ),

            _menuButton(
              context,
              title: "👤 Profil",
              route: "/profile",
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 Menü Butonu Oluşturan Widget
  Widget _menuButton(BuildContext context,
      {required String title, required String route}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },

        /// ⭐ YENİ BUTON TASARIMI BURADA
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          backgroundColor: Colors.deepPurpleAccent.withOpacity(0.1),
          foregroundColor: Colors.black87,
          elevation: 0, // gölgeyi kaldır
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        child: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
