import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'order_page.dart';

class CustomerDashboard extends StatefulWidget {
  final String name;

  const CustomerDashboard({super.key, required this.name});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;

  late String _currentName;
  String _currentEmail = "user@email.com";
  String _currentPhone = "08123456789";
  String _currentAddress = "Alamat Anda";
  File? _currentImage;

  @override
  void initState() {
    super.initState();
    _currentName = widget.name;
    _loadUserData();
  }

  // FUNGSI UNTUK MEMUAT DATA TERSIMPAN
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentName = prefs.getString('user_name') ?? widget.name;
      _currentEmail = prefs.getString('user_email') ?? "user@email.com";
      _currentPhone = prefs.getString('user_phone') ?? "08123456789";
      _currentAddress = prefs.getString('user_address') ?? "Alamat Anda";
      String? imagePath = prefs.getString('user_image');
      if (imagePath != null && File(imagePath).existsSync()) {
        _currentImage = File(imagePath);
      }
    });
  }

  // FUNGSI UNTUK MENYIMPAN DATA
  Future<void> _saveUserData({
    String? name,
    String? email,
    String? phone,
    String? address,
    File? image,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('user_name', name);
    if (email != null) await prefs.setString('user_email', email);
    if (phone != null) await prefs.setString('user_phone', phone);
    if (address != null) await prefs.setString('user_address', address);
    if (image != null) await prefs.setString('user_image', image.path);
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _homePage();
      case 1:
        return const OrderPage();
      case 2:
        return _notificationPage();
      case 3:
        return _profilePage();
      default:
        return _homePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "JASAKU",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Apakah kamu yakin ingin logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Pesanan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notif"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  // ===== HOME PAGE =====
  Widget _homePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Beranda",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Selamat datang kembali, $_currentName!",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: _currentImage != null ? FileImage(_currentImage!) : null,
                        child: _currentImage == null
                            ? const Icon(Icons.person, color: Colors.blue, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Halo, $_currentName 👋",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Ada yang bisa kami bantu hari ini?",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Menu Utama",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                GridView.count(
  crossAxisCount: 2,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  mainAxisSpacing: 15,
  crossAxisSpacing: 15,
  childAspectRatio: 1.1,
  children: [
    _menuItem(Icons.add_shopping_cart, "Buat Pesanan", Colors.blue.shade600, () {
      setState(() => _selectedIndex = 1);
    }),
    _menuItem(Icons.receipt_long, "Invoice", Colors.purple.shade600, () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoicePage()));
    }),
    _menuItem(Icons.help, "Bantuan", Colors.green.shade600, () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
    }),
    _menuItem(Icons.history, "Riwayat", Colors.blue.shade600, () {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryPage()));
    }),
  ],
),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Layanan Populer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedIndex = 1);
                      },
                      child: const Text(
                        "Lihat Semua",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _serviceCardModern(
                  title: "Pengisian Freon AC",
                  desc: "AC tidak dingin? Isi freon sekarang!",
                  price: "Rp 200.000",
                  duration: "45-60 menit",
                  isPopular: true,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                  },
                ),
                const SizedBox(height: 15),
                _serviceCardModern(
                  title: "Cuci AC",
                  desc: "Bersihkan AC agar lebih sehat dan awet",
                  price: "Rp 75.000",
                  duration: "30-45 menit",
                  isPopular: false,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceCardModern({
    required String title,
    required String desc,
    required String price,
    required String duration,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: const Icon(Icons.ac_unit, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Populer",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          duration,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.arrow_forward_ios, color: Colors.blue.shade700, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  // ===== NOTIFICATION PAGE =====
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Pesanan Dikonfirmasi!',
      'message': 'Pesanan Cuci AC kamu telah dikonfirmasi. Teknisi akan segera menghubungi kamu.',
      'time': '2 menit lalu',
      'isRead': false,
      'icon': Icons.check_circle_rounded,
      'color': 0xFF1565C0,
    },
    {
      'id': 2,
      'title': 'Promo Spesial! 🎉',
      'message': 'Dapatkan diskon 30% untuk layanan Cuci AC hari ini saja. Jangan sampai ketinggalan!',
      'time': '1 jam lalu',
      'isRead': false,
      'icon': Icons.local_offer_rounded,
      'color': 0xFFE65100,
    },
    {
      'id': 3,
      'title': 'Teknisi Dalam Perjalanan',
      'message': 'Budi Santoso sedang dalam perjalanan menuju lokasi kamu. Estimasi tiba 20 menit.',
      'time': '3 jam lalu',
      'isRead': true,
      'icon': Icons.directions_bike_rounded,
      'color': 0xFF2E7D32,
    },
  ];

  int get _unreadCount => _notifications.where((n) => n['isRead'] == false).length;

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
  }

  Widget _notificationPage() {
    final unread = _notifications.where((n) => n['isRead'] == false).toList();
    final read = _notifications.where((n) => n['isRead'] == true).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Notifikasi",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  if (_unreadCount > 0)
                    Text(
                      "$_unreadCount belum dibaca",
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                ],
              ),
              if (_unreadCount > 0)
                TextButton.icon(
                  onPressed: _markAllRead,
                  icon: const Icon(Icons.done_all_rounded, size: 16, color: Colors.blue),
                  label: const Text("Tandai semua"),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: Colors.blue.withOpacity(0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _notifications.isEmpty
              ? _notifEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (unread.isNotEmpty) ...[
                      ...unread.map((n) => _notifCard(n)),
                    ],
                    if (read.isNotEmpty) ...[
                      ...read.map((n) => _notifCard(n)),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _notifCard(Map<String, dynamic> notif) {
    final color = Color(notif['color'] as int);
    final isRead = notif['isRead'] as bool;
    final id = notif['id'] as int;

    return Dismissible(
      key: Key('notif_$id'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        setState(() {
          _notifications.removeWhere((n) => n['id'] == id);
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            final n = _notifications.firstWhere((n) => n['id'] == id);
            n['isRead'] = true;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead ? Colors.grey.shade200 : color.withOpacity(0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(notif['icon'] as IconData, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(notif['message'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(notif['time'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notifEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 56, color: Colors.blue.shade300),
          const SizedBox(height: 20),
          const Text("Tidak Ada Notifikasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  // ===== PROFILE PAGE =====
  Widget _profilePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blue,
              backgroundImage: _currentImage != null ? FileImage(_currentImage!) : null,
              child: _currentImage == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
            ),
            const SizedBox(height: 10),
            Text(_currentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Pelanggan", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            _profileItem(Icons.person, "Edit Profil"),
            _profileItem(Icons.lock, "Ubah Password"),
            _profileItem(Icons.history, "Riwayat Pesanan"),
            _profileItem(Icons.help, "Bantuan"),
            _profileItem(Icons.info, "Tentang Aplikasi"),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  LoginScreen()));
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String title) {
    return InkWell(
      onTap: () async {
        if (title == "Edit Profil") {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfilePage(
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
            await _saveUserData(
              name: result['name'],
              email: result['email'],
              phone: result['phone'],
              address: result['address'],
              image: result['image'],
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profil berhasil diperbarui!")),
            );
          }
        }

        if (title == "Ubah Password") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
        }
        if (title == "Riwayat Pesanan") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryPage()));
        }
        if (title == "Bantuan") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
        }
        if (title == "Tentang Aplikasi") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 15),
            Expanded(child: Text(title)),
            const Icon(Icons.arrow_forward_ios, size: 16)
          ],
        ),
      ),
    );
  }
}

// ================= INVOICE PAGE =================
class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  void _showInvoiceDetail(BuildContext context, String invoiceNumber, String date, 
      String serviceName, int price, int quantity, int total, String technician, String address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt, color: Color(0xFF1565C0), size: 40),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "INVOICE",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    invoiceNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _detailRow("Tanggal", date),
                      _detailRow("Layanan", serviceName),
                      _detailRow("Teknisi", technician),
                      _detailRow("Alamat", address),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _detailRow("Harga Satuan", formatRupiah(price)),
                      _detailRow("Jumlah", "$quantity Unit"),
                      const Divider(height: 16),
                      _detailRow("Total", formatRupiah(total), isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Status Pembayaran",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "LUNAS",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? const Color(0xFF1565C0) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text("Invoice", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInvoiceCard(
            context: context,
            invoiceNumber: "INV-2025-001",
            date: "20 April 2025",
            serviceName: "Cuci AC",
            price: 75000,
            quantity: 2,
            total: 150000,
            status: "Lunas",
            statusColor: Colors.green,
            technician: "Budi Santoso",
            address: "Jl. Mawar No. 123, Jakarta Barat",
          ),
          _buildInvoiceCard(
            context: context,
            invoiceNumber: "INV-2025-002",
            date: "24 April 2025",
            serviceName: "Pengisian Freon AC",
            price: 200000,
            quantity: 1,
            total: 200000,
            status: "Lunas",
            statusColor: Colors.green,
            technician: "Andi Wijaya",
            address: "Jl. Sudirman No. 45, Jakarta Selatan",
          ),
          _buildInvoiceCard(
            context: context,
            invoiceNumber: "INV-2025-003",
            date: "27 April 2025",
            serviceName: "Servis AC Komprehensif",
            price: 150000,
            quantity: 1,
            total: 150000,
            status: "Pending",
            statusColor: Colors.orange,
            technician: "-",
            address: "Jl. Mawar No. 123, Jakarta Barat",
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard({
    required BuildContext context,
    required String invoiceNumber,
    required String date,
    required String serviceName,
    required int price,
    required int quantity,
    required int total,
    required String status,
    required Color statusColor,
    required String technician,
    required String address,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoiceNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.ac_unit, color: Color(0xFF1565C0), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text("Teknisi: $technician", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _invoiceRow("Harga", formatRupiah(price)),
                _invoiceRow("Jumlah", "$quantity x"),
                const Divider(height: 16),
                _invoiceRow("Total", formatRupiah(total), isTotal: true),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(address, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showInvoiceDetail(context, invoiceNumber, date, serviceName, price, quantity, total, technician, address);
                    },
                    icon: const Icon(Icons.receipt, size: 18, color: Colors.white),
                    label: const Text(
                      "Lihat Detail Invoice",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 14 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.black87 : Colors.grey)),
          Text(value, style: TextStyle(fontSize: isTotal ? 16 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? const Color(0xFF1565C0) : Colors.black87)),
        ],
      ),
    );
  }
}

String formatRupiah(int amount) {
  return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
}

// ================= RIWAYAT TRANSAKSI PAGE =================
class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> transactions = [
      {'id': 'TRX-001', 'date': '20 April 2025', 'time': '14:30', 'service': 'Cuci AC', 'quantity': 2, 'amount': 150000, 'status': 'success', 'paymentMethod': 'GoPay', 'technician': 'Budi Santoso', 'address': 'Jl. Mawar No. 123, Jakarta Barat'},
      {'id': 'TRX-002', 'date': '15 April 2025', 'time': '10:00', 'service': 'Pengisian Freon AC', 'quantity': 1, 'amount': 200000, 'status': 'success', 'paymentMethod': 'Transfer Bank', 'technician': 'Andi Wijaya', 'address': 'Jl. Sudirman No. 45, Jakarta Selatan'},
      {'id': 'TRX-003', 'date': '10 April 2025', 'time': '09:15', 'service': 'Servis AC Komprehensif', 'quantity': 1, 'amount': 150000, 'status': 'success', 'paymentMethod': 'Tunai', 'technician': 'Budi Santoso', 'address': 'Jl. Mawar No. 123, Jakarta Barat'},
    ];

    int getTotalAmount() {
      int total = 0;
      for (var tx in transactions) {
        if (tx['status'] == 'success') total += tx['amount'] as int;
      }
      return total;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
  backgroundColor: const Color(0xFF1565C0),
  title: const Text("Riwayat Transaksi", style: TextStyle(color: Colors.white)),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Navigator.pop(context),
  ),
  centerTitle: true,  // ✅ Pindahkan ke sini
),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Pengeluaran", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(formatRupiah(getTotalAmount()), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.receipt_long, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return _buildTransactionCard(
                  context: context,
                  id: tx['id'] as String,
                  date: tx['date'] as String,
                  time: tx['time'] as String,
                  service: tx['service'] as String,
                  quantity: tx['quantity'] as int,
                  amount: tx['amount'] as int,
                  status: tx['status'] as String,
                  paymentMethod: tx['paymentMethod'] as String,
                  technician: tx['technician'] as String,
                  address: tx['address'] as String,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard({
    required BuildContext context,
    required String id,
    required String date,
    required String time,
    required String service,
    required int quantity,
    required int amount,
    required String status,
    required String paymentMethod,
    required String technician,
    required String address,
  }) {
    final isSuccess = status == 'success';
    final statusColor = isSuccess ? Colors.green : Colors.orange;
    final statusText = isSuccess ? 'Berhasil' : 'Menunggu';
    final statusIcon = isSuccess ? Icons.check_circle : Icons.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetail(
            context: context,
            id: id,
            date: date,
            time: time,
            service: service,
            quantity: quantity,
            amount: amount,
            statusText: statusText,
            paymentMethod: paymentMethod,
            technician: technician,
            address: address,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                            Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text("$date • $time", style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text("$quantity unit", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Text(formatRupiah(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1565C0))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.payment, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(paymentMethod, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    const SizedBox(width: 12),
                    Icon(Icons.person, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(child: Text(technician, style: TextStyle(fontSize: 11, color: Colors.grey.shade500))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail({
    required BuildContext context,
    required String id,
    required String date,
    required String time,
    required String service,
    required int quantity,
    required int amount,
    required String statusText,
    required String paymentMethod,
    required String technician,
    required String address,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Detail Transaksi", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("ID Transaksi", id),
            _detailRow("Tanggal", date),
            _detailRow("Waktu", time),
            _detailRow("Layanan", service),
            _detailRow("Jumlah", "$quantity unit"),
            _detailRow("Teknisi", technician),
            _detailRow("Alamat", address),
            _detailRow("Metode Pembayaran", paymentMethod),
            _detailRow("Status", statusText),
            const Divider(),
            _detailRow("Total", formatRupiah(amount), isBold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
// ================= EDIT PROFIL (REDESIGNED) =================
class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;
  final File? image;

  const EditProfilePage({
    super.key,
    required this.name,
    this.email = "user@email.com",
    this.phone = "08123456789",
    this.address = "Alamat Anda",
    this.image,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isSaving = false;
  int? _focusedField;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _addressController = TextEditingController(text: widget.address);
    _image = widget.image;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ubah Foto Profil",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              "Pilih sumber foto kamu",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _imageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: "Galeri",
                  color: Colors.blue,
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? picked = await _picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 85);
                    if (picked != null) {
                      setState(() => _image = File(picked.path));
                    }
                  },
                ),
                const SizedBox(width: 16),
                _imageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Kamera",
                  color: Colors.teal,
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? picked = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 85);
                    if (picked != null) {
                      setState(() => _image = File(picked.path));
                    }
                  },
                ),
                if (_image != null) ...[
                  const SizedBox(width: 16),
                  _imageSourceOption(
                    icon: Icons.delete_rounded,
                    label: "Hapus",
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _image = null);
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, {
      "name": _nameController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "address": _addressController.text,
      "image": _image,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: const Color(0xFF1565C0),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 16, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -40,
                        right: -40,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        left: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      )
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _image != null
                                        ? Image.file(_image!,
                                            fit: BoxFit.cover)
                                        : Container(
                                            color: Colors.blue.shade300,
                                            child: const Icon(Icons.person,
                                                size: 50, color: Colors.white),
                                          ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 8,
                                        )
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 16,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _nameController.text.isEmpty
                                  ? "Nama Kamu"
                                  : _nameController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Pelanggan JASAKU",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel("Informasi Pribadi"),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            _formField(
                              index: 0,
                              controller: _nameController,
                              label: "Nama Lengkap",
                              icon: Icons.person_outline_rounded,
                              hint: "Masukkan nama lengkap",
                              keyboardType: TextInputType.name,
                              onChanged: (_) => setState(() {}),
                            ),
                            _divider(),
                            _formField(
                              index: 1,
                              controller: _emailController,
                              label: "Email",
                              icon: Icons.email_outlined,
                              hint: "contoh@email.com",
                              keyboardType: TextInputType.emailAddress,
                            ),
                            _divider(),
                            _formField(
                              index: 2,
                              controller: _phoneController,
                              label: "No. HP",
                              icon: Icons.phone_outlined,
                              hint: "08xxxxxxxxxx",
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionLabel("Alamat"),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: _formField(
                          index: 3,
                          controller: _addressController,
                          label: "Alamat Lengkap",
                          icon: Icons.location_on_outlined,
                          hint: "Jl. Contoh No. 1, Kota...",
                          keyboardType: TextInputType.streetAddress,
                          maxLines: 3,
                          isLast: true,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.blue.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: Colors.blue.shade600, size: 18),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Pastikan data yang kamu masukkan sudah benar sebelum menyimpan.",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.blue.shade200,
                            elevation: 6,
                            shadowColor:
                                Colors.blue.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded,
                                        size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      "Simpan Perubahan",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  Widget _formField({
    required int index,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isLast = false,
    void Function(String)? onChanged,
  }) {
    final isFocused = _focusedField == index;

    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _focusedField = hasFocus ? index : null);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isFocused
              ? Colors.blue.withOpacity(0.03)
              : Colors.transparent,
          borderRadius: isLast
              ? BorderRadius.circular(20)
              : BorderRadius.zero,
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle:
                const TextStyle(color: Colors.black26, fontSize: 13),
            labelStyle: TextStyle(
              color: isFocused ? const Color(0xFF1565C0) : Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: Icon(
                icon,
                color: isFocused ? const Color(0xFF1565C0) : Colors.grey,
                size: 20,
              ),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}

// ================= UBAH PASSWORD =================
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('user_password') ?? '';

    if (savedPassword.isNotEmpty &&
        _oldPasswordController.text != savedPassword) {
      setState(() => _isLoading = false);
      if (!context.mounted) return;
      _showSnackbar("Password lama tidak sesuai!", isError: true);
      return;
    }

    await prefs.setString('user_password', _newPasswordController.text);
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() => _isLoading = false);

    if (!context.mounted) return;
    _showSnackbar("Password berhasil diperbarui! 🎉", isError: false);

    await Future.delayed(const Duration(milliseconds: 1200));
    if (context.mounted) Navigator.pop(context);
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? Colors.redAccent : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  double _getStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.25;
    return strength;
  }

  Color _strengthColor(double strength) {
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.5) return Colors.orange;
    if (strength <= 0.75) return Colors.amber;
    return Colors.green;
  }

  String _strengthLabel(double strength) {
    if (strength <= 0.25) return "Lemah";
    if (strength <= 0.5) return "Sedang";
    if (strength <= 0.75) return "Kuat";
    return "Sangat Kuat";
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getStrength(_newPasswordController.text);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.07), blurRadius: 8)
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: Colors.black87),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ubah Password",
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade600,
                          Colors.blue.shade900
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.lock_outline,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Keamanan Akun",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Perbarui password secara berkala\nuntuk menjaga keamanan akun kamu.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text("Password Lama",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black54)),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    controller: _oldPasswordController,
                    label: "Masukkan password lama",
                    show: _showOld,
                    onToggle: () => setState(() => _showOld = !_showOld),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Password lama tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text("Password Baru",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black54)),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: "Masukkan password baru",
                    show: _showNew,
                    onToggle: () => setState(() => _showNew = !_showNew),
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Password baru tidak boleh kosong";
                      }
                      if (val.length < 6) {
                        return "Password minimal 6 karakter";
                      }
                      if (val == _oldPasswordController.text) {
                        return "Password baru tidak boleh sama dengan yang lama";
                      }
                      return null;
                    },
                  ),
                  if (_newPasswordController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: strength,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _strengthColor(strength)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _strengthLabel(strength),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _strengthColor(strength),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Gunakan huruf besar, angka, dan simbol untuk password yang lebih kuat.",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text("Konfirmasi Password Baru",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black54)),
                  const SizedBox(height: 8),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: "Ulangi password baru",
                    show: _showConfirm,
                    onToggle: () =>
                        setState(() => _showConfirm = !_showConfirm),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Konfirmasi password tidak boleh kosong";
                      }
                      if (val != _newPasswordController.text) {
                        return "Password tidak cocok";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.blue.shade300,
                        elevation: 4,
                        shadowColor: Colors.blue.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded, size: 20),
                                SizedBox(width: 8),
                                Text("Simpan Password",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.tips_and_updates_outlined,
                            color: Colors.amber.shade700, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Tips: Jangan gunakan tanggal lahir atau nama sebagai password. Kombinasikan huruf, angka, dan simbol.",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool show,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !show,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.8),
        ),
        prefixIcon:
            const Icon(Icons.lock_outline, color: Colors.blue, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            show
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}

