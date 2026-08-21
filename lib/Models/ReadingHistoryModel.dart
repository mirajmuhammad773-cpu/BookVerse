// ignore_for_file: file_names

import 'package:BookVerse/Models/BookModel.dart';

class ReadingHistoryModel {
  final String bookId;
  final String title;
  final String author;
  final String imageUrl;

  /// 0.0 - 1.0
  ///
  /// Calculated from actually read pages,
  /// NOT from current page.
  final double progress;

  /// Last page user reached/opened.
  final int currentPage;

  /// Total pages of the book.
  final int totalPages;

  /// Pages that the user has actually visited/read.
  ///
  /// Page indexes are zero-based:
  /// 0 = first page
  /// 1 = second page
  /// etc.
  final List<int> readPages;

  final String status;

  final DateTime lastRead;

  final bool completed;

  const ReadingHistoryModel({
    required this.bookId,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.progress,
    required this.currentPage,
    required this.totalPages,
    required this.readPages,
    required this.status,
    required this.lastRead,
    required this.completed,
  });

  // ============================================================
  // FROM BOOK
  // ============================================================

  factory ReadingHistoryModel.fromBook({
    required BookModel book,
    required int currentPage,
    required int totalPages,
    List<int> readPages = const [],
  }) {
    final safeTotalPages =
        totalPages <= 0 ? 1 : totalPages;

    final safeCurrentPage =
        currentPage.clamp(
      0,
      safeTotalPages - 1,
    );

    final safeReadPages =
        readPages
            .where(
              (page) =>
                  page >= 0 &&
                  page < safeTotalPages,
            )
            .toSet()
            .toList()
          ..sort();

    final progress =
        safeReadPages.length /
            safeTotalPages;

    final isCompleted =
        safeReadPages.length >=
            safeTotalPages;

    return ReadingHistoryModel(
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
          safeTotalPages,
      readPages:
          List.unmodifiable(
        safeReadPages,
      ),
      status:
          isCompleted
              ? 'Completed'
              : 'In Progress',
      lastRead:
          DateTime.now(),
      completed:
          isCompleted,
    );
  }

  // ============================================================
  // FIREBASE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'progress': progress,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'readPages': readPages,
      'status': status,
      'lastRead': lastRead,
      'completed': completed,
    };
  }

  // ============================================================
  // FROM FIREBASE
  // ============================================================

  factory ReadingHistoryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    DateTime parsedLastRead;

    final lastReadValue =
        map['lastRead'];

    if (lastReadValue is DateTime) {
      parsedLastRead =
          lastReadValue;
    } else if (lastReadValue != null &&
        lastReadValue
            .toString()
            .isNotEmpty) {
      try {
        if (lastReadValue
            .runtimeType
            .toString() ==
            'Timestamp') {
          parsedLastRead =
              lastReadValue.toDate()
                  as DateTime;
        } else {
          parsedLastRead =
              DateTime.parse(
            lastReadValue
                .toString(),
          );
        }
      } catch (_) {
        parsedLastRead =
            DateTime.now();
      }
    } else {
      parsedLastRead =
          DateTime.now();
    }

    // ==========================================================
    // READ PAGES
    // ==========================================================

    final rawReadPages =
        map['readPages'];

    final List<int> parsedReadPages = [];

    if (rawReadPages is List) {
      for (final page
          in rawReadPages) {
        if (page is num) {
          parsedReadPages.add(
            page.toInt(),
          );
        }
      }
    }

    final totalPages =
        ((map['totalPages'] ?? 1)
                as num)
            .toInt()
            .clamp(1, 1000000);

    // Keep only valid pages.
    final safeReadPages =
        parsedReadPages
            .where(
              (page) =>
                  page >= 0 &&
                  page < totalPages,
            )
            .toSet()
            .toList()
          ..sort();

    // ==========================================================
    // PROGRESS
    //
    // IMPORTANT:
    // Always calculate from readPages.
    //
    // Old Firebase records may not have readPages.
    // In that case we preserve the old progress temporarily.
    // ==========================================================

    double parsedProgress;

    if (safeReadPages.isNotEmpty) {
      parsedProgress =
          safeReadPages.length /
              totalPages;
    } else {
      parsedProgress =
          ((map['progress'] ?? 0)
                  as num)
              .toDouble()
              .clamp(0.0, 1.0);
    }

    final completed =
        safeReadPages.isNotEmpty &&
            safeReadPages.length >=
                totalPages;

    return ReadingHistoryModel(
      bookId:
          map['bookId']
              ?.toString() ??
          '',
      title:
          map['title']
              ?.toString() ??
          '',
      author:
          map['author']
              ?.toString() ??
          '',
      imageUrl:
          map['imageUrl']
              ?.toString() ??
          '',
      progress:
          parsedProgress
              .clamp(0.0, 1.0),
      currentPage:
          ((map['currentPage'] ?? 0)
                  as num)
              .toInt(),
      totalPages:
          totalPages,
      readPages:
          List.unmodifiable(
        safeReadPages,
      ),
      status:
          completed
              ? 'Completed'
              : 'In Progress',
      lastRead:
          parsedLastRead,
      completed:
          completed,
    );
  }

  // ============================================================
  // COPY
  // ============================================================

  ReadingHistoryModel copyWith({
    String? bookId,
    String? title,
    String? author,
    String? imageUrl,
    double? progress,
    int? currentPage,
    int? totalPages,
    List<int>? readPages,
    String? status,
    DateTime? lastRead,
    bool? completed,
  }) {
    return ReadingHistoryModel(
      bookId:
          bookId ?? this.bookId,
      title:
          title ?? this.title,
      author:
          author ?? this.author,
      imageUrl:
          imageUrl ?? this.imageUrl,
      progress:
          progress ?? this.progress,
      currentPage:
          currentPage ??
              this.currentPage,
      totalPages:
          totalPages ??
              this.totalPages,
      readPages:
          readPages ??
              this.readPages,
      status:
          status ?? this.status,
      lastRead:
          lastRead ??
              this.lastRead,
      completed:
          completed ??
              this.completed,
    );
  }
}