import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/formatters.dart';
import 'login_screen.dart';

class TechnicianDashboard extends StatefulWidget {
  final User initialUser;

  const TechnicianDashboard({super.key, required this.initialUser});

  @override
  State<TechnicianDashboard> createState() => _TechnicianDashboardState();
}

class _TechnicianDashboardState extends State<TechnicianDashboard> {
  int _selectedIndex = 0;
  late User _user;
  List<Booking> _bookings = [];
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
      ]);

      if (!mounted) return;
      setState(() {
        _user = results[0] as User;
        _bookings = results[1] as List<Booking>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      _activeBookingsPage(),
      _historyPage(),
      _profilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('JASAKU Teknisi'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.work), label: 'Booking'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _homePage() {
    final active = _bookings.where((booking) => booking.isActive).length;
    final completed = _bookings.where((booking) => booking.isCompleted).length;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFF1565C0),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${_user.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user.specialization.isEmpty
                        ? 'Teknisi JASAKU'
                        : _user.specialization,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard(
                'Aktif',
                active.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
              const SizedBox(width: 12),
              _statCard(
                'Selesai',
                completed.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Tugas terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_bookings.where((booking) => booking.isActive).isEmpty)
            const _EmptyState(text: 'Belum ada booking aktif.')
          else
            ..._bookings
                .where((booking) => booking.isActive)
                .take(5)
                .map(_bookingCard),
        ],
      ),
    );
  }

  Widget _activeBookingsPage() {
    final activeBookings = _bookings
        .where((booking) => booking.isActive)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeBookings.isEmpty)
            const _EmptyState(text: 'Tidak ada booking aktif.')
          else
            ...activeBookings.map(_bookingCard),
        ],
      ),
    );
  }

  Widget _historyPage() {
    final history = _bookings.where((booking) => !booking.isActive).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (history.isEmpty)
            const _EmptyState(text: 'Riwayat masih kosong.')
          else
            ...history.map(_bookingCard),
        ],
      ),
    );
  }

  Widget _profilePage() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.email, _user.email),
                  _infoRow(
                    Icons.phone,
                    _user.phone.isEmpty ? '-' : _user.phone,
                  ),
                  _infoRow(
                    Icons.location_on,
                    _user.address.isEmpty ? '-' : _user.address,
                  ),
                  _infoRow(
                    Icons.handyman,
                    _user.specialization.isEmpty ? '-' : _user.specialization,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _showEditProfileDialog,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profil'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _showChangePasswordDialog,
            icon: const Icon(Icons.lock),
            label: const Text('Ubah Password'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookingCard(Booking booking) {
    final customerAddress = booking.customer?['address']?.toString() ?? '-';
    final serviceLocation = booking.serviceLocation.isEmpty
        ? customerAddress
        : booking.serviceLocation;
    final invoice = booking.invoice;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(bookingStatusLabel(booking.status)),
              ],
            ),
            const SizedBox(height: 8),
            Text(booking.service?.name ?? 'Layanan'),
            Text('Customer: ${booking.customer?['name'] ?? '-'}'),
            Text('Lokasi: $serviceLocation'),
            Text('Jadwal: ${formatDate(booking.scheduledDate)}'),
            Text('Total: ${formatRupiah(booking.totalPrice)}'),
            if (booking.notes.isNotEmpty) Text('Catatan: ${booking.notes}'),
            if (invoice != null) ...[
              const SizedBox(height: 10),
              _invoiceSummary(invoice),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (booking.status == 'pending')
                  FilledButton.tonal(
                    onPressed: () => _updateStatus(booking, 'confirmed'),
                    child: const Text('Terima'),
                  ),
                if (booking.status == 'confirmed')
                  FilledButton.tonal(
                    onPressed: () => _updateStatus(booking, 'en_route'),
                    child: const Text('Menuju Lokasi'),
                  ),
                if (booking.status == 'en_route')
                  FilledButton.tonal(
                    onPressed: () => _updateStatus(booking, 'in_progress'),
                    child: const Text('Mulai'),
                  ),
                if (booking.status == 'in_progress')
                  FilledButton(
                    onPressed: () => _completeBooking(booking),
                    child: const Text('Selesai'),
                  ),
                if (booking.status == 'pending' ||
                    booking.status == 'confirmed')
                  OutlinedButton(
                    onPressed: () => _updateStatus(booking, 'cancelled'),
                    child: const Text('Batalkan'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceSummary(Map<String, dynamic> invoice) {
    final invoiceNumber = invoice['invoice_number']?.toString() ?? 'Invoice';
    final status = invoice['status']?.toString() ?? '';
    final total = double.tryParse(invoice['total'].toString()) ?? 0;
    final pendingAmount =
        double.tryParse(invoice['pending_amount'].toString()) ?? 0;
    final latestPayment = invoice['latest_payment'];
    final latestPaymentStatus = latestPayment is Map<String, dynamic>
        ? latestPayment['status']?.toString() ?? ''
        : '';
    final latestPaymentId = latestPayment is Map<String, dynamic>
        ? int.tryParse(latestPayment['id'].toString())
        : null;
    final statusLabel = pendingAmount > 0
        ? 'Menunggu verifikasi'
        : invoiceStatusLabel(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Invoice',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                statusLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(invoiceNumber),
          Text(formatRupiah(total)),
          if (pendingAmount > 0)
            Text('Menunggu verifikasi ${formatRupiah(pendingAmount)}'),
          if (latestPaymentStatus.isNotEmpty)
            Text('Pembayaran: ${paymentStatusLabel(latestPaymentStatus)}'),
          if (latestPaymentId != null &&
              latestPaymentStatus == 'pending_approval') ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => _approvePayment(latestPaymentId),
                  child: const Text('Verifikasi'),
                ),
                OutlinedButton(
                  onPressed: () => _rejectPayment(latestPaymentId),
                  child: const Text('Tolak'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _approvePayment(int paymentId) async {
    try {
      await ApiService.approvePayment(paymentId, notes: 'Diverifikasi teknisi');
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil diverifikasi.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  Future<void> _rejectPayment(int paymentId) async {
    final reason = TextEditingController();
    final rejected = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pembayaran'),
        content: TextField(
          controller: reason,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Alasan penolakan'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (rejected != true) {
      reason.dispose();
      return;
    }

    if (reason.text.trim().isEmpty) {
      reason.dispose();
      _showError('Alasan penolakan wajib diisi.');
      return;
    }

    try {
      await ApiService.rejectPayment(paymentId, reason: reason.text);
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran ditolak.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      reason.dispose();
    }
  }

  Future<void> _updateStatus(Booking booking, String status) async {
    try {
      await ApiService.updateBookingStatus(booking.id, status);
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  Future<void> _completeBooking(Booking booking) async {
    final notes = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Booking'),
        content: TextField(
          controller: notes,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Catatan pekerjaan'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      notes.dispose();
      return;
    }

    try {
      await ApiService.updateBookingStatus(
        booking.id,
        'completed',
        notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      notes.dispose();
    }
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    final name = TextEditingController(text: _user.name);
    final email = TextEditingController(text: _user.email);
    final phone = TextEditingController(text: _user.phone);
    final address = TextEditingController(text: _user.address);
    final specialization = TextEditingController(text: _user.specialization);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil Teknisi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Telepon'),
              ),
              TextField(
                controller: address,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: specialization,
                decoration: const InputDecoration(labelText: 'Spesialisasi'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    try {
      final updated = await ApiService.updateProfile(
        name: name.text,
        email: email.text,
        phone: phone.text,
        address: address.text,
        specialization: specialization.text,
      );
      if (!mounted) return;
      setState(() => _user = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final current = TextEditingController();
    final password = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password lama'),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password baru'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    try {
      await ApiService.updatePassword(current.text, password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah.')),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    }
  }
}

class _EmptyState extends StatelessWidget {
  final String text;

  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(text, style: TextStyle(color: Colors.grey.shade600)),
      ),
    );
  }
}
