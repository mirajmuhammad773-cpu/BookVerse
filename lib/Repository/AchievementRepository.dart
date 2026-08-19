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
  // ACHIEVEMENT DOCUMENT
  // ============================================================

  DocumentReference<Map<String, dynamic>>
      _achievementDocument(String uid) {
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

    // Unique IDs
    required Set<int> completedBookIds,

    // Book titles for displaying in Achievement Screen
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

    final existing =
        await document.get();

    final data = <String, dynamic>{
      'uid': uid,

      // ========================================================
      // USER
      // ========================================================

      'userName': userName,

      // ========================================================
      // READING
      // ========================================================

      'completedBooks': completedBooks,

      // Keep IDs for unique book checking
      'completedBookIds':
          completedBookIds.toList(),

      // Store titles for Achievement Screen
      'completedBookTitles':
          completedBookTitles,

      // ========================================================
      // POINTS / REWARDS
      // ========================================================

      'points': points,

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
  // LOAD
  // ============================================================

  Future<Map<String, dynamic>?>
      loadAchievementData() async {
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
  // DELETE
  // ============================================================

  Future<void> deleteAchievementData() async {
    final uid = currentUserId;

    if (uid == null) {
      return;
    }

    await _achievementDocument(uid).delete();
  }
}