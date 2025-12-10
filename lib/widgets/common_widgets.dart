import 'package:flutter/material.dart';
import '../data/global_data.dart';
import '../screens/detail/detail_screens.dart'; // PrayerTimesScreen burada

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  void _showPrayerTimes(BuildContext context) {
    if (!GlobalData.isLocationPermissionGranted) {
      _showPermissionDeniedDialog(context);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PrayerTimesScreen()));
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("Konum İzni Gerekli", style: TextStyle(color: Colors.white)),
        content: const Text("Bu özelliği kullanabilmek için konum izni vermelisiniz.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Kapat", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              GlobalData.saveLocationPermission(true);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konum izni verildi.")));
            },
            child: const Text("İzin Ver", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Row(
        children: [
          Icon(Icons.mosque, color: Color(0xFF4CAF50)),
          SizedBox(width: 8),
          Text('E-Cenaze', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        InkWell(
          onTap: () => _showPrayerTimes(context),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, size: 18, color: Colors.orangeAccent),
                Text('Namaz Vakitleri', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CustomSearchBar({super.key, required this.hintText, this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25.0)),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          icon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}