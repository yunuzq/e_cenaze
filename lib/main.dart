import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          scrollBehavior: const _BouncingScrollBehavior(),
          home: const LoginPage(),
        );
      },
    );
  }

  ThemeData _buildDarkTheme() {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      fontFamily: GoogleFonts.inter().fontFamily,
      brightness: Brightness.dark,
      primaryColor: AppTheme.primary,
      scaffoldBackgroundColor: AppTheme.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppTheme.primary,
        secondary: AppTheme.primary,
        surface: AppTheme.cardDark,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700),
        displayMedium: baseTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
        displaySmall: baseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
        bodySmall: baseTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),
        labelMedium: baseTextTheme.labelMedium?.copyWith(fontWeight: FontWeight.w400),
        labelSmall: baseTextTheme.labelSmall?.copyWith(fontWeight: FontWeight.w400),
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
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.inter(textStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      useMaterial3: true,
    );
  }

  ThemeData _buildLightTheme() {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      fontFamily: GoogleFonts.inter().fontFamily,
      brightness: Brightness.light,
      primaryColor: AppTheme.primary,
      scaffoldBackgroundColor: AppTheme.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppTheme.primary,
        secondary: AppTheme.primary,
        surface: AppTheme.cardLight,
        onSurface: AppTheme.textLight,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700),
        displayMedium: baseTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
        displaySmall: baseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
        bodySmall: baseTextTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),
        labelMedium: baseTextTheme.labelMedium?.copyWith(fontWeight: FontWeight.w400),
        labelSmall: baseTextTheme.labelSmall?.copyWith(fontWeight: FontWeight.w400),
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
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textLight),
        titleTextStyle: GoogleFonts.inter(textStyle: TextStyle(color: AppTheme.textLight, fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      useMaterial3: true,
    );
  }
}

class _BouncingScrollBehavior extends ScrollBehavior {
  const _BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
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
  int _previousIndex = 0;

  // Sayfalar Listesi
  final List<Widget> _screens = [
    const HomeScreen(),      // Ana Sayfa
    const MosquesScreen(),   // Camiler (Harita burada)
    const AccountScreen()    // Hesap
  ];

  void _onItemTapped(int index) {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final goingRight = _selectedIndex > _previousIndex;
    final slideOffset = goingRight ? 0.05 : -0.05;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(slideOffset, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
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
                Icon(
                  isSelected ? icon : iconOutlined,
                  size: 26,
                  color: isSelected ? AppTheme.primary : Colors.grey,
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