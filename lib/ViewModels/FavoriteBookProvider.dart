import 'package:bookverse/Repository/FavoritebookRepository.dart';
import 'package:flutter/material.dart';

import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/Models/FavoriteBookModel.dart';

class FavouriteBooksProvider extends ChangeNotifier {
  // ============================================================
  // REPOSITORY
  // ============================================================

  final FavoriteBookRepository _repository =
      FavoriteBookRepository();

  // ============================================================
  // STATE
  // ============================================================

  final List<BookModel> _favoriteBooks = [];

  bool _isLoading = false;

  bool _isInitialized = false;

  String? _errorMessage;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  FavouriteBooksProvider() {
    loadFavorites();
  }

  // ============================================================
  // GETTERS
  // ============================================================

  List<BookModel> get favoriteBooks =>
      List.unmodifiable(_favoriteBooks);

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  String? get errorMessage => _errorMessage;

  int get favoriteCount =>
      _favoriteBooks.length;

  // ============================================================
  // LOAD FROM FIREBASE
  // ============================================================

  Future<void> loadFavorites() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final favorites =
          await _repository.getFavoriteBooks();

      _favoriteBooks
        ..clear()
        ..addAll(
          favorites.map(
            (favorite) =>
                favorite.toBookModel(),
          ),
        );

      _isInitialized = true;
    } catch (e) {
      _errorMessage = e.toString();
      _isInitialized = true;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CHECK FAVORITE
  // ============================================================

  bool isFavorite(
    BookModel book,
  ) {
    final bookId = book.id.toString();

    return _favoriteBooks.any(
      (favorite) =>
          favorite.id.toString() == bookId,
    );
  }

  // ============================================================
  // ADD FAVORITE
  // ============================================================

  Future<bool> addFavorite(
    BookModel book,
  ) async {
    // Prevent duplicate
    if (isFavorite(book)) {
      return true;
    }

    final favorite =
        FavoriteBookModel.fromBook(book);

    // ==========================================================
    // UPDATE UI FIRST
    // ==========================================================

    _favoriteBooks.insert(
      0,
      book,
    );

    notifyListeners();

    try {
      // ========================================================
      // SAVE FIREBASE
      // ========================================================

      final success =
          await _repository.addFavorite(
        favorite,
      );

      if (!success) {
        _favoriteBooks.removeWhere(
          (item) =>
              item.id.toString() ==
              book.id.toString(),
        );

        notifyListeners();

        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      // Rollback UI if Firebase fails
      _favoriteBooks.removeWhere(
        (item) =>
            item.id.toString() ==
            book.id.toString(),
      );

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // REMOVE FAVORITE
  // ============================================================

  Future<bool> removeFavorite(
    BookModel book,
  ) async {
    final bookId =
        book.id.toString();

    final index =
        _favoriteBooks.indexWhere(
      (item) =>
          item.id.toString() ==
          bookId,
    );

    if (index == -1) {
      return true;
    }

    // Keep backup for rollback
    final removedBook =
        _favoriteBooks[index];

    // ==========================================================
    // UPDATE UI
    // ==========================================================

    _favoriteBooks.removeAt(index);

    notifyListeners();

    try {
      // ========================================================
      // DELETE FIREBASE
      // ========================================================

      final success =
          await _repository.removeFavorite(
        bookId,
      );

      if (!success) {
        _favoriteBooks.insert(
          index,
          removedBook,
        );

        notifyListeners();

        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      // Rollback
      _favoriteBooks.insert(
        index,
        removedBook,
      );

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // TOGGLE FAVORITE
  // ============================================================

  Future<bool> toggleFavorite(
    BookModel book,
  ) async {
    if (isFavorite(book)) {
      return await removeFavorite(book);
    }

    return await addFavorite(book);
  }

  // ============================================================
  // REMOVE BY ID
  // ============================================================

  Future<bool> removeFavoriteById(
    String bookId,
  ) async {
    final index =
        _favoriteBooks.indexWhere(
      (book) =>
          book.id.toString() == bookId,
    );

    if (index == -1) {
      return true;
    }

    final book =
        _favoriteBooks[index];

    return await removeFavorite(book);
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  Future<void> clearFavorites() async {
    final backup =
        List<BookModel>.from(
      _favoriteBooks,
    );

    _favoriteBooks.clear();

    notifyListeners();

    try {
      await _repository.clearFavorites();
    } catch (e) {
      _errorMessage = e.toString();

      _favoriteBooks
        ..clear()
        ..addAll(backup);

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    _isLoading = false;

    await loadFavorites();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
}