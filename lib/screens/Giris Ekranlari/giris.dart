import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/global_data.dart';
import '../../utils.dart'; 
import '../../main.dart'; 
import 'imam_giris.dart'; 
import 'kayit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedCountryCode = "+90"; 
  bool _isPasswordVisible = false; 
  bool _rememberMe = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAutoFill());
  }

  void _checkAutoFill() {
    if (GlobalData.isRemembered && GlobalData.savedUsername.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Hoşgeldiniz"),
          content: const Text("Kaydedilen bilgileri otomatik doldurmak ister misiniz?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hayır", style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () {
                setState(() {
                  _phoneController.text = GlobalData.savedUsername; 
                  _passwordController.text = GlobalData.savedPassword;
                  _rememberMe = true;
                });
                Navigator.pop(context);
              },
              child: const Text("Evet", style: TextStyle(color: Color(0xFF1E7228), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  void _performLogin() {
    String rawPhone = _phoneController.text.replaceAll(' ', '');
    String phoneInput = rawPhone.trim();

    if (phoneInput.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen telefon numaranızı ve şifrenizi giriniz."), backgroundColor: Colors.red)
      );
      return;
    }
    
    String fullPhoneNumber = _selectedCountryCode + phoneInput;
    bool isTestUser = (phoneInput == "5555555555" && _passwordController.text == "123456");

    if (isTestUser || (mockUserDatabase.containsKey(fullPhoneNumber) && mockUserDatabase[fullPhoneNumber]!['pass'] == _passwordController.text)) {
        
        if (_rememberMe) {
          GlobalData.isRemembered = true;
          GlobalData.savedUsername = phoneInput; 
          GlobalData.savedPassword = _passwordController.text;
        } else {
          GlobalData.isRemembered = false;
          GlobalData.savedUsername = "";
          GlobalData.savedPassword = "";
        }
        
        GlobalData.isImam = false;
        GlobalData.userName = isTestUser 
            ? "Test Kullanıcısı" 
            : (mockUserDatabase[fullPhoneNumber]!['name'] ?? "Kullanıcı");
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Başarıyla giriş yapıldı."), backgroundColor: Colors.green));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hatalı telefon numarası veya şifre!"), backgroundColor: Colors.red));
    }
  }

  void _toggleTheme() => setState(() => isDarkMode = !isDarkMode);

  Future<void> _launchSocialURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bağlantı açılamadı.")));
    }
  }

  void _showForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => const ForgotPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = isDarkMode ? Colors.black : Colors.white;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    Color inputFill = isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    Color borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey.shade300;
    Color hintColor = isDarkMode ? Colors.grey[500]! : Colors.grey;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Ekrana dokununca klavyeyi kapatır
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            Positioned(
              top: 50, 
              right: 20, 
              child: IconButton(
                onPressed: _toggleTheme, 
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode, color: textColor, size: 28)
              )
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LOGO KISMI (Hata korumalı)
                    Image.asset(
                      'assets/ecenaze.png', 
                      height: 120, 
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.account_balance, size: 80, color: const Color(0xFF1E7228));
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "E-Cenaze", 
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Serif')
                    ),
                    const SizedBox(height: 40),
                    
                    Text("Telefon Numarası", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: inputFill, 
                        borderRadius: BorderRadius.circular(15), 
                        border: Border.all(color: borderColor)
                      ),
                      child: Row(
                        children: [
                          CountryCodePicker(
                            onChanged: (c) => _selectedCountryCode = c.dialCode!,
                            initialSelection: 'TR', 
                            showFlag: true, 
                            textStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                            dialogTextStyle: const TextStyle(color: Colors.black),
                          ),
                          Container(width: 1, height: 25, color: borderColor, margin: const EdgeInsets.symmetric(horizontal: 5)),
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
                              )
                            )
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text("Şifre", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: inputFill, 
                        borderRadius: BorderRadius.circular(15), 
                        border: Border.all(color: borderColor)
                      ),
                      child: TextField(
                        controller: _passwordController, 
                        obscureText: !_isPasswordVisible, 
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline, color: hintColor), 
                          border: InputBorder.none, 
                          contentPadding: const EdgeInsets.symmetric(vertical: 15), 
                          hintStyle: TextStyle(color: hintColor), 
                          hintText: "Şifreniz",
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: hintColor), 
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)
                          ),
                        ),
                      ),
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe, 
                                activeColor: const Color(0xFF1E7228), 
                                onChanged: (v) => setState(() => _rememberMe = v!)
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text("Beni Hatırla", style: TextStyle(color: textColor, fontSize: 13))
                          ]
                        ),
                        TextButton(
                          onPressed: _showForgotPassword, 
                          child: const Text("Şifremi Unuttum", style: TextStyle(color: Color(0xFF1E7228), fontWeight: FontWeight.bold, fontSize: 13))
                        ),
                      ]
                    ),
                    
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E7228), 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
                        elevation: 2
                      ), 
                      onPressed: _performLogin, 
                      child: const Text("Giriş Yap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Color(0xFF1E7228)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
                      ), 
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ImamLoginPage())), 
                      icon: const Icon(Icons.mosque, color: Color(0xFF1E7228)),
                      label: const Text("İmam/Görevli Girişi", style: TextStyle(fontSize: 16, color: Color(0xFF1E7228), fontWeight: FontWeight.bold))
                    ),
                    
                    const SizedBox(height: 25),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterPage())), 
                        child: RichText(
                          text: TextSpan(
                            text: "Henüz hesabınız yok mu? ", 
                            style: TextStyle(color: hintColor, fontSize: 14), 
                            children: const [
                              TextSpan(text: "Kayıt Ol", style: TextStyle(color: Color(0xFF1E7228), fontWeight: FontWeight.bold))
                            ]
                          )
                        )
                      )
                    ),
                    
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(child: Divider(color: borderColor)), 
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text("Sosyal Medya", style: TextStyle(color: hintColor, fontSize: 12))), 
                        Expanded(child: Divider(color: borderColor))
                      ]
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchSocialURL("https://facebook.com"), 
                            icon: const Icon(Icons.facebook, color: Colors.white), 
                            label: const Text("Facebook"), 
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1877F2), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))
                          )
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchSocialURL("https://google.com"), 
                            icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 28), 
                            label: const Text("Google"), 
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDB4437), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))
                          )
                        ),
                      ]
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordDialog extends StatelessWidget {
  const ForgotPasswordDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Şifremi Unuttum"), 
      content: const Text("Şifre sıfırlama özelliği yakında eklenecektir. Lütfen destek ile iletişime geçin."), 
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Kapat", style: TextStyle(color: Color(0xFF1E7228))))
      ]
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
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
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}