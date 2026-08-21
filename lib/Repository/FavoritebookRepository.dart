import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:BookVerse/Models/FavoriteBookModel.dart';

class FavoriteBookRepository {
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

  String? get _userId {
    return _auth.currentUser?.uid;
  }

  // ============================================================
  // FAVORITES COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>?
      get _favoritesCollection {
    final uid = _userId;

    if (uid == null) {
      return null;
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favoriteBooks');
  }

  // ============================================================
  // GET FAVORITES
  // ============================================================

  Future<List<FavoriteBookModel>>
      getFavoriteBooks() async {
    final collection = _favoritesCollection;

    if (collection == null) {
      return [];
    }

    final snapshot = await collection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .get();

    return snapshot.docs.map((doc) {
      return FavoriteBookModel.fromMap(
        doc.data(),
      );
    }).toList();
  }

  // ============================================================
  // ADD FAVORITE
  // ============================================================

  Future<bool> addFavorite(
    FavoriteBookModel favorite,
  ) async {
    final collection = _favoritesCollection;

    if (collection == null) {
      return false;
    }

    await collection
        .doc(favorite.title)
        .set(
          favorite.toMap(),
          SetOptions(merge: true),
        );

    return true;
  }

  // ============================================================
  // REMOVE FAVORITE
  // ============================================================

  Future<bool> removeFavorite(
    String bookId,
  ) async {
    final collection = _favoritesCollection;

    if (collection == null) {
      return false;
    }

    await collection
        .doc(bookId)
        .delete();

    return true;
  }

  // ============================================================
  // CHECK FAVORITE
  // ============================================================

  Future<bool> isFavorite(
    String bookId,
  ) async {
    final collection = _favoritesCollection;

    if (collection == null) {
      return false;
    }

    final doc = await collection
        .doc(bookId)
        .get();

    return doc.exists;
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  Future<void> clearFavorites() async {
    final collection = _favoritesCollection;

    if (collection == null) {
      return;
    }

    final snapshot = await collection.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}