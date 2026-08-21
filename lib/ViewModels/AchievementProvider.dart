import 'package:BookVerse/Models/AchievementModel.dart';
import 'package:BookVerse/Models/BookModel.dart';
import 'package:BookVerse/Repository/AchievementRepository.dart';
import 'package:flutter/material.dart';

class AchievementProvider extends ChangeNotifier {
  // ============================================================
  // REPOSITORY
  // ============================================================

  final AchievementRepository _repository =
      AchievementRepository();

  // ============================================================
  // USER
  // ============================================================

  String _userName = '';

  String get userName => _userName;

  // ============================================================
  // COMPLETED BOOKS
  // ============================================================

  // Book IDs are used only to prevent the SAME book
  // from being counted again.
  final Set<int> _completedBookIds = <int>{};

  // Titles are used for displaying completed books.
  final List<String> _completedBookTitles = <String>[];

  // Lifetime completed books count.
  int _completedBooks = 0;

  // ============================================================
  // POINTS
  // ============================================================

  int _points = 0;

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

  int get completedBooks => _completedBooks;

  int get points => _points;

  int get totalStars => _points;

  Set<int> get completedBookIds =>
      Set.unmodifiable(_completedBookIds);

  List<String> get completedBookTitles =>
      List.unmodifiable(_completedBookTitles);

  Set<String> get rewardedAchievementIds =>
      Set.unmodifiable(_rewardedAchievementIds);

  // ============================================================
  // LOAD ACHIEVEMENTS
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
          await _repository.loadAchievementData();

      // ========================================================
      // USER NAME
      // ========================================================

      if (name != null && name.trim().isNotEmpty) {
        _userName = name.trim();
      } else if (data != null) {
        _userName =
            data['userName']?.toString() ?? '';
      }

      // ========================================================
      // IMPORTANT
      //
      // Clear old in-memory data before loading Firebase.
      // Firebase data is the source of truth.
      // ========================================================

      _completedBookIds.clear();
      _completedBookTitles.clear();
      _rewardedAchievementIds.clear();

      _completedBooks = 0;
      _points = 0;

      // ========================================================
      // NO DATA
      // ========================================================

      if (data == null) {
        _isInitialized = true;
        _errorMessage = null;
        return;
      }

      // ========================================================
      // LOAD COMPLETED BOOK IDS
      // ========================================================

      final ids = data['completedBookIds'];

      if (ids is List) {
        for (final value in ids) {
          final id = int.tryParse(
            value.toString(),
          );

          if (id != null) {
            _completedBookIds.add(id);
          }
        }
      }

      // ========================================================
      // LOAD COMPLETED BOOK TITLES
      // ========================================================

      final titles =
          data['completedBookTitles'];

      if (titles is List) {
        for (final value in titles) {
          final title =
              value.toString().trim();

          if (title.isNotEmpty &&
              !_completedBookTitles
                  .contains(title)) {
            _completedBookTitles.add(title);
          }
        }
      }

      // ========================================================
      // LOAD LIFETIME COMPLETED BOOK COUNT
      //
      // IMPORTANT:
      // Never reduce the saved lifetime count.
      // ========================================================

      final savedCompletedBooks =
          data['completedBooks'];

      int firebaseCompletedBooks = 0;

      if (savedCompletedBooks is num) {
        firebaseCompletedBooks =
            savedCompletedBooks.toInt();
      } else {
        firebaseCompletedBooks =
            int.tryParse(
                  savedCompletedBooks
                          ?.toString() ??
                      '0',
                ) ??
                0;
      }

      // Use the largest valid value.
      _completedBooks = [
        firebaseCompletedBooks,
        _completedBookIds.length,
        _completedBookTitles.length,
      ].reduce(
        (a, b) => a > b ? a : b,
      );

      // ========================================================
      // LOAD POINTS
      // ========================================================

      final savedPoints = data['points'];

      if (savedPoints is num) {
        _points = savedPoints.toInt();
      } else {
        _points = int.tryParse(
              savedPoints?.toString() ?? '0',
            ) ??
            0;
      }

      // ========================================================
      // LOAD REWARDED ACHIEVEMENTS
      // ========================================================

      final rewarded =
          data['rewardedAchievementIds'];

