import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../models/santri.dart';
import 'digital_id_card_screen.dart';

class KartuDigitalGridScreen extends StatefulWidget {
  const KartuDigitalGridScreen({super.key});

  @override
  State<KartuDigitalGridScreen> createState() => _KartuDigitalGridScreenState();
}

class _KartuDigitalGridScreenState extends State<KartuDigitalGridScreen> {
  final ApiService _apiService = ApiService();
  List<Santri> _santriList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSantri();
  }

  Future<void> _fetchSantri() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('sekretaris/santri');
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _santriList = data.map((e) => Santri.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching santri for cards: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kartu Digital Santri',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 200,
              ),
              itemCount: _santriList.length,
              itemBuilder: (context, index) {
                final santri = _santriList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DigitalIdCardScreen(santri: santri)),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              const Color(0xFF1B5E20).withOpacity(0.1),
                          child: Text(santri.nama[0].toUpperCase(),
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1B5E20))),
                        ),
                        const SizedBox(height: 12),
                        Text(santri.nama,
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold, fontSize: 13),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(santri.nis,
                            style: GoogleFonts.outfit(
                                fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFF1B5E20).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text('Lihat Kartu',
                              style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: const Color(0xFF1B5E20),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
