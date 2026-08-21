// ignore_for_file: file_names

import 'dart:convert';

import 'package:BookVerse/Models/BookModel.dart';
import 'package:http/http.dart' as http;

class BookRepository {
  static const String baseUrl =
      'https://gutendex.com/books';

  static const int maxBooks = 200;

  // ============================================================
  // GENERIC API REQUEST
  // ============================================================

  Future<Map<String, dynamic>> _getBooksPage(
    String url,
  ) async {
    final response = await http.get(
      Uri.parse(url),
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load books: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Invalid API response',
      );
    }

    return data;
  }

  // ============================================================
  // PARSE BOOKS
  // ============================================================

  List<BookModel> _parseBooks(
    List<dynamic> results,
  ) {
    final List<BookModel> books = [];

    for (final item in results) {
      try {
        if (item is Map<String, dynamic>) {
          books.add(
            BookModel.fromJson(item),
          );
        }
      } catch (_) {
        continue;
      }
    }

    return books;
  }

  // ============================================================
  // CATEGORY TEXT
  // ============================================================

  String _categoryText(
    Map<String, dynamic> item,
  ) {
    final subjects =
        item['subjects'] as List<dynamic>? ?? [];

    final bookshelves =
        item['bookshelves'] as List<dynamic>? ?? [];

    final subjectsText = subjects
        .map(
          (e) => e.toString().toLowerCase(),
        )
        .join(' ');

    final bookshelvesText = bookshelves
        .map(
          (e) => e.toString().toLowerCase(),
        )
        .join(' ');

    return '$subjectsText $bookshelvesText';
  }

  // ============================================================
  // SCI-FI CHECK
  // ============================================================

  bool _isSciFi(
    Map<String, dynamic> item,
  ) {
    final text = _categoryText(item);

    return text.contains('science fiction') ||
        text.contains('science-fiction') ||
        text.contains('sci-fi') ||
        text.contains('sciencefiction') ||
        text.contains('space opera') ||
        text.contains('interplanetary voyages') ||
        text.contains('space travel') ||
        text.contains('future life') ||
        text.contains('robots') ||
        text.contains('robot') ||
        text.contains('artificial intelligence') ||
        text.contains('time travel') ||
        text.contains('time machine') ||
        text.contains('utopia') ||
        text.contains('dystopia');
  }

  // ============================================================
  // FANTASY CHECK
  // ============================================================

  bool _isFantasy(
    Map<String, dynamic> item,
  ) {
    final text = _categoryText(item);

    return text.contains('fantasy') ||
        text.contains('fairy tale') ||
        text.contains('fairy tales') ||
        text.contains('mythology') ||
        text.contains('magic') ||
        text.contains('dragons') ||
        text.contains('legends');
  }

  // ============================================================
  // ROMANCE CHECK
  // ============================================================

  bool _isRomance(
    Map<String, dynamic> item,
  ) {
    final text = _categoryText(item);

    return text.contains('romance') ||
        text.contains('love stories') ||
        text.contains('love story') ||
        text.contains('courtship') ||
        text.contains('marriage stories');
  }

  // ============================================================
  // HISTORY CHECK
  // ============================================================

  bool _isHistory(
    Map<String, dynamic> item,
  ) {
    final text = _categoryText(item);

    return text.contains('history') ||
        text.contains('historical') ||
        text.contains('civilization') ||
        text.contains('ancient history') ||
        text.contains('world history') ||
        text.contains('biography');
  }

  // ============================================================
  // SELF HELP CHECK
  // ============================================================

  bool _isSelfHelp(
    Map<String, dynamic> item,
  ) {
    final text = _categoryText(item);

    return text.contains('self-help') ||
        text.contains('self help') ||
        text.contains('self-improvement') ||
        text.contains('self improvement') ||
        text.contains('personal development') ||
        text.contains('personal improvement') ||
        text.contains('self development') ||
        text.contains('character development') ||
        text.contains('life skills') ||
        text.contains('conduct of life') ||
        text.contains('success') ||
        text.contains('motivation') ||
        text.contains('happiness') ||
        text.contains('psychology');
  }

  // ============================================================
  // POPULAR BOOKS
  // ============================================================

  Future<List<BookModel>> getPopularBooks() async {
    final List<BookModel> books = [];

    String? nextUrl =
        '$baseUrl?sort=popular';

    int pagesChecked = 0;

    while (
        nextUrl != null &&
        books.length < maxBooks &&
        pagesChecked < 20) {
      pagesChecked++;

      final data =
          await _getBooksPage(nextUrl);

      final results =
          data['results'] as List<dynamic>? ?? [];

      books.addAll(
        _parseBooks(results),
      );

      nextUrl =
          data['next']?.toString();
    }

    return books
        .take(maxBooks)
        .toList();
  }

  // ============================================================
  // HISTORY BOOKS
  // ============================================================

  Future<List<BookModel>> getHistoryBooks() async {
    return _getCategoryBooks(
      search: 'history',
      checker: _isHistory,
    );
  }

  // ============================================================
  // SEARCH HISTORY
  // ============================================================

  Future<List<BookModel>> searchHistoryBooks(
    String query,
  ) async {
    return _searchCategoryBooks(
      query,
      _isHistory,
    );
  }

  // ============================================================
  // FANTASY BOOKS
  // ============================================================

  Future<List<BookModel>>
      getFantasyBooksScenario() async {
    return _getCategoryBooks(
      search: 'fantasy',
      checker: _isFantasy,
    );
  }

  // ============================================================
  // SEARCH FANTASY
  // ============================================================

  Future<List<BookModel>> searchFantasyBooks(
    String query,
  ) async {
    return _searchCategoryBooks(
      query,
      _isFantasy,
    );
  }

  // ============================================================
  // ROMANCE BOOKS
  // ============================================================

  Future<List<BookModel>> getRomanceBooks() async {
    return _getCategoryBooks(
      search: 'romance',
      checker: _isRomance,
    );
  }

  // ============================================================
  // SEARCH ROMANCE
  // ============================================================

  Future<List<BookModel>> searchRomanceBooks(
    String query,
  ) async {
    return _searchCategoryBooks(
      query,
      _isRomance,
    );
  }

  // ============================================================
  // SCI-FI BOOKS
  // ============================================================

  Future<List<BookModel>> getSciFiBooks() async {
    return _getCategoryBooks(
      search: 'science fiction',
      checker: _isSciFi,
    );
  }

  // ============================================================
  // SEARCH SCI-FI
  // ============================================================

  Future<List<BookModel>> searchSciFiBooks(
    String query,
  ) async {
    return _searchCategoryBooks(
      query,
      _isSciFi,
    );
  }

  // ============================================================
  // SELF HELP BOOKS
  // ============================================================

  Future<List<BookModel>> getSelfHelpBooks() async {
    return _getCategoryBooks(
      search: 'self',
      checker: _isSelfHelp,
    );
  }

  // ============================================================
  // SEARCH SELF HELP
  // ============================================================

  Future<List<BookModel>> searchSelfHelpBooks(
    String query,
  ) async {
    return _searchCategoryBooks(
      query,
      _isSelfHelp,
    );
  }

  // ============================================================
  // GENERIC CATEGORY LOADER
  // ============================================================

  Future<List<BookModel>> _getCategoryBooks({
    required String search,
    required bool Function(
      Map<String, dynamic>,
    ) checker,
  }) async {
    final List<BookModel> books = [];

    String? nextUrl =
        '$baseUrl?search=${Uri.encodeQueryComponent(search)}';

    int pagesChecked = 0;

    while (
        nextUrl != null &&
        books.length < maxBooks &&
        pagesChecked < 20) {
      pagesChecked++;

      final data =
          await _getBooksPage(nextUrl);

      final results =
          data['results'] as List<dynamic>? ?? [];

      for (final item in results) {
        try {
          if (item is! Map<String, dynamic>) {
            continue;
          }

          if (!checker(item)) {
            continue;
          }

          books.add(
            BookModel.fromJson(item),
          );

          if (books.length >= maxBooks) {
            break;
          }
        } catch (_) {
          continue;
        }
      }

      nextUrl =
          data['next']?.toString();
    }

    return books
        .take(maxBooks)
        .toList();
  }

  // ============================================================
  // GENERIC CATEGORY SEARCH
  // ============================================================

  Future<List<BookModel>> _searchCategoryBooks(
    String query,
    bool Function(
      Map<String, dynamic>,
    ) checker,
  ) async {
    final cleanQuery =
        query.trim();

    if (cleanQuery.isEmpty) {
      return [];
    }

    final List<BookModel> books = [];

    String? nextUrl =
        '$baseUrl?search=${Uri.encodeQueryComponent(cleanQuery)}';

    int pagesChecked = 0;

    while (
        nextUrl != null &&
        books.length < maxBooks &&
        pagesChecked < 20) {
      pagesChecked++;

      final data =
          await _getBooksPage(nextUrl);

      final results =
          data['results'] as List<dynamic>? ?? [];

      for (final item in results) {
        try {
          if (item is! Map<String, dynamic>) {
            continue;
          }

          if (!checker(item)) {
            continue;
          }

          books.add(
            BookModel.fromJson(item),
          );

          if (books.length >= maxBooks) {
            break;
          }
        } catch (_) {
          continue;
        }
      }

      nextUrl =
          data['next']?.toString();
    }

    return books
        .take(maxBooks)
        .toList();
  }

  // ============================================================
  // GENERAL SEARCH
  // ============================================================

  Future<List<BookModel>> searchBooks(
    String query,
  ) async {
    final cleanQuery =
        query.trim();

    if (cleanQuery.isEmpty) {
      return [];
    }

    final List<BookModel> books = [];

    String? nextUrl =
        '$baseUrl?search=${Uri.encodeQueryComponent(cleanQuery)}';

    int pagesChecked = 0;

    while (
        nextUrl != null &&
        books.length < maxBooks &&
        pagesChecked < 20) {
      pagesChecked++;

      final data =
          await _getBooksPage(nextUrl);

      final results =
          data['results'] as List<dynamic>? ?? [];

      books.addAll(
        _parseBooks(results),
      );

      nextUrl =
          data['next']?.toString();
    }

    return books
        .take(maxBooks)
        .toList();
  }
}

