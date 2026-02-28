import 'package:flutter/material.dart';
import 'data/global_data.dart';
import 'theme/app_theme.dart';
import 'screens/Giris Ekranlari/giris.dart';
import 'screens/Anasayfa/anasayfa.dart';
import 'screens/Cami/Cami_Ekrani.dart';
import 'screens/Hesap/account_screens.dart';

Future<void> main() async {
  runApp(const ECenazeApp());
}

class ECenazeApp extends StatelessWidget {
  const ECenazeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: GlobalData.themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'E-Cenaze',
          darkTheme: _buildDarkTheme(),
          theme: _buildLightTheme(),
          themeMode: currentMode,
          home: const LoginPage(),
        );
      },
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppTheme.primary,
      scaffoldBackgroundColor: AppTheme.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppTheme.primary,
        secondary: AppTheme.primary,
        surface: AppTheme.cardDark,
      ),
      cardTheme: CardThemeData(
        color: AppTheme.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      useMaterial3: true,
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppTheme.primary,
      scaffoldBackgroundColor: AppTheme.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppTheme.primary,
        secondary: AppTheme.primary,
        surface: AppTheme.cardLight,
        onSurface: AppTheme.textLight,
      ),
      cardTheme: CardThemeData(
        color: AppTheme.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textLight),
        titleTextStyle: TextStyle(color: AppTheme.textLight, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      useMaterial3: true,
    );
  }
}

// --- ANA EKRAN (TAB BAR) ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Sayfalar Listesi
  final List<Widget> _screens = [
    const HomeScreen(),      // Ana Sayfa
    const MosquesScreen(),   // Camiler (Harita burada)
    const AccountScreen()    // Hesap
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          border: isDark ? Border(top: BorderSide(color: Colors.white12, width: 0.5)) : null,
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Ana Sayfa'),
              BottomNavigationBarItem(icon: Icon(Icons.mosque_rounded), label: 'Camiler'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Hesap'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}