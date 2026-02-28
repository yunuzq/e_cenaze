import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/global_data.dart';
import '../../models/app_models.dart';
import '../../theme/app_theme.dart';
import 'Cami_Detaylari.dart';

class MosquesScreen extends StatefulWidget {
  const MosquesScreen({super.key});

  @override
  State<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends State<MosquesScreen> {
  // HARİTA AYARLARI
  final MapController _mapController = MapController();
  final LatLng _initialCenter = const LatLng(41.0082, 28.9784); // İstanbul

  // FİLTRE DEĞİŞKENLERİ
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedNeighborhood;
  
  List<String> _districtsForDropdown = [];
  List<String> _neighborhoodsForDropdown = [];
  List<Mosque> _displayedMosques = [];

  List<Marker> _markers = [];

  // Haritadaki İkonlar
  final Map<String, LatLng> _mosqueCoordinates = {
    "Ayasofya-i Kebir Cami-i Şerifi": const LatLng(41.0086, 28.9802),
    "Kocatepe Camii": const LatLng(39.9166, 32.8607),
    "Süleymaniye Camii": const LatLng(41.0162, 28.9638),
    "Çoban Mustafa Paşa Cami": const LatLng(40.8026, 29.4308),
    "Bursa Ulu Cami": const LatLng(40.1826, 29.0630),
    // Yeni eklenen camiler
    "Selimiye Camii": const LatLng(41.6771, 26.5558),
    "Sultanahmet Camii": const LatLng(41.0054, 28.9768),
    "Fatih Camii": const LatLng(41.0190, 28.9497),
    "Hacı Bayram-ı Veli Camii": const LatLng(39.9439, 32.8560),
    "Konak Yalı Camii": const LatLng(38.4192, 27.1287),
    "Sabancı Merkez Camii": const LatLng(37.0022, 35.3289),
    "Melike Hatun Camii": const LatLng(39.9304, 32.8555),
    "Muradiye Camii": const LatLng(40.1910, 29.0473),
    "İplikçi (Mevlana) Camii": const LatLng(37.8724, 32.4988),
    "Diyarbakır Ulu Cami": const LatLng(37.9137, 40.2362),
  };

  @override
  void initState() {
    super.initState();
    _displayedMosques = GlobalData.mosques;
    _createMosqueMarkers();
  }

  void _createMosqueMarkers() {
    _markers = [];
    _mosqueCoordinates.forEach((name, latlng) {
      _markers.add(
        Marker(
          point: latlng,
          width: 80,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.primary, width: 1),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1, offset: Offset(0, 1))],
                ),
                child: Text(
                  name, 
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 36),
            ],
          ),
        ),
      );
    });
  }

  void _filterMosques() {
    setState(() {
      _displayedMosques = GlobalData.mosques.where((mosque) {
        final cityMatch = _selectedCity == null || mosque.city == _selectedCity;
        final districtMatch = _selectedDistrict == null || mosque.district == _selectedDistrict;
        final neighborhoodMatch = _selectedNeighborhood == null || mosque.neighborhood == _selectedNeighborhood;
        return cityMatch && districtMatch && neighborhoodMatch;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCity = null;
      _selectedDistrict = null;
      _selectedNeighborhood = null;
      _districtsForDropdown = [];
      _neighborhoodsForDropdown = [];
      _displayedMosques = GlobalData.mosques;
    });
  }

  void _toggleFavorite(String mosqueId) {
    setState(() {
      if (GlobalData.favoriteMosqueIds.contains(mosqueId)) {
        GlobalData.favoriteMosqueIds.remove(mosqueId);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Favorilerden çıkarıldı.")));
      } else {
        GlobalData.favoriteMosqueIds.add(mosqueId);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Favorilere eklendi!"), backgroundColor: AppTheme.primary));
      }
      GlobalData.saveFavorites(); 
    });
  }

  void _openFavoritesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoriteMosquesScreen()),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    List<String> cities = GlobalData.turkeyLocationData.keys.toList()..sort();
    
    // Panel renkleri
    Color sheetColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Klavye açılınca harita sıkışmasın
      appBar: AppBar(
        title: const Text("Camiler ve Harita", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.primary,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // ---------------------------------------------
          // KATMAN 1: ARKA PLAN (FİLTRELER + HARİTA)
          // ---------------------------------------------
          Column(
            children: [
              // FİLTRELER KISMI (Sabit kalsın istedik)
              Container(
                color: isDark ? AppTheme.bgDark : AppTheme.bgLight,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            hint: 'İl Seçiniz', value: _selectedCity, items: cities,
                            onChanged: (val) {
                              setState(() {
                                _selectedCity = val; _selectedDistrict = null; _selectedNeighborhood = null;
                                if (val != null && GlobalData.turkeyLocationData.containsKey(val)) {
                                  _districtsForDropdown = GlobalData.turkeyLocationData[val]!.keys.toList()..sort();
                                } else { _districtsForDropdown = []; }
                                _neighborhoodsForDropdown = []; _filterMosques();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDropdown(
                            hint: 'İlçe Seçiniz', value: _selectedDistrict, items: _districtsForDropdown,
                            onChanged: (val) {
                              setState(() {
                                _selectedDistrict = val; _selectedNeighborhood = null;
                                if (_selectedCity != null && val != null) {
                                  _neighborhoodsForDropdown = (GlobalData.turkeyLocationData[_selectedCity]![val] ?? [])..sort();
                                } else { _neighborhoodsForDropdown = []; }
                                _filterMosques();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(flex: 3, child: _buildDropdown(hint: 'Mahalle Seçiniz', value: _selectedNeighborhood, items: _neighborhoodsForDropdown, onChanged: (val) { setState(() { _selectedNeighborhood = val; _filterMosques(); }); })),
                        const SizedBox(width: 8),
                        Expanded(flex: 1, child: Container(height: 48, decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent.withOpacity(0.5))), child: IconButton(onPressed: _resetFilters, icon: const Icon(Icons.refresh, color: Colors.redAccent), tooltip: 'Temizle'))),
                      ],
                    ),
                  ],
                ),
              ),
              
              // HARİTA (Geri kalan tüm alanı kaplasın)
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: 9.0,
                    // Tüm temel etkileşimler açık, sadece rotate kapalı
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ecenaze.app',
                    ),
                    MarkerLayer(markers: _markers),
                  ],
                ),
              ),
            ],
          ),

          // ---------------------------------------------
          // KATMAN 2: KAYDIRILABİLİR LİSTE (DraggableScrollableSheet)
          // ---------------------------------------------
          DraggableScrollableSheet(
            initialChildSize: 0.40, // Başlangıçta ekranın %40'ı kadar olsun
            minChildSize: 0.15,     // Aşağı inince en az %15 kalsın (sadece başlık görünsün diye)
            maxChildSize: 0.90,     // Yukarı çekince ekranın %90'ına kadar çıksın
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: sheetColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, -2),
                    )
                  ],
                ),
                child: ListView(
                  controller: scrollController, // Panel ile listenin senkron kayması için
                  padding: EdgeInsets.zero,
                  children: [
                    // GRİ TUTAMAÇ ÇİZGİSİ (Kullanıcı çekebileceğini anlasın)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // FAVORİ BUTONU VE BAŞLIK (Listenin en tepesinde kalsın)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _openFavoritesScreen,
                              icon: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                              label: const Text("FAVORİ CAMİLER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text("Tüm Camiler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
                        ],
                      ),
                    ),

                    // CAMİ LİSTESİ
                    _displayedMosques.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(child: Text("Cami bulunamadı.", style: TextStyle(color: textColor.withOpacity(0.6)))),
                          )
                        : ListView.builder(
                            controller: scrollController, // İç liste scroll kontrolü
                            shrinkWrap: true, // İç içe liste hatasını önler
                            physics: const ClampingScrollPhysics(), // Kaydırma fiziği
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _displayedMosques.length,
                            itemBuilder: (context, index) {
                              final mosque = _displayedMosques[index];
                              final isFavorite = GlobalData.favoriteMosqueIds.contains(mosque.id);
                              return _MosqueCard(
                                mosque: mosque,
                                isFavorite: isFavorite,
                                onFavoriteToggle: () => _toggleFavorite(mosque.id),
                              );
                            },
                          ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    Color txtColor = isDark ? Colors.white : AppTheme.textLight;
    return Container(
      height: 48, padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300, width: isDark ? 0.5 : 1),
      ),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, hint: Text(hint, style: TextStyle(fontSize: 14, color: Colors.grey)), isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey), dropdownColor: bgColor, style: TextStyle(color: txtColor), items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(), onChanged: onChanged)),
    );
  }
}

