import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../models/perizinan.dart';
import 'data_santri_screen.dart';
import 'add_perizinan_screen.dart';

class PerizinanScreen extends StatefulWidget {
  const PerizinanScreen({super.key});

  @override
  State<PerizinanScreen> createState() => _PerizinanScreenState();
}

class _PerizinanScreenState extends State<PerizinanScreen> {
  final ApiService _apiService = ApiService();
  List<Perizinan> _perizinanList = [];
  bool _isLoading = true;
  String _selectedStatus = 'Semua';

  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchPerizinan();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userRole = prefs.getString('user_role') ?? '';
      });
    }
  }

  Future<void> _fetchPerizinan() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await _apiService.get('sekretaris/perizinan', queryParameters: {
        if (_selectedStatus != 'Semua') 'status': _selectedStatus.toLowerCase(),
      });
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _perizinanList = data.map((e) => Perizinan.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching perizinan: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perizinan',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchPerizinan,
                    child: _perizinanList.isEmpty
                        ? const Center(child: Text('Tidak ada data perizinan'))
                        : ListView.builder(
                            itemCount: _perizinanList.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final izin = _perizinanList[index];
                              return _buildPerizinanCard(izin);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _userRole == 'rois'
          ? null
          : FloatingActionButton(
              onPressed: () async {
                // 1. Select Santri
                final santri = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const DataSantriScreen(isSelectionMode: true),
                  ),
                );

                // 2. If Santri selected, Open Add Form
                if (santri != null) {
                  if (!context.mounted) return;
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPerizinanScreen(santri: santri),
                    ),
                  );

                  // 3. Refresh list if permission successfully added
                  if (result == true) {
                    _fetchPerizinan();
                  }
                }
              },
              backgroundColor: const Color(0xFF1B5E20),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ['Semua', 'Pending', 'Disetujui', 'Ditolak'].map((status) {
          final isSelected = _selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedStatus = status);
                  _fetchPerizinan();
                }
              },
              selectedColor: const Color(0xFF1B5E20).withOpacity(0.2),
              labelStyle: GoogleFonts.outfit(
                color: isSelected ? const Color(0xFF1B5E20) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      final response = await _apiService
          .post('sekretaris/perizinan/$id/approval', data: {'status': status});
      if (response.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Perizinan berhasil $status')),
          );
          _fetchPerizinan();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui status: $e')),
        );
      }
    }
  }

  Widget _buildPerizinanCard(Perizinan izin) {
    Color statusColor;
    bool showApproval = izin.status.toLowerCase() == 'pending';

    switch (izin.status.toLowerCase()) {
      case 'disetujui':
        statusColor = Colors.green;
        break;
      case 'ditolak':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    izin.namaSantri,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    izin.status,
                    style: GoogleFonts.outfit(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(izin.jenis,
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('dd MMM').format(izin.tglMulai)} - ${DateFormat('dd MMM yyyy').format(izin.tglSelesai)}',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Alasan:',
              style:
                  GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              izin.alasan,
              style:
                  GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade800),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showApproval && _userRole != 'rois') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(izin.id, 'Ditolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Tolak', style: GoogleFonts.outfit()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(izin.id, 'Disetujui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Setujui', style: GoogleFonts.outfit()),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
