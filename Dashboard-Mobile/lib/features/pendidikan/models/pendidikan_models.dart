class KalenderEvent {
  final int id;
  final String judul;
  final String deskripsi;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String kategori;
  final String warna;

  KalenderEvent({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.kategori,
    required this.warna,
  });

  factory KalenderEvent.fromJson(Map<String, dynamic> json) {
    return KalenderEvent(
      id: json['id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      tanggalMulai: json['tanggal_mulai'],
      tanggalSelesai: json['tanggal_selesai'],
      kategori: json['kategori'],
      warna: json['warna'],
    );
  }
}

class Kelas {
  final int id;
  final String namaKelas;

  Kelas({required this.id, required this.namaKelas});

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(id: json['id'], namaKelas: json['nama_kelas']);
  }
}

class SantriSimple {
  final int id;
  final String namaSantri;
  final String nis;

  SantriSimple({required this.id, required this.namaSantri, required this.nis});

  factory SantriSimple.fromJson(Map<String, dynamic> json) {
    return SantriSimple(
      id: json['id'],
      namaSantri: json['nama_santri'],
      nis: json['nis'],
    );
  }
}

class MataPelajaran {
  final int id;
  final String namaMapel;
  final bool hasWeeklyExam;

  MataPelajaran({
    required this.id,
    required this.namaMapel,
    required this.hasWeeklyExam,
  });

  factory MataPelajaran.fromJson(Map<String, dynamic> json) {
    return MataPelajaran(
      id: json['id'],
      namaMapel: json['nama_mapel'],
      hasWeeklyExam: json['has_weekly_exam'] == true,
    );
  }
}
