// ============================================================================
// DOSYA: imam_panel_screen.dart
// AÇIKLAMA: İmamların sisteme yeni vefat ilanı girdiği yönetim paneli sayfası.
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
  DateTime _selectedFuneralDate = DateTime.now(); // Yeni Eklendi: Cenaze Tarihi
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0); // Cenaze Saati

  List<String> _districts = [];
  List<String> _neighborhoods = [];
  List<String> _availableMosques = [];

  final List<String> _cemeteries = [
    'Edirnekapı Şehitliği',
    'Emirsultan Mezarlığı',
    'Gölbaşı Mezarlığı',
    'Hacılarkırı Mezarlığı',
    'Karşıyaka Mezarlığı',
    'Kozlu Mezarlığı',
    'Zincirlikuyu Mezarlığı',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // YARDIMCI FONKSİYONLAR (TARİH VE SAAT SEÇİCİLER)
  // ---------------------------------------------------------------------------

  /// Vefat Tarihi Seçici
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), 
      lastDate: DateTime(2030),  
      builder: (context, child) {
        // Klavyede beyaz yazı sorununu çözmek için ThemeData.light() ile sarmaladık
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E7228), 
              onPrimary: Colors.white,
              onSurface: Colors.black, // Takvimdeki genel yazılar
            ),
            // Klavyeyle giriş (manual entry) yaparken metnin siyah olması için:
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

  /// Cenaze Tarihi Seçici (Yeni Eklendi)
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
      setState(() => _selectedFuneralDate = picked);
    }
  }

  /// Cenaze Saati Seçici
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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

      if (_selectedCity != null && val != null) {
        _neighborhoods =
            GlobalData.turkeyLocationData[_selectedCity]![val] ?? [];
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
      date: formattedDate, // Vefat Tarihi
      time: formattedFuneralDate, // Cenaze Tarihi ('time' parametresine yazdırıyoruz)
      funeralTime: formattedTime, // Cenaze Saati
      prayerInfo: '', 
      mosqueName: _selectedMosque!,
      city: _selectedCity!,
      burialPlace: _selectedBurialPlace!,
    );

    GlobalData.addPerson(newPerson).then((_) {
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Vefat ilanı sisteme başarıyla kaydedildi!"),
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
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            const Icon(Icons.mosque, size: 64, color: Color(0xFF1E7228)),
            const SizedBox(height: 12),
            Text(
              "Yeni Vefat İlanı Girişi",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 24),

            // 1. İsim Girişi
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

            // 2. Vefat Tarihi (Üstte, tam genişlikte)
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

            // 3. Cenaze Tarihi ve Cenaze Saati (Yan yana)
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
                        prefixIcon: Icon(Icons.event, color: iconColor), // Farklı bir takvim ikonu
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

            // 4. İl ve İlçe Seçimi 
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: "İl",
                    value: _selectedCity,
                    items: GlobalData.turkeyLocationData.keys.toList()..sort((a, b) => a.compareTo(b)),
                    onChanged: _onCityChanged,
                    icon: Icons.location_city,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: "İlçe",
                    value: _selectedDistrict,
                    items: _districts,
                    onChanged: _onDistrictChanged,
                    icon: Icons.location_on_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 5. Mahalle Seçimi
            _buildDropdown(
              context,
              label: "Mahalle",
              value: _selectedNeighborhood,
              items: _neighborhoods,
              onChanged: (val) => setState(() => _selectedNeighborhood = val),
              icon: Icons.map,
            ),

            const SizedBox(height: 16),

            // 6. Cami Seçimi
            _buildDropdown(
              context,
              label: "Cami Seçiniz",
              value: _selectedMosque,
              items: _availableMosques,
              onChanged: (val) => setState(() => _selectedMosque = val),
              icon: Icons.mosque_outlined,
            ),

            const SizedBox(height: 16),

            // 7. Defin Yeri Seçimi
            _buildDropdown(
              context,
              label: "Defin Yeri (Mezarlık)",
              value: _selectedBurialPlace,
              items: _cemeteries,
              onChanged: (val) => setState(() => _selectedBurialPlace = val),
              icon: Icons.park,
            ),

            const SizedBox(height: 32),

            // 8. Kaydet Butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveFuneral,
                icon: const Icon(Icons.save_alt, size: 24),
                label: const Text(
                  "İlanı Yayınla ve Kaydet",
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
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color cardColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color dropdownBg = isDark ? Colors.grey[850]! : Colors.white;
    Color labelColor = isDark ? Colors.white70 : Colors.black54;

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true, 
      dropdownColor: dropdownBg,
      style: TextStyle(color: textColor, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor), 
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF1E7228)) : null,
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