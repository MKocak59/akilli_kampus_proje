import 'package:flutter/material.dart';

/// Uygulamanın ana sayfası (bildirimlerin ve haritanın geleceği yer)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akıllı Kampüs - Ana Sayfa'),
      ),
      body: const Center(
        child: Text('Home Screen - Buraya harita, bildirimler vb. gelecek'),
      ),
    );
  }
}
