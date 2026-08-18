import 'package:flutter/foundation.dart';

import '../Models/PaymentModel.dart';
import '../Repository/PaymentRepository.dart';

class PaymentProvider extends ChangeNotifier {
  // ============================================================
  // REPOSITORY
  // ============================================================

  final PaymentRepository _repository =
      PaymentRepository();

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = false;

  bool _isProcessing = false;

  bool _paymentSuccess = false;

  String? _errorMessage;

  String? _paymentId;

  PaymentModel? _currentPayment;

  List<PaymentModel> _payments = [];

  // Stripe PaymentIntent data
  String? _clientSecret;

  String? _customerId;

  String? _ephemeralKey;

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isLoading => _isLoading;

  bool get isProcessing => _isProcessing;

  bool get paymentSuccess => _paymentSuccess;

  String? get errorMessage => _errorMessage;

  String? get paymentId => _paymentId;

  PaymentModel? get currentPayment =>
      _currentPayment;

  List<PaymentModel> get payments =>
      List.unmodifiable(_payments);

  String? get clientSecret =>
      _clientSecret;

  String? get customerId =>
      _customerId;

  String? get ephemeralKey =>
      _ephemeralKey;

  bool get hasError =>
      _errorMessage != null;

  // ============================================================
  // SET LOADING
  // ============================================================

  void _setLoading(bool value) {
    _isLoading = value;

    notifyListeners();
  }

  // ============================================================
  // SET PROCESSING
  // ============================================================

