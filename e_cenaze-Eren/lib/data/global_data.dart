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

  // Favori Listesi
  static Set<String> favoriteMosqueIds = {};

  // ===========================================================================
  // TÜRKİYE'NİN 81 İLİ VE TEMEL İLÇELERİ (GÜNCELLENDİ)
  // ===========================================================================
  static final Map<String, Map<String, List<String>>> turkeyLocationData = {
    'Adana': {'Çukurova': ['Merkez'], 'Seyhan': ['Merkez'], 'Yüreğir': ['Merkez'], 'Ceyhan': ['Merkez'], 'Kozan': ['Merkez']},
    'Adıyaman': {'Merkez': ['Merkez'], 'Besni': ['Merkez'], 'Kahta': ['Merkez']},
    'Afyonkarahisar': {'Merkez': ['Merkez'], 'Sandıklı': ['Merkez'], 'Dinar': ['Merkez']},
    'Ağrı': {'Merkez': ['Merkez'], 'Doğubayazıt': ['Merkez'], 'Patnos': ['Merkez']},
    'Amasya': {'Merkez': ['Merkez'], 'Merzifon': ['Merkez'], 'Suluova': ['Merkez']},
    'Ankara': {
      'Çankaya': ['Kültür Mahallesi', 'Kızılay', 'Kocatepe', 'Bahçelievler'],
      'Keçiören': ['Etlik', 'Bağlum', 'İncirli'],
      'Altındağ': ['Ulus', 'Hacıbayram'],
      'Yenimahalle': ['Batıkent', 'Demetevler'],
      'Mamak': ['Kayaş', 'Abidinpaşa'],
      'Sincan': ['Merkez', 'Eryaman'],
      'Etimesgut': ['Elvankent', 'Eryaman'],
    },
    'Antalya': {'Muratpaşa': ['Merkez'], 'Kepez': ['Merkez'], 'Konyaaltı': ['Merkez'], 'Alanya': ['Merkez'], 'Manavgat': ['Merkez']},
    'Artvin': {'Merkez': ['Merkez'], 'Hopa': ['Merkez'], 'Arhavi': ['Merkez']},
    'Aydın': {'Efeler': ['Merkez'], 'Kuşadası': ['Merkez'], 'Nazilli': ['Merkez'], 'Söke': ['Merkez']},
    'Balıkesir': {'Altıeylül': ['Merkez'], 'Karesi': ['Merkez'], 'Bandırma': ['Merkez'], 'Edremit': ['Merkez']},
    'Bilecik': {'Merkez': ['Merkez'], 'Bozüyük': ['Merkez']},
    'Bingöl': {'Merkez': ['Merkez'], 'Genç': ['Merkez']},
    'Bitlis': {'Merkez': ['Merkez'], 'Tatvan': ['Merkez']},
    'Bolu': {'Merkez': ['Merkez'], 'Gerede': ['Merkez']},
    'Burdur': {'Merkez': ['Merkez'], 'Bucak': ['Merkez']},
    'Bursa': {
      'Osmangazi': ['Nalbantoğlu Mah', 'Şehreküstü', 'Çekirge'],
      'Nilüfer': ['Fethiye', 'Beşevler', 'Görükle'],
      'Yıldırım': ['Arabayatağı', 'Şirinevler'],
      'İnegöl': ['Merkez'],
      'Mudanya': ['Merkez'],
    },
    'Çanakkale': {'Merkez': ['Merkez'], 'Biga': ['Merkez'], 'Çan': ['Merkez']},
    'Çankırı': {'Merkez': ['Merkez'], 'Çerkeş': ['Merkez']},
    'Çorum': {'Merkez': ['Merkez'], 'Sungurlu': ['Merkez'], 'Osmancık': ['Merkez']},
    'Denizli': {'Pamukkale': ['Merkez'], 'Merkezefendi': ['Merkez'], 'Çivril': ['Merkez']},
    'Diyarbakır': {'Bağlar': ['Merkez'], 'Kayapınar': ['Merkez'], 'Sur': ['Merkez'], 'Yenişehir': ['Merkez']},
    'Edirne': {'Merkez': ['Merkez'], 'Keşan': ['Merkez'], 'Uzunköprü': ['Merkez']},
    'Elazığ': {'Merkez': ['Merkez'], 'Kovancılar': ['Merkez']},
    'Erzincan': {'Merkez': ['Merkez'], 'Tercan': ['Merkez']},
    'Erzurum': {'Yakutiye': ['Merkez'], 'Palandöken': ['Merkez'], 'Aziziye': ['Merkez']},
    'Eskişehir': {'Odunpazarı': ['Merkez'], 'Tepebaşı': ['Merkez']},
    'Gaziantep': {'Şahinbey': ['Merkez'], 'Şehitkamil': ['Merkez'], 'Nizip': ['Merkez']},
    'Giresun': {'Merkez': ['Merkez'], 'Bulancak': ['Merkez'], 'Görele': ['Merkez']},
    'Gümüşhane': {'Merkez': ['Merkez'], 'Kelkit': ['Merkez']},
    'Hakkari': {'Merkez': ['Merkez'], 'Yüksekova': ['Merkez']},
    'Hatay': {'Antakya': ['Merkez'], 'İskenderun': ['Merkez'], 'Defne': ['Merkez'], 'Dörtyol': ['Merkez']},
    'Isparta': {'Merkez': ['Merkez'], 'Eğirdir': ['Merkez']},
    'Mersin': {'Akdeniz': ['Merkez'], 'Mezitli': ['Merkez'], 'Toroslar': ['Merkez'], 'Yenişehir': ['Merkez'], 'Tarsus': ['Merkez']},
    'İstanbul': {
      'Fatih': ['Sultan Ahmet Mahallesi', 'Süleymaniye Mah', 'Zeyrek', 'Ali Kuşçu'],
      'Üsküdar': ['Mimar Sinan', 'Valide-i Atik', 'Altunizade', 'Kuzguncuk'],
      'Kadıköy': ['Caferağa', 'Fenerbahçe', 'Göztepe', 'Bostancı'],
      'Beşiktaş': ['Bebek', 'Etiler', 'Levent', 'Ortaköy'],
      'Şişli': ['Bomonti', 'Mecidiyeköy', 'Nişantaşı'],
      'Pendik': ['Batı Mah', 'Doğu Mah', 'Yenişehir'],
      'Esenyurt': ['Merkez', 'Güzelyurt'],
    },
    'İzmir': {
      'Konak': ['Alsancak', 'Basmane', 'Güzelyalı'],
      'Bornova': ['Erzene', 'Kazımdirik', 'Evka 3'],
      'Karşıyaka': ['Bostanlı', 'Mavişehir', 'Aksoy'],
      'Buca': ['Şirinyer', 'Adatepe'],
      'Çiğli': ['Ataşehir', 'Balatçık'],
    },
    'Kars': {'Merkez': ['Merkez'], 'Sarıkamış': ['Merkez']},
    'Kastamonu': {'Merkez': ['Merkez'], 'Tosya': ['Merkez']},
    'Kayseri': {'Melikgazi': ['Merkez'], 'Kocasinan': ['Merkez'], 'Talas': ['Merkez']},
    'Kırklareli': {'Merkez': ['Merkez'], 'Lüleburgaz': ['Merkez']},
    'Kırşehir': {'Merkez': ['Merkez'], 'Kaman': ['Merkez']},
    'Kocaeli': {'İzmit': ['Merkez', 'Yahyakaptan', 'Yenişehir'], 'Gebze': ['Merkez', 'Mutlukent'], 'Derince': ['Merkez'], 'Gölcük': ['Merkez'], 'Karamürsel': ['Merkez']},
    'Konya': {'Selçuklu': ['Merkez'], 'Meram': ['Merkez'], 'Karatay': ['Merkez'], 'Ereğli': ['Merkez']},
    'Kütahya': {'Merkez': ['Merkez'], 'Tavşanlı': ['Merkez']},
    'Malatya': {'Battalgazi': ['Merkez'], 'Yeşilyurt': ['Merkez']},
    'Manisa': {'Yunusemre': ['Merkez'], 'Şehzadeler': ['Merkez'], 'Akhisar': ['Merkez'], 'Turgutlu': ['Merkez']},
    'Kahramanmaraş': {'Onikişubat': ['Merkez'], 'Dulkadiroğlu': ['Merkez'], 'Elbistan': ['Merkez']},
    'Mardin': {'Artuklu': ['Merkez'], 'Kızıltepe': ['Merkez'], 'Midyat': ['Merkez']},
    'Muğla': {'Menteşe': ['Merkez'], 'Bodrum': ['Merkez'], 'Fethiye': ['Merkez'], 'Marmaris': ['Merkez']},
    'Muş': {'Merkez': ['Merkez'], 'Bulanık': ['Merkez']},
    'Nevşehir': {'Merkez': ['Merkez'], 'Ürgüp': ['Merkez']},
    'Niğde': {'Merkez': ['Merkez'], 'Bor': ['Merkez']},
    'Ordu': {'Altınordu': ['Merkez'], 'Ünye': ['Merkez'], 'Fatsa': ['Merkez']},
    'Rize': {'Merkez': ['Merkez'], 'Çayeli': ['Merkez'], 'Ardeşen': ['Merkez']},
    'Sakarya': {'Adapazarı': ['Merkez'], 'Serdivan': ['Merkez'], 'Erenler': ['Merkez']},
    'Samsun': {'İlkadım': ['Merkez'], 'Atakum': ['Merkez'], 'Bafra': ['Merkez']},
    'Siirt': {'Merkez': ['Merkez'], 'Kurtalan': ['Merkez']},
    'Sinop': {'Merkez': ['Merkez'], 'Boyabat': ['Merkez']},
    'Sivas': {'Merkez': ['Merkez'], 'Şarkışla': ['Merkez']},
    'Tekirdağ': {'Süleymanpaşa': ['Merkez'], 'Çorlu': ['Merkez'], 'Çerkezköy': ['Merkez']},
    'Tokat': {'Merkez': ['Merkez'], 'Erbaa': ['Merkez'], 'Turhal': ['Merkez']},
    'Trabzon': {'Ortahisar': ['Merkez'], 'Akçaabat': ['Merkez'], 'Yomra': ['Merkez']},
    'Tunceli': {'Merkez': ['Merkez'], 'Pertek': ['Merkez']},
    'Şanlıurfa': {'Haliliye': ['Merkez'], 'Eyyübiye': ['Merkez'], 'Karaköprü': ['Merkez'], 'Siverek': ['Merkez']},
    'Uşak': {'Merkez': ['Merkez'], 'Banaz': ['Merkez']},
    'Van': {'İpekyolu': ['Merkez'], 'Edremit': ['Merkez'], 'Tuşba': ['Merkez'], 'Erciş': ['Merkez']},
    'Yozgat': {'Merkez': ['Merkez'], 'Sorgun': ['Merkez']},
    'Zonguldak': {'Merkez': ['Merkez'], 'Ereğli': ['Merkez'], 'Çaycuma': ['Merkez']},
    'Aksaray': {'Merkez': ['Merkez'], 'Ortaköy': ['Merkez']},
    'Bayburt': {'Merkez': ['Merkez'], 'Aydıntepe': ['Merkez']},
    'Karaman': {'Merkez': ['Merkez'], 'Ermenek': ['Merkez']},
    'Kırıkkale': {'Merkez': ['Merkez'], 'Yahşihan': ['Merkez']},
    'Batman': {'Merkez': ['Merkez'], 'Kozluk': ['Merkez']},
    'Şırnak': {'Merkez': ['Merkez'], 'Cizre': ['Merkez'], 'Silopi': ['Merkez']},
    'Bartın': {'Merkez': ['Merkez'], 'Amasra': ['Merkez']},
    'Ardahan': {'Merkez': ['Merkez'], 'Göle': ['Merkez']},
    'Iğdır': {'Merkez': ['Merkez'], 'Tuzluca': ['Merkez']},
    'Yalova': {'Merkez': ['Merkez'], 'Çınarcık': ['Merkez']},
    'Karabük': {'Merkez': ['Merkez'], 'Safranbolu': ['Merkez']},
    'Kilis': {'Merkez': ['Merkez'], 'Musabeyli': ['Merkez']},
    'Osmaniye': {'Merkez': ['Merkez'], 'Kadirli': ['Merkez']},
    'Düzce': {'Merkez': ['Merkez'], 'Akçakoca': ['Merkez']},
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