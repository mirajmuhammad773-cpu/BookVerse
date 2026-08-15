// lib/Screens/AchievementScreen.dart

import 'package:bookverse/ViewModels/AchievementProvider.dart';
import 'package:bookverse/Widgets/Achievementwidget.dart';
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

class _AchievementScreenState extends State<AchievementScreen> {
  String _selectedCategory = 'All';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAchievementData();
    });
  }

  // ============================================================
  // LOAD BACKEND DATA
  // ============================================================

  Future<void> _loadAchievementData() async {
    final provider =
        context.read<AchievementProvider>();

    await provider.loadAchievements();
  }

  // ============================================================
  // FILTER ACHIEVEMENTS
  // ============================================================

  List<dynamic> _filteredAchievements(
    AchievementProvider provider,
  ) {
    if (_selectedCategory == 'All') {
      return provider.achievements;
    }

    return provider.achievements
        .where(
          (achievement) =>
              achievement.category ==
              _selectedCategory,
        )
        .toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementProvider>(
      builder: (
        context,
        achievementProvider,
        child,
      ) {
        final achievements =
            _filteredAchievements(
          achievementProvider,
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
                      achievementProvider.totalStars,
                  onBack: () {
                    Navigator.maybePop(context);
                  },
                ),

                // ==================================================
                // LOADING
                // ==================================================

                if (achievementProvider.isLoading)
                  const Expanded(
                    child: Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            Color(0xFF6938EF),
                      ),
                    ),
                  )

                // ==================================================
                // CONTENT
                // ==================================================

                else
                  Expanded(
                    child: ListView(
                      padding:
                          const EdgeInsets.only(
                        top: 4,
                        bottom: 25,
                      ),
                      children: [

                        // ==================================================
                        // HERO BANNER
                        // ==================================================

                        const AchievementHeroBanner(),

                        // ==================================================
                        // OVERALL PROGRESS
                        // ==================================================

                        OverallProgressCard(
                          completed:
                              achievementProvider
                                  .completedAchievements,
                          total:
                              achievementProvider
                                  .totalAchievements,
                          stars:
                              achievementProvider
                                  .totalStars,
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // ==================================================
                        // NEXT REWARD
                        // ==================================================

                        NextRewardCard(
                          completedBooks:
                              achievementProvider
                                  .completedBooks,
                        ),

                        // ==================================================
                        // CATEGORY FILTER
                        // ==================================================

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

                        // ==================================================
                        // ERROR
                        // ==================================================

                        if (achievementProvider
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
                              achievementProvider
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

                        // ==================================================
                        // ACHIEVEMENT LIST
                        // ==================================================

                        if (achievements.isEmpty)
                          const Padding(
                            padding:
                                EdgeInsets.all(40),
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
                            (achievement) {
                              return AchievementCard(
                                achievement:
                                    achievement,
                              );
                            },
                          ),
                      ],
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