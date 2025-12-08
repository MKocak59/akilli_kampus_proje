import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:akilli_kampus_proje/services/auth_service.dart';

///  HOME SCREEN (Ana Sayfa)
/// Kullanıcı giriş yaptıktan sonra yönlendirilen ekrandır.
/// Bu ekranda
/// - Kullanıcının email adresi gösterilir.
/// - Menü butonları burada bulunur.
/// - Bildirim akışı / harita / bildirim oluşturma / profil gibi
///   diğer ekranlara yönlendirme yapılır.
/// - Üst sağ köşede çıkış butonu yer alır.

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

            /// KULLANICI KARŞILAMA METNİ
            Text(
              "Hoş geldin,\n${user?.email ?? 'Kullanıcı'}",
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
              route: "/home", // yönlendirme yapılmasını sağlar
            ),

            _menuButton(
              context,
              title: "🗺️ Harita",
              route: "/map",
            ),

            _menuButton(
              context,
              title: "➕ Yeni Bildirim Oluştur",
              route: "/report", // Bildirim oluşturma ekranı
            ),

            _menuButton(
              context,
              title: "👤 Profil",
              route: "/profile", // Profil ekranı
            ),
          ],
        ),
      ),
    );
  }

  ///  Menü Butonu Oluşturan Yardımcı Widget
  Widget _menuButton(BuildContext context,
      {required String title, required String route}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
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

