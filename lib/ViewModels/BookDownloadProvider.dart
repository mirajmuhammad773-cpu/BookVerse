// lib/ViewModels/DownloadProvider.dart

import 'package:BookVerse/Models/BookDownloadModel.dart';
import 'package:BookVerse/Models/BookModel.dart';
import 'package:BookVerse/Repository/BookDownloadRepository.dart';
import 'package:flutter/foundation.dart';

class DownloadProvider
    extends ChangeNotifier {
  // ============================================================
  // REPOSITORY
  // ============================================================

  final DownloadRepository _repository =
      DownloadRepository();

  // ============================================================
  // STATE
  // ============================================================

  bool _isDownloading = false;

  bool _isLoading = false;

  double _downloadProgress = 0.0;

  String? _currentBookId;

  String? _errorMessage;

  List<DownloadModel>
      _downloads = [];

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isDownloading =>
      _isDownloading;

  bool get isLoading =>
      _isLoading;

  double get downloadProgress =>
      _downloadProgress;

  String? get currentBookId =>
      _currentBookId;

  String? get errorMessage =>
      _errorMessage;

  List<DownloadModel>
      get downloads =>
          List.unmodifiable(
        _downloads,
      );

  // ============================================================
  // CHECK BOOK
  // ============================================================

  Future<bool> isBookDownloaded(
    String bookId,
  ) async {
    try {
      return await _repository
          .isBookDownloaded(
        bookId,
      );
    } catch (e) {
      debugPrint(
        'Check download error: $e',
      );

      return false;
    }
  }

  // ============================================================
  // DOWNLOAD BOOK
  // ============================================================

  Future<bool> downloadBook(
    BookModel book,
  ) async {
    // ----------------------------------------------------------
    // PREVENT MULTIPLE DOWNLOADS
    // ----------------------------------------------------------

    if (_isDownloading) {
      return false;
    }

    _errorMessage = null;

    _isDownloading = true;

    _currentBookId =
        book.id.toString();

    _downloadProgress = 0.0;

    notifyListeners();

    try {
      // ========================================================
      // CHECK ALREADY DOWNLOADED
      // ========================================================

      final alreadyDownloaded =
          await _repository
              .isBookDownloaded(
        book.id.toString(),
      );

      if (alreadyDownloaded) {
        _errorMessage =
            'This book is already downloaded.';

        return false;
      }

      // ========================================================
      // DOWNLOAD
      // ========================================================

      final download =
          await _repository
              .downloadBook(
        book: book,
        onProgress: (
          received,
          total,
        ) {
          if (total > 0) {
            _downloadProgress =
                received /
                    total;

            if (_downloadProgress >
                1.0) {
              _downloadProgress =
                  1.0;
            }
          }

          notifyListeners();
        },
      );

      // ========================================================
      // SAVE FIRESTORE RECORD
      // ========================================================

      await _repository
          .saveDownloadRecord(
        download,
      );

      // ========================================================
      // ADD TO LOCAL LIST
      // ========================================================

      _downloads
          .removeWhere(
        (item) =>
            item.bookId ==
            download.bookId,
      );

      _downloads.insert(
        0,
        download,
      );

      _downloadProgress = 1.0;

      return true;
    } catch (e) {
      debugPrint(
        'Download error: $e',
      );

      _errorMessage =
          _getErrorMessage(
        e,
      );

      return false;
    } finally {
      _isDownloading = false;

      _currentBookId = null;

      notifyListeners();
    }
  }

  // ============================================================
  // LOAD DOWNLOAD HISTORY
  // ============================================================

  Future<void>
      loadDownloadHistory() async {
    _isLoading = true;

    _errorMessage = null;

    notifyListeners();

    try {
      _downloads =
          await _repository
              .getDownloadHistory();
    } catch (e) {
      debugPrint(
        'Load download history error: $e',
      );

      _errorMessage =
          _getErrorMessage(
        e,
      );
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET DOWNLOADED BOOK
  // ============================================================

  Future<DownloadModel?>
      getDownloadedBook(
    String title,
  ) async {
    try {
      return await _repository
          .getDownloadedBook(
        title,
      );
    } catch (e) {
      debugPrint(
        'Get downloaded book error: $e',
      );

      return null;
    }
  }

  // ============================================================
  // DELETE DOWNLOAD
  // ============================================================

  Future<bool>
      deleteDownloadedBook(
    String bookId,
  ) async {
    try {
      await _repository
          .deleteDownloadedBook(
        bookId,
      );

      _downloads
          .removeWhere(
        (item) =>
            item.bookId ==
            bookId,
      );

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'Delete download error: $e',
      );

      _errorMessage =
          _getErrorMessage(
        e,
      );

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  String _getErrorMessage(
    Object error,
  ) {
    final message =
        error.toString();

    if (message.contains(
      'User is not logged in',
    )) {
      return 'Please login first.';
    }

    if (message.contains(
      'SocketException',
    )) {
      return 'No internet connection.';
    }

    if (message.contains(
      '404',
    )) {
      return 'Book download link was not found.';
    }

    if (message.contains(
      '403',
    )) {
      return 'Download permission denied.';
    }

    return 'Unable to download book. Please try again.';
  }
}