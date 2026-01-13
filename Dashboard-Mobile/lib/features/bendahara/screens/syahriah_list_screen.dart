import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import 'syahriah_payment_screen.dart';
import 'payment_webview_screen.dart';

class SyahriahListScreen extends StatefulWidget {
  const SyahriahListScreen({super.key});

  @override
  State<SyahriahListScreen> createState() => _SyahriahListScreenState();
}

class _SyahriahListScreenState extends State<SyahriahListScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _userRole = '';
  List<dynamic> _records = [];
  final _currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchRecords();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role') ?? '';
    });
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      // Check if Parent, use specific endpoint if needed, or filter.
      // For now reusing same endpoint, backend should filter by user if Wali.
      // If backend doesn't filter automatically yet, we might see all data (not ideal but fixable in backend).
      final response = await _apiService.get('bendahara/syahriah');
      if (response.data['status'] == 'success') {
        setState(() {
          _records = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching syahriah: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSyahriah(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pembayaran?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _apiService.delete('bendahara/syahriah/$id');
        if (response.data['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data berhasil dihapus')));
            _fetchRecords();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Gagal hapus: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isParent = _userRole == 'wali_santri';

    return Scaffold(
      appBar: AppBar(
        title: Text(isParent ? 'Riwayat Pembayaran' : 'Data Syahriah',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: isParent
          ? FloatingActionButton.extended(
              onPressed: () => _initiatePayment(),
              label: const Text('Bayar Sekarang'),
              icon: const Icon(Icons.payment),
              backgroundColor: const Color(0xFF1B5E20),
            )
          : FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SyahriahPaymentScreen()),
                );
                if (result == true) _fetchRecords();
              },
              backgroundColor: const Color(0xFF1B5E20),
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchRecords,
              child: _records.isEmpty
                  ? Center(
                      child: Text('Belum ada data pembayaran',
                          style: GoogleFonts.outfit(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _records.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return _buildCard(record, isParent);
                      },
                    ),
            ),
    );
  }

  Widget _buildCard(dynamic record, bool isParent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
          child: const Icon(Icons.verified, color: Color(0xFF1B5E20)),
        ),
        title: Text(
          record['santri']['nama_santri'] ?? 'Unknown',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${record['bulan']} ${record['tahun']} • ${record['keterangan'] ?? '-'}',
          style: GoogleFonts.outfit(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currencyFormat
                  .format(double.tryParse(record['nominal'].toString()) ?? 0),
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)),
            ),
            if (!isParent)
              PopupMenuButton(
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SyahriahPaymentScreen(syahriah: record)),
                    );
                    if (result == true) _fetchRecords();
                  } else if (value == 'delete') {
                    _deleteSyahriah(record['id']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _initiatePayment() async {
    final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) {
          final amountController = TextEditingController(text: '150000');
          final monthController = TextEditingController(
              text: DateFormat('MMMM', 'id').format(DateTime.now()));
          final yearController =
              TextEditingController(text: DateTime.now().year.toString());

          return AlertDialog(
            title: const Text('Bayar Syahriah'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
                ),
                TextField(
                  controller: monthController,
                  decoration: const InputDecoration(
                      labelText: 'Bulan (Contoh: Januari)'),
                ),
                TextField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tahun'),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx, {
                      'amount': amountController.text,
                      'month': monthController.text,
                      'year': yearController.text
                    });
                  },
                  child: const Text('Bayar')),
            ],
          );
        });

    if (result != null) {
      if (mounted) setState(() => _isLoading = true);
      try {
        final response = await _apiService.post('payment/snap-token', data: {
          'amount': result['amount'],
          'item_name': 'Syahriah ${result['month']} ${result['year']}',
          'month': result['month'],
          'year': result['year']
        });

        if (response.data['status'] == 'success') {
          final redirectUrl = response.data['redirect_url'];
          if (mounted) {
            setState(() => _isLoading = false);
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PaymentWebviewScreen(url: redirectUrl)));
            _fetchRecords();
          }
        }
      } catch (e) {
        debugPrint('Payment Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Gagal: $e')));
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
