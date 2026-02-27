import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class GlobalData {
  static String userName = "Kullanıcı Adı";
  static String phoneNumber = "0555 123 45 67";
  static String email = "ornek1233@gmail.com";
  static Color profileColor = Colors.grey;

  static bool isImam = false;
  static const String imamUsernameReal = "admin123";
  static const String imamPasswordReal = "123456";

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
  
  // Camiler listesini başlangıçta _defaultMosques ile dolduruyoruz ki boş gelmesin
  static List<Mosque> mosques = _defaultMosques;

  // Favori Listesi (Yeni eklenen kısım)
  static Set<String> favoriteMosqueIds = {};

  static final Map<String, Map<String, List<String>>> turkeyLocationData = {
    'İstanbul': {
      'Fatih': ['Sultan Ahmet Mahallesi', 'Süleymaniye Mah', 'Zeyrek', 'Ali Kuşçu'],
      'Üsküdar': ['Mimar Sinan', 'Valide-i Atik', 'Altunizade', 'Kuzguncuk'],
      'Kadıköy': ['Caferağa', 'Fenerbahçe', 'Göztepe'],
    },
    'Ankara': {
      'Çankaya': ['Kültür Mahallesi', 'Kızılay', 'Kocatepe', 'Bahçelievler'],
      'Keçiören': ['Etlik', 'Bağlum', 'İncirli'],
      'Altındağ': ['Ulus', 'Hacıbayram'],
    },
    'İzmir': {
      'Konak': ['Alsancak', 'Basmane', 'Konak'],
      'Bornova': ['Erzene', 'Kazımdirik'],
    },
    'Bursa': {
      'Osmangazi': ['Nalbantoğlu Mah', 'Şehreküstü', 'Çekirge'],
      'Nilüfer': ['Fethiye', 'Beşevler'],
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

    // Favorileri yükle
    final List<String>? favs = prefs.getStringList('favorite_mosque_ids');
    if (favs != null) {
      favoriteMosqueIds = favs.toSet();
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
  
  // Favorileri kaydetme
  static Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_mosque_ids', favoriteMosqueIds.toList());
  }

  static final List<Person> _defaultPersons = [
    Person(
      name: 'AYŞE YILMAZ', date: '10 Aralık 2025', time: '09:45', funeralTime: '12:45',
      prayerInfo: '(Öğle Namazı)', mosqueName: 'Fatih Camii', city: 'İstanbul', burialPlace: 'Edirnekapı Şehitliği',
    ),
  ];

  // --- HARİTADA GÖZÜKEN CAMİLERİN BİLGİLERİ ---
  static final List<Mosque> _defaultMosques = [
    Mosque(
      id: 'cam_01', 
      name: 'Ayasofya-i Kebir Cami-i Şerifi', 
      city: 'İstanbul', 
      district: 'Fatih', 
      neighborhood: 'Sultan Ahmet Mahallesi, Ayasofya Meydanı No:1',
      history: '1453 yılında Fatih Sultan Mehmed tarafından camiye çevrilmiştir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/2/22/Hagia_Sophia_Mars_2013.jpg'],
    ),
    Mosque(
      id: 'cam_02', 
      name: 'Kocatepe Camii', 
      city: 'Ankara', 
      district: 'Çankaya', 
      neighborhood: 'Kültür Mahallesi, Dr. Mediha Eldem Sk. No:67',
      history: 'Cumhuriyet dönemi Türk mimarisinin en önemli eserlerindendir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Kocatepe_Mosque_Ankara.jpg/800px-Kocatepe_Mosque_Ankara.jpg'],
    ),
    Mosque(
      id: 'cam_03', 
      name: 'Süleymaniye Camii', 
      city: 'İstanbul', 
      district: 'Fatih', 
      neighborhood: 'Süleymaniye Mah, Prof. Sıddık Sami Onar Cd. No:1',
      history: 'Mimar Sinan tarafından Kanuni Sultan Süleyman adına yapılmıştır.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Suleymaniye_Mosque_Istanbul_Turkey.jpg/1200px-Suleymaniye_Mosque_Istanbul_Turkey.jpg'],
    ),
    Mosque(
      id: 'cam_05', 
      name: 'Bursa Ulu Cami', 
      city: 'Bursa', 
      district: 'Osmangazi', 
      neighborhood: 'Nalbantoğlu Mah, Atatürk Cd.',
      history: 'Erken dönem Osmanlı mimarisinin en önemli örneğidir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Bursa_Ulu_Camii_2010.jpg/1200px-Bursa_Ulu_Camii_2010.jpg'],
    ),
  ];
}