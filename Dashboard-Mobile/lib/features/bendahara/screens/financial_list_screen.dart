import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import '../models/financial_models.dart';

import 'add_financial_entry_screen.dart';

class FinancialListScreen extends StatefulWidget {
  final String type; // 'pemasukan' or 'pengeluaran'
  const FinancialListScreen({super.key, required this.type});

  @override
  State<FinancialListScreen> createState() => _FinancialListScreenState();
}

class _FinancialListScreenState extends State<FinancialListScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<FinancialRecord> _records = [];
  String _selectedCategory = 'Semua';
  final _currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('bendahara/kas', queryParameters: {
        'type': widget.type,
        if (_selectedCategory != 'Semua') 'kategori': _selectedCategory,
      });
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _records = data.map((e) => FinancialRecord.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching records: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'pemasukan' ? 'Pemasukan' : 'Pengeluaran';
    final primaryColor =
        widget.type == 'pemasukan' ? Colors.blue : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFinancialEntryScreen(type: widget.type),
            ),
          );
          if (result == true) {
            _fetchRecords();
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildCategoryFilters(primaryColor),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchRecords,
                    child: _records.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 80, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text('Belum ada data $title',
                                    style:
                                        GoogleFonts.outfit(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _records.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final record = _records[index];
                              return _buildRecordCard(record, primaryColor);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(Color color) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ['Semua', 'Umum', 'Sembako', 'Listrik', 'Donasi'].map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = cat);
                  _fetchRecords();
                }
              },
              selectedColor: color.withOpacity(0.2),
              labelStyle: GoogleFonts.outfit(
                color: isSelected ? color : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecordCard(FinancialRecord record, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.type == 'pemasukan'
                ? Icons.trending_up
                : Icons.trending_down,
            color: color,
          ),
        ),
        title: Text(
          record.title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record.category} • ${DateFormat('dd MMM yyyy').format(record.date)}',
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Text(
          _currencyFormat.format(double.parse(record.amount)),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
