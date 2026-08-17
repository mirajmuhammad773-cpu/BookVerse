// lib/Screens/ProfileScreen.dart

// ignore_for_file: file_names, prefer_const_constructors

import 'package:bookverse/Views/AchievementsScreen.dart';
import 'package:bookverse/Views/DownloadBook.dart';
import 'package:bookverse/Views/PaymentHistory.dart';
import 'package:bookverse/Views/ReadingGoalscreen.dart';
import 'package:bookverse/Views/ReadingHistory.dart';
import 'package:bookverse/Views/SettingScreen.dart';
import 'package:bookverse/ViewModels/FavoriteBookProvider.dart';
import 'package:bookverse/ViewModels/ReadingGoalProvider.dart';
import 'package:bookverse/Widgets/Profilewidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ============================================================
  // READING TIME FORMAT
  // ============================================================

  String _formatReadingTime(
    ReadingGoalProvider provider,
  ) {
    final hours = provider.totalReadingHours;
    final minutes = provider.totalReadingMinutesRemainder;

    // ----------------------------------------------------------
    // Less than one hour
    // ----------------------------------------------------------

    if (hours == 0) {
      return '${minutes}m';
    }

    // ----------------------------------------------------------
    // Full hours only
    // ----------------------------------------------------------

    if (minutes == 0) {
      return '${hours}h';
    }

    // ----------------------------------------------------------
    // Hours + minutes
    // ----------------------------------------------------------

    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366F1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              24,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                ProfileHeaderCard(
                  name: 'Miraj',
                  tagline: 'Book Lover 📚',
                  avatarUrl:
                      'https://i.pravatar.cc/150?img=12',
                  onEditProfile: () {},
                ),

                const SizedBox(height: 14),

                // ==================================================
                // PROFILE STATS
                // ==================================================

                Consumer2<
                    ReadingGoalProvider,
                    FavouriteBooksProvider>(
                  builder: (
                    context,
                    readingGoalProvider,
                    favouriteProvider,
                    child,
                  ) {
                    return ProfileStatsCard(
                      stats: [
                        // ------------------------------------------------
                        // BOOKS READ
                        // ------------------------------------------------

                        ProfileStat(
                          'Books Read',
                          readingGoalProvider.booksRead
                              .toString(),
                        ),

                        // ------------------------------------------------
                        // READING TIME
                        // ------------------------------------------------

                        ProfileStat(
                          'Reading Time',
                          _formatReadingTime(
                            readingGoalProvider,
                          ),
                        ),

                        // ------------------------------------------------
                        // BOOKMARKS
                        // ------------------------------------------------

                        ProfileStat(
                          'Bookmarks',
                          favouriteProvider.favoriteCount
                              .toString(),
                        ),

                        // ------------------------------------------------
                        // CURRENT STREAK
                        // ------------------------------------------------

                        ProfileStat(
                          'Current Streak',
                          readingGoalProvider
                              .currentStreakDays
                              .toString(),
                          suffix: 'Days',
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 14),

                // ==================================================
                // MENU LIST
                // ==================================================

                ProfileMenuList(
                  items: [
                    // ------------------------------------------------
                    // SUBSCRIPTION
                    // ------------------------------------------------

                    ProfileMenuData(
                      icon:
                          Icons.workspace_premium_rounded,
                      iconColor:
                          const Color(0xFFF59E0B),
                      label: 'My Subscription',
                      subtitle: 'Premium Plan',
                      onTap: () {},
                    ),

                    // ------------------------------------------------
                    // READING GOALS
                    // ------------------------------------------------

                    ProfileMenuData(
                      icon:
                          Icons.favorite_rounded,
                      iconColor:
                          const Color(0xFFEC4899),
                      label: 'Reading Goals',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReadingGoalsScreen(),
                          ),
                        );
                      },
                    ),

                    // ------------------------------------------------
                    // ACHIEVEMENTS
                    // ------------------------------------------------

                    ProfileMenuData(
                      icon:
                          Icons.emoji_events_rounded,
                      iconColor:
                          const Color(0xFF8B5CF6),
                      label: 'Achievements',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AchievementScreen(),
                          ),
                        );
                      },
                    ),

                    // ------------------------------------------------
                    // DOWNLOADS
                    // ------------------------------------------------

                    ProfileMenuData(
                      icon:
                          Icons.download_rounded,
                      iconColor:
                          const Color(0xFF3B82F6),
                      label: 'Downloads',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DownloadedBooksScreen(),
                          ),
                        );
                      },
                    ),

                    // ------------------------------------------------
                    // READING HISTORY
                    // ------------------------------------------------

                    ProfileMenuData(
                      icon:
                          Icons.history_rounded,
                      iconColor:
                          const Color(0xFF06B6D4),
                      label: 'Reading History',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReadingHistoryScreen(),
                          ),
                        );
                      },
                    ),

                    // ------------------------------------------------
                    // PAYMENT HISTORY
                    // ------------------------------------------------

                    ProfileMenuData(
                      icon:
                          Icons.receipt_long_rounded,
                      iconColor:
                          const Color(0xFF10B981),
                      label: 'Payment History',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PaymentHistoryScreen(),
                          ),
                        );
                      },
                    ),

                    // ------------------------------------------------
                    // HELP & SUPPORT
                    // ------------------------------------------------

                    ProfileMenuData(
                      icon:
                          Icons.help_outline_rounded,
                      iconColor:
                          const Color(0xFF6366F1),
                      label: 'Help & Support',
                      onTap: () {},
                    ),

                    // ------------------------------------------------
                    // SETTINGS
                    // ------------------------------------------------

                    ProfileMenuData(
                      icon:
                          Icons.settings_rounded,
                      iconColor:
                          const Color(0xFF64748B),
                      label: 'Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}