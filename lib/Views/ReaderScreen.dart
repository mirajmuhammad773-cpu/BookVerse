// ignore_for_file: unused_element

import 'dart:convert';

import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/Repository/Favoritebookprovider.dart';
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

class _ReaderScreenState extends State<ReaderScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final PageController _pageController = PageController();

  // ============================================================
  // READER STATE
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
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadBook();
  }

  // ============================================================
  // LOAD BOOK FROM API
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
      });
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
  // CREATE READER PAGES
  // ============================================================

  List<BookPageData> _createPages(String text) {
    String cleanText = text;

    // ----------------------------------------------------------
    // PROJECT GUTENBERG HEADER / FOOTER
    // ----------------------------------------------------------

    const startMarker =
        '*** START OF THE PROJECT GUTENBERG EBOOK';

    const endMarker =
        '*** END OF THE PROJECT GUTENBERG EBOOK';

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
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();

    if (cleanText.isEmpty) {
      return [];
    }

    // ----------------------------------------------------------
    // CHAPTER DETECTION
    // ----------------------------------------------------------

    final lines = cleanText.split('\n');

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

    // ----------------------------------------------------------
    // IF NO BLOCKS
    // ----------------------------------------------------------

    if (blocks.isEmpty) {
      return _splitPlainText(cleanText);
    }

    // ----------------------------------------------------------
    // CREATE PAGES
    // ----------------------------------------------------------

    const int charactersPerPage = 2600;

    final List<BookPageData> result = [];

    for (final block in blocks) {
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
            paragraphs: [
              chunk,
            ],
          ),
        );
      }
    }

    final totalPages = result.length;

    return result.map((page) {
      return BookPageData(
        chapterLabel: page.chapterLabel,
        title: page.title,
        pageNumber: page.pageNumber,
        totalPages: totalPages,
        pagesLeftInChapter:
            totalPages - page.pageNumber,
        paragraphs: page.paragraphs,
      );
    }).toList();
  }

  // ============================================================
  // CHAPTER CHECK
  // ============================================================

  bool _looksLikeChapter(String line) {
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
        result.add(remaining);
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
          .substring(splitIndex)
          .trim();
    }

    return result;
  }

  // ============================================================
  // DOWNLOAD BOOK
  // ============================================================

 
  // ============================================================
  // SAFE FILE NAME
  // ============================================================

  String _safeFileName(String name) {
    final cleaned = name
        .replaceAll(
          RegExp(r'[\\/:*?"<>|]'),
          '',
        )
        .trim();

    if (cleaned.isEmpty) {
      return 'book';
    }

    return cleaned;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
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
  // FAVORITE
  // ============================================================

  void _toggleFavorite(
    FavouriteBooksProvider provider,
  ) {
    final wasFavorite =
        provider.isFavorite(widget.book);

    provider.toggleFavorite(widget.book);

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
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
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
                  // BACK
                  IconButton(
                    onPressed: () {
                      Navigator.maybePop(
                        context,
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: iconColor,
                    ),
                  ),

                  // ACTIONS
                  Row(
                    children: [
                     
                      // ==================================================
                      // CHAPTERS
                      // ==================================================

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

                      // ==================================================
                      // FAVORITE
                      // ==================================================

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
                            icon: AnimatedSwitcher(
                              duration:
                                  const Duration(
                                milliseconds: 200,
                              ),
                              transitionBuilder:
                                  (
                                child,
                                animation,
                              ) {
                                return ScaleTransition(
                                  scale:
                                      animation,
                                  child: child,
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

            // ============================================================
            // READER
            // ============================================================

            Expanded(
              child: _buildReader(
                textColor,
              ),
            ),

            // ============================================================
            // FONT SIZE + BRIGHTNESS
            // ============================================================

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

                  const SizedBox(width: 5),

                  Expanded(
                    child: SliderTheme(
                      data:
                          SliderTheme.of(context)
                              .copyWith(
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

                  // ======================================================
                  // BRIGHTNESS
                  // ======================================================

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDayMode =
                            !_isDayMode;
                      });
                    },
                    child: Padding(
                      padding:
                          const EdgeInsets.only(
                        left: 6,
                      ),
                      child: Icon(
                        _isDayMode
                            ? Icons
                                .light_mode_rounded
                            : Icons
                                .dark_mode_rounded,
                        color: const Color(
                          0xFFE8A23D,
                        ),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // PAGE INFORMATION
            // ============================================================

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
    // ==========================================================
    // LOADING
    // ==========================================================

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

    // ==========================================================
    // ERROR
    // ==========================================================

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(30),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 48,
                color:
                    textColor.withOpacity(
                  0.5,
                ),
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
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================================
    // EMPTY
    // ==========================================================

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

    // ==========================================================
    // PAGE VIEW
    // ==========================================================

    return PageView.builder(
      controller: _pageController,
      itemCount: _pages.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
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
      backgroundColor: Colors.white,
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
                    CrossAxisAlignment.start,
                children: [
                  // --------------------------------------------------
                  // HEADER
                  // --------------------------------------------------

                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets
                                .all(
                          9,
                        ),
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
                        child: const Icon(
                          Icons.menu_book_rounded,
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
                                    Colors.grey,
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
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // --------------------------------------------------
                  // CHAPTERS
                  // --------------------------------------------------

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
                            chapters.entries
                                .elementAt(
                          index,
                        );

                        final isCurrent =
                            entry.value ==
                                _currentPage;

                        return ListTile(
                          contentPadding:
                              EdgeInsets.zero,

                          leading:
                              CircleAvatar(
                            backgroundColor:
                                isCurrent
                                    ? const Color(
                                        0xFF9C6B3E,
                                      )
                                    : const Color(
                                        0xFFF2E5D8,
                                      ),
                            child: Text(
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
                              isCurrent
                                  ? const Icon(
                                      Icons
                                          .check_circle_rounded,
                                      color:
                                          Color(
                                        0xFF9C6B3E,
                                      ),
                                      size: 20,
                                    )
                                  : const Icon(
                                      Icons
                                          .chevron_right_rounded,
                                      color:
                                          Colors.grey,
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
                              curve: Curves
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
  final List<String> paragraphs;

  const BookPageData({
    required this.chapterLabel,
    required this.title,
    required this.pageNumber,
    required this.totalPages,
    required this.pagesLeftInChapter,
    required this.paragraphs,
  });
}

// ================================================================
// READER PAGE CONTENT
// ================================================================

class ReaderPageContent
    extends StatelessWidget {
  final BookPageData page;
  final double fontSize;
  final Color textColor;
  final Color chapterLabelColor;

  const ReaderPageContent({
    super.key,
    required this.page,
    required this.fontSize,
    required this.textColor,
    required this.chapterLabelColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        28,
        20,
        28,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ======================================================
          // CHAPTER
          // ======================================================

          Text(
            page.chapterLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.bold,
              letterSpacing: 1.5,
              color:
                  chapterLabelColor,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // ======================================================
          // TITLE
          // ======================================================

          Text(
            page.title,
            style: TextStyle(
              fontSize: fontSize + 5,
              fontWeight:
                  FontWeight.bold,
              height: 1.25,
              color: textColor,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          // ======================================================
          // PARAGRAPHS
          // ======================================================

          ...page.paragraphs.map(
            (paragraph) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 18,
                ),
                child: Text(
                  paragraph,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.75,
                    color: textColor,
                  ),
                  textAlign:
                      TextAlign.left,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}