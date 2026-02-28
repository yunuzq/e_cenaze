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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          border: isDark ? Border(top: BorderSide(color: Colors.white12, width: 0.5)) : null,
        ),
        child: SafeArea(
          child: _CustomBottomNav(
            selectedIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

class _CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _NavItem(icon: Icons.home_rounded, iconOutlined: Icons.home_outlined, label: 'Ana Sayfa', index: 0, selectedIndex: selectedIndex, onTap: onTap),
        _NavItem(icon: Icons.mosque_rounded, iconOutlined: Icons.mosque_outlined, label: 'Camiler', index: 1, selectedIndex: selectedIndex, onTap: onTap),
        _NavItem(icon: Icons.person_rounded, iconOutlined: Icons.person_outline_rounded, label: 'Hesap', index: 2, selectedIndex: selectedIndex, onTap: onTap),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      isSelected ? icon : iconOutlined,
                      key: ValueKey<bool>(isSelected),
                      size: 26,
                      color: isSelected ? AppTheme.primary : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}