import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prime_policy/models/customer.dart';
import 'package:prime_policy/screens/add_edit_customer_screen.dart'; // Add this import
import 'package:prime_policy/services/firebase_service.dart';
import 'package:prime_policy/widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return StreamBuilder<QuerySnapshot<Customer>>(
      stream: firebaseService.getCustomersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          // Handles the case where the stream is active but has no data yet
          return const Center(child: Text("Loading data..."));
        }

        final customers = snapshot.data!.docs.map((doc) => doc.data()).toList();
        final totalCustomers = customers.length;
        final expiringSoon = customers.where((c) => c.isExpiringSoon).length;
        final renewedCount = customers
            .where((c) => c.status == 'Renewed')
            .length;
        // You can add more logic here, for example for 'Active' or 'Renewed' policies
        final activePolicies = customers.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // const Text(
              //   'Here is your policy summary.',
              //   style: TextStyle(color: Colors.black54, fontSize: 16),
              // ),
              const Center(
                child: Text(
                  'Here is your policy summary.',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: <Widget>[
                  DashboardCard(
                    icon: Icons.people,
                    title: 'Total Customers',
                    value: totalCustomers.toString(),
                  ),
                  DashboardCard(
                    icon: Icons.policy,
                    title: 'Active Policies',
                    value: activePolicies.toString(),
                  ),
                  DashboardCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Expiring Soon',
                    value: expiringSoon.toString(),
                  ),
                  DashboardCard(
                    icon: Icons.check_circle,
                    title: 'Renewed',
                    value: renewedCount.toString(), // Placeholder
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.blue,
                ),
                title: const Text('Add New Customer Policy'),
                onTap: () {
                  // This is the updated navigation logic
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddEditCustomerScreen(),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
