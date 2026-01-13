import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../models/pendidikan_models.dart';

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

  bool _isParent = false;
  int? _parentSantriId;

  @override
  void initState() {
    super.initState();
    _checkRoleAndInit();
  }

  Future<void> _checkRoleAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    if (role == 'wali_santri') {
      setState(() => _isParent = true);
      // Fetch Santri ID (Assumption: Use 'sekretaris/santri' to get SELF)
      _fetchParentSantriData();
    } else {
      _fetchKelas();
    }
  }

  Future<void> _fetchParentSantriData() async {
    setState(() => _isLoadingSantri = true);
    try {
      // Re-use logic: Backend 'sekretaris/santri' filters by Auth ID for parents
      final response = await _apiService.get('sekretaris/santri');
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        if (data.isNotEmpty) {
          final me = data.first; // Should be only one
          setState(() {
            _parentSantriId = me['id'];
            _isLoadingSantri = false;
          });
          // We don't populate _santriList because we will render a specific Parent UI
        }
      }
    } catch (e) {
      debugPrint('Error fetch parent data: $e');
      setState(() => _isLoadingSantri = false);
    }
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
    if (_isParent) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Data Rapor Anak',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            const Icon(Icons.school, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Rapor Digital',
              style:
                  GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan pilih Semester dan Tahun Ajaran untuk mengunduh Rapor Anak.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
            const SizedBox(height: 32),
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
            if (_isLoadingSantri)
              const CircularProgressIndicator()
            else if (_parentSantriId != null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text('Download Rapor'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () => _downloadRapor(_parentSantriId!),
                ),
              )
            else
              const Text('Data Santri tidak ditemukan (Login Ulang).')
          ]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('E-Rapor Digital',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