// ================= RIWAYAT PESANAN (REDESIGNED) =================
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#JS-001',
      'title': 'Cuci AC',
      'date': '20 Apr 2025',
      'time': '10:00',
      'price': 'Rp 75.000',
      'status': 'Selesai',
      'tech': 'Budi Santoso',
      'icon': Icons.ac_unit,
      'colorVal': 0xFF1565C0,
      'canRate': true,
      'rated': false,
    },
    {
      'id': '#JS-002',
      'title': 'Pengisian Freon AC',
      'date': '24 Apr 2025',
      'time': '13:00',
      'price': 'Rp 200.000',
      'status': 'Diproses',
      'tech': 'Andi Wijaya',
      'icon': Icons.air,
      'colorVal': 0xFFE65100,
      'canRate': false,
      'rated': false,
    },
    {
      'id': '#JS-003',
      'title': 'Servis AC',
      'date': '27 Apr 2025',
      'time': '09:00',
      'price': 'Rp 150.000',
      'status': 'Menunggu',
      'tech': '-',
      'icon': Icons.build,
      'colorVal': 0xFF6A1B9A,
      'canRate': false,
      'rated': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredOrders(String status) {
    if (status == 'Semua') return _orders;
    return _orders.where((o) => o['status'] == status).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Diproses':
        return Colors.orange;
      case 'Menunggu':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Selesai':
        return Icons.check_circle_rounded;
      case 'Diproses':
        return Icons.sync_rounded;
      case 'Menunggu':
        return Icons.schedule_rounded;
      default:
        return Icons.help_outline;
    }
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final color = Color(order['colorVal'] as int);
    final status = order['status'] as String;
    final canRate = order['canRate'] as bool;
    final rated = order['rated'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(order['icon'] as IconData,
                      color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['title'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order['id'] as String,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(status),
                          color: _statusColor(status), size: 13),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: _statusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Detail
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow(Icons.calendar_today_outlined,
                    "${order['date']}  •  ${order['time']}", Colors.grey),
                const SizedBox(height: 8),
                _detailRow(Icons.engineering_outlined,
                    "Teknisi: ${order['tech']}", Colors.grey),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Pembayaran",
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        Text(
                          order['price'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    if (canRate)
                      rated
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.star_rounded,
                                      color: Colors.amber, size: 16),
                                  SizedBox(width: 4),
                                  Text("Sudah Dinilai",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (_) => RatingDialog(
                                    serviceName: order['title'] as String,
                                  ),
                                );
                                setState(() {
                                  order['rated'] = true;
                                });
                              },
                              icon: const Icon(Icons.star_outline_rounded,
                                  size: 16),
                              label: const Text("Beri Rating"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade600,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_outlined,
                  size: 56, color: Colors.blue.shade300),
            ),
            const SizedBox(height: 20),
            const Text(
              "Belum Ada Pesanan",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              "Pesanan kamu akan muncul di sini setelah kamu membuat pesanan baru.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: const Color(0xFF1565C0),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06)),
                    ),
                  ),
                  const Positioned(
                    bottom: 50,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Riwayat Pesanan",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Pantau semua layanan kamu",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: const Color(0xFF0D47A1),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: "Semua"),
                    Tab(text: "Diproses"),
                    Tab(text: "Selesai"),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  _statCard("Total", "${_orders.length}",
                      Icons.receipt_long, Colors.blue),
                  const SizedBox(width: 10),
                  _statCard("Selesai",
                      "${_filteredOrders('Selesai').length}",
                      Icons.check_circle, Colors.green),
                  const SizedBox(width: 10),
                  _statCard("Proses",
                      "${_filteredOrders('Diproses').length}",
                      Icons.sync, Colors.orange),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderList('Semua'),
            _buildOrderList('Diproses'),
            _buildOrderList('Selesai'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(String filter) {
    final orders = _filteredOrders(filter);
    if (orders.isEmpty) return _emptyState();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: orders.length,
      itemBuilder: (_, i) => _orderCard(orders[i]),
    );
  }
}

