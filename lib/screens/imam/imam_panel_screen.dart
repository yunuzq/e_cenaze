import 'package:flutter/material.dart';
import '../../data/global_data.dart';
import '../../models/app_models.dart';
import '../auth/auth_screens.dart';

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
  final List<String> _prayerTimes = ["Öğle Namazı", "İkindi Namazı", "Cuma Namazı", "Cenaze Namazı"];
  final List<String> _cemeteries = [
    'Edirnekapı Şehitliği', 'Karşıyaka Mezarlığı', 'Hacılarkırı Mezarlığı', 
    'Zincirlikuyu Mezarlığı', 'Emirsultan Mezarlığı', 'Gölbaşı Mezarlığı', 'Kozlu Mezarlığı',
  ];

  @override
  void dispose() { _nameController.dispose(); super.dispose(); }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2026));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _onCityChanged(String? val) {
    setState(() {
      _selectedCity = val; _selectedDistrict = null; _selectedNeighborhood = null; _selectedMosque = null;
      // GlobalData içinden çağırıyoruz
      _districts = val != null ? GlobalData.turkeyLocationData[val]!.keys.toList() : [];
      _neighborhoods = []; _availableMosques = [];
    });
  }

  void _onDistrictChanged(String? val) {
    setState(() {
      _selectedDistrict = val; _selectedNeighborhood = null; _selectedMosque = null;
      if (_selectedCity != null && val != null) {
        _neighborhoods = GlobalData.turkeyLocationData[_selectedCity]![val] ?? [];
        _updateAvailableMosques();
      } else { _neighborhoods = []; _availableMosques = []; }
    });
  }

  void _updateAvailableMosques() {
    _availableMosques = GlobalData.mosques.where((m) => m.city == _selectedCity && m.district == _selectedDistrict).map((m) => m.name).toList();
    if (_availableMosques.isEmpty) _availableMosques.add("Merkez Camii (Varsayılan)");
  }

  void _saveFuneral() {
    if (_nameController.text.isEmpty || _selectedCity == null || _selectedDistrict == null || _selectedMosque == null || _selectedBurialPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları seçiniz.")));
      return;
    }

    String formattedDate = "${_selectedDate.day} ${_selectedDate.month} ${_selectedDate.year}";
    String formattedTime = "${_selectedTime.hour}:${_selectedTime.minute}";

    final newPerson = Person(
      name: _nameController.text.toUpperCase(), date: formattedDate, time: "Belirtilmedi",
      funeralTime: formattedTime, prayerInfo: '($_selectedPrayerTime)', mosqueName: _selectedMosque!,
      city: _selectedCity!, burialPlace: _selectedBurialPlace!,
    );

    GlobalData.addPerson(newPerson).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vefat ilanı sisteme kaydedildi!"), backgroundColor: Colors.green));
    });

    bool mosqueExists = GlobalData.mosques.any((m) => m.name == _selectedMosque);
    if (!mosqueExists) {
        final newMosque = Mosque(
            id: DateTime.now().millisecondsSinceEpoch.toString(), name: _selectedMosque!,
            city: _selectedCity!, district: _selectedDistrict!, neighborhood: _selectedNeighborhood ?? "Merkez",
            history: "İmam tarafından eklendi.", imageUrls: [],
            // location: LatLng(0,0) SİLİNDİ
        );
        GlobalData.addMosque(newMosque);
    }
    _nameController.clear();
    setState(() { _selectedMosque = null; _selectedBurialPlace = null; });
  }

  void _logout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("İmam Yönetim Paneli"), actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.redAccent))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Yeni Vefat İlanı Girişi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Vefat Edenin Adı Soyadı", prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[900])),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: InkWell(onTap: () => _pickDate(context), child: InputDecorator(decoration: InputDecoration(labelText: "Vefat Tarihi", prefixIcon: const Icon(Icons.calendar_today), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), child: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}")))),
              const SizedBox(width: 10),
              Expanded(child: InkWell(onTap: () => _pickTime(context), child: InputDecorator(decoration: InputDecoration(labelText: "Cenaze Saati", prefixIcon: const Icon(Icons.access_time), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), child: Text("${_selectedTime.hour}:${_selectedTime.minute}")))),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildDropdown(label: "İl", value: _selectedCity, items: GlobalData.turkeyLocationData.keys.toList(), onChanged: _onCityChanged)),
              const SizedBox(width: 10),
              Expanded(child: _buildDropdown(label: "İlçe", value: _selectedDistrict, items: _districts, onChanged: _onDistrictChanged)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildDropdown(label: "Mahalle", value: _selectedNeighborhood, items: _neighborhoods, onChanged: (val) => setState(() => _selectedNeighborhood = val))),
              const SizedBox(width: 10),
              Expanded(child: _buildDropdown(label: "Namaz Vakti", value: _selectedPrayerTime, items: _prayerTimes, onChanged: (val) => setState(() => _selectedPrayerTime = val!))),
            ]),
            const SizedBox(height: 16),
            _buildDropdown(label: "Cami Seçiniz", value: _selectedMosque, items: _availableMosques, onChanged: (val) => setState(() => _selectedMosque = val), icon: Icons.mosque),
            const SizedBox(height: 16),
            _buildDropdown(label: "Defin Yeri (Mezarlık)", value: _selectedBurialPlace, items: _cemeteries, onChanged: (val) => setState(() => _selectedBurialPlace = val), icon: Icons.place),
            const SizedBox(height: 30),
            SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(onPressed: _saveFuneral, icon: const Icon(Icons.save), label: const Text("İlanı Yayınla ve Kaydet", style: TextStyle(fontSize: 18)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label, required String? value, required List<String> items, required ValueChanged<String?> onChanged, IconData? icon}) {
    return DropdownButtonFormField<String>(
      value: value, isExpanded: true, dropdownColor: Colors.grey[850],
      decoration: InputDecoration(labelText: label, prefixIcon: icon != null ? Icon(icon) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[900]),
      items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );
  }
}