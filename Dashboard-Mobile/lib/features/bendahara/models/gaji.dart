import 'pegawai.dart';

class Gaji {
  final int id;
  final int pegawaiId;
  final int bulan;
  final int tahun;
  final String nominal;
  final bool isDibayar;
  final String? tanggalBayar;
  final String? keterangan;
  final Pegawai? pegawai;

  Gaji({
    required this.id,
    required this.pegawaiId,
    required this.bulan,
    required this.tahun,
    required this.nominal,
    required this.isDibayar,
    this.tanggalBayar,
    this.keterangan,
    this.pegawai,
  });

  factory Gaji.fromJson(Map<String, dynamic> json) {
    return Gaji(
      id: json['id'],
      pegawaiId: json['pegawai_id'],
      bulan: json['bulan'],
      tahun: json['tahun'],
      nominal: json['nominal'].toString(),
      isDibayar: json['is_dibayar'] == 1 || json['is_dibayar'] == true,
      tanggalBayar: json['tanggal_bayar'],
      keterangan: json['keterangan'],
      pegawai:
          json['pegawai'] != null ? Pegawai.fromJson(json['pegawai']) : null,
    );
  }
}
