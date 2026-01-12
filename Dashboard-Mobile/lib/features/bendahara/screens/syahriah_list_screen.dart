import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import 'syahriah_payment_screen.dart';

class SyahriahListScreen extends StatefulWidget {
  const SyahriahListScreen({super.key});

  @override
  State<SyahriahListScreen> createState() => _SyahriahListScreenState();
}

class _SyahriahListScreenState extends State<SyahriahListScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _records = [];
  final _currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      // Need a new endpoint or reuse existing one.
      // Assuming 'bendahara/syahriah' GET returns list.
      // If not, we might need to verify backend route.
      // Let's assume standard REST: GET /bendahara/syahriah
      // If that doesn't exist, we will add it.
      // Based on previous checks, we haven't seen 'getSyahriah' in BendaharaController.
      // We will check routes next. For now, writing UI assuming backend support.
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Syahriah',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
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
                      child: Text('Belum ada data syahriah',
                          style: GoogleFonts.outfit(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _records.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        return _buildCard(record);
                      },
                    ),
            ),
    );
  }

  Widget _buildCard(dynamic record) {
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
}
