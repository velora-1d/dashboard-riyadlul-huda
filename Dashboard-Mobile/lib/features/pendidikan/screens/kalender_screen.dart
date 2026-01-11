import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../models/pendidikan_models.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  final ApiService _apiService = ApiService();
  List<KalenderEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await _apiService.get('pendidikan/kalender');
      if (response.data['status'] == 'success') {
        setState(() {
          _events = (response.data['data'] as List)
              .map((e) => KalenderEvent.fromJson(e))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalender Akademik',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchEvents,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Container(
                        width: 12,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getColor(event.warna),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      title: Text(event.judul,
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${DateFormat('dd MMM yyyy', 'id').format(DateTime.parse(event.tanggalMulai))} - ${DateFormat('dd MMM yyyy', 'id').format(DateTime.parse(event.tanggalSelesai))}',
                            style: GoogleFonts.outfit(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (event.deskripsi.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(event.deskripsi,
                                style: GoogleFonts.outfit(fontSize: 13)),
                          ]
                        ],
                      ),
                      trailing: Chip(
                        label: Text(event.kategori,
                            style: GoogleFonts.outfit(
                                fontSize: 10, color: Colors.white)),
                        backgroundColor: _getColor(event.warna),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'merah':
        return Colors.red;
      case 'hijau':
        return Colors.green;
      case 'biru':
        return Colors.blue;
      case 'kuning':
        return Colors.orange;
      case 'ungu':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
