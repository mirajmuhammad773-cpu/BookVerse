import 'package:BookVerse/Models/BookModel.dart';
import 'package:BookVerse/Models/ReadingHistoryModel.dart';
import 'package:BookVerse/ViewModels/ReadingHistoryProvider.dart';
import 'package:BookVerse/Views/BookDetails.dart';
import 'package:BookVerse/Widgets/ReadingHistoryWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReadingHistoryScreen extends StatefulWidget {
  const ReadingHistoryScreen({
    super.key,
  });

  @override
  State<ReadingHistoryScreen> createState() =>
      _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState
    extends State<ReadingHistoryScreen> {
  static const _primary = Color(0xFF6366F1);

  int _selectedFilter = 0;

  final _filters = const [
    'All',
    'In Progress',
    'Completed',
    'Saved',
  ];

  String _searchQuery = '';

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatLastRead(
    DateTime date,
  ) {
    final now = DateTime.now();

    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24 &&
        now.day == date.day) {
      final hour =
          date.hour % 12 == 0
              ? 12
              : date.hour % 12;

      final minute =
          date.minute.toString().padLeft(2, '0');

      final period =
          date.hour >= 12 ? 'PM' : 'AM';

      return 'Today, $hour:$minute $period';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<ReadingHistoryModel> _visibleHistory(
    List<ReadingHistoryModel> history,
  ) {
    List<ReadingHistoryModel> result = history;

    // SEARCH
    if (_searchQuery.trim().isNotEmpty) {
      final query =
          _searchQuery.trim().toLowerCase();

      result = result.where((book) {
        return book.title
                .toLowerCase()
                .contains(query) ||
            book.author
                .toLowerCase()
                .contains(query);
      }).toList();
    }

    // FILTER
    if (_selectedFilter == 0) {
      return result;
    }

    final label =
        _filters[_selectedFilter];

    if (label == 'Completed') {
      return result
          .where(
            (book) => book.completed,
          )
          .toList();
    }

    return result
        .where(
          (book) => book.status == label,
        )
        .toList();
  }

  // ============================================================
  // OPEN BOOK DETAILS
  // ============================================================

  void _openBookDetails(
    ReadingHistoryModel historyBook,
  ) {
    final selectedBook = BookModel(
      id: int.tryParse(historyBook.bookId) ?? 0,
      title: historyBook.title,
      author: historyBook.author,
      imageUrl: historyBook.imageUrl,
      downloadCount: 0,
      textUrl: '',
      description:
          'Continue reading ${historyBook.title}.',
      language: 'EN',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(
          book: selectedBook,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.maybePop(
                      context,
                    ),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      'Reading History',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      context
                          .read<
                              ReadingHistoryProvider>()
                          .refresh();
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // SEARCH
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF3F3F7),
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery =
                                value;
                          });
                        },
                        decoration:
                            const InputDecoration(
                          border:
                              InputBorder.none,
                          hintText:
                              'Search books...',
                          hintStyle:
                              TextStyle(
                            color: Colors.grey,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // FILTERS
            // ==================================================

            SizedBox(
              height: 38,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                scrollDirection:
                    Axis.horizontal,
                itemCount:
                    _filters.length,
                separatorBuilder:
                    (_, __) =>
                        const SizedBox(
                  width: 10,
                ),
                itemBuilder:
                    (
                  context,
                  index,
                ) {
                  final isSelected =
                      _selectedFilter ==
                          index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter =
                            index;
                      });
                    },
                    child:
                        AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 180,
                      ),
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                      ),
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color: isSelected
                            ? _primary
                            : const Color(
                                0xFFF3F3F7,
                              ),
                        borderRadius:
                            BorderRadius
                                .circular(20),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black54,
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ==================================================
            // HISTORY
            // ==================================================

            Expanded(
              child: Consumer<
                  ReadingHistoryProvider>(
                builder: (
                  context,
                  provider,
                  child,
                ) {
                  // LOADING
                  if (provider.isLoading &&
                      !provider.isInitialized) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color: _primary,
                      ),
                    );
                  }

                  final history =
                      _visibleHistory(
                    provider.history,
                  );

                  // EMPTY
                  if (history.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons
                                .menu_book_rounded,
                            size: 52,
                            color: Colors
                                .grey
                                .shade300,
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          const Text(
                            'No reading history yet.',
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                              fontSize: 14,
                              fontWeight:
                                  FontWeight
                                      .w500,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          const Text(
                            'Start reading a book to see it here.',
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // LIST
                  return RefreshIndicator(
                    color: _primary,
                    onRefresh:
                        provider.refresh,
                    child: ListView(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 18,
                      ),
                      children: [
                        for (final book
                            in history)
                          ReadingHistoryItem(
                            book:
                                ReadingHistoryData(
                              title:
                                  book.title,
                              author:
                                  book.author,
                              imageUrl:
                                  book.imageUrl,
                              lastRead:
                                  _formatLastRead(
                                book.lastRead,
                              ),
                              progress:
                                  book.progress,
                              status:
                                  book.status,
                            ),

                            // ==================================================
                            // BOOK CLICK
                            // ==================================================
                            //
                            // Reading History
                            //      ↓
                            // BookDetailsScreen
                            //      ↓
                            // Read Now
                            //      ↓
                            // ReaderScreen
                            //
                            onTap: () {
                              _openBookDetails(
                                book,
                              );
                            },

                            onMenuTap: () {
                              _showBookMenu(
                                context,
                                book,
                              );
                            },
                          ),

                        const SizedBox(
                          height: 4,
                        ),

                        Center(
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons
                                    .access_time_rounded,
                                size: 13,
                                color: Colors
                                    .grey
                                    .shade400,
                              ),

                              const SizedBox(
                                width: 6,
                              ),

                              Text(
                                'History shows the last 50 books you read',
                                style:
                                    TextStyle(
                                  fontSize:
                                      11.5,
                                  color: Colors
                                      .grey
                                      .shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MENU
  // ============================================================

  void _showBookMenu(
    BuildContext context,
    ReadingHistoryModel book,
  ) {
    showModalBottomSheet(
      context: context,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons
                      .delete_outline_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  'Remove from history',
                ),
                onTap: () async {
                  Navigator.pop(
                    sheetContext,
                  );

                  await context
                      .read<
                          ReadingHistoryProvider>()
                      .deleteHistory(
                    book.bookId,
                  );
                },
              ),

              const SizedBox(
                height: 8,
              ),
            ],
          ),
        );
      },
    );
  }
}