import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/api_service.dart';
import '../models/pendidikan_models.dart';

class IjazahScreen extends StatefulWidget {
  const IjazahScreen({super.key});

  @override
  State<IjazahScreen> createState() => _IjazahScreenState();
}

class _IjazahScreenState extends State<IjazahScreen> {
  final ApiService _apiService = ApiService();
  String _uType = 'ibtida'; // ibtida or tsanawi

  // Re-using the Class/Santri logic within this file.
  List<Kelas> _kelasList = [];
  List<SantriSimple> _santriList = [];
  Kelas? _selectedKelas;
  bool _isLoadingSantri = false;

  @override
  void initState() {
    super.initState();
    _fetchKelas();
  }

  Future<void> _fetchKelas() async {
    try {
      final response = await _apiService.get('pendidikan/kelas');
      if (response.data['status'] == 'success') {
        if (mounted) {
          setState(() {
            _kelasList = (response.data['data'] as List)
                .map((e) => Kelas.fromJson(e))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
    }
  }

  Future<void> _fetchSantri(int kelasId) async {
    if (mounted) {
      setState(() => _isLoadingSantri = true);
    }
    try {
      final response =
          await _apiService.get('pendidikan/kelas/$kelasId/santri');
      if (response.data['status'] == 'success') {
        if (mounted) {
          setState(() {
            _santriList = (response.data['data'] as List)
                .map((e) => SantriSimple.fromJson(e))
                .toList();
            _isLoadingSantri = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching santri: $e');
      if (mounted) {
        setState(() => _isLoadingSantri = false);
      }
    }
  }

  Future<void> _downloadIjazah(int santriId) async {
    try {
      final response = await _apiService.post('pendidikan/ijazah/url', data: {
        'santri_id': santriId,
        'type': _uType,
      });

      if (response.data['status'] == 'success') {
        final url = Uri.parse(response.data['url']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          try {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Tidak dapat membuka link (Browser tidak ditemukan)')));
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Ijazah Digital',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _uType,
              decoration: InputDecoration(
                labelText: 'Tingkat Ijazah',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'ibtida', child: Text('Ibtidaiyah')),
                DropdownMenuItem(value: 'tsanawi', child: Text('Tsanawiyah')),
              ],
              onChanged: (v) => setState(() => _uType = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Kelas>(
              value: _selectedKelas,
              decoration: InputDecoration(
                labelText: 'Pilih Kelas',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _kelasList
                  .map((k) =>
                      DropdownMenuItem(value: k, child: Text(k.namaKelas)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedKelas = val);
                  _fetchSantri(val.id);
                }
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoadingSantri
                  ? const Center(child: CircularProgressIndicator())
                  : _santriList.isEmpty
                      ? const Center(
                          child: Text('Pilih kelas untuk melihat santri'))
                      : ListView.builder(
                          itemCount: _santriList.length,
                          itemBuilder: (context, index) {
                            final santri = _santriList[index];
                            return ListTile(
                              leading: const Icon(Icons.school,
                                  color: Colors.indigo),
                              title: Text(santri.namaSantri,
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(santri.nis),
                              trailing: IconButton(
                                icon: const Icon(Icons.print,
                                    color: Colors.indigo),
                                onPressed: () => _downloadIjazah(santri.id),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
