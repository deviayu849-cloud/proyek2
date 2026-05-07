import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedPaymentMethod = 'Tunai';
  String _selectedAddress = 'Rumah';
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // TAMBAHAN: controller untuk nomor telepon

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // TAMBAHAN: set nomor telepon default
    _phoneController.text = '08123456789';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _phoneController.dispose(); // TAMBAHAN: dispose controller
    super.dispose();
  }

  Map<String, dynamic>? get selectedServiceObj {
    if (_selectedService == null) return null;
    return _services.firstWhere((s) => s['id'].toString() == _selectedService);
  }

  int get totalPrice {
    final service = selectedServiceObj;
    if (service == null) return 0;
    return (service['price'] as int) * _quantity;
  }

  final List<Map<String, dynamic>> _services = [
    {'id': 1, 'name': 'Cuci AC', 'price': 75000, 'priceStr': 'Rp 75.000', 'icon': Icons.ac_unit, 'duration': '30-45 menit', 'description': 'Pembersihan AC secara menyeluruh', 'popular': true, 'color': 0xFF1565C0},
    {'id': 2, 'name': 'Pengisian Freon AC', 'price': 200000, 'priceStr': 'Rp 200.000', 'icon': Icons.air, 'duration': '45-60 menit', 'description': 'Pengisian ulang freon untuk AC', 'popular': true, 'color': 0xFFE65100},
    {'id': 3, 'name': 'Servis AC Komprehensif', 'price': 150000, 'priceStr': 'Rp 150.000', 'icon': Icons.build, 'duration': '60-90 menit', 'description': 'Pembersihan total + perbaikan minor', 'popular': false, 'color': 0xFF6A1B9A},
    {'id': 4, 'name': 'Bongkar Pasang AC', 'price': 250000, 'priceStr': 'Rp 250.000', 'icon': Icons.settings, 'duration': '90-120 menit', 'description': 'Pembongkaran dan pemasangan AC', 'popular': false, 'color': 0xFF2E7D32},
  ];
  
  final List<Map<String, dynamic>> _addresses = [
    {'label': 'Rumah', 'address': 'Jl. Mawar No. 123, Jakarta Barat', 'isDefault': true},
    {'label': 'Kantor', 'address': 'Jl. Sudirman No. 45, Jakarta Selatan', 'isDefault': false},
  ];
  
  final List<String> _paymentMethods = ['Tunai', 'Transfer Bank', 'GoPay', 'OVO', 'DANA'];

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submitOrder() async {
    if (_selectedService == null) {
      _showSnackbar("Pilih layanan terlebih dahulu");
      return;
    }
    if (_selectedDate == null) {
      _showSnackbar("Pilih tanggal layanan");
      return;
    }
    if (_selectedTime == null) {
      _showSnackbar("Pilih waktu layanan");
      return;
    }
    // TAMBAHAN: validasi nomor telepon
    if (_phoneController.text.isEmpty) {
      _showSnackbar("Masukkan nomor telepon");
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _confirmRow('Layanan', selectedServiceObj!['name']),
            _confirmRow('Tanggal', '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            _confirmRow('Waktu', _selectedTime!.format(context)),
            _confirmRow('Jumlah', '$_quantity unit'),
            _confirmRow('No. Telepon', _phoneController.text), // TAMBAHAN: menampilkan nomor telepon
            _confirmRow('Total', 'Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Konfirmasi')),
        ],
      ),
    );

    if (confirmed == true) {
      _showSnackbar("Pesanan berhasil dibuat! 🎉");
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // Header tanpa tombol back
          Container(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Buat Pesanan",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Pilih layanan AC terbaik untukmu",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab Bar
          Container(
            color: const Color(0xFF0D47A1),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: "Pilih Layanan"),
                Tab(text: "Detail Pemesanan"),
              ],
            ),
          ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Pilih Layanan
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _services.map((service) => _serviceCard(service)).toList(),
                  ),
                ),
                // Tab 2: Detail Pemesanan
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedService != null) ...[
                        _selectedServiceCard(),
                        const SizedBox(height: 20),
                      ],
                      // TAMBAHAN: Section Nomor Telepon
                      _sectionHeader(Icons.phone, "Nomor Telepon"),
                      const SizedBox(height: 8),
                      _phoneNumberField(),
                      const SizedBox(height: 20),
                      _sectionHeader(Icons.production_quantity_limits, "Jumlah Unit"),
                      const SizedBox(height: 8),
                      _quantitySelector(),
                      const SizedBox(height: 20),
                      _sectionHeader(Icons.calendar_today, "Jadwal Layanan"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _dateTile()),
                          const SizedBox(width: 12),
                          Expanded(child: _timeTile()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionHeader(Icons.location_on, "Alamat Layanan"),
                      const SizedBox(height: 8),
                      _addressTile(),
                      const SizedBox(height: 20),
                      _sectionHeader(Icons.payment, "Metode Pembayaran"),
                      const SizedBox(height: 8),
                      _paymentTile(),
                      const SizedBox(height: 20),
                      _sectionHeader(Icons.note_add, "Catatan Tambahan"),
                      const SizedBox(height: 8),
                      _notesField(),
                      const SizedBox(height: 24),
                      if (_selectedService != null) ...[
                        _priceSummary(),
                        const SizedBox(height: 24),
                        _submitButton(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAMBAHAN: Widget untuk field nomor telepon
  Widget _phoneNumberField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: "Contoh: 08123456789",
          labelText: "Nomor Telepon",
          prefixIcon: const Icon(Icons.phone, color: Color(0xFF1565C0)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _serviceCard(Map<String, dynamic> service) {
    final isSelected = _selectedService == service['id'].toString();
    final color = Color(service['color'] as int);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedService = service['id'].toString();
          _tabController.animateTo(1);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(service['icon'] as IconData, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(service['description'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(service['priceStr'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(service['duration'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _selectedServiceCard() {
    final service = selectedServiceObj!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(service['icon'] as IconData, color: const Color(0xFF1565C0), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(service['priceStr'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0), fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedService = null;
                _tabController.animateTo(0);
              });
            },
            icon: const Icon(Icons.edit, color: Colors.grey, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _quantitySelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Jumlah AC", style: TextStyle(fontSize: 14)),
          Row(
            children: [
              _qtyButton(Icons.remove, () { if (_quantity > 1) setState(() => _quantity--); }),
              Container(width: 50, alignment: Alignment.center, child: Text("$_quantity", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              _qtyButton(Icons.add, () => setState(() => _quantity++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18)),
    );
  }

  Widget _dateTile() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 20, color: Color(0xFF1565C0)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDate != null ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" : "Pilih Tanggal",
                style: TextStyle(fontSize: 13, color: _selectedDate != null ? Colors.black87 : Colors.grey),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _timeTile() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: Color(0xFF1565C0)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedTime != null ? _selectedTime!.format(context) : "Pilih Waktu",
                style: TextStyle(fontSize: 13, color: _selectedTime != null ? Colors.black87 : Colors.grey),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _addressTile() {
    final address = _addresses.firstWhere((a) => a['label'] == _selectedAddress);
    return GestureDetector(
      onTap: () => _showAddressPicker(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            Icon(_selectedAddress == 'Rumah' ? Icons.home : Icons.business, size: 20, color: const Color(0xFF1565C0)),
            const SizedBox(width: 12),
            Expanded(child: Text(address['address'], style: const TextStyle(fontSize: 13))),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pilih Alamat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ..._addresses.map((addr) => ListTile(
              leading: Icon(addr['label'] == 'Rumah' ? Icons.home : Icons.business, color: _selectedAddress == addr['label'] ? const Color(0xFF1565C0) : Colors.grey),
              title: Text(addr['label']),
              subtitle: Text(addr['address'], maxLines: 1),
              trailing: _selectedAddress == addr['label'] ? const Icon(Icons.check_circle, color: Color(0xFF1565C0)) : null,
              onTap: () { setState(() => _selectedAddress = addr['label']); Navigator.pop(context); },
            )),
          ],
        ),
      ),
    );
  }

  Widget _paymentTile() {
    return GestureDetector(
      onTap: () => _showPaymentPicker(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            const Icon(Icons.wallet, size: 20, color: Color(0xFF1565C0)),
            const SizedBox(width: 12),
            Expanded(child: Text(_selectedPaymentMethod, style: const TextStyle(fontSize: 13))),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showPaymentPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pilih Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ..._paymentMethods.map((method) => ListTile(
              leading: Icon(_getPaymentIcon(method), color: _selectedPaymentMethod == method ? const Color(0xFF1565C0) : Colors.grey),
              title: Text(method),
              trailing: _selectedPaymentMethod == method ? const Icon(Icons.check_circle, color: Color(0xFF1565C0)) : null,
              onTap: () { setState(() => _selectedPaymentMethod = method); Navigator.pop(context); },
            )),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'Tunai': return Icons.money;
      case 'Transfer Bank': return Icons.account_balance;
      case 'GoPay': return Icons.qr_code_scanner;
      case 'OVO': return Icons.phone_android;
      default: return Icons.wallet;
    }
  }

  Widget _notesField() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "Contoh: Lantai 3, pintu belakang...",
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _priceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _priceRow("Harga Layanan", selectedServiceObj!['priceStr']),
          const SizedBox(height: 8),
          _priceRow("Jumlah Unit", "$_quantity x"),
          const Divider(height: 24),
          _priceRow("Total", "Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}", isTotal: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? const Color(0xFF1565C0) : Colors.black87)),
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submitOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text("Buat Pesanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1565C0)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}