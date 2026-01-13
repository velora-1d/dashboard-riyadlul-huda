import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../models/hafalan.dart';
import 'input_hafalan_screen.dart';

class HafalanListScreen extends StatefulWidget {
  const HafalanListScreen({super.key});

  @override
  State<HafalanListScreen> createState() => _HafalanListScreenState();
}

class _HafalanListScreenState extends State<HafalanListScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Hafalan> _hafalanList = [];
  String _jenis = 'Quran'; // Filter
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchHafalan();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role') ?? '';
    });
  }

  Future<void> _fetchHafalan() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await _apiService.get('pendidikan/hafalan', queryParameters: {
        'jenis': _jenis // Optional filter
      });
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _hafalanList = data.map((e) => Hafalan.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching hafalan: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteHafalan(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Yakin ingin menghapus data hafalan ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.delete('pendidikan/hafalan/$id');
        _fetchHafalan();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Gagal menghapus')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isParent = _userRole == 'wali_santri';
    bool isRois = _userRole == 'rois';

    return Scaffold(
      appBar: AppBar(
        title: Text('Data Hafalan',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Quran'),
                const SizedBox(width: 8),
                _buildFilterChip('Kitab'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: (isParent || isRois)
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const InputHafalanScreen()));
                if (result == true) _fetchHafalan();
              },
              backgroundColor: const Color(0xFF1B5E20),
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hafalanList.isEmpty
              ? const Center(child: Text('Belum ada data hafalan'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _hafalanList.length,
                  itemBuilder: (context, index) {
                    final item = _hafalanList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: isParent
                            ? null
                            : () async {
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            InputHafalanScreen(hafalan: item)));
                                if (result == true) _fetchHafalan();
                              },
                        leading: CircleAvatar(
                          backgroundColor: item.jenis == 'Quran'
                              ? Colors.green[100]
                              : Colors.orange[100],
                          child: Icon(
                              item.jenis == 'Quran'
                                  ? Icons.menu_book
                                  : Icons.book,
                              color: item.jenis == 'Quran'
                                  ? Colors.green
                                  : Colors.orange),
                        ),
                        title: Text(item.santri?.namaSantri ?? 'Santri Unknown',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item.namaHafalan}: ${item.progress}'),
                            const SizedBox(height: 4),
                            Text(
                                DateFormat('dd MMM yyyy', 'id')
                                    .format(DateTime.parse(item.tanggal)),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.nilai != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text('${item.nilai}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue)),
                              ),
                            if (!isParent &&
                                !isRois) // Apply the new condition here
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 20),
                                onPressed: () => _deleteHafalan(item.id),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _jenis == label;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (val) {
        setState(() {
          _jenis = label;
          _isLoading = true;
        });
        _fetchHafalan();
      },
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF1B5E20).withOpacity(0.2),
      labelStyle:
          TextStyle(color: isSelected ? const Color(0xFF1B5E20) : Colors.black),
    );
  }
}
