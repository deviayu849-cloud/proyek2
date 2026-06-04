import 'package:flutter/material.dart';

import 'models/user.dart';
import 'services/api_service.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late final Future<User> _profile = ApiService.getProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<User>(
        future: _profile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Profil tidak ditemukan.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(title: const Text('Nama'), subtitle: Text(user.name)),
              ListTile(title: const Text('Email'), subtitle: Text(user.email)),
              ListTile(title: const Text('Role'), subtitle: Text(user.role)),
            ],
          );
        },
      ),
    );
  }
}
