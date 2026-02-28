import 'package:flutter/material.dart';
import '../data/global_data.dart';
import '../theme/app_theme.dart';
import '../screens/Detay/detaylar.dart';

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
            child: Text("İzin Ver", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.mosque_rounded, color: AppTheme.primary, size: 24),
          const SizedBox(width: 8),
          Text('E-Cenaze', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textLight)),
        ],
      ),
      actions: [
        InkWell(
          onTap: () => _showPrayerTimes(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded, size: 20, color: AppTheme.primary),
                Text('Namaz Vakitleri', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primary)),
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white12, width: 0.5) : null,
      ),
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