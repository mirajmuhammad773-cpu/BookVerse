import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/Repository/Book-Repository.dart';
import 'package:flutter/foundation.dart';

class BookViewModel extends ChangeNotifier {
  final BookRepository repository;

  BookViewModel({
    required this.repository,
  });

  // ============================================================
  // MAX BOOKS PER SCREEN
  // ============================================================

  static const int maxBooksPerScreen = 200;

  // ============================================================
  // BOOK LISTS
  // ============================================================

  List<BookModel> _popularBooks = [];

  List<BookModel> _searchResults = [];

  List<BookModel> _fantasyBooks = [];

  List<BookModel> _fantasySearchResults = [];

  List<BookModel> _romanceBooks = [];

  List<BookModel> _romanceSearchResults = [];

  // ============================================================
  // STATES
  // ============================================================

  bool _isLoading = false;

  bool _isSearching = false;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<BookModel> get popularBooks => _popularBooks;

  List<BookModel> get searchResults => _searchResults;

  List<BookModel> get fantasyBooks => _fantasyBooks;

  List<BookModel> get fantasySearchResults =>
      _fantasySearchResults;

  List<BookModel> get romanceBooks => _romanceBooks;

  List<BookModel> get romanceSearchResults =>
      _romanceSearchResults;

  bool get isLoading => _isLoading;

  bool get isSearching => _isSearching;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // POPULAR BOOKS
  // ============================================================

  Future<void> loadPopularBooks() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final books = await repository.getPopularBooks();

      _popularBooks = books
          .cast<BookModel>()
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
  // FANTASY BOOKS
  // ============================================================

  Future<void> loadFantasyBooks() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final books =
          await repository.getFantasyBooksScenario();

      _fantasyBooks = books
          .cast<BookModel>()
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

  // ============================================================
  // SEARCH FANTASY BOOKS
  // ============================================================

  Future<void> searchFantasyBooks(
    String query,
  ) async {
    final cleanQuery = query.trim();

    // Empty search
    if (cleanQuery.isEmpty) {
      _fantasySearchResults = [];
      _isSearching = false;
      _errorMessage = null;

      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final books =
          await repository.searchFantasyBooks(
        cleanQuery,
      );

      _fantasySearchResults = books
          .cast<BookModel>()
          .take(maxBooksPerScreen)
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      _fantasySearchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ROMANCE BOOKS
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
          .cast<BookModel>()
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

  // ============================================================
  // SEARCH ROMANCE BOOKS
  // ============================================================

  Future<void> searchRomanceBooks(
    String query,
  ) async {
    final cleanQuery = query.trim();

    // Empty search
    if (cleanQuery.isEmpty) {
      _romanceSearchResults = [];
      _isSearching = false;
      _errorMessage = null;

      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final books =
          await repository.searchRomanceBooks(
        cleanQuery,
      );

      _romanceSearchResults = books
          .cast<BookModel>()
          .take(maxBooksPerScreen)
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      _romanceSearchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // ============================================================
  // GENERAL SEARCH
  // ============================================================

  Future<void> searchBooks(
    String query,
  ) async {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      _errorMessage = null;

      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final books =
          await repository.searchBooks(cleanQuery);

      _searchResults = books
          .cast<BookModel>()
          .take(maxBooksPerScreen)
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR GENERAL SEARCH
  // ============================================================

  void clearSearch() {
    _searchResults = [];
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR FANTASY SEARCH
  // ============================================================

  void clearFantasySearch() {
    _fantasySearchResults = [];
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ROMANCE SEARCH
  // ============================================================

  void clearRomanceSearch() {
    _romanceSearchResults = [];
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // RESET FANTASY
  // ============================================================

  Future<void> resetFantasyBooks() async {
    _fantasySearchResults = [];
    _errorMessage = null;

    notifyListeners();

    if (_fantasyBooks.isEmpty) {
      await loadFantasyBooks();
    }
  }

  // ============================================================
  // RESET ROMANCE
  // ============================================================

  Future<void> resetRomanceBooks() async {
    _romanceSearchResults = [];
    _errorMessage = null;

    notifyListeners();

    if (_romanceBooks.isEmpty) {
      await loadRomanceBooks();
    }
  }
}