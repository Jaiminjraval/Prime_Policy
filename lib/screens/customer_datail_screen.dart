import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:prime_policy/models/customer.dart';
import 'package:prime_policy/screens/add_edit_customer_screen.dart';
import 'package:prime_policy/services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;
  final FirebaseService _firebaseService = FirebaseService();

  CustomerDetailScreen({super.key, required this.customer});

  void _renewPolicy(BuildContext context) async {
    final renewedCustomer = Customer(
      id: customer.id,
      name: customer.name,
      policyType: customer.policyType,
      phoneNumber: customer.phoneNumber,
      policyStartDate: DateTime.now(),
      policyExpiryDate: DateTime(
        DateTime.now().year + 1,
        DateTime.now().month,
        DateTime.now().day,
      ),
      status: 'Renewed',
    );

    await _firebaseService.updateCustomer(renewedCustomer);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${customer.name}\'s policy has been renewed!')),
      );
      Navigator.of(context).pop();
    }
  }

  void _deleteCustomer(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${customer.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _firebaseService.deleteCustomer(customer.id);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    final Uri launchUri = Uri(scheme: 'tel', path: customer.phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch call to ${customer.phoneNumber}'),
        ),
      );
    }
  }

  Future<void> _downloadPdf(BuildContext context) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) await Permission.storage.request();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Policy Details',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Name: ${customer.name}'),
            pw.Text('Phone Number: ${customer.phoneNumber}'),
            pw.Divider(height: 20),
            pw.Text('Policy Type: ${customer.policyType}'),
            pw.Text(
              'Start Date: ${customer.policyStartDate.toLocal().toString().split(' ')[0]}',
            ),
            pw.Text(
              'Expiry Date: ${customer.policyExpiryDate.toLocal().toString().split(' ')[0]}',
            ),
          ],
        ),
      ),
    );

    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find directory to save file.')),
      );
      return;
    }

    final path = '${directory.path}/${customer.name}_policy.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF saved to Downloads folder')));

    // ✅ Important: Explicitly set MIME type to application/pdf
    await OpenFile.open(path, type: "application/pdf");
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
        // This is where the new "Renew" button is added.
        // It only shows up if the policy is expiring soon or has already expired.
        if (customer.isExpiringSoon ||
            customer.policyExpiryDate.isBefore(DateTime.now()))
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => _renewPolicy(context),
              icon: const Icon(Icons.autorenew),
              label: const Text('Mark as Renewed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 40),
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _makePhoneCall(context),
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        AddEditCustomerScreen(customer: customer),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _deleteCustomer(context),
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
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
