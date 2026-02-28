import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/global_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../Giris Ekranlari/giris.dart';

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

  // Profil fotoğrafı yolu (Hafızadan okunacak)
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // Kullanıcıya özel profil resmini yükle (Sadece görüntüleme amaçlı)
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_${GlobalData.userName}');
    });
  }

  // Ekran her döndüğünde bildirim durumunu ve resmi güncellemek için
  void _refresh() {
    _loadProfileImage();
    setState(() {});
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Dışarı basınca kapanmasın
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 10),
            Text("Çıkış Yap"),
          ],
        ),
        content: const Text("Hesaptan çıkmak istediğinize emin misiniz?", style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Hayır", style: TextStyle(color: Colors.grey, fontSize: 16))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Dialogu kapat
              // Giriş ekranına at ve geçmişi temizle
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (c) => const LoginPage()), 
                (route) => false
              ); 
            }, 
            child: const Text("Evet", style: TextStyle(fontSize: 16))
          ),
        ],
      ),
    );
  }

  void _showFaqOverlay() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "SSS",
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: 26),
                          const SizedBox(width: 8),
                          const Text(
                            "Sıkça Sorulan Sorular",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "E-Cenaze nedir?",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "E-Cenaze, cenaze süreçlerinin takibini, bilgilendirmesini ve ilgili cami/görevlilerle iletişimi kolaylaştırmak için hazırlanmış dijital bir yardımcı uygulamadır.",
                                style: TextStyle(fontSize: 14, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cenaze namazı nasıl kılınır?",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Cenaze namazı, ayakta ve kıbleye dönük olarak, niyet ile birlikte dört tekbir, Fatiha, salavat ve dua okunarak kılınan, rükû ve secdesi bulunmayan bir namazdır. Detaylar için bağlı olduğunuz cami veya din görevlinizin talimatlarını esas alınız.",
                                style: TextStyle(fontSize: 14, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kıyafetin önemi?",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Cenaze merasimlerine katılırken sade, temiz ve vücut hatlarını belli etmeyen kıyafetler tercih edilmesi; hem dini hassasiyet hem de yakınlara saygı açısından önemlidir.",
                                style: TextStyle(fontSize: 14, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Gassal nedir?",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Gassal, vefat eden kişinin İslami usullere göre yıkanması ve kefenlenmesi işlemini gerçekleştiren görevliye verilen isimdir.",
                                style: TextStyle(fontSize: 14, height: 1.4),
                              ),
                            ],
                          ),
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
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView( 
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: CircleAvatar(
                  radius: 60, 
                  backgroundColor: GlobalData.profileColor, 
                  // Eğer kayıtlı resim varsa onu göster, yoksa null (rengi gösterir)
                  backgroundImage: _profileImagePath != null 
                      ? FileImage(File(_profileImagePath!)) 
                      : null,
                  // Eğer resim yoksa İkon göster
                  child: _profileImagePath == null 
                      ? const Icon(Icons.person, size: 80, color: Colors.white) 
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              GlobalData.userName, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)
            ),
            if (GlobalData.isImam) 
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.tintAvatarBg, borderRadius: BorderRadius.circular(20)),
                child: Text("Yetkili İmam Hesabı", style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            
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
            const SizedBox(height: 20),
            // İletişim ve SSS alanını sayfa içi, kaydırılabilir bölümün en altına aldık
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.phone, color: Theme.of(context).primaryColor, size: 20),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  GlobalData.phoneNumber.isNotEmpty ? GlobalData.phoneNumber : "Telefon: 0 (xxx) xxx xx xx",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.email, color: Theme.of(context).primaryColor, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "ecenaze.app@gmail.com",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(26),
                      onTap: _showFaqOverlay,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        child: const Text(
                          "S.S.S",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String text, bool isDestructive = false, bool hasNotification = false, required VoidCallback onTap}) {
    Color boxColor = isDestructive ? Colors.redAccent : AppTheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: boxColor, 
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(color: boxColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))
          ]
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              if (hasNotification) 
                Positioned(
                  right: -2, top: -2, 
                  child: Container(
                    width: 12, height: 12, 
                    decoration: BoxDecoration(
                      color: Colors.red, 
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)
                    )
                  )
                ),
            ],
          ),
          title: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
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

  // Geçici resim yolu (Kaydet diyene kadar burada tutulur)
  String? _tempProfileImagePath;
  
  // Resim seçici
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCurrentProfileImage();
  }

  // Mevcut resmi yükle
  Future<void> _loadCurrentProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tempProfileImagePath = prefs.getString('profile_image_${GlobalData.userName}');
    });
  }

  // Galeriden Fotoğraf Seçme (SADECE ÖNİZLEME YAPAR)
  Future<void> _pickImage() async {
    try {
      // Galeriden seçim yap (İzin otomatik istenir)
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          // Resmi geçici değişkene ata, henüz kaydetme!
          _tempProfileImagePath = image.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fotoğraf seçildi. Kaydetmeyi unutmayın."), duration: Duration(seconds: 1)));
      }
    } catch (e) {
      // İzin verilmezse veya hata olursa
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: Galeriye erişilemedi ($e)"), backgroundColor: Colors.red));
    }
  }

  // Fotoğrafı Kaldır
  void _removeImage() {
    setState(() {
      _tempProfileImagePath = null; // Resmi kaldır, varsayılan ikona dön
    });
  }

  // DEĞİŞİKLİKLERİ KAYDET (Hem yazı hem resim)
  Future<void> _saveChanges() async {
    setState(() {
      GlobalData.email = _emailController.text;
      GlobalData.phoneNumber = _phoneController.text;
    });

    final prefs = await SharedPreferences.getInstance();
    
    // Resmi veritabanına işle
    if (_tempProfileImagePath != null) {
      await prefs.setString('profile_image_${GlobalData.userName}', _tempProfileImagePath!);
    } else {
      await prefs.remove('profile_image_${GlobalData.userName}'); // Resim kaldırıldıysa sil
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tüm değişiklikler başarıyla kaydedildi."), backgroundColor: Colors.green));
    }
  }

  void _showChangePasswordDialog() {
    _oldPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();

    // Özel Font Stili (Daha şık ve okunaklı)
    TextStyle inputStyle = const TextStyle(
      fontSize: 16,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w500,
      color: Colors.black87, // Siyah tema olsa bile dialog içi beyaz olduğu için
    );

    showDialog(
      context: context,
      builder: (context) {
        // Dialog teması
        return Theme(
          data: ThemeData.light(), // Dialog her zaman aydınlık olsun ki okunabilsin
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
                SizedBox(width: 8),
                Text("Şifre Değiştir", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Güvenliğiniz için mevcut şifrenizi girin.", style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _oldPassController,
                    obscureText: true,
                    style: inputStyle,
                    decoration: const InputDecoration(labelText: "Eski Şifre", border: OutlineInputBorder(), prefixIcon: Icon(Icons.vpn_key_outlined)),
                  ),
                  const SizedBox(height: 20),
                  const Text("Yeni Şifrenizi Belirleyin", style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _newPassController,
                    obscureText: true,
                    style: inputStyle,
                    decoration: const InputDecoration(labelText: "Yeni Şifre", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPassController,
                    obscureText: true,
                    style: inputStyle,
                    decoration: const InputDecoration(labelText: "Yeni Şifre (Tekrar)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_clock)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("İptal", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  // 1. ESKİ ŞİFRE KONTROLÜ (Giriş yapılan şifreyle uyuşmalı)
                  // Eğer savedPassword boşsa (beni hatırla yapılmadıysa) basitlik adına "123456" gibi dummy kabul edebiliriz ama
                  // mantıken savedPassword boş olmamalı.
                  if (_oldPassController.text != GlobalData.savedPassword) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Eski şifreniz hatalı!"), backgroundColor: Colors.red));
                     return;
                  }

                  // 2. Yeni şifre uyuşmazlığı
                  if (_newPassController.text != _confirmPassController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yeni şifreler birbiriyle uyuşmuyor!"), backgroundColor: Colors.orange));
                    return;
                  }
                  
                  // 3. Boş alan kontrolü
                  if (_newPassController.text.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yeni şifre boş bırakılamaz."), backgroundColor: Colors.orange));
                     return;
                  }

                  // Başarılı
                  setState(() {
                    GlobalData.savedPassword = _newPassController.text; // Global şifreyi güncelle
                  });
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifreniz başarıyla değiştirildi!"), backgroundColor: Colors.green));
                },
                child: const Text("Değiştir"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kullanıcı Bilgileri")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- PROFİL FOTOĞRAFI ALANI ---
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).primaryColor, width: 4),
                      color: GlobalData.profileColor,
                      image: _tempProfileImagePath != null 
                        ? DecorationImage(image: FileImage(File(_tempProfileImagePath!)), fit: BoxFit.cover)
                        : null,
                    ),
                    child: _tempProfileImagePath == null 
                        ? const Icon(Icons.person, size: 90, color: Colors.white) 
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: _pickImage, // Galeriye git
                      child: Container(
                        height: 45, width: 45,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 5)]
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // FOTOĞRAFI KALDIR BUTONU (Sadece resim varsa göster)
            if (_tempProfileImagePath != null)
              TextButton.icon(
                onPressed: _removeImage, 
                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                label: const Text("Fotoğrafı Kaldır", style: TextStyle(color: Colors.redAccent)),
              )
            else
              const Text("Fotoğraf eklemek için ikona dokunun", style: TextStyle(color: Colors.grey, fontSize: 12)),
            
            const SizedBox(height: 40),
            
            // --- BİLGİ ALANLARI ---
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "E-Posta (İsteğe Bağlı)", 
                prefixIcon: const Icon(Icons.email), 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Telefon Numarası", 
                prefixIcon: const Icon(Icons.phone), 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
            const SizedBox(height: 20),
            
            // İmam değilse şifre değiştirme butonu
            if (!GlobalData.isImam) 
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.lock_reset),
                  label: const Text("Şifre Değiştir", style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orangeAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12)
                  ),
                ),
              )
            else
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(color: Colors.orangeAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange)),
                 child: const Row(children: [Icon(Icons.security, color: Colors.orange), SizedBox(width: 10), Expanded(child: Text("Yetkili hesaplarda şifre değişikliği yapılamaz.", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))]),
               ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text("Değişiklikleri Kaydet", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
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
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 10),
            child: Text("Görünüm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor)),
          ),
          
          // Beyaz Tema Seçeneği
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: !isDark ? AppTheme.primary : Colors.transparent, width: 2)),
            color: !isDark ? Colors.white : null,
            child: ListTile(
              leading: const Icon(Icons.wb_sunny, color: Colors.orange),
              title: Text("Aydınlık Tema", style: TextStyle(color: !isDark ? AppTheme.textLight : null, fontWeight: FontWeight.w700)),
              trailing: !isDark ? Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 28) : const Icon(Icons.circle_outlined, color: Colors.grey),
              onTap: () {
                GlobalData.saveTheme(false); // Beyaz tema kaydet
                setState(() {}); // Ekranı yenile
              },
            ),
          ),
          
          const SizedBox(height: 10),

          // Siyah Tema Seçeneği
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isDark ? AppTheme.primary : Colors.transparent, width: 2)),
            color: isDark ? AppTheme.cardDark : null,
            child: ListTile(
              leading: const Icon(Icons.nights_stay, color: Colors.blueAccent),
              title: const Text("Karanlık Tema", style: TextStyle(fontWeight: FontWeight.w700)),
              trailing: isDark ? Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 28) : const Icon(Icons.circle_outlined, color: Colors.grey),
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
// --- 4. BİLDİRİMLER EKRANI (REVIZE EDİLDİ) ---
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
        title: const Text("Bildirimler", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      ),
      body: GlobalData.notifications.isEmpty 
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.notifications_off, size: 80, color: Colors.grey),
              SizedBox(height: 10),
              Text("Henüz bildirim yok.", style: TextStyle(color: Colors.grey, fontSize: 18)),
            ],
          ),
        )
      : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: GlobalData.notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = GlobalData.notifications[index];
          
          // RENK MANTIĞI:
          // Okunmamış: Canlı Yeşil (0xFF4CAF50) - Tam opak, dikkat çekici.
          // Okunmuş: Sönük Yeşil (Saydam) - Arka plan ne olursa olsun, yeşilin transparan hali.
          
          Color cardColor = !notification.isRead 
              ? const Color(0xFF4CAF50) // Okunmamış: Canlı Yeşil
              : const Color(0xFF4CAF50).withValues(alpha: 0.15); // Okunmuş: İyice sönük, saydam yeşil
          
          Color borderColor = !notification.isRead ? AppTheme.primary : Colors.transparent;
          Color iconColor = !notification.isRead ? Colors.white : AppTheme.primary.withValues(alpha: 0.7);
          Color titleColor = !notification.isRead ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color!;
          Color bodyColor = !notification.isRead ? Colors.white.withValues(alpha: 0.9) : Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7);

          return GestureDetector(
            onTap: () {
              setState(() {
                notification.isRead = true; // Okundu işaretle
              });
              GlobalData.saveNotifications(); // Durumu kalıcı kaydet
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                // Okunmamışsa gölge ekle
                boxShadow: !notification.isRead 
                  ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 1, offset: const Offset(0, 1))] 
                  : [],
                border: Border.all(color: borderColor, width: notification.isRead ? 0 : 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İkon ve Bildirim Noktası
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Stack(
                      children: [
                        Icon(Icons.notifications, size: 32, color: iconColor),
                        if (!notification.isRead) // Sadece okunmamışsa kırmızı nokta
                          Positioned(
                            right: 0, top: 0,
                            child: Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: cardColor, width: 2), 
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.3,
                            color: bodyColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            notification.date,
                            style: TextStyle(
                              fontSize: 12, 
                              color: bodyColor.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic
                            ),
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