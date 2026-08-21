// ignore_for_file: depend_on_referenced_packages, prefer_final_fields

import 'package:BookVerse/Models/NotificationModel.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../Repository/NotificationRepository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository =
      NotificationRepository();

  final Uuid _uuid = const Uuid();

  // ============================================================
  // STATE
  // ============================================================

  List<AppNotificationModel> _notifications = [];

  bool _isLoading = false;

  String? _userId;

  // ============================================================
  // GETTERS
  // ============================================================

  List<AppNotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  bool get isLoading => _isLoading;

  int get unreadCount {
    return _notifications
        .where((notification) => !notification.isRead)
        .length;
  }

  bool get hasUnreadNotifications => unreadCount > 0;

  // ============================================================
  // INITIALIZE
  // ============================================================

  void initialize(String userId) {
    _userId = userId;

    _repository
        .getNotifications(userId)
        .listen(
      (data) {
        _notifications = data;
        notifyListeners();
      },
    );
  }

  // ============================================================
  // INTERNAL CREATE METHOD
  // ============================================================

  Future<void> _createNotification({
    required String eventKey,
    required String title,
    required String message,
    required String type,
    required String icon,
  }) async {
    if (_userId == null) return;

    final exists = await _repository.notificationExists(
      userId: _userId!,
      eventKey: eventKey,
    );

    if (exists) return;

    final notification = AppNotificationModel(
      id: _uuid.v4(),
      title: title,
      message: message,
      type: type,
      icon: icon,
      eventKey: eventKey,
      isRead: false,
      createdAt: DateTime.now(),
    );

    await _repository.createNotification(
      userId: _userId!,
      notification: notification,
    );
  }

  // ============================================================
  // DAILY READING GOAL
  // ============================================================

  Future<void> dailyReadingGoalCompleted({
    int minutes = 30,
  }) async {
    final today = DateTime.now();

    final dateKey =
        '${today.year}-${today.month}-${today.day}';

    await _createNotification(
      eventKey: 'daily_reading_goal_$dateKey',
      title: 'Daily Goal Complete!',
      message:
          'Amazing! You completed your $minutes minute reading goal today.',
      type: 'goal',
      icon: '🎯',
    );
  }

  // ============================================================
  // BOOK COMPLETED
  // ============================================================

  Future<void> bookCompleted({
    required String bookId,
    required String bookTitle,
  }) async {
    await _createNotification(
      eventKey: 'book_completed_$bookId',
      title: 'Book Completed!',
      message:
          'Congratulations! You completed "$bookTitle".',
      type: 'book',
      icon: '📚',
    );
  }

  // ============================================================
  // BOOK FAVORITED
  // ============================================================

  Future<void> bookFavorited({
    required String bookId,
    required String bookTitle,
  }) async {
    await _createNotification(
      eventKey: 'book_favorited_$bookId',
      title: 'Book Added to Favorites',
      message:
          '"$bookTitle" has been added to your favorite books.',
      type: 'favorite',
      icon: '❤️',
    );
  }

  // ============================================================
  // ACHIEVEMENT UNLOCKED
  // ============================================================

  Future<void> achievementUnlocked({
    required String achievementId,
    required String achievementTitle,
  }) async {
    await _createNotification(
      eventKey: 'achievement_$achievementId',
      title: 'Achievement Unlocked!',
      message:
          'You unlocked the "$achievementTitle" achievement.',
      type: 'achievement',
      icon: '🏆',
    );
  }

  // ============================================================
  // STREAK COMPLETED
  // ============================================================

  Future<void> streakCompleted({
    required int days,
  }) async {
    await _createNotification(
      eventKey: 'streak_$days',
      title: '$days-Day Streak!',
      message:
          'Amazing! You completed a $days-day reading streak.',
      type: 'streak',
      icon: '🔥',
    );
  }

  // ============================================================
  // READING CHALLENGE COMPLETED
  // ============================================================

  Future<void> readingChallengeCompleted({
    required String challengeId,
    required String challengeTitle,
  }) async {
    await _createNotification(
      eventKey: 'challenge_$challengeId',
      title: 'Challenge Completed!',
      message:
          'Congratulations! You completed "$challengeTitle".',
      type: 'challenge',
      icon: '📖',
    );
  }

  // ============================================================
  // YEARLY GOAL COMPLETED
  // ============================================================

  Future<void> yearlyGoalCompleted({
    required int goal,
  }) async {
    final year = DateTime.now().year;

    await _createNotification(
      eventKey: 'yearly_goal_${year}_$goal',
      title: 'Yearly Reading Goal Complete!',
      message:
          'Amazing! You reached your goal of reading $goal books this year.',
      type: 'goal',
      icon: '🎯',
    );
  }

  // ============================================================
  // MONTHLY GOAL COMPLETED
  // ============================================================

  Future<void> monthlyGoalCompleted({
    required int goal,
  }) async {
    final now = DateTime.now();

    final monthKey =
        '${now.year}-${now.month}';

    await _createNotification(
      eventKey: 'monthly_goal_${monthKey}_$goal',
      title: 'Monthly Goal Complete!',
      message:
          'Great job! You completed your goal of $goal books this month.',
      type: 'goal',
      icon: '🎯',
    );
  }

  // ============================================================
  // MARK AS READ
  // ============================================================

  Future<void> markAsRead(
    String notificationId,
  ) async {
    if (_userId == null) return;

    await _repository.markAsRead(
      userId: _userId!,
      notificationId: notificationId,
    );
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    await _repository.markAllAsRead(
      _userId!,
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteNotification(
    String notificationId,
  ) async {
    if (_userId == null) return;

    await _repository.deleteNotification(
      userId: _userId!,
      notificationId: notificationId,
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clear() {
    _notifications = [];
    _userId = null;
    notifyListeners();
  }
}