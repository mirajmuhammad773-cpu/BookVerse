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

  bool get isInitialized => _isInitialized;

  String? get errorMessage => _errorMessage;

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

  

  Future<void> updateReadingProgress({
    required BookModel book,
    required int currentPage,
    required int totalPages,
    required Set<int> readPages,
  }) async {
    if (totalPages <= 0 ||
        currentPage < 0 ||
        currentPage >= totalPages) {
      return;
    }

    // Preserve pages already saved, then add the pages supplied by the
    // reader. This prevents progress from being lost between sessions.
    final existingHistory =
        getBookHistory(book.id.toString());

    final pagesToSave = <int>{
      ...?existingHistory?.readPages,
      ...readPages,
    }..removeWhere(
        (page) =>
            page < 0 ||
            page >= totalPages,
      );

    final history = ReadingHistoryModel.fromBook(
      book: book,
      currentPage: currentPage,
      totalPages: totalPages,
      readPages: pagesToSave.toList(),
    );

    final existingIndex = _history.indexWhere(
      (item) => item.bookId == history.bookId,
    );

    if (existingIndex == -1) {
      _history.insert(0, history);
    } else {
      _history[existingIndex] = history;
    }

    if (_history.length > 50) {
      _history = _history.take(50).toList();
    }

    notifyListeners();

    try {
      await _repository.saveReadingHistory(history);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> markPageAsRead({
    required BookModel book,
    required int pageIndex,
    required int totalPages,
  }) async {
    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (totalPages <= 0) {
      return;
    }

    if (pageIndex < 0 ||
        pageIndex >= totalPages) {
      return;
    }

    // ==========================================================
    // GET EXISTING HISTORY
    // ==========================================================

    final existingHistory =
        getBookHistory(
      book.id.toString(),
    );

    // ==========================================================
    // EXISTING READ PAGES
    // ==========================================================

    final Set<int> readPages =
        existingHistory != null
            ? existingHistory.readPages.toSet()
            : <int>{};

    

    final bool alreadyRead =
        readPages.contains(
      pageIndex,
    );

    if (!alreadyRead) {
      readPages.add(
        pageIndex,
      );
    }

    // ==========================================================
    // REMOVE INVALID PAGES
    // ==========================================================

    readPages.removeWhere(
      (page) =>
          page < 0 ||
          page >= totalPages,
    );

    // ==========================================================
    // SORT
    // ==========================================================

    final List<int> sortedReadPages =
        readPages.toList()..sort();

   

    final double progress =
        sortedReadPages.length /
            totalPages;

    

    final bool completed =
        sortedReadPages.length >=
            totalPages;

    // ==========================================================
    // CREATE HISTORY
    // ==========================================================

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
          progress.clamp(
        0.0,
        1.0,
      ),
      currentPage:
          pageIndex,
      totalPages:
          totalPages,
      readPages:
          List.unmodifiable(
        sortedReadPages,
      ),
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
          item.title ==
          history.title,
    );

    if (existingIndex == -1) {
      // --------------------------------------------------------
      // NEW HISTORY
      // --------------------------------------------------------

      _history.insert(
        0,
        history,
      );
    } else {
      // --------------------------------------------------------
      // UPDATE EXISTING
      // --------------------------------------------------------

      _history[existingIndex] =
          history;
    }

    // ==========================================================
    // KEEP ONLY LATEST 50
    // ==========================================================

    if (_history.length > 50) {
      _history =
          _history
              .take(50)
              .toList();
    }

    // ==========================================================
    // UPDATE UI IMMEDIATELY
    // ==========================================================

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
      _errorMessage =
          e.toString();

      notifyListeners();
    }
  }

  // ============================================================
  // GET READ PAGES
  // ============================================================
  //
  // Returns pages actually read by the user.
  //
  // ============================================================

  Set<int> getReadPages(
    String title,
  ) {
    final history =
        getBookHistory(
      title,
    );

    if (history == null) {
      return <int>{};
    }

    return history.readPages.toSet();
  }

  // ============================================================
  // GET CURRENT PROGRESS
  // ============================================================

  double getBookProgress(
    String title,
  ) {
    final history =
        getBookHistory(
      title,
    );

    if (history == null) {
      return 0.0;
    }

    return history.progress
        .clamp(
      0.0,
      1.0,
    );
  }

  // ============================================================
  // GET READ PAGE COUNT
  // ============================================================

  int getReadPageCount(
    String title,
  ) {
    final history =
        getBookHistory(
      title,
    );

    if (history == null) {
      return 0;
    }

    return history.readPages.length;
  }

  // ============================================================
  // CHECK IF BOOK IS COMPLETED
  // ============================================================

  bool isBookCompleted(
    String title,
  ) {
    final history =
        getBookHistory(
      title,
    );

    if (history == null) {
      return false;
    }

    return history.completed;
  }

  // ============================================================
  // CHECK IF HISTORY EXISTS
  // ============================================================

  bool hasHistory(
    String title,
  ) {
    return _history.any(
      (item) =>
          item.bookId ==
          title,
    );
  }

  // ============================================================
  // GET BOOK HISTORY
  // ============================================================

  ReadingHistoryModel?
      getBookHistory(
    String title,
  ) {
    try {
      return _history.firstWhere(
        (item) =>
            item.bookId ==
            title,
      );
    } catch (_) {
      return null;
    }
  }

 

  Future<void> deleteHistory(
    String title,
  ) async {
    try {
      final existingHistory =
          getBookHistory(
        title,
      );

      if (existingHistory == null) {
        return;
      }

      await _repository
          .deleteReadingHistory(
        existingHistory.title,
      );

      _history.removeWhere(
        (item) =>
            item.bookId ==
            title,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage =
          e.toString();

      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR ALL HISTORY
  // ============================================================

  Future<void> clearHistory() async {
    try {
      await _repository
          .clearReadingHistory();

      _history.clear();

      notifyListeners();
    } catch (e) {
      _errorMessage =
          e.toString();

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    await loadHistory();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
}