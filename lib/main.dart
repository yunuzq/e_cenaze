import 'package:flutter/material.dart';
import 'data/global_data.dart';
import 'screens/Giris Ekranlari/giris.dart';        // Giriş Ekranı
import 'screens/Anasayfa/anasayfa.dart';       // Ana Sayfa
import 'screens/Cami/Cami_Ekrani.dart';  // Camiler ve Harita Ekranı
import 'screens/Hesap/account_screens.dart'; // Hesap Ekranı
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  // EKLENDİ: Uygulama başlamadan önce asenkron işlemlerin (SharedPreferences vb.) 
  // sorunsuz çalışması için motoru başlatıyoruz.
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // AÇILDI: İmam panelinden girdiğin geçmiş cenaze verilerinin ve 
  // ayarların telefon hafızasından okunmasını sağlar.
  await GlobalData.loadData(); 

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
          
          // --- TÜRKÇE DİL DESTEĞİ ---
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // EKLENDİ: Saatin, tarihin ve uyarıların Türkçe olmasını sağlayan kısım.
          supportedLocales: const [
            Locale('tr', 'TR'), 
          ],

          // --- KOYU TEMA ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF1E7228),
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1E7228),
              secondary: Color(0xFF81C784),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            useMaterial3: true,
          ),

          // --- AÇIK TEMA ---
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF1E7228),
            scaffoldBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E7228),
              secondary: Color(0xFF81C784),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            useMaterial3: true,
          ),
          
          themeMode: currentMode, // Seçilen tema
          home: const LoginPage(), // İlk açılış sayfası
        );
      },
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.mosque), label: 'Camiler'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hesap'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1E7228), // Yeşil Renk
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color.fromRGBO(255, 255, 255, 1),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}