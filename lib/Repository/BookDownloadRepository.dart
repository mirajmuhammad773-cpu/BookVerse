// lib/Repository/DownloadRepository.dart

// ignore_for_file: file_names

import 'dart:io';

import 'package:BookVerse/Models/BookDownloadModel.dart';
import 'package:BookVerse/Models/BookModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:external_path/external_path.dart';

class DownloadRepository {
  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  String? get _userId {
    return _auth.currentUser?.uid;
  }

  // ============================================================
  // DOWNLOAD COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get _downloadsCollection {
    final uid = _userId;

    if (uid == null || uid.isEmpty) {
      throw Exception(
        'User is not logged in.',
      );
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('downloads');
  }

  // ============================================================
  // CHECK BOOK ALREADY DOWNLOADED
  // ============================================================

  Future<bool> isBookDownloaded(
    String title,
  ) async {
    final doc = await _downloadsCollection
        .doc(title)
        .get();

    if (!doc.exists) {
      return false;
    }

    // ----------------------------------------------------------
    // ALSO CHECK LOCAL FILE
    // ----------------------------------------------------------

    final data = doc.data();

    if (data == null) {
      return false;
    }

    final localPath =
        data['localFilePath']
                ?.toString() ??
            '';

    if (localPath.isEmpty) {
      return false;
    }

    final file =
        File(localPath);

    return await file.exists();
  }

  // ============================================================
  // GET DOWNLOADED BOOK
  // ============================================================

  Future<DownloadModel?>
      getDownloadedBook(
    String bookId,
  ) async {
    final doc = await _downloadsCollection
        .doc(bookId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return DownloadModel.fromMap(
      data,
    );
  }

  // ============================================================
  // DOWNLOAD BOOK TO PUBLIC DOWNLOAD STORAGE
  // ============================================================

  Future<DownloadModel> downloadBook({
    required BookModel book,
    required Function(
      int received,
      int total,
    ) onProgress,
  }) async {
    // ----------------------------------------------------------
    // URL
    // ----------------------------------------------------------

    final url =
        book.textUrl.trim();

    if (url.isEmpty) {
      throw Exception(
        'Book download URL is empty.',
      );
    }

    // ----------------------------------------------------------
    // PUBLIC DOWNLOAD DIRECTORY
    // ----------------------------------------------------------

    final downloadDirectory =
        await ExternalPath
            .getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOWNLOAD,
    );

    // ----------------------------------------------------------
    // BOOKVERSE DIRECTORY
    // ----------------------------------------------------------

    final booksDirectory =
        Directory(
      path.join(
        downloadDirectory,
        'BookVerse',
      ),
    );

    if (!await booksDirectory.exists()) {
      await booksDirectory.create(
        recursive: true,
      );
    }

    // ----------------------------------------------------------
    // FILE NAME
    // ----------------------------------------------------------

    final safeTitle =
        _safeFileName(
      book.title,
    );

    final fileName =
        '${book.id}_$safeTitle.txt';

    final filePath =
        path.join(
      booksDirectory.path,
      fileName,
    );

    final file =
        File(filePath);

    // ----------------------------------------------------------
    // HTTP REQUEST
    // ----------------------------------------------------------

    final request =
        http.Request(
      'GET',
      Uri.parse(url),
    );

    request.headers.addAll({
      'Accept':
          'text/plain, text/*, */*',
    });

    final response =
        await request.send();

    // ----------------------------------------------------------
    // CHECK RESPONSE
    // ----------------------------------------------------------

    if (response.statusCode != 200) {
      throw Exception(
        'Download failed. Status: ${response.statusCode}',
      );
    }

    // ----------------------------------------------------------
    // TOTAL SIZE
    // ----------------------------------------------------------

    final total =
        response.contentLength ?? 0;

    int received = 0;

    // ----------------------------------------------------------
    // WRITE FILE
    // ----------------------------------------------------------

    final sink =
        file.openWrite();

    try {
      await for (
        final chunk
        in response.stream
      ) {
        received +=
            chunk.length;

        sink.add(chunk);

        onProgress(
          received,
          total,
        );
      }
    } finally {
      await sink.flush();
      await sink.close();
    }

    // ----------------------------------------------------------
    // VERIFY FILE
    // ----------------------------------------------------------

    if (!await file.exists()) {
      throw Exception(
        'Downloaded file could not be saved.',
      );
    }

    final fileSize =
        await file.length();

    if (fileSize <= 0) {
      throw Exception(
        'Downloaded file is empty.',
      );
    }

    // ----------------------------------------------------------
    // CREATE DOWNLOAD MODEL
    // ----------------------------------------------------------

    return DownloadModel(
      bookId:
          book.id.toString(),

      title:
          book.title,

      author:
          book.author,

      imageUrl:
          book.imageUrl,

      description:
          book.description,

      language:
          book.language,

      localFilePath:
          filePath,

      downloadUrl:
          book.textUrl,

      downloadedAt:
          DateTime.now(),

      fileSize:
          fileSize,
    );
  }

