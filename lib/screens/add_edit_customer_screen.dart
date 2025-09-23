import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prime_policy/models/customer.dart';
import 'package:prime_policy/services/firebase_service.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final Customer? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _policyTypeController;
  DateTime? _startDate;
  DateTime? _expiryDate;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name);
    _phoneController = TextEditingController(
      text: widget.customer?.phoneNumber,
    );
    _policyTypeController = TextEditingController(
      text: widget.customer?.policyType,
    );
    _startDate = widget.customer?.policyStartDate;
    _expiryDate = widget.customer?.policyExpiryDate;
  }

  // This method is now updated with the new logic
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    // If selecting an expiry date, but no start date is chosen, show a message and stop.
    if (!isStartDate && _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date first.')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          (isStartDate ? _startDate : _expiryDate) ??
          _startDate ??
          DateTime.now(),
      // If it's the start date picker, the first date is old.
      // If it's the expiry date picker, the first date is the selected start date.
      firstDate: isStartDate ? DateTime(2000) : _startDate!,
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Optional: Clear expiry date if the new start date is after the old expiry date
          if (_expiryDate != null && picked.isAfter(_expiryDate!)) {
            _expiryDate = null;
          }
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  // This method is now updated with the new validation
  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _expiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both start and expiry dates.'),
          ),
        );
        return;
      }

      // NEW: Add validation to ensure expiry date is not before the start date.
      if (_expiryDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expiry date cannot be earlier than the start date.'),
          ),
        );
        return;
      }

      if (_isEditing) {
        final updatedCustomer = Customer(
          id: widget.customer!.id,
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          policyType: _policyTypeController.text,
          policyStartDate: _startDate!,
          policyExpiryDate: _expiryDate!,
          status: widget.customer!.status,
        );
        await _firebaseService.updateCustomer(updatedCustomer);
      } else {
        final newCustomer = Customer(
          id: '',
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          policyType: _policyTypeController.text,
          policyStartDate: _startDate!,
          policyExpiryDate: _expiryDate!,
          status: 'Active',
        );
        await _firebaseService.addCustomer(newCustomer);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Customer' : 'Add New Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a phone number' : null,
              ),
              TextFormField(
                controller: _policyTypeController,
                decoration: const InputDecoration(labelText: 'Policy Type'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a policy type' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _startDate == null
                          ? 'No Start Date Chosen'
                          : 'Start: ${DateFormat.yMd().format(_startDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _expiryDate == null
                          ? 'No Expiry Date Chosen'
                          : 'Expiry: ${DateFormat.yMd().format(_expiryDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Save Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
