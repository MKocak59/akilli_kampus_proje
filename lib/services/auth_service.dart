import 'package:firebase_auth/firebase_auth.dart';

///  AuthService
/// Bu sınıf, Firebase Authentication ile tüm kimlik doğrulama işlemlerini
/// yöneten servistir.
///
/// Burada yapılanlar:
/// - Kullanıcı girişi (signIn)
/// - Kullanıcı kaydı (signUp)
/// - Şifre sıfırlama maili gönderme (resetPassword)
/// - Çıkış yapma (signOut)
///
/// Projede ekranlardan direkt Firebase çağırmak yerine
/// bu servis üzerinden çağrı yapılır.
/// Bu hem düzen sağlar hem de hata yönetimini kolaylaştırır.

class AuthService {
  // FirebaseAuth örneğini oluşturuyoruz.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 1) Kullanıcı girişi için (email ve şifre)
  /// Eğer giriş başarılı olursa user nesnesi dönecek,hatalı girişse null döner.
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user; // giriş başarılı
    } catch (e) {
      print("⚠️ Giriş Hatası: $e");
      return null;
    }
  }

  /// 2) Kullanıcı kaydı yine email ve şifreyle olacak
  /// Email başka bir hesapta kullanılıyorsa yada şifre uymuyorsa hata verir.
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user; // kayıt başarılı
    } catch (e) {
      print("⚠️ Kayıt Hatası: $e");
      return null;
    }
  }

  /// 3) Şifre sıfırlama maili gönderme
  /// Kullanıcı email adresini girer ve  Firebase den  mail gönderir.
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("⚠️ Şifre Sıfırlama Hatası: $e");
      return false;
    }
  }

  /// 4) Kullanıcı Çıkışı
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
