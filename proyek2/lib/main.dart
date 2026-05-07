import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login_screen.dart';
import 'customer_dashboard.dart';
import 'technician_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  Future<Widget> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    String? name = prefs.getString('name');

    print("ROLE SAAT APP DIBUKA: $role");
    print("NAME SAAT APP DIBUKA: $name");

    // AUTO ROUTING BERDASARKAN ROLE
    if (role == "customer") {
      return CustomerDashboard(name: name ?? "");
    } 
    else if (role == "technician") {
      return TechnicianDashboard(name: name ?? "");
    } 
    else {
      return LoginScreen(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: checkLogin(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Terjadi error")),
            );
          }

          return snapshot.data ?? LoginScreen();
        },
      ),
    );
  }
}