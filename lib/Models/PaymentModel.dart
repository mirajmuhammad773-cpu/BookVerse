// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String userId;

  final String planId;
  final String planName;
  final String billingCycle;

  final double amount;
  final String currency;

  final String status;

  final String? paymentIntentId;
  final String? stripeCustomerId;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.billingCycle,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentIntentId,
    this.stripeCustomerId,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory PaymentModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return PaymentModel(
      id: document.id,
      userId: data['userId']?.toString() ?? '',
      planId: data['planId']?.toString() ?? '',
      planName: data['planName']?.toString() ?? '',
      billingCycle:
          data['billingCycle']?.toString() ?? 'monthly',
      amount: _toDouble(data['amount']),
      currency:
          data['currency']?.toString().toLowerCase() ?? 'usd',
      status: data['status']?.toString() ?? 'pending',
      paymentIntentId:
          data['paymentIntentId']?.toString(),
      stripeCustomerId:
          data['stripeCustomerId']?.toString(),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  // ============================================================
  // TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'planId': planId,
      'planName': planName,
      'billingCycle': billingCycle,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentIntentId': paymentIntentId,
      'stripeCustomerId': stripeCustomerId,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  PaymentModel copyWith({
    String? id,
    String? userId,
    String? planId,
    String? planName,
    String? billingCycle,
    double? amount,
    String? currency,
    String? status,
    String? paymentIntentId,
    String? stripeCustomerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      billingCycle: billingCycle ?? this.billingCycle,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentIntentId:
          paymentIntentId ?? this.paymentIntentId,
      stripeCustomerId:
          stripeCustomerId ?? this.stripeCustomerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}