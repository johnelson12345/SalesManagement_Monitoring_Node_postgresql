import 'package:flutter/foundation.dart';
import 'package:sales_managementv5/model/notification_model.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final List<Notification> _notifications = [];

  List<Notification> get notifications => List.unmodifiable(_notifications);

  int get notificationCount => _notifications.length;

  void addNotification(String title, String subtitle) {
    _notifications.add(Notification(title: title, subtitle: subtitle));
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
