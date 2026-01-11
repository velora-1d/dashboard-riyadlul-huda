import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _savings = [];
  final _currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchSavings();
  }

  Future<void> _fetchSavings() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('bendahara/tabungan');
      if (response.data['status'] == 'success') {
        setState(() {
          _savings = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching savings: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tabungan Santri',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSavings,
              child: _savings.isEmpty
                  ? const Center(child: Text('Belum ada data tabungan'))
                  : ListView.builder(
                      itemCount: _savings.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final item = _savings[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(item['nama_santri'] ?? 'Santri',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text('Saldo Terakhir',
                                style: GoogleFonts.outfit(fontSize: 12)),
                            trailing: Text(
                              _currencyFormat.format(item['saldo'] ?? 0),
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
