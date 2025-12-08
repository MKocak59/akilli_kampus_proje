import 'package:cloud_firestore/cloud_firestore.dart';

///  NotificationModel
/// Bu sınıf Firestore'da saklanan bir bildirimi temsil eder.
/// Bildirim Alanları:
/// - id: Firestore belge ID'si
/// - title: Bildirimin başlığı
/// - description: Bildirimin açıklaması
/// - type: Bildirim türü (enum)
/// - status: Açık,İnceleniyor,Çözüldü
/// - latitude,longitude: Konum bilgisi
/// - imageUrl: Fotoğraf linki (opsiyonel)
/// - createdAt: Oluşturulma zamanı
/// - userId: Bildirimi oluşturan kullanıcı ID'si
/// - followers: Takip eden kullanıcılar listesi

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String type; // Sağlık, Güvenlik, Teknik Arıza, Çevre vb.
  final String status; // Açık,İnceleniyor,Çözüldü
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final DateTime createdAt;
  final String userId;
  final List<String> followers;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.userId,
    this.imageUrl,
    required this.followers,
  });

  /// Firestore’dan model oluşturma
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'Genel',
      status: data['status'] ?? 'Açık',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
    );
  }

  /// Firestore’a kaydedilecek JSON formatı
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'userId': userId,
      'followers': followers,
    };
  }
}