      if (rewarded is List) {
        for (final value in rewarded) {
          final id =
              value.toString().trim();

          if (id.isNotEmpty) {
            _rewardedAchievementIds.add(id);
          }
        }
      }

      // ========================================================
      // CHECK EXISTING REWARDS
      // ========================================================

      final rewardsChanged =
          _checkAndGiveAchievementRewards();

      if (rewardsChanged) {
        await _saveToFirebase();
      }

      _isInitialized = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();

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
  // SAVE
  // ============================================================

  Future<void> _saveToFirebase() async {
    await _repository.saveAchievementData(
      userName: _userName,

      completedBooks: _completedBooks,

      completedBookIds:
          Set<int>.from(_completedBookIds),

      completedBookTitles:
          List<String>.from(
        _completedBookTitles,
      ),

      points: _points,

      rewardedAchievementIds:
          Set<String>.from(
        _rewardedAchievementIds,
      ),
    );
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  List<AchievementModel> get achievements {
    return getAchievementsWithStreak(0);
  }

  // ============================================================
  // ACHIEVEMENTS WITH LIVE STREAK
  // ============================================================

  List<AchievementModel>
      getAchievementsWithStreak(
    int currentStreak,
  ) {
    final bookCount = _completedBooks;

    final safeStreak =
        currentStreak < 0
            ? 0
            : currentStreak;

    return [
      // ========================================================
      // FIRST BOOK
      // ========================================================

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
            bookCount >= 1 ? 1 : 0,
        target: 1,
        reward: 150,
        category: 'Reading',
      ),

      // ========================================================
      // 3 BOOKS
      // ========================================================

      AchievementModel(
        id: 'book_explorer',
        title: 'Book Explorer',
        description: 'Read 3 books',
        icon:
            Icons.auto_stories_rounded,
        iconBackgroundColor:
            const Color(0xFFE3F1FF),
        iconColor:
            const Color(0xFF2979FF),
        current:
            bookCount.clamp(0, 3),
        target: 3,
        reward: 300,
        category: 'Reading',
      ),

      // ========================================================
      // 7 DAY STREAK
      // ========================================================

      AchievementModel(
        id: 'reading_streak',
        title: 'Reading Streak',
        description:
            'Read for 7 days in a row',
        icon:
            Icons.local_fire_department_rounded,
        iconBackgroundColor:
            const Color(0xFFFFE7D8),
        iconColor:
            const Color(0xFFFF721B),
        current:
            safeStreak.clamp(0, 7),
        target: 7,
        reward: 150,
        category: 'Streaks',
      ),

      // ========================================================
      // 15 DAY STREAK
      // ========================================================

      AchievementModel(
        id: 'daily_reader',
        title: 'Daily Reader',
        description:
            'Read for 15 days',
        icon:
            Icons.calendar_month_rounded,
        iconBackgroundColor:
            const Color(0xFFEAE4FF),
        iconColor:
            const Color(0xFF6C3CF5),
        current:
            safeStreak.clamp(0, 15),
        target: 15,
        reward: 200,
        category: 'Streaks',
      ),

      // ========================================================
      // 10 BOOKS
      // ========================================================

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
            bookCount.clamp(0, 10),
        target: 10,
        reward: 500,
        category: 'Reading',
      ),

      // ========================================================
      // 25 BOOKS
      // ========================================================

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
            bookCount.clamp(0, 25),
        target: 25,
        reward: 1000,
        category: 'Collection',
      ),

      // ========================================================
      // 50 BOOKS
      // ========================================================

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
            bookCount.clamp(0, 50),
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

  int get totalAchievements =>
      achievements.length;

  // ============================================================
  // COMPLETE BOOK
  // ============================================================

