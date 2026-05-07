import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'customer_dashboard.dart';
import 'technician_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ================= EMAIL LOGIN =================
  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.7:8000/api/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.text,
          "password": password.text,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      setState(() => isLoading = false);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // --- JIKA TERDAFTAR ---
        String name = data['user']['name'];
        String role = data['user']['role'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name);
        await prefs.setString('role', role);

        if (!mounted) return; // Tambahkan ini untuk keamanan async
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => role == "customer"
                ? CustomerDashboard(name: name)
                : TechnicianDashboard(name: name),
          ),
        );
      } 
      else if (response.statusCode == 404) {
        // --- JIKA BELUM TERDAFTAR ---
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Email belum terdaftar!"),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
      } 
      else {
        // --- ERROR LAINNYA ---
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Login gagal")),
        );
      }
    } // <--- Penutup blok IF/ELSE
    catch (e) { 
      // 🔥 INI BAGIAN YANG TADI HILANG 🔥
      setState(() => isLoading = false);
      print("ERROR LOGIN: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan jaringan")),
      );
    }
  }
  // ================= GOOGLE LOGIN (LENGKAP & TINGGAL PASTE) =================
  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      // 1. Paksa Google untuk memunculkan pilihan akun (Reset session)
      await googleSignIn.disconnect().catchError((e) => null); 
      await googleSignIn.signOut();

      // 2. Mulai proses pilihan akun
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Jika user menekan tombol kembali atau membatalkan pilihan akun
      if (googleUser == null) return;

      // 3. Kirim data ke Laravel (Pastikan IP 192.168.1.9 sudah benar)
      final response = await http.post(
        Uri.parse('http://192.168.1.9:8000/api/google-login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": googleUser.email.trim().toLowerCase(),
          "name": googleUser.displayName,
        }),
      );

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // --- LOGIN BERHASIL ---
        String name = data['user']['name'];
        String role = data['user']['role'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name);
        await prefs.setString('role', role);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => role == "customer"
                ? CustomerDashboard(name: name)
                : TechnicianDashboard(name: name),
          ),
        );
      } 
      else if (response.statusCode == 404) {
        // --- EMAIL BELUM TERDAFTAR DI DATABASE ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Email belum terdaftar!"),
            backgroundColor: Colors.orange,
          ),
        );
        // Arahkan ke halaman Register agar user pilih role dulu
        Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
      } 
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Google login gagal")),
        );
      }
    } catch (e) {
      print("ERROR GOOGLE: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak dapat terhubung ke server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // LOGO 
                      CircleAvatar(
  radius: 45,
  backgroundColor: Colors.blue.shade50,
  // Gunakan icon palu/obeng (build) agar nyambung dengan JasaKu
  child: Icon(Icons.build_rounded, size: 45, color: Colors.blue.shade800),
),

                      SizedBox(height: 10),

                      // NAMA APP
                      Text(
                        "JASAKU",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),

                      SizedBox(height: 10),

                      

                      Text(
                        "Kelola pemesanan dan layanan anda",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),

                      SizedBox(height: 25),

                      TextField(
                        controller: email,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Kata Sandi",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text("Masuk"),
                        ),
                      ),

                      SizedBox(height: 15),

                      Text("Atau lanjutkan dengan"),

                      SizedBox(height: 15),

                      // GOOGLE
                      // ================= GOOGLE BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: loginWithGoogle,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                "https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png",
                                height: 22,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Continue with Google",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 10),
                      SizedBox(height: 10),

                      // FACEBOOK
                      // ================= FACEBOOK BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.facebook, color: Colors.blue),
                              SizedBox(width: 12),
                              Text(
                                "Continue with Facebook",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterScreen()),
    );
  },
  child: Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: "Belum punya akun? ",
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.normal,
        ),
      ),
      TextSpan(
        text: "Daftar sekarang",
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
      TextSpan(
        text: " atau ", // Spasi di awal dan akhir penting agar tidak nempel
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.normal,
        ),
      ),
      TextSpan(
        text: "jadi penyedia jasa",
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    ],
  ),
  textAlign: TextAlign.center,
),
),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}