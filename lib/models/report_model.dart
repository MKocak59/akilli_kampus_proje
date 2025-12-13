/// ****************************************************
///  REPORT MODEL
/// ****************************************************
/// Kampüs içinde oluşturulan tüm bildirimlerin
/// Firestore üzerindeki veri modelidir.
/// ****************************************************

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
  final List<String> followers;

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

  /// Firestore'dan gelen veriyi modele çevirir
  factory ReportModel.fromMap(String id, Map<String, dynamic> data) {
    return ReportModel(
      id: id,
      title: data['title'],
      description: data['description'],
      type: data['type'],
      status: data['status'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      createdAt: data['createdAt'].toDate(),
      createdBy: data['createdBy'],
      createdByEmail: data['createdByEmail'],
      followers: List<String>.from(data['followers'] ?? []),
    );
  }

  /// Modeli Firestore'a uygun Map'e çevirir
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
      'followers': followers,
    };
  }
}
