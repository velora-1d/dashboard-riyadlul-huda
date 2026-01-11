class FinancialRecord {
  final int id;
  final String title;
  final String amount;
  final DateTime date;
  final String category;
  final String type; // 'income' or 'expense'

  FinancialRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });

  factory FinancialRecord.fromJson(Map<String, dynamic> json) {
    return FinancialRecord(
      id: json['id'],
      title: json['keterangan'] ?? '',
      amount: json['jumlah']?.toString() ?? '0',
      date: DateTime.parse(json['tanggal']),
      category: json['kategori'] ?? '',
      type: json['tipe'] ?? 'income',
    );
  }
}

class Employee {
  final int id;
  final String name;
  final String position;
  final String status;
  final String phone;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.status,
    required this.phone,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['nama'] ?? '',
      position: json['jabatan'] ?? '',
      status: json['status'] ?? 'Aktif',
      phone: json['no_hp'] ?? '',
    );
  }
}

class SalaryRecord {
  final int id;
  final String employeeName;
  final String amount;
  final DateTime date;
  final String status;

  SalaryRecord({
    required this.id,
    required this.employeeName,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory SalaryRecord.fromJson(Map<String, dynamic> json) {
    return SalaryRecord(
      id: json['id'],
      employeeName: json['nama_pegawai'] ?? '',
      amount: json['jumlah']?.toString() ?? '0',
      date: DateTime.parse(json['tanggal']),
      status: json['status'] ?? 'Dibayar',
    );
  }
}