class _MosqueCard extends StatelessWidget {
  final Mosque mosque;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  const _MosqueCard({required this.mosque, required this.isFavorite, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color cardBg = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    Color titleColor = isDark ? Colors.white : AppTheme.textLight;
    Color subColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white12, width: 0.5) : null,
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 1, offset: const Offset(0, 1))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MosqueDetailScreen(mosque: mosque))),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.tintAvatarBg, shape: BoxShape.circle),
                    child: Icon(Icons.mosque_rounded, color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(mosque.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: titleColor)),
                    const SizedBox(height: 4),
                    Row(children: [Icon(Icons.location_on_outlined, size: 14, color: subColor), const SizedBox(width: 4), Expanded(child: Text('${mosque.district} / ${mosque.city}', style: TextStyle(fontSize: 13, color: subColor), overflow: TextOverflow.ellipsis))]),
                    Text(mosque.neighborhood, style: TextStyle(fontSize: 12, color: subColor, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis)
                  ])),
                  const Padding(padding: EdgeInsets.only(right: 36), child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
                ]),
              ),
              Positioned(top: 0, right: 0, child: IconButton(icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_border_rounded, color: isFavorite ? Colors.amber : Colors.grey, size: 24), onPressed: onFavoriteToggle)),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteMosquesScreen extends StatefulWidget {
  const FavoriteMosquesScreen({super.key});

  @override
  State<FavoriteMosquesScreen> createState() => _FavoriteMosquesScreenState();
}

class _FavoriteMosquesScreenState extends State<FavoriteMosquesScreen> {
  late List<Mosque> _favoriteMosques;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoriteMosques = GlobalData.mosques
          .where((m) => GlobalData.favoriteMosqueIds.contains(m.id))
          .toList();
    });
  }

  void _removeFromFavorites(String id) {
    setState(() {
      GlobalData.favoriteMosqueIds.remove(id);
      GlobalData.saveFavorites();
      _loadFavorites();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Favorilerden çıkarıldı.")));
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favori Camilerim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _favoriteMosques.isEmpty
          ? Center(child: Text("Henüz favori cami eklemediniz.", style: TextStyle(color: textColor.withOpacity(0.6))))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _favoriteMosques.length,
              itemBuilder: (context, index) {
                final mosque = _favoriteMosques[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? Border.all(color: Colors.white12, width: 0.5) : null,
                    boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 1, offset: const Offset(0, 1))],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: AppTheme.tintAvatarBg, shape: BoxShape.circle),
                        child: Icon(Icons.mosque_rounded, color: AppTheme.primary, size: 24),
                      ),
                      title: Text(mosque.name, style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),
                    subtitle: Text(mosque.neighborhood, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _removeFromFavorites(mosque.id),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MosqueDetailScreen(mosque: mosque))),
                  ),
                ),
                );
              },
            ),
    );
  }
}