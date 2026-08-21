// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementRepository {
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
      _achievementDocument(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('achievement')
        .doc('data');
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> saveAchievementData({
    required String userName,
    required int completedBooks,
    required int points,
    required Set<int> completedBookIds,
    required List<String> completedBookTitles,
    required Set<String> rewardedAchievementIds,
  }) async {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final document =
        _achievementDocument(uid);

    // ========================================================
    // LOAD EXISTING DATA FIRST
    // ========================================================

    final existing =
        await document.get();

    final existingData =
        existing.data();

    // ========================================================
    // EXISTING COUNT
    // ========================================================

    int existingCompletedBooks = 0;

    if (existingData != null) {
      final value =
          existingData['completedBooks'];

      if (value is num) {
        existingCompletedBooks =
            value.toInt();
      } else {
        existingCompletedBooks =
            int.tryParse(
                  value?.toString() ??
                      '0',
                ) ??
                0;
      }
    }

    // ========================================================
    // NEVER DECREASE LIFETIME COUNT
    // ========================================================

    final finalCompletedBooks =
        completedBooks >
                existingCompletedBooks
            ? completedBooks
            : existingCompletedBooks;

    // ========================================================
    // MERGE BOOK IDS
    //
    // Existing Firebase IDs + new IDs
    // ========================================================

    final Set<int> mergedBookIds =
        <int>{};

    if (existingData != null) {
      final oldIds =
          existingData['completedBookIds'];

      if (oldIds is List) {
        for (final value in oldIds) {
          final id = int.tryParse(
            value.toString(),
          );

          if (id != null) {
            mergedBookIds.add(id);
          }
        }
      }
    }

    mergedBookIds.addAll(
      completedBookIds,
    );

    // ========================================================
    // MERGE BOOK TITLES
    // ========================================================

    final List<String> mergedBookTitles =
        <String>[];

    if (existingData != null) {
      final oldTitles =
          existingData[
              'completedBookTitles'];

      if (oldTitles is List) {
        for (final value in oldTitles) {
          final title =
              value.toString().trim();

          if (title.isNotEmpty &&
              !mergedBookTitles
                  .contains(title)) {
            mergedBookTitles.add(
              title,
            );
          }
        }
      }
    }

    for (final title
        in completedBookTitles) {
      final cleanTitle =
          title.trim();

      if (cleanTitle.isNotEmpty &&
          !mergedBookTitles
              .contains(cleanTitle)) {
        mergedBookTitles.add(
          cleanTitle,
        );
      }
    }

    // ========================================================
    // MERGE REWARDED ACHIEVEMENTS
    // ========================================================

    final Set<String>
        mergedRewardedAchievements =
        <String>{};

    if (existingData != null) {
      final oldRewards =
          existingData[
              'rewardedAchievementIds'];

      if (oldRewards is List) {
        for (final value in oldRewards) {
          final id =
              value.toString().trim();

          if (id.isNotEmpty) {
            mergedRewardedAchievements
                .add(id);
          }
        }
      }
    }

    mergedRewardedAchievements
        .addAll(
      rewardedAchievementIds,
    );

    // ========================================================
    // EXISTING POINTS
    // ========================================================

    int existingPoints = 0;

    if (existingData != null) {
      final value =
          existingData['points'];

      if (value is num) {
        existingPoints =
            value.toInt();
      } else {
        existingPoints =
            int.tryParse(
                  value?.toString() ??
                      '0',
                ) ??
                0;
      }
    }

    // Points should never decrease accidentally.
    final finalPoints =
        points > existingPoints
            ? points
            : existingPoints;

    // ========================================================
    // FINAL DATA
    // ========================================================

    final data =
        <String, dynamic>{
      'uid': uid,

      // ======================================================
      // USER
      // ======================================================

      'userName': userName,

      // ======================================================
      // COMPLETED BOOKS
      // ======================================================

      'completedBooks':
          finalCompletedBooks,

      'completedBookIds':
          mergedBookIds.toList(),

      'completedBookTitles':
          mergedBookTitles,

      // ======================================================
      // POINTS
      // ======================================================

      'points': finalPoints,

      'rewardedAchievementIds':
          mergedRewardedAchievements
              .toList(),

      // ======================================================
      // TIME
      // ======================================================

      'updatedAt':
          FieldValue.serverTimestamp(),
    };

    // ========================================================
    // CREATED AT
    // ========================================================

    if (!existing.exists) {
      data['createdAt'] =
          FieldValue.serverTimestamp();
    }

    // ========================================================
    // SAVE
    // ========================================================

    await document.set(
      data,
      SetOptions(
        merge: true,
      ),
    );
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<Map<String, dynamic>?>
      loadAchievementData() async {
    final uid = currentUserId;

    if (uid == null) {
      return null;
    }

    final snapshot =
        await _achievementDocument(uid)
            .get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void>
      deleteAchievementData() async {
    final uid = currentUserId;

    if (uid == null) {
      return;
    }

    await _achievementDocument(uid)
        .delete();
  }
}