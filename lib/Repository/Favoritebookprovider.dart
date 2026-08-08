// lib/Providers/FavouriteBooksProvider.dart

import 'package:flutter/foundation.dart';
import 'package:bookverse/Models/BookModel.dart';

class FavouriteBooksProvider extends ChangeNotifier {
  final List<BookModel> _favoriteBooks = [];

  List<BookModel> get favoriteBooks =>
      List.unmodifiable(_favoriteBooks);

  bool isFavorite(BookModel book) {
    return _favoriteBooks.any(
      (item) => _bookId(item) == _bookId(book),
    );
  }

  void toggleFavorite(BookModel book) {
    final index = _favoriteBooks.indexWhere(
      (item) => _bookId(item) == _bookId(book),
    );

    if (index >= 0) {
      _favoriteBooks.removeAt(index);
    } else {
      _favoriteBooks.add(book);
    }

    notifyListeners();
  }

  void removeFavorite(BookModel book) {
    _favoriteBooks.removeWhere(
      (item) => _bookId(item) == _bookId(book),
    );

    notifyListeners();
  }

  String _bookId(BookModel book) {
    // Agar BookModel mein id available hai
    // to id ko priority milegi.
    //
    // Agar id nahi hai to title + author use hoga.

    try {
      final dynamic value = book;

      final id = value.id;

      if (id != null && id.toString().isNotEmpty) {
        return id.toString();
      }
    } catch (_) {}

    return '${book.title}_${book.author}'.toLowerCase();
  }
}