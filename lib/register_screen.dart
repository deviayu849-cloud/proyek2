import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/gestures.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  String role = "customer"; // default
  bool isLoading = false;

  Future<void> register() async {
    // Validasi sederhana agar tidak mengirim data kosong
    if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Harap isi semua kolom")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.9:8000/api/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name.text,
          "email": email.text,
          "password": password.text,
          "role": role,
        }),
      );

      final data = jsonDecode(response.body);

      setState(() => isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registrasi berhasil sebagai $role")),
        );
        Navigator.pop(context); // Kembali ke halaman login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Gagal register")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error: Periksa koneksi atau IP")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Akun")),
      body: SingleChildScrollView( // Tambah scroll supaya tidak overflow saat keyboard muncul
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 15),
            
            // Dropdown tetap ada untuk sinkronisasi visual
            DropdownButtonFormField(
              value: role,
              items: [
                DropdownMenuItem(value: "customer", child: Text("Pelanggan")),
                DropdownMenuItem(value: "technician", child: Text("Penyedia Jasa")),
              ],
              onChanged: (value) {
                setState(() => role = value.toString());
              },
              decoration: InputDecoration(labelText: "Daftar sebagai"),
            ),

            SizedBox(height: 30),

            // Tombol Daftar Utama
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("DAFTAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            SizedBox(height: 25),

            
          ],
        ),
      ),
    );
  }
}