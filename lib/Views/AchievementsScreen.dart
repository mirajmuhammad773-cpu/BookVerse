import 'package:BookVerse/ViewModels/AchievementProvider.dart';
import 'package:BookVerse/ViewModels/ReadingGoalProvider.dart';
import 'package:BookVerse/Widgets/Achievementwidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({
    super.key,
  });

  @override
  State<AchievementScreen> createState() =>
      _AchievementScreenState();
}

class _AchievementScreenState
    extends State<AchievementScreen> {
  // ============================================================
  // CATEGORY
  // ============================================================

  String _selectedCategory = 'All';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) return;

        final provider =
            context.read<AchievementProvider>();

        if (!provider.isInitialized) {
          provider.loadAchievements();
        }
      },
    );
  }

  // ============================================================
  // FILTER ACHIEVEMENTS
  // ============================================================

  List<dynamic> _filteredAchievements(
    AchievementProvider provider,
    ReadingGoalProvider readingGoalProvider,
  ) {
    final achievements =
        provider.getAchievementsWithStreak(
      readingGoalProvider.currentStreakDays,
    );

    if (_selectedCategory == 'All') {
      return achievements;
    }

    return achievements
        .where(
          (achievement) =>
              achievement.category ==
              _selectedCategory,
        )
        .toList();
  }

  // ============================================================
  // COMPLETED BOOKS SECTION
  // ============================================================

  Widget _buildCompletedBooks(
    AchievementProvider provider,
  ) {
    final completedBookTitles =
        provider.completedBookTitles;

    if (completedBookTitles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEDE4FF),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.library_books_rounded,
                  color:
                      Color(0xFF6938EF),
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completed Books',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(0xFF202338),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Books you have completed',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Color(0xFF777B91),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEDE4FF),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  '${completedBookTitles.length}',
                  style: const TextStyle(
                    color:
                        Color(0xFF6938EF),
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ======================================================
          // BOOK LIST
          // ======================================================

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color:
                    const Color(0xFFE9E9F1),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount:
                  completedBookTitles.length,
              separatorBuilder:
                  (context, index) {
                return const Divider(
                  height: 1,
                  indent: 60,
                  endIndent: 16,
                );
              },
              itemBuilder:
                  (context, index) {
                final title =
                    completedBookTitles[index];

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFEFFAF1),
                      borderRadius:
                          BorderRadius.circular(
                        11,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color:
                          Color(0xFF4CAF50),
                      size: 21,
                    ),
                  ),
                  title: Text(
                    title,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF202338),
                    ),
                  ),
                  subtitle: const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          Color(0xFF777B91),
                    ),
                  ),
                  trailing:
                      const Icon(
                    Icons.check_circle_rounded,
                    color:
                        Color(0xFF4CAF50),
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer2<
        AchievementProvider,
        ReadingGoalProvider>(
      builder: (
        context,
        provider,
        readingGoalProvider,
        child,
      ) {
        final achievements =
            _filteredAchievements(
          provider,
          readingGoalProvider,
        );

        return Scaffold(
          backgroundColor:
              const Color(0xFFF9F9FD),
          body: SafeArea(
            child: Column(
              children: [
                // ==================================================
                // TOP BAR
                // ==================================================

                AchievementTopBar(
                  stars:
                      provider.totalStars,
                  onBack: () {
                    Navigator.maybePop(
                      context,
                    );
                  },
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
                            Color(0xFF6938EF),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      color:
                          const Color(
                        0xFF6938EF,
                      ),
                      onRefresh: () async {
                        await provider
                            .refreshAchievements();
                      },
                      child: ListView(
                        padding:
                            const EdgeInsets.only(
                          top: 4,
                          bottom: 25,
                        ),
                        children: [
                          // ==========================================
                          // HERO
                          // ==========================================

                          const AchievementHeroBanner(),

                          // ==========================================
                          // OVERALL PROGRESS
                          // ==========================================

                          OverallProgressCard(
                            completed: provider
                                .completedAchievements,
                            total: provider
                                .totalAchievements,
                            stars:
                                provider.totalStars,
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ==========================================
                          // NEXT REWARD
                          // ==========================================

                          NextRewardCard(
                            completedBooks:
                                provider
                                    .completedBooks,
                          ),

                          // ==========================================
                          // CATEGORY
                          // ==========================================

                          AchievementCategoryTabs(
                            selectedCategory:
                                _selectedCategory,
                            onCategoryChanged:
                                (category) {
                              setState(() {
                                _selectedCategory =
                                    category;
                              });
                            },
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          // ==========================================
                          // ERROR
                          // ==========================================

                          if (provider
                                  .errorMessage !=
                              null)
                            Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              child: Text(
                                provider
                                    .errorMessage!,
                                textAlign:
                                    TextAlign.center,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                          // ==========================================
                          // ACHIEVEMENTS
                          // ==========================================

                          if (achievements
                              .isEmpty)
                            const Padding(
                              padding:
                                  EdgeInsets.all(
                                40,
                              ),
                              child: Center(
                                child: Text(
                                  'No achievements found.',
                                  style:
                                      TextStyle(
                                    color:
                                        Color(
                                      0xFF666B82,
                                    ),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...achievements.map(
                              (
                                achievement,
                              ) {
                                return AchievementCard(
                                  achievement:
                                      achievement,
                                );
                              },
                            ),

                          // ==========================================
                          // COMPLETED BOOKS
                          // ==========================================

                          _buildCompletedBooks(
                            provider,
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
}