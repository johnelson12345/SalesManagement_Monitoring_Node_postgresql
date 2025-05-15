import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/notification_model.dart' as model;

class NotificationDialog extends StatelessWidget {
  final List<model.Notification> notifications;

  const NotificationDialog({Key? key, required this.notifications}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Notifications'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return ListTile(
              leading: const Icon(Icons.notification_important),
              title: Text(notification.title),
              subtitle: Text(notification.subtitle),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
