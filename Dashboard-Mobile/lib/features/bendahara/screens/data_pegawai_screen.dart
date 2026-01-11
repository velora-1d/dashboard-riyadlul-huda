import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../models/financial_models.dart';

class DataPegawaiScreen extends StatefulWidget {
  const DataPegawaiScreen({super.key});

  @override
  State<DataPegawaiScreen> createState() => _DataPegawaiScreenState();
}

class _DataPegawaiScreenState extends State<DataPegawaiScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Employee> _employees = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('bendahara/pegawai');
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _employees = data.map((e) => Employee.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching employees: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Pegawai',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchEmployees,
              child: _employees.isEmpty
                  ? const Center(child: Text('Data pegawai belum tersedia'))
                  : ListView.builder(
                      itemCount: _employees.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final employee = _employees[index];
                        return _buildEmployeeCard(employee);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
              child: const Icon(Icons.person, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    employee.position,
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                employee.status,
                style: GoogleFonts.outfit(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
