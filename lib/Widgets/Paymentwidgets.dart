// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

const _primary = Color(0xFF6366F1);
const _secondary = Color(0xFF8B5CF6);
const _cardBg = Color(0xFFF6F6F9);
const _cardBorder = Color(0xFFECECF2);

/// PremiumPlanSummaryCard
/// The purple/indigo gradient card at the top showing which plan is
/// being paid for, its perks, and the price.
class PremiumPlanSummaryCard extends StatelessWidget {
  final String planName;
  final String subscriptionLabel;
  final List<String> perks;
  final String price;
  final String priceSuffix;

  const PremiumPlanSummaryCard({
    super.key,
    required this.planName,
    required this.subscriptionLabel,
    required this.perks,
    required this.price,
    required this.priceSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_primary, _secondary]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: _primary.withOpacity(0.28), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(planName, style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subscriptionLabel, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: perks
                      .map((p) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(p, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(color: Color(0xFFFACC15), fontSize: 18, fontWeight: FontWeight.bold)),
              Text(priceSuffix, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple data model for one payment method row.
class PaymentMethodOption {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String brandText;

  const PaymentMethodOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.brandText,
  });
}

/// PaymentMethodTile
/// A single selectable payment method row — radio dot, icon, title,
/// subtitle, and a small brand label on the right. Built as its own
/// widget so the payment method list can call it once per method.
class PaymentMethodTile extends StatelessWidget {
  final PaymentMethodOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? _secondary : _cardBorder, width: isSelected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? _secondary : Colors.grey.shade400, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: _secondary),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: option.iconColor.withOpacity(0.14), borderRadius: BorderRadius.circular(10)),
              child: Icon(option.icon, color: option.iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(option.subtitle, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                ],
              ),
            ),
            Text(option.brandText, style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// TotalAmountRow
/// The small row above the Pay button showing the total amount.
class TotalAmountRow extends StatelessWidget {
  final String amount;

  const TotalAmountRow({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: _primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.receipt_long_rounded, color: _primary, size: 17),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.black87)),
                Text('Inclusive of all taxes', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(color: Color(0xFFCA8A04), fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}



class PaymentConfirmingDialog extends StatelessWidget {
  const PaymentConfirmingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF6366F1)),
            SizedBox(height: 18),
            Text(
              'Payment confirm ho rahi hai...',              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Chand seconds intezaar karein',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}