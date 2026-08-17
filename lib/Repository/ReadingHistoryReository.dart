import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:bookverse/Models/ReadingHistoryModel.dart';

class ReadingHistoryRepository {
  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // USER
  // ============================================================

  String? get _userId {
    return _auth.currentUser?.uid;
  }

  // ============================================================
  // COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      _historyCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('readingHistory');
  }

  // ============================================================
  // SAVE / UPDATE
  // ============================================================

  Future<void> saveReadingHistory(
    ReadingHistoryModel history,
  ) async {
    final userId = _userId;

    if (userId == null) {
      throw Exception(
        'User is not authenticated.',
      );
    }

    await _historyCollection(userId)
        .doc(history.title)
        .set(
          history.toMap(),
          SetOptions(merge: true),
        );
  }

  // ============================================================
  // GET ALL HISTORY
  // ============================================================

  Future<List<ReadingHistoryModel>>
      getReadingHistory() async {
    final userId = _userId;

    if (userId == null) {
      return [];
    }

    final snapshot =
        await _historyCollection(userId)
            .orderBy(
              'lastRead',
              descending: true,
            )
            .limit(50)
            .get();

    return snapshot.docs.map((doc) {
      return ReadingHistoryModel.fromMap(
        doc.data(),
      );
    }).toList();
  }

  // ============================================================
  // GET SINGLE BOOK
  // ============================================================

  Future<ReadingHistoryModel?>
      getBookHistory(
    String title,
  ) async {
    final userId = _userId;

    if (userId == null) {
      return null;
    }

    final doc =
        await _historyCollection(userId)
            .doc(title)
            .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return ReadingHistoryModel.fromMap(
      doc.data()!,
    );
  }

  // ============================================================
  // DELETE HISTORY
  // ============================================================

  Future<void> deleteReadingHistory(
    String title,
  ) async {
    final userId = _userId;

    if (userId == null) {
      return;
    }

    await _historyCollection(userId)
        .doc(title)
        .delete();
  }

  // ============================================================
  // CLEAR ALL HISTORY
  // ============================================================

  Future<void> clearReadingHistory() async {
    final userId = _userId;

    if (userId == null) {
      return;
    }

    final snapshot =
        await _historyCollection(userId)
            .get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}