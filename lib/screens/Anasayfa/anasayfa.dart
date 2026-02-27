import 'dart:async'; // Timer için gerekli
import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../Detay/detaylar.dart'; 

// --- GLOBAL İZİN DEĞİŞKENİ (Hafızada tutulur) ---
bool globalLocationPermissionGranted = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  String isimSansurle(String tamIsim) {
    if (tamIsim.trim().isEmpty) return "";
    List<String> kelimeler = tamIsim.trim().split(' ');
    List<String> sansurluKelimeler = kelimeler.map((kelime) {
      if (kelime.length <= 1) return kelime;
      return kelime[0] + 'X' * (kelime.length - 1);
    }).toList();
    return sansurluKelimeler.join(' ');
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // --- KONUM VE SAYAÇ DEĞİŞKENLERİ ---
  Timer? _timer;
  String _nextPrayerName = "HESAPLANIYOR";
  String _timeLeftString = "00:00:00";

  // --- GERÇEK NAMAZ VAKİTLERİ (11 ARALIK 2025 - İSTANBUL) ---
  final Map<String, String> _prayerSchedule = {
    "İMSAK": "06:40",
    "GÜNEŞ": "08:12",
    "ÖĞLE": "13:02",
    "İKİNDİ": "15:22",
    "AKŞAM": "17:43",
    "YATSI": "19:09",
  };

  @override
  void initState() {
    super.initState();
    
    if (!globalLocationPermissionGranted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _askLocationPermission();
      });
    }

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  // --- SAYAÇ MANTIĞI ---
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateNextPrayer();
    });
  }

  void _calculateNextPrayer() {
    final now = DateTime.now();
    DateTime? nextTime;
    String nextName = "";

    for (var entry in _prayerSchedule.entries) {
      final timeParts = entry.value.split(':');
      final prayerTime = DateTime(
        now.year, now.month, now.day, 
        int.parse(timeParts[0]), int.parse(timeParts[1])
      );

      if (prayerTime.isAfter(now)) {
        nextTime = prayerTime;
        nextName = entry.key;
        break; 
      }
    }

    if (nextTime == null) {
      nextName = "İMSAK (YARIN)";
      nextTime = DateTime(now.year, now.month, now.day + 1, 6, 41);
    }

    final difference = nextTime.difference(now);
    
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(difference.inHours);
    final minutes = twoDigits(difference.inMinutes.remainder(60));
    final seconds = twoDigits(difference.inSeconds.remainder(60));

    if (mounted) {
      setState(() {
        _nextPrayerName = nextName;
        _timeLeftString = "$hours:$minutes:$seconds";
      });
    }
  }

  void _askLocationPermission() {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => AlertDialog(
        title: const Text("Konum İzni Gerekiyor"),
        content: const Text("Namaz vakitlerini ve size en yakın camileri gösterebilmek için konum iznine ihtiyacımız var."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konum izni verilmediği için namaz vakitleri gösterilemiyor.")));
            },
            child: const Text("Hayır", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                globalLocationPermissionGranted = true; 
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konum izni alındı. Vakitler güncelleniyor..."), backgroundColor: Colors.green));
            },
            child: const Text("İzin Ver", style: TextStyle(color: Color(0xFF1E7228), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- MOCK DATA ---
  final List<Person> _people = [
    Person(name: "A**** Y***", date: "11 Aralık 2025", time: "10:30", funeralTime: "İkindi", prayerInfo: "(Cenaze Namazı)", mosqueName: "Fatih Camii", city: "İstanbul", burialPlace: "Edirnekapı Mezarlığı",cenazeSaati: "Belirtilmedi",),
    Person(name: "M*** Ö****", date: "11 Aralık 2025", time: "09:15", funeralTime: "Öğle", prayerInfo: "(Cenaze Namazı)", mosqueName: "Ulu Camii", city: "Bursa", burialPlace: "Emirsultan Mezarlığı",cenazeSaati: "Belirtilmedi",),
    Person(name: "A*** D****", date: "11 Aralık 2025", time: "11:00", funeralTime: "İkindi", prayerInfo: "(Cenaze Namazı)", mosqueName: "Kocatepe Camii", city: "Ankara", burialPlace: "Karşıyaka Mezarlığı",cenazeSaati: "Belirtilmedi",),
    Person(name: "F**** K****", date: "10 Aralık 2025", time: "13:45", funeralTime: "Öğle", prayerInfo: "(Cenaze Namazı)", mosqueName: "Merkez Camii", city: "İzmir", burialPlace: "Hacılarkırı Mezarlığı",cenazeSaati: "Belirtilmedi",),
    Person(name: "M***** Ç******", date: "10 Aralık 2025", time: "14:20", funeralTime: "İkindi", prayerInfo: "(Cenaze Namazı)", mosqueName: "Selimiye Camii", city: "Edirne", burialPlace: "Şehir Mezarlığı",cenazeSaati: "Belirtilmedi",),
    Person(name: "H***** A*****", date: "10 Aralık 2025", time: "16:00", funeralTime: "Öğle", prayerInfo: "(Cenaze Namazı)", mosqueName: "Hacı Bayram Veli", city: "Ankara", burialPlace: "Gölbaşı Mezarlığı",cenazeSaati: "Belirtilmedi",),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color textColor = isDark ? Colors.white : Colors.black87;

    final DateTime now = DateTime.now();
    final List<String> months = ["", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
    String dayNumber = now.day.toString();
    String monthName = months[now.month];
    String year = now.year.toString();

    return Scaffold(
      backgroundColor: bgColor, 
      appBar: AppBar(
        title: const Text("Ana Sayfa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E7228),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // --- HEADER ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E7228), 
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                      ),
                      padding: const EdgeInsets.all(2), 
                      child: CircleAvatar(
                        radius: 28, 
                        backgroundColor: Colors.white,
                        backgroundImage: const AssetImage('assets/ecenaze.png'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "E-Cenaze",
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                        ),
                        Text(
                          "Hoşgeldiniz",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!globalLocationPermissionGranted) {
                          _askLocationPermission();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vakitler güncel (Konum: İstanbul)")));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              globalLocationPermissionGranted ? _nextPrayerName : "Konum İzni", 
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                            Text(
                              globalLocationPermissionGranted ? _timeLeftString : "GEREKLİ", 
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                            ),
                            child: Center(
                              child: Text(year, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                dayNumber,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              monthName, 
                              style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- İÇERİK KISMI ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SADECE BUGÜNKÜ VEFATLAR KALDI
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Text("Bugünkü Vefatlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  ),
                  
                  ListView.builder(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: _people.length,
  itemBuilder: (context, index) {
    var person = _people[index];

    return _PersonCard(person: person);
  },
),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- VEFAT EDEN KİŞİ KARTI ---
class _PersonCard extends StatelessWidget {
  final Person person;
  const _PersonCard({required this.person});

  // 1. SANSÜRLEME FONKSİYONUNU BURAYA EKLEDİK
  String isimSansurle(String tamIsim) {
    if (tamIsim.trim().isEmpty) return "";
    return tamIsim.trim().split(' ').map((kelime) {
      if (kelime.length <= 1) return kelime;
      return kelime[0] + 'X' * (kelime.length - 1);
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color cardColor = isDark ? Colors.grey[900]! : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color subTextColor = isDark ? Colors.grey[400]! : Colors.grey;

    // 2. DEĞİŞKENİ BURADA OLUŞTURUYORUZ (MODELİ DEĞİŞTİRMİYORUZ)
    String sansurluIsim = isimSansurle(person.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  person.name.isNotEmpty ? person.name[0] : "?",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E7228)),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sansurluIsim, // 3. EKRANA ARTIK BU YAZILIYOR
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${person.mosqueName}, ${person.city}',
                    style: TextStyle(fontSize: 12, color: subTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${person.funeralTime} Vakti',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1E7228), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PersonDetailScreen(person: person)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E7228),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
              child: const Text('Detay', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}