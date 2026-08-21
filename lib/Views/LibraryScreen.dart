
// ignore_for_file: unused_field

import 'dart:async';

import 'package:BookVerse/Models/BookModel.dart';
import 'package:BookVerse/ViewModels/Book-view-model.dart';
import 'package:BookVerse/Views/BookDetails.dart';
import 'package:BookVerse/Widgets/Homewidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  State<MyLibraryScreen> createState() =>
      _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  static const primary = Color(0xFF6366F1);

  Timer? _searchTimer;

  bool _showSearch = false;
  String _searchQuery = '';

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<BookViewModel>().loadPopularBooks();
    });
  }

  // ------------------------------------------------------------
  // SEARCH
  // ------------------------------------------------------------

  void _onSearchChanged(String value) {
    final query = value.trim();

    _searchTimer?.cancel();

    setState(() {
      _searchQuery = query;
    });

    // Search empty -> 20 normal API books
    if (query.isEmpty) {
      context.read<BookViewModel>().clearSearch();
      return;
    }

    // Search API
    _searchTimer = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        context.read<BookViewModel>().searchBooks(query);
      },
    );
  }

  // ------------------------------------------------------------
  // CLOSE SEARCH
  // ------------------------------------------------------------

  void _closeSearch() {
    _searchTimer?.cancel();

    setState(() {
      _showSearch = false;
      _searchQuery = '';
    });

    context.read<BookViewModel>().clearSearch();
  }

  // ------------------------------------------------------------
  // OPEN DETAILS
  // ------------------------------------------------------------

  void _openBookDetails(BookModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailsScreen(
          book: book,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BookViewModel>();

    final bool isSearching =
        _searchQuery.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ------------------------------------------------
              // HEADER
              // ------------------------------------------------

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Library',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_showSearch) {
                            _closeSearch();
                          } else {
                            setState(() {
                              _showSearch = true;
                            });
                          }
                        },
                        icon: Icon(
                          _showSearch
                              ? Icons.close_rounded
                              : Icons.search_rounded,
                          color: Colors.black54,
                        ),
                      ),

                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.tune_rounded,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ------------------------------------------------
              // SEARCH BAR
              // ------------------------------------------------

              if (_showSearch) ...[
                const SizedBox(height: 6),

                BookSearchBar(
                  onChanged: _onSearchChanged,
                ),

                const SizedBox(height: 14),
              ],

              // ------------------------------------------------
              // BOOKS
              // ------------------------------------------------

              Expanded(
                child: isSearching
                    ? _buildSearchBooks(viewModel)
                    : _buildAllBooks(viewModel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ALL BOOKS
  // API SE 200 BOOKS
  // ============================================================

  Widget _buildAllBooks(
    BookViewModel viewModel,
  ) {
    if (viewModel.isLoading &&
        viewModel.popularBooks.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (viewModel.errorMessage != null &&
        viewModel.popularBooks.isEmpty) {
      return _buildErrorWidget(
        onRetry: () {
          context
              .read<BookViewModel>()
              .loadPopularBooks();
        },
      );
    }

    // ----------------------------------------------------------
    // EMPTY
    // ----------------------------------------------------------

    if (viewModel.popularBooks.isEmpty) {
      return const Center(
        child: Text(
          'No books available',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // ONLY 200 BOOKS
    // ----------------------------------------------------------

    final books =
        viewModel.popularBooks.take(200).toList();

    return ListView.builder(
      padding:
          const EdgeInsets.only(bottom: 20),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];

        // EXACT SAME FAMOUS BOOK CARD
        // FROM HOME SCREEN
        return _buildApiBookCard(book);
      },
    );
  }

  // ============================================================
  // SEARCH BOOKS
  // ============================================================

  Widget _buildSearchBooks(
    BookViewModel viewModel,
  ) {
    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (viewModel.isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (viewModel.errorMessage != null &&
        viewModel.searchResults.isEmpty) {
      return _buildErrorWidget(
        onRetry: () {
          if (_searchQuery.isNotEmpty) {
            context
                .read<BookViewModel>()
                .searchBooks(
                  _searchQuery,
                );
          }
        },
      );
    }

    // ----------------------------------------------------------
    // NO RESULTS
    // ----------------------------------------------------------

    if (viewModel.searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              'No books found',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // ----------------------------------------------------------
    // SEARCH RESULTS
    // MAX 1000
    // ----------------------------------------------------------

    final books =
        viewModel.searchResults.take(1000).toList();

    return ListView.builder(
      padding:
          const EdgeInsets.only(bottom: 20),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];

        // SAME HOME SCREEN FAMOUS BOOK WIDGET
        return _buildApiBookCard(book);
      },
    );
  }

  // ============================================================
  // EXACT FAMOUS BOOK CARD
  // SAME DESIGN AS BOOK HOME SCREEN
  // ============================================================

  Widget _buildApiBookCard(
    BookModel book,
  ) {
    return GestureDetector(
      onTap: () {
        _openBookDetails(book);
      },
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F9),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFECECF2),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // COVER
            // --------------------------------------------------

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),
              child: Image.network(
                book.imageUrl,
                width: 64,
                height: 88,
                fit: BoxFit.cover,
                loadingBuilder:
                    (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return Container(
                    width: 64,
                    height: 88,
                    color:
                        const Color(0xFFE5E5EC),
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) {
                  return Container(
                    width: 64,
                    height: 88,
                    color:
                        const Color(0xFFE5E5EC),
                    child: const Icon(
                      Icons
                          .menu_book_rounded,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 14),

            // --------------------------------------------------
            // BOOK INFORMATION
            // --------------------------------------------------

            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      book.author,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .local_fire_department_rounded,
                          color:
                              Color(0xFFF5A623),
                          size: 17,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          _formatDownloads(
                            book.downloadCount,
                          ),
                          style:
                              const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                Colors.black87,
                          ),
                        ),

                        const SizedBox(width: 4),

                        const Text(
                          'downloads',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 5),

            const Icon(
              Icons
                  .chevron_right_rounded,
              color: Colors.grey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR WIDGET
  // ============================================================

  Widget _buildErrorWidget({
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              const Color(0xFFF6F6F9),
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 34,
              color: Colors.grey,
            ),

            const SizedBox(height: 8),

            const Text(
              'Unable to load books',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: onRetry,
              child:
                  const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DOWNLOAD FORMAT
  // ============================================================

  String _formatDownloads(
    int count,
  ) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }

    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }

    return count.toString();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}

