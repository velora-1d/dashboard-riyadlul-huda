class Hafalan {
  final int id;
  final int santriId;
  final SantriInfo? santri;
  final String jenis; // Quran, Kitab
  final String namaHafalan;
  final String progress;
  final String tanggal;
  final int? nilai;
  final String? catatan;

  Hafalan({
    required this.id,
    required this.santriId,
    this.santri,
    required this.jenis,
    required this.namaHafalan,
    required this.progress,
    required this.tanggal,
    this.nilai,
    this.catatan,
  });

  factory Hafalan.fromJson(Map<String, dynamic> json) {
    return Hafalan(
      id: json['id'],
      santriId: json['santri_id'],
      santri:
          json['santri'] != null ? SantriInfo.fromJson(json['santri']) : null,
      jenis: json['jenis'],
      namaHafalan: json['nama_hafalan'],
      progress: json['progress'],
      tanggal: json['tanggal'],
      nilai: json['nilai'],
      catatan: json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'santri_id': santriId,
      'jenis': jenis,
      'nama_hafalan': namaHafalan,
      'progress': progress,
      'tanggal': tanggal,
      'nilai': nilai,
      'catatan': catatan,
    };
  }
}

class SantriInfo {
  final int id;
  final String namaSantri;
  final String kelas;

  SantriInfo({required this.id, required this.namaSantri, required this.kelas});

  factory SantriInfo.fromJson(Map<String, dynamic> json) {
    return SantriInfo(
      id: json['id'],
      namaSantri: json['nama_santri'],
      kelas: json['kelas']?['nama_kelas'] ?? '-',
    );
  }
}
