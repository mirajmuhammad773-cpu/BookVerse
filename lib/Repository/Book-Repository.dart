
import 'dart:convert';

import 'package:bookverse/Models/BookModel.dart';
import 'package:http/http.dart' as http;

class BookRepository {
  static const String baseUrl = 'https://gutendex.com/books';

  // ============================================================
  // POPULAR BOOKS
  // ============================================================

  Future<List<BookModel>> getPopularBooks() async {
    final uri = Uri.parse('$baseUrl?sort=popular');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load books');
    }

    final data = jsonDecode(response.body);

    final List<dynamic> results = data['results'] ?? [];

    return results
        .map(
          (book) => BookModel.fromJson(
            book as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // ============================================================
  // FANTASY BOOKS
  // Initial screen = only 20 books
  // ============================================================

  Future<List<BookModel>> getFantasyBooksScenario() async {
    final uri = Uri.parse(
      '$baseUrl?topic=fantasy&page=1',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load fantasy books: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    final List<dynamic> results = data['results'] ?? [];

    return results
        .map(
          (book) => BookModel.fromJson(
            book as Map<String, dynamic>,
          ),
        )
        .take(20)
        .toList();
  }

  // ============================================================
  // SEARCH FANTASY BOOKS
  //
  // Example:
  //
  // w   -> books containing "w" in title
  // wa  -> books containing "wa" in title
  // war -> books containing "war" in title
  //
  // Search is NOT limited to 20.
  // Multiple Gutendex pages are checked.
  // ============================================================

  Future<List<BookModel>> searchFantasyBooks(
    String query,
  ) async {
    final cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      return [];
    }

    final List<BookModel> books = [];
    final Set<int> addedBookIds = {};

    int page = 1;

    // Prevent infinite API requests.
    // Gutendex normally has many pages, but we don't need
    // to request unlimited pages.
    const int maxPages = 10;

    while (page <= maxPages) {
      final uri = Uri.parse(
        '$baseUrl'
        '?search=${Uri.encodeQueryComponent(cleanQuery)}'
        '&page=$page',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          'Unable to search fantasy books: '
          '${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      final List<dynamic> results =
          data['results'] ?? [];

      // No more results.
      if (results.isEmpty) {
        break;
      }

      for (final item in results) {
        try {
          final bookJson =
              item as Map<String, dynamic>;

          // ----------------------------------------------------
          // GENRE DATA
          // ----------------------------------------------------

          final List<dynamic> subjects =
              bookJson['subjects'] ?? [];

          final List<dynamic> bookshelves =
              bookJson['bookshelves'] ?? [];

          final String subjectText = subjects
              .map(
                (e) => e.toString().toLowerCase(),
              )
              .join(' ');

          final String bookshelfText = bookshelves
              .map(
                (e) => e.toString().toLowerCase(),
              )
              .join(' ');

          // ----------------------------------------------------
          // FANTASY CHECK
          // ----------------------------------------------------

          final bool isFantasy =
              subjectText.contains('fantasy') ||
              bookshelfText.contains('fantasy') ||
              subjectText.contains('fairy tale') ||
              bookshelfText.contains('fairy tale') ||
              subjectText.contains('fairy tales') ||
              bookshelfText.contains('fairy tales') ||
              subjectText.contains('mythology') ||
              bookshelfText.contains('mythology') ||
              subjectText.contains('magic') ||
              bookshelfText.contains('magic');

          if (!isFantasy) {
            continue;
          }

          // ----------------------------------------------------
          // BOOK MODEL
          // ----------------------------------------------------

          final BookModel book =
              BookModel.fromJson(bookJson);

          // ----------------------------------------------------
          // TITLE SEARCH
          //
          // User query title mein honi chahiye.
          //
          // w
          // wa
          // war
          // ----------------------------------------------------

          final String title =
              book.title.toLowerCase();

          if (!title.contains(cleanQuery)) {
            continue;
          }

          // ----------------------------------------------------
          // DUPLICATE CHECK
          // ----------------------------------------------------

          if (addedBookIds.add(book.id)) {
            books.add(book);
          }
        } catch (_) {
          // Invalid book ko skip kar dein.
          continue;
        }
      }

      // --------------------------------------------------------
      // CHECK NEXT PAGE
      // --------------------------------------------------------

      final String? nextUrl =
          data['next']?.toString();

      if (nextUrl == null ||
          nextUrl.isEmpty) {
        break;
      }

      page++;
    }

    return books;
  }

  // ============================================================
  // ROMANCE BOOKS
  // Initial screen = only 20 books
  // ============================================================

  Future<List<BookModel>> getRomanceBooks() async {
    final uri = Uri.parse(
      '$baseUrl?topic=romance&page=1',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load romance books: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    final List<dynamic> results =
        data['results'] ?? [];

    return results
        .map(
          (book) => BookModel.fromJson(
            book as Map<String, dynamic>,
          ),
        )
        .take(20)
        .toList();
  }

  
  Future<List<BookModel>> searchRomanceBooks(
    String query,
  ) async {
    final cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      return [];
    }

    final List<BookModel> books = [];
    final Set<int> addedBookIds = {};

    int page = 1;

    const int maxPages = 10;

    while (page <= maxPages) {
      final uri = Uri.parse(
        '$baseUrl'
        '?search=${Uri.encodeQueryComponent(cleanQuery)}'
        '&page=$page',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          'Unable to search romance books: '
          '${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      final List<dynamic> results =
          data['results'] ?? [];

      if (results.isEmpty) {
        break;
      }

      for (final item in results) {
        try {
          final bookJson =
              item as Map<String, dynamic>;

          // ----------------------------------------------------
          // GENRE DATA
          // ----------------------------------------------------

          final List<dynamic> subjects =
              bookJson['subjects'] ?? [];

          final List<dynamic> bookshelves =
              bookJson['bookshelves'] ?? [];

          final String subjectText = subjects
              .map(
                (e) => e.toString().toLowerCase(),
              )
              .join(' ');

          final String bookshelfText = bookshelves
              .map(
                (e) => e.toString().toLowerCase(),
              )
              .join(' ');

          // ----------------------------------------------------
          // ROMANCE CHECK
          // ----------------------------------------------------

          final bool isRomance =
              subjectText.contains('romance') ||
              bookshelfText.contains('romance') ||
              subjectText.contains('love stories') ||
              bookshelfText.contains('love stories') ||
              subjectText.contains('love story') ||
              bookshelfText.contains('love story');

          if (!isRomance) {
            continue;
          }

          // ----------------------------------------------------
          // BOOK MODEL
          // ----------------------------------------------------

          final BookModel book =
              BookModel.fromJson(bookJson);

          // ----------------------------------------------------
          // TITLE SEARCH
          // ----------------------------------------------------

          final String title =
              book.title.toLowerCase();

          if (!title.contains(cleanQuery)) {
            continue;
          }

          // ----------------------------------------------------
          // DUPLICATE CHECK
          // ----------------------------------------------------

          if (addedBookIds.add(book.id)) {
            books.add(book);
          }
        } catch (_) {
          continue;
        }
      }

      // --------------------------------------------------------
      // NEXT PAGE
      // --------------------------------------------------------

      final String? nextUrl =
          data['next']?.toString();

      if (nextUrl == null ||
          nextUrl.isEmpty) {
        break;
      }

      page++;
    }

    return books;
  }

  // ============================================================
  // GENERAL SEARCH
  // ============================================================

  Future<List<BookModel>> searchBooks(
    String query,
  ) async {
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return [];
    }

    final uri = Uri.parse(
      '$baseUrl'
      '?search=${Uri.encodeQueryComponent(cleanQuery)}',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to search books');
    }

    final data = jsonDecode(response.body);

    final List<dynamic> results =
        data['results'] ?? [];

    return results
        .map(
          (book) => BookModel.fromJson(
            book as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}

