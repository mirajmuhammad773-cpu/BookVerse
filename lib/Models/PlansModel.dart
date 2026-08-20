// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  // ============================================================
  // BASIC PLAN INFO
  // ============================================================

  final String id;
  final String name;
  final String description;

  // ============================================================
  // MONTHLY
  // ============================================================

  final double monthlyPrice;

  // ============================================================
  // YEARLY
  // ============================================================

  final double yearlyPrice;

  // ============================================================
  // FEATURES
  // ============================================================

  final List<String> monthlyFeatures;
  final List<String> yearlyFeatures;

  // ============================================================
  // PLAN SETTINGS
  // ============================================================

  final bool isPopular;
  final bool isActive;

  // ============================================================
  // CURRENCY
  // ============================================================

  final String currency;

  // ============================================================
  // CREATED / UPDATED
  // ============================================================

  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  const PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.monthlyFeatures,
    required this.yearlyFeatures,
    required this.isPopular,
    required this.isActive,
    required this.currency,
    this.createdAt,
    this.updatedAt,
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  PlanModel copyWith({
    String? id,
    String? name,
    String? description,
    double? monthlyPrice,
    double? yearlyPrice,
    List<String>? monthlyFeatures,
    List<String>? yearlyFeatures,
    bool? isPopular,
    bool? isActive,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      monthlyPrice:
          monthlyPrice ?? this.monthlyPrice,
      yearlyPrice:
          yearlyPrice ?? this.yearlyPrice,
      monthlyFeatures:
          monthlyFeatures ?? this.monthlyFeatures,
      yearlyFeatures:
          yearlyFeatures ?? this.yearlyFeatures,
      isPopular:
          isPopular ?? this.isPopular,
      isActive:
          isActive ?? this.isActive,
      currency:
          currency ?? this.currency,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  // ============================================================
  // TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,

      'monthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,

      'monthlyFeatures': monthlyFeatures,
      'yearlyFeatures': yearlyFeatures,

      'isPopular': isPopular,
      'isActive': isActive,

      'currency': currency,

      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),

      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory PlanModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return PlanModel(
      id: documentId,

      name: map['name'] ?? '',

      description:
          map['description'] ?? '',

      monthlyPrice:
          _toDouble(
        map['monthlyPrice'],
      ),

      yearlyPrice:
          _toDouble(
        map['yearlyPrice'],
      ),

      monthlyFeatures:
          _toStringList(
        map['monthlyFeatures'],
      ),

      yearlyFeatures:
          _toStringList(
        map['yearlyFeatures'],
      ),

      isPopular:
          map['isPopular'] ?? false,

      isActive:
          map['isActive'] ?? true,

      currency:
          map['currency'] ?? 'usd',

      createdAt:
          _parseDate(
        map['createdAt'],
      ),

      updatedAt:
          _parseDate(
        map['updatedAt'],
      ),
    );
  }

  // ============================================================
  // FROM DOCUMENT
  // ============================================================

  factory PlanModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>>
        document,
  ) {
    final data =
        document.data() ?? {};

    return PlanModel.fromMap(
      data,
      document.id,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  static List<String> _toStringList(
    dynamic value,
  ) {
    if (value is List) {
      return value
          .map(
            (item) => item.toString(),
          )
          .toList();
    }

    return [];
  }

  static DateTime? _parseDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ============================================================
  // MONTHLY PRICE TEXT
  // ============================================================

  String get monthlyPriceText {
    return '\$${monthlyPrice.toStringAsFixed(2)}';
  }

  // ============================================================
  // YEARLY PRICE TEXT
  // ============================================================

  String get yearlyPriceText {
    return '\$${yearlyPrice.toStringAsFixed(2)}';
  }

  // ============================================================
  // FREE PLAN
  // ============================================================

  bool get isFree {
    return monthlyPrice <= 0 &&
        yearlyPrice <= 0;
  }

  // ============================================================
  // PAID PLAN
  // ============================================================

  bool get isPaid {
    return !isFree;
  }
}