import 'package:flutter/material.dart';
import 'package:akilli_kampus_proje/services/auth_service.dart';
///  RESET PASSWORD SCREEN (Şifre Sıfırlama Ekranı)
/// Bu ekran, şifresini unutan kullanıcıların e-posta adreslerini girerek
/// "Şifre sıfırlama maili" talep etmelerini sağlar.
/// Firebase Authentication ile:
///   FirebaseAuth.instance.sendPasswordResetEmail(email: ...)
/// fonksiyonu ile kullanıcıya e-posta gönderilecektir.

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  /// Kullanıcının yazdığı e-posta değerini almak için kontroller
  final TextEditingController emailController = TextEditingController();

  bool loading = false;

  /// Firebase hata kodlarını Türkçeye çeviren fonksiyon
  String getErrorMessage(String code) {
    switch (code) {
      case "user-not-found":
        return "Bu e-posta ile kayıtlı kullanıcı bulunamadı.";
      case "invalid-email":
        return "Geçersiz e-posta adresi.";
      case "network-request-failed":
        return "İnternet bağlantı hatası.";
      default:
        return "Bir hata oluştu. ($code)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.all(24.0),

        child: Center(
          child: SingleChildScrollView(

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                ///  BAŞLIK — ŞİFRE SIFIRLA-
                const Text(
                  "Şifreyi Sıfırla",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                ///  E-POSTA GİRİŞ ALANI
                /// Kullanıcı şifre sıfırlama maili almak için e-posta adresini girer.
                /// Firebase tarafında sadece e-posta yeterli oluyor
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "E-posta",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                ///  ŞİFRE SIFIRLAMA BUTONU
                /// Firebase ile AuthService içindeki fonksiyon çağrılacak.
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                    if (emailController.text.trim().isEmpty) {
                      _showMessage(context, "Lütfen e-posta adresi giriniz.");
                      return;
                    }
                    /// basit email format kontrolü
                    if (!emailController.text.contains("@")) {
                      _showMessage(context, "Lütfen geçerli bir e-posta girin.");
                      return;
                    }

                    setState(() => loading = true);

                    bool result = await AuthService()
                        .resetPassword(emailController.text.trim());

                    setState(() => loading = false);

                    if (result) {
                      _showMessage(
                          context,
                          "📩 Şifre sıfırlama maili gönderildi!\n"
                              "Lütfen gelen kutunuzu kontrol edin."
                      );
                    } else {
                      _showMessage(
                          context,
                          "❌ İşlem başarısız! E-posta adresini kontrol edin."
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurpleAccent.withOpacity(0.15),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Mail Gönder",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 20),

                ///  GİRİŞ EKRANINA GERİ DÖNÜŞ İÇİN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Giriş ekranına dönmek için"),
                    const SizedBox(width: 5),

                    GestureDetector(
                      onTap: () {
                        /// Navigator.pushNamed ile '/login' route'una gider
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Tıklayın",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
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
/// Basit mesaj gösteren fonksiyon (AlertDialog yerine SnackBar)
void _showMessage(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

