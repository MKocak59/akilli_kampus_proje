import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';


///  LOGIN SCREEN
/// Bu ekranda:
/// - Kullanıcı giriş yapabilir
/// - Şifre sıfırlama ekranına yönlenebilir
/// - Kayıt ekranına geçiş yapılabilir
/// - Firebase hata kodları Türkçeye çevrilir
/// - Şık yükleniyor animasyonu bulunur


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLoading = false; // Buton animasyonu

  /// Firebase hata kodlarını Türkçeye çeviren fonksiyon
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
        return "Bu e-posta adresiyle kayıtlı bir kullanıcı bulunamadı.";
      case "wrong-password":
        return "Şifre yanlış! Lütfen tekrar deneyin.";
      case "invalid-email":
        return "Geçersiz e-posta formatı.";
      case "too-many-requests":
        return "Çok fazla deneme yaptınız. Bir süre sonra tekrar deneyin.";
      case "network-request-failed":
        return "İnternet bağlantı hatası.";
      default:
        return "Bir hata oluştu. (${e.code})";
    }
  }

  /// Kullanıcı giriş fonksiyonu
  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    /// Basit kontroller
    if (email.isEmpty || password.isEmpty) {
      showMessage("Lütfen tüm alanları doldurun.");
      return;
    }

    /// E-posta format kontrolü
    if (!email.contains("@") || !email.contains(".")) {
      showMessage("Lütfen geçerli bir e-posta adresi girin.");
      return;
    }

    setState(() => isLoading = true);

    try {
      User? user = await _authService.signIn(email, password);

      setState(() => isLoading = false);

      if (user != null) {
        showMessage("Giriş başarılı!");

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        showMessage("e-posta veya şifre hatalı.");
      }
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      showMessage(getErrorMessage(e));
    }
  }

  /// Snackbar mesaj gösterme fonksiyonu
  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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

                /// Başlık
                const Text(
                  "Akıllı Kampüs",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                /// E-posta alanı
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "E-posta",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// Şifre alanı
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Şifre",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                /// Şifremi unuttum linki
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/reset'),
                    child: const Text("Şifremi unuttum?", style: TextStyle(color: Colors.blue)),
                  ),
                ),

                const SizedBox(height: 20),

                /// GİRİŞ BUTONU
                ElevatedButton(
                  onPressed: isLoading ? null : loginUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.deepPurple.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Giriş Yap", style: TextStyle(fontSize: 18)),
                ),

                const SizedBox(height: 20),

                /// Kayıt ekranına geçiş
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Hesabın yok mu?"),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        "Kayıt Ol",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
