class Santri {
  final int id;
  final String nama;
  final String nis;
  final String kelas;
  final String kamar;
  final String fotoPath;
  final String status;

  Santri({
    required this.id,
    required this.nama,
    required this.nis,
    required this.kelas,
    required this.kamar,
    this.fotoPath = '',
    this.status = 'Aktif',
  });

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      id: json['id'],
      nama: json['nama'],
      nis: json['nis'] ?? '-',
      kelas: json['kelas'] ?? '-',
      kamar: json['kamar'] ?? '-',
      fotoPath: json['foto_path'] ?? '',
      status: json['status'] ?? 'Aktif',
    );
  }
}
