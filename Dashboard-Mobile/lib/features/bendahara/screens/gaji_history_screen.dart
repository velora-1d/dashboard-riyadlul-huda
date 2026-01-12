import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../models/gaji.dart';
import 'input_gaji_screen.dart';

class GajiHistoryScreen extends StatefulWidget {
  const GajiHistoryScreen({super.key});

  @override
  State<GajiHistoryScreen> createState() => _GajiHistoryScreenState();
}

class _GajiHistoryScreenState extends State<GajiHistoryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Gaji> _gajiList = [];
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _fetchGaji();
  }

  Future<void> _fetchGaji() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await _apiService.get('bendahara/gaji', queryParameters: {
        'tahun': _selectedYear,
      });
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _gajiList = data.map((e) => Gaji.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching gaji: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteGaji(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Gaji'),
        content: const Text('Yakin ingin menghapus data gaji ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.delete('bendahara/gaji/$id');
        _fetchGaji();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data gaji berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus data gaji')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Gaji',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedYear,
                dropdownColor: Colors.white,
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - 2 + index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString(), style: GoogleFonts.outfit()),
                  );
                }),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _selectedYear = v);
                    _fetchGaji();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const InputGajiScreen()),
          );
          if (result == true) _fetchGaji();
        },
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchGaji,
              child: _gajiList.isEmpty
                  ? Center(
                      child: Text('Belum ada data gaji tahun $_selectedYear',
                          style: GoogleFonts.outfit(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _gajiList.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final gaji = _gajiList[index];
                        final bulanNama = DateFormat('MMMM', 'id')
                            .format(DateTime(gaji.tahun, gaji.bulan));

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: gaji.isDibayar
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                gaji.isDibayar
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: gaji.isDibayar
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            title: Text(
                              gaji.pegawai?.namaPegawai ?? 'Pegawai',
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '$bulanNama ${gaji.tahun} • ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(double.parse(gaji.nominal))}',
                              style: GoogleFonts.outfit(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  gaji.isDibayar ? 'Lunas' : 'Belum',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: gaji.isDibayar
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                PopupMenuButton(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              InputGajiScreen(gaji: gaji),
                                        ),
                                      );
                                      if (result == true) _fetchGaji();
                                    } else if (value == 'delete') {
                                      _deleteGaji(gaji.id);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Hapus',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
