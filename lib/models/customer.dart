import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final String policyType;
  final DateTime policyStartDate;
  final DateTime policyExpiryDate;
  final String phoneNumber;
  final String status;

  Customer({
    required this.id,
    required this.name,
    required this.policyType,
    required this.policyStartDate,
    required this.policyExpiryDate,
    required this.phoneNumber,
    required this.status,
  });

  // Helper to check if the policy is expiring soon (e.g., within 30 days)
  bool get isExpiringSoon {
    final now = DateTime.now();
    return policyExpiryDate.difference(now).inDays <= 30 &&
        policyExpiryDate.isAfter(now);
  }

  // Helper to get the number of days until expiry
  int get daysToExpire {
    return policyExpiryDate.difference(DateTime.now()).inDays;
  }

  // Factory constructor to create a Customer from a Firestore document
  factory Customer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      policyType: data['policyType'] ?? '',
      // Convert Firestore Timestamp to DateTime
      policyStartDate: (data['policyStartDate'] as Timestamp).toDate(),
      policyExpiryDate: (data['policyExpiryDate'] as Timestamp).toDate(),
      phoneNumber: data['phoneNumber'] ?? '',
      status: data['status'] ?? 'Active',
    );
  }

  // Method to convert a Customer object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'policyType': policyType,
      'policyStartDate': Timestamp.fromDate(policyStartDate),
      'policyExpiryDate': Timestamp.fromDate(policyExpiryDate),
      'phoneNumber': phoneNumber,
      'status': status,
    };
  }
}
