import 'package:flutter/material.dart';
import '../../data/global_data.dart';
import '../../main.dart'; // MainScreen için
import '../imam/imam_panel_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false; // Şifre görünürlüğü için eklendi

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAutoFill());
  }

  void _checkAutoFill() {
    if (GlobalData.isRemembered && GlobalData.savedUsername.isNotEmpty) {
      setState(() {
        _usernameController.text = GlobalData.savedUsername;
        _passwordController.text = GlobalData.savedPassword;
        _rememberMe = true;
      });
    }
  }

  void _navigateToHome() {
    if (_rememberMe) {
      GlobalData.isRemembered = true;
      GlobalData.savedUsername = _usernameController.text;
      GlobalData.savedPassword = _passwordController.text;
    } else {
      GlobalData.isRemembered = false;
    }

    if (_usernameController.text == GlobalData.imamUsernameReal &&
        _passwordController.text == GlobalData.imamPasswordReal) {
      GlobalData.isImam = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("İmam girişi başarılı. Yönetim Paneli açılıyor...")),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const ImamPanelScreen()));
    } else {
      GlobalData.isImam = false;
      GlobalData.userName = _usernameController.text;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MainScreen()));
    }
  }

  // Misafir Girişi Fonksiyonu
  void _loginAsGuest() {
    GlobalData.isImam = false;
    GlobalData.userName = "Misafir";
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mosque, size: 80, color: Colors.green),
                const SizedBox(height: 10),
                const Text("E-Cenaze",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 40),
                // Kullanıcı Adı
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: "Kullanıcı Adı",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30))),
                ),
                const SizedBox(height: 20),
                // Şifre Alanı (Güncellendi)
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // Ters mantık
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: "Şifre",
                      // Göz ikonu eklendi
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30))),
                ),
                const SizedBox(height: 10),
                // Beni Hatırla ve Şifremi Unuttum Satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                            value: _rememberMe,
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val!;
                              });
                            }),
                        const Text("Beni Hatırla",
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgotPasswordPage()));
                      },
                      child: const Text("Şifremi Unuttum?"),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                // Giriş Yap Butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B86F7),
                        foregroundColor: Colors.white),
                    onPressed: _navigateToHome,
                    child: const Text("Giriş Yap", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 15),
                // Kayıt Ol Butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const RegisterPage())),
                    child: const Text("Kayıt Ol",
                        style: TextStyle(color: Colors.green)),
                  ),
                ),
                const SizedBox(height: 20),
                // Misafir Girişi Butonu (Eklendi)
                TextButton.icon(
                  onPressed: _loginAsGuest,
                  icon: const Icon(Icons.person_pin_circle_outlined, color: Colors.grey),
                  label: const Text("Misafir Olarak Giriş Yap", 
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- ŞİFREMI UNUTTUM SAYFASI VE AKIŞI ---
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 0; // 0: Telefon, 1: Kod Doğrulama, 2: Yeni Şifre
  String? _selectedCountryCode = "+90";
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _isNewPassVisible = false;

  final List<Map<String, String>> _countries = [
    {"name": "Türkiye", "code": "+90"},
    {"name": "Almanya", "code": "+49"},
    {"name": "Amerika", "code": "+1"},
    {"name": "İngiltere", "code": "+44"},
  ];

  void _nextStep() {
    // Basit Validasyonlar
    if (_currentStep == 0) {
      if (_phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen telefon numarası giriniz.")));
        return;
      }
      // Simülasyon: SMS gönderildi
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${_selectedCountryCode}${_phoneController.text} numarasına kod gönderildi.")));
    } else if (_currentStep == 1) {
      if (_codeController.text.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen gelen kodu giriniz.")));
         return;
      }
    } else if (_currentStep == 2) {
      if (_newPassController.text.isEmpty || _confirmPassController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurunuz.")));
        return;
      }
      if (_newPassController.text != _confirmPassController.text) {
        // İstenilen hata mesajı
        showDialog(
          context: context, 
          builder: (c) => AlertDialog(
            title: const Text("İşlem Başarısız"),
            content: const Text("Girdiğiniz şifreler uyuşmuyor."),
            actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Tamam"))],
          )
        );
        return;
      }
      
      // Başarılı senaryo
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifre başarıyla yenilendi!")));
      Navigator.pop(context); // Giriş ekranına dön
      return;
    }

    setState(() {
      _currentStep++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Şifremi Unuttum")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Adım Göstergesi (Opsiyonel görsel)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.looks_one, color: _currentStep >= 0 ? Colors.green : Colors.grey),
                const SizedBox(width: 10),
                Icon(Icons.arrow_forward, size: 16),
                const SizedBox(width: 10),
                Icon(Icons.looks_two, color: _currentStep >= 1 ? Colors.green : Colors.grey),
                const SizedBox(width: 10),
                Icon(Icons.arrow_forward, size: 16),
                const SizedBox(width: 10),
                Icon(Icons.looks_3, color: _currentStep >= 2 ? Colors.green : Colors.grey),
              ],
            ),
            const SizedBox(height: 30),
            
            Expanded(
              child: _buildStepContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: // Telefon Giriş
        return Column(
          children: [
            const Text("Bölgenizi seçin ve telefon numaranızı girin.", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              children: [
                // Ülke Kodu Seçimi
                DropdownButton<String>(
                  value: _selectedCountryCode,
                  items: _countries.map((c) {
                    return DropdownMenuItem(
                      value: c['code'],
                      child: Text("${c['name']} (${c['code']})"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCountryCode = val;
                    });
                  },
                ),
                const SizedBox(width: 10),
                // Telefon No Alanı
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "5XX XXX XX XX",
                      labelText: "Telefon (Başında 0 olmadan)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep, 
                child: const Text("Doğrulama Kodu Gönder")
              ),
            ),
          ],
        );
      case 1: // Kod Doğrulama
        return Column(
          children: [
            Text("Lütfen ${_selectedCountryCode}${_phoneController.text} numarasına gelen kodu giriniz.", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              // DÜZELTME BURADA YAPILDI:
              style: const TextStyle(letterSpacing: 10), 
              decoration: const InputDecoration(
                hintText: "SMS Kodu",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep, 
                child: const Text("Doğrula")
              ),
            ),
          ],
        );
      case 2: // Yeni Şifre
        return Column(
          children: [
            const Text("Yeni şifrenizi belirleyin.", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(
              controller: _newPassController,
              obscureText: !_isNewPassVisible,
              decoration: InputDecoration(
                labelText: "Yeni Şifre",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isNewPassVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isNewPassVisible = !_isNewPassVisible),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _confirmPassController,
              obscureText: !_isNewPassVisible, // Aynı kontrolcüyle yönetiyoruz
              decoration: const InputDecoration(
                labelText: "Yeni Şifreyi Onayla",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep, 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: const Text("Şifreyi Yenile")
              ),
            ),
          ],
        );
      default:
        return Container();
    }
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Kayıt Ol")), body: const Center(child: Text("Kayıt Ol Sayfası")));
  }
}