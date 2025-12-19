import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Scaffold(body: Center(child: Text("Giriş yapmalısınız.")));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bildirimler"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🔥 Sadece bu kullanıcıya ait bildirimleri getir, en yenisi en üstte
        stream: FirebaseFirestore.instance
            .collection('user_notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("Henüz bir bildiriminiz yok.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notif = notifications[index].data() as Map<String, dynamic>;
              final bool isRead = notif['isRead'] ?? false;
              final String docId = notifications[index].id;

              return Container(
                color: isRead ? Colors.white : Colors.blue.shade50, // Okunmamışsa mavi tonlu
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(Icons.notifications, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    notif['title'] ?? "Bildirim",
                    style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notif['message'] ?? ""),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(notif['createdAt']), // Tarih formatı
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Tıklanınca "Okundu" olarak işaretle (Rengi beyaza döner)
                    FirebaseFirestore.instance
                        .collection('user_notifications')
                        .doc(docId)
                        .update({'isRead': true});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Tarihi güzel gösteren minik yardımcı fonksiyon
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final date = timestamp.toDate();
    return "${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}