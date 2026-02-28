// ============================================================================
// DOSYA: imam_panel_screen.dart
// AÇIKLAMA: İmamların sisteme yeni vefat ilanı girdiği yönetim paneli sayfası.
// GÜNCELLEMELER: Namaz vakti kaldırıldı, tarih çökme hatası çözüldü, 
// çıkış butonu temizlendi ve UI (kullanıcı arayüzü) modernize edildi.
// ============================================================================

import 'package:flutter/material.dart';
import '../../data/global_data.dart';
import '../../models/app_models.dart';
// import '../Giris Ekranlari/giris.dart'; // Çıkış butonu kalktığı için şimdilik inaktif

class ImamPanelScreen extends StatefulWidget {
  const ImamPanelScreen({super.key});

  @override
  State<ImamPanelScreen> createState() => _ImamPanelScreenState();
}

class _ImamPanelScreenState extends State<ImamPanelScreen> {
  // ---------------------------------------------------------------------------
  // KULLANICI GİRİŞ KONTROLLERİ VE DEĞİŞKENLER
  // ---------------------------------------------------------------------------
  
  // İsim girişi için kullanılan text kontrolcüsü
  final TextEditingController _nameController = TextEditingController();

  // Dropdown (açılır menü) seçimlerini tutan değişkenler
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedNeighborhood;
  String? _selectedMosque;
  String? _selectedBurialPlace;

