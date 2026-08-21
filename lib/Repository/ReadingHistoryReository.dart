import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:BookVerse/Models/ReadingHistoryModel.dart';

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
      _historyCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('readingHistory');
  }

  // ============================================================
  // DOCUMENT ID
  // ============================================================
  //
  // IMPORTANT:
  //
  // Use bookId instead of title.
  //
  // Book title can theoretically be changed or duplicated.
  // Book ID is stable and unique.
  //
  // ============================================================

  String _documentId(
    ReadingHistoryModel history,
  ) {
    return history.bookId;
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
        .doc(
          _documentId(history),
        )
        .set(
          history.toMap(),
          SetOptions(
            merge: true,
          ),
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

    return snapshot.docs.map(
      (doc) {
        return ReadingHistoryModel.fromMap(
          doc.data(),
        );
      },
    ).toList();
  }

  // ============================================================
  // GET SINGLE BOOK
  // ============================================================

  Future<ReadingHistoryModel?>
      getBookHistory(
    String bookId,
  ) async {
    final userId = _userId;

    if (userId == null) {
      return null;
    }

    final doc =
        await _historyCollection(userId)
            .doc(bookId)
            .get();

    if (!doc.exists ||
        doc.data() == null) {
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
    String bookId,
  ) async {
    final userId = _userId;

    if (userId == null) {
      return;
    }

    await _historyCollection(userId)
        .doc(bookId)
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

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch =
        _firestore.batch();

    for (final doc
        in snapshot.docs) {
      batch.delete(
        doc.reference,
      );
    }

    await batch.commit();
  }
}