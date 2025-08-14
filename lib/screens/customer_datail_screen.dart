import 'package:flutter/material.dart';
import 'package:prime_policy/models/customer.dart';
// import 'package:url_launcher/url_launcher.dart'; // Add url_launcher to pubspec.yaml for real use

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  // Example function to launch a phone call
  Future<void> _makePhoneCall(String phoneNumber, BuildContext context) async {
    // final Uri launchUri = Uri(
    //   scheme: 'tel',
    //   path: phoneNumber,
    // );
    // if (await canLaunchUrl(launchUri)) {
    //   await launchUrl(launchUri);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Could not launch call to $phoneNumber')),
    //   );
    // }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Calling ${customer.name}...')));
  }

  // Placeholder for PDF download
  void _downloadPdf(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading PDF for ${customer.name}...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(customer.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildDetailCard(context),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Policy Type:', customer.policyType),
            _buildDetailRow(
              'Start Date:',
              customer.policyStartDate.toLocal().toString().split(' ')[0],
            ),
            _buildDetailRow(
              'Expiry Date:',
              customer.policyExpiryDate.toLocal().toString().split(' ')[0],
            ),
            _buildDetailRow(
              'Days to Expire:',
              '${customer.daysToExpire} days',
              isHighlight: customer.isExpiringSoon,
            ),
            _buildDetailRow('Phone Number:', customer.phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _makePhoneCall(customer.phoneNumber, context),
              icon: const Icon(Icons.call),
              label: const Text('Call'),
            ),
            ElevatedButton.icon(
              onPressed: () => _downloadPdf(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Download'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to an edit screen
              },
              icon: const Icon(Icons.edit),
              label: const Text('Update'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Show a confirmation dialog before deleting
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String title,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isHighlight ? Colors.orange.shade800 : Colors.black87,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
