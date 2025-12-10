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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ImamPanelScreen()));
    } else {
      GlobalData.isImam = false;
      GlobalData.userName = _usernameController.text;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
    }
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
                const Text("E-Cenaze", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.person_outline), hintText: "Kullanıcı Adı", border: OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline), hintText: "Şifre", border: OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
                ),
                const SizedBox(height: 20),
                Row(children: [Checkbox(value: _rememberMe, onChanged: (val) { setState(() { _rememberMe = val!; }); }), const Text("Beni Hatırla", style: TextStyle(color: Colors.black))]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B86F7), foregroundColor: Colors.white),
                    onPressed: _navigateToHome, 
                    child: const Text("Giriş Yap", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 15),
                 SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterPage())),
                    child: const Text("Kayıt Ol", style: TextStyle(color: Colors.green)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: const Center(child: Text("Kayıt Ol Sayfası")));
  }
}