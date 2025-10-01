import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prime_policy/models/customer.dart';
import 'package:prime_policy/screens/customer_datail_screen.dart';
import 'package:prime_policy/services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart'; // Make sure this is imported

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Helper method to launch the SMS app
  Future<void> _sendSmsReminder(Customer customer, BuildContext context) async {
    final message =
        "Hi ${customer.name}, a friendly reminder that your ${customer.policyType} policy is expiring on ${customer.policyExpiryDate.toLocal().toString().split(' ')[0]}. Please contact us to renew.";
    final uri = Uri(
      scheme: 'sms',
      path: customer.phoneNumber,
      queryParameters: <String, String>{'body': message},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open SMS app.')));
    }
  }

  // Helper method to launch WhatsApp
  Future<void> _sendWhatsAppReminder(
    Customer customer,
    BuildContext context,
  ) async {
    final message =
        "Hi ${customer.name}, a friendly reminder that your ${customer.policyType} policy is expiring on ${customer.policyExpiryDate.toLocal().toString().split(' ')[0]}. Please contact us to renew.";
    // IMPORTANT: Replace with your country code, e.g., +91 for India
    final whatsappUrl =
        "https://wa.me/+91${customer.phoneNumber}?text=${Uri.encodeComponent(message)}";
    final uri = Uri.parse(whatsappUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return StreamBuilder<QuerySnapshot<Customer>>(
      stream: firebaseService.getCustomersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No notifications.'));
        }

        final expiringCustomers = snapshot.data!.docs
            .map((doc) => doc.data())
            .where((customer) => customer.isExpiringSoon)
            .toList();

        if (expiringCustomers.isEmpty) {
          return const Center(child: Text('No policies are expiring soon.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: expiringCustomers.length,
          itemBuilder: (context, index) {
            final customer = expiringCustomers[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        customer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Policy: ${customer.policyType}\nExpires in ${customer.daysToExpire} days.',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              CustomerDetailScreen(customer: customer),
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.sms, color: Colors.orange),
                          label: const Text('Send SMS'),
                          onPressed: () => _sendSmsReminder(customer, context),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.chat, color: Colors.green),
                          label: const Text('WhatsApp'),
                          onPressed: () =>
                              _sendWhatsAppReminder(customer, context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
