import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';

class SyahriahPaymentScreen extends StatefulWidget {
  const SyahriahPaymentScreen({super.key});

  @override
  State<SyahriahPaymentScreen> createState() => _SyahriahPaymentScreenState();
}

class _SyahriahPaymentScreenState extends State<SyahriahPaymentScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  String? _selectedSantriId;
  String? _selectedBulan;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isLoading = false;
  List<dynamic> _santriList = [];
  bool _isFetchingSantri = false;

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
    _fetchSantri();
  }

  Future<void> _fetchSantri() async {
    setState(() => _isFetchingSantri = true);
    try {
      // Assuming a generic santri list endpoint
      final response = await _apiService.get('santri/list');
      if (response.data['status'] == 'success') {
        setState(() {
          _santriList = response.data['data'];
          _isFetchingSantri = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching santri: $e');
      setState(() => _isFetchingSantri = false);
    }
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.post('bendahara/syahriah', data: {
        'santri_id': _selectedSantriId,
        'bulan': _selectedBulan,
        'jumlah': _amountController.text,
        'keterangan': _noteController.text,
      });

      if (response.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran berhasil dicatat')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Error submitting payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mencatat pembayaran')),
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
        title: Text('Input Syahriah',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isFetchingSantri
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pilih Santri',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      hint: const Text('Cari/Pilih Santri'),
                      items: _santriList.map((s) {
                        return DropdownMenuItem<String>(
                          value: s['id'].toString(),
                          child: Text("${s['nama']} (${s['kelas']})"),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSantriId = value),
                      validator: (value) =>
                          value == null ? 'Pilih santri terlebih dahulu' : null,
                    ),
                    const SizedBox(height: 20),
                    Text('Bulan Pembayaran',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      hint: const Text('Pilih Bulan'),
                      items: _months.map((m) {
                        return DropdownMenuItem<String>(
                            value: m, child: Text(m));
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedBulan = value),
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
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text('Simpan Pembayaran',
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
