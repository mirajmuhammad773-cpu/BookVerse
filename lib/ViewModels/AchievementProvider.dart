import 'package:bookverse/Repository/AchievementProvider.dart';
import 'package:flutter/material.dart';
import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/Models/AchievementModel.dart';

class AchievementProvider extends ChangeNotifier {
  // ============================================================
  // REPOSITORY
  // ============================================================

  final AchievementRepository _repository =
      AchievementRepository();

  // ============================================================
  // USER DATA
  // ============================================================

  String _userName = '';

  String get userName => _userName;

  // ============================================================
  // READING DATA
  // ============================================================

  int _completedBooks = 0;

  int _points = 0;

  final Set<int> _completedBookIds = {};

  final Set<String> _rewardedAchievementIds = {};

  // ============================================================
  // LOADING
  // ============================================================

  bool _isLoading = false;

  bool _isInitialized = false;

  String? _errorMessage;

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  int get completedBooks => _completedBooks;

  int get points => _points;

  int get totalStars => _points;

  Set<int> get completedBookIds =>
      Set.unmodifiable(_completedBookIds);

  // ============================================================
  // LOAD FROM FIREBASE
  // ============================================================

  Future<void> loadAchievements({
    String? userName,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final data =
          await _repository.loadAchievementData();

      // ========================================================
      // USER NAME
      // ========================================================

      if (userName != null &&
          userName.trim().isNotEmpty) {
        _userName = userName.trim();
      } else if (data != null) {
        _userName =
            data['userName']?.toString() ?? '';
      }

      // ========================================================
      // NO DATA YET
      // ========================================================

      if (data == null) {
        _isInitialized = true;
        return;
      }

      // ========================================================
      // COMPLETED BOOKS
      // ========================================================

      _completedBooks =
          (data['completedBooks'] as num?)
                  ?.toInt() ??
              0;

      // ========================================================
      // POINTS
      // ========================================================

      _points =
          (data['points'] as num?)
                  ?.toInt() ??
              0;

      // ========================================================
      // COMPLETED BOOK IDS
      // ========================================================

      _completedBookIds.clear();

      final completedIds =
          data['completedBookIds'];

      if (completedIds is List) {
        for (final id in completedIds) {
          final parsedId =
              int.tryParse(id.toString());

          if (parsedId != null) {
            _completedBookIds.add(
              parsedId,
            );
          }
        }
      }

      // ========================================================
      // REWARDED ACHIEVEMENT IDS
      // ========================================================

      _rewardedAchievementIds.clear();

      final rewardedIds =
          data['rewardedAchievementIds'];

      if (rewardedIds is List) {
        for (final id in rewardedIds) {
          _rewardedAchievementIds.add(
            id.toString(),
          );
        }
      }

      _isInitialized = true;
    } catch (e) {
      _errorMessage = e.toString();
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SAVE TO FIREBASE
  // ============================================================

  Future<void> _saveToFirebase() async {
    try {
      await _repository.saveAchievementData(
        userName: _userName,
        completedBooks: _completedBooks,
        points: _points,
        completedBookIds: _completedBookIds,
        rewardedAchievementIds:
            _rewardedAchievementIds,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

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
        iconBackgroundColor:
            const Color(0xFFEDE4FF),
        iconColor:
            const Color(0xFF6938EF),
        current:
            _completedBooks >= 1 ? 1 : 0,
        target: 1,
        reward: 150,
        category: 'Reading',
      ),

      AchievementModel(
        id: 'book_explorer',
        title: 'Book Explorer',
        description: 'Read 3 books',
        icon: Icons.auto_stories_rounded,
        iconBackgroundColor:
            const Color(0xFFE3F1FF),
        iconColor:
            const Color(0xFF2979FF),
        current:
            _completedBooks.clamp(0, 3),
        target: 3,
        reward: 300,
        category: 'Reading',
      ),

      const AchievementModel(
        id: 'reading_streak',
        title: 'Reading Streak',
        description: 'Read for 7 days in a row',
        icon:
            Icons.local_fire_department_rounded,
        iconBackgroundColor:
            Color(0xFFFFE7D8),
        iconColor:
            Color(0xFFFF721B),
        current: 0,
        target: 7,
        reward: 150,
        category: 'Streaks',
      ),

      const AchievementModel(
        id: 'daily_reader',
        title: 'Daily Reader',
        description: 'Read for 15 days',
        icon:
            Icons.calendar_month_rounded,
        iconBackgroundColor:
            Color(0xFFEAE4FF),
        iconColor:
            Color(0xFF6C3CF5),
        current: 0,
        target: 15,
        reward: 200,
        category: 'Streaks',
      ),

      AchievementModel(
        id: 'avid_reader',
        title: 'Avid Reader',
        description: 'Read 10 books',
        icon:
            Icons.emoji_events_rounded,
        iconBackgroundColor:
            const Color(0xFFF0F0F0),
        iconColor:
            const Color(0xFF8C8C96),
        current:
            _completedBooks.clamp(0, 10),
        target: 10,
        reward: 500,
        category: 'Reading',
      ),

      AchievementModel(
        id: 'book_master',
        title: 'Book Master',
        description: 'Read 25 books',
        icon:
            Icons.workspace_premium_rounded,
        iconBackgroundColor:
            const Color(0xFFFFF0D9),
        iconColor:
            const Color(0xFFFFA400),
        current:
            _completedBooks.clamp(0, 25),
        target: 25,
        reward: 1000,
        category: 'Collection',
      ),

      AchievementModel(
        id: 'book_collector',
        title: 'Book Collector',
        description: 'Read 50 books',
        icon:
            Icons.collections_bookmark_rounded,
        iconBackgroundColor:
            const Color(0xFFEDE4FF),
        iconColor:
            const Color(0xFF6938EF),
        current:
            _completedBooks.clamp(0, 50),
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
        .where(
          (achievement) =>
              achievement.isCompleted,
        )
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

    return completedAchievements /
        totalAchievements;
  }

  // ============================================================
  // COMPLETE BOOK
  // ============================================================

  Future<bool> completeBook(
    BookModel book,
  ) async {
    // ========================================================
    // SAME BOOK CHECK
    // ========================================================

    if (_completedBookIds.contains(book.id)) {
      return true;
    }

    try {
      // ========================================================
      // MARK BOOK COMPLETED
      // ========================================================

      _completedBookIds.add(book.id);

      _completedBooks++;

      // ========================================================
      // REWARDS
      // ========================================================

      _checkAndGiveAchievementRewards();

      // ========================================================
      // UPDATE UI FIRST
      // ========================================================

      notifyListeners();

      // ========================================================
      // SAVE FIREBASE
      // ========================================================

      await _saveToFirebase();
      _errorMessage = null;
      return true;
    } catch (e) {
      _completedBookIds.remove(book.id);
      _completedBooks =
          _completedBooks > 0 ? _completedBooks - 1 : 0;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // CHECK AND GIVE REWARDS
  // ============================================================

  void _checkAndGiveAchievementRewards() {
    for (final achievement in achievements) {
      if (achievement.isCompleted) {
        if (!_rewardedAchievementIds
            .contains(achievement.id)) {
          _points += achievement.reward;

          _rewardedAchievementIds.add(
            achievement.id,
          );
        }
      }
    }
  }

  // ============================================================
  // CHECK BOOK
  // ============================================================

  bool isBookCompleted(
    BookModel book,
  ) {
    return _completedBookIds
        .contains(book.id);
  }

  // ============================================================
  // RESET
  // ============================================================

  Future<void> resetAchievements() async {
    _completedBooks = 0;

    _points = 0;

    _completedBookIds.clear();

    _rewardedAchievementIds.clear();

    notifyListeners();

    await _saveToFirebase();
  }
}