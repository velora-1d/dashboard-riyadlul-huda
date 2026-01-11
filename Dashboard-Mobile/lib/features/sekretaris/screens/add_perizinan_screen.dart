import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../models/santri.dart';

class AddPerizinanScreen extends StatefulWidget {
  final Santri santri;
  const AddPerizinanScreen({super.key, required this.santri});

  @override
  State<AddPerizinanScreen> createState() => _AddPerizinanScreenState();
}

class _AddPerizinanScreenState extends State<AddPerizinanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alasanController = TextEditingController();
  DateTime _tglPulang = DateTime.now();
  DateTime _tglKembali = DateTime.now().add(const Duration(days: 3));
  bool _isSubmitting = false;

  Future<void> _selectDate(BuildContext context, bool isPulang) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPulang ? _tglPulang : _tglKembali,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isPulang) {
          _tglPulang = picked;
        } else {
          _tglKembali = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final response = await ApiService().post('sekretaris/perizinan', data: {
        'santri_id': widget.santri.id,
        'alasan': _alasanController.text,
        'tgl_pulang': DateFormat('yyyy-MM-dd').format(_tglPulang),
        'tgl_kembali': DateFormat('yyyy-MM-dd').format(_tglKembali),
      });

      if (response.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin berhasil disimpan')),
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
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Izin Santri',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color(0xFF1B5E20).withOpacity(0.05),
                elevation: 0,
                child: ListTile(
                  leading:
                      const Icon(Icons.person_pin, color: Color(0xFF1B5E20)),
                  title: Text(widget.santri.nama,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('NIS: ${widget.santri.nis}',
                      style: GoogleFonts.outfit()),
                ),
              ),
              const SizedBox(height: 24),
              Text('Alasan Izin',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _alasanController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Acara keluarga, Sakit, dsb.',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Alasan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tgl Pulang',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 8),
                                Text(DateFormat('dd/MM/yyyy')
                                    .format(_tglPulang)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tgl Kembali',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 8),
                                Text(DateFormat('dd/MM/yyyy')
                                    .format(_tglKembali)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
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
                      : Text('Simpan Data Izin',
                          style: GoogleFonts.outfit(
                              color: Colors.white,
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
