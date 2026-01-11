class AcademicEvent {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final String category; // e.g., 'Libur', 'Ujian', 'Kegiatan'

  AcademicEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
  });

  factory AcademicEvent.fromJson(Map<String, dynamic> json) {
    return AcademicEvent(
      id: json['id'],
      title: json['judul'] ?? '',
      description: json['deskripsi'] ?? '',
      date: DateTime.parse(json['tanggal']),
      category: json['kategori'] ?? 'Kegiatan',
    );
  }
}

class GradeRecord {
  final String subject;
  final String score;
  final String grade;
  final String note;

  GradeRecord({
    required this.subject,
    required this.score,
    required this.grade,
    this.note = '-',
  });

  factory GradeRecord.fromJson(Map<String, dynamic> json) {
    return GradeRecord(
      subject: json['mapel'] ?? '',
      score: json['nilai']?.toString() ?? '0',
      grade: json['grade'] ?? '-',
      note: json['keterangan'] ?? '-',
    );
  }
}
