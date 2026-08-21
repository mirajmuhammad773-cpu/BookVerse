import 'package:BookVerse/Widgets/PaymentHistoryWidget.dart';
import 'package:flutter/material.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  static const _primary = Color(0xFF6366F1);

  int _selectedFilter = 0;
  final _filters = const ['All', 'Successful', 'Pending', 'Failed'];

  final List<PaymentHistoryData> _transactions = const [
    PaymentHistoryData(
      icon: Icons.menu_book_rounded,
      iconColor: Color(0xFF16A34A),
      title: 'Premium Membership',
      date: 'May 20, 2024',
      time: '10:30 AM',
      amount: '\$29.99',
      status: 'Paid',
    ),
    PaymentHistoryData(
      icon: Icons.diamond_rounded,
      iconColor: Color(0xFF8B5CF6),
      title: 'Gold Plan',
      date: 'May 15, 2024',
      time: '04:45 PM',
      amount: '\$59.99',
      status: 'Paid',
    ),
    PaymentHistoryData(
      icon: Icons.import_contacts_rounded,
      iconColor: Color(0xFFF59E0B),
      title: 'The Alchemist (E-book)',
      date: 'May 12, 2024',
      time: '11:20 AM',
      amount: '\$4.99',
      status: 'Paid',
    ),
    PaymentHistoryData(
      icon: Icons.card_giftcard_rounded,
      iconColor: Color(0xFFEC4899),
      title: 'Referral Bonus',
      date: 'May 10, 2024',
      time: '09:15 AM',
      amount: '-\$5.00',
      status: 'Credited',
      isCredit: true,
    ),
    PaymentHistoryData(
      icon: Icons.diamond_rounded,
      iconColor: Color(0xFF8B5CF6),
      title: 'Silver Plan',
      date: 'May 05, 2024',
      time: '03:30 PM',
      amount: '\$19.99',
      status: 'Paid',
    ),
    PaymentHistoryData(
      icon: Icons.local_offer_rounded,
      iconColor: Color(0xFFEF4444),
      title: 'Buy 3 Books Offer',
      date: 'May 01, 2024',
      time: '08:10 PM',
      amount: '\$12.99',
      status: 'Paid',
    ),
    PaymentHistoryData(
      icon: Icons.access_time_rounded,
      iconColor: Color(0xFFF59E0B),
      title: 'Pending Payment',
      date: 'Apr 30, 2024',
      time: '06:25 PM',
      amount: '\$29.99',
      status: 'Pending',
    ),
    PaymentHistoryData(
      icon: Icons.close_rounded,
      iconColor: Color(0xFFEF4444),
      title: 'Transaction Failed',
      date: 'Apr 28, 2024',
      time: '02:40 PM',
      amount: '\$9.99',
      status: 'Failed',
    ),
  ];

  List<PaymentHistoryData> get _visibleTransactions {
    if (_selectedFilter == 0) return _transactions;
    final label = _filters[_selectedFilter];
    if (label == 'Successful') {
      return _transactions.where((t) => t.status == 'Paid' || t.status == 'Credited').toList();
    }
    return _transactions.where((t) => t.status == label).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent = _transactions
        .where((t) => !t.isCredit)
        .fold<double>(0, (sum, t) => sum + (double.tryParse(t.amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  const Expanded(
                    child: Text(
                      'Payment History',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded, color: Colors.black87),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  // Summary card, called from its own file.
                  PaymentSummaryCard(
                    totalSpent: '\$${totalSpent.toStringAsFixed(2)}',
                    transactionCount: _transactions.length + 10, // matches "18 transactions" style demo total
                  ),

                  const SizedBox(height: 18),

                  // Filter chips
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilter == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? _primary : const Color(0xFFF3F3F7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _filters[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black54,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Transaction list — the SAME PaymentHistoryItem
                  // widget, called again for each entry with different
                  // arguments.
                  if (_visibleTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('No transactions here.', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    for (final tx in _visibleTransactions)
                      PaymentHistoryItem(data: tx, onTap: () {}),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}