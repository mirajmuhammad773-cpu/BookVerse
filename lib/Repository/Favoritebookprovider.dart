
// lib/Providers/FavouriteBooksProvider.dart

import 'package:flutter/foundation.dart';
import 'package:bookverse/Models/BookModel.dart';

class FavouriteBooksProvider extends ChangeNotifier {
  // ============================================================
  // FAVORITE BOOKS
  // ============================================================

  final List<BookModel> _favoriteBooks = [];

  // ============================================================
  // GETTERS
  // ============================================================

  List<BookModel> get favoriteBooks =>
      List.unmodifiable(_favoriteBooks);

  // ============================================================
  // CHECK FAVORITE
  // ============================================================

  bool isFavorite(BookModel book) {
    return _favoriteBooks.any(
      (item) => _bookId(item) == _bookId(book),
    );
  }

  // ============================================================
  // TOGGLE FAVORITE
  // ============================================================

  void toggleFavorite(BookModel book) {
    final index = _favoriteBooks.indexWhere(
      (item) => _bookId(item) == _bookId(book),
    );

    if (index >= 0) {
      // Remove favorite
      _favoriteBooks.removeAt(index);
    } else {
      // Add favorite
      _favoriteBooks.add(book);
    }

    // Update UI
    notifyListeners();
  }

  // ============================================================
  // REMOVE FAVORITE
  // ============================================================

  void removeFavorite(BookModel book) {
    _favoriteBooks.removeWhere(
      (item) => _bookId(item) == _bookId(book),
    );

    notifyListeners();
  }

  // ============================================================
  // CLEAR ALL FAVORITES
  // ============================================================

  void clearFavorites() {
    _favoriteBooks.clear();

    notifyListeners();
  }

  // ============================================================
  // BOOK ID
  // ============================================================

  String _bookId(BookModel book) {
    try {
      final dynamic value = book;

      final id = value.id;

      if (id != null && id.toString().trim().isNotEmpty) {
        return id.toString();
      }
    } catch (_) {}

    // Agar id available nahi hai
    return '${book.title}_${book.author}'
        .trim()
        .toLowerCase();
  }
}