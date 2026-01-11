import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/api_service.dart';
import '../models/pendidikan_models.dart';
import 'input_nilai_screen.dart';

class EraporScreen extends StatefulWidget {
  const EraporScreen({super.key});

  @override
  State<EraporScreen> createState() => _EraporScreenState();
}

class _EraporScreenState extends State<EraporScreen> {
  final ApiService _apiService = ApiService();
  List<Kelas> _kelasList = [];
  List<SantriSimple> _santriList = [];
  Kelas? _selectedKelas;
  bool _isLoadingSantri = false;

  final _tahunController = TextEditingController(
      text: '${DateTime.now().year}/${DateTime.now().year + 1}');
  int _semester = 1;

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
      debugPrint('Error: $e');
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
      debugPrint('Error: $e');
      if (mounted) {
        setState(() => _isLoadingSantri = false);
      }
    }
  }

  Future<void> _downloadRapor(int santriId) async {
    try {
      final response = await _apiService.post('pendidikan/rapor/url', data: {
        'santri_id': santriId,
        'tahun_ajaran': _tahunController.text,
        'semester': _semester,
      });

      if (response.data['status'] == 'success') {
        final url = Uri.parse(response.data['url']);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
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
        title: Text('E-Rapor Digital',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          if (_selectedKelas != null)
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InputNilaiScreen(
                      kelas: _selectedKelas!,
                      tahunAjaran: _tahunController.text,
                      semester: _semester,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_note, color: Colors.blue),
              label: Text('Input Nilai',
                  style: GoogleFonts.outfit(color: Colors.blue)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tahunController,
                    decoration: InputDecoration(
                      labelText: 'Tahun Ajaran',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _semester,
                    decoration: InputDecoration(
                      labelText: 'Semester',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Ganjil')),
                      DropdownMenuItem(value: 2, child: Text('Genap')),
                    ],
                    onChanged: (v) => setState(() => _semester = v!),
                  ),
                ),
              ],
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
                              leading:
                                  const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(santri.namaSantri,
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(santri.nis),
                              trailing: IconButton(
                                icon: const Icon(Icons.download,
                                    color: Colors.blue),
                                onPressed: () => _downloadRapor(santri.id),
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
