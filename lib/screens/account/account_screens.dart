import 'package:flutter/material.dart';
import '../../data/global_data.dart';
import '../../widgets/common_widgets.dart';
import '../auth/auth_screens.dart';

// ------------------------------------
// --- 1. HESAP ANA EKRANI ---
// ------------------------------------
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Bildirimlerin okunup okunmadığını kontrol et
  bool get _hasUnreadNotifications => GlobalData.notifications.any((element) => !element.isRead);

  // Ekran her döndüğünde bildirim durumunu güncellemek için
  void _refresh() {
    setState(() {});
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Dışarı basınca kapanmasın
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Çıkış Yap"),
        content: const Text("Hesaptan çıkmak istiyor musunuz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Hayır", style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialogu kapat
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (c) => const LoginPage()), 
                (route) => false
              ); 
            }, 
            child: const Text("Evet", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                border: Border.all(color: Theme.of(context).primaryColor, width: 3)
              ),
              child: CircleAvatar(
                radius: 60, 
                backgroundColor: GlobalData.profileColor, 
                child: const Icon(Icons.person, size: 80, color: Colors.white)
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(GlobalData.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (GlobalData.isImam) 
            const Text("(Yetkili İmam Hesabı)", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
          
          const SizedBox(height: 32),
          
          _buildMenuItem(context, 
            icon: Icons.person, 
            text: 'Kullanıcı Bilgileri', 
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const UserInfoScreen())).then((_) => _refresh())
          ),
          _buildMenuItem(context, 
            icon: Icons.settings, 
            text: 'Ayarlar', 
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsScreen())).then((_) => _refresh())
          ),
          _buildMenuItem(context, 
            icon: Icons.notifications, 
            text: 'Bildirimler', 
            hasNotification: _hasUnreadNotifications, 
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationsScreen())).then((_) => _refresh())
          ),
          _buildMenuItem(context, 
            icon: Icons.exit_to_app, 
            text: 'Çıkış Yap', 
            isDestructive: true, 
            onTap: _showLogoutDialog
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String text, bool isDestructive = false, bool hasNotification = false, required VoidCallback onTap}) {
    Color boxColor = const Color(0xFF4CAF50); // Buton rengi sabit yeşil

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: boxColor, 
          borderRadius: BorderRadius.circular(10.0)
        ),
        child: ListTile(
          leading: Stack(
            children: [
              Icon(icon, color: Colors.white), // Buton içi hep beyaz olsun
              if (hasNotification) 
                Positioned(
                  right: 0, top: 0, 
                  child: Container(
                    width: 10, height: 10, 
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)
                  )
                ),
            ],
          ),
          title: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

// ------------------------------------
// --- 2. KULLANICI BİLGİLERİ EKRANI ---
// ------------------------------------
class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController _emailController = TextEditingController(text: GlobalData.email);
  final TextEditingController _phoneController = TextEditingController(text: GlobalData.phoneNumber);
  
  // Şifre değiştirme kontrolcüleri
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  void _changeProfilePicture() {
    setState(() {
      if (GlobalData.profileColor == Colors.grey) GlobalData.profileColor = Colors.blueAccent;
      else if (GlobalData.profileColor == Colors.blueAccent) GlobalData.profileColor = Colors.purple;
      else GlobalData.profileColor = Colors.grey;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil fotoğrafı güncellendi.")));
  }

  void _saveChanges() {
    setState(() {
      GlobalData.email = _emailController.text;
      GlobalData.phoneNumber = _phoneController.text;
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bilgiler kaydedildi.")));
  }

  void _showChangePasswordDialog() {
    _oldPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Şifre Değiştir"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _oldPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Eski Şifre"),
                ),
                TextField(
                  controller: _newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Yeni Şifre"),
                ),
                TextField(
                  controller: _confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Yeni Şifre (Tekrar)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_newPassController.text != _confirmPassController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yeni şifreler uyuşmuyor!")));
                  return;
                }
                
                if (_oldPassController.text.isEmpty || _newPassController.text.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alanlar boş olamaz.")));
                   return;
                }

                // Başarılı (Demo güncelleme)
                GlobalData.savedPassword = _newPassController.text; 
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifre başarıyla değiştirildi!"), backgroundColor: Colors.green));
              },
              child: const Text("Değiştir"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kullanıcı Bilgileri")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _changeProfilePicture,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(radius: 60, backgroundColor: GlobalData.profileColor, child: const Icon(Icons.person, size: 80, color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text("Fotoğrafı değiştirmek için dokunun", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 30),
            
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "E-Posta (İsteğe Bağlı)", prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Telefon Numarası", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            if (!GlobalData.isImam) 
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.lock_reset),
                  label: const Text("Şifre Değiştir"),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orangeAccent)),
                ),
              )
            else
               const Card(color: Colors.orangeAccent, child: Padding(padding: EdgeInsets.all(8.0), child: Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.black), SizedBox(width: 8), Expanded(child: Text("Yetkili hesaplarda şifre değişikliği yapılamaz.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))]))),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                child: const Text("Kaydet", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------------------------
// --- 3. AYARLAR EKRANI ---
// ------------------------------------
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Ayarlar")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Tema Seçimi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // Beyaz Tema Seçeneği
          Card(
            // DÜZELTİLDİ: withOpacity yerine withValues
            color: !isDark ? Colors.green.withValues(alpha: 0.2) : null,
            child: ListTile(
              leading: const Icon(Icons.wb_sunny, color: Colors.orange),
              title: const Text("Aydınlık (Beyaz) Tema"),
              trailing: !isDark ? const Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () {
                GlobalData.saveTheme(false); // Beyaz tema kaydet
                setState(() {}); // Ekranı yenile
              },
            ),
          ),
          
          // Siyah Tema Seçeneği
          Card(
            // DÜZELTİLDİ: withOpacity yerine withValues
            color: isDark ? Colors.green.withValues(alpha: 0.2) : null,
            child: ListTile(
              leading: const Icon(Icons.nights_stay, color: Colors.blueGrey),
              title: const Text("Karanlık (Siyah) Tema"),
              trailing: isDark ? const Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () {
                GlobalData.saveTheme(true); // Siyah tema kaydet
                setState(() {}); // Ekranı yenile
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------
// --- 4. BİLDİRİMLER EKRANI ---
// ------------------------------------
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Bildirimler", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: GlobalData.notifications.isEmpty 
      ? const Center(child: Text("Henüz bildirim yok."))
      : ListView.builder(
        itemCount: GlobalData.notifications.length,
        itemBuilder: (context, index) {
          final notification = GlobalData.notifications[index];
          
          // DÜZELTİLDİ: withOpacity yerine withValues
          Color cardColor = !notification.isRead 
              ? const Color(0xFF4CAF50).withValues(alpha: 0.8) // Okunmamış: Canlı Yeşil
              : Colors.transparent; // Okunmuş: Saydam
          
          Color borderColor = !notification.isRead ? Colors.greenAccent : Colors.grey;

          return GestureDetector(
            onTap: () {
              setState(() {
                notification.isRead = true; // Okundu işaretle
              });
              GlobalData.saveNotifications(); // Durumu kaydet (Uygulama kapanınca gitmesin)
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: notification.isRead ? 1 : 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Okunmamışsa Kırmızı Nokta
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      const Icon(Icons.notifications, size: 30, color: Colors.white),
                      if (!notification.isRead)
                        Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 14,
                            // DÜZELTİLDİ: withOpacity yerine withValues
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            notification.date,
                            // DÜZELTİLDİ: withOpacity yerine withValues
                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7), fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 