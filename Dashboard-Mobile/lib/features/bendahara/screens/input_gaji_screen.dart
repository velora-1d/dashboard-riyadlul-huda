import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../models/pegawai.dart';

class InputGajiScreen extends StatefulWidget {
  const InputGajiScreen({super.key});

  @override
  State<InputGajiScreen> createState() => _InputGajiScreenState();
}

class _InputGajiScreenState extends State<InputGajiScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isFetchingPegawai = true;

  List<Pegawai> _pegawaiList = [];
  Pegawai? _selectedPegawai;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isPaid = true;
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchPegawai();
  }

  Future<void> _fetchPegawai() async {
    try {
      final response = await _apiService.get('bendahara/pegawai');
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _pegawaiList = data.map((e) => Pegawai.fromJson(e)).toList();
          _isFetchingPegawai = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching pegawai: $e');
      setState(() => _isFetchingPegawai = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPegawai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih pegawai terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'pegawai_id': _selectedPegawai!.id,
        'bulan': _selectedMonth,
        'tahun': _selectedYear,
        'nominal': _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'is_dibayar': _isPaid,
        'tanggal_bayar': DateFormat('yyyy-MM-dd').format(_paymentDate),
        'keterangan': _noteController.text,
      };

      await _apiService.post('bendahara/gaji', data: data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data gaji berhasil disimpan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data gaji')),
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
        title: Text('Input Gaji Pegawai',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isFetchingPegawai
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Pegawai>(
                      decoration: InputDecoration(
                        labelText: 'Pilih Pegawai',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _selectedPegawai,
                      items: _pegawaiList.map((pegawai) {
                        return DropdownMenuItem(
                          value: pegawai,
                          child: Text(
                              '${pegawai.namaPegawai} (${pegawai.jabatan})'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedPegawai = v),
                      validator: (v) => v == null ? 'Wajib dipilih' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Bulan',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            value: _selectedMonth,
                            items: List.generate(12, (index) {
                              return DropdownMenuItem(
                                value: index + 1,
                                child: Text(DateFormat('MMMM', 'id')
                                    .format(DateTime(2024, index + 1))),
                              );
                            }),
                            onChanged: (v) =>
                                setState(() => _selectedMonth = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Tahun',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            value: _selectedYear,
                            items: List.generate(5, (index) {
                              final year = DateTime.now().year - 1 + index;
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }),
                            onChanged: (v) =>
                                setState(() => _selectedYear = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Nominal Gaji (Rp)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title:
                          Text('Status Dibayar', style: GoogleFonts.outfit()),
                      value: _isPaid,
                      onChanged: (v) => setState(() => _isPaid = v),
                    ),
                    if (_isPaid)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _paymentDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _paymentDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Tanggal Bayar',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(DateFormat('dd MMMM yyyy', 'id')
                                .format(_paymentDate)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Keterangan',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
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
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text('Simpan Data Gaji',
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
