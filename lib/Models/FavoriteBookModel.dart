// ignore_for_file: file_names

import 'package:bookverse/Models/BookModel.dart';

class FavoriteBookModel {
  final String bookId;
  final String title;
  final String author;
  final String imageUrl;
  final String textUrl;
  final String description;
  final String language;
  final int downloadCount;
  final DateTime createdAt;

  const FavoriteBookModel({
    required this.bookId,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.textUrl,
    required this.description,
    required this.language,
    required this.downloadCount,
    required this.createdAt,
  });

  // ============================================================
  // BOOK -> FAVORITE MODEL
  // ============================================================

  factory FavoriteBookModel.fromBook(BookModel book) {
    return FavoriteBookModel(
      bookId: book.id.toString(),
      title: book.title,
      author: book.author,
      imageUrl: book.imageUrl,
      textUrl: book.textUrl,
      description: book.description,
      language: book.language,
      downloadCount: book.downloadCount,
      createdAt: DateTime.now(),
    );
  }

  // ============================================================
  // FIREBASE -> MODEL
  // ============================================================

  factory FavoriteBookModel.fromMap(
    Map<String, dynamic> map,
  ) {
    DateTime createdDate = DateTime.now();

    final createdAt = map['createdAt'];

    if (createdAt is DateTime) {
      createdDate = createdAt;
    } else if (createdAt != null) {
      try {
        createdDate = DateTime.parse(
          createdAt.toString(),
        );
      } catch (_) {
        createdDate = DateTime.now();
      }
    }

    return FavoriteBookModel(
      bookId: map['bookId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      author: map['author']?.toString() ?? 'Unknown Author',
      imageUrl: map['imageUrl']?.toString() ?? '',
      textUrl: map['textUrl']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      language: map['language']?.toString() ?? '',
      downloadCount:
          int.tryParse(
                map['downloadCount']?.toString() ?? '0',
              ) ??
              0,
      createdAt: createdDate,
    );
  }

  // ============================================================
  // MODEL -> FIREBASE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'textUrl': textUrl,
      'description': description,
      'language': language,
      'downloadCount': downloadCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ============================================================
  // FAVORITE MODEL -> BOOK MODEL
  // ============================================================

  BookModel toBookModel() {
    return BookModel(
      id: int.tryParse(bookId) ?? 0,
      title: title,
      author: author,
      imageUrl: imageUrl,
      downloadCount: downloadCount,
      textUrl: textUrl,
      description: description,
      language: language,
    );
  }
}