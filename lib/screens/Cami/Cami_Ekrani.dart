import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import '../../data/global_data.dart';
import '../../models/app_models.dart';
import 'cami_detaylari.dart';

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
                  border: Border.all(color: const Color(0xFF1E7228), width: 1),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
                ),
                child: Text(
                  name, 
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.location_on, color: Color(0xFF1E7228), size: 40, shadows: [Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))]),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Favorilere eklendi!"), backgroundColor: Color(0xFF1E7228)));
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
    Color sheetColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Klavye açılınca harita sıkışmasın
      appBar: AppBar(
        title: const Text("Camiler ve Harita", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E7228),
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
                color: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.all(12.0),
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
                        Expanded(flex: 1, child: Container(height: 48, decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.1))), child: IconButton(onPressed: _resetFilters, icon: const Icon(Icons.refresh, color: Colors.redAccent), tooltip: 'Temizle'))),
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
                            height: 45,
                            child: ElevatedButton.icon(
                              onPressed: _openFavoritesScreen,
                              icon: const Icon(Icons.favorite, color: Colors.white),
                              label: const Text("FAVORİ CAMİLER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E7228),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text("Tüm Camiler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                        ],
                      ),
                    ),

                    // CAMİ LİSTESİ
                    _displayedMosques.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(child: Text("Cami bulunamadı.", style: TextStyle(color: textColor.withValues(alpha: 0.6)))),
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
    Color bgColor = isDark ? Colors.grey[850]! : Colors.white;
    Color txtColor = isDark ? Colors.white : Colors.black;
    return Container(
      height: 48, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.withValues(alpha: 0.4))),
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
    Color cardBg = isDark ? Colors.grey[900]! : const Color(0xFFC8E6C9).withValues(alpha: 0.5);
    Color titleColor = isDark ? Colors.white : Colors.black;
    Color subColor = isDark ? Colors.grey[400]! : Colors.grey[800]!;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MosqueDetailScreen(mosque: mosque))),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12.0), padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12.0), border: isDark ? Border.all(color: Colors.grey[800]!) : null),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: const Icon(Icons.mosque, color: Color(0xFF1E7228), size: 30)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(mosque.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor)), 
                const SizedBox(height: 4), 
                Row(children: [Icon(Icons.location_on_outlined, size: 14, color: subColor), const SizedBox(width: 4), Expanded(child: Text('${mosque.district} / ${mosque.city}', style: TextStyle(fontSize: 12, color: subColor), overflow: TextOverflow.ellipsis))]),
                Text(mosque.neighborhood, style: TextStyle(fontSize: 12, color: subColor, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis)
              ])),
              const Padding(padding: EdgeInsets.only(right: 30.0), child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
            ]),
          ),
          Positioned(top: 0, right: 0, child: IconButton(icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: isFavorite ? Colors.amber : Colors.grey, size: 30), onPressed: onFavoriteToggle)),
        ],
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
        title: const Text("Favori Camilerim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E7228),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _favoriteMosques.isEmpty
          ? Center(child: Text("Henüz favori cami eklemediniz.", style: TextStyle(color: textColor.withValues(alpha: 0.6))))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _favoriteMosques.length,
              itemBuilder: (context, index) {
                final mosque = _favoriteMosques[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: isDark ? Colors.grey[850] : Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.mosque, color: Color(0xFF1E7228), size: 30),
                    title: Text(mosque.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    subtitle: Text(mosque.neighborhood, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _removeFromFavorites(mosque.id),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MosqueDetailScreen(mosque: mosque))),
                  ),
                );
              },
            ),
    );
  }
}