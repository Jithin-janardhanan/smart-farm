import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfarm/controller/notification_log_controller.dart';


class NotificationPage extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

NotificationPage({super.key});

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

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final n = controller.notifications[index];
            return ListTile(
              leading: Icon(
                n['level'] == 'error' ? Icons.error : Icons.info,
                color: n['level'] == 'error' ? Colors.red : Colors.blue,
              ),
              title: Text(n['title']),
              subtitle: Text(n['message']),
              trailing: Text(
                n['created_at'].toString().split('T').first,
                style: const TextStyle(fontSize: 12),
              ),
            );
          },
        );
      }),
    );
  }
}