  Future<bool> completeBook(
    BookModel book,
  ) async {
    final bookId = book.id;

    final bookTitle =
        book.title.trim();

    if (bookTitle.isEmpty) {
      debugPrint(
        'Achievement: Book title is empty.',
      );

      return false;
    }

    // ========================================================
    // IMPORTANT DUPLICATE CHECK
    //
    // Same book should never be counted twice.
    //
    // We check BOTH ID and title.
    // This protects us even if the API/model gives
    // an unexpected duplicate ID.
    // ========================================================

    final alreadyCompletedById =
        _completedBookIds.contains(bookId);

    final alreadyCompletedByTitle =
        _completedBookTitles.contains(
      bookTitle,
    );

    if (alreadyCompletedById ||
        alreadyCompletedByTitle) {
      debugPrint(
        'Achievement: "$bookTitle" already completed.',
      );

      return true;
    }

    // ========================================================
    // BACKUP
    // ========================================================

    final oldIds =
        Set<int>.from(
      _completedBookIds,
    );

    final oldTitles =
        List<String>.from(
      _completedBookTitles,
    );

    final oldCompletedBooks =
        _completedBooks;

    final oldPoints = _points;

    final oldRewards =
        Set<String>.from(
      _rewardedAchievementIds,
    );

    try {
      // ======================================================
      // ADD NEW BOOK
      // ======================================================

      _completedBookIds.add(bookId);

      if (!_completedBookTitles
          .contains(bookTitle)) {
        _completedBookTitles.add(
          bookTitle,
        );
      }

      // ======================================================
      // INCREASE LIFETIME COUNT
      //
      // THIS MUST HAPPEN ONLY FOR A NEW BOOK.
      // ======================================================

      _completedBooks =
          _completedBooks + 1;

      // ======================================================
      // RECHECK ACHIEVEMENTS
      // ======================================================

      final rewardsAdded =
          _checkAndGiveAchievementRewards();

      _errorMessage = null;

      // Update UI immediately.
      notifyListeners();

      // ======================================================
      // SAVE ALL BOOKS
      // ======================================================

      await _saveToFirebase();

      debugPrint(
        '================================',
      );

      debugPrint(
        'BOOK SAVED TO ACHIEVEMENT',
      );

      debugPrint(
        'Book: $bookTitle',
      );

      debugPrint(
        'Book ID: $bookId',
      );

      debugPrint(
        'Completed Books: $_completedBooks',
      );

      debugPrint(
        'Completed IDs: $_completedBookIds',
      );

      debugPrint(
        'Completed Titles: $_completedBookTitles',
      );

      debugPrint(
        'Points: $_points',
      );

      if (rewardsAdded) {
        debugPrint(
          'New achievement reward added.',
        );
      }

      debugPrint(
        '================================',
      );

      return true;
    } catch (e) {
      // ======================================================
      // ROLLBACK
      // ======================================================

      _completedBookIds
        ..clear()
        ..addAll(oldIds);

      _completedBookTitles
        ..clear()
        ..addAll(oldTitles);

      _completedBooks =
          oldCompletedBooks;

      _points = oldPoints;

      _rewardedAchievementIds
        ..clear()
        ..addAll(oldRewards);

      _errorMessage = e.toString();

      notifyListeners();

      debugPrint(
        'Achievement complete error: $e',
      );

      return false;
    }
  }

  // ============================================================
  // ACHIEVEMENT REWARDS
  // ============================================================

  bool _checkAndGiveAchievementRewards() {
    bool rewardAdded = false;

    for (final achievement
        in achievements) {
      if (!achievement.isCompleted) {
        continue;
      }

      if (_rewardedAchievementIds
          .contains(achievement.id)) {
        continue;
      }

      _points +=
          achievement.reward;

      _rewardedAchievementIds.add(
        achievement.id,
      );

      rewardAdded = true;

      debugPrint(
        'Achievement unlocked: '
        '${achievement.title}',
      );
    }

    return rewardAdded;
  }

  // ============================================================
  // CHECK BOOK COMPLETION
  // ============================================================

  bool isBookCompleted(
    BookModel book,
  ) {
    return _completedBookIds
            .contains(book.id) ||
        _completedBookTitles
            .contains(book.title.trim());
  }

  // ============================================================
  // CHECK ACHIEVEMENT REWARD
  // ============================================================

  bool hasReceivedReward(
    String achievementId,
  ) {
    return _rewardedAchievementIds
        .contains(
      achievementId,
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void>
      refreshAchievements() async {
    _isInitialized = false;

    await loadAchievements(
      name: _userName.isEmpty
          ? null
          : _userName,
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  Future<void>
      resetAchievements() async {
    try {
      _completedBookIds.clear();

      _completedBookTitles.clear();

      _rewardedAchievementIds.clear();

      _completedBooks = 0;

      _points = 0;

      _errorMessage = null;

      notifyListeners();

      await _repository
          .deleteAchievementData();
    } catch (e) {
      _errorMessage =
          e.toString();

      notifyListeners();
    }
  }
}