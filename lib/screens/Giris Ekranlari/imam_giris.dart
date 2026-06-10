import 'package:flutter/material.dart';
import '../../data/global_data.dart';
import '../../theme/app_theme.dart';
import '../../utils.dart';
import '../İmam/imam_paneli.dart';

class ImamLoginPage extends StatefulWidget {
  const ImamLoginPage({super.key});

  @override
  State<ImamLoginPage> createState() => _ImamLoginPageState();
}

class _ImamLoginPageState extends State<ImamLoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _imamLogin() {
    if (_usernameController.text == GlobalData.imamUsernameReal && 
        _passwordController.text == GlobalData.imamPasswordReal) {
      
      GlobalData.isImam = true;
      GlobalData.userName = _usernameController.text;
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("İmam girişi başarılı.")));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ImamPanelScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hatalı İmam Bilgileri"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = isDarkMode ? AppTheme.bgDark : AppTheme.bgLight;
    Color textColor = isDarkMode ? Colors.white : AppTheme.textLight;
    Color inputFillColor = isDarkMode ? AppTheme.cardDark : Colors.white;
    Color inputBorderColor = isDarkMode ? Colors.grey[700]! : Colors.grey.shade400;
    Color hintColor = isDarkMode ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
        title: Text("İmam Girişi", style: TextStyle(color: textColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent, elevation: 0
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/ecenaze.png', height: 180, width: 100, fit: BoxFit.contain),
              const SizedBox(height: 30),

              Text("İmam Kullanıcı Adı", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: inputBorderColor)),
                child: TextField(controller: _usernameController, style: TextStyle(color: textColor), decoration: InputDecoration(prefixIcon: Icon(Icons.mosque, color: hintColor), hintText: "Kullanıcı Adı", hintStyle: TextStyle(color: hintColor), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15))),
              ),
              const SizedBox(height: 20),

              Text("Şifre", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: inputBorderColor)),
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: hintColor),
                    hintText: "••••••••",
                    hintStyle: TextStyle(color: hintColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    suffixIcon: GestureDetector(onTapDown: (_) => setState(() => _isPasswordVisible = true), onTapUp: (_) => setState(() => _isPasswordVisible = false), onTapCancel: () => setState(() => _isPasswordVisible = false), child: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: hintColor)),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0), onPressed: _imamLogin, child: const Text("Giriş Yap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)))),
            ],
          ),
        ),
      ),
    );
  }
}