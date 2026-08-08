// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xffF7F8FC);

  static const card = Colors.white;

  static const primary = Color(0xff12C7E8);

  static const text = Color(0xff222222);

  static const subtitle = Color(0xff7A7A7A);

  static const logout = Color(0xffFF4F67);

  static const divider = Color(0xffECECEC);
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class SettingsSectionCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsSectionCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(children: children),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: Switch(
        value: value,
        activeColor: Colors.white,
        activeTrackColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}

class SettingsArrowTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const SettingsArrowTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class LogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(
        Icons.logout_rounded,
        color: AppColors.logout,
      ),
      title: const Text(
        "Logout",
        style: TextStyle(
          color: AppColors.logout,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}