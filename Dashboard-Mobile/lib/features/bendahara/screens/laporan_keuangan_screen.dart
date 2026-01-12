import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/api_service.dart';

class LaporanKeuanganScreen extends StatefulWidget {
  const LaporanKeuanganScreen({super.key});

  @override
  State<LaporanKeuanganScreen> createState() => _LaporanKeuanganScreenState();
}

class _LaporanKeuanganScreenState extends State<LaporanKeuanganScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService
          .get('bendahara/laporan', queryParameters: {'tahun': _selectedYear});
      if (response.data['status'] == 'success') {
        setState(() {
          _data = response.data['data'];
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
        title: Text('Laporan Keuangan',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          DropdownButton<int>(
            value: _selectedYear,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            items: List.generate(5, (i) => DateTime.now().year - 2 + i)
                .map((y) =>
                    DropdownMenuItem(value: y, child: Text(y.toString())))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedYear = v);
                _fetchData();
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('Gagal memuat data'))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSummaryCard(
                          'Saldo Akhir',
                          _data!['summary']['saldo_akhir'],
                          Colors.blue,
                          Icons.account_balance_wallet,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _buildSummaryCard(
                                    'Total Pemasukan',
                                    _data!['summary']['total_masuk_bersih'],
                                    Colors.green,
                                    Icons.arrow_downward)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildSummaryCard(
                                    'Total Pengeluaran',
                                    _data!['summary']['total_keluar_bersih'],
                                    Colors.red,
                                    Icons.arrow_upward)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Arus Kas Bulanan',
                            style: GoogleFonts.outfit(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: _getMaxY(),
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final months = [
                                        'Jan',
                                        'Feb',
                                        'Mar',
                                        'Apr',
                                        'Mei',
                                        'Jun',
                                        'Jul',
                                        'Agu',
                                        'Sep',
                                        ' Okt',
                                        'Nov',
                                        'Des'
                                      ];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(months[value.toInt() - 1],
                                            style:
                                                const TextStyle(fontSize: 10)),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: (_data!['chart'] as List)
                                  .map<BarChartGroupData>((item) {
                                return BarChartGroupData(
                                  x: item['bulan'],
                                  barRods: [
                                    BarChartRodData(
                                        toY: (item['masuk'] as num).toDouble(),
                                        color: Colors.green,
                                        width: 8),
                                    BarChartRodData(
                                        toY: (item['keluar'] as num).toDouble(),
                                        color: Colors.red,
                                        width: 8),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegend(Colors.green, 'Pemasukan'),
                            const SizedBox(width: 16),
                            _buildLegend(Colors.red, 'Pengeluaran'),
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final response = await _apiService.post(
                                    'bendahara/laporan/url',
                                    data: {'tahun': _selectedYear});
                                if (response.data['status'] == 'success') {
                                  final url = Uri.parse(response.data['url']);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Tidak dapat membuka link download')));
                                    }
                                  }
                                }
                              } catch (e) {
                                debugPrint('Download error: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Gagal mengunduh laporan')));
                                }
                              }
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Download Laporan PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (var item in (_data!['chart'] as List)) {
      if (item['masuk'] > max) max = (item['masuk'] as num).toDouble();
      if (item['keluar'] > max) max = (item['keluar'] as num).toDouble();
    }
    return max * 1.2;
  }

  Widget _buildSummaryCard(
      String title, num amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(title,
                      style: GoogleFonts.outfit(
                          color: Colors.grey[600], fontSize: 13))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                .format(amount),
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.outfit(fontSize: 12)),
      ],
    );
  }
}
