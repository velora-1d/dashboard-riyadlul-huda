class SantriArrears {
  final int id;
  final String name;
  final String nis;
  final String kelas;
  final int totalTunggakan;
  final List<String> bulanMenunggak;

  SantriArrears({
    required this.id,
    required this.name,
    required this.nis,
    required this.kelas,
    required this.totalTunggakan,
    required this.bulanMenunggak,
  });

  factory SantriArrears.fromJson(Map<String, dynamic> json) {
    return SantriArrears(
      id: json['id'],
      name: json['name'],
      nis: json['nis'] ?? '-',
      kelas: json['kelas'] ?? '-',
      totalTunggakan: json['total_tunggakan'],
      bulanMenunggak: List<String>.from(json['bulan_menunggak']),
    );
  }
}
