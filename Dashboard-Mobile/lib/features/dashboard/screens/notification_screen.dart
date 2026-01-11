import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/notification_model.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../auth/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService _apiService = ApiService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('notifications');
      if (response.data['status'] == 'success') {
        final List data = response.data['data'];
        setState(() {
          _notifications =
              data.map((json) => NotificationModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (e is DioException && e.response?.statusCode == 401) {
          // Token expired, logout
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          await _apiService.clearToken();

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengambil notifikasi: $e')),
          );
        }
      }
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _apiService.post('notifications/$id/read', data: {});
      _fetchNotifications();
    } catch (e) {
      // Silent error
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _apiService.post('notifications/read-all', data: {});
      _fetchNotifications();
    } catch (e) {
      // Silent error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Tandai semua dibaca',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Tidak ada notifikasi',
                            style: GoogleFonts.outfit(
                                color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Container(
      color: notification.isRead ? null : Colors.green.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColor(notification.color).withOpacity(0.1),
          child: Icon(_getIcon(notification.icon),
              color: _getColor(notification.color)),
        ),
        title: Text(notification.title,
            style: GoogleFonts.outfit(
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message, style: GoogleFonts.outfit()),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(notification.createdAt),
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
        },
      ),
    );
  }

  Color _getColor(String? colorStr) {
    if (colorStr == null) return Colors.green;
    try {
      return Color(int.parse(colorStr.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.green;
    }
  }

  IconData _getIcon(String? iconStr) {
    switch (iconStr) {
      case 'clock':
        return Icons.access_time;
      case 'dollar-sign':
        return Icons.attach_money;
      case 'user':
        return Icons.person;
      case 'info':
        return Icons.info_outline;
      default:
        return Icons.notifications_none;
    }
  }
}
