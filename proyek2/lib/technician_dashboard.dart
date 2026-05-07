import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class TechnicianDashboard extends StatefulWidget {
  final String name;

  const TechnicianDashboard({super.key, required this.name});

  @override
  State<TechnicianDashboard> createState() => _TechnicianDashboardState();
}

class _TechnicianDashboardState extends State<TechnicianDashboard> {
  int _selectedIndex = 0;

  late String _currentName;
  File? _currentImage;
  String _currentPhone = "08123456789";
  String _currentEmail = "teknisi@jasaku.id";
  String _currentAddress = "Alamat Teknisi";

  List<Map<String, dynamic>> _activeBookings = [];
  List<Map<String, dynamic>> _completedBookings = [];

  @override
  void initState() {
    super.initState();
    _currentName = widget.name;
    _loadTechnicianData();
    _loadDummyBookings();
  }

  void _loadDummyBookings() {
    _activeBookings = [
      {
        'id': 'BK-001',
        'customer': 'Budi Santoso',
        'service': 'Cuci AC',
        'address': 'Jl. Mawar No. 123, Jakarta Barat',
        'date': '20 April 2025',
        'time': '10:00',
        'status': 'menunggu',
        'phone': '08123456789',
        'notes': 'Lantai 3, pintu belakang',
      },
      {
        'id': 'BK-002',
        'customer': 'Siti Aminah',
        'service': 'Pengisian Freon AC',
        'address': 'Jl. Melati No. 45, Jakarta Selatan',
        'date': '20 April 2025',
        'time': '14:00',
        'status': 'menunggu',
        'phone': '08129876543',
        'notes': 'AC tidak dingin sama sekali',
      },
    ];

    _completedBookings = [
      {
        'id': 'BK-003',
        'customer': 'Budi Santoso',
        'service': 'Servis AC',
        'address': 'Jl. Mawar No. 123, Jakarta Barat',
        'date': '19 April 2025',
        'time': '09:00',
        'rating': 5,
        'completedAt': '19 April 2025 11:30',
      },
      {
        'id': 'BK-004',
        'customer': 'Dewi Lestari',
        'service': 'Bongkar Pasang AC',
        'address': 'Jl. Kenanga No. 78, Jakarta Timur',
        'date': '18 April 2025',
        'time': '13:00',
        'rating': 4,
        'completedAt': '18 April 2025 15:45',
      },
    ];
  }

