import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../models/pendidikan_models.dart';

class KalenderAkademikScreen extends StatefulWidget {
  const KalenderAkademikScreen({super.key});

  @override
  State<KalenderAkademikScreen> createState() => _KalenderAkademikScreenState();
}

class _KalenderAkademikScreenState extends State<KalenderAkademikScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<AcademicEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('pendidikan/kalender');
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _events = data.map((e) => AcademicEvent.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching calendar: $e');
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
                  ? const Center(child: Text('Belum ada agenda akademik'))
                  : ListView.builder(
                      itemCount: _events.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return _buildEventCard(event);
                      },
                    ),
            ),
    );
  }

  Widget _buildEventCard(AcademicEvent event) {
    Color categoryColor;
    switch (event.category.toLowerCase()) {
      case 'libur':
        categoryColor = Colors.red;
        break;
      case 'ujian':
        categoryColor = Colors.orange;
        break;
      default:
        categoryColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.event, size: 16, color: categoryColor),
                const SizedBox(width: 8),
                Text(
                  event.category.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: categoryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMMM yyyy').format(event.date),
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: GoogleFonts.outfit(
                      color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
