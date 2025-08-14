import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool isRead;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isRead ? Colors.white : Colors.blue.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRead ? Colors.grey.shade300 : Colors.blue.shade300,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.notifications_active,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$message\n$time'),
        isThreeLine: true,
        onTap: () {
          // Can navigate to the specific customer or policy
        },
      ),
    );
  }
}
