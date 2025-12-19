import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final String status;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String createdBy;
  final String createdByEmail;
  final List<String> followers; // 🔥 Bu listenin olduğundan emin olmalıyız

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.createdBy,
    required this.createdByEmail,
    required this.followers,
  });

  // 📥 Firestore'dan veri çekerken (Burada followers'ı okuması ŞART)
  factory ReportModel.fromMap(String id, Map<String, dynamic> map) {
    return ReportModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
      createdByEmail: map['createdByEmail'] ?? '',
      // 🔥 İŞTE KRİTİK NOKTA BURASI:
      followers: List<String>.from(map['followers'] ?? []),
    );
  }

  // 📤 Firestore'a veri yazarken
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
      'followers': followers, // Burayı da unutmamak lazım
    };
  }
}