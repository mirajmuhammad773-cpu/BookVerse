// lib/ViewModels/AchievementProvider.dart

import 'package:bookverse/Models/AchievementModel.dart';
import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/Repository/AchievementRepository.dart';
import 'package:flutter/material.dart';

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

  // Unique book IDs
  final Set<int> _completedBookIds =
      <int>{};

  // Book titles
  final List<String> _completedBookTitles =
      <String>[];

  // Already rewarded achievements
  final Set<String> _rewardedAchievementIds =
      <String>{};

  // ============================================================
  // STATE
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

  int get completedBooks =>
      _completedBooks;

  int get points => _points;

  int get totalStars => _points;

  Set<int> get completedBookIds =>
      Set.unmodifiable(
        _completedBookIds,
      );

  // ============================================================
  // COMPLETED BOOK TITLES
  // ============================================================

  List<String> get completedBookTitles =>
      List.unmodifiable(
        _completedBookTitles,
      );

  // ============================================================
  // LOAD FROM FIREBASE
  // ============================================================

  Future<void> loadAchievements({
    String? name,
  }) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final data =
          await _repository
              .loadAchievementData();

      // ========================================================
      // USER NAME
      // ========================================================

      if (name != null &&
          name.trim().isNotEmpty) {
        _userName =
            name.trim();
      } else if (data != null) {
        _userName =
            data['userName']
                ?.toString() ??
                '';
      }

      // ========================================================
      // RESET LOCAL DATA
      // ========================================================

      _completedBooks = 0;

      _points = 0;

      _completedBookIds.clear();

      _completedBookTitles.clear();

      _rewardedAchievementIds.clear();

      // ========================================================
      // NO FIREBASE DATA
      // ========================================================

      if (data == null) {
        _isInitialized = true;
        return;
      }

      // ========================================================
      // COMPLETED BOOK IDS
      // ========================================================

      final completedIds =
          data['completedBookIds'];

      if (completedIds is List) {
        for (final id
            in completedIds) {
          final parsedId =
              int.tryParse(
            id.toString(),
          );

          if (parsedId != null) {
            _completedBookIds.add(
              parsedId,
            );
          }
        }
      }

      // ========================================================
      // COMPLETED BOOK TITLES
      // ========================================================

      final titles =
          data['completedBookTitles'];

      if (titles is List) {
        for (final title
            in titles) {
          final value =
              title.toString().trim();

          if (value.isNotEmpty &&
              !_completedBookTitles
                  .contains(value)) {
            _completedBookTitles.add(
              value,
            );
          }
        }
      }

      // ========================================================
      // COMPLETED BOOK COUNT
      // ========================================================
      //
      // Always calculate from unique IDs.
      //
      // This prevents:
      //
      // Book A
      // Book B
      // Book C
      //
      // becoming only 1 book accidentally.
      //

      _completedBooks =
          _completedBookIds.length;

      // ========================================================
      // BACKWARD COMPATIBILITY
      // ========================================================
      //
      // If old Firebase data doesn't have IDs but has
      // completedBooks, keep the old count.
      //

      if (_completedBooks == 0) {
        final oldCount =
            data['completedBooks'];

        if (oldCount is num) {
          _completedBooks =
              oldCount.toInt();
        }
      }

      // ========================================================
      // POINTS
      // ========================================================

      final pointsValue =
          data['points'];

      if (pointsValue is num) {
        _points =
            pointsValue.toInt();
      }

      // ========================================================
      // REWARDED ACHIEVEMENTS
      // ========================================================

      final rewardedIds =
          data['rewardedAchievementIds'];

      if (rewardedIds is List) {
        for (final id
            in rewardedIds) {
          _rewardedAchievementIds.add(
            id.toString(),
          );
        }
      }

      _isInitialized = true;
    } catch (e) {
      _errorMessage =
          e.toString();

      _isInitialized = true;

      debugPrint(
        'Achievement load error: $e',
      );
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // SAVE TO FIREBASE
  // ============================================================

  Future<void> _saveToFirebase() async {
    await _repository
        .saveAchievementData(
      userName: _userName,

      completedBooks:
          _completedBooks,

      points:
          _points,

      completedBookIds:
          Set<int>.from(
        _completedBookIds,
      ),

      completedBookTitles:
          List<String>.from(
        _completedBookTitles,
      ),

      rewardedAchievementIds:
          Set<String>.from(
        _rewardedAchievementIds,
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  List<AchievementModel>
      get achievements {
    return [
      AchievementModel(
        id: 'first_chapter',
        title: 'First Chapter',
        description:
            'Read your first book',
        icon:
            Icons.menu_book_rounded,
        iconBackgroundColor:
            const Color(0xFFEDE4FF),
        iconColor:
            const Color(0xFF6938EF),
        current:
            _completedBooks >= 1
                ? 1
                : 0,
        target: 1,
        reward: 150,
        category: 'Reading',
      ),

      AchievementModel(
        id: 'book_explorer',
        title: 'Book Explorer',
        description:
            'Read 3 books',
        icon:
            Icons.auto_stories_rounded,
        iconBackgroundColor:
            const Color(0xFFE3F1FF),
        iconColor:
            const Color(0xFF2979FF),
        current:
            _completedBooks.clamp(
          0,
          3,
        ),
        target: 3,
        reward: 300,
        category: 'Reading',
      ),

      const AchievementModel(
        id: 'reading_streak',
        title: 'Reading Streak',
        description:
            'Read for 7 days in a row',
        icon:
            Icons
                .local_fire_department_rounded,
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
        description:
            'Read for 15 days',
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
        description:
            'Read 10 books',
        icon:
            Icons.emoji_events_rounded,
        iconBackgroundColor:
            const Color(0xFFF0F0F0),
        iconColor:
            const Color(0xFF8C8C96),
        current:
            _completedBooks.clamp(
          0,
          10,
        ),
        target: 10,
        reward: 500,
        category: 'Reading',
      ),

      AchievementModel(
        id: 'book_master',
        title: 'Book Master',
        description:
            'Read 25 books',
        icon:
            Icons
                .workspace_premium_rounded,
        iconBackgroundColor:
            const Color(0xFFFFF0D9),
        iconColor:
            const Color(0xFFFFA400),
        current:
            _completedBooks.clamp(
          0,
          25,
        ),
        target: 25,
        reward: 1000,
        category: 'Collection',
      ),

      AchievementModel(
        id: 'book_collector',
        title: 'Book Collector',
        description:
            'Read 50 books',
        icon:
            Icons
                .collections_bookmark_rounded,
        iconBackgroundColor:
            const Color(0xFFEDE4FF),
        iconColor:
            const Color(0xFF6938EF),
        current:
            _completedBooks.clamp(
          0,
          50,
        ),
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
    final bookId =
        book.id;

    final bookTitle =
        book.title.trim();

    // ========================================================
    // ALREADY COMPLETED
    // ========================================================

    if (_completedBookIds
        .contains(bookId)) {
      debugPrint(
        'Achievement: book already completed: $bookId',
      );

      return true;
    }

    // ========================================================
    // OLD STATE
    // ========================================================

    final oldCompletedBooks =
        _completedBooks;

    final oldPoints =
        _points;

    final oldCompletedIds =
        Set<int>.from(
      _completedBookIds,
    );

    final oldCompletedTitles =
        List<String>.from(
      _completedBookTitles,
    );

    final oldRewardedIds =
        Set<String>.from(
      _rewardedAchievementIds,
    );

    try {
      // ======================================================
      // ADD BOOK ID
      // ======================================================

      _completedBookIds.add(
        bookId,
      );

      // ======================================================
      // ADD BOOK TITLE
      // ======================================================

      if (bookTitle.isNotEmpty &&
          !_completedBookTitles
              .contains(bookTitle)) {
        _completedBookTitles.add(
          bookTitle,
        );
      }

      // ======================================================
      // COUNT UNIQUE BOOKS
      // ======================================================

      _completedBooks =
          _completedBookIds.length;

      // ======================================================
      // ACHIEVEMENT REWARDS
      // ======================================================

      _checkAndGiveAchievementRewards();

      _errorMessage = null;

      // ======================================================
      // UPDATE UI
      // ======================================================

      notifyListeners();

      debugPrint(
        'Achievement: book completed',
      );

      debugPrint(
        'Book ID: $bookId',
      );

      debugPrint(
        'Book Title: $bookTitle',
      );

      debugPrint(
        'Completed Books: $_completedBooks',
      );

      debugPrint(
        'Completed Titles: $_completedBookTitles',
      );

      // ======================================================
      // FIREBASE
      // ======================================================

      await _saveToFirebase();

      debugPrint(
        'Achievement: Firebase save successful',
      );

      return true;
    } catch (e) {
      // ======================================================
      // ROLLBACK
      // ======================================================

      _completedBooks =
          oldCompletedBooks;

      _points =
          oldPoints;

      _completedBookIds
        ..clear()
        ..addAll(
          oldCompletedIds,
        );

      _completedBookTitles
        ..clear()
        ..addAll(
          oldCompletedTitles,
        );

      _rewardedAchievementIds
        ..clear()
        ..addAll(
          oldRewardedIds,
        );

      _errorMessage =
          e.toString();

      notifyListeners();

      debugPrint(
        'Achievement completeBook error: $e',
      );

      return false;
    }
  }

  // ============================================================
  // REWARD CHECK
  // ============================================================

  void _checkAndGiveAchievementRewards() {
    for (final achievement
        in achievements) {
      if (!achievement.isCompleted) {
        continue;
      }

      if (_rewardedAchievementIds
          .contains(
        achievement.id,
      )) {
        continue;
      }

      _points +=
          achievement.reward;

      _rewardedAchievementIds.add(
        achievement.id,
      );

      debugPrint(
        'Achievement reward: '
        '${achievement.id} '
        '+${achievement.reward}',
      );
    }
  }

  // ============================================================
  // BOOK COMPLETED?
  // ============================================================

  bool isBookCompleted(
    BookModel book,
  ) {
    return _completedBookIds
        .contains(
      book.id,
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void>
      refreshAchievements() async {
    await loadAchievements(
      name: _userName.isEmpty
          ? null
          : _userName,
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  Future<void> resetAchievements() async {
    try {
      _completedBooks = 0;

      _points = 0;

      _completedBookIds.clear();

      _completedBookTitles.clear();

      _rewardedAchievementIds.clear();

      _errorMessage = null;

      notifyListeners();

      await _saveToFirebase();
    } catch (e) {
      _errorMessage =
          e.toString();

      notifyListeners();
    }
  }
}