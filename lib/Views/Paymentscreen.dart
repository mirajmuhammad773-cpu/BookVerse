// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:bookverse/Widgets/Paymentwidgets.dart';
import 'package:bookverse/ViewModels/PaymentProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

class SecurePaymentScreen extends StatefulWidget {
  final String planId;
  final String planName;
  final String billingCycle;
  final double amount;
  final String currency;

  const SecurePaymentScreen({
    super.key,
    required this.planId,
    required this.planName,
    required this.billingCycle,
    required this.amount,
    required this.currency,
  });

  @override
  State<SecurePaymentScreen> createState() =>
      _SecurePaymentScreenState();
}

class _SecurePaymentScreenState
    extends State<SecurePaymentScreen> {
  static const _primary = Color(0xFF6366F1);
  static const _secondary = Color(0xFF8B5CF6);

  int _selectedMethod = 0;

  final _paymentMethods = const [
    PaymentMethodOption(
      icon: Icons.credit_card_rounded,
      iconColor: _primary,
      title: 'Credit / Debit Card',
      subtitle: 'Visa, Mastercard, Rupay',
      brandText: 'VISA  ●●',
    ),
    PaymentMethodOption(
      icon: Icons.account_balance_wallet_rounded,
      iconColor: Color(0xFFF97316),
      title: 'UPI',
      subtitle: 'Google Pay, PhonePe, Paytm',
      brandText: 'UPI',
    ),
    PaymentMethodOption(
      icon: Icons.wallet_rounded,
      iconColor: Color(0xFF22C55E),
      title: 'Digital Wallet',
      subtitle: 'JazzCash, Easypaisa',
      brandText: 'JazzCash',
    ),
    PaymentMethodOption(
      icon: Icons.account_balance_rounded,
      iconColor: _secondary,
      title: 'Net Banking',
      subtitle: 'All Major Banks',
      brandText: '50+ Banks',
    ),
  ];

  final _cardNumberController =
      TextEditingController();

  final _expiryController =
      TextEditingController();

  final _cvvController =
      TextEditingController();

  final _holderNameController =
      TextEditingController();

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();

    super.dispose();
  }

  // ============================================================
  // START PAYMENT
  // ============================================================

  Future<void> _startPayment() async {
    if (widget.amount <= 0) {
      _showError(
        'This plan does not require payment.',
      );
      return;
    }

    // ----------------------------------------------------------
    // CURRENTLY STRIPE PAYMENT SHEET IS USED FOR CARD PAYMENT.
    //
    // JazzCash / Easypaisa / UPI / Bank options require a Stripe
    // payment method supported and enabled on your Stripe account.
    // ----------------------------------------------------------

    if (_selectedMethod != 0) {
      _showError(
        'This payment method is not connected to Stripe yet. '
        'For testing, please select Credit / Debit Card.',
      );

      return;
    }

    final provider =
        context.read<PaymentProvider>();

    try {
      // --------------------------------------------------------
      // SHOW LOADING
      // --------------------------------------------------------

      _showLoading();

      // --------------------------------------------------------
      // 1. CREATE FIREBASE PAYMENT
      // 2. CREATE STRIPE PAYMENT INTENT
      // --------------------------------------------------------

      final initialized =
          await provider.initializePayment(
        planId: widget.planId,
        planName: widget.planName,
        billingCycle: widget.billingCycle,
        amount: widget.amount,
        currency: widget.currency,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();

      if (!initialized) {
        _showError(
          provider.errorMessage ??
              'Unable to initialize payment.',
        );

        return;
      }

      final clientSecret =
          provider.clientSecret;

      if (clientSecret == null ||
          clientSecret.isEmpty) {
        _showError(
          'Stripe payment information was not received.',
        );

        return;
      }

      // --------------------------------------------------------
      // INITIALIZE STRIPE PAYMENT SHEET
      // --------------------------------------------------------

      await Stripe.instance
          .initPaymentSheet(
        paymentSheetParameters:
            SetupPaymentSheetParameters(
          paymentIntentClientSecret:
              clientSecret,

          merchantDisplayName:
              'BookVerse',

          style:
              ThemeMode.light,

          allowsDelayedPaymentMethods:
              false,

          billingDetails:
              BillingDetails(
            name:
                _holderNameController
                    .text
                    .trim(),
          ),
        ),
      );

      // --------------------------------------------------------
      // OPEN STRIPE PAYMENT SHEET
      // --------------------------------------------------------

      await Stripe.instance
          .presentPaymentSheet();

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // PAYMENT SUCCESS UI
      // --------------------------------------------------------

      await provider
          .markPaymentCompleted();

      if (!mounted) {
        return;
      }

      _showPaymentSuccessDialog();
    } on StripeException catch (e) {
      if (mounted) {
        _showError(
          e.error.localizedMessage ??
              'Payment was cancelled or failed.',
        );
      }

      await provider
          .markPaymentFailed();
    } catch (e) {
      if (mounted) {
        _showError(
          e.toString().replaceFirst(
                'Exception: ',
                '',
              ),
        );
      }

      await provider
          .markPaymentFailed();
    }
  }

  // ============================================================
  // LOADING DIALOG
  // ============================================================

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor:
          Colors.black.withOpacity(0.45),
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(
            color: _primary,
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor:
          Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor:
              Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: Container(
            padding:
                const EdgeInsets.fromLTRB(
              24,
              32,
              24,
              22,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration:
                      const BoxDecoration(
                    gradient:
                        LinearGradient(
                      colors: [
                        _primary,
                        _secondary,
                      ],
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Payment Successful',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${widget.planName} plan payment has been submitted successfully.',
                  textAlign:
                      TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        dialogContext,
                      ).pop();

                      Navigator.of(
                        context,
                      ).pop(true);
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          _primary,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 13,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          26,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child:
                        const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final amountText =
        '${widget.currency.toUpperCase()} '
        '${widget.amount.toStringAsFixed(2)}';

    final subscriptionLabel =
        widget.billingCycle ==
                'monthly'
            ? '1 Month Subscription'
            : '1 Year Subscription';

    final priceSuffix =
        widget.billingCycle ==
                'monthly'
            ? 'per month'
            : 'per year';

    return Scaffold(
      backgroundColor:
          Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                8,
                16,
                8,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF6F6F9,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                    child:
                        IconButton(
                      padding:
                          EdgeInsets.zero,
                      onPressed:
                          () => Navigator
                              .maybePop(
                        context,
                      ),
                      icon:
                          const Icon(
                        Icons
                            .arrow_back,
                        color:
                            Colors
                                .black87,
                        size: 18,
                      ),
                    ),
                  ),

                  Expanded(
                    child:
                        Column(
                      children: const [
                        Text(
                          'Secure Payment',
                          style:
                              TextStyle(
                            fontSize:
                                17,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                Colors
                                    .black87,
                          ),
                        ),
                        Text(
                          'Complete your subscription',
                          style:
                              TextStyle(
                            fontSize:
                                11.5,
                            color:
                                Colors
                                    .grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 38,
                    height: 38,
                    decoration:
                        const BoxDecoration(
                      gradient:
                          LinearGradient(
                        colors: [
                          _primary,
                          _secondary,
                        ],
                      ),
                      shape:
                          BoxShape.circle,
                    ),
                    child:
                        const Icon(
                      Icons
                          .lock_rounded,
                      color:
                          Colors.white,
                      size: 17,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // BODY
            // ==================================================

            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 18,
                ),
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    // ------------------------------------------
                    // PLAN SUMMARY
                    // ------------------------------------------

                    PremiumPlanSummaryCard(
                      planName:
                          widget.planName,
                      subscriptionLabel:
                          subscriptionLabel,
                      perks: const [
                        '∞ Unlimited Books',
                        '🚫 No Ads',
                      ],
                      price:
                          amountText,
                      priceSuffix:
                          priceSuffix,
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // ------------------------------------------
                    // PAYMENT METHODS
                    // ------------------------------------------

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Text(
                          'Select Payment Method',
                          style:
                              TextStyle(
                            fontSize:
                                14.5,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                Colors
                                    .black87,
                          ),
                        ),

                        Row(
                          children: const [
                            Icon(
                              Icons
                                  .lock_outline_rounded,
                              size: 12,
                              color:
                                  Colors
                                      .grey,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              '100% Secure Payment',
                              style:
                                  TextStyle(
                                fontSize:
                                    10.5,
                                color:
                                    Colors
                                        .grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    for (
                      int i = 0;
                      i <
                          _paymentMethods
                              .length;
                      i++
                    )
                      PaymentMethodTile(
                        option:
                            _paymentMethods[
                                i],
                        isSelected:
                            _selectedMethod ==
                                i,
                        onTap: () {
                          setState(
                            () {
                              _selectedMethod =
                                  i;
                            },
                          );
                        },
                      ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ------------------------------------------
                    // CARD DETAILS
                    // ------------------------------------------

                    if (_selectedMethod ==
                        0) ...[
                      const Text(
                        'Card Details',
                        style:
                            TextStyle(
                          fontSize:
                              14.5,
                          fontWeight:
                              FontWeight
                                  .bold,
                          color:
                              Colors
                                  .black87,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _cardField(
                        controller:
                            _cardNumberController,
                        hint:
                            '1234 5678 9012 3456',
                        icon:
                            Icons
                                .credit_card_rounded,
                        keyboardType:
                            TextInputType
                                .number,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                _cardField(
                              controller:
                                  _expiryController,
                              hint:
                                  'MM / YY',
                              icon:
                                  Icons
                                      .calendar_today_rounded,
                              keyboardType:
                                  TextInputType
                                      .datetime,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                _cardField(
                              controller:
                                  _cvvController,
                              hint:
                                  '123',
                              icon:
                                  Icons
                                      .shield_outlined,
                              keyboardType:
                                  TextInputType
                                      .number,
                              obscureText:
                                  true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _cardField(
                        controller:
                            _holderNameController,
                        hint:
                            'John Doe',
                        icon:
                            Icons
                                .person_outline_rounded,
                        label:
                            'Card Holder Name',
                      ),

                      const SizedBox(
                        height: 18,
                      ),
                    ],

                    // ------------------------------------------
                    // TOTAL
                    // ------------------------------------------

                    TotalAmountRow(
                      amount:
                          amountText,
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // PAY BUTTON
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                0,
                18,
                18,
              ),
              child:
                  SizedBox(
                width:
                    double.infinity,
                height: 54,
                child:
                    Container(
                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        _primary,
                        _secondary,
                      ],
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      28,
                    ),
                  ),
                  child:
                      Material(
                    color:
                        Colors.transparent,
                    child:
                        InkWell(
                      borderRadius:
                          BorderRadius
                              .circular(
                        28,
                      ),
                      onTap:
                          _startPayment,
                      child:
                          Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          const Icon(
                            Icons
                                .lock_rounded,
                            color:
                                Colors
                                    .white,
                            size: 16,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Text(
                            'Pay $amountText Securely',
                            style:
                                const TextStyle(
                              color:
                                  Colors
                                      .white,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              fontSize:
                                  15,
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          const Icon(
                            Icons
                                .arrow_forward_rounded,
                            color:
                                Colors
                                    .white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Padding(
              padding:
                  EdgeInsets.only(
                bottom: 10,
              ),
              child: Text(
                'Your payment information is encrypted and secure',
                style:
                    TextStyle(
                  fontSize:
                      10.5,
                  color:
                      Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD FIELD
  // ============================================================

  Widget _cardField({
    required TextEditingController
        controller,
    required String hint,
    required IconData icon,
    String? label,
    TextInputType keyboardType =
        TextInputType.text,
    bool obscureText = false,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF6F6F9),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border:
            Border.all(
          color:
              const Color(0xFFECECF2),
        ),
      ),
      child:
          Row(
        children: [
          Icon(
            icon,
            size: 18,
            color:
                Colors.grey,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child:
                TextField(
              controller:
                  controller,
              keyboardType:
                  keyboardType,
              obscureText:
                  obscureText,
              style:
                  const TextStyle(
                fontSize:
                    13.5,
                color:
                    Colors
                        .black87,
              ),
              decoration:
                  InputDecoration(
                labelText:
                    label,
                hintText:
                    hint,
                hintStyle:
                    const TextStyle(
                  color:
                      Colors.grey,
                  fontSize:
                      13,
                ),
                border:
                    InputBorder.none,
                isDense:
                    true,
                contentPadding:
                    const EdgeInsets
                        .symmetric(
                  vertical:
                      14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}