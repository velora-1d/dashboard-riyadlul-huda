import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../models/hafalan.dart';
import '../models/pendidikan_models.dart'; // For Kelas & SantriSimple

class InputHafalanScreen extends StatefulWidget {
  final Hafalan? hafalan;

  const InputHafalanScreen({super.key, this.hafalan});

  @override
  State<InputHafalanScreen> createState() => _InputHafalanScreenState();
}

class _InputHafalanScreenState extends State<InputHafalanScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late String _jenis;
  late TextEditingController _namaHafalanCtrl;
  late TextEditingController _progressCtrl;
  late TextEditingController _nilaiCtrl;
  late TextEditingController _catatanCtrl;
  DateTime _tanggal = DateTime.now();

  List<Kelas> _kelasList = [];
  List<SantriSimple> _santriList = [];
  Kelas? _selectedKelas;
  SantriSimple? _selectedSantri;
  bool _isLoadingInit = false;
  bool _isLoadingSantri = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _jenis = widget.hafalan?.jenis ?? 'Quran';
    _namaHafalanCtrl =
        TextEditingController(text: widget.hafalan?.namaHafalan ?? '');
    _progressCtrl = TextEditingController(text: widget.hafalan?.progress ?? '');
    _nilaiCtrl =
        TextEditingController(text: widget.hafalan?.nilai?.toString() ?? '');
    _catatanCtrl = TextEditingController(text: widget.hafalan?.catatan ?? '');
    if (widget.hafalan != null) {
      _tanggal = DateTime.parse(widget.hafalan!.tanggal);
      // Logic to pre-fill santri/kelas is tricky if API doesn't return full Relations
      // But typically we edit from list where we have context.
      // For now, edit might be limited or we fetch Santri detail if needed.
    }

    _fetchKelas();
  }

  Future<void> _fetchKelas() async {
    setState(() => _isLoadingInit = true);
    try {
      final response = await _apiService.get('pendidikan/kelas');
      if (response.data['status'] == 'success') {
        setState(() {
          _kelasList = (response.data['data'] as List)
              .map((e) => Kelas.fromJson(e))
              .toList();
          _isLoadingInit = false;
        });

        // If editing, try to find santri's class?
        // Skipped for MVP unless requested.
      }
    } catch (e) {
      setState(() => _isLoadingInit = false);
    }
  }

  Future<void> _fetchSantri(int kelasId) async {
    setState(() => _isLoadingSantri = true);
    try {
      final response =
          await _apiService.get('pendidikan/kelas/$kelasId/santri');
      if (response.data['status'] == 'success') {
        setState(() {
          _santriList = (response.data['data'] as List)
              .map((e) => SantriSimple.fromJson(e))
              .toList();
          _isLoadingSantri = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingSantri = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.hafalan == null && _selectedSantri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih Santri terlebih dahulu')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'santri_id': widget.hafalan?.santriId ?? _selectedSantri!.id,
        'jenis': _jenis,
        'nama_hafalan': _namaHafalanCtrl.text,
        'progress': _progressCtrl.text,
        'tanggal': DateFormat('yyyy-MM-dd').format(_tanggal),
        'nilai': _nilaiCtrl.text.isNotEmpty ? int.parse(_nilaiCtrl.text) : null,
        'catatan': _catatanCtrl.text,
      };

      if (widget.hafalan == null) {
        await _apiService.post('pendidikan/hafalan', data: data);
      } else {
        await _apiService.put('pendidikan/hafalan/${widget.hafalan!.id}',
            data: data);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data hafalan berhasil disimpan')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hafalan == null ? 'Tambah Hafalan' : 'Edit Hafalan',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.hafalan == null) ...[
                if (_isLoadingInit)
                  const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<Kelas>(
                    value: _selectedKelas,
                    decoration: const InputDecoration(
                        labelText: 'Kelas', border: OutlineInputBorder()),
                    items: _kelasList
                        .map((k) => DropdownMenuItem(
                            value: k, child: Text(k.namaKelas)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedKelas = val;
                          _selectedSantri = null; // Reset santri
                        });
                        _fetchSantri(val.id);
                      }
                    },
                  ),
                const SizedBox(height: 16),
                if (_isLoadingSantri)
                  const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<SantriSimple>(
                    value: _selectedSantri,
                    decoration: const InputDecoration(
                        labelText: 'Santri', border: OutlineInputBorder()),
                    items: _santriList
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(s.namaSantri)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedSantri = val),
                  ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                value: _jenis,
                decoration: const InputDecoration(
                    labelText: 'Jenis Hafalan', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Quran', child: Text('Al-Quran')),
                  DropdownMenuItem(value: 'Kitab', child: Text('Kitab')),
                ],
                onChanged: (val) => setState(() => _jenis = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaHafalanCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Hafalan (Misal: Juz 30 / Jurumiyah)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _progressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Progress (Misal: An-Naba 1-10)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _tanggal,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _tanggal = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Penilaian',
                    border: OutlineInputBorder(),
                  ),
                  child:
                      Text(DateFormat('dd MMMM yyyy', 'id').format(_tanggal)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nilaiCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nilai (0-100)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _catatanCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Simpan Data',
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
