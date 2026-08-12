// ignore_for_file: file_names, prefer_const_constructors

import 'package:bookverse/Views/AchievementsScreen.dart';
import 'package:bookverse/Views/DownloadBook.dart';
import 'package:bookverse/Views/PaymentHistory.dart';
import 'package:bookverse/Views/ReadingGoalscreen.dart';
import 'package:bookverse/Views/ReadingHistory.dart';
import 'package:bookverse/Views/SettingScreen.dart';
import 'package:bookverse/Widgets/Profilewidget.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [ Color(0xFF6366F1),Colors.white],
      ),
    ),
     child:  SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Header widget, called from its own file ----
              ProfileHeaderCard(
                name: 'Miraj',
                tagline: 'Book Lover 📚',
                avatarUrl: 'https://i.pravatar.cc/150?img=12',
                onEditProfile: () {},
              ),

              // FIX: no more Transform.translate overlap - the reference
              // design shows the stats card sitting cleanly BELOW the
              // header with a normal gap, not overlapping into it.
              const SizedBox(height: 14),
              ProfileStatsCard(
                stats: const [
                  ProfileStat('Books Read', '24'),
                  ProfileStat('Reading Time', '128h'),
                  ProfileStat('Bookmarks', '36'),
                  ProfileStat('Current Streak', '12', suffix: 'Days'),
                ],
              ),

              const SizedBox(height: 14),

              // ---- Menu list widget, called from its own file ----
              ProfileMenuList(
                items: [
                  ProfileMenuData(
                    icon: Icons.workspace_premium_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'My Subscription',
                    subtitle: 'Premium Plan',
                    onTap: () {},
                  ),
                  ProfileMenuData(
                    icon: Icons.favorite_rounded,
                    iconColor: const Color(0xFFEC4899),
                    label: 'Reading Goals',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ReadingGoalsScreen()));
                    },
                  ),
                  ProfileMenuData(
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    label: 'Achievements',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>AchievementScreen()));
                    },
                  ),
                  ProfileMenuData(
                    icon: Icons.download_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    label: 'Downloads',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>DownloadedBooksScreen()));
                    },
                  ),
                  ProfileMenuData(
                    icon: Icons.history_rounded,
                    iconColor: const Color(0xFF06B6D4),
                    label: 'Reading History',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ReadingHistoryScreen()));
                    },
                  ),
                  ProfileMenuData(
                    icon: Icons.receipt_long_rounded,
                    iconColor: const Color(0xFF10B981),
                    label: 'Payment History',
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentHistoryScreen()));
                    },
                  ),
                  ProfileMenuData(
                    icon: Icons.help_outline_rounded,
                    iconColor: const Color(0xFF6366F1),
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                  ProfileMenuData(
                    icon: Icons.settings_rounded,
                    iconColor: const Color(0xFF64748B),
                    label: 'Settings',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
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