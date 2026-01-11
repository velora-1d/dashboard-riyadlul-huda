import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/api_service.dart';
import '../models/santri_arrears.dart';

class CekTunggakanScreen extends StatefulWidget {
  const CekTunggakanScreen({super.key});

  @override
  State<CekTunggakanScreen> createState() => _CekTunggakanScreenState();
}

class _CekTunggakanScreenState extends State<CekTunggakanScreen> {
  final ApiService _apiService = ApiService();
  List<SantriArrears> _arrearsList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchArrears();
  }

  Future<void> _fetchArrears() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await _apiService.get('bendahara/cek-tunggakan', queryParameters: {
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      });

      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _arrearsList = data.map((e) => SantriArrears.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching arrears: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cek Tunggakan',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama santri...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                _searchQuery = value;
                _fetchArrears();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _arrearsList.isEmpty
                    ? const Center(child: Text('Tidak ada data tunggakan'))
                    : RefreshIndicator(
                        onRefresh: _fetchArrears,
                        child: ListView.builder(
                          itemCount: _arrearsList.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final santri = _arrearsList[index];
                            return _buildArrearsCard(santri);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrearsCard(SantriArrears santri) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    santri.name,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  'Rp ${NumberFormat.compact(locale: 'id').format(santri.totalTunggakan)}',
                  style: GoogleFonts.outfit(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'NIS: ${santri.nis} • Kelas: ${santri.kelas}',
              style:
                  GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 12),
            ),
            const Divider(height: 24),
            Text(
              'Bulan Menunggak:',
              style:
                  GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: santri.bulanMenunggak.map((bulan) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    bulan,
                    style: GoogleFonts.outfit(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
            if (santri.noHpOrtu != null && santri.noHpOrtu!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final phone =
                        santri.noHpOrtu!.replaceAll(RegExp(r'[^0-9]'), '');
                    final formattedPhone = phone.startsWith('0')
                        ? '62${phone.substring(1)}'
                        : (phone.startsWith('62') ? phone : '62$phone');

                    final message =
                        "Assalamu'alaikum Wr. Wb.\n\nYth. Wali dari Ananda *${santri.name}*\nNIS: ${santri.nis}\nKelas: ${santri.kelas}\n\nKami informasikan bahwa terdapat *tunggakan Syahriah* sebanyak ${santri.jumlahBulan} bulan.\n\n💰 *Total Tunggakan:* Rp ${NumberFormat.decimalPattern('id').format(santri.totalTunggakan)}\n\nMohon dapat melunasi melalui Bendahara PP Riyadlul Huda.\n\nJazakumullahu Khairan.\n_Bendahara PP Riyadlul Huda_";

                    final url = Uri.parse(
                        "https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Tidak dapat membuka WhatsApp')));
                      }
                    }
                  },
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Kirim Tagihan WA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
