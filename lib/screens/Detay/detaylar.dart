import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';

// --- CENAZE DETAY ---
class PersonDetailScreen extends StatelessWidget {
  final Person person;
  const PersonDetailScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(person.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vefat Bilgileri', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.calendar_today, 'Vefat Tarihi:', person.date),
            
            const SizedBox(height: 24),
            Text('Cenaze Bilgileri', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            const SizedBox(height: 16),
            // CENAZE SAATİ GÖSTERİMİ
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.tintAvatarBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.primary)),
              child: _buildDetailRow(Icons.access_time_filled, 'Cenaze Saati:', '${person.funeralTime} ${person.prayerInfo}'),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.mosque, 'Cami:', person.mosqueName),
            _buildDetailRow(Icons.location_on, 'Şehir:', person.city),
            _buildDetailRow(Icons.place, 'Defin Yeri:', person.burialPlace),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey), const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

// --- CAMİ DETAY (Haritasız) ---
class MosqueDetailScreen extends StatelessWidget {
  final Mosque mosque;
  const MosqueDetailScreen({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: Text(mosque.name), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(height: 250, width: double.infinity, color: Colors.grey[800], child: const Icon(Icons.image, size: 100)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mosque.name, style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('${mosque.neighborhood}, ${mosque.district}, ${mosque.city}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 20),
                  const Text('Tarihçe', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(mosque.history, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NAMAZ VAKİTLERİ ---
class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Namaz Vakitleri")), body: const Center(child: Text("Vakitler...")));
  }
}