import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/PaymentModel.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  CollectionReference<Map<String, dynamic>> get _paymentsCollection {
    return _firestore.collection('payments');
  }

  User get _currentUser {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }
    return user;
  }

  String get currentUserId => _currentUser.uid;

  Future<String> createPaymentRecord({
    required String planId,
    required String planName,
    required String billingCycle,
    required double amount,
    required String currency,
  }) async {
    try {
      final document = _paymentsCollection.doc();

      final payment = PaymentModel(
        id: document.id,
        userId: currentUserId,
        planId: planId,
        planName: planName,
        billingCycle: billingCycle,
        amount: amount,
        currency: currency.toLowerCase(),
        status: 'pending',
      );

      await document.set(payment.toMap());
      return document.id;
    } catch (e) {
      throw Exception('Unable to create payment record: $e');
    }
  }

  Future<Map<String, dynamic>> createStripePaymentIntent({
    required String paymentId,
    required String planId,
    required String planName,
    required String billingCycle,
    required double amount,
    required String currency,
  }) async {
    try {
      final callable = _functions.httpsCallable('createPaymentIntent');

      final result = await callable.call({
        'paymentId': paymentId,
        'planId': planId,
        'planName': planName,
        'billingCycle': billingCycle,
        'amount': amount,
        'currency': currency.toLowerCase(),
      });

      return Map<String, dynamic>.from(result.data as Map);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Unable to create Stripe payment.');
    } catch (e) {
      throw Exception('Stripe payment initialization failed: $e');
    }
  }

  Future<PaymentModel?> getPayment(String paymentId) async {
    try {
      final document = await _paymentsCollection.doc(paymentId).get();
      if (!document.exists) return null;
      return PaymentModel.fromDocument(document);
    } catch (e) {
      throw Exception('Unable to get payment: $e');
    }
  }

  // ============================================================
  // WATCH SINGLE PAYMENT
  // Webhook se status change hote hi yeh real-time notify karega.
  // ============================================================
  Stream<PaymentModel?> watchPayment(String paymentId) {
    return _paymentsCollection.doc(paymentId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PaymentModel.fromDocument(doc);
    });
  }

  Future<List<PaymentModel>> getUserPayments() async {
    try {
      final snapshot = await _paymentsCollection
          .where('userId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((document) => PaymentModel.fromDocument(document)).toList();
    } catch (e) {
      throw Exception('Unable to load payment history: $e');
    }
  }

  Stream<List<PaymentModel>> watchUserPayments() {
    return _paymentsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) => PaymentModel.fromDocument(document)).toList();
    });
  }

  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
  }) async {
    try {
      await _paymentsCollection.doc(paymentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Unable to update payment status: $e');
    }
  }

  Future<void> deletePayment(String paymentId) async {
    try {
      await _paymentsCollection.doc(paymentId).delete();
    } catch (e) {
      throw Exception('Unable to delete payment: $e');
    }
  }

  Future<void> cancelPendingPayment(String paymentId) async {
    try {
      await _paymentsCollection.doc(paymentId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Unable to cancel payment: $e');
    }
  }
}