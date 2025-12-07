import 'package:flutter/material.dart';

/// **********************************************************************
///  LOGIN SCREEN (Giriş Ekranı)
/// **********************************************************************
/// Bu ekran, kullanıcıların sisteme giriş yapmasını sağlar.
/// Kullanıcı:
///   - E-posta adresini girer
///   - Şifresini girer
///   - “Şifremi unuttum?” bağlantısıyla şifre sıfırlama ekranına gider
///   - “Kayıt Ol” bağlantısıyla kayıt ekranına yönlendirilir
///
/// Bu sayfa henüz Firebase Authentication’a bağlı değildir.
/// Firebase kodları ileride eklenecektir.
/// **********************************************************************

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Kullanıcının girdiği e-posta değerini kontrol etmek için TextEditingController
  final TextEditingController emailController = TextEditingController();

  /// Kullanıcının girdiği şifreyi kontrol etmek için TextEditingController
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Arka plan rengini beyaz yaptık (tasarıma en uygun görünüm)
      backgroundColor: Colors.white,

      /// Sayfanın tüm kenarlarından 24 px boşluk bırakıyoruz
      body: Padding(
        padding: const EdgeInsets.all(24.0),

        child: Center(
          /// Ekran taşarsa (küçük telefonlarda) kaydırılabilmesini sağlar
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Tüm elemanlar genişliği kaplasın
              children: [

                /// --------------------------------------------------------------
                ///  BAŞLIK — “Akıllı Kampüs”
                /// --------------------------------------------------------------
                const Text(
                  "Akıllı Kampüs",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                /// --------------------------------------------------------------
                ///  E-POSTA GİRİŞ ALANI
                /// --------------------------------------------------------------
                /// controller: kullanıcı ne yazarsa bu controller üzerinden okunur.
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "E-posta",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// --------------------------------------------------------------
                ///  ŞİFRE GİRİŞ ALANI
                /// --------------------------------------------------------------
                /// obscureText: true → Şifre yazılırken gizlenir.
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Şifre",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                /// --------------------------------------------------------------
                ///  ŞİFREMİ UNUTTUM BAĞLANTISI
                ///  Kullanıcıyı /reset rotasına yönlendirir.
                /// --------------------------------------------------------------
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/reset');
                    },
                    child: const Text(
                      "Şifremi unuttum?",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// --------------------------------------------------------------
                ///  GİRİŞ YAP BUTONU
                /// --------------------------------------------------------------
                /// Şu an sadece konsola mesaj yazar.
                /// Firebase Authentication entegrasyonu ileride eklenecek.
                ElevatedButton(
                  onPressed: () {
                    print("🔐 Giriş Yap tıklandı — Firebase login buraya eklenecek");
                    print("E-posta: ${emailController.text}");
                    print("Şifre: ${passwordController.text}");
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurpleAccent.withOpacity(0.15),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Giriş Yap",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 20),

                /// --------------------------------------------------------------
                ///  KAYIT OLMAYA YÖNLENDİREN SATIR
                /// --------------------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Hesabın yok mu?"),
                    const SizedBox(width: 5),

                    /// “Kayıt Ol” metnine tıklanınca /register rotasına gider
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Kayıt Ol",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
