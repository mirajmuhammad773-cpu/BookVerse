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
  // CURRENT USER UID
  // ============================================================

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  // ============================================================
  // ACHIEVEMENT DOCUMENT
  // ============================================================

  DocumentReference<Map<String, dynamic>> _achievementDocument(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('achievement')
        .doc('data');
  }

  // ============================================================
  // SAVE ACHIEVEMENT DATA
  // ============================================================

  Future<void> saveAchievementData({
    required String userName,
    required int completedBooks,
    required int points,
    required Set<int> completedBookIds,
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

    final existing =
        await document.get();

    final data = <String, dynamic>{
      'uid': uid,

      // ========================================================
      // USER INFORMATION
      // ========================================================

      'userName': userName,

      // ========================================================
      // READING DATA
      // ========================================================

      'completedBooks': completedBooks,

      'points': points,

      'completedBookIds':
          completedBookIds.toList(),

      'rewardedAchievementIds':
          rewardedAchievementIds.toList(),

      // ========================================================
      // TIMESTAMPS
      // ========================================================

      'updatedAt':
          FieldValue.serverTimestamp(),
    };

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
  // LOAD ACHIEVEMENT DATA
  // ============================================================

  Future<Map<String, dynamic>?> loadAchievementData() async {
    final uid = currentUserId;

    if (uid == null) {
      return null;
    }

    final snapshot =
        await _achievementDocument(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  // ============================================================
  // DELETE ACHIEVEMENT DATA
  // ============================================================

  Future<void> deleteAchievementData() async {
    final uid = currentUserId;

    if (uid == null) {
      return;
    }

    await _achievementDocument(uid).delete();
  }
}