// lib/Repository/ReadingGoalRepository.dart

import 'package:bookverse/Models/ReadingGoalsModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReadingGoalRepository {
  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER
  // ============================================================

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  // ============================================================
  // DOCUMENT
  // ============================================================

  DocumentReference<Map<String, dynamic>>
      _readingGoalDocument(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('readingGoals')
        .doc('data');
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<ReadingGoalModel?> loadReadingGoals() async {
    final uid = currentUserId;

    if (uid == null) {
      return null;
    }

    final snapshot =
        await _readingGoalDocument(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    return ReadingGoalModel.fromMap(data);
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> saveReadingGoals(
    ReadingGoalModel model,
  ) async {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final document =
        _readingGoalDocument(uid);

    final data = model.toMap();

    data['uid'] = uid;

    data['updatedAt'] =
        FieldValue.serverTimestamp();

    final existing =
        await document.get();

    if (!existing.exists) {
      data['createdAt'] =
          FieldValue.serverTimestamp();
    }

    await document.set(
      data,
      SetOptions(
        merge: true,
      ),
    );
  }

  // ============================================================
  // ADD READING TIME
  // ============================================================

  Future<void> addReadingTime({
    required int minutes,
    required ReadingGoalModel currentModel,
  }) async {
    if (minutes <= 0) {
      return;
    }

    final updatedModel =
        currentModel.copyWith(
      totalReadingMinutes:
          currentModel.totalReadingMinutes +
              minutes,
    );

    await saveReadingGoals(
      updatedModel,
    );
  }

  // ============================================================
  // COMPLETE BOOK
  // ============================================================

  Future<ReadingGoalModel> addCompletedBook({
    required String bookId,
    required ReadingGoalModel currentModel,
  }) async {
    if (currentModel.completedBookIds
        .contains(bookId)) {
      return currentModel;
    }

    final updatedIds =
        List<String>.from(
      currentModel.completedBookIds,
    );

    updatedIds.add(bookId);

    final updatedModel =
        currentModel.copyWith(
      booksRead:
          currentModel.booksRead + 1,
      completedBookIds:
          updatedIds,
      monthlyGoalCurrent:
          currentModel.monthlyGoalCurrent + 1,
    );

    await saveReadingGoals(
      updatedModel,
    );

    return updatedModel;
  }

  // ============================================================
  // SET YEARLY GOAL
  // ============================================================

  Future<void> setYearlyGoal({
    required int goal,
    required ReadingGoalModel currentModel,
  }) async {
    if (goal <= 0) {
      return;
    }

    await saveReadingGoals(
      currentModel.copyWith(
        yearlyGoal: goal,
      ),
    );
  }

  // ============================================================
  // SET DAILY GOAL
  // ============================================================

  Future<void> setDailyGoal({
    required int goal,
    required ReadingGoalModel currentModel,
  }) async {
    if (goal <= 0) {
      return;
    }

    await saveReadingGoals(
      currentModel.copyWith(
        dailyGoalTarget: goal,
      ),
    );
  }

  // ============================================================
  // SET MONTHLY GOAL
  // ============================================================

  Future<void> setMonthlyGoal({
    required int goal,
    required ReadingGoalModel currentModel,
  }) async {
    if (goal <= 0) {
      return;
    }

    await saveReadingGoals(
      currentModel.copyWith(
        monthlyGoalTarget: goal,
      ),
    );
  }

  // ============================================================
  // UPDATE WEEKLY DATA
  // ============================================================

  Future<void> updateWeeklyData({
    required List<DayReading> weeklyData,
    required ReadingGoalModel currentModel,
  }) async {
    await saveReadingGoals(
      currentModel.copyWith(
        weeklyData: weeklyData,
      ),
    );
  }

  // ============================================================
  // UPDATE DAILY READING
  // ============================================================

  Future<void> updateDailyReading({
    required int dailyMinutes,
    required ReadingGoalModel currentModel,
  }) async {
    await saveReadingGoals(
      currentModel.copyWith(
        dailyGoalCurrent: dailyMinutes,
      ),
    );
  }

  // ============================================================
  // UPDATE STREAK
  // ============================================================

  Future<void> updateStreak({
    required int streakDays,
    required ReadingGoalModel currentModel,
  }) async {
    await saveReadingGoals(
      currentModel.copyWith(
        currentStreakDays: streakDays,
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteReadingGoals() async {
    final uid = currentUserId;

    if (uid == null) {
      return;
    }

    await _readingGoalDocument(uid).delete();
  }
}