  Future<void> _loadTechnicianData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentName = prefs.getString('technician_name') ?? widget.name;
      _currentPhone = prefs.getString('technician_phone') ?? "08123456789";
      _currentEmail = prefs.getString('technician_email') ?? "teknisi@jasaku.id";
      _currentAddress = prefs.getString('technician_address') ?? "Alamat Teknisi";
      String? imagePath = prefs.getString('technician_image');
      if (imagePath != null && File(imagePath).existsSync()) {
        _currentImage = File(imagePath);
      }
    });
  }

  Future<void> _saveTechnicianData({
    String? name,
    String? phone,
    String? email,
    String? address,
    File? image,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('technician_name', name);
    if (phone != null) await prefs.setString('technician_phone', phone);
    if (email != null) await prefs.setString('technician_email', email);
    if (address != null) await prefs.setString('technician_address', address);
    if (image != null) await prefs.setString('technician_image', image.path);
  }

  int get _totalBookings => _activeBookings.length + _completedBookings.length;
  int get _activeCount => _activeBookings.length;
  int get _completedCount => _completedBookings.length;

  void _updateBookingStatus(int index, String newStatus) {
  setState(() {
    if (newStatus == 'selesai') {
      final Map<String, dynamic> completedBooking = Map<String, dynamic>.from(_activeBookings[index]);
      completedBooking['completedAt'] = _getCurrentDateTime();
      completedBooking['rating'] = 0;
      _completedBookings.insert(0, completedBooking);
      _activeBookings.removeAt(index);
    } else {
      _activeBookings[index]['status'] = newStatus;
    }
  });
  
  String message = newStatus == 'menuju' 
      ? 'Status diubah menjadi Menuju Lokasi' 
      : (newStatus == 'selesai' ? 'Booking ditandai selesai' : 'Booking dibatalkan');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green),
  );
}

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return "${now.day} ${_getMonthName(now.month)} ${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "JASAKU - Teknisi",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (!context.mounted) return;
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                  },
                ),
              ],
            ),
          ),
          if (_selectedIndex != 0)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedIndex == 1 ? "Booking Saya" : (_selectedIndex == 2 ? "Riwayat" : "Profil Saya"),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedIndex == 1 ? "Kelola booking yang masuk" : (_selectedIndex == 2 ? "Riwayat booking selesai" : "Kelola data diri Anda"),
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomePage(),
                _buildActiveBookingsPage(),
                _buildHistoryPage(),
                _buildProfilePage(),
              ],
            ),
          ),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF1565C0),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.book_online), label: "Booking"),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade700]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: _currentImage != null ? FileImage(_currentImage!) : null,
                  child: _currentImage == null ? const Icon(Icons.person, color: Colors.blue, size: 30) : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Halo, $_currentName 👋", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text("Selamat bekerja hari ini!", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(Icons.receipt_long, "Total Booking", _totalBookings.toString(), Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard(Icons.pending, "Aktif", _activeCount.toString(), Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard(Icons.check_circle, "Selesai", _completedCount.toString(), Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Booking Terbaru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          if (_activeBookings.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text("Belum ada booking masuk", style: TextStyle(color: Colors.grey))),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeBookings.length > 3 ? 3 : _activeBookings.length,
              itemBuilder: (context, index) => _buildBookingCard(_activeBookings[index], index),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (booking['status']) {
      case 'menuju':
        statusColor = Colors.orange;
        statusText = 'Menuju Lokasi';
        statusIcon = Icons.directions_car;
        break;
      case 'selesai':
        statusColor = Colors.green;
        statusText = 'Selesai';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'Menunggu';
        statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(statusIcon, color: statusColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text("${booking['date']} • ${booking['time']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(booking['customer'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(booking['service'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(booking['address'], style: const TextStyle(fontSize: 12, color: Colors.grey))),
              ],
            ),
            if (booking['notes'] != null && booking['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note, size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(booking['notes'], style: const TextStyle(fontSize: 11, color: Colors.grey))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (booking['status'] == 'menunggu')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateBookingStatus(index, 'menuju'),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue)),
                      child: const Text("Menuju Lokasi"),
                    ),
                  ),
                if (booking['status'] == 'menunggu') const SizedBox(width: 12),
                if (booking['status'] == 'menuju')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateBookingStatus(index, 'selesai'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text("Selesai"),
                    ),
                  ),
                if (booking['status'] == 'menunggu' || booking['status'] == 'menuju')
                  const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCustomerContact(booking),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text("Hubungi"),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerContact(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Hubungi ${booking['customer']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text("Telepon"),
              subtitle: Text(booking['phone']),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.blue),
              title: const Text("WhatsApp"),
              subtitle: Text(booking['phone']),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text("Lihat Lokasi"),
              subtitle: Text(booking['address']),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup")),
        ],
      ),
    );
  }

  Widget _buildActiveBookingsPage() {
    if (_activeBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_online, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("Belum ada booking aktif", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeBookings.length,
      itemBuilder: (context, index) => _buildBookingCard(_activeBookings[index], index),
    );
  }

  Widget _buildHistoryPage() {
    if (_completedBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("Belum ada riwayat booking", style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedBookings.length,
      itemBuilder: (context, index) => _buildHistoryCard(_completedBookings[index]),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(booking['completedAt'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < booking['rating'] ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(booking['customer'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(booking['service'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(booking['address'], style: const TextStyle(fontSize: 12, color: Colors.grey))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            backgroundImage: _currentImage != null ? FileImage(_currentImage!) : null,
            child: _currentImage == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
          ),
          const SizedBox(height: 12),
          Text(_currentName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("Teknisi Bersertifikat", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 30),
          _buildProfileTile(Icons.person_outline, "Edit Profil", () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TechnicianEditProfilePage(
                  name: _currentName,
                  email: _currentEmail,
                  phone: _currentPhone,
                  address: _currentAddress,
                  image: _currentImage,
                ),
              ),
            );
            if (result != null && result is Map) {
              setState(() {
                _currentName = result['name'];
                _currentEmail = result['email'];
                _currentPhone = result['phone'];
                _currentAddress = result['address'];
                _currentImage = result['image'];
              });
              await _saveTechnicianData(
                name: result['name'],
                phone: result['phone'],
                email: result['email'],
                address: result['address'],
                image: result['image'],
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profil berhasil diperbarui!")),
              );
            }
          }),
          _buildProfileTile(Icons.star_border, "Rating & Ulasan", () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Rating: 4.5 (12 ulasan)")),
            );
          }),
          _buildProfileTile(Icons.info_outline, "Tentang Aplikasi", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TechnicianAboutPage()));
          }),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ================= TECHNICIAN EDIT PROFILE PAGE =================
class TechnicianEditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;
  final File? image;

  const TechnicianEditProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.image,
  });

  @override
  State<TechnicianEditProfilePage> createState() => _TechnicianEditProfilePageState();
}

class _TechnicianEditProfilePageState extends State<TechnicianEditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _addressController = TextEditingController(text: widget.address);
    _image = widget.image;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text("Edit Profil", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "No. Telepon", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Alamat", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    "name": _nameController.text,
                    "email": _emailController.text,
                    "phone": _phoneController.text,
                    "address": _addressController.text,
                    "image": _image,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Simpan", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= TECHNICIAN ABOUT PAGE =================
class TechnicianAboutPage extends StatelessWidget {
  const TechnicianAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text("Tentang Aplikasi", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.ac_unit, size: 64, color: Color(0xFF1565C0)),
                    const SizedBox(height: 16),
                    const Text("JASAKU", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                    const SizedBox(height: 8),
                    const Text("Versi 1.0.0", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    const Text(
                      "Aplikasi layanan servis AC terpercaya\nuntuk teknisi profesional",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}