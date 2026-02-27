import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';

import '../../utils.dart'; // Ortak değişkenler buradan geliyor
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart'; // AZ ÖNCE OLUŞTURDUĞUMUZ DOSYA

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final UserService _userService = UserService();

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

    // +90 5XX... ile tam telefon
    String fullPhoneNumber = _selectedCountryCode + phoneInput;

    // 📌 Firebase için telefon numarasını sahte email'e çeviriyoruz
    // Aynı kural LOGIN tarafında da kullanılmalı:
    // final email = '$fullPhoneNumber@ecenaze.com';
    final email = '$fullPhoneNumber@ecenaze.com';

    try {
      // 1) FirebaseAuth ile kullanıcı oluştur
      UserCredential cred =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: _passController.text,
);

debugPrint('UID: ${cred.user?.uid}');

      // 2) Firestore'a kullanıcıyı kaydet
      await _userService.saveUserData(
        name: _usernameController.text.trim(),
        phone: fullPhoneNumber,
      );

      // 3) Başarılı mesajı + login sayfasına geri dön
      if (!mounted) return;  // <-- ADDED (En önemli satır)
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text("Kayıt Başarılı! Giriş yapabilirsiniz."),
    backgroundColor: Colors.green,
  ),
);


      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = "Kayıt sırasında bir hata oluştu.";

      if (e.code == 'email-already-in-use') {
        // Çünkü email'i telefondan ürettik: aynı telefon = aynı email
        msg = "Bu telefon numarası ile zaten bir hesap mevcut!";
      } else if (e.code == 'weak-password') {
        msg = "Şifreniz çok zayıf. Daha güçlü bir şifre giriniz.";
      } else {
        msg = e.message ?? msg;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Beklenmeyen bir hata oluştu."),
          backgroundColor: Colors.red,
        ),
      );
    }
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
