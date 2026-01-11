class Pegawai {
  final int id;
  final String namaPegawai;
  final String jabatan;
  final String departemen;
  final String noHp;
  final String alamat;
  final bool isActive;

  Pegawai({
    required this.id,
    required this.namaPegawai,
    required this.jabatan,
    required this.departemen,
    required this.noHp,
    required this.alamat,
    required this.isActive,
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) {
    return Pegawai(
      id: json['id'],
      namaPegawai: json['nama_pegawai'],
      jabatan: json['jabatan'],
      departemen: json['departemen'],
      noHp: json['no_hp'],
      alamat: json['alamat'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_pegawai': namaPegawai,
      'jabatan': jabatan,
      'departemen': departemen,
      'no_hp': noHp,
      'alamat': alamat,
      'is_active': isActive,
    };
  }
}
