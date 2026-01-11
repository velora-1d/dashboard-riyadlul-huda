import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../models/pendidikan_models.dart';

class InputNilaiScreen extends StatefulWidget {
  final Kelas kelas;
  final String tahunAjaran;
  final int semester;

  const InputNilaiScreen({
    super.key,
    required this.kelas,
    required this.tahunAjaran,
    required this.semester,
  });

  @override
  State<InputNilaiScreen> createState() => _InputNilaiScreenState();
}

class _InputNilaiScreenState extends State<InputNilaiScreen> {
  final ApiService _apiService = ApiService();
  List<MataPelajaran> _mapelList = [];
  List<SantriSimple> _santriList = [];
  MataPelajaran? _selectedMapel;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchMapel(),
      _fetchSantri(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchMapel() async {
    try {
      final response = await _apiService.get(
        'pendidikan/mapel',
        queryParameters: {'kelas_id': widget.kelas.id},
      );
      if (response.data['status'] == 'success') {
        _mapelList = (response.data['data'] as List)
            .map((e) => MataPelajaran.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetch mapel: $e');
    }
  }

  Future<void> _fetchSantri() async {
    try {
      final response = await _apiService.get(
        'pendidikan/kelas/${widget.kelas.id}/santri',
      );
      if (response.data['status'] == 'success') {
        _santriList = (response.data['data'] as List)
            .map((e) => SantriSimple.fromJson(e))
            .toList();
        for (var s in _santriList) {
          _controllers[s.id] = TextEditingController();
        }
      }
    } catch (e) {
      debugPrint('Error fetch santri: $e');
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedMapel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih mata pelajaran terlebih dahulu')),
      );
      return;
    }

    bool allFilled = true;
    for (var s in _santriList) {
      if (_controllers[s.id]!.text.isEmpty) {
        allFilled = false;
        break;
      }
    }

    if (!allFilled) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Beberapa nilai masih kosong. Lanjutkan?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ya, Lanjut')),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isSubmitting = true);

    try {
      final List<Map<String, dynamic>> santriDataList = [];
      for (var s in _santriList) {
        final val = _controllers[s.id]!.text;
        if (val.isNotEmpty) {
          santriDataList.add({
            'id': s.id,
            'mapel': {
              _selectedMapel!.id.toString(): double.tryParse(val) ?? 0,
            }
          });
        }
      }

      final response = await _apiService.post('pendidikan/nilai/bulk', data: {
        'kelas_id': widget.kelas.id,
        'tahun_ajaran': widget.tahunAjaran,
        'semester': widget.semester,
        'santri': santriDataList,
      });

      if (response.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nilai berhasil disimpan')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Input Nilai',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            Text('${widget.kelas.namaKelas} - ${widget.tahunAjaran}',
                style: GoogleFonts.outfit(fontSize: 12)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<MataPelajaran>(
                    value: _selectedMapel,
                    decoration: InputDecoration(
                      labelText: 'Pilih Mata Pelajaran',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _mapelList
                        .map((m) => DropdownMenuItem(
                            value: m, child: Text(m.namaMapel)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedMapel = val),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _santriList.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final santri = _santriList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(santri.namaSantri,
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(santri.nis),
                          trailing: SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _controllers[santri.id],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '0-100',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Simpan Nilai',
                    style: GoogleFonts.outfit(
                        color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
