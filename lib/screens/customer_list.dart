import 'package:flutter/material.dart';
import 'package:prime_policy/models/customer.dart';
import 'package:prime_policy/screens/customer_datail_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  // In a real app, this data would come from a database or API
  final List<Customer> _allCustomers = [
    Customer(id: '1', name: 'John Doe', policyType: 'Health Insurance', policyStartDate: DateTime(2024, 9, 15), policyExpiryDate: DateTime(2025, 9, 15), phoneNumber: '1234567890'),
    Customer(id: '2', name: 'Jane Smith', policyType: 'Car Insurance', policyStartDate: DateTime(2024, 8, 20), policyExpiryDate: DateTime(2025, 8, 20), phoneNumber: '2345678901'),
    Customer(id: '3', name: 'Peter Jones', policyType: 'Home Insurance', policyStartDate: DateTime(2024, 10, 1), policyExpiryDate: DateTime(2025, 10, 1), phoneNumber: '3456789012'),
    Customer(id: '4', name: 'Mary Johnson', policyType: 'Life Insurance', policyStartDate: DateTime(2025, 1, 10), policyExpiryDate: DateTime(2026, 1, 10), phoneNumber: '4567890123'),
    Customer(id: '5', name: 'David Williams', policyType: 'Car Insurance', policyStartDate: DateTime(2024, 8, 25), policyExpiryDate: DateTime(2025, 8, 25), phoneNumber: '5678901234'),
  ];

  List<Customer> _filteredCustomers = [];
  String _filterMonth = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCustomers = _allCustomers;
    _searchController.addListener(_filterCustomers);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_filterCustomers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCustomers() {
    final searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredCustomers = _allCustomers.where((customer) {
        final nameMatches = customer.name.toLowerCase().contains(searchQuery);
        
        final monthMatches = _filterMonth == 'All' ||
            customer.policyExpiryDate.month == [
              'All', 'January', 'February', 'March', 'April', 'May', 'June', 
              'July', 'August', 'September', 'October', 'November', 'December'
            ].indexOf(_filterMonth);

        return nameMatches && monthMatches;
      }).toList();
    });
  }

  void _onMonthChanged(String? newValue) {
    setState(() {
      _filterMonth = newValue ?? 'All';
      _filterCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by Name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _filterMonth,
                decoration: const InputDecoration(
                  labelText: 'Filter by Expiry Month',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'All', 'January', 'February', 'March', 'April', 'May', 'June', 
                  'July', 'August', 'September', 'October', 'November', 'December'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: _onMonthChanged,
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredCustomers.isEmpty
              ? const Center(child: Text('No customers found.'))
              : ListView.builder(
            itemCount: _filteredCustomers.length,
            itemBuilder: (context, index) {
              final customer = _filteredCustomers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(customer.name[0]),
                  ),
                  title: Text(customer.name),
                  subtitle: Text(
                      '${customer.policyType}\nExpires: ${customer.policyExpiryDate.toLocal().toString().split(' ')[0]}'),
                  trailing: customer.isExpiringSoon
                      ? const Icon(Icons.warning, color: Colors.orange)
                      : null,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          CustomerDetailScreen(customer: customer),
                    ));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
