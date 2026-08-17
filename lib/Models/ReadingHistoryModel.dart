import 'package:bookverse/Models/BookModel.dart';

class ReadingHistoryModel {
  final String bookId;
  final String title;
  final String author;
  final String imageUrl;

  /// 0.0 - 1.0
  final double progress;

  /// Last page user reached.
  final int currentPage;

  /// Total pages of the book when it was read.
  final int totalPages;

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
  }) {
    final safeTotalPages = totalPages <= 0 ? 1 : totalPages;

    final safeCurrentPage = currentPage.clamp(
      0,
      safeTotalPages - 1,
    );

    final progress = safeTotalPages <= 1
        ? 0.0
        : safeCurrentPage / (safeTotalPages - 1);

    final isCompleted =
        safeCurrentPage >= safeTotalPages - 1;

    return ReadingHistoryModel(
      bookId: book.id.toString(),
      title: book.title,
      author: book.author,
      imageUrl: book.imageUrl,
      progress: progress.clamp(0.0, 1.0),
      currentPage: safeCurrentPage,
      totalPages: safeTotalPages,
      status: isCompleted
          ? 'Completed'
          : 'In Progress',
      lastRead: DateTime.now(),
      completed: isCompleted,
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

    final lastReadValue = map['lastRead'];

    if (lastReadValue is DateTime) {
      parsedLastRead = lastReadValue;
    } else if (lastReadValue != null &&
        lastReadValue.toString().isNotEmpty) {
      try {
        if (lastReadValue.runtimeType.toString() ==
            'Timestamp') {
          parsedLastRead =
              lastReadValue.toDate() as DateTime;
        } else {
          parsedLastRead =
              DateTime.parse(
            lastReadValue.toString(),
          );
        }
      } catch (_) {
        parsedLastRead = DateTime.now();
      }
    } else {
      parsedLastRead = DateTime.now();
    }

    return ReadingHistoryModel(
      bookId:
          map['bookId']?.toString() ?? '',
      title:
          map['title']?.toString() ?? '',
      author:
          map['author']?.toString() ?? '',
      imageUrl:
          map['imageUrl']?.toString() ?? '',
      progress:
          ((map['progress'] ?? 0) as num)
              .toDouble()
              .clamp(0.0, 1.0),
      currentPage:
          ((map['currentPage'] ?? 0) as num)
              .toInt(),
      totalPages:
          ((map['totalPages'] ?? 1) as num)
              .toInt(),
      status:
          map['status']?.toString() ??
              'In Progress',
      lastRead: parsedLastRead,
      completed:
          map['completed'] == true,
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
    String? status,
    DateTime? lastRead,
    bool? completed,
  }) {
    return ReadingHistoryModel(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      progress: progress ?? this.progress,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      status: status ?? this.status,
      lastRead: lastRead ?? this.lastRead,
      completed: completed ?? this.completed,
    );
  }
}