class Perizinan {
  final int id;
  final int santriId;
  final String namaSantri;
  final String jenis;
  final String alasan;
  final DateTime tglMulai;
  final DateTime tglSelesai;
  final String status;

  Perizinan({
    required this.id,
    required this.santriId,
    required this.namaSantri,
    required this.jenis,
    required this.alasan,
    required this.tglMulai,
    required this.tglSelesai,
    required this.status,
  });

  factory Perizinan.fromJson(Map<String, dynamic> json) {
    return Perizinan(
      id: json['id'],
      santriId: json['santri_id'],
      namaSantri: json['santri']['nama'] ?? 'Unknown',
      jenis: json['jenis_perizinan'] ?? '-',
      alasan: json['alasan'] ?? '-',
      tglMulai: DateTime.parse(json['tanggal_mulai']),
      tglSelesai: DateTime.parse(json['tanggal_selesai']),
      status: json['status'] ?? 'Pending',
    );
  }
}
