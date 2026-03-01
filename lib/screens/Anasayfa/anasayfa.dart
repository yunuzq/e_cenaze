import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../Detay/detaylar.dart';

// --- GLOBAL İZİN DEĞİŞKENİ (Hafızada tutulur) ---
bool globalLocationPermissionGranted = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

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
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _isLoading = false);
    });
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
            child: Text("İzin Ver", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // --- MOCK DATA ---
  final List<Person> _people = [
    Person(name: "A**** Y***", date: "11 Aralık 2025", time: "10:30", funeralTime: "İkindi", prayerInfo: "(Cenaze Namazı)", mosqueName: "Fatih Camii", city: "İstanbul", burialPlace: "Edirnekapı Mezarlığı"),
    Person(name: "M*** Ö****", date: "11 Aralık 2025", time: "09:15", funeralTime: "Öğle", prayerInfo: "(Cenaze Namazı)", mosqueName: "Ulu Camii", city: "Bursa", burialPlace: "Emirsultan Mezarlığı"),
    Person(name: "A*** D****", date: "11 Aralık 2025", time: "11:00", funeralTime: "İkindi", prayerInfo: "(Cenaze Namazı)", mosqueName: "Kocatepe Camii", city: "Ankara", burialPlace: "Karşıyaka Mezarlığı"),
    Person(name: "F**** K****", date: "10 Aralık 2025", time: "13:45", funeralTime: "Öğle", prayerInfo: "(Cenaze Namazı)", mosqueName: "Merkez Camii", city: "İzmir", burialPlace: "Hacılarkırı Mezarlığı"),
    Person(name: "M***** Ç******", date: "10 Aralık 2025", time: "14:20", funeralTime: "İkindi", prayerInfo: "(Cenaze Namazı)", mosqueName: "Selimiye Camii", city: "Edirne", burialPlace: "Şehir Mezarlığı"),
    Person(name: "H***** A*****", date: "10 Aralık 2025", time: "16:00", funeralTime: "Öğle", prayerInfo: "(Cenaze Namazı)", mosqueName: "Hacı Bayram Veli", city: "Ankara", burialPlace: "Gölbaşı Mezarlığı"),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color textColor = isDark ? Colors.white : AppTheme.textLight;

    final DateTime now = DateTime.now();
    final List<String> months = ["", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
    String dayNumber = now.day.toString();
    String monthName = months[now.month];
    String year = now.year.toString();

    return Scaffold(
      backgroundColor: bgColor, 
      appBar: AppBar(
        title: const Text("Ana Sayfa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.primary,
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
              color: AppTheme.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
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
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
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
                    FluidScale(
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24, width: 0.5),
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
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                            ),
                            child: Center(
                              child: Text(year, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                dayNumber,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textLight),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              monthName, 
                              style: TextStyle(fontSize: 9, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
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
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SADECE BUGÜNKÜ VEFATLAR KALDI
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Text("Bugünkü Vefatlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
                  ),
                  
                  _isLoading
                      ? ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 6,
                          itemBuilder: (context, index) => _PersonCardSkeleton(isDark: isDark),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _people.length,
                          itemBuilder: (context, index) {
                            final person = _people[index];
                            return _StaggeredCard(index: index, child: _PersonCard(person: person));
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

// --- İSKELET KART (Shimmer - PersonCard ile aynı boyut) ---
class _PersonCardSkeleton extends StatelessWidget {
  final bool isDark;

  const _PersonCardSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? Colors.white10 : Colors.grey[300]!;
    final highlightColor = isDark
        ? AppTheme.primary.withValues(alpha: 0.15)
        : AppTheme.primary.withValues(alpha: 0.2);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      direction: ShimmerDirection.ltr,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 160,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 88,
                height: 48,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- STAGGERED YÜKLEME (FadeIn + 10px Slide, 400ms, easeOutQuart) ---
class _StaggeredCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredCard({required this.index, required this.child});

  @override
  State<_StaggeredCard> createState() => _StaggeredCardState();
}

class _StaggeredCardState extends State<_StaggeredCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

// --- VEFAT EDEN KİŞİ KARTI (FluidScale, ripple yok) ---
class _PersonCard extends StatelessWidget {
  final Person person;
  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color cardColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    Color textColor = isDark ? Colors.white : AppTheme.textLight;
    Color subTextColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;

    return FluidScale(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PersonDetailScreen(person: person))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: Colors.white12, width: 0.5) : null,
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 1, offset: const Offset(0, 1))],
        ),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.tintAvatarBg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      person.name.isNotEmpty ? person.name[0].toUpperCase() : "?",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(person.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('${person.mosqueName}, ${person.city}', style: TextStyle(fontSize: 13, color: subTextColor, fontWeight: FontWeight.w400)),
                      const SizedBox(height: 2),
                      Text('${person.funeralTime} Vakti', style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: const BoxConstraints(minHeight: 48),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Detay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            ),
        ),
      ),
    );
  }
}