  void _setProcessing(bool value) {
    _isProcessing = value;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // INITIALIZE PAYMENT
  //
  // This does:
  //
  // 1. Creates Firebase payment record
  // 2. Calls Cloud Function
  // 3. Gets Stripe PaymentIntent client secret
  //
  // IMPORTANT:
  // Stripe Secret Key is NOT used in Flutter.
  // ============================================================

  Future<bool> initializePayment({
    required String planId,
    required String planName,
    required String billingCycle,
    required double amount,
    required String currency,
  }) async {
    _setProcessing(true);

    _errorMessage = null;

    _paymentSuccess = false;

    _paymentId = null;

    _currentPayment = null;

    _clientSecret = null;

    _customerId = null;

    _ephemeralKey = null;

    try {
      // ----------------------------------------------------------
      // FREE PLAN CHECK
      // ----------------------------------------------------------

      if (amount <= 0) {
        throw Exception(
          'Free plan does not require payment.',
        );
      }

      // ----------------------------------------------------------
      // STEP 1
      // CREATE FIREBASE PAYMENT RECORD
      // ----------------------------------------------------------

      final paymentId =
          await _repository
              .createPaymentRecord(
        planId: planId,
        planName: planName,
        billingCycle: billingCycle,
        amount: amount,
        currency: currency,
      );

      _paymentId = paymentId;

      // ----------------------------------------------------------
      // STEP 2
      // CALL FIREBASE CLOUD FUNCTION
      // ----------------------------------------------------------

      final stripeData =
          await _repository
              .createStripePaymentIntent(
        paymentId: paymentId,
        planId: planId,
        planName: planName,
        billingCycle: billingCycle,
        amount: amount,
        currency: currency,
      );

      // ----------------------------------------------------------
      // STEP 3
      // GET STRIPE DATA
      // ----------------------------------------------------------

      _clientSecret =
          stripeData['clientSecret']
              ?.toString();

      _customerId =
          stripeData['customerId']
              ?.toString();

      _ephemeralKey =
          stripeData['ephemeralKey']
              ?.toString();

      // ----------------------------------------------------------
      // VALIDATE CLIENT SECRET
      // ----------------------------------------------------------

      if (_clientSecret == null ||
          _clientSecret!.isEmpty) {
        throw Exception(
          'Stripe client secret was not returned.',
        );
      }

      // ----------------------------------------------------------
      // LOAD PAYMENT
      // ----------------------------------------------------------

      _currentPayment =
          await _repository.getPayment(
        paymentId,
      );

      return true;
    } catch (e) {
      _errorMessage =
          _cleanError(
        e.toString(),
      );

      return false;
    } finally {
      _setProcessing(false);
    }
  }

  // ============================================================
  // PAYMENT COMPLETED
  //
  // This should be called after Stripe SDK confirms the payment.
  //
  // Final payment verification should still happen through
  // Stripe webhook / Cloud Function.
  // ============================================================

  Future<bool> markPaymentCompleted() async {
    if (_paymentId == null) {
      _errorMessage =
          'Payment ID is missing.';

      notifyListeners();

      return false;
    }

    _setProcessing(true);

    _errorMessage = null;

    try {
      await _repository.updatePaymentStatus(
        paymentId: _paymentId!,
        status: 'processing',
      );

      _paymentSuccess = true;

      await loadPayment(
        _paymentId!,
      );

      return true;
    } catch (e) {
      _errorMessage =
          _cleanError(
        e.toString(),
      );

      return false;
    } finally {
      _setProcessing(false);
    }
  }

  // ============================================================
  // PAYMENT FAILED
  // ============================================================

  Future<void> markPaymentFailed() async {
    if (_paymentId == null) {
      return;
    }

    try {
      await _repository.updatePaymentStatus(
        paymentId: _paymentId!,
        status: 'failed',
      );

      await loadPayment(
        _paymentId!,
      );
    } catch (e) {
      _errorMessage =
          _cleanError(
        e.toString(),
      );

      notifyListeners();
    }
  }

  // ============================================================
  // LOAD PAYMENT
  // ============================================================

  Future<void> loadPayment(
    String paymentId,
  ) async {
    _setLoading(true);

    _errorMessage = null;

    try {
      _currentPayment =
          await _repository.getPayment(
        paymentId,
      );
    } catch (e) {
      _errorMessage =
          _cleanError(
        e.toString(),
      );
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // LOAD USER PAYMENT HISTORY
  // ============================================================

  Future<void> loadUserPayments() async {
    _setLoading(true);

    _errorMessage = null;

    try {
      _payments =
          await _repository
              .getUserPayments();
    } catch (e) {
      _errorMessage =
          _cleanError(
        e.toString(),
      );
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // UPDATE PAYMENT STATUS
  // ============================================================

  Future<bool> updatePaymentStatus({
    required String paymentId,
    required String status,
  }) async {
    _setProcessing(true);

    _errorMessage = null;

    try {
      await _repository.updatePaymentStatus(
        paymentId: paymentId,
        status: status,
      );

      await loadPayment(
        paymentId,
      );

      return true;
    } catch (e) {
      _errorMessage =
          _cleanError(
        e.toString(),
      );

      return false;
    } finally {
      _setProcessing(false);
    }
  }

  // ============================================================
  // CANCEL PAYMENT
  // ============================================================

  Future<bool> cancelPayment() async {
    if (_paymentId == null) {
      return false;
    }

    _setProcessing(true);

    _errorMessage = null;

    try {
      await _repository
          .cancelPendingPayment(
        _paymentId!,
      );

      await loadPayment(
        _paymentId!,
      );

      return true;
    } catch (e) {
      _errorMessage =
          _cleanError(
        e.toString(),
      );

      return false;
    } finally {
      _setProcessing(false);
    }
  }

  // ============================================================
  // RESET PAYMENT STATE
  // ============================================================

  void reset() {
    _isLoading = false;

    _isProcessing = false;

    _paymentSuccess = false;

    _errorMessage = null;

    _paymentId = null;

    _currentPayment = null;

    _clientSecret = null;

    _customerId = null;

    _ephemeralKey = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAN ERROR
  // ============================================================

  String _cleanError(
    String error,
  ) {
    return error.replaceFirst(
      'Exception: ',
      '',
    );
  }
}