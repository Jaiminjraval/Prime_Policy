import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prime_policy/models/customer.dart';
import 'package:prime_policy/screens/customer_datail_screen.dart';
import 'package:prime_policy/services/firebase_service.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search by Name',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Customer>>(
            stream: _firebaseService.getCustomersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong!'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No customers found.'));
              }

              final customers = snapshot.data!.docs
                  .map((doc) => doc.data())
                  .toList();

              final filteredCustomers = customers.where((customer) {
                return customer.name.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filteredCustomers.isEmpty) {
                return const Center(
                  child: Text('No customers match your search.'),
                );
              }

              return ListView.builder(
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = filteredCustomers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(customer.name[0])),
                      title: Text(customer.name),
                      subtitle: Text(
                        '${customer.policyType}\nExpires: ${customer.policyExpiryDate.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: customer.isExpiringSoon
                          ? const Icon(Icons.warning, color: Colors.orange)
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                CustomerDetailScreen(customer: customer),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
