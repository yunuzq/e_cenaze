// ============================================================================
// DOSYA: imam_panel_screen.dart
// AÇIKLAMA: İmamların sisteme yeni cenaze haberi girdiği yönetim paneli sayfası.
// ============================================================================

import 'package:flutter/material.dart';
import '../../data/global_data.dart';
import '../../models/app_models.dart';

class ImamPanelScreen extends StatefulWidget {
  const ImamPanelScreen({super.key});

  @override
  State<ImamPanelScreen> createState() => _ImamPanelScreenState();
}

class _ImamPanelScreenState extends State<ImamPanelScreen> {
  // ---------------------------------------------------------------------------
  // KULLANICI GİRİŞ KONTROLLERİ VE DEĞİŞKENLER
  // ---------------------------------------------------------------------------
  
  final TextEditingController _nameController = TextEditingController();

  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedNeighborhood;
  String? _selectedMosque;
  String? _selectedBurialPlace;

  // Tarih ve saat değişkenleri
  DateTime _selectedDate = DateTime.now(); // Vefat Tarihi
  DateTime _selectedFuneralDate = DateTime.now(); // Cenaze Tarihi
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0); // Cenaze Saati

  List<String> _districts = [];
  List<String> _neighborhoods = [];
  List<String> _availableMosques = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // YARDIMCI FONKSİYONLAR (TARİH VE SAAT SEÇİCİLER)
  // ---------------------------------------------------------------------------

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), 
      lastDate: DateTime(2030),  
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E7228), 
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textTheme: const TextTheme(
              titleMedium: TextStyle(color: Colors.black, fontSize: 16), 
              bodyLarge: TextStyle(color: Colors.black),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.black87),
              hintStyle: TextStyle(color: Colors.black54),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickFuneralDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFuneralDate,
      firstDate: DateTime(2000), 
      lastDate: DateTime(2030),  
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E7228), 
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textTheme: const TextTheme(
              titleMedium: TextStyle(color: Colors.black, fontSize: 16), 
              bodyLarge: TextStyle(color: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedFuneralDate = picked);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      initialEntryMode: TimePickerEntryMode.input, 
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E7228),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), 
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // ---------------------------------------------------------------------------
  // DEĞİŞİM DİNLEYİCİLERİ
  // ---------------------------------------------------------------------------

  void _onCityChanged(String? val) {
    setState(() {
      _selectedCity = val;
      _selectedDistrict = null;
      _selectedNeighborhood = null;
      _selectedMosque = null;
      _selectedBurialPlace = null; 

      if (val != null) {
        _districts = GlobalData.turkeyLocationData[val]!.keys.toList();
        _districts.sort((a, b) => a.compareTo(b));
      } else {
        _districts = [];
      }
      _neighborhoods = [];
      _availableMosques = [];
    });
  }

  void _onDistrictChanged(String? val) {
    setState(() {
      _selectedDistrict = val;
      _selectedNeighborhood = null;
      _selectedMosque = null;
      _selectedBurialPlace = null; 

      if (_selectedCity != null && val != null) {
        _neighborhoods = GlobalData.turkeyLocationData[_selectedCity]![val] ?? [];
        _neighborhoods.sort((a, b) => a.compareTo(b)); 
        _updateAvailableMosques();
      } else {
        _neighborhoods = [];
        _availableMosques = [];
      }
    });
  }

  void _updateAvailableMosques() {
    _availableMosques = GlobalData.mosques
        .where((m) => m.city == _selectedCity && m.district == _selectedDistrict)
        .map((m) => m.name)
        .toList();

    _availableMosques.sort((a, b) => a.compareTo(b)); 

    if (_availableMosques.isEmpty) {
      _availableMosques.add("Merkez Camii (Varsayılan)");
    }
  }

  // ---------------------------------------------------------------------------
  // VERİ KAYDETME
  // ---------------------------------------------------------------------------

  void _saveFuneral() {
    if (_nameController.text.isEmpty ||
        _selectedCity == null ||
        _selectedDistrict == null ||
        _selectedMosque == null ||
        _selectedBurialPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm zorunlu alanları eksiksiz doldurunuz."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return; 
    }

    String formattedDate = "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
    String formattedFuneralDate = "${_selectedFuneralDate.day}/${_selectedFuneralDate.month}/${_selectedFuneralDate.year}";
    String formattedTime = "${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}";

    final newPerson = Person(
      name: _nameController.text.toUpperCase(),
      date: formattedDate, 
      time: formattedFuneralDate, 
      funeralTime: formattedTime, 
      prayerInfo: '', 
      mosqueName: _selectedMosque!,
      city: _selectedCity!,
      burialPlace: _selectedBurialPlace!,
    );

    GlobalData.addPerson(newPerson).then((_) {
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Cenaze haberi sisteme başarıyla kaydedildi!"),
          backgroundColor: Color(0xFF1E7228),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    bool mosqueExists = GlobalData.mosques.any((m) => m.name == _selectedMosque);
    if (!mosqueExists) {
      final newMosque = Mosque(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _selectedMosque!,
        city: _selectedCity!,
        district: _selectedDistrict!,
        neighborhood: _selectedNeighborhood ?? "Merkez",
        history: "İmam yönetim paneli tarafından otomatik eklendi.",
        imageUrls: [],
      );
      GlobalData.addMosque(newMosque);
    }

    _nameController.clear();
    setState(() {
      _selectedMosque = null;
      _selectedBurialPlace = null;
    });
  }

  // ---------------------------------------------------------------------------
  // ARAYÜZ OLUŞTURMA
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? Colors.black : Colors.white;
    Color cardColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color iconColor = const Color(0xFF1E7228); 

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "İmam Yönetim Paneli",
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5, 
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            const Icon(Icons.mosque, size: 64, color: Color(0xFF1E7228)),
            const SizedBox(height: 12),
            Text(
              "Yeni Cenaze Haberi Girişi",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              textCapitalization: TextCapitalization.words, 
              decoration: InputDecoration(
                labelText: "Vefat Edenin Adı Soyadı",
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ), 
                prefixIcon: Icon(Icons.person, color: iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cardColor,
              ),
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: "Vefat Tarihi",
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  prefixIcon: Icon(Icons.calendar_today, color: iconColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: cardColor,
                ),
                child: Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickFuneralDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Cenaze Tarihi",
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        prefixIcon: Icon(Icons.event, color: iconColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: cardColor,
                      ),
                      child: Text(
                        "${_selectedFuneralDate.day}/${_selectedFuneralDate.month}/${_selectedFuneralDate.year}",
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(context),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Cenaze Saati",
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        prefixIcon: Icon(Icons.access_time, color: iconColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: cardColor,
                      ),
                      child: Text(
                        "${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: "İl",
                    value: _selectedCity,
                    items: GlobalData.turkeyLocationData.keys.toList()..sort((a, b) => a.compareTo(b)),
                    onChanged: _onCityChanged,
                    onClear: () => _onCityChanged(null), 
                    icon: Icons.location_city,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: _selectedCity == null ? "İlçe (İl Seçiniz)" : "İlçe", 
                    value: _selectedDistrict,
                    items: _districts,
                    onChanged: _selectedCity == null ? null : _onDistrictChanged,
                    onClear: () => _onDistrictChanged(null), 
                    icon: Icons.location_on_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildDropdown(
              context,
              label: _selectedDistrict == null ? "Mahalle (İlçe Seçiniz)" : "Mahalle", 
              value: _selectedNeighborhood,
              items: _neighborhoods,
              onChanged: _selectedDistrict == null ? null : (val) => setState(() => _selectedNeighborhood = val),
              onClear: () => setState(() => _selectedNeighborhood = null), 
              icon: Icons.map,
            ),

            const SizedBox(height: 16),

            _buildDropdown(
              context,
              label: _selectedDistrict == null ? "Cami (İlçe Seçiniz)" : "Cami Seçiniz", 
              value: _selectedMosque,
              items: _availableMosques,
              onChanged: _selectedDistrict == null ? null : (val) => setState(() => _selectedMosque = val),
              onClear: () => setState(() => _selectedMosque = null), 
              icon: Icons.mosque_outlined,
            ),

            const SizedBox(height: 16),

            _buildDropdown(
              context,
              label: _selectedDistrict == null ? "Defin Yeri (Önce İlçe Seçiniz)" : "Defin Yeri (Mezarlık)", 
              value: _selectedBurialPlace,
              items: _selectedDistrict == null ? [] : (GlobalData.cemeteriesData[_selectedCity]?[_selectedDistrict] ?? ['Merkez Mezarlığı']),
              onChanged: _selectedDistrict == null ? null : (val) => setState(() => _selectedBurialPlace = val), 
              onClear: () => setState(() => _selectedBurialPlace = null), 
              icon: Icons.park,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveFuneral,
                child: const Text(
                  "Cenaze Haberini Yayınla",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E7228), 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), 
                  ),
                  elevation: 4, 
                ),
              ),
            ),
            const SizedBox(height: 30), 
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged, 
    VoidCallback? onClear, 
    IconData? icon,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color cardColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color dropdownBg = isDark ? Colors.grey[850]! : Colors.white;

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true, 
      dropdownColor: dropdownBg,
      style: TextStyle(color: textColor, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54), 
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF1E7228)) : null,
        suffixIcon: value != null && onClear != null
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                onPressed: onClear,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: cardColor,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textColor),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}