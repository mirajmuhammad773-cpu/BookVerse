import 'package:bookverse/ViewModels/PlansProvider.dart';
import 'package:bookverse/Views/Paymentscreen.dart';
import 'package:bookverse/Widgets/Planscardwidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChoosePlanScreen extends StatefulWidget {
  const ChoosePlanScreen({super.key});

  @override
  State<ChoosePlanScreen> createState() =>
      _ChoosePlanScreenState();
}

class _ChoosePlanScreenState
    extends State<ChoosePlanScreen> {

  // ============================================================
  // MONTHLY PLANS
  // ============================================================

  static const _monthlyPlans = [
    PlanData(
      name: 'Free',
      price: '\$0',
      period: '/ month',
      features: [
        '1 Books / Month',
        'Standard Quality',
        'Basic Support',
      ],
    ),

    PlanData(
      name: 'Premium',
      price: '\$4.99',
      period: '/ month',
      isPopular: true,
      features: [
        'Unlimited Books',
        'High Quality',
        'Offline Reading',
        'Priority Support',
      ],
    ),

    PlanData(
      name: 'Pro',
      price: '\$9.99',
      period: '/ month',
      features: [
        'Everything in Premium',
        'Audiobooks',
        'Cloud Sync',
        'Early Access',
      ],
    ),
  ];

  // ============================================================
  // YEARLY PLANS
  // ============================================================

  static const _yearlyPlans = [
    PlanData(
      name: 'Free',
      price: '\$0',
      period: '/ year',
      features: [
        '5 Books / Month',
        'Standard Quality',
        'Basic Support',
      ],
    ),

    PlanData(
      name: 'Premium',
      price: '\$47.99',
      period: '/ year',
      isPopular: true,
      features: [
        'Unlimited Books',
        'High Quality',
        'Offline Reading',
        'Priority Support',
      ],
    ),

    PlanData(
      name: 'Pro',
      price: '\$95.99',
      period: '/ year',
      features: [
        'Everything in Premium',
        'Audiobooks',
        'Cloud Sync',
        'Early Access',
      ],
    ),
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        final currentPlans =
            provider.isMonthly
                ? _monthlyPlans
                : _yearlyPlans;

        return Scaffold(
          backgroundColor: Colors.white,

          body: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // ==================================================
                  // HEADER
                  // ==================================================

                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Unlock unlimited stories',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // MONTHLY / YEARLY TOGGLE
                  // ==================================================

                  Container(
                    padding:
                        const EdgeInsets.all(4),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFF1F1F5,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),
                    ),

                    child: Row(
                      children: [

                        Expanded(
                          child: _cycleTab(
                            label: 'Monthly',
                            index: 0,
                            provider:
                                provider,
                          ),
                        ),

                        Expanded(
                          child: _cycleTab(
                            label: 'Yearly',
                            suffix:
                                '(save 20%)',
                            index: 1,
                            provider:
                                provider,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // PLANS
                  // ==================================================

                  Expanded(
                    child:
                        ListView.separated(
                      itemCount:
                          currentPlans.length,

                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                        height: 14,
                      ),

                      itemBuilder:
                          (context, index) {

                        final plan =
                            currentPlans[index];

                        return PlanCard(
                          plan: plan,

                          isSelected:
                              index ==
                                  provider
                                      .selectedPlanIndex,

                          onTap: () {
                            provider
                                .selectPlan(
                              index,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // CONTINUE
                  // ==================================================

                  SizedBox(
                    width:
                        double.infinity,

                    height: 54,

                    child: Container(
                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          28,
                        ),
                      ),

                      child: Material(
                        color:
                            Colors.transparent,

                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(
                            28,
                          ),

                          onTap: () {
                            _continue(
                              context,
                              provider,
                            );
                          },

                          child:
                              const Center(
                            child: Text(
                              'Continue',

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.w700,
                                fontSize:
                                    15.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MONTHLY / YEARLY TAB
  // ============================================================

  Widget _cycleTab({
    required String label,
    String? suffix,
    required int index,
    required PlanProvider provider,
  }) {
    final isSelected =
        provider.billingCycle ==
            index;

    return GestureDetector(
      onTap: () {
        provider.setBillingCycle(
          index,
        );
      },

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),

        padding:
            const EdgeInsets.symmetric(
          vertical: 11,
        ),

        decoration:
            BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                )
              : null,

          borderRadius:
              BorderRadius.circular(
            26,
          ),
        ),

        child: Center(
          child: RichText(
            text: TextSpan(
              children: [

                TextSpan(
                  text: label,

                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.black54,

                    fontWeight:
                        FontWeight.w600,

                    fontSize: 13.5,
                  ),
                ),

                if (suffix != null)
                  TextSpan(
                    text:
                        ' $suffix',

                    style:
                        TextStyle(
                      color: isSelected
                          ? Colors.white70
                          : Colors.grey,

                      fontWeight:
                          FontWeight.w500,

                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTINUE TO PAYMENT
  // ============================================================

  void _continue(
    BuildContext context,
    PlanProvider provider,
  ) {
    // ------------------------------------------------------------
    // FREE PLAN
    // ------------------------------------------------------------

    if (provider.isFree) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Free plan selected.',
          ),
        ),
      );

      return;
    }

    // ------------------------------------------------------------
    // PAID PLAN
    // ------------------------------------------------------------

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SecurePaymentScreen(
          planId:
              provider.selectedPlanId,

          planName:
              provider.selectedPlanName,

          billingCycle:
              provider.billingText,

          amount:
              provider.selectedPrice,

          currency:
              provider.currency,
        ),
      ),
    );
  }
}