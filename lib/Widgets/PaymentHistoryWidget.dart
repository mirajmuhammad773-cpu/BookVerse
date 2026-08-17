// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

const _primary = Color(0xFF6366F1);
const _secondary = Color(0xFF8B5CF6);

/// PaymentSummaryCard
/// The purple gradient card showing total spent, transaction count,
/// and a decorative wallet illustration.
class PaymentSummaryCard extends StatelessWidget {
  final String totalSpent;
  final int transactionCount;

  const PaymentSummaryCard({
    super.key,
    required this.totalSpent,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 22, offset: const Offset(0, 12))],
      ),
      child: Stack(
        children: [
          // Decorative sparkles
          const Positioned(top: 4, right: 70, child: Icon(Icons.auto_awesome_rounded, color: Colors.white38, size: 14)),
          const Positioned(bottom: 30, right: 20, child: Icon(Icons.auto_awesome_rounded, color: Colors.white38, size: 12)),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Spent', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(totalSpent, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Across $transactionCount transactions', style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                  ],
                ),
              ),
              // Wallet illustration approximated with icons/shapes.
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 62,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      child: Container(
                        width: 46,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 10,
                      right: 8,
                      child: Icon(Icons.circle, color: Color(0xFFFACC15), size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple data model for one payment/transaction entry.
class PaymentHistoryData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String date;
  final String time;
  final String amount;
  final bool isCredit; // true = green (+), false amount still shown as-is
  final String status; // 'Paid', 'Credited', 'Pending', 'Failed'

  const PaymentHistoryData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
    required this.time,
    required this.amount,
    required this.status,
    this.isCredit = false,
  });
}

/// PaymentHistoryItem
/// A single row in the payment history list — icon, title, date/time,
/// amount, and a status pill. Built as its own widget so the screen
/// can call it once per transaction, just by passing a
/// [PaymentHistoryData].
class PaymentHistoryItem extends StatelessWidget {
  final PaymentHistoryData data;
  final VoidCallback? onTap;

  const PaymentHistoryItem({super.key, required this.data, this.onTap});

  Color get _statusColor {
    switch (data.status) {
      case 'Paid':
      case 'Credited':
        return const Color(0xFF16A34A);
      case 'Pending':
        return const Color(0xFFD97706);
      case 'Failed':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFEFF4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: data.iconColor.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
              child: Icon(data.icon, color: data.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 3),
                  Text('${data.date}  •  ${data.time}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data.amount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.status,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}