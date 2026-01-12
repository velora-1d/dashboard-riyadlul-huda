import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    setState(() => _isLoading = true);
    try {
      // Endpoint ini mungkin perlu ditambahkan di API
      final response = await _apiService.get('sekretaris/laporan');
      if (response.data['status'] == 'success') {
        setState(() {
          _summary = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching summary: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Summary',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSummary,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildSummaryCard(
                        'Total Santri',
                        _summary?['total_santri']?.toString() ?? '0',
                        Icons.people,
                        Colors.blue),
                    _buildSummaryCard(
                        'Izin Aktif',
                        _summary?['izin_aktif']?.toString() ?? '0',
                        Icons.assignment_ind,
                        Colors.orange),
                    _buildSummaryCard(
                        'Santri Libur',
                        _summary?['santri_libur']?.toString() ?? '0',
                        Icons.home,
                        Colors.green),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            final response = await _apiService.post(
                                'sekretaris/laporan/url',
                                data: {'type': 'semua'});
                            if (response.data['status'] == 'success') {
                              final url =
                                  Uri.parse(response.data['data']['url']);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                try {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  messenger.showSnackBar(const SnackBar(
                                      content: Text(
                                          'Tidak dapat membuka link (Browser tidak ditemukan)')));
                                }
                              }
                            }
                          } catch (e) {
                            messenger.showSnackBar(
                                SnackBar(content: Text('Error: $e')));
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download Laporan PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Laporan akan diunduh dalam format PDF.',
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.grey)),
                Text(value,
                    style: GoogleFonts.outfit(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
