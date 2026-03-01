import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';

class MosqueDetailScreen extends StatelessWidget {
  final Mosque mosque;
  const MosqueDetailScreen({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(mosque.name),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Cami Resmi (Placeholder veya URL)
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[800],
              child: mosque.imageUrls.isNotEmpty && mosque.imageUrls.first.startsWith('http')
                  ? Image.network(
                      mosque.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100),
                    )
                  : const Icon(Icons.image, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mosque.name,
                    style: TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${mosque.neighborhood}, ${mosque.district}, ${mosque.city}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tarihçe',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mosque.history,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}