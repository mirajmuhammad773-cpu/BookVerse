// ignore_for_file: deprecated_member_use, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';



/// Simple data model for one stat in the stats row (Books Read,
/// Reading Time, Bookmarks, Current Streak).
class ProfileStat {
  final String label;
  final String value;
  final String? suffix; // e.g. 'Days' for the streak
  const ProfileStat(this.label, this.value, {this.suffix});
}

/// Simple data model for one row in the settings/menu list.
class ProfileMenuData {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle; // e.g. 'Premium Plan' under My Subscription
  final String? trailingText; // e.g. '12 / 28' for Achievements
  final VoidCallback? onTap;

  const ProfileMenuData({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    this.trailingText,
    this.onTap,
  });
}

/// ProfileHeaderCard
class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String tagline;
  final String avatarUrl;
  final VoidCallback? onEditProfile;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.tagline,
    required this.avatarUrl,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Decorative sparkle glow, top-right
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white70, size: 26),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIX: solid white ring (was Colors.white24, which blended
              // into the purple background instead of standing out crisp
              // white like the reference).
              Container(
                width: 74,
                height: 74,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white24,
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tagline,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onEditProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Edit Profile',
                              style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 12.5),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF6366F1)),
                          ],
                        ),
                      ),
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

/// ProfileStatsCard
class ProfileStatsCard extends StatelessWidget {
  final List<ProfileStat> stats;

  const ProfileStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            if (i != 0) Container(width: 1, height: 34, color: Colors.grey.shade200),
            Expanded(child: _statColumn(stats[i])),
          ],
        ],
      ),
    );
  }

  Widget _statColumn(ProfileStat stat) {
    return Column(
      children: [
        Text(stat.label, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            children: [
              TextSpan(text: stat.value),
              if (stat.suffix != null)
                TextSpan(
                  text: ' ${stat.suffix}',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ProfileMenuList
class ProfileMenuList extends StatelessWidget {
  final List<ProfileMenuData> items;

  const ProfileMenuList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _ProfileMenuRow(item: items[i]),
            if (i != items.length - 1) Divider(height: 1, color: Colors.grey.shade100, indent: 56),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  final ProfileMenuData item;
  const _ProfileMenuRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: item.iconColor.withOpacity(0.14), borderRadius: BorderRadius.circular(10)),
              child: Icon(item.icon, color: item.iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(item.subtitle!, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                  ],
                ],
              ),
            ),
            if (item.trailingText != null) ...[
              Text(item.trailingText!, style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}