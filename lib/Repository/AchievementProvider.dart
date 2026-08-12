// lib/Providers/AchievementProvider.dart

import 'package:flutter/material.dart';
import 'package:bookverse/Models/BookModel.dart';
import '../Models/AchievementModel.dart';

class AchievementProvider extends ChangeNotifier {
  // ============================================================
  // READING DATA
  // ============================================================

  int _completedBooks = 0;

  // Total earned points
  int _points = 0;

  // Books which have already been completed
  final Set<int> _completedBookIds = {};

  // Achievements for which reward has already been given
  final Set<String> _rewardedAchievementIds = {};

  // ============================================================
  // GETTERS
  // ============================================================

  int get completedBooks => _completedBooks;

  int get points => _points;

  // UI is currently using totalStars.
  // Stars = Total Points
  int get totalStars => _points;

  Set<int> get completedBookIds =>
      Set.unmodifiable(_completedBookIds);

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  List<AchievementModel> get achievements {
    return [
      AchievementModel(
        id: 'first_chapter',
        title: 'First Chapter',
        description: 'Read your first book',
        icon: Icons.menu_book_rounded,
        iconBackgroundColor: const Color(0xFFEDE4FF),
        iconColor: const Color(0xFF6938EF),
        current: _completedBooks >= 1 ? 1 : 0,
        target: 1,
        reward: 150,
        category: 'Reading',
      ),

      AchievementModel(
        id: 'book_explorer',
        title: 'Book Explorer',
        description: 'Read 3 books',
        icon: Icons.auto_stories_rounded,
        iconBackgroundColor: const Color(0xFFE3F1FF),
        iconColor: const Color(0xFF2979FF),
        current: _completedBooks.clamp(0, 3),
        target: 3,
        reward: 300,
        category: 'Reading',
      ),

      const AchievementModel(
        id: 'reading_streak',
        title: 'Reading Streak',
        description: 'Read for 7 days in a row',
        icon: Icons.local_fire_department_rounded,
        iconBackgroundColor: Color(0xFFFFE7D8),
        iconColor: Color(0xFFFF721B),
        current: 0,
        target: 7,
        reward: 150,
        category: 'Streaks',
      ),

      const AchievementModel(
        id: 'daily_reader',
        title: 'Daily Reader',
        description: 'Read for 15 days',
        icon: Icons.calendar_month_rounded,
        iconBackgroundColor: Color(0xFFEAE4FF),
        iconColor: Color(0xFF6C3CF5),
        current: 0,
        target: 15,
        reward: 200,
        category: 'Streaks',
      ),

      AchievementModel(
        id: 'avid_reader',
        title: 'Avid Reader',
        description: 'Read 10 books',
        icon: Icons.emoji_events_rounded,
        iconBackgroundColor: const Color(0xFFF0F0F0),
        iconColor: const Color(0xFF8C8C96),
        current: _completedBooks.clamp(0, 10),
        target: 10,
        reward: 500,
        category: 'Reading',
      ),

      AchievementModel(
        id: 'book_master',
        title: 'Book Master',
        description: 'Read 25 books',
        icon: Icons.workspace_premium_rounded,
        iconBackgroundColor: const Color(0xFFFFF0D9),
        iconColor: const Color(0xFFFFA400),
        current: _completedBooks.clamp(0, 25),
        target: 25,
        reward: 1000,
        category: 'Collection',
      ),

      AchievementModel(
        id: 'book_collector',
        title: 'Book Collector',
        description: 'Read 50 books',
        icon: Icons.collections_bookmark_rounded,
        iconBackgroundColor: const Color(0xFFEDE4FF),
        iconColor: const Color(0xFF6938EF),
        current: _completedBooks.clamp(0, 50),
        target: 50,
        reward: 2500,
        category: 'Collection',
      ),
    ];
  }

  // ============================================================
  // COMPLETED ACHIEVEMENTS
  // ============================================================

  int get completedAchievements {
    return achievements
        .where((achievement) => achievement.isCompleted)
        .length;
  }

  // ============================================================
  // TOTAL ACHIEVEMENTS
  // ============================================================

  int get totalAchievements {
    return achievements.length;
  }

  // ============================================================
  // OVERALL PROGRESS
  // ============================================================

  double get overallProgress {
    if (totalAchievements == 0) {
      return 0;
    }

    return completedAchievements / totalAchievements;
  }

  // ============================================================
  // COMPLETE BOOK
  // ============================================================

  void completeBook(BookModel book) {
    // ----------------------------------------------------------
    // SAME BOOK CHECK
    // ----------------------------------------------------------

    if (_completedBookIds.contains(book.id)) {
      return;
    }

    // ----------------------------------------------------------
    // MARK BOOK AS COMPLETED
    // ----------------------------------------------------------

    _completedBookIds.add(book.id);

    _completedBooks++;

    // ----------------------------------------------------------
    // CHECK ACHIEVEMENT REWARDS
    // ----------------------------------------------------------

    _checkAndGiveAchievementRewards();

    // ----------------------------------------------------------
    // UPDATE UI
    // ----------------------------------------------------------

    notifyListeners();
  }

  // ============================================================
  // CHECK AND GIVE ACHIEVEMENT REWARDS
  // ============================================================

  void _checkAndGiveAchievementRewards() {
    for (final achievement in achievements) {
      // Achievement is completed
      if (achievement.isCompleted) {
        // Reward has not been given before
        if (!_rewardedAchievementIds.contains(achievement.id)) {
          // Add achievement reward to total points
          _points += achievement.reward;

          // Mark reward as already given
          _rewardedAchievementIds.add(achievement.id);
        }
      }
    }
  }

  // ============================================================
  // CHECK BOOK
  // ============================================================

  bool isBookCompleted(BookModel book) {
    return _completedBookIds.contains(book.id);
  }

  // ============================================================
  // TESTING
  // ============================================================

  void addTestBook() {
    final fakeBookId = 100000 + _completedBooks;

    final fakeBook = BookModel(
      id: fakeBookId,
      title: 'Test Book $_completedBooks',
      author: 'Test Author',
      imageUrl: '',
      downloadCount: 0,
      textUrl: '',
      description: '',
      language: 'en',
    );

    completeBook(fakeBook);
  }

  // ============================================================
  // RESET
  // ============================================================

  void resetAchievements() {
    _completedBooks = 0;

    _points = 0;

    _completedBookIds.clear();

    _rewardedAchievementIds.clear();

    notifyListeners();
  }
}