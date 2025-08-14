class Customer {
  final String id;
  final String name;
  final String policyType;
  final DateTime policyStartDate;
  final DateTime policyExpiryDate;
  final String phoneNumber;

  Customer({
    required this.id,
    required this.name,
    required this.policyType,
    required this.policyStartDate,
    required this.policyExpiryDate,
    required this.phoneNumber,
  });

  // Helper to check if the policy is expiring soon (e.g., within 30 days)
  bool get isExpiringSoon {
    return policyExpiryDate.difference(DateTime.now()).inDays <= 30 &&
           policyExpiryDate.isAfter(DateTime.now());
  }

  // Helper to get the number of days until expiry
  int get daysToExpire {
    return policyExpiryDate.difference(DateTime.now()).inDays;
  }
}
