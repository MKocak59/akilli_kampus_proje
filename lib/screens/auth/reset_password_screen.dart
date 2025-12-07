import 'package:flutter/material.dart';

/// **********************************************************************
///  RESET PASSWORD SCREEN (Şifre Sıfırlama Ekranı)
/// **********************************************************************
/// Bu ekran, şifresini unutan kullanıcıların e-posta adreslerini girerek
/// "Şifre sıfırlama maili" talep etmelerini sağlar.
///
/// Firebase Authentication kullanıldığında:
///   FirebaseAuth.instance.sendPasswordResetEmail(email: ...)
/// fonksiyonu ile kullanıcıya e-posta gönderilecektir.
///
/// Şu anki hali taslak ekran tasarımıdır, Firebase işlemleri daha sonra
/// AuthService içerisine eklenecektir.
/// **********************************************************************

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  /// Kullanıcının yazdığı e-posta değerini almak için controller
  final TextEditingController emailController = TextEditingController();

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

                /// --------------------------------------------------------------
                ///  BAŞLIK — ŞİFRE SIFIRLA
                /// --------------------------------------------------------------
                const Text(
                  "Şifre Sıfırla",
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
                /// Kullanıcı şifre sıfırlama maili almak için e-posta adresini girer.
                /// Firebase tarafında sadece e-posta yeterlidir.
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "E-posta",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                /// --------------------------------------------------------------
                ///  ŞİFRE SIFIRLAMA BUTONU
                /// --------------------------------------------------------------
                /// Şu anda sadece mesaj yazdırır.
                /// Firebase bağlanınca AuthService içindeki fonksiyon çağrılacak.
                ElevatedButton(
                  onPressed: () {
                    print("📩 Şifre sıfırlama maili gönderilecek → ${emailController.text}");
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
                    "Mail Gönder",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 20),

                /// --------------------------------------------------------------
                ///  GİRİŞ EKRANINA GERİ DÖNÜŞ
                /// --------------------------------------------------------------
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
