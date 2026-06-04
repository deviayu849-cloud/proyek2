import 'package:flutter/material.dart';

import 'models/user.dart';
import 'screens/admin_dashboard.dart';
import 'screens/customer_dashboard.dart';
import 'screens/login_screen.dart';
import 'screens/technician_dashboard.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _initialScreen() async {
    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) return const LoginScreen();

    try {
      final User user = await ApiService.getProfile();
      return _dashboardFor(user);
    } catch (_) {
      await ApiService.clearSession();
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JASAKU',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _initialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          return snapshot.data ?? const LoginScreen();
        },
      ),
    );
  }

  Widget _dashboardFor(User user) {
    if (user.isAdmin) {
      return AdminDashboard(initialUser: user);
    }
    if (user.isTechnician) {
      return TechnicianDashboard(initialUser: user);
    }
    return CustomerDashboard(initialUser: user);
  }
}
