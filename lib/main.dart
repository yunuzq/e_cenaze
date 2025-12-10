import 'package:flutter/material.dart';
import 'data/global_data.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/home/home_screen.dart';
import 'screens/mosque/mosques_screen.dart';
import 'screens/account/account_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalData.loadData();
  runApp(const ECenazeApp());
}

class ECenazeApp extends StatelessWidget {
  const ECenazeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder ile Tema değişikliğini dinliyoruz
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: GlobalData.themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'E-Cenaze',
          // KOYU TEMA AYARLARI
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF4CAF50),
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4CAF50),
              secondary: Color(0xFF81C784),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            useMaterial3: true,
          ),
          // AÇIK TEMA AYARLARI (Beyaz Arka Plan)
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF4CAF50),
            scaffoldBackgroundColor: Colors.white, // BEYAZ ARKA PLAN
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              secondary: Color(0xFF81C784),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black), // İkonlar siyah olsun
              titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            useMaterial3: true,
          ),
          themeMode: currentMode, // Seçilen tema
          home: const LoginPage(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const MosquesScreen(),
    const AccountScreen()
  ];

  @override
  void initState() {
    super.initState();
    if (!GlobalData.hasLocationPermissionBeenAsked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // İzin mantığı burada
      });
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.mosque), label: 'Camiler'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hesap'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
        // Tema'ya göre arka plan rengi ayarla
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1E1E1E) 
            : Colors.grey[100],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}