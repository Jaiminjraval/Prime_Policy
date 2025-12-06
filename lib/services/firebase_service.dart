import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prime_policy/models/customer.dart';


class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Customer> _customersRef;

  FirebaseService() {
    _customersRef = _firestore
        .collection('customers')
        .withConverter<Customer>(
          fromFirestore: (snapshots, _) => Customer.fromFirestore(snapshots),
          toFirestore: (customer, _) => customer.toMap(),
        );
  }

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<QuerySnapshot<Customer>> getCustomersStream() {
    return _customersRef.orderBy('name').snapshots();
  }

  Future<void> addCustomer(Customer customer) async {
    await _customersRef.add(customer);
  }

  Future<void> updateCustomer(Customer customer) async {
    await _customersRef.doc(customer.id).update(customer.toMap());
  }

  Future<void> deleteCustomer(String customerId) async {
    await _customersRef.doc(customerId).delete();
  }
}
