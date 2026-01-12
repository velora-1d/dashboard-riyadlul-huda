import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../models/financial_models.dart';

class AddFinancialEntryScreen extends StatefulWidget {
  final String type; // 'pemasukan' or 'pengeluaran'
  final FinancialRecord? item; // If provided, it's Edit Mode

  const AddFinancialEntryScreen({super.key, required this.type, this.item});

  @override
  State<AddFinancialEntryScreen> createState() =>
      _AddFinancialEntryScreenState();
}

class _AddFinancialEntryScreenState extends State<AddFinancialEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _amountController.text = widget.item!.amount;
      _descController.text = widget.item!
          .title; // title is mapped to keterangan in model often? or check model
      // Wait, FinancialRecord usually has 'title' (keterangan) and 'category' and 'amount'.
      // Let's double check FinancialListScreen mapping.
      // id, keterangan, jumlah, tanggal, kategori.
      // FinancialRecord.fromJson maps: title=keterangan.

      _descController.text = widget.item!.title;
      _categoryController.text = widget.item!.category;
      _selectedDate = widget.item!.date;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final data = {
        'type': widget.type,
        'jumlah': _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'keterangan': _descController.text,
        'tanggal': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'kategori': _categoryController.text.isEmpty
            ? 'Umum'
            : _categoryController.text,
      };

      final response = widget.item == null
          ? await ApiService().post('bendahara/kas', data: data)
          : await ApiService()
              .put('bendahara/kas/${widget.item!.id}', data: data);

      if (response.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(widget.item == null
                    ? 'Catatan berhasil disimpan'
                    : 'Catatan berhasil diperbarui')),
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

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSubmitting = true);
    try {
      final response = await ApiService().delete(
          'bendahara/kas/${widget.item!.id}',
          queryParameters: {'type': widget.type});

      if (response.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan berhasil dihapus')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPemasukan = widget.type == 'pemasukan';
    final primaryColor = isPemasukan ? Colors.blue : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.item == null
                ? 'Input ${isPemasukan ? "Pemasukan" : "Pengeluaran"}'
                : 'Edit Catatan',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          if (widget.item != null)
            IconButton(
                onPressed: _isSubmitting ? null : _delete,
                icon: const Icon(Icons.delete, color: Colors.red)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nominal (Rp)',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
                decoration: InputDecoration(
                  hintText: '0',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Nominal tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              Text('Kategori',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  hintText: 'Misal: Donasi, Sembako, Listrik, dsb.',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Tanggal',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
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
                      Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Keterangan',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Catatan tambahan...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Keterangan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.item == null
                              ? 'Simpan Catatan'
                              : 'Update Catatan',
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
