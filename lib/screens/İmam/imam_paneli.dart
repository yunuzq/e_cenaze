import 'package:flutter/material.dart';
import '../../data/global_data.dart';
import '../../models/app_models.dart';
import '../Giris Ekranlari/giris.dart'; // Giriş sayfasına dönüş için doğru import

class ImamPanelScreen extends StatefulWidget {
  const ImamPanelScreen({super.key});

  @override
  State<ImamPanelScreen> createState() => _ImamPanelScreenState();
}

class _ImamPanelScreenState extends State<ImamPanelScreen> {
  final TextEditingController _nameController = TextEditingController();

  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedNeighborhood;
  String? _selectedMosque;
  String? _selectedBurialPlace;
  String _selectedPrayerTime = "Öğle Namazı";

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);

  List<String> _districts = [];
  List<String> _neighborhoods = [];
  List<String> _availableMosques = [];

  final List<String> _prayerTimes = [
    "Öğle Namazı",
    "İkindi Namazı",
    "Cuma Namazı",
    "Cenaze Namazı",
  ];

  // Mezarlıkları alfabetik sıralayalım
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

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E7228), // Takvim başlığı yeşil
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E7228),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _onCityChanged(String? val) {
    setState(() {
      _selectedCity = val;
      _selectedDistrict = null;
      _selectedNeighborhood = null;
      _selectedMosque = null;

      // Şehir değişince ilçeleri getir ve ALFABETİK SIRALA
      if (val != null) {
        _districts = GlobalData.turkeyLocationData[val]!.keys.toList();
        _districts.sort((a, b) => a.compareTo(b)); // A-Z Sıralama
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
        // Mahalleleri getir ve ALFABETİK SIRALA
        _neighborhoods =
            GlobalData.turkeyLocationData[_selectedCity]![val] ?? [];
        _neighborhoods.sort((a, b) => a.compareTo(b)); // A-Z Sıralama
        _updateAvailableMosques();
      } else {
        _neighborhoods = [];
        _availableMosques = [];
      }
    });
  }

  void _updateAvailableMosques() {
    // Camileri filtrele ve ALFABETİK SIRALA
    _availableMosques = GlobalData.mosques
        .where(
          (m) => m.city == _selectedCity && m.district == _selectedDistrict,
        )
        .map((m) => m.name)
        .toList();

    _availableMosques.sort((a, b) => a.compareTo(b)); // A-Z Sıralama

    if (_availableMosques.isEmpty) {
      _availableMosques.add("Merkez Camii (Varsayılan)");
  }
  }

  
 
  void _saveFuneral() {
    if (_nameController.text.isEmpty ||
        _selectedCity == null ||
        _selectedDistrict == null ||
        _selectedMosque == null ||
        _selectedBurialPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları seçiniz."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String formattedDate =
        "${_selectedDate.day} ${_selectedDate.month} ${_selectedDate.year}";
    String formattedTime =
        "${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}";

    final newPerson = Person(
      name: _nameController.text.toUpperCase(),
      date: formattedDate,
      time: "Belirtilmedi",
      funeralTime: formattedTime,
      prayerInfo: '($_selectedPrayerTime)',
      mosqueName: _selectedMosque!,
      city: _selectedCity!,
      burialPlace: _selectedBurialPlace!,
      cenazeSaati: "Belirtilmedi"
    );

    GlobalData.addPerson(newPerson).then((_) {
      if (!mounted) return; // 👈 Güvenlik kontrolü
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vefat ilanı sisteme kaydedildi!"),
          backgroundColor: Color(0xFF1E7228),
        ),
      );
    });

    // Eğer cami daha önce yoksa listeye ekle (Basit mantık)
    bool mosqueExists = GlobalData.mosques.any(
      (m) => m.name == _selectedMosque,
    );
    if (!mosqueExists) {
      final newMosque = Mosque(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _selectedMosque!,
        city: _selectedCity!,
        district: _selectedDistrict!,
        neighborhood: _selectedNeighborhood ?? "Merkez",
        history: "İmam tarafından eklendi.",
        imageUrls: [],
      );
      GlobalData.addMosque(newMosque);
    }

    // Formu temizle
    _nameController.clear();
    setState(() {
      _selectedMosque = null;
      _selectedBurialPlace = null;
      _selectedPrayerTime = "Öğle Namazı";
    });
  }

  void _logout() {
    // Çıkış yapınca Login ekranına at
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tema renklerini al
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? Colors.black : Colors.white;
    Color cardColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color iconColor = const Color(0xFF1E7228); // Bizim özel yeşil

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "İmam Yönetim Paneli",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.mosque, size: 60, color: Color(0xFF1E7228)),
            const SizedBox(height: 10),
            Text(
              "Yeni Vefat İlanı Girişi",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 20),

            // İsim Girişi
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Vefat Edenin Adı Soyadı",
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ), // withOpacity yerine sabit renk
                prefixIcon: Icon(Icons.person, color: iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cardColor,
              ),
            ),

            const SizedBox(height: 16),

            // Tarih ve Saat Seçimi
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Vefat Tarihi",
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: iconColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: cardColor,
                      ),
                      child: Text(
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(context),
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
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // İl ve İlçe
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: "İl",
                    value: _selectedCity,
                    items: GlobalData.turkeyLocationData.keys.toList()
                      ..sort((a, b) => a.compareTo(b)),
                    onChanged: _onCityChanged,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: "İlçe",
                    value: _selectedDistrict,
                    items: _districts,
                    onChanged: _onDistrictChanged,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Mahalle ve Namaz Vakti
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: "Mahalle",
                    value: _selectedNeighborhood,
                    items: _neighborhoods,
                    onChanged: (val) =>
                        setState(() => _selectedNeighborhood = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    context,
                    label: "Namaz Vakti",
                    value: _selectedPrayerTime,
                    items: _prayerTimes,
                    onChanged: (val) =>
                        setState(() => _selectedPrayerTime = val!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Cami Seçimi
            _buildDropdown(
              context,
              label: "Cami Seçiniz",
              value: _selectedMosque,
              items: _availableMosques,
              onChanged: (val) => setState(() => _selectedMosque = val),
              icon: Icons.mosque,
            ),

            const SizedBox(height: 16),

            // Mezarlık Seçimi
            _buildDropdown(
              context,
              label: "Defin Yeri (Mezarlık)",
              value: _selectedBurialPlace,
              items: _cemeteries,
              onChanged: (val) => setState(() => _selectedBurialPlace = val),
              icon: Icons.place,
            ),

            const SizedBox(height: 30),

            // Kaydet Butonu
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _saveFuneral,
                icon: const Icon(Icons.save),
                label: const Text(
                  "İlanı Yayınla ve Kaydet",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E7228), // Bizim Yeşil
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ),
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

    // --- BURASI DÜZELTİLDİ: withOpacity YERİNE SABİT RENK ---
    Color labelColor = isDark ? Colors.white70 : Colors.black54;

    return DropdownButtonFormField<String>(
      initialValue: "...",
      isExpanded: true,
      dropdownColor: dropdownBg,
      style: TextStyle(color: textColor, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor), // Hata veren yer çözüldü
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFF1E7228))
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: cardColor,
      ),
      items: items
          .map(
            (String item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
