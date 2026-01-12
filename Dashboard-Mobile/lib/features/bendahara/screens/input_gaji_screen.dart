import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../models/gaji.dart';
import '../models/pegawai.dart';

class InputGajiScreen extends StatefulWidget {
  final Gaji? gaji;
  const InputGajiScreen({super.key, this.gaji});

  @override
  State<InputGajiScreen> createState() => _InputGajiScreenState();
}

class _InputGajiScreenState extends State<InputGajiScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isFetchingPegawai = true;
  bool _isEditMode = false;

  List<Pegawai> _pegawaiList = [];
  Pegawai? _selectedPegawai;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isPaid = false;
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.gaji != null) {
      _isEditMode = true;
      _prefillData();
    }
    _fetchPegawai();
  }

  void _prefillData() {
    final g = widget.gaji!;
    _selectedMonth = g.bulan;
    _selectedYear = g.tahun;
    _amountController.text = g.nominal;
    _isPaid = g.isDibayar;
    _noteController.text = g.keterangan ?? '';
    if (g.tanggalBayar != null) {
      _paymentDate = DateTime.tryParse(g.tanggalBayar!) ?? DateTime.now();
    }
    // _selectedPegawai will be set after fetching list
  }

  Future<void> _fetchPegawai() async {
    try {
      final response = await _apiService.get('bendahara/pegawai');
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _pegawaiList = data.map((e) => Pegawai.fromJson(e)).toList();
          _isFetchingPegawai = false;

          if (_isEditMode && widget.gaji?.pegawai != null) {
            try {
              _selectedPegawai = _pegawaiList.firstWhere(
                (p) => p.id == widget.gaji!.pegawai!.id,
                orElse: () => _pegawaiList.first,
              );
            } catch (_) {}
          }
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
        'tanggal_bayar':
            _isPaid ? DateFormat('yyyy-MM-dd').format(_paymentDate) : null,
        'keterangan': _noteController.text,
      };

      _isEditMode
          ? await _apiService.put('bendahara/gaji/${widget.gaji!.id}',
              data: data)
          : await _apiService.post('bendahara/gaji', data: data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_isEditMode
                  ? 'Data gaji diperbarui'
                  : 'Data gaji berhasil disimpan')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal ${_isEditMode ? 'memperbarui' : 'menyimpan'} data gaji')),
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
        title: Text(_isEditMode ? 'Edit Gaji Pegawai' : 'Input Gaji Pegawai',
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
                      items: _isEditMode
                          ? null
                          : _pegawaiList.map((pegawai) {
                              // Disable changing pegawai in Edit Mode? Normally allowed but let's keep it simple
                              return DropdownMenuItem(
                                value: pegawai,
                                child: Text(
                                    '${pegawai.namaPegawai} (${pegawai.jabatan})'),
                              );
                            }).toList(),
                      // If edit mode, maybe just show text or allow change.
                      // Let's allow change for now, or if complex just disabled it.
                      // Code above enables it if not edit mode? No, wait items logic.
                      // Let's just allow it always.
                      onChanged: _isEditMode
                          ? null
                          : (v) {
                              if (v != null) {
                                setState(() => _selectedPegawai = v);
                              }
                            },
                      validator: (v) => v == null ? 'Wajib dipilih' : null,
                      disabledHint:
                          Text(_selectedPegawai?.namaPegawai ?? 'Pegawai'),
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
                            : Text(
                                _isEditMode
                                    ? 'Update Data Gaji'
                                    : 'Simpan Data Gaji',
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
