import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../models/pendidikan_models.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  final ApiService _apiService = ApiService();
  List<KalenderEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await _apiService.get('pendidikan/kalender');
      if (response.data['status'] == 'success') {
        setState(() {
          _events = (response.data['data'] as List)
              .map((e) => KalenderEvent.fromJson(e))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalender Akademik',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchEvents,
              child: _events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada agenda',
                            style: GoogleFonts.outfit(
                                fontSize: 16, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 16, bottom: 80),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Container(
                              width: 12,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getColor(event.warna),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            title: Text(event.judul,
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${DateFormat('dd MMM yyyy', 'id').format(DateTime.parse(event.tanggalMulai))} - ${DateFormat('dd MMM yyyy', 'id').format(DateTime.parse(event.tanggalSelesai))}',
                                  style: GoogleFonts.outfit(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                                if (event.deskripsi.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(event.deskripsi,
                                      style: GoogleFonts.outfit(fontSize: 13)),
                                ]
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      _showEventDialog(event: event),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteEvent(event.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteEvent(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Agenda?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text('Hapus', style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final response = await _apiService.delete('pendidikan/kalender/$id');
        if (response.data['status'] == 'success') {
          await _fetchEvents();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agenda berhasil dihapus')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        }
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEventDialog({KalenderEvent? event}) {
    final titleController = TextEditingController(text: event?.judul ?? '');
    final descController = TextEditingController(text: event?.deskripsi ?? '');
    DateTime startDate =
        event != null ? DateTime.parse(event.tanggalMulai) : DateTime.now();
    DateTime endDate =
        event != null ? DateTime.parse(event.tanggalSelesai) : DateTime.now();
    String selectedColor = event?.warna ?? 'hijau';
    String selectedCategory = event?.kategori ?? 'Kegiatan';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(event == null ? 'Tambah Agenda' : 'Edit Agenda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Judul Agenda'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('dd MMM').format(startDate)),
                        onPressed: () async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030));
                          if (date != null) setState(() => startDate = date);
                        },
                      ),
                    ),
                    const Icon(Icons.arrow_forward, size: 16),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('dd MMM').format(endDate)),
                        onPressed: () async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030));
                          if (date != null) setState(() => endDate = date);
                        },
                      ),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: selectedColor,
                  decoration: const InputDecoration(labelText: 'Warna Label'),
                  items: const [
                    DropdownMenuItem(value: 'hijau', child: Text('Hijau')),
                    DropdownMenuItem(value: 'merah', child: Text('Merah')),
                    DropdownMenuItem(value: 'biru', child: Text('Biru')),
                    DropdownMenuItem(value: 'kuning', child: Text('Kuning')),
                    DropdownMenuItem(value: 'ungu', child: Text('Ungu')),
                  ],
                  onChanged: (v) => setState(() => selectedColor = v!),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Kegiatan', child: Text('Kegiatan (Akademik)')),
                    DropdownMenuItem(value: 'Libur', child: Text('Libur')),
                    DropdownMenuItem(value: 'Ujian', child: Text('Ujian')),
                    DropdownMenuItem(value: 'Rapat', child: Text('Rapat')),
                    DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                  ],
                  onChanged: (v) => setState(() => selectedCategory = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      final navigator = Navigator.of(context);
                      final scaffold = ScaffoldMessenger.of(context);

                      try {
                        if (titleController.text.isEmpty) {
                          throw Exception('Judul agenda tidak boleh kosong');
                        }

                        final data = {
                          'judul': titleController.text,
                          'deskripsi': descController.text,
                          'tanggal_mulai':
                              DateFormat('yyyy-MM-dd').format(startDate),
                          'tanggal_selesai':
                              DateFormat('yyyy-MM-dd').format(endDate),
                          'warna': selectedColor,
                          'kategori': selectedCategory,
                        };

                        if (event == null) {
                          await _apiService.post('pendidikan/kalender',
                              data: data);
                        } else {
                          await _apiService.put(
                              'pendidikan/kalender/${event.id}',
                              data: data);
                        }

                        navigator.pop();
                        _fetchEvents();
                        scaffold.showSnackBar(
                          const SnackBar(
                              content: Text('Agenda berhasil disimpan')),
                        );
                      } catch (e) {
                        setState(() => _isLoading = false);
                        String message = 'Gagal menyimpan agenda';
                        if (e.toString().contains('Judul')) {
                          message = e.toString().replaceAll('Exception: ', '');
                        }
                        scaffold.showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    },
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'merah':
        return Colors.red;
      case 'hijau':
        return Colors.green;
      case 'biru':
        return Colors.blue;
      case 'kuning':
        return Colors.orange;
      case 'ungu':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
