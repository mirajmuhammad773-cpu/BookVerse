// lib/Screens/FantasyBooksScreen.dart

import 'dart:async';

import 'package:bookverse/Models/BookModel.dart';
import 'package:bookverse/ViewModels/Book-view-model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'BookDetails.dart';

class FantasyBooksScreen extends StatefulWidget {
  const FantasyBooksScreen({super.key});

  @override
  State<FantasyBooksScreen> createState() =>
      _FantasyBooksScreenState();
}

class _FantasyBooksScreenState
    extends State<FantasyBooksScreen> {
  static const Color purple = Color(0xFF6C4CE0);

  // ============================================================
  // SCREEN LIMIT
  // ============================================================

  static const int maxBooks = 200;

  final TextEditingController _searchController =
      TextEditingController();

  Timer? _searchDebounce;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = context.read<BookViewModel>();

      if (viewModel.fantasyBooks.isEmpty) {
        viewModel.loadFantasyBooks();
      }
    });
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (mounted) {
      setState(() {
        _searchQuery = query;
      });
    }

    _searchDebounce?.cancel();

    // ==========================================================
    // EMPTY SEARCH
    // ==========================================================

    if (query.isEmpty) {
      final viewModel = context.read<BookViewModel>();

      viewModel.clearFantasySearch();

      if (viewModel.fantasyBooks.isEmpty) {
        viewModel.loadFantasyBooks();
      }

      return;
    }

    // ==========================================================
    // SEARCH FROM FIRST LETTER
    // ==========================================================

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        context
            .read<BookViewModel>()
            .searchFantasyBooks(query);
      },
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // OPEN BOOK DETAILS
  // ============================================================

  void _openBookDetails(BookModel book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(
          book: book,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                8,
                8,
                16,
                8,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.black87,
                    ),
                  ),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fantasy Books',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Explore magical worlds',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // SEARCH BAR
            // ==================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFEAE8F2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction:
                      TextInputAction.search,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText:
                        'Search fantasy books...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13.5,
                    ),

                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Colors.grey,
                    ),

                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController
                                      .clear();
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.grey,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .auto_awesome_rounded,
                                color: purple,
                              ),

                    border: InputBorder.none,

                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // BOOK LIST
            // ==================================================

            Expanded(
              child: Consumer<BookViewModel>(
                builder: (
                  context,
                  viewModel,
                  child,
                ) {
                  // ==================================================
                  // SEARCH LOADING
                  // ==================================================

                  if (_searchQuery.isNotEmpty &&
                      viewModel.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: purple,
                      ),
                    );
                  }

                  // ==================================================
                  // INITIAL LOADING
                  // ==================================================

                  if (_searchQuery.isEmpty &&
                      viewModel.isLoading &&
                      viewModel.fantasyBooks.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: purple,
                      ),
                    );
                  }

                  // ==================================================
                  // CURRENT BOOKS
                  // ==================================================

                  final List<BookModel> books =
                      _getBooks(viewModel);

                  // ==================================================
                  // ERROR
                  // ==================================================

                  if (viewModel.errorMessage != null &&
                      books.isEmpty) {
                    return _buildError(viewModel);
                  }

                  // ==================================================
                  // EMPTY
                  // ==================================================

                  if (books.isEmpty) {
                    return _buildEmpty();
                  }

                  // ==================================================
                  // BOOK LIST
                  // ==================================================

                  return ListView.builder(
                    physics:
                        const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      2,
                      16,
                      25,
                    ),
                    itemCount: books.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final book = books[index];

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child:
                            _buildBookCard(book),
                      );
                    },
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
  // GET BOOKS
  // ============================================================

  List<BookModel> _getBooks(
    BookViewModel viewModel,
  ) {
    // ==========================================================
    // NORMAL MODE
    // ==========================================================
    //
    // Screen par maximum 200 fantasy books.
    //

    if (_searchQuery.isEmpty) {
      return viewModel.fantasyBooks
          .cast<BookModel>()
          .take(maxBooks)
          .toList();
    }

    // ==========================================================
    // SEARCH MODE
    // ==========================================================
    //
    // Search ke waqt 200 ki limit nahi.
    //
    // Repository/API jitni matching fantasy books return
    // karegi, woh sab show hongi.
    //

    return viewModel.fantasySearchResults
        .cast<BookModel>()
        .toList();
  }

  // ============================================================
  // BOOK CARD
  // ============================================================

  Widget _buildBookCard(BookModel book) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _openBookDetails(book);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFECECF2),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // COVER
              // ==================================================

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(10),
                child: Image.network(
                  book.imageUrl,
                  width: 68,
                  height: 94,
                  fit: BoxFit.cover,
                  loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                  ) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      width: 68,
                      height: 94,
                      color:
                          const Color(0xFFE5E5EC),
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: purple,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      width: 68,
                      height: 94,
                      color:
                          const Color(0xFFE5E5EC),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.grey,
                        size: 28,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              // ==================================================
              // BOOK INFO
              // ==================================================

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 3,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        book.author,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 12),

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
                            style:
                                TextStyle(
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

              // ==================================================
              // RIGHT ARROW
              // ==================================================

              const Padding(
                padding: EdgeInsets.only(
                  top: 34,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
    BookViewModel viewModel,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: Colors.grey,
            ),

            const SizedBox(height: 12),

            Text(
              _searchQuery.isNotEmpty
                  ? 'Unable to search fantasy books'
                  : 'Unable to load fantasy books',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 14),

            ElevatedButton(
              onPressed: () {
                if (_searchQuery.isNotEmpty) {
                  viewModel.searchFantasyBooks(
                    _searchQuery,
                  );
                } else {
                  viewModel.loadFantasyBooks();
                }
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            size: 45,
            color: Colors.grey,
          ),

          const SizedBox(height: 12),

          Text(
            _searchQuery.isEmpty
                ? 'No fantasy books available'
                : 'No fantasy books found',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 5),
            const Text(
              'Try another search.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // DOWNLOAD FORMAT
  // ============================================================

  String _formatDownloads(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }

    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }

    return count.toString();
  }
}