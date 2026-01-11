class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final String? icon;
  final String? color;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.icon,
    this.color,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      data: json['data'],
      icon: json['icon'],
      color: json['color'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
