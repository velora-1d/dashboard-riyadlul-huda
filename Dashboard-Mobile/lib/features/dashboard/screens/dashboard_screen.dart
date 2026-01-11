import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/screens/login_screen.dart';
import '../../bendahara/screens/cek_tunggakan_screen.dart';
import '../../bendahara/screens/financial_list_screen.dart';
import '../../bendahara/screens/data_pegawai_screen.dart';
import '../../bendahara/screens/gaji_pegawai_screen.dart';
import '../../sekretaris/screens/data_santri_screen.dart';
import '../../sekretaris/screens/perizinan_screen.dart';
import 'notification_screen.dart';
import '../../sekretaris/screens/kartu_digital_grid_screen.dart';
import '../../sekretaris/screens/report_screen.dart';
import '../../pendidikan/screens/e_rapor_screen.dart';
import '../../pendidikan/screens/ijazah_digital_screen.dart';
import '../../pendidikan/screens/kalender_akademik_screen.dart';
import '../../../core/services/api_service.dart';
import '../../bendahara/screens/syahriah_payment_screen.dart';
import '../../bendahara/screens/savings_screen.dart';
import 'placeholder_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userRole = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role') ?? 'Staff';
      _userName = prefs.getString('user_name') ?? 'User';
    });
  }

  List<Map<String, dynamic>> _getMenuItems() {
    final role = _userRole.toLowerCase();
    debugPrint("Current User Role for Menu: $role");

    final List<Map<String, dynamic>> sekretarisMenus = [
      {
        'icon': Icons.people_outline,
        'label': 'Data Santri',
        'color': Colors.blue
      },
      {
        'icon': Icons.qr_code_2_outlined,
        'label': 'Kartu Digital',
        'color': Colors.purple
      },
      {
        'icon': Icons.assignment_turned_in_outlined,
        'label': 'Perizinan',
        'color': Colors.orange
      },
      {
        'icon': Icons.description_outlined,
        'label': 'Laporan',
        'color': Colors.teal
      },
    ];

    final List<Map<String, dynamic>> bendaharaMenus = [
      {
        'icon': Icons.payments_outlined,
        'label': 'Input Syahriah',
        'color': Colors.green
      },
      {
        'icon': Icons.search_off_outlined,
        'label': 'Cek Tunggakan',
        'color': Colors.red
      },
      {
        'icon': Icons.add_chart_outlined,
        'label': 'Pemasukan',
        'color': Colors.blue
      },
      {
        'icon': Icons.shopping_bag_outlined,
        'label': 'Pengeluaran',
        'color': Colors.orange
      },
      {
        'icon': Icons.bar_chart_outlined,
        'label': 'Lap. Keuangan',
        'color': Colors.indigo
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Tabungan',
        'color': Colors.teal
      },
      {
        'icon': Icons.badge_outlined,
        'label': 'Data Pegawai',
        'color': Colors.brown
      },
      {
        'icon': Icons.money_outlined,
        'label': 'Gaji Pegawai',
        'color': Colors.deepOrange
      },
    ];

    final List<Map<String, dynamic>> pendidikanMenus = [
      {'icon': Icons.school_outlined, 'label': 'E-Rapor', 'color': Colors.blue},
      {
        'icon': Icons.verified_outlined,
        'label': 'Ijazah Digital',
        'color': Colors.amber
      },
      {
        'icon': Icons.calendar_month_outlined,
        'label': 'Kalender Akademik',
        'color': Colors.red
      },
    ];

    if (role == 'admin' || role == 'super_admin') {
      return [...sekretarisMenus, ...bendaharaMenus, ...pendidikanMenus];
    } else if (role == 'bendahara') {
      return bendaharaMenus;
    } else if (role == 'sekretaris') {
      return sekretarisMenus;
    } else if (role == 'pendidikan') {
      return pendidikanMenus;
    }

    return [
      {'icon': Icons.help_outline, 'label': 'Bantuan', 'color': Colors.grey},
    ];
  }

  void _navigateToMenu(String label) {
    if (label == 'Data Santri') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DataSantriScreen()),
      );
    } else if (label == 'Kartu Digital') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KartuDigitalGridScreen()),
      );
    } else if (label == 'Perizinan') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PerizinanScreen()),
      );
    } else if (label == 'Laporan') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportScreen()),
      );
    } else if (label == 'Input Syahriah') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SyahriahPaymentScreen()),
      );
    } else if (label == 'Cek Tunggakan') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CekTunggakanScreen()),
      );
    } else if (label == 'Pemasukan') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FinancialListScreen(type: 'pemasukan'),
        ),
      );
    } else if (label == 'Pengeluaran') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FinancialListScreen(type: 'pengeluaran'),
        ),
      );
    } else if (label == 'Lap. Keuangan') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const PlaceholderScreen(title: 'Laporan Keuangan')),
      );
    } else if (label == 'Tabungan') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SavingsScreen()),
      );
    } else if (label == 'Data Pegawai') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DataPegawaiScreen()),
      );
    } else if (label == 'Gaji Pegawai') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GajiPegawaiScreen()),
      );
    } else if (label == 'E-Rapor') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ERaporScreen()),
      );
    } else if (label == 'Ijazah Digital') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const IjazahDigitalScreen()),
      );
    } else if (label == 'Kalender Akademik') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KalenderAkademikScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationScreen()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang,',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userName.isEmpty ? 'Memuat...' : _userName,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _userRole.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Grid
            Text(
              'Menu Utama',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 110,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuCard(
                  icon: item['icon'] as IconData,
                  label: item['label'] as String,
                  color: item['color'] as Color,
                  onTap: () => _navigateToMenu(item['label'] as String),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final menuItems = _getMenuItems();

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
            ),
            accountName: Text(
              _userName,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              _userRole.toUpperCase(),
              style: GoogleFonts.outfit(fontSize: 12),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard_outlined),
                  title: Text('Dashboard', style: GoogleFonts.outfit()),
                  selected: true,
                  selectedColor: const Color(0xFF1B5E20),
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(),
                ...menuItems.map((item) {
                  return ListTile(
                    leading: Icon(item['icon'] as IconData),
                    title: Text(item['label'] as String,
                        style: GoogleFonts.outfit()),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      _navigateToMenu(item['label'] as String);
                    },
                  );
                }),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('Keluar', style: GoogleFonts.outfit(color: Colors.red)),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              ApiService().clearToken();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
