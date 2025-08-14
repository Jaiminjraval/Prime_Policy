import 'package:flutter/material.dart';
import 'package:prime_policy/widgets/notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This would be dynamically generated in a real app
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const <Widget>[
        NotificationCard(
          title: 'Policy Expiry Reminder',
          message: 'Jane Smith\'s car insurance is expiring in 13 days.',
          time: '2 hours ago',
          isRead: false,
        ),
        NotificationCard(
          title: 'Policy Expiry Reminder',
          message: 'John Doe\'s health insurance is expiring in 29 days.',
          time: '1 day ago',
          isRead: true,
        ),
        NotificationCard(
          title: 'New Policy Added',
          message: 'A new policy was added for David Williams.',
          time: '3 days ago',
          isRead: true,
        ),
      ],
    );
  }
}
