import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';

import '../../utils.dart'; // Ortak değişkenler buradan geliyor
// UserService'i sildik çünkü Firebase yok, hata fırlatır!
// import '../../services/user_service.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Firebase olmadığı için bu servisi de iptal ettik
  // final UserService _userService = UserService();

// ignore: unused_field
String _selectedCountryCode = "+90";

  Future<void> _register() async {
    if (_usernameController.text.isEmpty ||
        _passController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları doldurunuz."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // --- Ekranda boşluklu görünen numarayı temizle ---
    String rawPhone = _phoneController.text.replaceAll(' ', '');
    String phoneInput = rawPhone.trim();
    // --------------------------------------------------

    // Telefon format kontrolü
    if (!RegExp(r'^[0-9]+$').hasMatch(phoneInput) ||
        phoneInput.length != 10 ||
        !phoneInput.startsWith('5')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Geçersiz numara. (Başında 0 olmadan 5 ile başlayan 10 hane giriniz).",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 📌 FIREBASE KODLARI TAMAMEN TEMİZLENDİ - TASARIM MODU
    // Artık backend ile işimiz yok, sadece web tasarımı için geçiş yapıyoruz.
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Kayıt Başarılı! (Tasarım Modu)"),
        backgroundColor: Colors.green,
      ),
    );

    // Kayıt başarılıymış gibi bir önceki sayfaya (girişe) dön
    if (mounted) Navigator.pop(context);
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = isDarkMode ? Colors.black : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    Color inputFillColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    Color inputBorderColor =
        isDarkMode ? Colors.grey[700]! : Colors.grey.shade400;
    Color hintColor = isDarkMode ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _toggleTheme,
            icon: Icon(
              isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Kayıt Ol",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // İsim
              Text(
                "Kullanıcı Adı",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: inputBorderColor),
                ),
                child: TextField(
                  controller: _usernameController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: hintColor),
                    hintText: "Ad Soyad",
                    hintStyle: TextStyle(color: hintColor),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Telefon
              Text(
                "Telefon Numarası",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: inputBorderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CountryCodePicker(
                        onChanged: (code) => setState(
                            () => _selectedCountryCode = code.dialCode!),
                        initialSelection: 'TR',
                        favorite: const ['+90', 'TR'],
                        showFlag: true,
                        comparator: (a, b) =>
                            a.name!.compareTo(b.name!),
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        dialogTextStyle: const TextStyle(
                          color: Colors.black,
                        ),
                        dialogBackgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    VerticalDivider(color: inputBorderColor),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          PhoneInputFormatter(),
                        ],
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: "5XX XXX XX XX",
                          hintStyle: TextStyle(color: hintColor),
                          border: InputBorder.none,
                          counterText: "",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Şifre
              Text(
                "Şifre",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: inputBorderColor),
                ),
                child: TextField(
                  controller: _passController,
                  obscureText: true,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: hintColor),
                    hintText: "Şifre",
                    hintStyle: TextStyle(color: hintColor),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E7228),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _register,
                  child: const Text(
                    "Kayıt Ol",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ÖZEL TELEFON FORMATLAYICI SINIFI ---
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 10) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 2 || i == 5 || i == 7) && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}