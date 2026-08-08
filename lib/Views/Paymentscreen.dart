// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:bookverse/Widgets/Paymentwidgets.dart';
import 'package:flutter/material.dart';

class SecurePaymentScreen extends StatefulWidget {
  const SecurePaymentScreen({super.key});

  @override
  State<SecurePaymentScreen> createState() => _SecurePaymentScreenState();
}

class _SecurePaymentScreenState extends State<SecurePaymentScreen> {
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

  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderNameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  void _showRequestSentDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [_primary, _secondary]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Your request send the admin\nafter admin approval inform you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Close the popup first...
                      Navigator.of(dialogContext).pop();
                      // ...then go back from the Secure Payment screen
                      // to the previous screen.
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      elevation: 0,
                    ),
                    child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background white, as requested — design pattern otherwise unchanged.
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: const Color(0xFFF6F6F9), borderRadius: BorderRadius.circular(12)),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: const [
                        Text('Secure Payment', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text('Complete your subscription', style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [_primary, _secondary]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_rounded, color: Colors.white, size: 17),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PremiumPlanSummaryCard(
                      planName: 'Premium Plan',
                      subscriptionLabel: '1 Year Subscription',
                      perks: ['∞ Unlimited Books', '🚫 No Ads'],
                      price: '\$ 47.99',
                      priceSuffix: 'per year',
                    ),

                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select Payment Method', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Row(
                          children: const [
                            Icon(Icons.lock_outline_rounded, size: 12, color: Colors.grey),
                            SizedBox(width: 4),
                            Text('100% Secure Payment', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    for (int i = 0; i < _paymentMethods.length; i++)
                      PaymentMethodTile(
                        option: _paymentMethods[i],
                        isSelected: _selectedMethod == i,
                        onTap: () => setState(() => _selectedMethod = i),
                      ),

                    const SizedBox(height: 10),

                    // Card Details form — only relevant when Card is
                    // the selected payment method.
                    if (_selectedMethod == 0) ...[
                      const Text('Card Details', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                      _cardField(
                        controller: _cardNumberController,
                        hint: '1234 5678 9012 3456',
                        icon: Icons.credit_card_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _cardField(
                              controller: _expiryController,
                              hint: 'MM / YY',
                              icon: Icons.calendar_today_rounded,
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _cardField(
                              controller: _cvvController,
                              hint: '123',
                              icon: Icons.shield_outlined,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _cardField(
                        controller: _holderNameController,
                        hint: 'John Doe',
                        icon: Icons.person_outline_rounded,
                        label: 'Card Holder Name',
                      ),
                      const SizedBox(height: 18),
                    ],

                    const TotalAmountRow(amount: '\$ 47.99'),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Pay button
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_primary, _secondary]),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _showRequestSentDialog,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Pay \$ 47.99 Securely', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Your payment information is encrypted and secure',
                style: TextStyle(fontSize: 10.5, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECECF2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(fontSize: 13.5, color: Colors.black87),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}