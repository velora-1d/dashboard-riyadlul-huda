import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';

class IjazahDigitalScreen extends StatefulWidget {
  const IjazahDigitalScreen({super.key});

  @override
  State<IjazahDigitalScreen> createState() => _IjazahDigitalScreenState();
}

class _IjazahDigitalScreenState extends State<IjazahDigitalScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _ijazahList = [];

  @override
  void initState() {
    super.initState();
    _fetchIjazah();
  }

  Future<void> _fetchIjazah() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('pendidikan/ijazah');
      if (response.data['status'] == 'success') {
        setState(() {
          _ijazahList = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching ijazah: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ijazah Digital',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ijazahList.isEmpty
              ? const Center(child: Text('Data ijazah belum tersedia'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _ijazahList.length,
                  itemBuilder: (context, index) {
                    final item = _ijazahList[index];
                    return _buildIjazahCard(item);
                  },
                ),
    );
  }

  Widget _buildIjazahCard(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child:
                  const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama_santri'] ?? 'Santri',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Tahun: ${item['tahun_lulus']}',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Open PDF/Image
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Buka',
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