  // ============================================================
  // SAVE DOWNLOAD RECORD TO FIRESTORE
  // ============================================================

  Future<void> saveDownloadRecord(
    DownloadModel download,
  ) async {
    await _downloadsCollection
        .doc(download.bookId)
        .set(
      {
        'bookId':
            download.bookId,

        'title':
            download.title,

        'author':
            download.author,

        'imageUrl':
            download.imageUrl,

        'description':
            download.description,

        'language':
            download.language,

        'localFilePath':
            download.localFilePath,

        'downloadUrl':
            download.downloadUrl,

        'downloadedAt':
            Timestamp.fromDate(
          download.downloadedAt,
        ),

        'fileSize':
            download.fileSize,
      },
    );
  }

  // ============================================================
  // GET DOWNLOAD HISTORY
  // ============================================================

  Future<List<DownloadModel>>
      getDownloadHistory() async {
    final snapshot =
        await _downloadsCollection
            .orderBy(
              'downloadedAt',
              descending: true,
            )
            .get();

    return snapshot.docs.map(
      (doc) {
        final data =
            doc.data();

        return DownloadModel
            .fromMap(
          data,
        );
      },
    ).toList();
  }

  // ============================================================
  // DELETE DOWNLOADED BOOK
  // ============================================================

  Future<void> deleteDownloadedBook(
    String bookId,
  ) async {
    final doc =
        await _downloadsCollection
            .doc(bookId)
            .get();

    // ----------------------------------------------------------
    // DELETE LOCAL FILE
    // ----------------------------------------------------------

    if (doc.exists) {
      final data =
          doc.data();

      final localPath =
          data?['localFilePath']
                  ?.toString() ??
              '';

      if (localPath.isNotEmpty) {
        final file =
            File(localPath);

        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    // ----------------------------------------------------------
    // DELETE FIRESTORE RECORD
    // ----------------------------------------------------------

    await _downloadsCollection
        .doc(bookId)
        .delete();
  }

  // ============================================================
  // GET LOCAL BOOK FILE
  // ============================================================

  Future<File?> getLocalBookFile(
    String bookId,
  ) async {
    final download =
        await getDownloadedBook(
      bookId,
    );

    if (download == null) {
      return null;
    }

    final file =
        File(
      download.localFilePath,
    );

    if (!await file.exists()) {
      return null;
    }

    return file;
  }

  // ============================================================
  // SAFE FILE NAME
  // ============================================================

  String _safeFileName(
    String value,
  ) {
    var name =
        value.trim();

    if (name.isEmpty) {
      name = 'book';
    }

    // ----------------------------------------------------------
    // REMOVE INVALID FILE NAME CHARACTERS
    // ----------------------------------------------------------

    name = name.replaceAll(
      RegExp(
        r'[<>:"/\\|?*]',
      ),
      '_',
    );

    // ----------------------------------------------------------
    // REPLACE MULTIPLE SPACES
    // ----------------------------------------------------------

    name = name.replaceAll(
      RegExp(
        r'\s+',
      ),
      '_',
    );

    // ----------------------------------------------------------
    // LIMIT FILE NAME LENGTH
    // ----------------------------------------------------------

    if (name.length > 80) {
      name =
          name.substring(
        0,
        80,
      );
    }

    return name;
  }
}