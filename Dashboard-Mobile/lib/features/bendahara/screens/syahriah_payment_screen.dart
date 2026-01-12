import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';

import '../../sekretaris/models/santri.dart';
import '../../sekretaris/screens/data_santri_screen.dart';

class SyahriahPaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? syahriah; // If provided, edit mode

  const SyahriahPaymentScreen({super.key, this.syahriah});

  @override
  State<SyahriahPaymentScreen> createState() => _SyahriahPaymentScreenState();
}

class _SyahriahPaymentScreenState extends State<SyahriahPaymentScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  Santri? _selectedSantri;
  String? _selectedBulan;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;

  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.syahriah != null) {
      _isEditMode = true;
      _prefillData();
    }
  }

  void _prefillData() {
    final data = widget.syahriah!;
    // Assuming 'santri' object is available inside data or just santri_id
    if (data['santri'] != null) {
      _selectedSantri = Santri.fromJson(data['santri']);
    }
    _selectedBulan = data['bulan'];
    _amountController.text = data['nominal'].toString();
    _noteController.text = data['keterangan'] ?? '';
  }

  Future<void> _pickSantri() async {
    // Disable picking santri in Edit Mode if not desired, usually okay to lock it
    if (_isEditMode) return;

    final result = await Navigator.push<Santri>(
      context,
      MaterialPageRoute(
        builder: (context) => const DataSantriScreen(isSelectionMode: true),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSantri = result;
      });
    }
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSantri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih santri terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final endpoint = _isEditMode
          ? 'bendahara/syahriah/${widget.syahriah!['id']}'
          : 'bendahara/syahriah';

      final data = {
        'santri_id': _selectedSantri!.id,
        'bulan': _selectedBulan,
        'jumlah': _amountController.text,
        'keterangan': _noteController.text,
      };

      final response = _isEditMode
          ? await _apiService.put(endpoint, data: data)
          : await _apiService.post(endpoint, data: data);

      if (response.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_isEditMode
                    ? 'Data berhasil diperbarui'
                    : 'Pembayaran berhasil dicatat')),
          );
          Navigator.pop(context, true); // Return true to refresh list
        }
      }
    } catch (e) {
      debugPrint('Error submitting payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data')),
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
        title: Text(_isEditMode ? 'Edit Syahriah' : 'Input Syahriah',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Santri',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickSantri,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isEditMode ? Colors.grey[200] : Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedSantri != null
                            ? "${_selectedSantri!.nama} (${_selectedSantri!.kelas})"
                            : 'Pilih Santri',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: _selectedSantri != null
                              ? Colors.black
                              : Colors.grey[600],
                        ),
                      ),
                      if (!_isEditMode)
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              if (_selectedSantri == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text('Wajib dipilih',
                      style: GoogleFonts.outfit(
                          color: Colors.red[700], fontSize: 12)),
                ),
              const SizedBox(height: 20),
              Text('Bulan Pembayaran',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                hint: const Text('Pilih Bulan'),
                value: _selectedBulan,
                items: _months.map((m) {
                  return DropdownMenuItem<String>(value: m, child: Text(m));
                }).toList(),
                onChanged: (value) => setState(() => _selectedBulan = value),
                validator: (value) =>
                    value == null ? 'Pilih bulan pembayaran' : null,
              ),
              const SizedBox(height: 20),
              Text('Jumlah Pembayaran (Rp)',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 150000',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan jumlah pembayaran' : null,
              ),
              const SizedBox(height: 20),
              Text('Keterangan (Opsional)',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Catatan tambahan...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditMode
                              ? 'Perbarui Pembayaran'
                              : 'Simpan Pembayaran',
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
}
