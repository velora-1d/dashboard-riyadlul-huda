class SantriArrears {
  final int id;
  final String name;
  final String nis;
  final String kelas;
  final int totalTunggakan;
  final List<String> bulanMenunggak;
  final String? noHpOrtu;
  final int jumlahBulan;

  SantriArrears({
    required this.id,
    required this.name,
    required this.nis,
    required this.kelas,
    required this.totalTunggakan,
    this.bulanMenunggak = const [],
    this.noHpOrtu,
    this.jumlahBulan = 0,
  });

  factory SantriArrears.fromJson(Map<String, dynamic> json) {
    return SantriArrears(
      id: json['id'],
      name: json['nama_santri'],
      nis: json['nis'] ?? '-',
      kelas: json['kelas'] ?? '-',
      noHpOrtu: json['no_hp_ortu'],
      totalTunggakan: json['total_tunggakan'],
      jumlahBulan: json['jumlah_bulan'] ?? 0,
      bulanMenunggak: List<String>.from(json['bulan_menunggak']),
    );
  }
}