  // Tarih ve saat varsayılan ayarları (Bugün ve 12:00 olarak başlar)
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);

  // Dinamik olarak dolacak listeler (İle/İlçeye göre değişir)
  List<String> _districts = [];
  List<String> _neighborhoods = [];
  List<String> _availableMosques = [];

  // Sistemde kayıtlı varsayılan mezarlıklar listesi (Alfabetik)
  final List<String> _cemeteries = [
    'Edirnekapı Şehitliği',
    'Emirsultan Mezarlığı',
    'Gölbaşı Mezarlığı',
    'Hacılarkırı Mezarlığı',
    'Karşıyaka Mezarlığı',
    'Kozlu Mezarlığı',
    'Zincirlikuyu Mezarlığı',
  ];

  // ---------------------------------------------------------------------------
  // BELLEK YÖNETİMİ
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    // Sayfa kapatıldığında bellek sızıntısını önlemek için controller'ı temizleriz
    _nameController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // YARDIMCI FONKSİYONLAR (TARİH VE SAAT SEÇİCİLER)
  // ---------------------------------------------------------------------------

  /// Kullanıcıya takvim penceresini açar ve tarih seçtirir.
  /// Çökme hatasını önlemek için firstDate 2000 yılına çekilmiştir.
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // GEÇMİŞ ZAMAN LİMİTİ: 2000 Yılı
      lastDate: DateTime(2030),  // GELECEK ZAMAN LİMİTİ: 2030 Yılı
      builder: (context, child) {
        // Takvimin tema renklerini uygulamamızın yeşiline uyduruyoruz
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
    // Eğer bir tarih seçildiyse, değişkeni güncelleriz
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Kullanıcıya saat penceresini açar ve saat seçtirir.
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        // Saat seçicinin tema renkleri (Yeşil konsept)
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
    // Eğer bir saat seçildiyse, değişkeni güncelleriz
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // DEĞİŞİM DİNLEYİCİLERİ (ON CHANGED EVENTS)
  // ---------------------------------------------------------------------------

  /// Şehir seçildiğinde tetiklenir, ilçeleri getirir.
  void _onCityChanged(String? val) {
    setState(() {
      _selectedCity = val;
      // Alt seçimleri sıfırlıyoruz ki eski ilin verileri kalmasın
      _selectedDistrict = null;
      _selectedNeighborhood = null;
      _selectedMosque = null;

      if (val != null) {
        // Yeni şehrin ilçelerini çekip A'dan Z'ye sıralıyoruz
        _districts = GlobalData.turkeyLocationData[val]!.keys.toList();
        _districts.sort((a, b) => a.compareTo(b));
      } else {
        _districts = [];
      }

      _neighborhoods = [];
      _availableMosques = [];
    });
  }

  /// İlçe seçildiğinde tetiklenir, mahalleleri ve camileri getirir.
  void _onDistrictChanged(String? val) {
    setState(() {
      _selectedDistrict = val;
      // Alt seçimleri sıfırlıyoruz
      _selectedNeighborhood = null;
      _selectedMosque = null;

      if (_selectedCity != null && val != null) {
        // Mahalleleri veritabanından çek ve sırala
        _neighborhoods =
            GlobalData.turkeyLocationData[_selectedCity]![val] ?? [];
        _neighborhoods.sort((a, b) => a.compareTo(b)); 
        // İlgili ilçedeki camileri güncelle
        _updateAvailableMosques();
      } else {
        _neighborhoods = [];
        _availableMosques = [];
      }
    });
  }

  /// Seçili il ve ilçeye göre camileri filtreler.
  void _updateAvailableMosques() {
    _availableMosques = GlobalData.mosques
        .where(
          (m) => m.city == _selectedCity && m.district == _selectedDistrict,
        )
        .map((m) => m.name)
        .toList();

    // Camileri alfabetik olarak diz
    _availableMosques.sort((a, b) => a.compareTo(b)); 

    // Eğer o bölgede hiç cami yoksa, varsayılan bir cami ekle
    if (_availableMosques.isEmpty) {
      _availableMosques.add("Merkez Camii (Varsayılan)");
    }
  }

  // ---------------------------------------------------------------------------
  // VERİ KAYDETME İŞLEMLERİ
  // ---------------------------------------------------------------------------

  /// Tüm bilgileri toplar ve sistemi yeni bir vefat ilanı olarak kaydeder.
  void _saveFuneral() {
    // 1. GÜVENLİK KONTROLÜ: Zorunlu alanların dolu olduğundan emin ol
    if (_nameController.text.isEmpty ||
        _selectedCity == null ||
        _selectedDistrict == null ||
        _selectedMosque == null ||
        _selectedBurialPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm zorunlu alanları eksiksiz doldurunuz."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating, // Biraz daha şık bir hata mesajı
        ),
      );
      return; // Eğer hata varsa kaydetme işlemini burada durdur
    }

    // 2. VERİ FORMATLAMA: Tarih ve saati okunabilir metin formatına çevir
    String formattedDate =
        "${_selectedDate.day} ${_selectedDate.month} ${_selectedDate.year}";
    String formattedTime =
        "${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}";

    // 3. MODEL OLUŞTURMA: Yeni bir Person nesnesi yarat
    final newPerson = Person(
      name: _nameController.text.toUpperCase(),
      date: formattedDate,
      time: "Belirtilmedi",
      funeralTime: formattedTime,
      prayerInfo: '', // Namaz vakti kaldırıldığı için bilerek boş bırakıldı
      mosqueName: _selectedMosque!,
      city: _selectedCity!,
      burialPlace: _selectedBurialPlace!,
    );

    // 4. KAYDETME: Veriyi global listeye ekle
    GlobalData.addPerson(newPerson).then((_) {
      if (!mounted) return; 
      // Başarılı olursa yeşil bir bildirim göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Vefat ilanı sisteme başarıyla kaydedildi!"),
          backgroundColor: Color(0xFF1E7228),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    // 5. EKSTRA İŞLEM: Eğer seçilen cami sistemde yoksa, onu da kaydet
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
        history: "İmam yönetim paneli tarafından otomatik eklendi.",
        imageUrls: [],
      );
      GlobalData.addMosque(newMosque);
    }

    // 6. EKRANI TEMİZLEME: Yeni bir kayıt için formu sıfırla
    _nameController.clear();
    setState(() {
      _selectedMosque = null;
      _selectedBurialPlace = null;
    });
  }

  // ---------------------------------------------------------------------------
  // ARAYÜZ (UI) OLUŞTURMA ALANI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Tema renklerini algılama (Karanlık mod desteği için)
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? Colors.black : Colors.white;
    Color cardColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color iconColor = const Color(0xFF1E7228); 

    return Scaffold(
      backgroundColor: bgColor,
      
      // Üst Başlık Çubuğu
      appBar: AppBar(
        title: Text(
          "İmam Yönetim Paneli",
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5, // Yazıya hafif bir ferahlık katar
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // Not: Çıkış butonu kullanıcı talebi üzerine kaldırıldı.
      ),
      
      // Ana Gövde (Kaydırılabilir alan)
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // Üstteki Cami İkonu ve Başlık
            const Icon(
              Icons.mosque, 
              size: 64, 
              color: Color(0xFF1E7228)
            ),
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

            // 1. KISIM: Vefat Edenin İsim Girişi
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              textCapitalization: TextCapitalization.words, // İlk harfleri büyük yapar
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

            // 2. KISIM: Tarih ve Saat Seçimi Yan Yana
            Row(
              children: [
                Expanded(
                  child: InkWell(
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

            // 3. KISIM: İl ve İlçe Seçimi Yan Yana
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

            // 4. KISIM: Mahalle Seçimi
            _buildDropdown(
              context,
              label: "Mahalle",
              value: _selectedNeighborhood,
              items: _neighborhoods,
              onChanged: (val) => setState(() => _selectedNeighborhood = val),
              icon: Icons.map,
            ),

            const SizedBox(height: 16),

            // 5. KISIM: Cami Seçimi
            _buildDropdown(
              context,
              label: "Cami Seçiniz",
              value: _selectedMosque,
              items: _availableMosques,
              onChanged: (val) => setState(() => _selectedMosque = val),
              icon: Icons.mosque_outlined,
            ),

            const SizedBox(height: 16),

            // 6. KISIM: Defin Yeri (Mezarlık) Seçimi
            _buildDropdown(
              context,
              label: "Defin Yeri (Mezarlık)",
              value: _selectedBurialPlace,
              items: _cemeteries,
              onChanged: (val) => setState(() => _selectedBurialPlace = val),
              icon: Icons.park,
            ),

            const SizedBox(height: 32),

            // 7. KISIM: İlanı Kaydetme Butonu
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
                  elevation: 4, // Biraz daha gölge eklendi
                ),
              ),
            ),
            const SizedBox(height: 30), // Sayfanın en altından biraz boşluk
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ÖZEL WIDGET'LAR (KOD TEKRARINI ÖNLEMEK İÇİN)
  // ---------------------------------------------------------------------------
  
  /// Formlardaki açılır menüleri (Dropdown) standart bir tasarımla çizer.
  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    // Tema renkleri algılaması
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color cardColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color dropdownBg = isDark ? Colors.grey[850]! : Colors.white;
    Color labelColor = isDark ? Colors.white70 : Colors.black54;

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true, // Yazı uzun olursa taşmayı engeller
      dropdownColor: dropdownBg,
      style: TextStyle(color: textColor, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor), 
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFF1E7228))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12)
        ),
        filled: true,
        fillColor: cardColor,
      ),
      // Listeyi ekrandaki butonlara dönüştürme işlemi
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