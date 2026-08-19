// lib/Screens/ReaderScreen.dart
// ignore_for_file: unused_element

import 'dart:convert';

import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/ViewModels/AchievementProvider.dart';
import 'package:bookverse/ViewModels/BookDownloadProvider.dart';
import 'package:bookverse/ViewModels/FavoriteBookProvider.dart';
import 'package:bookverse/ViewModels/ReadingGoalProvider.dart';
import 'package:bookverse/ViewModels/ReadingHistoryProvider.dart';
import 'package:bookverse/Widgets/Favoritebookwidget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ReaderScreen extends StatefulWidget {
  final BookModel book;

  const ReaderScreen({
    super.key,
    required this.book,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with WidgetsBindingObserver {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final PageController _pageController = PageController();

  // ============================================================
  // READER STATE
  // ============================================================

  int _currentPage = 0;

  int _savedPage = 0;

  double _fontSize = 17;

  static const double _minFontSize = 14;

  static const double _maxFontSize = 24;

  bool _isDayMode = true;

  bool _isLoading = true;

  String? _errorMessage;

  List<BookPageData> _pages = [];

  // ============================================================
  // ACTUALLY READ PAGES
  // ============================================================
  //
  // IMPORTANT:
  //
  // Opening page 1 does NOT make page 1 read.
  //
  // When user moves:
  //
  // Page 1 -> Page 2
  //
  // Page 1 becomes read.
  //
  // When user reaches the last page,
  // the last page is also marked as read.
  //
  // Therefore skipped pages are NOT counted.
  // ============================================================

  final Set<int> _readPages = {};

  // ============================================================
  // CHAPTER TRACKING
  // ============================================================

  final Set<int> _completedChapterIndexes = {};

  final List<int> _pageChapterIndexes = [];

  int _totalChapters = 0;

  // ============================================================
  // COMPLETION
  // ============================================================

  bool _completionHandled = false;

  bool _completionInProgress = false;

  // ============================================================
  // READING SESSION
  // ============================================================

  DateTime? _readingSessionStart;

  bool _savingReadingSession = false;

  // ============================================================
  // READING HISTORY
  // ============================================================

  bool _historyUpdateInProgress = false;

  int _lastHistoryPageSaved = -1;

  // ============================================================
  // DOWNLOAD
  // ============================================================

  bool _isBookDownloaded = false;

  bool _checkingDownload = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _checkDownloadStatus();

    _loadBook();
  }

  // ============================================================
  // CHECK DOWNLOAD STATUS
  // ============================================================

  Future<void> _checkDownloadStatus() async {
    try {
      final downloadProvider = context.read<DownloadProvider>();

      final downloaded = await downloadProvider.isBookDownloaded(
        widget.book.id.toString(),
      );

      if (!mounted) return;

      setState(() {
        _isBookDownloaded = downloaded;
        _checkingDownload = false;
      });
    } catch (e) {
      debugPrint('Download status error: $e');

      if (!mounted) return;

      setState(() {
        _checkingDownload = false;
      });
    }
  }

  // ============================================================
  // DOWNLOAD BOOK
  // ============================================================

  Future<void> _downloadBook() async {
    if (!mounted) return;

    final downloadProvider = context.read<DownloadProvider>();

    if (_isBookDownloaded) {
      _showMessage(
        'This book is already downloaded.',
      );

      return;
    }

    if (downloadProvider.isDownloading) {
      _showMessage(
        'A book is already downloading.',
      );

      return;
    }

    final success = await downloadProvider.downloadBook(
      widget.book,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isBookDownloaded = true;
      });

      _showMessage(
        '✓ Book downloaded successfully.',
      );
    } else {
      _showMessage(
        downloadProvider.errorMessage ??
            'Unable to download book.',
      );
    }
  }

  // ============================================================
  // LOAD BOOK
  // ============================================================

  Future<void> _loadBook() async {
    final url = widget.book.textUrl.trim();

    if (url.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;

        _errorMessage =
            'This book is currently not available for reading.';
      });

      return;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Unable to load book. Status: ${response.statusCode}',
        );
      }

      final text = utf8.decode(
        response.bodyBytes,
        allowMalformed: true,
      );

      final pages = _createPages(text);

      if (!mounted) return;

      // ==========================================================
      // LOAD SAVED HISTORY
      // ==========================================================

      final historyProvider =
          context.read<ReadingHistoryProvider>();

      final savedHistory = historyProvider.getBookHistory(
        widget.book.id.toString(),
      );

      int savedPage = savedHistory?.currentPage ?? 0;

      // ==========================================================
      // RESTORE ACTUALLY READ PAGES
      // ==========================================================

      _readPages.clear();

      if (savedHistory != null) {
        for (final page in savedHistory.readPages) {
          if (page >= 0 && page < pages.length) {
            _readPages.add(page);
          }
        }
      }

      // ==========================================================
      // SAFE CURRENT PAGE
      // ==========================================================

      if (pages.isEmpty) {
        savedPage = 0;
      } else {
        savedPage = savedPage.clamp(
          0,
          pages.length - 1,
        );
      }

      _savedPage = savedPage;

      // ==========================================================
      // RESET CHAPTER TRACKING
      // ==========================================================

      _completedChapterIndexes.clear();

      // Rebuild completed chapters from actually read pages.
      //
      // IMPORTANT:
      // We do NOT automatically complete chapters from current page.
      //
      _restoreCompletedChapters();

      // ==========================================================
      // COMPLETION STATE
      // ==========================================================
      //
      // IMPORTANT:
      //
      // ReadingHistory.completed should NOT control
      // AchievementProvider completion.
      //
      // AchievementProvider has its own completedBookIds.
      //
      // Therefore start this ReaderScreen completion state fresh.
      //
      // ==========================================================

      _completionHandled = false;

      _completionInProgress = false;

      // ==========================================================
      // READING SESSION
      // ==========================================================

      _readingSessionStart = null;

      _savingReadingSession = false;

      // ==========================================================
      // HISTORY SAVE STATE
      // ==========================================================

      _lastHistoryPageSaved = -1;

      _historyUpdateInProgress = false;

      // ==========================================================
      // SET STATE
      // ==========================================================

      setState(() {
        _pages = pages;

        _isLoading = false;

        _errorMessage = null;

        _currentPage = savedPage;
      });

      // ==========================================================
      // OPEN SAVED PAGE
      // ==========================================================

      if (_pages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            if (!mounted) return;

            if (!_pageController.hasClients) {
              return;
            }

            if (_savedPage >= 0 &&
                _savedPage < _pages.length) {
              _pageController.jumpToPage(
                _savedPage,
              );
            }
          },
        );

        // ========================================================
        // START READING SESSION
        // ========================================================

        _startReadingSession();
      }
    } catch (e) {
      debugPrint(
        'Book loading error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;

        _errorMessage =
            'Unable to load this book. Please try again.';
      });
    }
  }

  // ============================================================
  // RESTORE COMPLETED CHAPTERS
  // ============================================================

  void _restoreCompletedChapters() {
    if (_pages.isEmpty) {
      return;
    }

    final Map<int, List<int>> chapterPages = {};

    for (int i = 0; i < _pages.length; i++) {
      final chapterIndex = _pages[i].chapterIndex;

      chapterPages
          .putIfAbsent(
            chapterIndex,
            () => [],
          )
          .add(i);
    }

    for (final entry in chapterPages.entries) {
      final pages = entry.value;

      if (pages.isEmpty) {
        continue;
      }

      final allRead = pages.every(
        (pageIndex) => _readPages.contains(pageIndex),
      );

      if (allRead) {
        _completedChapterIndexes.add(
          entry.key,
        );
      }
    }
  }

  // ============================================================
  // START READING SESSION
  // ============================================================

  void _startReadingSession() {
    if (!mounted) return;

    if (_readingSessionStart != null) {
      return;
    }

    _readingSessionStart = DateTime.now();
  }

  // ============================================================
  // SAVE READING SESSION
  // ============================================================

  Future<void> _saveReadingSession() async {
    if (_readingSessionStart == null) {
      return;
    }

    if (_savingReadingSession) {
      return;
    }

    _savingReadingSession = true;

    final DateTime sessionStart = _readingSessionStart!;

    try {
      final DateTime sessionEnd = DateTime.now();

      final Duration duration = sessionEnd.difference(
        sessionStart,
      );

      final int minutes = duration.inMinutes;

      _readingSessionStart = null;

      if (minutes <= 0) {
        return;
      }

      if (!mounted) {
        return;
      }

      final readingGoalProvider =
          context.read<ReadingGoalProvider>();

      await readingGoalProvider.saveReadingSession(
        book: widget.book,
        minutes: minutes,
      );

      debugPrint(
        'Reading session saved: $minutes minutes',
      );
    } catch (e) {
      debugPrint(
        'Reading session save error: $e',
      );
    } finally {
      _savingReadingSession = false;
    }
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    super.didChangeAppLifecycleState(
      state,
    );

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveReadingSession();

      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (_pages.isNotEmpty && mounted) {
        _startReadingSession();
      }
    }
  }

  // ============================================================
  // CREATE PAGES
  // ============================================================

  List<BookPageData> _createPages(
    String text,
  ) {
    String cleanText = text;

    const startMarker =
        '*** START OF THE PROJECT GUTENBERG EBOOK';

    const endMarker =
        '*** END OF THE PROJECT GUTENBERG EBOOK';

    // ==========================================================
    // REMOVE START MARKER
    // ==========================================================

    final startIndex = cleanText.indexOf(
      startMarker,
    );

    if (startIndex != -1) {
      final firstNewLine = cleanText.indexOf(
        '\n',
        startIndex,
      );

      if (firstNewLine != -1) {
        cleanText = cleanText.substring(
          firstNewLine + 1,
        );
      }
    }

    // ==========================================================
    // REMOVE END MARKER
    // ==========================================================

    final endIndex = cleanText.indexOf(
      endMarker,
    );

    if (endIndex != -1) {
      cleanText = cleanText.substring(
        0,
        endIndex,
      );
    }

    cleanText = cleanText
        .replaceAll(
          '\r\n',
          '\n',
        )
        .replaceAll(
          '\r',
          '\n',
        )
        .trim();

    if (cleanText.isEmpty) {
      return [];
    }

    // ==========================================================
    // CHAPTER DETECTION
    // ==========================================================

    final lines = cleanText.split('\n');

    final List<_TextBlock> blocks = [];

    String currentChapter = 'READING';

    String currentTitle = '';

    final StringBuffer paragraphBuffer = StringBuffer();

    void flushParagraph() {
      final paragraph = paragraphBuffer.toString().trim();

      if (paragraph.isNotEmpty) {
        blocks.add(
          _TextBlock(
            chapter: currentChapter,
            title: currentTitle,
            text: paragraph,
          ),
        );
      }

      paragraphBuffer.clear();
    }

    for (final rawLine in lines) {
      final line = rawLine.trim();

      if (line.isEmpty) {
        flushParagraph();

        continue;
      }

      final upper = line.toUpperCase();

      if (_looksLikeChapter(upper)) {
        flushParagraph();

        currentChapter = line;

        currentTitle = '';

        continue;
      }

      if (paragraphBuffer.isNotEmpty) {
        paragraphBuffer.write(' ');
      }

      paragraphBuffer.write(line);
    }

    flushParagraph();

    // ==========================================================
    // NO BLOCKS
    // ==========================================================

    if (blocks.isEmpty) {
      return _splitPlainText(
        cleanText,
      );
    }

    // ==========================================================
    // CREATE CHAPTER PAGES
    // ==========================================================

    const int charactersPerPage = 2600;

    final List<BookPageData> result = [];

    _pageChapterIndexes.clear();

    final Map<String, int> chapterIndexes = {};

    int nextChapterIndex = 0;

    for (final block in blocks) {
      if (!chapterIndexes.containsKey(block.chapter)) {
        chapterIndexes[block.chapter] = nextChapterIndex;

        nextChapterIndex++;
      }

      final chapterIndex = chapterIndexes[block.chapter]!;

      final chunks = _splitText(
        block.text,
        charactersPerPage,
      );

      for (final chunk in chunks) {
        result.add(
          BookPageData(
            chapterLabel: block.chapter,
            title: block.title.isEmpty
                ? widget.book.title
                : block.title,
            pageNumber: result.length + 1,
            totalPages: 0,
            pagesLeftInChapter: 0,
            chapterIndex: chapterIndex,
            paragraphs: [
              chunk,
            ],
          ),
        );

        _pageChapterIndexes.add(
          chapterIndex,
        );
      }
    }

    _totalChapters = nextChapterIndex;

    final totalPages = result.length;

    // ==========================================================
    // LAST PAGE OF EACH CHAPTER
    // ==========================================================

    final Map<int, int> lastPageForChapter = {};

    for (int i = 0; i < result.length; i++) {
      final chapterIndex = result[i].chapterIndex;

      lastPageForChapter[chapterIndex] = i;
    }

    // ==========================================================
    // FINAL PAGE DATA
    // ==========================================================

    return result.map(
      (page) {
        final chapterLastPageIndex =
            lastPageForChapter[page.chapterIndex]!;

        final currentIndex = page.pageNumber - 1;

        final pagesLeft =
            chapterLastPageIndex - currentIndex;

        return BookPageData(
          chapterLabel: page.chapterLabel,
          title: page.title,
          pageNumber: page.pageNumber,
          totalPages: totalPages,
          pagesLeftInChapter: pagesLeft < 0
              ? 0
              : pagesLeft,
          chapterIndex: page.chapterIndex,
          paragraphs: page.paragraphs,
        );
      },
    ).toList();
  }

  // ============================================================
  // CHAPTER DETECTION
  // ============================================================

  bool _looksLikeChapter(
    String line,
  ) {
    return line.startsWith('CHAPTER ') ||
        line.startsWith('BOOK ') ||
        line.startsWith('PART ') ||
        RegExp(
          r'^CHAPTER\s+[IVXLCDM0-9]+',
        ).hasMatch(line);
  }

  // ============================================================
  // SPLIT PLAIN TEXT
  // ============================================================

  List<BookPageData> _splitPlainText(
    String text,
  ) {
    const charactersPerPage = 2600;

    final chunks = _splitText(
      text,
      charactersPerPage,
    );

    final totalPages = chunks.length;

    _totalChapters = totalPages > 0 ? 1 : 0;

    _pageChapterIndexes.clear();

    if (totalPages > 0) {
      _pageChapterIndexes.addAll(
        List<int>.filled(
          totalPages,
          0,
        ),
      );
    }

    return List.generate(
      totalPages,
      (index) {
        return BookPageData(
          chapterLabel: 'READING',
          title: widget.book.title,
          pageNumber: index + 1,
          totalPages: totalPages,
          pagesLeftInChapter:
              totalPages - index - 1,
          chapterIndex: 0,
          paragraphs: [
            chunks[index],
          ],
        );
      },
    );
  }

  // ============================================================
  // TEXT SPLITTER
  // ============================================================

  List<String> _splitText(
    String text,
    int maxCharacters,
  ) {
    final List<String> result = [];

    String remaining = text.trim();

    while (remaining.isNotEmpty) {
      if (remaining.length <= maxCharacters) {
        result.add(
          remaining,
        );

        break;
      }

      int splitIndex = remaining.lastIndexOf(
        '\n',
        maxCharacters,
      );

      if (splitIndex < maxCharacters ~/ 2) {
        splitIndex = remaining.lastIndexOf(
          ' ',
          maxCharacters,
        );
      }

      if (splitIndex <= 0) {
        splitIndex = maxCharacters;
      }

      final chunk = remaining
          .substring(
            0,
            splitIndex,
          )
          .trim();

      if (chunk.isNotEmpty) {
        result.add(chunk);
      }

      remaining = remaining
          .substring(
            splitIndex,
          )
          .trim();
    }

    return result;
  }

  // ============================================================
  // PAGE CHANGE
  // ============================================================
  //
  // IMPORTANT:
  //
  // We mark the PREVIOUS page as read.
  //
  // Example:
  //
  // Page 1 -> Page 2
  //
  // Page 1 becomes read.
  //
  // We do NOT mark every skipped page as read.
  //
  // ============================================================

  Future<void> _onPageChanged(
    int newPageIndex,
  ) async {
    if (!mounted) return;

    if (_pages.isEmpty) {
      return;
    }

    if (newPageIndex < 0 ||
        newPageIndex >= _pages.length) {
      return;
    }

    // ==========================================================
    // PREVIOUS PAGE BECOMES READ
    // ==========================================================

    final previousPageIndex = _currentPage;

    if (previousPageIndex >= 0 &&
        previousPageIndex < _pages.length &&
        previousPageIndex != newPageIndex) {
      _readPages.add(
        previousPageIndex,
      );
    }

    // ==========================================================
    // UPDATE CURRENT PAGE
    // ==========================================================

    setState(() {
      _currentPage = newPageIndex;
    });

    // ==========================================================
    // LAST PAGE
    //
    // Last page must also become read.
    //
    // ==========================================================

    if (newPageIndex == _pages.length - 1) {
      _readPages.add(
        newPageIndex,
      );
    }

    // ==========================================================
    // SAVE HISTORY
    // ==========================================================

    await _saveReadingHistoryProgress(
      newPageIndex,
    );

    // ==========================================================
    // CHECK CHAPTER
    // ==========================================================

    _checkChapterProgress(
      newPageIndex,
    );
  }

  // ============================================================
  // SAVE READING HISTORY
  // ============================================================

  Future<void> _saveReadingHistoryProgress(
    int pageIndex,
  ) async {
    if (!mounted) return;

    if (_pages.isEmpty) {
      return;
    }

    if (pageIndex < 0 ||
        pageIndex >= _pages.length) {
      return;
    }

    // ==========================================================
    // DO NOT CREATE HISTORY ON FIRST PAGE ALONE
    //
    // If user opened page 1 and immediately exits,
    // no reading history should be created.
    //
    // ==========================================================

    if (pageIndex == 0 &&
        _readPages.isEmpty) {
      return;
    }

    if (_historyUpdateInProgress) {
      return;
    }

    _historyUpdateInProgress = true;

    try {
      final historyProvider =
          context.read<ReadingHistoryProvider>();

      await historyProvider.updateReadingProgress(
        book: widget.book,
        currentPage: pageIndex,
        totalPages: _pages.length,
        readPages: Set<int>.from(
          _readPages,
        ),
      );

      _lastHistoryPageSaved = pageIndex;
    } catch (e) {
      debugPrint(
        'Reading history error: $e',
      );
    } finally {
      _historyUpdateInProgress = false;
    }
  }

  // ============================================================
  // CHECK CHAPTER PROGRESS
  // ============================================================

  void _checkChapterProgress(
    int pageIndex,
  ) {
    if (_pages.isEmpty) {
      return;
    }

    if (pageIndex < 0 ||
        pageIndex >= _pages.length) {
      return;
    }

    final page = _pages[pageIndex];

    final chapterIndex = page.chapterIndex;

    // ==========================================================
    // GET ALL PAGES OF THIS CHAPTER
    // ==========================================================

    final chapterPages = <int>[];

    for (int i = 0; i < _pages.length; i++) {
      if (_pages[i].chapterIndex == chapterIndex) {
        chapterPages.add(i);
      }
    }

    if (chapterPages.isEmpty) {
      return;
    }

    // ==========================================================
    // CHAPTER COMPLETE ONLY IF EVERY PAGE
    // WAS ACTUALLY READ
    // ==========================================================

    final chapterCompleted = chapterPages.every(
      (pageIndex) => _readPages.contains(
        pageIndex,
      ),
    );

    if (chapterCompleted) {
      if (!_completedChapterIndexes.contains(
        chapterIndex,
      )) {
        _completedChapterIndexes.add(
          chapterIndex,
        );

        if (mounted) {
          setState(() {});
        }
      }
    }

    // ==========================================================
    // CHECK WHOLE BOOK
    // ==========================================================

    _checkWholeBookCompletion(
      pageIndex,
    );
  }

  // ============================================================
  // CHECK WHOLE BOOK COMPLETION
  // ============================================================

  void _checkWholeBookCompletion(
    int pageIndex,
  ) {
    if (_pages.isEmpty) {
      return;
    }

    if (pageIndex < 0 ||
        pageIndex >= _pages.length) {
      return;
    }

    // ==========================================================
    // MUST BE ON LAST PAGE
    // ==========================================================

    final isLastPage =
        pageIndex == _pages.length - 1;

    if (!isLastPage) {
      return;
    }

    // ==========================================================
    // LAST PAGE MUST BE READ
    // ==========================================================

    _readPages.add(
      pageIndex,
    );

    // ==========================================================
    // ALL PAGES MUST BE READ
    // ==========================================================

    final allPagesRead =
        _readPages.length >= _pages.length;

    if (!allPagesRead) {
      _showMessage(
        'Please read all pages before completing this book.',
      );

      return;
    }

    // ==========================================================
    // ALL CHAPTERS MUST BE COMPLETE
    // ==========================================================

    final allChaptersCompleted =
        _totalChapters > 0 &&
        _completedChapterIndexes.length >=
            _totalChapters;

    if (!allChaptersCompleted) {
      _showMessage(
        'Please read all chapters before completing this book.',
      );

      return;
    }

    // ==========================================================
    // COMPLETE BOOK
    // ==========================================================

    _handleBookCompletion();
  }

  // ============================================================
  // BOOK COMPLETION
  // ============================================================

  Future<void> _handleBookCompletion() async {
    if (_completionHandled) {
      return;
    }

    if (_completionInProgress) {
      return;
    }

    if (_pages.isEmpty) {
      return;
    }

    if (_currentPage != _pages.length - 1) {
      return;
    }

    // ==========================================================
    // FINAL SAFETY
    // ==========================================================

    _readPages.add(
      _currentPage,
    );

    if (_readPages.length < _pages.length) {
      return;
    }

    if (_completedChapterIndexes.length <
        _totalChapters) {
      return;
    }

    _completionInProgress = true;

    try {
      // ========================================================
      // FINAL HISTORY SAVE
      // ========================================================

      await _saveReadingHistoryProgress(
        _currentPage,
      );

      // ========================================================
      // FINAL READING TIME
      // ========================================================

      await _saveReadingSession();

      if (!mounted) {
        _completionInProgress = false;
        return;
      }

      // ========================================================
      // PROVIDERS
      // ========================================================

      final readingGoalProvider =
          context.read<ReadingGoalProvider>();

      final achievementProvider =
          context.read<AchievementProvider>();

      // ========================================================
      // READING GOAL
      // FIRST COMPLETION ONLY
      // ========================================================

      final readingGoalAlreadyCompleted =
          readingGoalProvider.isBookCompleted(
        widget.book.id.toString(),
      );

      bool readingGoalSuccess = true;

      if (!readingGoalAlreadyCompleted) {
        readingGoalSuccess =
            await readingGoalProvider.addCompletedBook(
          widget.book.id.toString(),
        );
      }

      // ========================================================
      // ACHIEVEMENT
      // FIRST COMPLETION ONLY
      // ========================================================

      final achievementAlreadyCompleted =
          achievementProvider.isBookCompleted(
        widget.book,
      );

      bool achievementSuccess = true;

      if (!achievementAlreadyCompleted) {
        achievementSuccess =
            await achievementProvider.completeBook(
          widget.book,
        );
      }

      // ========================================================
      // CHECK MOUNTED
      // ========================================================

      if (!mounted) {
        _completionInProgress = false;
        return;
      }

      // ========================================================
      // SUCCESS
      // ========================================================

      if (readingGoalSuccess &&
          achievementSuccess) {
        _completionHandled = true;

        _completionInProgress = false;

        _showMessage(
          '🎉 Your book is complete! Achievement updated.',
        );

        return;
      }

      // ========================================================
      // FAILURE
      // ========================================================

      _completionInProgress = false;

      _completionHandled = false;

      _showMessage(
        readingGoalProvider.errorMessage ??
            achievementProvider.errorMessage ??
            'Unable to save book completion.',
      );
    } catch (e) {
      debugPrint(
        'Book completion error: $e',
      );

      _completionInProgress = false;

      _completionHandled = false;

      if (mounted) {
        _showMessage(
          'Unable to save book completion.',
        );
      }
    }
  }

  // ============================================================
  // FAVORITE
  // ============================================================

  void _toggleFavorite(
    FavouriteBooksProvider provider,
  ) {
    final wasFavorite = provider.isFavorite(
      widget.book,
    );

    provider.toggleFavorite(
      widget.book,
    );

    _showMessage(
      wasFavorite
          ? 'Removed from favourites'
          : 'Added to favourites',
    );
  }

  // ============================================================
  // ACTIVE PAGE
  // ============================================================

  BookPageData? get _activePage {
    if (_pages.isEmpty) {
      return null;
    }

    if (_currentPage >= _pages.length) {
      return _pages.last;
    }

    return _pages[_currentPage];
  }

  // ============================================================
  // READING PROGRESS
  // ============================================================

  double get _readingProgress {
    if (_pages.isEmpty) {
      return 0.0;
    }

    if (_readPages.isEmpty) {
      return 0.0;
    }

    return (_readPages.length / _pages.length).clamp(
      0.0,
      1.0,
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(
            seconds: 2,
          ),
        ),
      );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _pageController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final bgColor = _isDayMode
        ? const Color(0xFFFBF3E7)
        : const Color(0xFF211D18);

    final iconColor = _isDayMode
        ? const Color(0xFF2B2620)
        : const Color(0xFFEDE3D3);

    final textColor = _isDayMode
        ? const Color(0xFF2B2620)
        : const Color(0xFFEDE3D3);

    const mutedColor = Color(0xFF8A8375);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // TOP BAR
            // ==================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  // ==================================================
                  // BACK
                  // ==================================================

                  IconButton(
                    onPressed: () async {
                      // ==================================================
                      // IMPORTANT:
                      //
                      // If user is still on first page,
                      // don't create reading history.
                      //
                      // If user has moved forward,
                      // current page is considered read on exit.
                      // ==================================================

                      if (_pages.isNotEmpty &&
                          _currentPage > 0 &&
                          _currentPage < _pages.length) {
                        _readPages.add(
                          _currentPage,
                        );

                        await _saveReadingHistoryProgress(
                          _currentPage,
                        );

                        _checkChapterProgress(
                          _currentPage,
                        );
                      }

                      await _saveReadingSession();

                      if (!mounted) {
                        return;
                      }

                      Navigator.maybePop(
                        context,
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: iconColor,
                    ),
                  ),

                  // ==================================================
                  // ACTIONS
                  // ==================================================

                  Row(
                    children: [
                      // ==================================================
                      // DOWNLOAD
                      // ==================================================

                      Consumer<DownloadProvider>(
                        builder: (
                          context,
                          downloadProvider,
                          child,
                        ) {
                          final isCurrentBookDownloading =
                              downloadProvider.isDownloading &&
                              downloadProvider.currentBookId ==
                                  widget.book.id.toString();

                          if (_checkingDownload) {
                            return const Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Color(0xFF9C6B3E),
                                ),
                              ),
                            );
                          }

                          return IconButton(
                            tooltip: _isBookDownloaded
                                ? 'Book downloaded'
                                : 'Download book',
                            onPressed:
                                isCurrentBookDownloading
                                    ? null
                                    : _downloadBook,
                            icon:
                                isCurrentBookDownloading
                                    ? SizedBox(
                                        width: 19,
                                        height: 19,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value:
                                              downloadProvider
                                                          .downloadProgress >
                                                      0
                                                  ? downloadProvider
                                                      .downloadProgress
                                                  : null,
                                          color:
                                              const Color(
                                            0xFF9C6B3E,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        _isBookDownloaded
                                            ? Icons
                                                .download_done_rounded
                                            : Icons
                                                .download_rounded,
                                        color:
                                            _isBookDownloaded
                                                ? const Color(
                                                    0xFF4CAF50,
                                                  )
                                                : iconColor,
                                        size: 21,
                                      ),
                          );
                        },
                      ),

                      // ==================================================
                      // CHAPTERS
                      // ==================================================

                      IconButton(
                        tooltip: 'Table of contents',
                        onPressed: _showChapterList,
                        icon: Icon(
                          Icons.format_list_bulleted_rounded,
                          color: iconColor,
                          size: 21,
                        ),
                      ),

                      // ==================================================
                      // FAVORITE
                      // ==================================================

                      Consumer<FavouriteBooksProvider>(
                        builder: (
                          context,
                          favoriteProvider,
                          child,
                        ) {
                          final isFavorite =
                              favoriteProvider.isFavorite(
                            widget.book,
                          );

                          return IconButton(
                            tooltip: isFavorite
                                ? 'Remove from favourites'
                                : 'Add to favourites',
                            onPressed: () {
                              _toggleFavorite(
                                favoriteProvider,
                              );
                            },
                            icon: AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 200,
                              ),
                              transitionBuilder: (
                                child,
                                animation,
                              ) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons
                                        .favorite_border_rounded,
                                key: ValueKey(
                                  isFavorite,
                                ),
                                color: isFavorite
                                    ? const Color(
                                        0xFFE85D75,
                                      )
                                    : iconColor,
                                size: 21,
                              ),
                            ),
                          );
                        },
                      ),

                      // ==================================================
                      // SEARCH
                      // ==================================================

                      IconButton(
                        tooltip: 'Search',
                        onPressed: () {
                          _showMessage(
                            'Search will be available soon.',
                          );
                        },
                        icon: Icon(
                          Icons.search_rounded,
                          color: iconColor,
                          size: 21,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // READER
            // ==================================================

            Expanded(
              child: _buildReader(
                textColor,
              ),
            ),

            // ==================================================
            // FONT SIZE
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                4,
                20,
                6,
              ),
              child: Row(
                children: [
                  const Text(
                    'Aa',
                    style: TextStyle(
                      fontSize: 13,
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                        overlayShape:
                            const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                        activeTrackColor:
                            const Color(0xFF3B82F6),
                        inactiveTrackColor:
                            mutedColor.withOpacity(0.3),
                        thumbColor:
                            const Color(0xFF3B82F6),
                      ),
                      child: Slider(
                        value: _fontSize,
                        min: _minFontSize,
                        max: _maxFontSize,
                        onChanged: (value) {
                          setState(() {
                            _fontSize = value;
                          });
                        },
                      ),
                    ),
                  ),

                  // ==================================================
                  // DAY / NIGHT
                  // ==================================================

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDayMode = !_isDayMode;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 6,
                      ),
                      child: Icon(
                        _isDayMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: const Color(0xFFE8A23D),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // PAGE INFORMATION
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                14,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activePage == null
                        ? '0 / 0'
                        : '${_activePage!.pageNumber} / ${_activePage!.totalPages}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: mutedColor,
                    ),
                  ),
                  Text(
                    _activePage == null
                        ? ''
                        : '${_activePage!.pagesLeftInChapter} pages left in chapter',
                    style: const TextStyle(
                      fontSize: 12,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // READER BODY
  // ============================================================

  Widget _buildReader(
    Color textColor,
  ) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF9C6B3E),
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              'Loading book...',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 48,
                color: textColor.withOpacity(0.5),
              ),
              const SizedBox(
                height: 14,
              ),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;

                    _errorMessage = null;
                  });

                  _loadBook();
                },
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_pages.isEmpty) {
      return Center(
        child: Text(
          'No readable content available.',
          style: TextStyle(
            color: textColor,
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: _pages.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (
        context,
        index,
      ) {
        return ReaderPageContent(
          page: _pages[index],
          fontSize: _fontSize,
          textColor: textColor,
          chapterLabelColor:
              const Color(0xFF9C6B3E),
        );
      },
    );
  }

  // ============================================================
  // CHAPTER LIST
  // ============================================================

  void _showChapterList() {
    if (_pages.isEmpty) {
      _showMessage(
        'No chapters available.',
      );

      return;
    }

    // ==========================================================
    // GET FIRST PAGE OF EACH CHAPTER
    // ==========================================================

    final Map<String, int> chapters = {};

    for (int i = 0; i < _pages.length; i++) {
      chapters.putIfAbsent(
        _pages[i].chapterLabel,
        () => i,
      );
    }

    // ==========================================================
    // BOTTOM SHEET
    // ==========================================================

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height *
                    0.65,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFF2E5D8),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color:
                              Color(0xFF9C6B3E),
                          size: 20,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chapters',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              'Jump to a chapter',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // CHAPTERS
                  // ==================================================

                  Expanded(
                    child: ListView.separated(
                      itemCount: chapters.length,
                      separatorBuilder: (
                        context,
                        index,
                      ) {
                        return const Divider(
                          height: 1,
                        );
                      },
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final entry =
                            chapters.entries.elementAt(
                          index,
                        );

                        final chapterPageIndex =
                            entry.value;

                        final chapterIndex =
                            _pages[
                              chapterPageIndex
                            ].chapterIndex;

                        // ==================================================
                        // CURRENT CHAPTER
                        // ==================================================

                        final isCurrent =
                            _pages[_currentPage]
                                    .chapterIndex ==
                                chapterIndex;

                        // ==================================================
                        // COMPLETED CHAPTER
                        // ==================================================

                        final isCompleted =
                            _completedChapterIndexes
                                .contains(
                          chapterIndex,
                        );

                        return ListTile(
                          contentPadding:
                              EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                isCompleted
                                    ? const Color(
                                        0xFF4CAF50,
                                      )
                                    : isCurrent
                                        ? const Color(
                                            0xFF9C6B3E,
                                          )
                                        : const Color(
                                            0xFFF2E5D8,
                                          ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isCurrent
                                          ? Colors.white
                                          : const Color(
                                              0xFF9C6B3E,
                                            ),
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                          ),
                          title: Text(
                            entry.key,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          trailing: isCompleted
                              ? const Icon(
                                  Icons
                                      .check_circle_rounded,
                                  color:
                                      Color(0xFF4CAF50),
                                  size: 20,
                                )
                              : const Icon(
                                  Icons
                                      .chevron_right_rounded,
                                  color: Colors.grey,
                                ),
                          onTap: () {
                            Navigator.pop(context);

                            // ==================================================
                            // IMPORTANT
                            //
                            // Chapter jump DOES NOT mark skipped pages.
                            //
                            // Only the page user lands on is handled
                            // through onPageChanged.
                            //
                            // ==================================================

                            _pageController.animateToPage(
                              entry.value,
                              duration:
                                  const Duration(
                                milliseconds: 400,
                              ),
                              curve: Curves.easeInOut,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// TEXT BLOCK
// ================================================================

class _TextBlock {
  final String chapter;

  final String title;

  final String text;

  const _TextBlock({
    required this.chapter,
    required this.title,
    required this.text,
  });
}

// ================================================================
// BOOK PAGE DATA
// ================================================================

class BookPageData {
  final String chapterLabel;

  final String title;

  final int pageNumber;

  final int totalPages;

  final int pagesLeftInChapter;

  final int chapterIndex;

  final List<String> paragraphs;

  const BookPageData({
    required this.chapterLabel,
    required this.title,
    required this.pageNumber,
    required this.totalPages,
    required this.pagesLeftInChapter,
    required this.chapterIndex,
    required this.paragraphs,
  });
}