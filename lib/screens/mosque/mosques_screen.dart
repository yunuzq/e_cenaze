import 'package:flutter/material.dart';
import '../../data/global_data.dart';
import '../../models/app_models.dart';
import '../../widgets/common_widgets.dart';
import 'mosque_detail_screen.dart';

class MosquesScreen extends StatefulWidget {
  const MosquesScreen({super.key});

  @override
  State<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends State<MosquesScreen> {
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedNeighborhood;
  List<String> _districtsForDropdown = [];
  List<String> _neighborhoodsForDropdown = [];
  List<Mosque> _displayedMosques = [];

  @override
  void initState() {
    super.initState();
    _displayedMosques = GlobalData.mosques; 
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // İL ve İLÇE Yan Yana
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        hint: 'İl Seçiniz',
                        value: _selectedCity,
                        // DÜZELTİLDİ: GlobalData.turkeyLocationData
                        items: GlobalData.turkeyLocationData.keys.toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCity = val;
                            _selectedDistrict = null;
                            _selectedNeighborhood = null;
                            // DÜZELTİLDİ: GlobalData.turkeyLocationData
                            _districtsForDropdown = val != null ? GlobalData.turkeyLocationData[val]!.keys.toList() : [];
                            _neighborhoodsForDropdown = [];
                            _filterMosques();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        hint: 'İlçe Seçiniz',
                        value: _selectedDistrict,
                        items: _districtsForDropdown,
                        onChanged: (val) {
                          setState(() {
                            _selectedDistrict = val;
                            _selectedNeighborhood = null;
                            if (_selectedCity != null && val != null) {
                               // DÜZELTİLDİ: GlobalData.turkeyLocationData
                              _neighborhoodsForDropdown = GlobalData.turkeyLocationData[_selectedCity]![val] ?? [];
                            } else {
                              _neighborhoodsForDropdown = [];
                            }
                            _filterMosques();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // MAHALLE ve SIFIRLA BUTONU
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(
                        hint: 'Mahalle Seçiniz',
                        value: _selectedNeighborhood,
                        items: _neighborhoodsForDropdown,
                        onChanged: (val) {
                          setState(() {
                            _selectedNeighborhood = val;
                            _filterMosques();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.refresh, color: Colors.redAccent),
                          tooltip: 'Filtreleri Temizle',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _displayedMosques.isEmpty
                ? const Center(child: Text("Kriterlere uygun cami bulunamadı.", style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    itemCount: _displayedMosques.length,
                    itemBuilder: (context, index) {
                      final mosque = _displayedMosques[index];
                      return _MosqueCard(mosque: mosque);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MosqueCard extends StatelessWidget {
  final Mosque mosque;
  const _MosqueCard({required this.mosque});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MosqueDetailScreen(mosque: mosque))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(color: const Color(0xFFC8E6C9).withOpacity(0.9), borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: [
            const Icon(Icons.mosque, color: Colors.black, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mosque.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text('${mosque.district} / ${mosque.city}', style: TextStyle(fontSize: 12, color: Colors.grey[800])),
                  Text(mosque.neighborhood, style: TextStyle(fontSize: 12, color: Colors.grey[800], fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}