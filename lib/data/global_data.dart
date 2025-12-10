import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart'; <--- SİLİNDİ
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class GlobalData {
  static String userName = "Kullanıcı Adı";
  static String phoneNumber = "0555 123 45 67";
  static String email = "ornek@email.com";
  static Color profileColor = Colors.grey;

  static bool isImam = false;
  static const String imamUsernameReal = "qçwöemrmtnyb";
  static const String imamPasswordReal = "1029384756";

  static bool isLocationPermissionGranted = false;
  static bool hasLocationPermissionBeenAsked = false;

  static bool isRemembered = false;
  static String savedUsername = "";
  static String savedPassword = "";

  static ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  static List<AppNotification> notifications = [
    AppNotification(title: "Sistem", message: "Uygulamaya hoşgeldiniz.", date: "Bugün", isRead: false),
  ];

  static List<Person> people = [];
  static List<Mosque> mosques = [];

  static final Map<String, Map<String, List<String>>> turkeyLocationData = {
    'İstanbul': {
      'Fatih': ['Ali Kuşçu', 'Balat', 'Zeyrek', 'Topkapı'],
      'Üsküdar': ['Mimar Sinan', 'Valide-i Atik', 'Altunizade', 'Kuzguncuk'],
      'Kadıköy': ['Caferağa', 'Fenerbahçe', 'Göztepe'],
    },
    'Ankara': {
      'Çankaya': ['Kızılay', 'Kocatepe', 'Bahçelievler'],
      'Keçiören': ['Etlik', 'Bağlum', 'İncirli'],
      'Altındağ': ['Ulus', 'Hacıbayram'],
    },
    'İzmir': {
      'Konak': ['Alsancak', 'Basmane', 'Konak'],
      'Bornova': ['Erzene', 'Kazımdirik'],
    },
  };

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    bool isDark = prefs.getBool('is_dark_theme') ?? true;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

    final String? peopleJson = prefs.getString('saved_people');
    if (peopleJson != null) {
      Iterable l = json.decode(peopleJson);
      people = List<Person>.from(l.map((model) => Person.fromJson(model)));
    } else {
      people = _defaultPersons;
    }

    final String? mosquesJson = prefs.getString('saved_mosques');
    if (mosquesJson != null) {
      Iterable l = json.decode(mosquesJson);
      mosques = List<Mosque>.from(l.map((model) => Mosque.fromJson(model)));
    } else {
      mosques = _defaultMosques;
    }

    isLocationPermissionGranted = prefs.getBool('location_granted') ?? false;
    hasLocationPermissionBeenAsked = prefs.getBool('location_asked') ?? false;
  }

  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_theme', isDark);
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> saveNotifications() async {
     // Bildirim kaydetme (opsiyonel)
  }

  static Future<void> addPerson(Person person) async {
    people.insert(0, person);
    final prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(people.map((e) => e.toJson()).toList());
    await prefs.setString('saved_people', jsonString);
  }

  static Future<void> addMosque(Mosque mosque) async {
    mosques.add(mosque);
    final prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(mosques.map((e) => e.toJson()).toList());
    await prefs.setString('saved_mosques', jsonString);
  }

  static Future<void> saveLocationPermission(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_granted', granted);
    await prefs.setBool('location_asked', true);
    isLocationPermissionGranted = granted;
    hasLocationPermissionBeenAsked = true;
  }

  static final List<Person> _defaultPersons = [
    Person(
      name: 'AYŞE YILMAZ', date: '10 Aralık 2025', time: '09:45', funeralTime: '12:45',
      prayerInfo: '(Öğle Namazı)', mosqueName: 'Fatih Camii', city: 'İstanbul', burialPlace: 'Edirnekapı Şehitliği',
    ),
  ];

  // Location parametreleri temizlendi
  static final List<Mosque> _defaultMosques = [
    Mosque(
      id: '1', name: 'Sultanahmet Camii', city: 'İstanbul', district: 'Fatih', neighborhood: 'Ali Kuşçu',
      history: '1609-1617 yılları arasında I. Ahmed tarafından yaptırılmıştır.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Blue_Mosque_Courtyard_Dusk.jpg/1200px-Blue_Mosque_Courtyard_Dusk.jpg'],
    ),
    Mosque(
      id: '2', name: 'Fatih Camii', city: 'İstanbul', district: 'Fatih', neighborhood: 'Zeyrek',
      history: 'Fatih Sultan Mehmed tarafından yaptırılmış olan camidir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/e/e5/Fatih_Mosque_Istanbul.jpg'],
    ),
    Mosque(
      id: '3', name: 'Kocatepe Camii', city: 'Ankara', district: 'Çankaya', neighborhood: 'Kocatepe',
      history: 'Ankara\'nın en büyük camilerinden biridir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Kocatepe_Mosque_Ankara.jpg/800px-Kocatepe_Mosque_Ankara.jpg'],
    ),
     Mosque(
      id: '5', name: 'Konak Camii (Yalı Camii)', city: 'İzmir', district: 'Konak', neighborhood: 'Konak',
      history: 'İzmir Konak Meydanı\'nda yer alan tarihi camidir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Yal%C4%B1_Mosque_2015.jpg/800px-Yal%C4%B1_Mosque_2015.jpg'],
    ),
    Mosque(
      id: '6', name: 'Büyük Çamlıca Camii', city: 'İstanbul', district: 'Üsküdar', neighborhood: 'Kuzguncuk',
      history: 'Cumhuriyet tarihinin en büyük camisidir.',
      imageUrls: ['https://example.com/camlica.jpg'],
    ),
  ];
}