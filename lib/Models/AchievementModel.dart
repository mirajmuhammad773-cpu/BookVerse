// lib/Models/AchievementModel.dart

// ignore_for_file: file_names

import 'package:flutter/material.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;

  final int current;
  final int target;
  final int reward;

  final String category;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.current,
    required this.target,
    required this.reward,
    required this.category,
  });

  double get progress {
    if (target <= 0) return 0;

    final value = current / target;

    if (value > 1) return 1;

    return value;
  }

  bool get isCompleted => current >= target;
}