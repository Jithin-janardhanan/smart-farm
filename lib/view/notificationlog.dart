import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartfarm/controller/notification_log_controller.dart';

class NotificationPage extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

  NotificationPage({super.key});

  String _formatMessage(dynamic msg) {
    if (msg is String) {
      return msg;
    } else if (msg is Map) {
      return "Type: ${msg['type'] ?? '-'}\n"
          "Event: ${msg['event'] ?? '-'}\n"
          "Message: ${msg['message'] ?? '-'}";
    } else {
      return "-";
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('hh:mm a').format(dt); // 05:01 PM format
    } catch (e) {
      return '';
    }
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final notifDate = DateTime(dt.year, dt.month, dt.day);

      if (notifDate == today) {
        return 'Today';
      } else if (notifDate == yesterday) {
        return 'Yesterday';
      } else {
        return DateFormat('dd MMM yyyy').format(dt);
      }
    } catch (e) {
      return '';
    }
  }

  Map<String, List<dynamic>> _groupByDate(List<dynamic> notifications) {
    final grouped = <String, List<dynamic>>{};

    for (var notif in notifications) {
      final dateKey = _formatDate(notif['created_at']);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notif);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return const Center(child: Text("No notifications found"));
        }

        final groupedNotifications = _groupByDate(controller.notifications);

        return ListView.builder(
          itemCount: groupedNotifications.length,
          itemBuilder: (context, index) {
            final dateKey = groupedNotifications.keys.elementAt(index);
            final notifications = groupedNotifications[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.grey[200],
                  child: Text(
                    dateKey,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Notifications for this date
                ...notifications.map((n) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(
                        n['level'] == 'error' ? Icons.error : Icons.info,
                        color: n['level'] == 'error' ? Colors.red : Colors.blue,
                      ),
                      title: Text(
                        n['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_formatMessage(n['message'])),
                      trailing: Text(
                        _formatTime(n['created_at']),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        );
      }),
    );
  }
}
