
import 'package:BookVerse/Models/BookModel.dart';
import 'package:BookVerse/Repository/Book-Repository.dart';
import 'package:flutter/foundation.dart';

class BookViewModel extends ChangeNotifier {
  final BookRepository repository;

  BookViewModel({
    required this.repository,
  });

  static const int maxBooksPerScreen = 200;

  // ============================================================
  // BOOK LISTS
  // ============================================================

  List<BookModel> _historyBooks = [];
  List<BookModel> _historySearchResults = [];

  List<BookModel> _popularBooks = [];
  List<BookModel> _searchResults = [];

  List<BookModel> _fantasyBooks = [];
  List<BookModel> _fantasySearchResults = [];

  List<BookModel> _romanceBooks = [];
  List<BookModel> _romanceSearchResults = [];

  List<BookModel> _sciFiBooks = [];
  List<BookModel> _sciFiSearchResults = [];

  List<BookModel> _selfHelpBooks = [];
  List<BookModel> _selfHelpSearchResults = [];

  // ============================================================
  // STATES
  // ============================================================

  bool _isLoading = false;
  bool _isSearching = false;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<BookModel> get historyBooks =>
      _historyBooks;

  List<BookModel> get historySearchResults =>
      _historySearchResults;

  List<BookModel> get popularBooks =>
      _popularBooks;

  List<BookModel> get searchResults =>
      _searchResults;

  List<BookModel> get fantasyBooks =>
      _fantasyBooks;

  List<BookModel> get fantasySearchResults =>
      _fantasySearchResults;

  List<BookModel> get romanceBooks =>
      _romanceBooks;

  List<BookModel> get romanceSearchResults =>
      _romanceSearchResults;

  List<BookModel> get sciFiBooks =>
      _sciFiBooks;

  List<BookModel> get sciFiSearchResults =>
      _sciFiSearchResults;

  List<BookModel> get selfHelpBooks =>
      _selfHelpBooks;

  List<BookModel> get selfHelpSearchResults =>
      _selfHelpSearchResults;

  bool get isLoading =>
      _isLoading;

  bool get isSearching =>
      _isSearching;

  String? get errorMessage =>
      _errorMessage;

  // ============================================================
  // POPULAR
  // ============================================================

  Future<void> loadPopularBooks() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final books =
          await repository.getPopularBooks();

      _popularBooks = books
          .take(maxBooksPerScreen)
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      _popularBooks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // GENERAL SEARCH
  // ============================================================

  Future<void> searchBooks(
    String query,
  ) async {
    final cleanQuery =
        query.trim();

    if (cleanQuery.isEmpty) {
      clearSearch();
      return;
    }

    _isSearching = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _searchResults =
          await repository.searchBooks(
        cleanQuery,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // HISTORY
  // ============================================================

  Future<void> loadHistoryBooks() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final books =
          await repository.getHistoryBooks();

      _historyBooks = books
          .take(maxBooksPerScreen)
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      _historyBooks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchHistoryBooks(
    String query,
  ) async {
    final cleanQuery =
        query.trim();

    if (cleanQuery.isEmpty) {
      clearHistorySearch();
      return;
    }

    _isSearching = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _historySearchResults =
          await repository.searchHistoryBooks(
        cleanQuery,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _historySearchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearHistorySearch() {
    _historySearchResults = [];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> resetHistoryBooks() async {
    _historySearchResults = [];
    _errorMessage = null;

    notifyListeners();

    if (_historyBooks.isEmpty) {
      await loadHistoryBooks();
    }
  }

  // ============================================================
  // FANTASY
  // ============================================================

  Future<void> loadFantasyBooks() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final books =
          await repository
              .getFantasyBooksScenario();

      _fantasyBooks = books
          .take(maxBooksPerScreen)
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      _fantasyBooks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchFantasyBooks(
    String query,
  ) async {
    final cleanQuery =
        query.trim();

    if (cleanQuery.isEmpty) {
      clearFantasySearch();
      return;
    }

    _isSearching = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _fantasySearchResults =
          await repository.searchFantasyBooks(
        cleanQuery,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _fantasySearchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearFantasySearch() {
    _fantasySearchResults = [];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> resetFantasyBooks() async {
    _fantasySearchResults = [];
    _errorMessage = null;

    notifyListeners();

    if (_fantasyBooks.isEmpty) {
      await loadFantasyBooks();
    }
  }

  // ============================================================
  // ROMANCE
  // ============================================================

  Future<void> loadRomanceBooks() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final books =
          await repository.getRomanceBooks();

      _romanceBooks = books
          .take(maxBooksPerScreen)
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      _romanceBooks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchRomanceBooks(
    String query,
  ) async {
    final cleanQuery =
        query.trim();

    if (cleanQuery.isEmpty) {
      clearRomanceSearch();
      return;
    }

    _isSearching = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _romanceSearchResults =
          await repository.searchRomanceBooks(
        cleanQuery,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _romanceSearchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearRomanceSearch() {
    _romanceSearchResults = [];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> resetRomanceBooks() async {
    _romanceSearchResults = [];
    _errorMessage = null;

    notifyListeners();

    if (_romanceBooks.isEmpty) {
      await loadRomanceBooks();
    }
  }

  // ============================================================
  // SCI-FI
  // ============================================================

  Future<void> loadSciFiBooks() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final books =
          await repository.getSciFiBooks();

      _sciFiBooks = books
          .take(maxBooksPerScreen)
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      _sciFiBooks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchSciFiBooks(
    String query,
  ) async {
    final cleanQuery =
        query.trim();

    if (cleanQuery.isEmpty) {
      clearSciFiSearch();
      return;
    }

    _isSearching = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _sciFiSearchResults =
          await repository.searchSciFiBooks(
        cleanQuery,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _sciFiSearchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSciFiSearch() {
    _sciFiSearchResults = [];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> resetSciFiBooks() async {
    _sciFiSearchResults = [];
    _errorMessage = null;

    notifyListeners();

    if (_sciFiBooks.isEmpty) {
      await loadSciFiBooks();
    }
  }

  // ============================================================
  // SELF HELP
  // ============================================================

  Future<void> loadSelfHelpBooks() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final books =
          await repository.getSelfHelpBooks();

      _selfHelpBooks = books
          .take(maxBooksPerScreen)
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      _selfHelpBooks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchSelfHelpBooks(
    String query,
  ) async {
    final cleanQuery =
        query.trim();

    if (cleanQuery.isEmpty) {
      clearSelfHelpSearch();
      return;
    }

    _isSearching = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _selfHelpSearchResults =
          await repository.searchSelfHelpBooks(
        cleanQuery,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _selfHelpSearchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSelfHelpSearch() {
    _selfHelpSearchResults = [];
    _errorMessage = null;

    notifyListeners();
  }

  Future<void> resetSelfHelpBooks() async {
    _selfHelpSearchResults = [];
    _errorMessage = null;

    notifyListeners();

    if (_selfHelpBooks.isEmpty) {
      await loadSelfHelpBooks();
    }
  }
}
