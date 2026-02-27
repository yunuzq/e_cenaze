// Google Maps import'u KALDIRILDI

// Ölen Kişi Modeli
class Person {
  final String name;
  final String date;
  final String time;
  final String funeralTime;
  final String prayerInfo;
  final String mosqueName;
  final String city;
  final String burialPlace;
  final String cenazeSaati;
  

  Person({
    required this.name,
    required this.date,
    required this.time,
    required this.funeralTime,
    required this.prayerInfo,
    required this.mosqueName,
    required this.city,
    required this.burialPlace,
    required this.cenazeSaati,
    
  });

  Map<String, dynamic> toJson() => {
    'name': name, 'date': date, 'time': time, 'funeralTime': funeralTime,
    'prayerInfo': prayerInfo, 'mosqueName': mosqueName, 'city': city, 'burialPlace': burialPlace,
  };

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'], date: json['date'], time: json['time'],
      funeralTime: json['funeralTime'] ?? "Belirtilmedi", prayerInfo: json['prayerInfo'],
      mosqueName: json['mosqueName'], city: json['city'], burialPlace: json['burialPlace'],
      // Örnek kullanım (Diğer parametrelerin yanına ekle):
cenazeSaati: "Belirtilmedi",
    );
  }
}

// Cami Modeli
class Mosque {
  final String id;
  final String name;
  final String city;
  final String district;
  final String neighborhood;
  // LatLng location;  <--- KALDIRILDI
  final String history;
  final List<String> imageUrls;

  Mosque({
    required this.id, required this.name, required this.city, required this.district,
    required this.neighborhood, required this.history, required this.imageUrls,
    // location parametresi silindi
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'city': city, 'district': district,
    'neighborhood': neighborhood,
    // 'lat': location.latitude, <--- SİLİNDİ
    // 'lng': location.longitude, <--- SİLİNDİ
    'history': history, 'imageUrls': imageUrls,
  };

  factory Mosque.fromJson(Map<String, dynamic> json) {
    return Mosque(
      id: json['id'], name: json['name'], city: json['city'], district: json['district'],
      neighborhood: json['neighborhood'],
      // location satırı silindi
      history: json['history'], imageUrls: List<String>.from(json['imageUrls']),
    );
  }
}

// Bildirim Modeli
class AppNotification {
  final String title;
  final String message;
  final String date;
  bool isRead;

  AppNotification({
    required this.title, required this.message, required this.date, this.isRead = false,
  });
}