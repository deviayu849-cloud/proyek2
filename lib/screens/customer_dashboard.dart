import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/invoice.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/formatters.dart';
import 'login_screen.dart';
import 'order_page.dart';

class CustomerDashboard extends StatefulWidget {
  final User initialUser;

  const CustomerDashboard({super.key, required this.initialUser});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;
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

      if (!mounted) return;
      setState(() {
        _user = results[0] as User;
        _bookings = results[1] as List<Booking>;
        _invoices = results[2] as List<Invoice>;
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
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      OrderPage(onCreated: _loadData),
      _historyPage(),
      _profilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('JASAKU Customer'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
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
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Booking'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _homePage() {
    final active = _bookings.where((booking) => booking.isActive).length;
    final completed = _bookings.where((booking) => booking.isCompleted).length;
    final pendingInvoices =
        _invoices.where((invoice) => invoice.status != 'paid').length;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _welcomeCard(),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard('Aktif', active.toString(), Icons.pending_actions,
                  Colors.orange),
              const SizedBox(width: 12),
              _statCard('Selesai', completed.toString(), Icons.check_circle,
                  Colors.green),
              const SizedBox(width: 12),
              _statCard('Invoice', pendingInvoices.toString(), Icons.receipt,
                  Colors.blue),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Booking terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_bookings.isEmpty)
            const _EmptyState(text: 'Belum ada booking.')
          else
            ..._bookings.take(5).map(_bookingCard),
        ],
      ),
    );
  }

  Widget _historyPage() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Booking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_bookings.isEmpty)
            const _EmptyState(text: 'Riwayat booking kosong.')
          else
            ..._bookings.map(_bookingCard),
          const SizedBox(height: 24),
          const Text('Invoice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_invoices.isEmpty)
            const _EmptyState(text: 'Belum ada invoice.')
          else
            ..._invoices.map(_invoiceCard),
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
                  Text(_user.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _infoRow(Icons.email, _user.email),
                  _infoRow(
                      Icons.phone, _user.phone.isEmpty ? '-' : _user.phone),
                  _infoRow(Icons.location_on,
                      _user.address.isEmpty ? '-' : _user.address),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
              onPressed: _showEditProfileDialog,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profil')),
          const SizedBox(height: 10),
          OutlinedButton.icon(
              onPressed: _showChangePasswordDialog,
              icon: const Icon(Icons.lock),
              label: const Text('Ubah Password')),
        ],
      ),
    );
  }

  Widget _welcomeCard() {
    return Card(
      color: const Color(0xFF1565C0),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Halo,', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(_user.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Buat booking servis dan pantau statusnya dari sini.',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookingCard(Booking booking) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.build),
            title: Text(booking.service?.name ?? 'Layanan'),
            subtitle: Text(
              '${formatDate(booking.scheduledDate)}\n'
              '${booking.technician?.name ?? 'Teknisi belum ditentukan'}',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(bookingStatusLabel(booking.status),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(formatRupiah(booking.totalPrice)),
              ],
            ),
          ),
          if (booking.isCompleted)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  if (booking.hasRating)
                    Text('Rating ${booking.rating?['rating'] ?? '-'}/5',
                        style: TextStyle(color: Colors.grey.shade700)),
                  OutlinedButton.icon(
                    onPressed: () => _showRatingDialog(booking),
                    icon: const Icon(Icons.star),
                    label:
                        Text(booking.hasRating ? 'Ubah Rating' : 'Beri Rating'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _invoiceCard(Invoice invoice) {
    final service = invoice.booking?['service'];
    final serviceName = service is Map
        ? service['name']?.toString() ?? 'Booking #${invoice.bookingId}'
        : 'Booking #${invoice.bookingId}';

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(invoice.invoiceNumber),
            subtitle: Text(
                '$serviceName\nJatuh tempo: ${formatDate(invoice.dueDate)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(invoiceStatusLabel(invoice.status),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(formatRupiah(invoice.total)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                if (invoice.hasPendingPayment)
                  Text('Menunggu verifikasi',
                      style: TextStyle(color: Colors.grey.shade700)),
                if (!invoice.isPaid && !invoice.hasPendingPayment) ...[
                  Text('Sisa ${formatRupiah(invoice.remainingAmount)}',
                      style: TextStyle(color: Colors.grey.shade700)),
                  OutlinedButton.icon(
                    onPressed: () => _showPaymentDialog(invoice),
                    icon: const Icon(Icons.payments),
                    label: const Text('Bayar'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentDialog(Invoice invoice) async {
    final amount = TextEditingController(
        text: invoice.remainingAmount > 0
            ? invoice.remainingAmount.toStringAsFixed(0)
            : invoice.total.toStringAsFixed(0));
    final reference = TextEditingController();
    final notes = TextEditingController();
    var method = 'bank_transfer';

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Bayar Invoice'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nominal'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration:
                      const InputDecoration(labelText: 'Metode pembayaran'),
                  items: const [
                    DropdownMenuItem(
                        value: 'bank_transfer', child: Text('Transfer Bank')),
                    DropdownMenuItem(value: 'cash', child: Text('Tunai')),
                    DropdownMenuItem(value: 'check', child: Text('Cek')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => method = value);
                    }
                  },
                ),
                TextField(
                  controller: reference,
                  decoration:
                      const InputDecoration(labelText: 'Nomor referensi'),
                ),
                TextField(
                  controller: notes,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Catatan'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Kirim')),
          ],
        ),
      ),
    );

    if (submitted != true) {
      amount.dispose();
      reference.dispose();
      notes.dispose();
      return;
    }

    final parsedAmount =
        double.tryParse(amount.text.trim().replaceAll(',', '.')) ?? 0;

    try {
      await ApiService.submitPayment(
        invoiceId: invoice.id,
        amount: parsedAmount,
        paymentMethod: method,
        referenceNumber: reference.text,
        notes: notes.text,
      );
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pembayaran dikirim untuk verifikasi.'),
          backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      amount.dispose();
      reference.dispose();
      notes.dispose();
    }
  }

  Future<void> _showRatingDialog(Booking booking) async {
    final review = TextEditingController(
        text: booking.rating?['review']?.toString() ?? '');
    var rating = int.tryParse(booking.rating?['rating']?.toString() ?? '') ?? 5;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Rating Layanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: rating,
                decoration: const InputDecoration(labelText: 'Rating'),
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5 - Sangat baik')),
                  DropdownMenuItem(value: 4, child: Text('4 - Baik')),
                  DropdownMenuItem(value: 3, child: Text('3 - Cukup')),
                  DropdownMenuItem(value: 2, child: Text('2 - Kurang')),
                  DropdownMenuItem(value: 1, child: Text('1 - Buruk')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => rating = value);
                  }
                },
              ),
              TextField(
                controller: review,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Review'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Simpan')),
          ],
        ),
      ),
    );

    if (submitted != true) {
      review.dispose();
      return;
    }

    try {
      await ApiService.submitRating(
        bookingId: booking.id,
        rating: rating,
        review: review.text,
      );
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Rating berhasil disimpan.'),
          backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      review.dispose();
    }
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text))
      ]),
    );
  }

  Future<void> _showEditProfileDialog() async {
    final name = TextEditingController(text: _user.name);
    final email = TextEditingController(text: _user.email);
    final phone = TextEditingController(text: _user.phone);
    final address = TextEditingController(text: _user.address);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nama')),
              TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: 'Email')),
              TextField(
                  controller: phone,
                  decoration: const InputDecoration(labelText: 'Telepon')),
              TextField(
                  controller: address,
                  decoration: const InputDecoration(labelText: 'Alamat')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan')),
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
      );
      if (!mounted) return;
      setState(() => _user = updated);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui.')));
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
                decoration: const InputDecoration(labelText: 'Password lama')),
            TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password baru')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan')),
        ],
      ),
    );

    if (saved != true) return;

    try {
      await ApiService.updatePassword(current.text, password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah.')));
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
          child: Text(text, style: TextStyle(color: Colors.grey.shade600))),
    );
  }
}
