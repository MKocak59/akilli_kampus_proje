import 'package:flutter/material.dart';
import '../../models/report_model.dart'; // Model dosyanın yolu neyse onu yazmalısın

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report; // Tıklanan bildirimin tüm verisi burada

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.title), // Başlıkta bildirimin adı yazar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Detay Sayfası",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Seçilen ID: ${report.id}"), // Test amaçlı ID'yi görelim
            Text("Durum: ${report.status}"),
          ],
        ),
      ),
    );
  }
}