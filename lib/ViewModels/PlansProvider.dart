import 'package:flutter/foundation.dart';

class PlanProvider extends ChangeNotifier {
  // ============================================================
  // BILLING CYCLE
  // 0 = Monthly
  // 1 = Yearly
  // ============================================================

  int _billingCycle = 0;

  // ============================================================
  // SELECTED PLAN
  // 0 = Free
  // 1 = Premium
  // 2 = Pro
  // ============================================================

  int _selectedPlanIndex = 1;

  // ============================================================
  // GETTERS
  // ============================================================

  int get billingCycle => _billingCycle;

  int get selectedPlanIndex =>
      _selectedPlanIndex;

  bool get isMonthly =>
      _billingCycle == 0;

  bool get isYearly =>
      _billingCycle == 1;

  // ============================================================
  // SET MONTHLY
  // ============================================================

  void setMonthly() {
    if (_billingCycle == 0) {
      return;
    }

    _billingCycle = 0;

    notifyListeners();
  }

  // ============================================================
  // SET YEARLY
  // ============================================================

  void setYearly() {
    if (_billingCycle == 1) {
      return;
    }

    _billingCycle = 1;

    notifyListeners();
  }

  // ============================================================
  // SET BILLING CYCLE
  // ============================================================

  void setBillingCycle(
    int cycle,
  ) {
    if (cycle != 0 && cycle != 1) {
      return;
    }

    if (_billingCycle == cycle) {
      return;
    }

    _billingCycle = cycle;

    notifyListeners();
  }

  // ============================================================
  // SELECT PLAN
  // ============================================================

  void selectPlan(
    int index,
  ) {
    if (index < 0 || index > 2) {
      return;
    }

    _selectedPlanIndex = index;

    notifyListeners();
  }

  // ============================================================
  // PLAN NAME
  // ============================================================

  String get selectedPlanName {
    switch (_selectedPlanIndex) {
      case 0:
        return 'Free';

      case 1:
        return 'Premium';

      case 2:
        return 'Pro';

      default:
        return 'Free';
    }
  }

  // ============================================================
  // PLAN ID
  // ============================================================

  String get selectedPlanId {
    switch (_selectedPlanIndex) {
      case 0:
        return 'free';

      case 1:
        return 'premium';

      case 2:
        return 'pro';

      default:
        return 'free';
    }
  }

  // ============================================================
  // SELECTED PRICE
  // ============================================================

  double get selectedPrice {
    // ----------------------------------------------------------
    // FREE
    // ----------------------------------------------------------

    if (_selectedPlanIndex == 0) {
      return 0.0;
    }

    // ----------------------------------------------------------
    // PREMIUM
    // ----------------------------------------------------------

    if (_selectedPlanIndex == 1) {
      return isMonthly
          ? 4.99
          : 47.99;
    }

    // ----------------------------------------------------------
    // PRO
    // ----------------------------------------------------------

    if (_selectedPlanIndex == 2) {
      return isMonthly
          ? 9.99
          : 95.99;
    }

    return 0.0;
  }

  // ============================================================
  // PRICE TEXT
  // ============================================================

  String get selectedPriceText {
    return '\$${selectedPrice.toStringAsFixed(2)}';
  }

  // ============================================================
  // BILLING TEXT
  // ============================================================

  String get billingText {
    return isMonthly
        ? 'Monthly'
        : 'Yearly';
  }

  // ============================================================
  // PERIOD TEXT
  // ============================================================

  String get periodText {
    return isMonthly
        ? '/ month'
        : '/ year';
  }

  // ============================================================
  // CURRENCY
  // ============================================================

  String get currency {
    return 'usd';
  }

  // ============================================================
  // DURATION
  // ============================================================

  int get durationInDays {
    return isMonthly ? 30 : 365;
  }

  // ============================================================
  // IS FREE
  // ============================================================

  bool get isFree {
    return _selectedPlanIndex == 0;
  }

  // ============================================================
  // IS PAID
  // ============================================================

  bool get isPaid {
    return _selectedPlanIndex != 0;
  }

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    _billingCycle = 0;

    _selectedPlanIndex = 1;

    notifyListeners();
  }
}