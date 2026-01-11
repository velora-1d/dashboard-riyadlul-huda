import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../models/financial_models.dart';

class GajiPegawaiScreen extends StatefulWidget {
  const GajiPegawaiScreen({super.key});

  @override
  State<GajiPegawaiScreen> createState() => _GajiPegawaiScreenState();
}

class _GajiPegawaiScreenState extends State<GajiPegawaiScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<SalaryRecord> _salaries = [];
  final _currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchSalaries();
  }

  Future<void> _fetchSalaries() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('bendahara/gaji');
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _salaries = data.map((e) => SalaryRecord.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching salaries: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gaji Pegawai',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSalaries,
              child: _salaries.isEmpty
                  ? const Center(child: Text('Data gaji belum tersedia'))
                  : ListView.builder(
                      itemCount: _salaries.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final salary = _salaries[index];
                        return _buildSalaryCard(salary);
                      },
                    ),
            ),
    );
  }

  Widget _buildSalaryCard(SalaryRecord salary) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: const Icon(Icons.money, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salary.employeeName,
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(salary.date),
                        style: GoogleFonts.outfit(
                            color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  _currencyFormat.format(double.parse(salary.amount)),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