// ================= DIALOG RATING (REDESIGNED) =================
class RatingDialog extends StatefulWidget {
  final String serviceName;
  const RatingDialog({super.key, this.serviceName = "Layanan"});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int rating = 0;
  final _commentController = TextEditingController();

  String _ratingLabel() {
    switch (rating) {
      case 1:
        return "Sangat Buruk 😞";
      case 2:
        return "Kurang Memuaskan 😕";
      case 3:
        return "Cukup 😐";
      case 4:
        return "Bagus 😊";
      case 5:
        return "Luar Biasa! 🤩";
      default:
        return "Pilih bintang di atas";
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded,
                  color: Colors.amber, size: 36),
            ),
            const SizedBox(height: 14),
            const Text("Beri Penilaian",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              widget.serviceName,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => rating = index + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: index < rating
                          ? Colors.amber
                          : Colors.grey.shade300,
                      size: index < rating ? 40 : 36,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _ratingLabel(),
                key: ValueKey(rating),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: rating > 0 ? Colors.amber.shade700 : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Tulis komentar (opsional)...",
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF5F7FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Lewati"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: rating > 0
                        ? () => Navigator.pop(context, rating)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Kirim",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= BANTUAN (REDESIGNED) =================
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Bagaimana cara membuat pesanan?',
        'a':
            'Kamu bisa membuat pesanan melalui menu "Buat Pesanan" di halaman utama. Pilih layanan yang kamu butuhkan, tentukan jadwal, dan konfirmasi pesananmu.',
      },
      {
        'q': 'Berapa lama teknisi datang?',
        'a':
            'Teknisi kami biasanya tiba dalam 30–60 menit setelah pesanan dikonfirmasi, tergantung lokasi dan ketersediaan teknisi di area kamu.',
      },
      {
        'q': 'Apakah ada garansi layanan?',
        'a':
            'Ya! Semua layanan kami dilengkapi garansi 7 hari. Jika ada masalah setelah servis, teknisi kami akan kembali tanpa biaya tambahan.',
      },
      {
        'q': 'Metode pembayaran apa saja yang tersedia?',
        'a':
            'Kami menerima pembayaran tunai, transfer bank, dan berbagai dompet digital seperti GoPay, OVO, dan Dana.',
      },
      {
        'q': 'Bagaimana cara membatalkan pesanan?',
        'a':
            'Pesanan dapat dibatalkan maksimal 1 jam sebelum jadwal servis. Hubungi CS kami untuk proses pembatalan.',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: const Color(0xFF1565C0),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06)),
                    ),
                  ),
                  const Positioned(
                    bottom: 24,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Pusat Bantuan",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Ada yang bisa kami bantu?",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade600,
                          Colors.blue.shade900
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Hubungi Kami",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text("Tim CS kami siap membantu kamu",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _contactChip(
                                Icons.phone_rounded,
                                "0812-3456-7890",
                                Colors.white.withOpacity(0.2)),
                            const SizedBox(width: 10),
                            _contactChip(
                                Icons.chat_rounded,
                                "WhatsApp",
                                Colors.green.withOpacity(0.4)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _contactChip(
                            Icons.email_rounded,
                            "cs@jasaku.id",
                            Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 6),
                            const Text("Senin–Sabtu, 08.00–20.00 WIB",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // FAQ label
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("Pertanyaan Umum",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // FAQ list
                  ...faqs.map((faq) => _faqItem(
                        faq['q'] as String,
                        faq['a'] as String,
                      )),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactChip(IconData icon, String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.help_outline_rounded,
              color: Colors.blue, size: 18),
        ),
        title: Text(
          question,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
        iconColor: Colors.blue,
        collapsedIconColor: Colors.grey,
        children: [
          Text(
            answer,
            style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ================= TENTANG APLIKASI (REDESIGNED) =================
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.ac_unit_rounded,
        'title': 'Servis AC',
        'desc': 'Cuci, isi freon, dan perbaikan AC oleh teknisi berpengalaman',
        'color': 0xFF1565C0,
      },
      {
        'icon': Icons.bolt_rounded,
        'title': 'Cepat & Terpercaya',
        'desc': 'Teknisi tiba dalam 30–60 menit dengan garansi layanan 7 hari',
        'color': 0xFFE65100,
      },
      {
        'icon': Icons.verified_rounded,
        'title': 'Teknisi Bersertifikat',
        'desc': 'Semua teknisi kami telah tersertifikasi dan terlatih profesional',
        'color': 0xFF2E7D32,
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': 'CS 24/7',
        'desc': 'Layanan pelanggan siap membantu kamu kapan saja dibutuhkan',
        'color': 0xFF6A1B9A,
      },
    ];

    final team = [
      {'name': 'Tim Teknisi', 'role': 'Profesional & Berpengalaman', 'icon': Icons.engineering},
      {'name': 'Customer Service', 'role': 'Ramah & Responsif', 'icon': Icons.headset_mic},
      {'name': 'Tim Produk', 'role': 'Inovatif & Kreatif', 'icon': Icons.lightbulb},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1565C0),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05)),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.ac_unit_rounded,
                                color: Color(0xFF1565C0), size: 44),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text("JASAKU",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        const SizedBox(height: 4),
                        const Text("Solusi AC Terpercaya Anda",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Version badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: const Text(
                        "Versi 1.0.0  •  Build 2025",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // About text
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10)
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text("Tentang JASAKU",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          "JASAKU adalah aplikasi layanan servis AC terpercaya yang menghubungkan pelanggan dengan teknisi profesional bersertifikat. Kami hadir untuk memberikan solusi terbaik bagi kebutuhan AC kamu dengan layanan yang cepat, terjangkau, dan berkualitas.",
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.7),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section label
                  _sectionLabel("Fitur Unggulan"),
                  const SizedBox(height: 12),

                  // Features grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: features.map((f) {
                      final color = Color(f['color'] as int);
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(f['icon'] as IconData,
                                  color: color, size: 22),
                            ),
                            const SizedBox(height: 10),
                            Text(f['title'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(f['desc'] as String,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    height: 1.4)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  _sectionLabel("Tim Kami"),
                  const SizedBox(height: 12),

                  // Team
                  ...team.map((t) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8)
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(t['icon'] as IconData,
                                  color: Colors.blue, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t['name'] as String,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(t['role'] as String,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                      )),

                  const SizedBox(height: 20),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade700,
                          Colors.blue.shade900
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.favorite_rounded,
                            color: Colors.white, size: 28),
                        const SizedBox(height: 8),
                        const Text(
                          "Dibuat dengan ❤️ oleh Tim JASAKU",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "© 2025 JASAKU. All rights reserved.",
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          children: [
                            _footerChip("Kebijakan Privasi"),
                            _footerChip("Syarat & Ketentuan"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87)),
      ],
    );
  }

  Widget _footerChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}