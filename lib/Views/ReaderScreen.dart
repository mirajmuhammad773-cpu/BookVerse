import 'dart:async';
import 'dart:convert';

import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/Repository/Favoritebookprovider.dart';
import 'package:bookverse/ViewModels/AchievementProvider.dart';
import 'package:bookverse/ViewModels/ReadingGoalProvider.dart';
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

  Timer? _readingTimer;

  // ============================================================
  // READER
  // ============================================================

  int _currentPage = 0;

  double _fontSize = 17;

  static const double _minFontSize = 14;
  static const double _maxFontSize = 24;

  bool _isDayMode = true;

  bool _isLoading = true;

  String? _errorMessage;

  List<BookPageData> _pages = [];

  // ============================================================
  // CHAPTER TRACKING
  // ============================================================

  final Set<int> _completedChapterIndexes = {};

  int _totalChapters = 0;

  bool _completionHandled = false;

  bool _completionInProgress = false;

  // ============================================================
  // READING TIME
  // ============================================================

  /// When the current active reading session started.
  DateTime? _readingSessionStart;

  /// Seconds that have already been saved to Provider.
  int _savedSessionSeconds = 0;

  /// Prevent multiple saves at the same time.
  bool _savingReadingTime = false;

  /// Prevent multiple lifecycle saves.
  bool _isReaderActive = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadBook();
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

      setState(() {
        _pages = pages;
        _isLoading = false;
        _errorMessage = null;
        _currentPage = 0;

        _completionHandled = false;
        _completionInProgress = false;

        _completedChapterIndexes.clear();

        _readingSessionStart = null;
        _savedSessionSeconds = 0;
        _savingReadingTime = false;
        _isReaderActive = false;
      });

      if (_pages.isNotEmpty) {
        _startReadingSession();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load this book. Please try again.';
      });
    }
  }

  // ============================================================
  // START READING SESSION
  // ============================================================

  void _startReadingSession() {
    if (!mounted) return;

    if (_pages.isEmpty) {
      return;
    }

    if (_readingSessionStart != null) {
      return;
    }

    _readingSessionStart = DateTime.now();

    _savedSessionSeconds = 0;

    _isReaderActive = true;

    // ----------------------------------------------------------
    // Provider session
    // ----------------------------------------------------------

    try {
      context.read<ReadingGoalProvider>().startReadingSession(
            book: widget.book,
          );
    } catch (_) {}

    // ----------------------------------------------------------
    // IMPORTANT
    //
    // Check reading time every 30 seconds.
    //
    // This means we don't have to wait only for dispose()
    // or page changes.
    // ----------------------------------------------------------

    _readingTimer?.cancel();

    _readingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        _checkAndSaveReadingTime();
      },
    );
  }

  // ============================================================
  // CHECK AND SAVE READING TIME
  // ============================================================

  Future<void> _checkAndSaveReadingTime() async {
    if (!mounted) return;

    if (!_isReaderActive) {
      return;
    }

    if (_readingSessionStart == null) {
      return;
    }

    if (_savingReadingTime) {
      return;
    }

    final elapsedSeconds =
        DateTime.now()
            .difference(_readingSessionStart!)
            .inSeconds;

    if (elapsedSeconds <= _savedSessionSeconds) {
      return;
    }

    final newSeconds =
        elapsedSeconds - _savedSessionSeconds;

    // ----------------------------------------------------------
    // Only completed minutes are saved.
    //
    // Example:
    //
    // 59 sec  -> 0 min
    // 60 sec  -> 1 min
    // 120 sec -> 2 min
    // 300 sec -> 5 min
    // ----------------------------------------------------------

    final minutesToSave =
        newSeconds ~/ 60;

    if (minutesToSave <= 0) {
      return;
    }

    final secondsToMarkAsSaved =
        minutesToSave * 60;

    _savedSessionSeconds +=
        secondsToMarkAsSaved;

    await _saveMinutesToProvider(
      minutesToSave,
    );
  }

  // ============================================================
  // SAVE MINUTES TO PROVIDER
  // ============================================================

  Future<void> _saveMinutesToProvider(
    int minutes,
  ) async {
    if (minutes <= 0) {
      return;
    }

    try {
      await context
          .read<ReadingGoalProvider>()
          .addReadingTime(minutes);
    } catch (_) {
      // --------------------------------------------------------
      // If Firestore fails, don't crash the reader.
      // --------------------------------------------------------
    }
  }

  // ============================================================
  // SAVE REMAINING SESSION
  // ============================================================

  Future<void> _saveRemainingReadingTime() async {
    if (_readingSessionStart == null) {
      return;
    }

    if (_savingReadingTime) {
      return;
    }

    _savingReadingTime = true;

    try {
      final elapsedSeconds =
          DateTime.now()
              .difference(_readingSessionStart!)
              .inSeconds;

      final remainingSeconds =
          elapsedSeconds -
              _savedSessionSeconds;

      if (remainingSeconds > 0) {
        final minutes =
            remainingSeconds ~/ 60;

        if (minutes > 0) {
          _savedSessionSeconds +=
              minutes * 60;

          await _saveMinutesToProvider(
            minutes,
          );
        }
      }
    } finally {
      _savingReadingTime = false;
    }
  }

  // ============================================================
  // STOP READING SESSION
  // ============================================================

  Future<void> _stopReadingSession() async {
    if (!_isReaderActive) {
      return;
    }

    _isReaderActive = false;

    _readingTimer?.cancel();

    _readingTimer = null;

    await _saveRemainingReadingTime();

    _readingSessionStart = null;

    _savedSessionSeconds = 0;

    // ----------------------------------------------------------
    // Reset Provider session too.
    // ----------------------------------------------------------

    try {
      await context
          .read<ReadingGoalProvider>()
          .saveReadingSession(
            book: widget.book,
            minutes: 0,
          );
    } catch (_) {}
  }

  // ============================================================
  // APP LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    super.didChangeAppLifecycleState(state);

    // ----------------------------------------------------------
    // APP GOES BACKGROUND
    // ----------------------------------------------------------

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _pauseReadingSession();

      return;
    }

    // ----------------------------------------------------------
    // APP RETURNS
    // ----------------------------------------------------------

    if (state == AppLifecycleState.resumed) {
      if (_pages.isNotEmpty && mounted) {
        _resumeReadingSession();
      }
    }
  }

  // ============================================================
  // PAUSE READING
  // ============================================================

  Future<void> _pauseReadingSession() async {
    if (!_isReaderActive) {
      return;
    }

    _isReaderActive = false;

    _readingTimer?.cancel();

    _readingTimer = null;

    await _saveRemainingReadingTime();

    _readingSessionStart = null;

    _savedSessionSeconds = 0;
  }

  // ============================================================
  // RESUME READING
  // ============================================================

  void _resumeReadingSession() {
    if (!mounted) return;

    if (_pages.isEmpty) {
      return;
    }

    if (_readingSessionStart != null) {
      return;
    }

    _startReadingSession();
  }

  // ============================================================
  // CREATE PAGES
  // ============================================================

  List<BookPageData> _createPages(String text) {
    String cleanText = text;

    const startMarker =
        '*** START OF THE PROJECT GUTENBERG EBOOK';

    const endMarker =
        '*** END OF THE PROJECT GUTENBERG EBOOK';

    final startIndex =
        cleanText.indexOf(startMarker);

    if (startIndex != -1) {
      final firstNewLine =
          cleanText.indexOf(
        '\n',
        startIndex,
      );

      if (firstNewLine != -1) {
        cleanText =
            cleanText.substring(
          firstNewLine + 1,
        );
      }
    }

    final endIndex =
        cleanText.indexOf(endMarker);

    if (endIndex != -1) {
      cleanText =
          cleanText.substring(
        0,
        endIndex,
      );
    }

    cleanText = cleanText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();

    if (cleanText.isEmpty) {
      return [];
    }

    final lines =
        cleanText.split('\n');

    final List<_TextBlock> blocks = [];

    String currentChapter = 'READING';

    String currentTitle = '';

    final StringBuffer paragraphBuffer =
        StringBuffer();

    void flushParagraph() {
      final paragraph =
          paragraphBuffer.toString().trim();

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

      final upper =
          line.toUpperCase();

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

    if (blocks.isEmpty) {
      return _splitPlainText(cleanText);
    }

    const charactersPerPage = 2600;

    final List<BookPageData> result = [];

    final Map<String, int> chapterIndexes = {};

    int nextChapterIndex = 0;

    for (final block in blocks) {
      if (!chapterIndexes.containsKey(
        block.chapter,
      )) {
        chapterIndexes[block.chapter] =
            nextChapterIndex;

        nextChapterIndex++;
      }

      final chapterIndex =
          chapterIndexes[block.chapter]!;

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
            pageNumber:
                result.length + 1,
            totalPages: 0,
            pagesLeftInChapter: 0,
            chapterIndex:
                chapterIndex,
            paragraphs: [chunk],
          ),
        );
      }
    }

    _totalChapters =
        nextChapterIndex;

    final totalPages =
        result.length;

    final Map<int, int>
        lastPageForChapter = {};

    for (int i = 0;
        i < result.length;
        i++) {
      lastPageForChapter[
          result[i].chapterIndex] = i;
    }

    return result.map((page) {
      final chapterLastPageIndex =
          lastPageForChapter[
              page.chapterIndex]!;

      final currentIndex =
          page.pageNumber - 1;

      final pagesLeft =
          chapterLastPageIndex -
              currentIndex;

      return BookPageData(
        chapterLabel:
            page.chapterLabel,
        title: page.title,
        pageNumber:
            page.pageNumber,
        totalPages:
            totalPages,
        pagesLeftInChapter:
            pagesLeft < 0
                ? 0
                : pagesLeft,
        chapterIndex:
            page.chapterIndex,
        paragraphs:
            page.paragraphs,
      );
    }).toList();
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
  // PLAIN TEXT
  // ============================================================

  List<BookPageData> _splitPlainText(
    String text,
  ) {
    const charactersPerPage = 2600;

    final chunks = _splitText(
      text,
      charactersPerPage,
    );

    final totalPages =
        chunks.length;

    _totalChapters =
        totalPages > 0 ? 1 : 0;

    return List.generate(
      totalPages,
      (index) {
        return BookPageData(
          chapterLabel: 'READING',
          title: widget.book.title,
          pageNumber: index + 1,
          totalPages: totalPages,
          pagesLeftInChapter:
              totalPages -
                  index -
                  1,
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

    String remaining =
        text.trim();

    while (remaining.isNotEmpty) {
      if (remaining.length <=
          maxCharacters) {
        result.add(remaining);

        break;
      }

      int splitIndex =
          remaining.lastIndexOf(
        '\n',
        maxCharacters,
      );

      if (splitIndex <
          maxCharacters ~/ 2) {
        splitIndex =
            remaining.lastIndexOf(
          ' ',
          maxCharacters,
        );
      }

      if (splitIndex <= 0) {
        splitIndex =
            maxCharacters;
      }

      final chunk =
          remaining
              .substring(
                0,
                splitIndex,
              )
              .trim();

      if (chunk.isNotEmpty) {
        result.add(chunk);
      }

      remaining =
          remaining
              .substring(splitIndex)
              .trim();
    }

    return result;
  }

  // ============================================================
  // PAGE CHANGE
  // ============================================================

  void _onPageChanged(
    int index,
  ) {
    if (!mounted) return;

    setState(() {
      _currentPage = index;
    });

    _checkChapterProgress(index);
  }

  // ============================================================
  // CHAPTER PROGRESS
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

    final page =
        _pages[pageIndex];

    final chapterIndex =
        page.chapterIndex;

    if (page.pagesLeftInChapter ==
        0) {
      if (!_completedChapterIndexes
          .contains(chapterIndex)) {
        _completedChapterIndexes.add(
          chapterIndex,
        );

        if (mounted) {
          setState(() {});
        }
      }
    }

    _checkWholeBookCompletion(
      pageIndex,
    );
  }

  // ============================================================
  // WHOLE BOOK COMPLETION
  // ============================================================

  void _checkWholeBookCompletion(
    int pageIndex,
  ) {
    if (_pages.isEmpty) {
      return;
    }

    final isLastPage =
        pageIndex ==
            _pages.length - 1;

    if (!isLastPage) {
      return;
    }

    final allChaptersCompleted =
        _completedChapterIndexes.length >=
            _totalChapters;

    if (!allChaptersCompleted) {
      _showMessage(
        'Please read all chapters before completing this book.',
      );

      return;
    }

    _handleBookCompletion();
  }

  // ============================================================
  // BOOK COMPLETION
  // ============================================================

  Future<void> _handleBookCompletion() async {
    if (_completionHandled ||
        _completionInProgress) {
      return;
    }

    if (_pages.isEmpty) {
      return;
    }

    if (_currentPage !=
        _pages.length - 1) {
      return;
    }

    if (_completedChapterIndexes.length <
        _totalChapters) {
      return;
    }

    _completionInProgress = true;

    try {
      // --------------------------------------------------------
      // Make sure all current reading time is saved.
      // --------------------------------------------------------

      await _saveRemainingReadingTime();

      if (!mounted) {
        return;
      }

      final readingGoalProvider =
          context.read<ReadingGoalProvider>();

      final achievementProvider =
          context.read<AchievementProvider>();

      // --------------------------------------------------------
      // READING GOAL
      // FIRST COMPLETION ONLY
      // --------------------------------------------------------

      final readingGoalAlreadyCompleted =
          readingGoalProvider
              .isBookCompleted(
        widget.book.id.toString(),
      );

      bool readingGoalSuccess = true;

      if (!readingGoalAlreadyCompleted) {
        readingGoalSuccess =
            await readingGoalProvider
                .addCompletedBook(
          widget.book.id.toString(),
        );
      }

      // --------------------------------------------------------
      // ACHIEVEMENT
      // FIRST COMPLETION ONLY
      // --------------------------------------------------------

      final achievementAlreadyCompleted =
          achievementProvider
              .isBookCompleted(
        widget.book,
      );

      bool achievementSuccess = true;

      if (!achievementAlreadyCompleted) {
        achievementSuccess =
            await achievementProvider
                .completeBook(
          widget.book,
        );
      }

      if (!mounted) {
        return;
      }

      if (readingGoalSuccess &&
          achievementSuccess) {
        _completionHandled = true;

        _completionInProgress = false;

        if (!readingGoalAlreadyCompleted ||
            !achievementAlreadyCompleted) {
          _showMessage(
            '🎉 Book completed! You earned a reading reward.',
          );
        }

        return;
      }

      _completionInProgress = false;

      _showMessage(
        readingGoalProvider.errorMessage ??
            achievementProvider.errorMessage ??
            'Unable to save book completion.',
      );
    } catch (_) {
      _completionInProgress = false;

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
    final wasFavorite =
        provider.isFavorite(
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

    if (_currentPage >=
        _pages.length) {
      return _pages.last;
    }

    return _pages[_currentPage];
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

    final Map<String, int> chapters = {};

    for (int i = 0;
        i < _pages.length;
        i++) {
      chapters.putIfAbsent(
        _pages[i].chapterLabel,
        () => i,
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.white,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.of(context)
                        .size
                        .height *
                    0.65,
            child: Padding(
              padding:
                  const EdgeInsets.all(
                20,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets
                                .all(9),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFF2E5D8,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons
                              .menu_book_rounded,
                          color:
                              Color(
                            0xFF9C6B3E,
                          ),
                          size: 20,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Chapters',
                              style:
                                  TextStyle(
                                fontSize:
                                    19,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              'Jump to a chapter',
                              style:
                                  TextStyle(
                                fontSize:
                                    12,
                                color:
                                    Colors
                                        .grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        icon:
                            const Icon(
                          Icons
                              .close_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Expanded(
                    child:
                        ListView.separated(
                      itemCount:
                          chapters.length,
                      separatorBuilder:
                          (
                        context,
                        index,
                      ) {
                        return const Divider(
                          height: 1,
                        );
                      },
                      itemBuilder:
                          (
                        context,
                        index,
                      ) {
                        final entry =
                            chapters
                                .entries
                                .elementAt(
                          index,
                        );

                        final chapterPageIndex =
                            entry.value;

                        final chapterIndex =
                            _pages[
                              chapterPageIndex
                            ].chapterIndex;

                        final isCurrent =
                            _pages[
                                  _currentPage
                                ].chapterIndex ==
                                chapterIndex;

                        final isCompleted =
                            _completedChapterIndexes
                                .contains(
                          chapterIndex,
                        );

                        return ListTile(
                          contentPadding:
                              EdgeInsets
                                  .zero,
                          leading:
                              CircleAvatar(
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
                                    Icons
                                        .check_rounded,
                                    color:
                                        Colors
                                            .white,
                                    size: 19,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style:
                                        TextStyle(
                                      color:
                                          isCurrent
                                              ? Colors
                                                  .white
                                              : const Color(
                                                  0xFF9C6B3E,
                                                ),
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                          ),
                          title: Text(
                            entry.key,
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isCurrent
                                      ? FontWeight
                                          .w700
                                      : FontWeight
                                          .w500,
                            ),
                          ),
                          trailing:
                              isCompleted
                                  ? const Icon(
                                      Icons
                                          .check_circle_rounded,
                                      color:
                                          Color(
                                        0xFF4CAF50,
                                      ),
                                      size: 20,
                                    )
                                  : const Icon(
                                      Icons
                                          .chevron_right_rounded,
                                      color:
                                          Colors
                                              .grey,
                                    ),
                          onTap: () {
                            Navigator.pop(
                              context,
                            );

                            _pageController
                                .animateToPage(
                              entry.value,
                              duration:
                                  const Duration(
                                milliseconds:
                                    400,
                              ),
                              curve:
                                  Curves
                                      .easeInOut,
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
          behavior:
              SnackBarBehavior.floating,
          duration:
              const Duration(
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
    // ----------------------------------------------------------
    // Cancel periodic timer.
    // ----------------------------------------------------------

    _readingTimer?.cancel();

    _readingTimer = null;

    // ----------------------------------------------------------
    // We intentionally don't depend only on dispose for saving.
    // The periodic timer + lifecycle already saves the time.
    // ----------------------------------------------------------

    WidgetsBinding.instance
        .removeObserver(this);

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

    const mutedColor =
        Color(0xFF8A8375);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // TOP BAR
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async {
                      await _stopReadingSession();

                      if (!mounted) return;

                      Navigator.maybePop(
                        context,
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: iconColor,
                    ),
                  ),

                  Row(
                    children: [
                      IconButton(
                        tooltip:
                            'Table of contents',
                        onPressed:
                            _showChapterList,
                        icon: Icon(
                          Icons
                              .format_list_bulleted_rounded,
                          color: iconColor,
                          size: 21,
                        ),
                      ),

                      Consumer<
                          FavouriteBooksProvider>(
                        builder: (
                          context,
                          favoriteProvider,
                          child,
                        ) {
                          final isFavorite =
                              favoriteProvider
                                  .isFavorite(
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
                            icon:
                                AnimatedSwitcher(
                              duration:
                                  const Duration(
                                milliseconds:
                                    200,
                              ),
                              transitionBuilder:
                                  (
                                child,
                                animation,
                              ) {
                                return ScaleTransition(
                                  scale:
                                      animation,
                                  child:
                                      child,
                                );
                              },
                              child: Icon(
                                isFavorite
                                    ? Icons
                                        .favorite_rounded
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

                      IconButton(
                        tooltip: 'Search',
                        onPressed: () {
                          _showMessage(
                            'Search will be available soon.',
                          );
                        },
                        icon: Icon(
                          Icons
                              .search_rounded,
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
              padding:
                  const EdgeInsets.fromLTRB(
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
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  Expanded(
                    child:
                        SliderTheme(
                      data:
                          SliderTheme.of(
                        context,
                      ).copyWith(
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(
                          enabledThumbRadius:
                              8,
                        ),
                        overlayShape:
                            const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                        activeTrackColor:
                            const Color(
                          0xFF3B82F6,
                        ),
                        inactiveTrackColor:
                            mutedColor
                                .withOpacity(
                          0.3,
                        ),
                        thumbColor:
                            const Color(
                          0xFF3B82F6,
                        ),
                      ),
                      child: Slider(
                        value: _fontSize,
                        min:
                            _minFontSize,
                        max:
                            _maxFontSize,
                        onChanged:
                            (value) {
                          setState(() {
                            _fontSize =
                                value;
                          });
                        },
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDayMode =
                            !_isDayMode;
                      });
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        left: 6,
                      ),
                      child: Icon(
                        _isDayMode
                            ? Icons
                                .light_mode_rounded
                            : Icons
                                .dark_mode_rounded,
                        color:
                            const Color(
                          0xFFE8A23D,
                        ),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // PAGE INFO
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                14,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Text(
                    _activePage == null
                        ? '0 / 0'
                        : '${_activePage!.pageNumber} / ${_activePage!.totalPages}',
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          mutedColor,
                    ),
                  ),
                  Text(
                    _activePage == null
                        ? ''
                        : '${_activePage!.pagesLeftInChapter} pages left in chapter',
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          mutedColor,
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
          mainAxisSize:
              MainAxisSize.min,
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
          padding:
              const EdgeInsets.all(
            30,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons
                    .menu_book_rounded,
                size: 48,
                color: textColor
                    .withOpacity(0.5),
              ),
              const SizedBox(
                height: 14,
              ),
              Text(
                _errorMessage!,
                textAlign:
                    TextAlign.center,
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
                child:
                    const Text('Retry'),
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
      controller:
          _pageController,
      itemCount:
          _pages.length,
      onPageChanged:
          _onPageChanged,
      itemBuilder:
          (
        context,
        index,
      ) {
        return ReaderPageContent(
          page: _pages[index],
          fontSize: _fontSize,
          textColor: textColor,
          chapterLabelColor:
              const Color(
            0xFF9C6B3E,
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