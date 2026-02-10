import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartfarm/controller/notification_log_controller.dart';
import 'package:smartfarm/model/colors_model.dart';

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
      final dt = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return '';
    }
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';

    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();

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

  Color _getNotificationColor(String? level, bool isDark) {
    if (level == 'error') {
      return AppColors.errorRed;
    } else if (level == 'success') {
      return AppColors.successGreen;
    } else {
      return isDark ? AppColors.darkAccent : AppColors.lightAccent;
    }
  }

  IconData _getNotificationIcon(String? level) {
    switch (level) {
      case 'error':
        return Icons.error_outline_rounded;
      case 'success':
        return Icons.check_circle_outline_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: surfaceColor,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.notifications.isNotEmpty) {
              return IconButton(
                icon: Icon(Icons.done_all_rounded, color: subTextColor),
                tooltip: 'Mark all as read',
                onPressed: () {
                  // Add mark all as read functionality
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.darkAccent : AppColors.lightAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading notifications...',
                  style: TextStyle(color: subTextColor, fontSize: 14),
                ),
              ],
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    boxShadow: isDark ? null : AppColors.greenGlow,
                  ),
                  child: Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "No notifications yet",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You're all caught up!",
                  style: TextStyle(color: subTextColor, fontSize: 14),
                ),
              ],
            ),
          );
        }

        final groupedNotifications = _groupByDate(controller.notifications);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: groupedNotifications.length,
          itemBuilder: (context, index) {
            final dateKey = groupedNotifications.keys.elementAt(index);
            final notifications = groupedNotifications[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header with modern styling
                Container(
                  margin: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isDark
                                  ? AppColors.darkAccent
                                  : AppColors.lightAccent,
                              isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        dateKey,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isDark
                                      ? AppColors.darkAccent
                                      : AppColors.lightAccent)
                                  .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${notifications.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkAccent
                                : AppColors.lightAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Notifications for this date
                ...notifications.map((n) {
                  final notifColor = _getNotificationColor(n['level'], isDark);
                  final icon = _getNotificationIcon(n['level']);

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Handle notification tap
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon with colored background
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: notifColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: notifColor, size: 24),
                              ),
                              const SizedBox(width: 16),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n['title'] ?? 'Notification',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: textColor,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: subTextColor.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 12,
                                                color: subTextColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatTime(n['created_at']),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: subTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _formatMessage(n['message']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: subTextColor,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            );
          },
        );
      }),
    );
  }
}
