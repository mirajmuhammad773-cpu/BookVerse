import 'package:flutter/foundation.dart';

// ============================================================
// SINGLE SOURCE OF TRUTH FOR ALL PLANS
// Price, id, features — sab yahin se aata hai. UI aur payment
// dono isi se data lete hain, taake kabhi mismatch na ho.
// ============================================================

class PlanDetails {
  final String id;
  final String name;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> monthlyFeatures;
  final List<String> yearlyFeatures;
  final bool isPopular;

  const PlanDetails({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.monthlyFeatures,
    required this.yearlyFeatures,
    this.isPopular = false,
  });
}

class PlanProvider extends ChangeNotifier {
  // ============================================================
  // PLANS DATA — yahan edit karein agar price/features change karni ho
  // ============================================================

  static const List<PlanDetails> plans = [
    PlanDetails(
      id: 'free',
      name: 'Free',
      monthlyPrice: 0.0,
      yearlyPrice: 0.0,
      monthlyFeatures: ['1 Books / Month', 'Standard Quality', 'Basic Support'],
      yearlyFeatures: ['5 Books / Month', 'Standard Quality', 'Basic Support'],
    ),
    PlanDetails(
      id: 'premium',
      name: 'Premium',
      monthlyPrice: 4.99,
      yearlyPrice: 47.99,
      isPopular: true,
      monthlyFeatures: ['Unlimited Books', 'High Quality', 'Offline Reading', 'Priority Support'],
      yearlyFeatures: ['Unlimited Books', 'High Quality', 'Offline Reading', 'Priority Support'],
    ),
    PlanDetails(
      id: 'pro',
      name: 'Pro',
      monthlyPrice: 9.99,
      yearlyPrice: 95.99,
      monthlyFeatures: ['Everything in Premium', 'Audiobooks', 'Cloud Sync', 'Early Access'],
      yearlyFeatures: ['Everything in Premium', 'Audiobooks', 'Cloud Sync', 'Early Access'],
    ),
  ];

  // ============================================================
  // BILLING CYCLE — 0 = Monthly, 1 = Yearly
  // ============================================================

  int _billingCycle = 0;

  // ============================================================
  // SELECTED PLAN — 0 = Free, 1 = Premium, 2 = Pro
  // ============================================================

  int _selectedPlanIndex = 1;

  // ============================================================
  // GETTERS
  // ============================================================

  int get billingCycle => _billingCycle;
  int get selectedPlanIndex => _selectedPlanIndex;
  bool get isMonthly => _billingCycle == 0;
  bool get isYearly => _billingCycle == 1;

  PlanDetails get selectedPlan => plans[_selectedPlanIndex];

  // ============================================================
  // SET BILLING CYCLE
  // ============================================================

  void setMonthly() => setBillingCycle(0);
  void setYearly() => setBillingCycle(1);

  void setBillingCycle(int cycle) {
    if (cycle != 0 && cycle != 1) return;
    if (_billingCycle == cycle) return;
    _billingCycle = cycle;
    notifyListeners();
  }

  // ============================================================
  // SELECT PLAN
  // ============================================================

  void selectPlan(int index) {
    if (index < 0 || index >= plans.length) return;
    _selectedPlanIndex = index;
    notifyListeners();
  }

  // ============================================================
  // PLAN NAME / ID
  // ============================================================

  String get selectedPlanName => selectedPlan.name;
  String get selectedPlanId => selectedPlan.id;

  // ============================================================
  // SELECTED PRICE
  // ============================================================

  double get selectedPrice {
    return isMonthly ? selectedPlan.monthlyPrice : selectedPlan.yearlyPrice;
  }

  String get selectedPriceText => '\$${selectedPrice.toStringAsFixed(2)}';

  // ============================================================
  // BILLING TEXT
  // ⚠️ FIX: lowercase honi zaroori hai — SecurePaymentScreen aur
  // Cloud Function dono 'monthly' / 'yearly' (lowercase) expect karte hain.
  // ============================================================

  String get billingText => isMonthly ? 'monthly' : 'yearly';

  String get periodText => isMonthly ? '/ month' : '/ year';

  String get currency => 'usd';

  int get durationInDays => isMonthly ? 30 : 365;

  bool get isFree => _selectedPlanIndex == 0;
  bool get isPaid => _selectedPlanIndex != 0;

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    _billingCycle = 0;
    _selectedPlanIndex = 1;
    notifyListeners();
  }
}