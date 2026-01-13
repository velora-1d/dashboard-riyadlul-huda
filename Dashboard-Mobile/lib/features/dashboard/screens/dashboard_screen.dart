import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/screens/login_screen.dart';
import '../../bendahara/screens/cek_tunggakan_screen.dart';
import '../../bendahara/screens/financial_list_screen.dart';
import '../../bendahara/screens/gaji_history_screen.dart';
import '../../bendahara/screens/pegawai_list_screen.dart';

import '../../sekretaris/screens/data_santri_screen.dart';
import '../../sekretaris/screens/perizinan_screen.dart';
import '../../sekretaris/screens/kartu_digital_grid_screen.dart';
import '../../sekretaris/screens/report_screen.dart';
import '../../pendidikan/screens/erapor_screen.dart';
import '../../pendidikan/screens/ijazah_screen.dart';
import '../../pendidikan/screens/hafalan_list_screen.dart';
import '../../pendidikan/screens/kalender_screen.dart';
import '../../bendahara/screens/laporan_keuangan_screen.dart';
import '../../../core/services/api_service.dart';
import '../../bendahara/screens/syahriah_list_screen.dart';
import '../../bendahara/screens/withdrawal_screen.dart';
import '../../admin/screens/withdrawal_tracking_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  final String? role;
  const DashboardScreen({super.key, this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  String _userRole = '';
  String _userName = '';
  Map<String, dynamic> _kpiData = {};
  bool _isLoadingKpi = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userRole = widget.role ?? prefs.getString('user_role') ?? '';
        _userName = prefs.getString('user_name') ?? '';
      });
      _fetchKpi();
    }
  }

  Future<void> _fetchKpi() async {
    if (_userRole.isEmpty) return;

    setState(() => _isLoadingKpi = true);

    try {
      String endpoint = 'sekretaris/dashboard';
      if (_userRole.toLowerCase() == 'bendahara') {
        endpoint = 'bendahara/dashboard';
      }

      final response = await _apiService.get(endpoint);
      if (mounted && response.data['status'] == 'success') {
        setState(() {
          _kpiData = response.data['data'] ?? {};
        });
      }
    } catch (e) {
      debugPrint('Error fetching KPI: $e');
    } finally {
      if (mounted) setState(() => _isLoadingKpi = false);
    }
  }

  List<Map<String, dynamic>> _getMenuItems() {
    final role = _userRole.toLowerCase();
    if (role == 'sekretaris') {
      return [
        {
          'icon': Icons.people_outline,
          'label': 'Data Santri',
          'color': Colors.blue
        },
        {
          'icon': Icons.assignment_outlined,
          'label': 'Perizinan',
          'color': Colors.orange
        },
        {
          'icon': Icons.card_membership_outlined,
          'label': 'Kartu Digital',
          'color': Colors.purple
        },
        {
          'icon': Icons.description_outlined,
          'label': 'Laporan',
          'color': Colors.red
        },
      ];
    } else if (role == 'bendahara') {
      return [
        {
          'icon': Icons.payments_outlined,
          'label': 'Data Syahriah',
          'color': Colors.green
        },
        {
          'icon': Icons.warning_amber_rounded,
          'label': 'Cek Tunggakan',
          'color': Colors.red
        },
        {
          'icon': Icons.arrow_downward_rounded,
          'label': 'Pemasukan',
          'color': Colors.blue
        },
        {
          'icon': Icons.arrow_upward_rounded,
          'label': 'Pengeluaran',
          'color': Colors.orange
        },
        {
          'icon': Icons.pie_chart_outline,
          'label': 'Lap. Keuangan',
          'color': Colors.purple
        },
        {
          'icon': Icons.people_alt_outlined,
          'label': 'Data Pegawai',
          'color': Colors.cyan
        },
        {
          'icon': Icons.attach_money_outlined,
          'label': 'Gaji Pegawai',
          'color': Colors.teal
        },
        {
          'icon': Icons.account_balance_outlined,
          'label': 'Penarikan Dana',
          'color': Colors.indigo
        },
      ];
    } else if (role == 'pendidikan') {
      return [
        {
          'icon': Icons.assessment_outlined,
          'label': 'E-Rapor',
          'color': Colors.blue
        },
        {
          'icon': Icons.school_outlined,
          'label': 'Ijazah Digital',
          'color': Colors.orange
        },
        {
          'icon': Icons.calendar_today_outlined,
          'label': 'Kalender Akademik',
          'color': Colors.red
        },
        {
          'icon': Icons.menu_book_rounded,
          'label': 'Data Hafalan',
          'color': Colors.teal
        },
      ];
    } else if (role == 'admin' || role == 'super_admin') {
      return [
        {
          'icon': Icons.admin_panel_settings_outlined,
          'label': 'Tracking Pencairan',
          'color': Colors.redAccent
        },
        // Sekretaris Menus
        {
          'icon': Icons.people_outline,
          'label': 'Data Santri',
          'color': Colors.blue
        },
        {
          'icon': Icons.assignment_outlined,
          'label': 'Perizinan',
          'color': Colors.orange
        },
        // Bendahara Menus
        {
          'icon': Icons.payments_outlined,
          'label': 'Data Syahriah',
          'color': Colors.green
        },
        {
          'icon': Icons.warning_amber_rounded,
          'label': 'Cek Tunggakan',
          'color': Colors.red
        },
        {
          'icon': Icons.arrow_downward_rounded,
          'label': 'Pemasukan',
          'color': Colors.blue
        },
        {
          'icon': Icons.arrow_upward_rounded,
          'label': 'Pengeluaran',
          'color': Colors.orange
        },
        {
          'icon': Icons.pie_chart_outline,
          'label': 'Lap. Keuangan',
          'color': Colors.purple
        },
        // Pendidikan Menus
        {
          'icon': Icons.assessment_outlined,
          'label': 'E-Rapor',
          'color': Colors.blue
        },
        {
          'icon': Icons.calendar_today_outlined,
          'label': 'Kalender Akademik',
          'color': Colors.red
        },
        {
          'icon': Icons.menu_book_rounded,
          'label': 'Data Hafalan',
          'color': Colors.teal
        },
      ];
    }
    return [];
  }

  Future<void> _navigateToMenu(String label) async {
    Widget? screen;

    if (label == 'Data Santri') {
      screen = const DataSantriScreen();
    } else if (label == 'Perizinan') {
      screen = const PerizinanScreen();
    } else if (label == 'Kartu Digital') {
      screen = const KartuDigitalGridScreen();
    } else if (label == 'Laporan') {
      screen = const ReportScreen();
    } else if (label == 'Data Syahriah') {
      screen = const SyahriahListScreen();
    } else if (label == 'Cek Tunggakan') {
      screen = const CekTunggakanScreen();
    } else if (label == 'Pemasukan') {
      screen = const FinancialListScreen(type: 'pemasukan');
    } else if (label == 'Pengeluaran') {
      screen = const FinancialListScreen(type: 'pengeluaran');
    } else if (label == 'Lap. Keuangan') {
      screen = const LaporanKeuanganScreen();
    } else if (label == 'Data Pegawai') {
      screen = const PegawaiListScreen();
    } else if (label == 'Gaji Pegawai') {
      screen = const GajiHistoryScreen();
    } else if (label == 'Data Hafalan') {
      screen = const HafalanListScreen();
    } else if (label == 'E-Rapor') {
      screen = const EraporScreen();
    } else if (label == 'Ijazah Digital') {
      screen = const IjazahScreen();
    } else if (label == 'Kalender Akademik') {
      screen = const KalenderScreen();
    } else if (label == 'Penarikan Dana') {
      screen = const WithdrawalScreen();
    } else if (label == 'Tracking Pencairan') {
      screen = const WithdrawalTrackingScreen();
    }

    // Parent Navigation Handlers
    else if (label == 'Tagihanku') {
      // Reuse Syahriah Screen but maybe read-only or specific view
      // For now point to SyahriahListScreen, assuming it handles role check internally or we pass a flag
      screen = const SyahriahListScreen();
    } else if (label == 'Hafalan Anak') {
      screen = const HafalanListScreen();
    } else if (label == 'Rapor Anak') {
      screen = const EraporScreen();
    }

    if (screen != null) {
      // WAIT for the screen to pop (user comes back), then REFRESH DATA
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen!),
        );
        _fetchKpi(); // Auto-refresh logic
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _fetchKpi,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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

              if (_userRole.toLowerCase() == 'sekretaris' ||
                  _userRole.toLowerCase() == 'admin' ||
                  _userRole.toLowerCase() == 'super_admin' ||
                  _userRole.toLowerCase() == 'bendahara') ...[
                _buildKpiHeader(),
                const SizedBox(height: 16),
                _buildKpiGrid(),
                const SizedBox(height: 24),
              ],

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
      ),
    );
  }

  Widget _buildKpiHeader() {
    String title = 'Statistik Santri';
    if (_userRole.toLowerCase() == 'bendahara') {
      title = 'Ikhtisar Keuangan';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        if (_isLoadingKpi)
          const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
      ],
    );
  }

  Widget _buildKpiGrid() {
    final role = _userRole.toLowerCase();

    if (role == 'bendahara') {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _buildKpiCard(
              'Saldo Total',
              'Rp ${_formatNumber(_kpiData['saldo_total'])}',
              Colors.green,
              Icons.account_balance_wallet_outlined),
          _buildKpiCard(
              'Syahriah Manual',
              'Rp ${_formatNumber(_kpiData['syahriah_summary']?['manual'])}',
              Colors.orange,
              Icons.payments_outlined),
          _buildKpiCard(
              'Syahriah Gateway',
              'Rp ${_formatNumber(_kpiData['syahriah_summary']?['gateway'])}',
              Colors.blue,
              Icons.account_balance_outlined),
          _buildKpiCard(
              'Masuk Hari Ini',
              'Rp ${_formatNumber(_kpiData['arus_kas_hari_ini']?['masuk'])}',
              Colors.teal,
              Icons.arrow_downward),
        ],
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _buildKpiCard('Total', _kpiData['total_santri']?.toString() ?? '0',
            Colors.blue, Icons.people),
        _buildKpiCard('Putra', _kpiData['putra']?.toString() ?? '0',
            Colors.indigo, Icons.male),
        _buildKpiCard('Putri', _kpiData['putri']?.toString() ?? '0',
            Colors.pink, Icons.female),
        _buildKpiCard('Kelas', _kpiData['total_kelas']?.toString() ?? '0',
            Colors.orange, Icons.school),
        _buildKpiCard('Asrama', _kpiData['total_asrama']?.toString() ?? '0',
            Colors.teal, Icons.apartment),
        _buildKpiCard('Kamar', _kpiData['total_kamar']?.toString() ?? '0',
            Colors.brown, Icons.meeting_room_outlined),
      ],
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    if (number is String) number = double.tryParse(number) ?? 0;

    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}rb';
    }
    return number.toString();
  }

  Widget _buildKpiCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
          // Hubungi Admin Button
          ListTile(
            leading:
                const Icon(Icons.support_agent_rounded, color: Colors.blue),
            title: Text('Hubungi Admin',
                style: GoogleFonts.outfit(color: Colors.blue)),
            onTap: _launchWhatsApp,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('Keluar', style: GoogleFonts.outfit(color: Colors.red)),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              await ApiService().clearToken();

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

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse(
        'https://wa.me/6281320442174?text=Halo%20Admin,%20saya%20butuh%20bantuan%20terkait%20Aplikasi%20Dashboard.');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
        );
      }
    }
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
