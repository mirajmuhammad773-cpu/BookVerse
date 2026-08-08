import 'package:flutter/material.dart';

/// Simple data model for one subscription plan.
class PlanData {
  final String name;
  final String price;
  final String period; // e.g. '/ month' or '/ year'
  final List<String> features;
  final bool isPopular;

  const PlanData({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
  });
}

/// PlanCard
/// A single subscription plan card — name, price, an optional "Most
/// Popular" badge, a feature checklist, and a radio-style selector on
/// the right. Built as its own widget so the Plans screen can call it
/// once per plan (Free / Premium / Pro), just by passing a
/// [PlanData] and whether it's currently selected.
///
/// Usage:
/// PlanCard(plan: myPlan, isSelected: true, onTap: () => ...)
class PlanCard extends StatelessWidget {
  final PlanData plan;
  final bool isSelected;
  final VoidCallback onTap;

  static const _gradient = LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]);

  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    if (plan.isPopular) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF6366F1)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Most Popular',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
                _RadioDot(isSelected: isSelected),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  plan.price,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(width: 4),
                Text(plan.period, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            for (final feature in plan.features)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_rounded, size: 16, color: Color(0xFF8B5CF6)),
                    const SizedBox(width: 8),
                    Text(feature, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool isSelected;
  const _RadioDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade400, width: 2),
        color: Colors.white,
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: PlanCard._gradient),
              ),
            )
          : null,
    );
  }
}