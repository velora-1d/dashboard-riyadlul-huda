import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../models/santri.dart';

class AddEditSantriScreen extends StatefulWidget {
  final Santri? santri;
  const AddEditSantriScreen({super.key, this.santri});

  @override
  State<AddEditSantriScreen> createState() => _AddEditSantriScreenState();
}

class _AddEditSantriScreenState extends State<AddEditSantriScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isInitLoading = true;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _nisController;
  late TextEditingController _negaraController;
  late TextEditingController _provinsiController;
  late TextEditingController _kotaController;
  late TextEditingController _kecamatanController;
  late TextEditingController _desaController;
  late TextEditingController _rtRwController;
  late TextEditingController _ortuController;
  late TextEditingController _hpOrtuController;
  late TextEditingController _tanggalMasukController;
  late TextEditingController _tanggalLahirController; // Added

  // Dropdown values
  String? _selectedGender;
  String? _selectedKelasId;
  String? _selectedAsramaId;
  String? _selectedKobongId;

  // Filter data
  List<dynamic> _kelasOptions = [];
  List<dynamic> _asramaOptions = [];
  List<dynamic> _kobongOptions = [];
  List<dynamic> _filteredKobong = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.santri?.nama);
    _nisController = TextEditingController(text: widget.santri?.nis);
    _negaraController =
        TextEditingController(text: widget.santri?.negara ?? 'Indonesia');
    _provinsiController = TextEditingController(text: widget.santri?.provinsi);
    _kotaController = TextEditingController(text: widget.santri?.kotaKabupaten);
    _kecamatanController =
        TextEditingController(text: widget.santri?.kecamatan);
    _desaController = TextEditingController(text: widget.santri?.desaKampung);
    _rtRwController = TextEditingController(text: widget.santri?.rtRw);
    _ortuController = TextEditingController(text: widget.santri?.namaOrtuWali);
    _hpOrtuController =
        TextEditingController(text: widget.santri?.noHpOrtuWali);
    _tanggalMasukController = TextEditingController(
        text: widget.santri?.tanggalMasuk ??
            DateTime.now().toString().split(' ')[0]);

    // Format Tanggal Lahir for Display (YYYY-MM-DD -> DD-MM-YYYY)
    String initialTanggalLahir = '';
    if (widget.santri?.tanggalLahir != null) {
      try {
        final parts = widget.santri!.tanggalLahir!.split('-');
        if (parts.length == 3) {
          initialTanggalLahir = '${parts[2]}-${parts[1]}-${parts[0]}';
        } else {
          initialTanggalLahir = widget.santri!.tanggalLahir!;
        }
      } catch (e) {
        initialTanggalLahir = widget.santri!.tanggalLahir!;
      }
    }
    _tanggalLahirController = TextEditingController(text: initialTanggalLahir);

    _selectedGender = widget.santri?.gender;
    _selectedKelasId = widget.santri?.kelasId?.toString();
    _selectedAsramaId = widget.santri?.asramaId?.toString();
    _selectedKobongId = widget.santri?.kobongId?.toString();

    _fetchOptions();
  }

  // ... (keeping initState same)

  Future<void> _fetchOptions() async {
    setState(() => _isInitLoading = true);
    try {
      final kelasRes = await _apiService.get('sekretaris/kelas');
      final asramaRes = await _apiService.get('sekretaris/asrama');
      final kobongRes = await _apiService.get('sekretaris/kobong');

      if (mounted) {
        setState(() {
          _kelasOptions = kelasRes.data['data'] ?? [];
          _asramaOptions = asramaRes.data['data'] ?? [];
          _kobongOptions = kobongRes.data['data'] ?? [];

          // Initial filter if editing
          if (_selectedAsramaId != null) {
            _filterKobong(_selectedAsramaId!);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching options: $e');
    } finally {
      if (mounted) setState(() => _isInitLoading = false);
    }
  }

  void _filterKobong(String asramaId) {
    setState(() {
      _filteredKobong = _kobongOptions
          .where((k) => k['asrama_id'].toString() == asramaId)
          .toList();

      // Reset kobong if the selected one is not in the new filtered list
      if (_selectedKobongId != null) {
        bool exists =
            _filteredKobong.any((k) => k['id'].toString() == _selectedKobongId);
        if (!exists) _selectedKobongId = null;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Convert Display Date (DD-MM-YYYY) to API Date (YYYY-MM-DD)
      String submitTanggalLahir = _tanggalLahirController.text;
      if (submitTanggalLahir.contains('-')) {
        final parts = submitTanggalLahir.split('-');
        if (parts.length == 3) {
          submitTanggalLahir = '${parts[2]}-${parts[1]}-${parts[0]}';
        }
      }

      final data = {
        'nama_santri': _nameController.text,
        'nis': _nisController.text,
        'negara': _negaraController.text,
        'provinsi': _provinsiController.text,
        'kota_kabupaten': _kotaController.text,
        'kecamatan': _kecamatanController.text,
        'desa_kampung': _desaController.text,
        'rt_rw': _rtRwController.text,
        'nama_ortu_wali': _ortuController.text,
        'no_hp_ortu_wali': _hpOrtuController.text,
        'asrama_id': _selectedAsramaId,
        'kobong_id': _selectedKobongId,
        'kelas_id': _selectedKelasId,
        'gender': _selectedGender,
        'tanggal_masuk': _tanggalMasukController.text,
        'tanggal_lahir': submitTanggalLahir, // Use converted date
      };

      final response = widget.santri == null
          ? await _apiService.post('sekretaris/santri', data: data)
          : await _apiService.put('sekretaris/santri/${widget.santri!.id}',
              data: data);

      if (response.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.santri == null
                    ? 'Santri berhasil ditambah'
                    : 'Data berhasil diupdate')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
        title: Text(
          widget.santri == null ? 'Tambah Santri' : 'Edit Santri',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isInitLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Diri',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildTextField(
                        'Nama Lengkap', _nameController, Icons.person),
                    _buildTextField(
                        'NIS', _nisController, Icons.card_membership,
                        keyboardType: TextInputType.number),

                    const SizedBox(height: 16),
                    Text('Data Kelahiran & Login',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildDatePicker(
                        'Tanggal Lahir (DD-MM-YYYY)', _tanggalLahirController),

                    const SizedBox(height: 16),
                    Text('Alamat',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildTextField('Negara', _negaraController, Icons.flag),
                    _buildTextField(
                        'Provinsi', _provinsiController, Icons.map_outlined),
                    _buildTextField(
                        'Kota/Kabupaten', _kotaController, Icons.location_city),
                    _buildTextField(
                        'Kecamatan', _kecamatanController, Icons.location_on),
                    _buildTextField(
                        'Desa/Kampung', _desaController, Icons.home_work),
                    _buildTextField('RT/RW', _rtRwController, Icons.signpost),

                    const SizedBox(height: 16),
                    Text('Orang Tua / Wali',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildTextField('Nama Orang Tua', _ortuController,
                        Icons.family_restroom),
                    _buildTextField(
                        'No HP Orang Tua', _hpOrtuController, Icons.phone,
                        keyboardType: TextInputType.phone),

                    const SizedBox(height: 16),
                    Text('Data Akademik & Asrama',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),

                    // Gender Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Jenis Kelamin',
                        prefixIcon: const Icon(Icons.wc, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: ['Laki-laki', 'Perempuan']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedGender = val),
                      validator: (val) =>
                          val == null ? 'Jenis kelamin wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Kelas Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedKelasId,
                      decoration: InputDecoration(
                        labelText: 'Kelas',
                        prefixIcon: const Icon(Icons.class_, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _kelasOptions.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nama_kelas'] ?? '-'),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedKelasId = val),
                      validator: (val) =>
                          val == null ? 'Kelas wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Asrama Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedAsramaId,
                      decoration: InputDecoration(
                        labelText: 'Asrama',
                        prefixIcon: const Icon(Icons.apartment, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _asramaOptions.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nama_asrama'] ?? '-'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAsramaId = val;
                          if (val != null) _filterKobong(val);
                        });
                      },
                      validator: (val) =>
                          val == null ? 'Asrama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    // Kobong Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedKobongId,
                      decoration: InputDecoration(
                        labelText: 'Kobong (Kamar)',
                        prefixIcon: const Icon(Icons.meeting_room, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _filteredKobong.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nama_kobong'] ?? '-'),
                        );
                      }).toList(),
                      onChanged: _selectedAsramaId == null
                          ? null
                          : (val) => setState(() => _selectedKobongId = val),
                      validator: (val) =>
                          val == null ? 'Kobong wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildDatePicker('Tanggal Masuk', _tanggalMasukController),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'Simpan Data',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? '$label tidak boleh kosong' : null,
      ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onTap: () async {
          DateTime initialDate = DateTime.now();
          if (controller.text.isNotEmpty) {
            try {
              // Try parse DD-MM-YYYY
              final parts = controller.text.split('-');
              if (parts.length == 3) {
                initialDate = DateTime(int.parse(parts[2]), int.parse(parts[1]),
                    int.parse(parts[0]));
              }
            } catch (_) {}
          }

          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              // Set as DD-MM-YYYY
              controller.text =
                  "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
            });
          }
        },
        validator: (v) => v!.isEmpty ? '$label tidak boleh kosong' : null,
      ),
    );
  }
}
