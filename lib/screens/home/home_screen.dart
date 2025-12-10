import 'package:flutter/material.dart';
import '../../data/global_data.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';
import '../detail/detail_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomSearchBar(hintText: 'İsim, Cami veya Şehir Ara...'),
          Expanded(
            child: ListView.builder(
              itemCount: GlobalData.people.length,
              itemBuilder: (context, index) {
                final person = GlobalData.people[index];
                return _PersonCard(person: person);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Person person;
  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFC8E6C9).withOpacity(0.8),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text('Cenaze: ${person.funeralTime} ${person.prayerInfo}', style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('${person.mosqueName}, ${person.city}', style: TextStyle(fontSize: 12, color: Colors.grey[800]), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PersonDetailScreen(person: person))),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), foregroundColor: Colors.white),
            child: const Text('Ayrıntılar'),
          ),
        ],
      ),
    );
  }
}