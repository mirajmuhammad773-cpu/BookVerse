import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/Models/ReadingHistoryModel.dart';
import 'package:bookverse/Repository/ReadingHistoryReository.dart';
import 'package:flutter/material.dart';

class ReadingHistoryProvider extends ChangeNotifier {
  // ============================================================
  // REPOSITORY
  // ============================================================

  final ReadingHistoryRepository _repository =
      ReadingHistoryRepository();

  // ============================================================
  // DATA
  // ============================================================

  List<ReadingHistoryModel> _history = [];

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = false;

  bool _isInitialized = false;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<ReadingHistoryModel> get history =>
      List.unmodifiable(_history);

  bool get isLoading => _isLoading;

  bool get isInitialized =>
      _isInitialized;

  String? get errorMessage =>
      _errorMessage;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  ReadingHistoryProvider() {
    loadHistory();
  }

  // ============================================================
  // LOAD HISTORY
  // ============================================================

  Future<void> loadHistory() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    _errorMessage = null;

    notifyListeners();

    try {
      _history =
          await _repository.getReadingHistory();

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
  // UPDATE READING PROGRESS
  // ============================================================

  Future<void> updateReadingProgress({
    required BookModel book,
    required int currentPage,
    required int totalPages,
  }) async {
    // ==========================================================
    // IMPORTANT
    //
    // User must move from first page.
    //
    // Page index:
    // 0 = first page
    // 1 = second page
    // 2 = third page
    //
    // If user opens book and leaves on page 0,
    // NO history is created.
    // ==========================================================

    if (currentPage <= 0) {
      return;
    }

    if (totalPages <= 0) {
      return;
    }

    final safeCurrentPage =
        currentPage.clamp(
      0,
      totalPages - 1,
    );

    final progress =
        totalPages <= 1
            ? 0.0
            : safeCurrentPage /
                (totalPages - 1);

    final completed =
        safeCurrentPage >=
            totalPages - 1;

    final history =
        ReadingHistoryModel(
      bookId:
          book.id.toString(),
      title:
          book.title,
      author:
          book.author,
      imageUrl:
          book.imageUrl,
      progress:
          progress.clamp(0.0, 1.0),
      currentPage:
          safeCurrentPage,
      totalPages:
          totalPages,
      status:
          completed
              ? 'Completed'
              : 'In Progress',
      lastRead:
          DateTime.now(),
      completed:
          completed,
    );

    // ==========================================================
    // UPDATE LOCAL LIST
    // ==========================================================

    final existingIndex =
        _history.indexWhere(
      (item) =>
          item.bookId ==
          history.bookId,
    );

    if (existingIndex == -1) {
      _history.insert(
        0,
        history,
      );
    } else {
      _history[existingIndex] =
          history;
    }

    // Keep only latest 50 locally.
    if (_history.length > 50) {
      _history =
          _history.take(50).toList();
    }

    notifyListeners();

    // ==========================================================
    // FIREBASE
    // ==========================================================

    try {
      await _repository
          .saveReadingHistory(
        history,
      );
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    }
  }

  // ============================================================
  // CHECK IF HISTORY EXISTS
  // ============================================================

  bool hasHistory(
    String bookId,
  ) {
    return _history.any(
      (item) =>
          item.bookId == bookId,
    );
  }

  // ============================================================
  // GET BOOK HISTORY
  // ============================================================

  ReadingHistoryModel?
      getBookHistory(
    String bookId,
  ) {
    try {
      return _history.firstWhere(
        (item) =>
            item.bookId == bookId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteHistory(
    String bookId,
  ) async {
    try {
      await _repository
          .deleteReadingHistory(
        bookId,
      );

      _history.removeWhere(
        (item) =>
            item.bookId == bookId,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR
  // ============================================================

  Future<void> clearHistory() async {
    try {
      await _repository
          .clearReadingHistory();

      _history.clear();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    await loadHistory();
  }
}