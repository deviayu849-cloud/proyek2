import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/invoice.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/formatters.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  final User initialUser;

  const AdminDashboard({super.key, required this.initialUser});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late User _user;
  List<Booking> _bookings = [];
  List<Invoice> _invoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getProfile(),
        ApiService.getBookings(),
        ApiService.getInvoices(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _user = results[0] as User;
        _bookings = results[1] as List<Booking>;
        _invoices = results[2] as List<Invoice>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) {
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending =
        _bookings.where((booking) => booking.status == 'pending').length;
    final inProgress =
        _bookings.where((booking) => booking.status == 'in_progress').length;
    final completed =
        _bookings.where((booking) => booking.status == 'completed').length;
    final unpaid =
        _invoices.where((invoice) => invoice.status != 'paid').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JASAKU Admin'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: const Color(0xFF263238),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Admin',
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(
                            _user.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pantau ringkasan operasional dari mobile. Kelola detail penuh lewat dashboard web.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      _statCard('Booking', _bookings.length.toString(),
                          Icons.receipt_long, Colors.blue),
                      _statCard('Pending', pending.toString(),
                          Icons.pending_actions, Colors.orange),
                      _statCard('Proses', inProgress.toString(),
                          Icons.engineering, Colors.purple),
                      _statCard('Selesai', completed.toString(),
                          Icons.check_circle, Colors.green),
                      _statCard('Invoice', _invoices.length.toString(),
                          Icons.request_quote, Colors.teal),
                      _statCard('Belum Bayar', unpaid.toString(),
                          Icons.warning_amber, Colors.red),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Booking terbaru',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_bookings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('Belum ada booking.')),
                    )
                  else
                    ..._bookings.take(8).map(_bookingTile),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _bookingTile(Booking booking) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.build),
        title: Text(booking.service?.name ?? 'Booking #${booking.id}'),
        subtitle: Text(
          '${booking.customer?['name'] ?? '-'} - ${booking.technician?.name ?? 'Teknisi belum ditentukan'}\n'
          '${formatDate(booking.scheduledDate)}',
        ),
        trailing: Text(bookingStatusLabel(booking.status)),
      ),
    );
  }
}
