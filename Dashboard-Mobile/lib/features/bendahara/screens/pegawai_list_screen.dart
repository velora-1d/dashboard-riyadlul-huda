import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../models/pegawai.dart';
import 'add_edit_pegawai_screen.dart';

class PegawaiListScreen extends StatefulWidget {
  const PegawaiListScreen({super.key});

  @override
  State<PegawaiListScreen> createState() => _PegawaiListScreenState();
}

class _PegawaiListScreenState extends State<PegawaiListScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Pegawai> _pegawaiList = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPegawai();
  }

  Future<void> _fetchPegawai() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get(
        'bendahara/pegawai',
        queryParameters:
            _searchQuery.isNotEmpty ? {'search': _searchQuery} : null,
      );
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _pegawaiList = data.map((e) => Pegawai.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching pegawai: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePegawai(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pegawai'),
        content: const Text('Yakin ingin menghapus data pegawai ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.delete('bendahara/pegawai/$id');
        _fetchPegawai();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pegawai berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus pegawai')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Pegawai',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddEditPegawaiScreen()),
          );
          if (result == true) _fetchPegawai();
        },
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari pegawai, jabatan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _apiService.get('bendahara/pegawai',
                    queryParameters: {'search': value}).then((response) {
                  if (response.data['status'] == 'success') {
                    final List data = response.data['data'];
                    setState(() {
                      _pegawaiList =
                          data.map((e) => Pegawai.fromJson(e)).toList();
                    });
                  }
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchPegawai,
                    child: _pegawaiList.isEmpty
                        ? Center(
                            child: Text('Data pegawai tidak ditemukan',
                                style: GoogleFonts.outfit(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _pegawaiList.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final pegawai = _pegawaiList[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF1B5E20),
                                    child: Text(
                                      pegawai.namaPegawai[0].toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(pegawai.namaPegawai,
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      '${pegawai.jabatan} • ${pegawai.noHp}',
                                      style: GoogleFonts.outfit(fontSize: 12)),
                                  trailing: PopupMenuButton(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddEditPegawaiScreen(
                                                    pegawai: pegawai),
                                          ),
                                        ).then((val) {
                                          if (val == true) _fetchPegawai();
                                        });
                                      } else if (value == 'delete') {
                                        _deletePegawai(pegawai.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Hapus',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
