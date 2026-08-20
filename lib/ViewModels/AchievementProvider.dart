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
  // USER
  // ============================================================

  String _userName = '';

  String get userName => _userName;

  // ============================================================
  // COMPLETED BOOKS
  // ============================================================

  final Set<int> _completedBookIds =
      <int>{};

  final List<String> _completedBookTitles =
      <String>[];

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

  int get completedBooks =>
      _completedBookIds.length;

  int get points => _points;

  int get totalStars => _points;

  Set<int> get completedBookIds =>
      Set.unmodifiable(
        _completedBookIds,
      );

  List<String> get completedBookTitles =>
      List.unmodifiable(
        _completedBookTitles,
      );

  Set<String> get rewardedAchievementIds =>
      Set.unmodifiable(
        _rewardedAchievementIds,
      );

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
          await _repository
              .loadAchievementData();

      // ========================================================
      // USER NAME
      // ========================================================

      if (name != null &&
          name.trim().isNotEmpty) {
        _userName = name.trim();
      } else if (data != null) {
        _userName =
            data['userName']
                    ?.toString() ??
                '';
      }

      // ========================================================
      // RESET LOCAL DATA
      // ========================================================

      _completedBookIds.clear();

      _completedBookTitles.clear();

      _rewardedAchievementIds.clear();

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
      // COMPLETED BOOK IDS
      // ========================================================

      final ids =
          data['completedBookIds'];

      if (ids is List) {
        for (final value in ids) {
          final id =
              int.tryParse(
            value.toString(),
          );

          if (id != null) {
            _completedBookIds.add(id);
          }
        }
      }

      // ========================================================
      // COMPLETED BOOK TITLES
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
            _completedBookTitles
                .add(title);
          }
        }
      }

      // ========================================================
      // POINTS
      // ========================================================

      final savedPoints =
          data['points'];

      if (savedPoints is num) {
        _points =
            savedPoints.toInt();
      } else {
        _points =
            int.tryParse(
                  savedPoints
                          ?.toString() ??
                      '0',
                ) ??
                0;
      }

      // ========================================================
      // REWARDED ACHIEVEMENTS
      // ========================================================

      final rewarded =
          data[
              'rewardedAchievementIds'];

      if (rewarded is List) {
        for (final value
            in rewarded) {
          final id =
              value.toString().trim();

          if (id.isNotEmpty) {
            _rewardedAchievementIds
                .add(id);
          }
        }
      }

      // ========================================================
      // CHECK REWARDS
      // ========================================================

      final bool rewardsChanged =
          _checkAndGiveAchievementRewards();

      if (rewardsChanged) {
        await _saveToFirebase();
      }

      // ========================================================
      // INITIALIZED
      // ========================================================

      _isInitialized = true;

      _errorMessage = null;
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
  // SAVE
  // ============================================================

  Future<void> _saveToFirebase() async {
    await _repository
        .saveAchievementData(
      userName: _userName,
      completedBooks:
          _completedBookIds.length,
      points: _points,
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
  //
  // Default achievements for existing reward logic.
  // ============================================================

  List<AchievementModel>
      get achievements {
    return getAchievementsWithStreak(0);
  }

  // ============================================================
  // ACHIEVEMENTS WITH LIVE STREAK
  // ============================================================

  List<AchievementModel>
      getAchievementsWithStreak(
    int currentStreak,
  ) {
    final bookCount =
        _completedBookIds.length;

    final safeStreak =
        currentStreak < 0
            ? 0
            : currentStreak;

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
            bookCount >= 1 ? 1 : 0,
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
      // 15 DAY READING
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
            bookCount.clamp(0, 10),
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

      AchievementModel(
        id: 'book_collector',
        title: 'Book Collector',
        description:
            'Read 50 books',
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

    // ========================================================
    // DUPLICATE CHECK
    // ========================================================

    if (_completedBookIds
        .contains(bookId)) {
      debugPrint(
        'Achievement: Book already completed',
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

    final oldPoints = _points;

    final oldRewards =
        Set<String>.from(
      _rewardedAchievementIds,
    );

    try {
      // ======================================================
      // ADD BOOK
      // ======================================================

      _completedBookIds.add(
        bookId,
      );

      // ======================================================
      // ADD TITLE
      // ======================================================

      if (bookTitle.isNotEmpty &&
          !_completedBookTitles
              .contains(bookTitle)) {
        _completedBookTitles.add(
          bookTitle,
        );
      }

      // ======================================================
      // CALCULATE REWARDS
      // ======================================================

      final bool rewardsAdded =
          _checkAndGiveAchievementRewards();

      _errorMessage = null;

      notifyListeners();

      await _saveToFirebase();

      debugPrint(
        '================================',
      );

      debugPrint(
        'BOOK SAVED TO ACHIEVEMENT',
      );

      debugPrint(
        'Book ID: $bookId',
      );

      debugPrint(
        'Book Title: $bookTitle',
      );

      debugPrint(
        'Total Books: '
        '${_completedBookIds.length}',
      );

      if (rewardsAdded) {
        debugPrint(
          'New achievement reward added.',
        );
      }

      debugPrint(
        'Points: $_points',
      );

      debugPrint(
        'Rewarded IDs: '
        '$_rewardedAchievementIds',
      );

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

      _points = oldPoints;

      _rewardedAchievementIds
        ..clear()
        ..addAll(oldRewards);

      _errorMessage =
          e.toString();

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

      rewardAdded = true;

      debugPrint(
        '================================',
      );

      debugPrint(
        'ACHIEVEMENT REWARD ADDED',
      );

      debugPrint(
        'Achievement: '
        '${achievement.title}',
      );

      debugPrint(
        'Reward: '
        '+${achievement.reward}',
      );

      debugPrint(
        'Total Points: '
        '$_points',
      );

      debugPrint(
        '================================',
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
        .contains(book.id);
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
      name:
          _userName.isEmpty
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

      _points = 0;

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