import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../models/pegawai.dart';

class AddEditPegawaiScreen extends StatefulWidget {
  final Pegawai? pegawai;
  const AddEditPegawaiScreen({super.key, this.pegawai});

  @override
  State<AddEditPegawaiScreen> createState() => _AddEditPegawaiScreenState();
}

class _AddEditPegawaiScreenState extends State<AddEditPegawaiScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final _namaController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _departemenController = TextEditingController();
  final _hpController = TextEditingController();
  final _alamatController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.pegawai != null) {
      _namaController.text = widget.pegawai!.namaPegawai;
      _jabatanController.text = widget.pegawai!.jabatan;
      _departemenController.text = widget.pegawai!.departemen;
      _hpController.text = widget.pegawai!.noHp;
      _alamatController.text = widget.pegawai!.alamat;
      _isActive = widget.pegawai!.isActive;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'nama_pegawai': _namaController.text,
        'jabatan': _jabatanController.text,
        'departemen': _departemenController.text,
        'no_hp': _hpController.text,
        'alamat': _alamatController.text,
        'is_active': _isActive,
      };

      if (widget.pegawai == null) {
        await _apiService.post('bendahara/pegawai', data: data);
      } else {
        await _apiService.put('bendahara/pegawai/${widget.pegawai!.id}',
            data: data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Pegawai berhasil ${widget.pegawai == null ? "ditambahkan" : "diperbarui"}')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data pegawai')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pegawai == null ? 'Tambah Pegawai' : 'Edit Pegawai',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration('Nama Pegawai'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jabatanController,
                decoration: _inputDecoration('Jabatan'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _departemenController,
                decoration: _inputDecoration('Departemen'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hpController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('No HP'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                maxLines: 3,
                decoration: _inputDecoration('Alamat'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text('Status Aktif', style: GoogleFonts.outfit()),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Simpan',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
