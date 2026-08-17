// lib/Models/DownloadModel.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DownloadModel {
  // ============================================================
  // BOOK INFORMATION
  // ============================================================

  final String bookId;

  final String title;

  final String author;

  final String imageUrl;

  final String description;

  final String language;

  // ============================================================
  // DOWNLOAD INFORMATION
  // ============================================================

  final String localFilePath;

  final String downloadUrl;

  final DateTime downloadedAt;

  final int fileSize;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  const DownloadModel({
    required this.bookId,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.description,
    required this.language,
    required this.localFilePath,
    required this.downloadUrl,
    required this.downloadedAt,
    required this.fileSize,
  });

  // ============================================================
  // FROM FIRESTORE / MAP
  // ============================================================

  factory DownloadModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return DownloadModel(
      bookId:
          map['bookId']?.toString() ?? '',

      title:
          map['title']?.toString() ?? '',

      author:
          map['author']?.toString() ?? '',

      imageUrl:
          map['imageUrl']?.toString() ?? '',

      description:
          map['description']?.toString() ?? '',

      language:
          map['language']?.toString() ?? 'EN',

      localFilePath:
          map['localFilePath']?.toString() ?? '',

      downloadUrl:
          map['downloadUrl']?.toString() ?? '',

      downloadedAt:
          _parseDateTime(
        map['downloadedAt'],
      ),

      fileSize:
          _parseInt(
        map['fileSize'],
      ),
    );
  }

  // ============================================================
  // TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'description': description,
      'language': language,
      'localFilePath': localFilePath,
      'downloadUrl': downloadUrl,
      'downloadedAt':
          Timestamp.fromDate(
        downloadedAt,
      ),
      'fileSize': fileSize,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  DownloadModel copyWith({
    String? bookId,
    String? title,
    String? author,
    String? imageUrl,
    String? description,
    String? language,
    String? localFilePath,
    String? downloadUrl,
    DateTime? downloadedAt,
    int? fileSize,
  }) {
    return DownloadModel(
      bookId:
          bookId ?? this.bookId,

      title:
          title ?? this.title,

      author:
          author ?? this.author,

      imageUrl:
          imageUrl ?? this.imageUrl,

      description:
          description ?? this.description,

      language:
          language ?? this.language,

      localFilePath:
          localFilePath ??
              this.localFilePath,

      downloadUrl:
          downloadUrl ??
              this.downloadUrl,

      downloadedAt:
          downloadedAt ??
              this.downloadedAt,

      fileSize:
          fileSize ??
              this.fileSize,
    );
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  static DateTime _parseDateTime(
    dynamic value,
  ) {
    // Firestore Timestamp
    if (value is Timestamp) {
      return value.toDate();
    }

    // Dart DateTime
    if (value is DateTime) {
      return value;
    }

    // String
    if (value != null) {
      final parsed =
          DateTime.tryParse(
        value.toString(),
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }

  // ============================================================
  // INTEGER PARSER
  // ============================================================

  static int _parseInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // FILE SIZE FORMATTING
  // ============================================================

  String get formattedFileSize {
    if (fileSize <= 0) {
      return 'Unknown size';
    }

    if (fileSize < 1024) {
      return '$fileSize B';
    }

    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }

    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ============================================================
  // DOWNLOAD DATE
  // ============================================================

  String get formattedDownloadDate {
    return '${downloadedAt.day.toString().padLeft(2, '0')}/'
        '${downloadedAt.month.toString().padLeft(2, '0')}/'
        '${downloadedAt.year}';
  }

  // ============================================================
  // DOWNLOAD TIME
  // ============================================================

  String get formattedDownloadTime {
    final hour =
        downloadedAt.hour % 12 == 0
            ? 12
            : downloadedAt.hour % 12;

    final minute =
        downloadedAt.minute
            .toString()
            .padLeft(
          2,
          '0',
        );

    final period =
        downloadedAt.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // FULL DATE + TIME
  // ============================================================

  String get formattedDownloadDateTime {
    return '$formattedDownloadDate • '
        '$formattedDownloadTime';
  }
}