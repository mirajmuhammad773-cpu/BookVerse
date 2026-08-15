// lib/Screens/ReadingGoalsScreen.dart

import 'package:bookverse/ViewModels/ReadingGoalProvider.dart';
import 'package:bookverse/Widgets/ReadingGoalwidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReadingGoalsScreen extends StatefulWidget {
  const ReadingGoalsScreen({super.key});

  @override
  State<ReadingGoalsScreen> createState() =>
      _ReadingGoalsScreenState();
}

class _ReadingGoalsScreenState
    extends State<ReadingGoalsScreen> {
  // ============================================================
  // SELECTED PERIOD
  // ============================================================

  String selectedPeriod = 'Daily';

  final List<String> periods = const [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingGoalProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        return Scaffold(
          backgroundColor:
              const Color(0xFFF7F7FB),

          body: SafeArea(
            child: Column(
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    0,
                  ),
                  child: Row(
                    children: [
                      _iconButton(
                        Icons.arrow_back_rounded,
                        () {
                          Navigator.maybePop(
                            context,
                          );
                        },
                      ),

                      const SizedBox(
                        width: 60,
                      ),

                      const Text(
                        'Reading Goals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // LOADING
                // ==================================================

                if (provider.isLoading)
                  const Expanded(
                    child: Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            goalsPurple,
                      ),
                    ),
                  )

                // ==================================================
                // CONTENT
                // ==================================================

                else
                  Expanded(
                    child: RefreshIndicator(
                      color: goalsPurple,
                      onRefresh: () async {
                        await provider.refresh();
                      },
                      child: ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          16,
                          0,
                          16,
                          20,
                        ),
                        children: [
                          // ==================================================
                          // ERROR
                          // ==================================================

                          if (provider.errorMessage !=
                              null)
                            Container(
                              margin:
                                  const EdgeInsets
                                      .only(
                                bottom: 12,
                              ),
                              padding:
                                  const EdgeInsets
                                      .all(12),
                              decoration:
                                  BoxDecoration(
                                color: Colors.red
                                    .withOpacity(
                                  0.08,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    provider
                                        .errorMessage!,
                                    textAlign:
                                        TextAlign
                                            .center,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      provider
                                          .refresh();
                                    },
                                    child:
                                        const Text(
                                      'Retry',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // ==================================================
                          // HEADER CARD
                          // ==================================================

                          ReadingGoalsHeaderCard(
                            booksRead:
                                provider.booksRead,
                            yearlyGoal:
                                provider.yearlyGoal,
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ==================================================
                          // STATS
                          // ==================================================

                          ReadingStatsRow(
                            stats: [
                              StatMini(
                                icon:
                                    Icons.menu_book_rounded,
                                color:
                                    goalsPurple,
                                value:
                                    '${provider.booksRead}',
                                label:
                                    'Books Read',
                              ),

                              StatMini(
                                icon:
                                    Icons.access_time_rounded,
                                color:
                                    goalsPurple,
                                value:
                                    _formatReadingTime(
                                  provider
                                      .totalReadingMinutes,
                                ),
                                label:
                                    'Total Reading Time',
                              ),

                              StatMini(
                                icon:
                                    Icons
                                        .local_fire_department_rounded,
                                color:
                                    const Color(
                                  0xFFE53935,
                                ),
                                value:
                                    '${provider.currentStreakDays} Days',
                                label:
                                    'Current Streak',
                              ),

                              StatMini(
                                icon:
                                    Icons.star_rounded,
                                color:
                                    const Color(
                                  0xFFE8A93B,
                                ),
                                value:
                                    '${provider.monthlyGoalCurrent} / ${provider.monthlyGoalTarget}',
                                label:
                                    'Monthly Goal',
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ==================================================
                          // READING GOALS
                          // ==================================================

                          SetGoalsCard(
                            periods:
                                periods,

                            selectedPeriod:
                                selectedPeriod,

                            onPeriodChanged:
                                (period) {
                              setState(() {
                                selectedPeriod =
                                    period;
                              });
                            },

                            goalTitle:
                                _getGoalTitle(
                              selectedPeriod,
                            ),

                            goalSubtitle:
                                _getGoalSubtitle(
                              selectedPeriod,
                              provider,
                            ),

                            current:
                                _getGoalCurrent(
                              selectedPeriod,
                              provider,
                            ),

                            target:
                                _getGoalTarget(
                              selectedPeriod,
                              provider,
                            ),

                            onEditGoals: null,
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ==================================================
                          // WEEKLY READING CHART
                          // ==================================================

                          WeeklyReadingChart(
                            data:
                                provider.weeklyData,
                            onSeeDetails: () {
                              _showWeeklyDetails(
                                context,
                                provider,
                              );
                            },
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ==================================================
                          // CHALLENGES
                          // ==================================================

                          ReadingChallengesCard(
                            challenges:
                                provider.challenges,
                            onViewAll: () {
                              _showMessage(
                                'All reading challenges',
                              );
                            },
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // ==================================================
                          // QUOTE
                          // ==================================================

                          Container(
                            padding:
                                const EdgeInsets
                                    .all(16),
                            decoration:
                                BoxDecoration(
                              color: goalsPurple
                                  .withOpacity(
                                0.06,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                            ),
                            child:
                                const Column(
                              children: [
                                Text(
                                  '"Today a reader, tomorrow a leader."',
                                  textAlign:
                                      TextAlign
                                          .center,
                                  style:
                                      TextStyle(
                                    fontStyle:
                                        FontStyle
                                            .italic,
                                    fontSize: 13,
                                    color:
                                        Colors
                                            .black87,
                                  ),
                                ),

                                SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  '— Margaret Fuller',
                                  style:
                                      TextStyle(
                                    fontSize: 11,
                                    color:
                                        Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
  // GOAL TITLE
  // ============================================================

  String _getGoalTitle(
    String period,
  ) {
    switch (period) {
      case 'Weekly':
        return 'Weekly Reading Goal';

      case 'Monthly':
        return 'Monthly Reading Goal';

      case 'Yearly':
        return 'Yearly Reading Goal';

      case 'Daily':
      default:
        return 'Daily Reading Goal';
    }
  }

  // ============================================================
  // GOAL SUBTITLE
  // ============================================================

  String _getGoalSubtitle(
    String period,
    ReadingGoalProvider provider,
  ) {
    switch (period) {
      case 'Weekly':
        return 'Read ${provider.weeklyReadingTarget} minutes per week';

      case 'Monthly':
        return 'Complete ${provider.monthlyGoalTarget} books this month';

      case 'Yearly':
        return 'Read ${provider.yearlyGoal} books this year';

      case 'Daily':
      default:
        return 'Read ${provider.dailyGoalTarget} minutes per day';
    }
  }

  // ============================================================
  // CURRENT VALUE
  // ============================================================

  int _getGoalCurrent(
    String period,
    ReadingGoalProvider provider,
  ) {
    switch (period) {
      case 'Weekly':
        return provider.weeklyReadingMinutes;

      case 'Monthly':
        return provider.monthlyGoalCurrent;

      case 'Yearly':
        return provider.booksRead;

      case 'Daily':
      default:
        return provider.dailyGoalCurrent;
    }
  }

  // ============================================================
  // TARGET VALUE
  // ============================================================

  int _getGoalTarget(
    String period,
    ReadingGoalProvider provider,
  ) {
    switch (period) {
      case 'Weekly':
        return provider.weeklyReadingTarget;

      case 'Monthly':
        return provider.monthlyGoalTarget;

      case 'Yearly':
        return provider.yearlyGoal;

      case 'Daily':
      default:
        return provider.dailyGoalTarget;
    }
  }

  // ============================================================
  // FORMAT READING TIME
  // ============================================================

  String _formatReadingTime(
    int totalMinutes,
  ) {
    final hours =
        totalMinutes ~/ 60;

    final minutes =
        totalMinutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    }

    if (minutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${minutes}m';
  }

  // ============================================================
  // WEEKLY DETAILS
  // ============================================================

  void _showWeeklyDetails(
    BuildContext context,
    ReadingGoalProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // TITLE
                // ==================================================

                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets
                              .all(9),
                      decoration:
                          BoxDecoration(
                        color:
                            goalsPurple
                                .withOpacity(
                          0.10,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .access_time_rounded,
                        color:
                            goalsPurple,
                        size: 20,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    const Expanded(
                      child: Text(
                        'Weekly Reading',
                        style:
                            TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },
                      icon:
                          const Icon(
                        Icons
                            .close_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                // ==================================================
                // WEEK DATA
                // ==================================================

                ...provider.weeklyData
                    .map(
                  (day) {
                    return Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 7,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 45,
                            child: Text(
                              day.label,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w600,
                                fontSize:
                                    13,
                              ),
                            ),
                          ),

                          Expanded(
                            child:
                                ClipRRect(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                              child:
                                  LinearProgressIndicator(
                                value:
                                    provider.weeklyReadingTarget >
                                            0
                                        ? (day.minutes /
                                                provider
                                                    .weeklyReadingTarget)
                                            .clamp(
                                            0.0,
                                            1.0,
                                          )
                                        : 0,
                                minHeight:
                                    7,
                                backgroundColor:
                                    Colors.grey
                                        .withOpacity(
                                  0.12,
                                ),
                                color:
                                    goalsPurple,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          SizedBox(
                            width: 42,
                            child:
                                Text(
                              '${day.minutes}m',
                              textAlign:
                                  TextAlign
                                      .right,
                              style:
                                  const TextStyle(
                                fontSize:
                                    12,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(
                  height: 10,
                ),

                // ==================================================
                // TOTAL
                // ==================================================

                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .all(14),
                  decoration:
                      BoxDecoration(
                    color:
                        goalsPurple
                            .withOpacity(
                      0.06,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      const Text(
                        'Total this week',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                      Text(
                        '${provider.weeklyReadingMinutes} minutes',
                        style:
                            const TextStyle(
                          color:
                              goalsPurple,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ICON BUTTON
  // ============================================================

  Widget _iconButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.all(8),
        decoration:
            BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          behavior:
              SnackBarBehavior
                  .floating,
          duration:
              const Duration(
            seconds: 2,
          ),
        ),
      );
  }
}