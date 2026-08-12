// lib/Widgets/AchievementWidgets.dart

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../Models/AchievementModel.dart';

// ================================================================
// TOP BAR
// ================================================================

class AchievementTopBar extends StatelessWidget {
  final int stars;
  final VoidCallback onBack;

  const AchievementTopBar({
    super.key,
    required this.stars,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        5,
        20,
        8,
      ),
      child: Row(
        children: [
          // ========================================================
          // BACK BUTTON
          // ========================================================

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF101638),
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 18),

          // ========================================================
          // TITLE
          // ========================================================

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0E1535),
                  ),
                ),
              ],
            ),
          ),

          // ========================================================
          // TOTAL STARS / POINTS
          // ========================================================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: Color(0xFFFFB300),
                  size: 25,
                ),
                const SizedBox(width: 7),
                Text(
                  '$stars',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6938EF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// HERO BANNER
// ================================================================

class AchievementHeroBanner extends StatelessWidget {
  const AchievementHeroBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        16,
      ),
      padding: const EdgeInsets.all(24),
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3EDFF),
            Color(0xFFE9E1FF),
          ],
        ),
        border: Border.all(
          color: Color(0xFFE0D4FF),
        ),
      ),
      child: Row(
        children: [
          // ========================================================
          // TEXT
          // ========================================================

          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Read more.\nGrow more.',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101638),
                  ),
                ),
                SizedBox(height:10),
                Text(
                  'Complete achievements, earn\nstars and unlock new milestones.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF454B70),
                  ),
                ),
              ],
            ),
          ),

          // ========================================================
          // ICONS
          // ========================================================

          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 8,
                  child: Icon(
                    Icons.auto_stories_rounded,
                    size: 100,
                    color: Color(0xFF7044E8),
                  ),
                ),
                const Positioned(
                  top: 0,
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 75,
                    color: Color(0xFFFFAA00),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// OVERALL PROGRESS
// ================================================================

class OverallProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final int stars;

  const OverallProgressCard({
    super.key,
    required this.completed,
    required this.total,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        total == 0 ? 0.0 : completed / total;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          // ========================================================
          // CIRCULAR PROGRESS
          // ========================================================

          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 105,
                  height: 105,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor:
                        const Color(0xFFE9E8F0),
                    valueColor:
                        const AlwaysStoppedAnimation(
                      Color(0xFF6938EF),
                    ),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF101638),
                      ),
                    ),
                    const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF59607E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // ========================================================
          // PROGRESS INFORMATION
          // ========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Progress',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101638),
                  ),
                ),

                const SizedBox(height: 12),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$completed / $total ',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6938EF),
                        ),
                      ),
                      const TextSpan(
                        text: 'Achievements completed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF59607E),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor:
                        const Color(0xFFE9E8F0),
                    valueColor:
                        const AlwaysStoppedAnimation(
                      Color(0xFF6938EF),
                    ),
                  ),
                ),

                const SizedBox(height: 7),

                // ==================================================
                // TOTAL EARNED POINTS
                // ==================================================

                Text(
                  '$stars Stars earned',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF737993),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// CATEGORY FILTER
// ================================================================

class AchievementCategoryTabs extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const AchievementCategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const categories = [
    'All',
    'Reading',
    'Streaks',
    'Collection',
    'Social',
    'Special',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];

          final selected =
              selectedCategory == category;

          return GestureDetector(
            onTap: () {
              onCategoryChanged(category);
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF6938EF)
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(30),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF6938EF)
                      : const Color(0xFFE5E4ED),
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF42486C),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================================================================
// ACHIEVEMENT CARD
// ================================================================

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementCard({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final progress = achievement.progress;

    return Container(
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 10,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // ========================================================
          // ICON
          // ========================================================

          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: achievement.iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.iconColor,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // ========================================================
          // INFORMATION
          // ========================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101638),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  achievement.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF59607E),
                  ),
                ),

                const SizedBox(height: 13),

                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value:
                              progress.clamp(0.0, 1.0),
                          minHeight: 7,
                          backgroundColor:
                              const Color(0xFFE9E8F0),
                          valueColor:
                              AlwaysStoppedAnimation(
                            achievement.isCompleted
                                ? const Color(0xFF19B65A)
                                : const Color(0xFF6938EF),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      '${achievement.current}/${achievement.target}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5E647D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ========================================================
          // REWARD
          // ========================================================

          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: achievement.isCompleted
                  ? const Color(0xFFEAFBF0)
                  : const Color(0xFFFFFAF2),
              borderRadius:
                  BorderRadius.circular(17),
              border: Border.all(
                color: achievement.isCompleted
                    ? const Color(0xFFCDEFD9)
                    : const Color(0xFFF4EBDD),
              ),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  achievement.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.stars_rounded,
                  color: achievement.isCompleted
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFFFAA00),
                  size: 20,
                ),

                const SizedBox(height: 3),

                Text(
                  '${achievement.reward}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: achievement.isCompleted
                        ? const Color(0xFF159447)
                        : const Color(0xFF101638),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// NEXT REWARD CARD
// ================================================================

class NextRewardCard extends StatelessWidget {
  final int completedBooks;

  const NextRewardCard({
    super.key,
    required this.completedBooks,
  });

  @override
  Widget build(BuildContext context) {
    int nextBooks;

    if (completedBooks < 5) {
      nextBooks = 5;
    } else if (completedBooks < 10) {
      nextBooks = 10;
    } else if (completedBooks < 25) {
      nextBooks = 25;
    } else {
      nextBooks = 50;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        6,
        20,
        14,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE7E1F7),
        ),
      ),
      child: Row(
        children: [
          // ========================================================
          // ICON
          // ========================================================

          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E9FF),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Color(0xFF6938EF),
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          // ========================================================
          // TEXT
          // ========================================================

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Next Reward',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6938EF),
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                '$nextBooks books milestone',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101638),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}