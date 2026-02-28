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

  // ===========================================================================
  // TÜRKİYE'NİN 81 İLİ VE TEMEL İLÇELERİ (TAM LİSTE)
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

  // ===========================================================================
  // HARİTADA GÖZÜKEN CAMİLERİN BİLGİLERİ (KULLANICI LİSTESİYLE BİRLEŞTİRİLDİ)
  // ===========================================================================
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
    Mosque(
      id: 'cam_06',
      name: 'Selimiye Camii',
      city: 'Edirne',
      district: 'Merkez',
      neighborhood: 'Meydan Mah, Mimar Sinan Cd.',
      history: 'Mimar Sinan’ın ustalık eseri olarak kabul edilen Selimiye Camii, II. Selim döneminde 16. yüzyılda inşa edilmiştir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/6/60/Selimiye_Mosque%2C_Edirne%2C_Turkey.jpg'],
    ),
    Mosque(
      id: 'cam_07',
      name: 'Sultanahmet Camii',
      city: 'İstanbul',
      district: 'Fatih',
      neighborhood: 'Sultanahmet Mah, Atmeydanı Cd.',
      history: 'I. Ahmed tarafından 17. yüzyılda yaptırılan Sultanahmet Camii, mavi çinileri ve altı minaresiyle dünyaca tanınır.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/6/6b/Blue_Mosque_Istanbul_Turkey.jpg'],
    ),
    Mosque(
      id: 'cam_08',
      name: 'Fatih Camii',
      city: 'İstanbul',
      district: 'Fatih',
      neighborhood: 'Ali Kuşçu Mah, Fevzi Paşa Cd.',
      history: 'Fatih Sultan Mehmed adına 15. yüzyılda inşa edilen Fatih Camii, İstanbul’un fethinden sonra kurulan ilk büyük külliyelerden biridir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/0/0d/Fatih_Mosque_Istanbul_Turkey.jpg'],
    ),
    Mosque(
      id: 'cam_09',
      name: 'Hacı Bayram-ı Veli Camii',
      city: 'Ankara',
      district: 'Altındağ',
      neighborhood: 'Hacı Bayram Mah, Sarıbağ Sk.',
      history: '15. yüzyılda inşa edilen Hacı Bayram-ı Veli Camii, Ankara’nın manevi merkezlerinden biri olup türbe ve cami birlikte bir külliye oluşturur.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/5/5c/Haci_Bayram_Mosque_Ankara.jpg'],
    ),
    Mosque(
      id: 'cam_10',
      name: 'Konak Yalı Camii',
      city: 'İzmir',
      district: 'Konak',
      neighborhood: 'Konak Meydanı',
      history: '19. yüzyılda inşa edilen Konak Yalı Camii, İzmir saat kulesiyle birlikte kentin simge yapılarından biridir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/4/4e/Yali_Camii_Izmir.jpg'],
    ),
    Mosque(
      id: 'cam_11',
      name: 'Sabancı Merkez Camii',
      city: 'Adana',
      district: 'Seyhan',
      neighborhood: 'Reşatbey Mah, Turhan Cemal Beriker Blv.',
      history: '1998’de ibadete açılan Sabancı Merkez Camii, altı minaresi ve büyük kapasitesiyle Türkiye’nin en büyük camilerinden biridir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/7/7f/Sabanci_Central_Mosque_Adana.jpg'],
    ),
    Mosque(
      id: 'cam_12',
      name: 'Melike Hatun Camii',
      city: 'Ankara',
      district: 'Çankaya',
      neighborhood: 'Cumhuriyet Mah, Atatürk Blv.',
      history: '2017 yılında açılan Melike Hatun Camii, klasik Osmanlı mimarisinden esinlenerek modern dönemde inşa edilmiştir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/3/33/Melike_Hatun_Mosque_Ankara.jpg'],
    ),
    Mosque(
      id: 'cam_13',
      name: 'Muradiye Camii',
      city: 'Bursa',
      district: 'Osmangazi',
      neighborhood: 'Muradiye Mah, Cami Sk.',
      history: 'II. Murad döneminde yaptırılan Muradiye Camii ve külliyesi, çok sayıda Osmanlı hanedan türbesine ev sahipliği yapar.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/8/86/Muradiye_Complex_Bursa.jpg'],
    ),
    Mosque(
      id: 'cam_14',
      name: 'İplikçi (Mevlana) Camii',
      city: 'Konya',
      district: 'Karatay',
      neighborhood: 'Aziziye Mah, Mevlana Cd.',
      history: 'İplikçi Camii, Konya’nın en eski camilerinden biri olup Mevlana Celaleddin-i Rumi’nin de ders halkalarına katıldığı yer olarak bilinir.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/9/90/Iplikci_Mosque_Konya.jpg'],
    ),
    Mosque(
      id: 'cam_15',
      name: 'Diyarbakır Ulu Cami',
      city: 'Diyarbakır',
      district: 'Sur',
      neighborhood: 'Cami Nebi Mah, İzzet Paşa Sk.',
      history: 'İslam dünyasının en eski camilerinden kabul edilen Diyarbakır Ulu Cami, farklı medeniyetlerin izlerini taşıyan çok katmanlı bir yapıdır.',
      imageUrls: ['https://upload.wikimedia.org/wikipedia/commons/0/0d/Diyarbakir_Ulu_Camii.jpg'],
    ),
    Mosque(
      id: 'cam_16',
      name: 'Adıyaman Ulu Camii',
      city: 'Adıyaman',
      district: 'Merkez',
      neighborhood: 'Turgutreis Mahallesi',
      history: 'Adıyaman Ulu Camii, şehir merkezinde yer alan ve bölgenin en çok bilinen camilerinden biridir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_17',
      name: 'Afyonkarahisar Ulu Camii',
      city: 'Afyonkarahisar',
      district: 'Merkez',
      neighborhood: 'Burmalı Mahallesi',
      history: 'Ahşap direkli yapısıyla bilinen Afyonkarahisar Ulu Camii, Anadolu Selçuklu döneminin özgün eserlerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_18',
      name: 'Ağrı Ulu Camii',
      city: 'Ağrı',
      district: 'Merkez',
      neighborhood: 'Kaşmer Mahallesi',
      history: 'Ağrı Ulu Camii, şehir halkının toplu ibadetlerinde sıkça tercih ettiği merkezî bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_19',
      name: 'Sultan II. Bayezid Camii',
      city: 'Amasya',
      district: 'Merkez',
      neighborhood: 'Hatuniye Mahallesi',
      history: 'Yeşilırmak kıyısında yer alan Sultan II. Bayezid Camii, Amasya’nın en tanınmış tarihi camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_20',
      name: 'Murat Paşa Camii',
      city: 'Antalya',
      district: 'Muratpaşa',
      neighborhood: 'Muratpaşa Mahallesi',
      history: '16. yüzyıldan kalan Murat Paşa Camii, kalem işi süslemeleriyle Antalya’nın simge camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_21',
      name: 'Artvin Merkez Camii',
      city: 'Artvin',
      district: 'Merkez',
      neighborhood: 'Çayağzı Mahallesi',
      history: 'Artvin Merkez Camii, şehir silüetinde öne çıkan, bölgenin en bilinen camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_22',
      name: 'Ramazan Paşa Camii',
      city: 'Aydın',
      district: 'Efeler',
      neighborhood: 'Ramazan Paşa Mahallesi',
      history: 'Ramazan Paşa Camii, Osmanlı döneminden kalma mimarisiyle Aydın şehir merkezinin önemli ibadethanelerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_23',
      name: 'Zağnos Paşa Camii',
      city: 'Balıkesir',
      district: 'Karesi',
      neighborhood: 'Hisariçi Mahallesi',
      history: 'Zağnos Paşa Camii, Balıkesir’in tarihi kent dokusu içinde öne çıkan ve çevresinde çarşı ile bütünleşen bir yapıdır.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_24',
      name: 'Şeyh Edebali Camii',
      city: 'Bilecik',
      district: 'Merkez',
      neighborhood: 'Şeyh Edebali Külliyesi',
      history: 'Şeyh Edebali Camii, Osmanlı’nın manevi önderlerinden Şeyh Edebali’nin türbesi ile birlikte önemli bir ziyaret merkezidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_25',
      name: 'Bingöl Ulu Camii',
      city: 'Bingöl',
      district: 'Merkez',
      neighborhood: 'Yenişehir Mahallesi',
      history: 'Bingöl Ulu Camii, şehir merkezi ve çevre mahallelerden gelen cemaatin yoğun olarak kullandığı bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_26',
      name: 'Bitlis Ulu Camii',
      city: 'Bitlis',
      district: 'Merkez',
      neighborhood: 'Ulu Cami Mahallesi',
      history: 'Bitlis Ulu Camii, taş mimarisi ve tarihi dokusuyla kentin en bilinen camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_27',
      name: 'Yıldırım Bayezid Camii',
      city: 'Bolu',
      district: 'Merkez',
      neighborhood: 'Aktaş Mahallesi',
      history: 'Yıldırım Bayezid Camii, Bolu şehir merkezinde Osmanlı klasik üslubunu yansıtan önemli bir yapıdır.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_28',
      name: 'Burdur Ulu Camii',
      city: 'Burdur',
      district: 'Merkez',
      neighborhood: 'Pazar Mahallesi',
      history: 'Burdur Ulu Camii, şehrin tarihî merkezinde yer alan, sade ve işlevsel mimarisiyle öne çıkan bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_29',
      name: 'Yalı Camii',
      city: 'Çanakkale',
      district: 'Merkez',
      neighborhood: 'Cevat Paşa Mahallesi',
      history: 'Çanakkale Yalı Camii, denize yakın konumuyla şehir merkezinde bilinen ve sıkça ziyaret edilen bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_30',
      name: 'Büyük Camii',
      city: 'Çankırı',
      district: 'Merkez',
      neighborhood: 'Buğday Pazarı Mahallesi',
      history: 'Çankırı Büyük Camii, uzun yıllardır şehir halkının toplu ibadetlerine ev sahipliği yapan merkezî bir yapıdır.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_31',
      name: 'Çorum Ulu Camii',
      city: 'Çorum',
      district: 'Merkez',
      neighborhood: 'Gülabibey Mahallesi',
      history: 'Çorum Ulu Camii, Selçuklu ve Osmanlı döneminin izlerini taşıyan, şehrin en tanınmış camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_32',
      name: 'Denizli Ulu Camii',
      city: 'Denizli',
      district: 'Merkezefendi',
      neighborhood: 'Sırakapılar Mahallesi',
      history: 'Denizli Ulu Camii, şehir merkezinde yer alan ve yoğun cemaatle kılınan vakit namazlarıyla bilinir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_33',
      name: 'İzzet Paşa Camii',
      city: 'Elazığ',
      district: 'Merkez',
      neighborhood: 'Rüstem Paşa Mahallesi',
      history: 'İzzet Paşa Camii, Elazığ şehir merkezinde geniş avlusu ile bilinen ve sıkça tercih edilen bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_34',
      name: 'Terzibaba Camii',
      city: 'Erzincan',
      district: 'Merkez',
      neighborhood: 'Terzibaba Mahallesi',
      history: 'Terzibaba Camii, Erzincan’ın simge camilerinden olup çevresindeki türbe ve park alanıyla bir bütün oluşturur.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_35',
      name: 'Erzurum Ulu Camii',
      city: 'Erzurum',
      district: 'Yakutiye',
      neighborhood: 'Rabia Ana Mahallesi',
      history: 'Erzurum Ulu Camii, kışları sert geçen şehirde, tarihî çarşı dokusuyla iç içe geçmiş önemli bir ibadethanedir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_36',
      name: 'Reşadiye Camii',
      city: 'Eskişehir',
      district: 'Odunpazarı',
      neighborhood: 'İstiklal Mahallesi',
      history: 'Reşadiye Camii, Eskişehir şehir merkezinde modern çarşı alanlarıyla çevrili ve sıkça ziyaret edilen bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_37',
      name: 'Gaziantep Ulu Camii',
      city: 'Gaziantep',
      district: 'Şahinbey',
      neighborhood: 'Seferpaşa Mahallesi',
      history: 'Gaziantep Ulu Camii, taş mimarisi ve merkezi konumuyla şehrin en bilinen camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_38',
      name: 'Hacı Hüseyin Camii',
      city: 'Giresun',
      district: 'Merkez',
      neighborhood: 'Hacımiktat Mahallesi',
      history: 'Hacı Hüseyin Camii, Giresun şehir merkezinde yer alan ve sahile yakın konumuyla bilinen bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_39',
      name: 'Gümüşhane Ulu Camii',
      city: 'Gümüşhane',
      district: 'Merkez',
      neighborhood: 'Süleymaniye Mahallesi',
      history: 'Gümüşhane Ulu Camii, küçük ama yoğun cemaatli bir şehir camisi olarak öne çıkar.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_40',
      name: 'Hakkari Merkez Camii',
      city: 'Hakkari',
      district: 'Merkez',
      neighborhood: 'Pehlivan Mahallesi',
      history: 'Hakkari Merkez Camii, dağlarla çevrili şehirde toplu ibadetlerin yapıldığı başlıca camilerdendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_41',
      name: 'Habib-i Neccar Camii',
      city: 'Hatay',
      district: 'Antakya',
      neighborhood: 'Kurtuluş Caddesi',
      history: 'Habib-i Neccar Camii, Anadolu’nun en eski camilerinden sayılan, çok kültürlü Antakya’nın simgesel yapılarındandır.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_42',
      name: 'Isparta Ulu Camii',
      city: 'Isparta',
      district: 'Merkez',
      neighborhood: 'Kutlubey Mahallesi',
      history: 'Isparta Ulu Camii, gül diyarı olarak bilinen şehirde merkezî konumda yer alan tarihî bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_43',
      name: 'Mersin Ulu Camii',
      city: 'Mersin',
      district: 'Akdeniz',
      neighborhood: 'Camii Şerif Mahallesi',
      history: 'Mersin Ulu Camii, sahile yakın konumu ve geniş iç hacmiyle şehrin en çok bilinen camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_44',
      name: 'Fethiye Camii',
      city: 'Kars',
      district: 'Merkez',
      neighborhood: 'Yusufpaşa Mahallesi',
      history: 'Aslen kilise olarak inşa edilip sonradan camiye çevrilen Fethiye Camii, Kars’ın çok katmanlı tarihini yansıtır.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_45',
      name: 'Nasrullah Kadı Camii',
      city: 'Kastamonu',
      district: 'Merkez',
      neighborhood: 'Nasrullah Mahallesi',
      history: 'Nasrullah Kadı Camii, Kastamonu şehir tarihinin ve çarşı kültürünün merkezinde yer alan önemli bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_46',
      name: 'Hunat Hatun Camii',
      city: 'Kayseri',
      district: 'Kocasinan',
      neighborhood: 'Hunat Mahallesi',
      history: 'Hunat Hatun Külliyesi’nin bir parçası olan Hunat Camii, Kayseri’nin en tanınmış Selçuklu eserlerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_47',
      name: 'Hızırbey Camii',
      city: 'Kırklareli',
      district: 'Merkez',
      neighborhood: 'Karacaibrahim Mahallesi',
      history: 'Hızırbey Camii, Kırklareli şehir merkezinde, çevresindeki tarihi çarşı ile birlikte kentin simge yapılarındandır.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_48',
      name: 'Ahi Evran Camii',
      city: 'Kırşehir',
      district: 'Merkez',
      neighborhood: 'Ahi Evran Mahallesi',
      history: 'Ahi teşkilatının önemli isimlerinden Ahi Evran’ın ismini taşıyan cami, Kırşehir’in manevi merkezlerinden biridir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_49',
      name: 'Fevziye Camii',
      city: 'Kocaeli',
      district: 'İzmit',
      neighborhood: 'Fevziye Mahallesi',
      history: 'Fevziye Camii, İzmit şehir merkezinde yer alan ve uzun yıllardır şehrin simgelerinden biri kabul edilen bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_50',
      name: 'Kütahya Ulu Camii',
      city: 'Kütahya',
      district: 'Merkez',
      neighborhood: 'Dumlupınar Mahallesi',
      history: 'Kütahya Ulu Camii, çini ve seramikleriyle tanınan şehirde tarihî doku içinde öne çıkan bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_51',
      name: 'Malatya Yeni Camii',
      city: 'Malatya',
      district: 'Yeşilyurt',
      neighborhood: 'Niyazi Mahallesi',
      history: 'Malatya Yeni Camii, şehir merkezi ve çevresinde yaşayanların toplu ibadet için sıkça tercih ettiği büyük bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_52',
      name: 'Şehzadeler Camii',
      city: 'Manisa',
      district: 'Şehzadeler',
      neighborhood: 'Yarhasanlar Mahallesi',
      history: 'Şehzadeler diyarı Manisa’da yer alan bu cami, klasik Osmanlı mimarisiyle şehrin öne çıkan ibadethanelerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_53',
      name: 'Kahramanmaraş Ulu Camii',
      city: 'Kahramanmaraş',
      district: 'Dulkadiroğlu',
      neighborhood: 'Trabzon Caddesi',
      history: 'Kahramanmaraş Ulu Camii, ahşap minberi ve merkezi konumuyla şehrin sembol camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_54',
      name: 'Mardin Ulu Camii',
      city: 'Mardin',
      district: 'Artuklu',
      neighborhood: 'Yukarı Mardin',
      history: 'Mardin Ulu Camii, taş mimarisi ve Mezopotamya ovasına bakan manzarasıyla bilinen bir yapıdır.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_55',
      name: 'Kurşunlu Camii',
      city: 'Muğla',
      district: 'Menteşe',
      neighborhood: 'Kiramettin Mahallesi',
      history: 'Kurşunlu Camii, tarihi Muğla evleriyle çevrili sokaklar içinde, merkezin en bilinen camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_56',
      name: 'Muş Ulu Camii',
      city: 'Muş',
      district: 'Merkez',
      neighborhood: 'Hürriyet Mahallesi',
      history: 'Muş Ulu Camii, şehir halkının uzun yıllardır toplu ibadet için bir araya geldiği merkezî bir yapıdır.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_57',
      name: 'Nevşehir Kurşunlu Camii',
      city: 'Nevşehir',
      district: 'Merkez',
      neighborhood: 'Yeni Mahalle',
      history: 'Nevşehir Kurşunlu Camii, Kapadokya bölgesinin turistik hareketliliği içinde şehir merkezinde yer alan önemli bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_58',
      name: 'Niğde Alaaddin Camii',
      city: 'Niğde',
      district: 'Merkez',
      neighborhood: 'Alaaddin Mahallesi',
      history: 'Niğde Alaaddin Camii, Selçuklu döneminden kalan ve şehrin en tanınmış tarihi eserlerinden biri olan bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_59',
      name: 'Ordu Ulu Camii',
      city: 'Ordu',
      district: 'Altınordu',
      neighborhood: 'Selimiye Mahallesi',
      history: 'Ordu Ulu Camii, Karadeniz kıyısına yakın konumuyla şehir merkezinin önemli ibadethanelerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_60',
      name: 'Rize Sahil Camii',
      city: 'Rize',
      district: 'Merkez',
      neighborhood: 'Portakallık Mahallesi',
      history: 'Rize Sahil Camii, denize yakın konumda yer alan ve şehir halkının sıkça kullandığı bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_61',
      name: 'Orhan Camii',
      city: 'Sakarya',
      district: 'Adapazarı',
      neighborhood: 'Semerciler Mahallesi',
      history: 'Orhan Camii, Sakarya şehir merkezindeki en eski camilerden biri olup çarşı dokusuyla iç içedir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_62',
      name: 'Samsun Büyük Cami',
      city: 'Samsun',
      district: 'İlkadım',
      neighborhood: 'Ulugazi Mahallesi',
      history: 'Samsun Büyük Cami, şehrin en kalabalık bölgelerinden birinde yer alan büyük bir ibadethanedir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_63',
      name: 'Siirt Ulu Camii',
      city: 'Siirt',
      district: 'Merkez',
      neighborhood: 'Sakarya Mahallesi',
      history: 'Siirt Ulu Camii, minaresindeki özgün süslemelerle tanınan, şehrin sembol camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_64',
      name: 'Sinop Alaaddin Camii',
      city: 'Sinop',
      district: 'Merkez',
      neighborhood: 'Meydankapı Mahallesi',
      history: 'Sinop Alaaddin Camii, Karadeniz kıyısındaki liman kenti Sinop’un tarihi çekirdeğinde yer alan bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_65',
      name: 'Sivas Ulu Camii',
      city: 'Sivas',
      district: 'Merkez',
      neighborhood: 'Kaleardı Mahallesi',
      history: 'Sivas Ulu Camii, Selçuklu dönemine uzanan geçmişiyle şehrin en tarihi ibadethanelerinden biridir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_66',
      name: 'Rüstem Paşa Camii',
      city: 'Tekirdağ',
      district: 'Süleymanpaşa',
      neighborhood: 'Hüseyin Ağa Mahallesi',
      history: 'Rüstem Paşa Camii, Tekirdağ şehir merkezinde yer alan klasik dönem Osmanlı camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_67',
      name: 'Tokat Ulu Camii',
      city: 'Tokat',
      district: 'Merkez',
      neighborhood: 'Büyükbeybağı Mahallesi',
      history: 'Tokat Ulu Camii, şehir merkezindeki tarihî çarşı bölgesinde konumlanmış önemli bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_68',
      name: 'Ortahisar Fatih Camii',
      city: 'Trabzon',
      district: 'Ortahisar',
      neighborhood: 'Ortahisar Mahallesi',
      history: 'Ortahisar Fatih Camii, eski bir kiliseden camiye çevrilmiş olup Trabzon’un en bilinen tarihi camilerindendir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_69',
      name: 'Tunceli Merkez Camii',
      city: 'Tunceli',
      district: 'Merkez',
      neighborhood: 'Atatürk Mahallesi',
      history: 'Tunceli Merkez Camii, şehirdeki sınırlı sayıdaki büyük camiden biri olarak toplu ibadetlerde öne çıkar.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_70',
      name: 'Balıklıgöl Dergâh Camii',
      city: 'Şanlıurfa',
      district: 'Haliliye',
      neighborhood: 'Balıklıgöl Çevresi',
      history: 'Balıklıgöl çevresindeki dergâh camii, hem ibadet hem de ziyaret amacıyla yoğun şekilde kullanılan bir mekândır.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_71',
      name: 'Uşak Ulu Camii',
      city: 'Uşak',
      district: 'Merkez',
      neighborhood: 'Karaağaç Mahallesi',
      history: 'Uşak Ulu Camii, şehir merkezinde uzun yıllardır hizmet veren tarihî bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_72',
      name: 'Van Ulu Camii',
      city: 'Van',
      district: 'İpekyolu',
      neighborhood: 'Hafiziye Mahallesi',
      history: 'Van Ulu Camii, göl manzaralı şehirde merkezî konumda yer alan ve sıkça ziyaret edilen bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_73',
      name: 'Çapanoğlu Büyük Camii',
      city: 'Yozgat',
      district: 'Merkez',
      neighborhood: 'Çapanoğlu Mahallesi',
      history: 'Çapanoğlu Büyük Camii, barok etkiler taşıyan mimarisiyle Yozgat’ın en dikkat çekici camilerinden biridir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_74',
      name: 'Zonguldak Ulu Camii',
      city: 'Zonguldak',
      district: 'Merkez',
      neighborhood: 'Mithatpaşa Mahallesi',
      history: 'Zonguldak Ulu Camii, Karadeniz kıyısındaki sanayi kentinde merkezî konumuyla bilinen bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_75',
      name: 'Aksaray Ulu Camii',
      city: 'Aksaray',
      district: 'Merkez',
      neighborhood: 'Hamidiye Mahallesi',
      history: 'Aksaray Ulu Camii, İç Anadolu’nun tarihî şehirlerinden Aksaray’da en bilinen camilerden biridir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_76',
      name: 'Bayburt Ulu Camii',
      city: 'Bayburt',
      district: 'Merkez',
      neighborhood: 'Zahit Mahallesi',
      history: 'Bayburt Ulu Camii, küçük şehir merkezinde toplu ibadetler için kullanılan başlıca camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_77',
      name: 'Aktekke Camii',
      city: 'Karaman',
      district: 'Merkez',
      neighborhood: 'Aktekke Meydanı',
      history: 'Aktekke Camii, Karaman’ın simge camilerinden olup Yunus Emre ile ilişkilendirilen türbeleri barındırır.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_78',
      name: 'Nur Camii',
      city: 'Kırıkkale',
      district: 'Merkez',
      neighborhood: 'Yenimahalle',
      history: 'Kırıkkale Nur Camii, modern dönemde inşa edilmiş geniş kapasiteli bir şehir camisidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_79',
      name: 'Batman Ulu Camii',
      city: 'Batman',
      district: 'Merkez',
      neighborhood: 'Gültepe Mahallesi',
      history: 'Batman Ulu Camii, genç bir şehir olan Batman’da geniş cemaat kapasitesiyle öne çıkmaktadır.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_80',
      name: 'Şırnak Ulu Camii',
      city: 'Şırnak',
      district: 'Merkez',
      neighborhood: 'Yeni Mahalle',
      history: 'Şırnak Ulu Camii, şehir merkezinde yer alan ve bölge halkının en çok kullandığı camilerden biridir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_81',
      name: 'Bartın Merkez Camii',
      city: 'Bartın',
      district: 'Merkez',
      neighborhood: 'Orta Mahalle',
      history: 'Bartın Merkez Camii, küçük ama yoğun kullanılan şehir merkezinde, çarşıya yakın konumlu bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_82',
      name: 'Ardahan Merkez Camii',
      city: 'Ardahan',
      district: 'Merkez',
      neighborhood: 'Kaptanpaşa Mahallesi',
      history: 'Ardahan Merkez Camii, şehrin soğuk iklimine rağmen cemaatin toplu ibadetlerde buluştuğu başlıca camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_83',
      name: 'Iğdır Merkez Camii',
      city: 'Iğdır',
      district: 'Merkez',
      neighborhood: 'Bağlar Mahallesi',
      history: 'Iğdır Merkez Camii, Aras ovasına yakın konumda yer alan, şehrin en bilinen camilerinden biridir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_84',
      name: 'Yalova Merkez Camii',
      city: 'Yalova',
      district: 'Merkez',
      neighborhood: 'Süleymanbey Mahallesi',
      history: 'Yalova Merkez Camii, Marmara Denizi kıyısındaki termal kentin önemli ibadethanelerinden biridir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_85',
      name: 'Karabük Yenişehir Camii',
      city: 'Karabük',
      district: 'Merkez',
      neighborhood: 'Yenişehir Mahallesi',
      history: 'Karabük Yenişehir Camii, sanayi kenti Karabük’ün gelişen bölgelerinden birinde yer alan büyük bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_86',
      name: 'Kilis Ulu Camii',
      city: 'Kilis',
      district: 'Merkez',
      neighborhood: 'Cumhuriyet Mahallesi',
      history: 'Kilis Ulu Camii, Suriye sınırına yakın bu küçük şehirde merkezî konumdaki en bilinen camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_87',
      name: 'Envarülhamid Camii',
      city: 'Osmaniye',
      district: 'Merkez',
      neighborhood: 'Raufbey Mahallesi',
      history: 'Envarülhamid Camii, Osmaniye şehir merkezinde yer alan ve geniş cemaat kapasitesiyle bilinen bir camidir.',
      imageUrls: const [],
    ),
    Mosque(
      id: 'cam_88',
      name: 'Düzce Büyük Camii',
      city: 'Düzce',
      district: 'Merkez',
      neighborhood: 'Şerefiye Mahallesi',
      history: 'Düzce Büyük Camii, deprem sonrası yeniden şekillenen şehir merkezinde önemli bir ibadet noktasıdır.',
      imageUrls: const [],
    ),
  ];
}