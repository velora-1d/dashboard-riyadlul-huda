import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../models/pendidikan_models.dart';

class ERaporScreen extends StatefulWidget {
  const ERaporScreen({super.key});

  @override
  State<ERaporScreen> createState() => _ERaporScreenState();
}

class _ERaporScreenState extends State<ERaporScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<GradeRecord> _grades = [];
  String? _selectedSantriName;

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    setState(() => _isLoading = true);
    try {
      // For staff, we might need a way to select a santri first,
      // but for now let's assume it shows a general list or we select one
      final response = await _apiService.get('pendidikan/e-rapor');
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _grades = data.map((e) => GradeRecord.fromJson(e)).toList();
          _selectedSantriName = response.data['santri_name'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching grades: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Rapor Santri',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_selectedSantriName != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFF1B5E20).withOpacity(0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Menampilkan Nilai Untuk:',
                            style: GoogleFonts.outfit(
                                fontSize: 12, color: Colors.grey)),
                        Text(_selectedSantriName!,
                            style: GoogleFonts.outfit(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                Expanded(
                  child: _grades.isEmpty
                      ? const Center(child: Text('Data nilai belum tersedia'))
                      : ListView.builder(
                          itemCount: _grades.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final grade = _grades[index];
                            return _buildGradeCard(grade);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildGradeCard(GradeRecord grade) {
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
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getGradeColor(grade.grade).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  grade.grade,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getGradeColor(grade.grade),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grade.subject,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Keterangan: ${grade.note}',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              grade.score,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    return Colors.red;
  }
}
