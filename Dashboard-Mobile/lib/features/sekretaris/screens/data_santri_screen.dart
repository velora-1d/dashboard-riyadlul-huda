import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../models/santri.dart';
import 'digital_id_card_screen.dart';

class DataSantriScreen extends StatefulWidget {
  const DataSantriScreen({super.key});

  @override
  State<DataSantriScreen> createState() => _DataSantriScreenState();
}

class _DataSantriScreenState extends State<DataSantriScreen> {
  final ApiService _apiService = ApiService();
  List<Santri> _santriList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchSantri();
  }

  Future<void> _fetchSantri() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await _apiService.get('sekretaris/santri', queryParameters: {
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      });

      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _santriList = data.map((e) => Santri.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching santri: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Santri',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIS...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                _searchQuery = value;
                _fetchSantri();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _santriList.isEmpty
                    ? const Center(child: Text('Data santri tidak ditemukan'))
                    : RefreshIndicator(
                        onRefresh: _fetchSantri,
                        child: ListView.builder(
                          itemCount: _santriList.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final santri = _santriList[index];
                            return _buildSantriCard(santri);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSantriCard(Santri santri) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
          child: Text(
            santri.nama[0].toUpperCase(),
            style: GoogleFonts.outfit(
                color: const Color(0xFF1B5E20), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          santri.nama,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('NIS: ${santri.nis}', style: GoogleFonts.outfit(fontSize: 12)),
            Text('Kelas: ${santri.kelas} • Kamar: ${santri.kamar}',
                style: GoogleFonts.outfit(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.qr_code_scanner, color: Color(0xFF1B5E20)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DigitalIdCardScreen(santri: santri),
            ),
          );
        },
      ),
    );
  }
}
